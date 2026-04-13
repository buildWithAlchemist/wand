-- ============================================================================
-- Shared utilities for Sidekick prompt modules
-- ============================================================================

local M               = {}

-- ── Shared Notion collection URLs ──────────────────────────────────────────
M.SISU_TASKS_DB       = "collection://6faddf03-1642-4192-bfd0-713c97ff41d7"
M.MEETING_NOTES_DB    = "collection://32100339-99d0-8070-b8f2-000b83919cde"
M.ENGINEERING_DOCS_DB = "collection://32500339-99d0-80ff-b43a-000bfa481612"
M.INVESTIGATIONS_DB   = "collection://32100339-99d0-80e2-b37a-000b18969a5d"

--- Send a prompt to the active sidekick CLI session.
--- Uses Text.to_text() to bypass sidekick's template engine.
function M.send(prompt_text)
  if not prompt_text then return end
  local Text = require("sidekick.text")
  require("sidekick.cli").send({ text = Text.to_text(prompt_text) })
end

--- Escape % characters for use in string.format patterns.
function M.sanitize(str)
  return str:gsub("%%", "%%%%")
end

--- Today page title in the canonical format used by all session/notion prompts.
--- Example: "Today -- Monday, 24 March 2026"
--- Uses hardcoded English tables to avoid os.setlocale (process-global, not safe under async).
function M.today_title()
  local days   = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
  local months = { "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December" }
  local t      = os.date("*t")
  return "Today -- " .. days[t.wday] .. ", " .. t.day .. " " .. months[t.month] .. " " .. t.year
end

--- Get visual selection text, or nil if not in visual mode.
function M.get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then return nil end
  local _, srow, scol = unpack(vim.fn.getpos("v"))
  local _, erow, ecol = unpack(vim.fn.getpos("."))
  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow = erow, srow
    scol, ecol = ecol, scol
  end
  local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
  if #lines == 0 then return nil end
  return table.concat(lines, "\n")
end

return M
