-- Run with: nvim --headless -u init.lua -c "luafile test_pomodoro_store.lua" -c "quit"
local errors = {}
local function fail(msg) table.insert(errors, msg) end
local function assert_eq(label, got, want)
  if got ~= want then
    fail(label .. ": want=" .. tostring(want) .. " got=" .. tostring(got))
  end
end
local function assert_nil(label, got)
  if got ~= nil then fail(label .. ": want=nil got=" .. tostring(got)) end
end

local store = require("pomodoro.store")

-- 1: read on empty store returns nil
store.clear()
assert_nil("read_empty", store.read())

-- 2: write and read back basic fields
local s = {
  phase = "work", cycle = 2, phase_start = 1000000, phase_duration = 1500,
  paused_at = nil, paused_remaining = nil,
  escalation = nil, escalation_deadline = nil,
  transitioning = false, transition_started_at = nil, transition_owner = nil,
  version = 1,
}
store.write(s)
local got = store.read()
assert_eq("phase", got.phase, "work")
assert_eq("cycle", got.cycle, 2)
assert_eq("phase_duration", got.phase_duration, 1500)
assert_eq("transitioning", got.transitioning, false)
assert_nil("escalation", got.escalation)

-- 3: overwrite and verify latest value wins
s.phase = "short_break"
s.cycle = 3
store.write(s)
local got2 = store.read()
assert_eq("overwrite_phase", got2.phase, "short_break")
assert_eq("overwrite_cycle", got2.cycle, 3)

-- 4: clear removes state
store.clear()
assert_nil("after_clear", store.read())

-- 5: path() returns a non-empty string
local p = store.path()
assert_eq("path_type", type(p), "string")
if p == "" then fail("path is empty string") end

if #errors > 0 then
  for _, e in ipairs(errors) do io.stderr:write("FAIL: " .. e .. "\n") end
  vim.cmd("cquit 1")
else
  print("OK (5/5 pomodoro store tests passed)")
end
