-- ============================================================================
-- Notion Prompts for Sidekick.nvim — updated 2026-03-23
-- ============================================================================
-- Reflects reorganised workspace structure.
--
-- Notion structure (hardcoded for speed):
--   SISU (product hub) : 3130033999d08083976ac57442a10236
--   Today pages live   : directly under SISU
--   Title format       : "Today -- Monday, 23 March 2026"
--
--   Databases:
--     SISU Tasks       : collection://6faddf03-1642-4192-bfd0-713c97ff41d7
--     Engineering Docs : collection://32500339-99d0-80ff-b43a-000bfa481612
--     Meeting Notes    : collection://32100339-99d0-8070-b8f2-000b83919cde
--     Investigations   : collection://32100339-99d0-80e2-b37a-000b18969a5d
--
--   Products under SISU:
--     Halo             : 3130033999d0802ea306e84b39b8e290
--     Universe         : 31f0033999d080ef83e2cba194895471
--     SISU IQ          : 32c0033999d081cabd68c7b47f3b364c

local utils = require("plugins.prompts.utils")
local send = utils.send
local sanitize = utils.sanitize
local today_title = utils.today_title

local SISU = vim.env.NOTION_SISU_PAGE_ID or "3130033999d08083976ac57442a10236"
local SISU_TASKS_DB = utils.SISU_TASKS_DB

local M = {}

-- ── Picker-safe prompts (no vim.fn.input) ──────────────────────────────────

M.prompts = {
  notion_today = function(_ctx)
    local title = today_title()

    local parts = {
      "Show today's work view — live tasks from SISU Tasks plus today's journal.",
      "Run both fetches, then present a combined view.",
    }

    -- ── Fetch 1: Live tasks from SISU Tasks ──────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Fetch 1: Active tasks")
    table.insert(parts, string.format('Call notion-fetch with URL: "%s". This returns all tasks.', SISU_TASKS_DB))
    table.insert(parts, 'From the results, filter to Status "In progress" or "Blocked".')
    table.insert(parts, "Order by Priority (High first).")

    -- ── Fetch 2: Today journal page (if exists) ─────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Fetch 2: Today's journal")
    table.insert(parts, string.format('Call notion-search with query: "%s".', title))
    table.insert(parts, "If found, call notion-fetch with the page URL.")
    table.insert(parts, 'Extract the Done section and any free-text notes.')
    table.insert(parts, 'If not found, note "No journal page yet."')

    -- ── Present combined view ────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Present in this format:")
    table.insert(parts, "")
    table.insert(parts, "## Focus (from SISU Tasks)")
    table.insert(parts, "In Progress tasks, one line each:")
    table.insert(parts, "  - [Task name] — Priority — Product — Jira URL if set")
    table.insert(parts, "")
    table.insert(parts, "## Blocked")
    table.insert(parts, "Blocked tasks, one line each. If none, say \"None.\"")
    table.insert(parts, "")
    table.insert(parts, "## Journal")
    table.insert(parts, "From today's journal page: Done items and notes.")
    table.insert(parts, 'If no journal page, say "No journal page yet — run <leader>ann to add notes."')
    table.insert(parts, "")
    table.insert(parts, "Keep output concise. This is a dashboard, not a report.")

    return table.concat(parts, "\n")
  end,
}

-- ── Keybinding-only prompts (require vim.fn.input) ─────────────────────────

function M.notion_search()
  local ok, query = pcall(vim.fn.input, "Search Notion: ")
  if not ok or query == "" then return end
  send(string.format([[
Step 1: Call notion-search with:
  query: "%s"

Focus results on pages within the SISU workspace. Deprioritise results from unrelated areas.

Step 2: From the results, show the top 6. For each:
  [Title](url)
  Type: Page / Database entry / Meeting Note
  Last edited: relative date

Step 3: If any results are from Meeting Notes, group them
  separately at the end under "Meeting Notes".

Step 4: If 0 results, say:
  "No results for '%s' in SISU workspace."
  Do not fabricate results. Do not retry with different terms.
]], sanitize(query), sanitize(query)))
end

function M.notion_today()
  send(M.prompts.notion_today())
end

function M.notion_quick_note()
  local ok, note = pcall(vim.fn.input, "Note: ")
  if not ok or note == "" then return end

  local title = today_title()
  local time = os.date("%H:%M")

  send(string.format([[
Step 1: Call notion-search with:
  query: "%s"

Step 2: Check if any result has an exact title match for "%s".

  IF NOT FOUND:
    Respond with: "No journal page exists. Run session end (<leader>ase) to create one, or start a session (<leader>ass)."
    Do NOT create a page. Stop here.

  IF FOUND:
    Call notion-update-page with:
      page_id: <page ID from search result>
      command: "update_content"
      content_updates: find the "## Done" heading and insert before it:
        "%s — %s"

Step 3: Respond with exactly one line:
  "Note added → [page title] (url)"
  Do not print page contents.

If any API call fails, say what failed and stop. Do not retry.
]], title, title, time, sanitize(note)))
end

return M
