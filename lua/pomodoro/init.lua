local M = {}

-- ============================================================================
-- Config
-- ============================================================================

local WORK_MINS = 25
local SHORT_BREAK_MINS = 5
local LONG_BREAK_MINS = 15
local CYCLES_BEFORE_LONG = 4
local ESCALATION_DELAY_SECS = 30
local POLL_INTERVAL_MS = 500
local STALE_TRANSITION_SECS = 5
local TRANSITION_RACE_DELAY_MS = 20

-- ============================================================================
-- Per-instance identity (for transition ownership)
-- ============================================================================

-- hrtime() gives nanosecond precision — effectively unique per process
local INSTANCE_ID = tostring(vim.uv.hrtime())

-- ============================================================================
-- Dependencies
-- ============================================================================

local store = require("pomodoro.store")
local timer_mod = require("pomodoro.timer")
local dialog = require("pomodoro.dialog")
local music = require("pomodoro.music")
local overlay = require("pomodoro.overlay")
local format_time = require("pomodoro.util").format_time

-- ============================================================================
-- Display cache (derived from store on each poll tick, used by lualine)
-- ============================================================================

local cache = {
  phase = nil,
  remaining = 0,
  cycle = 0,
  escalation = nil,
  paused = false,
}

local flash_toggle = false
local dialog_is_open = false

-- ============================================================================
-- Helpers
-- ============================================================================

--- Compute seconds remaining from state file timestamps.
---@param state table
---@return number
local function compute_remaining(state)
  if state.phase == nil then return 0 end
  if state.paused_at then return state.paused_remaining or 0 end
  local elapsed = os.time() - (state.phase_start or 0)
  return math.max(0, (state.phase_duration or 0) - elapsed)
end

-- ============================================================================
-- Break overlay (local UI — only opens in the instance that initiated break)
-- ============================================================================

local handle_break_phase_complete  -- forward declaration

local function start_break_overlay(state)
  local phase = state.phase
  local remaining = compute_remaining(state)
  local break_label = phase == "short_break" and "Short Break" or "Long Break"

  overlay.open({
    title = break_label,
    duration_secs = remaining,
    cycle_info = "Cycle " .. state.cycle .. "/" .. CYCLES_BEFORE_LONG,
  }, {
    on_complete = function()
      handle_break_phase_complete()
    end,
    on_stop = function()
      M.stop()
    end,
  })
end

-- ============================================================================
-- Phase transitions
-- ============================================================================

--- Work phase complete: claim transition and advance to escalation.
local function handle_work_phase_complete()
  local state = store.read()
  if not state or state.phase ~= "work" then return end
  if state.transitioning then
    if state.transition_started_at
        and (os.time() - state.transition_started_at) < STALE_TRANSITION_SECS then
      return
    end
  end

  -- Claim the transition
  state.transitioning = true
  state.transition_started_at = os.time()
  state.transition_owner = INSTANCE_ID
  store.write(state)

  -- Verify ownership after brief race window
  vim.defer_fn(function()
    local latest = store.read()
    if not latest or latest.transition_owner ~= INSTANCE_ID then return end

    latest.transitioning = false
    latest.transition_started_at = nil
    latest.transition_owner = nil
    latest.escalation = "notified"
    latest.escalation_deadline = os.time() + ESCALATION_DELAY_SECS
    store.write(latest)

    music.pause()
    local msg = "Work session complete — time for a break!"
    vim.notify(msg, vim.log.levels.WARN)
    if vim.fn.executable("notify-send") == 1 then
      vim.fn.jobstart({ "notify-send", "Pomodoro", msg })
    end
  end, TRANSITION_RACE_DELAY_MS)
end

--- Break phase complete: claim transition and start next work session.
--- Called by overlay on_complete AND by poll (handles orphaned break if overlay
--- instance was closed before break ended).
handle_break_phase_complete = function()
  local state = store.read()
  if not state then return end
  if state.phase == "work" then return end  -- already transitioned
  if state.transitioning then
    if state.transition_started_at
        and (os.time() - state.transition_started_at) < STALE_TRANSITION_SECS then
      return
    end
  end

  state.transitioning = true
  state.transition_started_at = os.time()
  state.transition_owner = INSTANCE_ID
  store.write(state)

  vim.defer_fn(function()
    local latest = store.read()
    if not latest or latest.transition_owner ~= INSTANCE_ID then return end

    local next_cycle = (latest.cycle % CYCLES_BEFORE_LONG) + 1
    store.write({
      phase = "work",
      cycle = next_cycle,
      phase_start = os.time(),
      phase_duration = WORK_MINS * 60,
      paused_at = nil,
      paused_remaining = nil,
      escalation = nil,
      escalation_deadline = nil,
      transitioning = false,
      transition_started_at = nil,
      transition_owner = nil,
      version = 1,
    })
    music.play()
    local msg = "Break over — back to work!"
    vim.notify(msg, vim.log.levels.INFO)
    if vim.fn.executable("notify-send") == 1 then
      vim.fn.jobstart({ "notify-send", "Pomodoro", msg })
    end
  end, TRANSITION_RACE_DELAY_MS)
end

-- ============================================================================
-- Escalation dialog
-- ============================================================================

local open_escalation_dialog

open_escalation_dialog = function()
  local state = store.read()
  if not state then return end

  local cycle = state.cycle or 1
  local is_long = cycle >= CYCLES_BEFORE_LONG
  local break_mins = is_long and LONG_BREAK_MINS or SHORT_BREAK_MINS
  local break_type = is_long and "long break" or "short break"

  local header_lines = {
    "Work session complete!",
    "Cycle " .. cycle .. "/" .. CYCLES_BEFORE_LONG
      .. " — You've been focused for " .. WORK_MINS .. " minutes.",
    "Next break: " .. break_mins .. "-minute " .. break_type .. ".",
  }

  dialog_is_open = true
  dialog.open({ title = "Pomodoro", header_lines = header_lines }, function(action)
    dialog_is_open = false
    local s = store.read()
    if not s then return end

    if action == "break" then
      local phase = (s.cycle or 1) >= CYCLES_BEFORE_LONG and "long_break" or "short_break"
      local mins = (s.cycle or 1) >= CYCLES_BEFORE_LONG and LONG_BREAK_MINS or SHORT_BREAK_MINS
      local next_state = {
        phase = phase,
        cycle = s.cycle,
        phase_start = os.time(),
        phase_duration = mins * 60,
        paused_at = nil,
        paused_remaining = nil,
        escalation = nil,
        escalation_deadline = nil,
        transitioning = false,
        transition_started_at = nil,
        transition_owner = nil,
        version = 1,
      }
      store.write(next_state)
      start_break_overlay(next_state)
    elseif action == "stop" then
      M.stop()
    end
  end)
end

-- ============================================================================
-- Poll loop (fires every POLL_INTERVAL_MS, reads store, drives all state)
-- ============================================================================

local function on_poll()
  local state = store.read()

  -- No active session
  if not state or state.phase == nil then
    if cache.phase ~= nil then
      cache.phase = nil
      cache.remaining = 0
      cache.cycle = 0
      cache.escalation = nil
      cache.paused = false
      if dialog_is_open then dialog.close(); dialog_is_open = false end
      if overlay.is_open() then overlay.close() end
      vim.cmd("redrawstatus")
    end
    return
  end

  local remaining = compute_remaining(state)

  -- Update display cache
  cache.phase = state.phase
  cache.remaining = remaining
  cache.cycle = state.cycle or 1
  cache.escalation = state.escalation
  cache.paused = state.paused_at ~= nil

  -- Escalation deadline: any instance advances "notified" → "dialog"
  if state.escalation == "notified"
      and state.escalation_deadline
      and os.time() >= state.escalation_deadline
      and not state.paused_at then
    local fresh = store.read()
    if fresh and fresh.escalation == "notified" and fresh.escalation_deadline then
      fresh.escalation = "dialog"
      fresh.escalation_deadline = nil
      store.write(fresh)
    end
  end

  -- Escalation dialog open/close coordination
  local esc = state.escalation
  if esc == "dialog" and not dialog_is_open and state.phase == "work" then
    open_escalation_dialog()
  elseif dialog_is_open and (esc == nil or state.phase ~= "work") then
    dialog.close()
    dialog_is_open = false
  end

  -- Phase completion detection
  if state.phase == "work" and remaining <= 0 and not state.transitioning then
    handle_work_phase_complete()
  elseif (state.phase == "short_break" or state.phase == "long_break")
      and remaining <= 0
      and not state.transitioning
      and not overlay.is_open() then
    -- Handles orphaned break: overlay instance was closed before break ended
    handle_break_phase_complete()
  end

  vim.cmd("redrawstatus")
end

-- ============================================================================
-- Public API
-- ============================================================================

function M.start()
  if dialog_is_open then dialog.close(); dialog_is_open = false end
  if overlay.is_open() then overlay.close() end

  store.write({
    phase = "work",
    cycle = 1,
    phase_start = os.time(),
    phase_duration = WORK_MINS * 60,
    paused_at = nil,
    paused_remaining = nil,
    escalation = nil,
    escalation_deadline = nil,
    transitioning = false,
    transition_started_at = nil,
    transition_owner = nil,
    version = 1,
  })
  music.play()
  vim.notify(
    "🔥 Work session 1/" .. CYCLES_BEFORE_LONG .. " — " .. WORK_MINS .. " minutes",
    vim.log.levels.INFO
  )
  vim.cmd("redrawstatus")
end

function M.toggle_pause()
  local state = store.read()
  if not state or state.phase == nil then return end
  if overlay.is_open() then return end  -- breaks cannot be paused

  -- Re-read immediately before writing to reduce lost-update window
  local current = store.read()
  if not current or current.phase == nil then return end

  if current.paused_at then
    -- Resume: reconstruct phase_start so remaining is preserved
    local remaining = current.paused_remaining or 0
    current.phase_start = os.time() - ((current.phase_duration or 0) - remaining)
    current.paused_at = nil
    current.paused_remaining = nil
    store.write(current)
    if not current.escalation then music.play() end
    vim.notify("Pomodoro resumed", vim.log.levels.INFO)
  else
    -- Pause: snapshot current remaining
    local remaining = compute_remaining(current)
    current.paused_at = os.time()
    current.paused_remaining = remaining
    store.write(current)
    if dialog_is_open then dialog.close(); dialog_is_open = false end
    music.pause()
    vim.notify("Pomodoro paused", vim.log.levels.INFO)
  end
  vim.cmd("redrawstatus")
end

function M.stop()
  if overlay.is_open() then overlay.close() end
  if dialog_is_open then dialog.close(); dialog_is_open = false end
  music.pause()
  store.clear()
  cache.phase = nil
  cache.remaining = 0
  cache.cycle = 0
  cache.escalation = nil
  cache.paused = false
  vim.notify("Pomodoro stopped", vim.log.levels.INFO)
  vim.cmd("redrawstatus")
end

-- ============================================================================
-- Lualine component
-- ============================================================================

function M.is_active()
  return cache.phase ~= nil
end

function M.lualine()
  if cache.phase == nil then return "" end

  local icon = cache.phase == "work" and "🔥" or "☕"

  if cache.escalation then
    flash_toggle = not flash_toggle
    if flash_toggle then icon = icon .. " ⚠" end
  end

  if cache.paused then icon = icon .. " ⏸" end

  local time = format_time(cache.remaining)
  if cache.phase == "work" then
    return icon .. " " .. time .. " [" .. cache.cycle .. "/" .. CYCLES_BEFORE_LONG .. "]"
  else
    return icon .. " " .. time
  end
end

-- ============================================================================
-- Module init: start poll loop immediately on require
-- ============================================================================

timer_mod.start(POLL_INTERVAL_MS, on_poll)

return M
