-- ============================================================================
-- Krisp Meeting Review Prompts for Sidekick.nvim
-- ============================================================================
-- Closes the meeting pipeline: Krisp → Meeting Notes → SISU Tasks.
--
-- Uses Krisp MCP to fetch meeting data, then Notion MCP to create/update
-- Meeting Notes and SISU Tasks with proper relations and Krisp URL field.
--
-- Notion data sources:
--   Meeting Notes : collection://32100339-99d0-8070-b8f2-000b83919cde
--   SISU Tasks    : collection://6faddf03-1642-4192-bfd0-713c97ff41d7

local utils = require("plugins.prompts.utils")
local send = utils.send
local MEETING_NOTES_DB = utils.MEETING_NOTES_DB
local SISU_TASKS_DB = utils.SISU_TASKS_DB

local M = {}

-- ── Picker-safe prompts ────────────────────────────────────────────────────

M.prompts = {
  meeting_review = function(_ctx)
    local step = 0
    local parts = {
      "Review a Krisp meeting and create structured notes + tasks in Notion.",
      "This is a multi-turn conversation. You will present options, wait for my input, then act.",
    }

    -- ── Step 1: List recent meetings ─────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: List recent Krisp meetings", step))
    table.insert(parts, "Call search_meetings (Krisp MCP) to fetch meetings from the last 7 days.")
    table.insert(parts, "Present them as a numbered list:")
    table.insert(parts, "  1. [Title] — [Date] — [Duration] — [Participants count]")
    table.insert(parts, "  2. ...")
    table.insert(parts, "")
    table.insert(parts, "Ask: \"Which meeting to review? (number)\"")
    table.insert(parts, "")
    table.insert(parts, "STOP here and wait for my response before proceeding.")

    -- ── Step 2: Fetch meeting details ────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Fetch meeting details", step))
    table.insert(parts, "For the selected meeting:")
    table.insert(parts, "  a) Call get_multiple_documents (Krisp MCP) to get the transcript and summary.")
    table.insert(parts, "  b) Call list_action_items (Krisp MCP) to get action items for this meeting.")
    table.insert(parts, "")
    table.insert(parts, "Present a brief summary:")
    table.insert(parts, "  - Meeting title, date, duration, participants")
    table.insert(parts, "  - 2-3 sentence summary of key discussion points")
    table.insert(parts, "  - List of action items found (numbered)")
    table.insert(parts, "")
    table.insert(parts, "Ask: \"Create Meeting Note and tasks from this? (y/n, or edit action items first)\"")
    table.insert(parts, "")
    table.insert(parts, "STOP here and wait for my response before proceeding.")

    -- ── Step 3: Create/update Meeting Note ───────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Create or update Meeting Note in Notion", step))
    table.insert(parts, string.format("Call notion-search with the meeting title to check if a Meeting Note already exists."))
    table.insert(parts, "")
    table.insert(parts, "If NOT found, call notion-create-pages to create one:")
    table.insert(parts, string.format("  Database: %s", MEETING_NOTES_DB))
    table.insert(parts, "  Properties:")
    table.insert(parts, '    "Meeting name" = meeting title from Krisp')
    table.insert(parts, '    "Krisp URL" = the Krisp recording URL for this meeting')
    table.insert(parts, '    "date:Date:start" = meeting date (ISO-8601)')
    table.insert(parts, '    "date:Date:is_datetime" = 0')
    table.insert(parts, '    "Summary" = 2-3 sentence summary from Step 2')
    table.insert(parts, '    "Category" = infer from context (Planning, Standup, Presentation, Retro, Customer call)')
    table.insert(parts, '    "Product" = infer from discussion topics (Halo, Universe, SISU IQ, Cross-cutting)')
    table.insert(parts, "  Content: the meeting summary and key discussion points as structured markdown.")
    table.insert(parts, "")
    table.insert(parts, "If found, call notion-update-page to:")
    table.insert(parts, '  - Set "Krisp URL" if not already set')
    table.insert(parts, '  - Update "Summary" if empty')
    table.insert(parts, "  - Do NOT overwrite existing content")
    table.insert(parts, "")
    table.insert(parts, "Store the Meeting Note page URL — you will need it for Step 4.")

    -- ── Step 4: Create SISU Tasks from action items ──────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Create SISU Tasks from action items", step))
    table.insert(parts, "For each action item from Step 2:")
    table.insert(parts, string.format("  Call notion-create-pages to create a task in SISU Tasks (%s):", SISU_TASKS_DB))
    table.insert(parts, "  Properties:")
    table.insert(parts, '    "Task" = action item text (concise, imperative form)')
    table.insert(parts, '    "Status" = "Not started"')
    table.insert(parts, '    "Priority" = infer from urgency language (default: Medium)')
    table.insert(parts, '    "Category" = infer from context (Dev, Ops, Planning)')
    table.insert(parts, '    "Product" = same as the Meeting Note Product')
    table.insert(parts, '    "Meeting Note" = [Meeting Note page URL from Step 3]')
    table.insert(parts, "")
    table.insert(parts, "This sets the Meeting Note relation — linking the task to its source meeting.")
    table.insert(parts, "If an action item is vague or unclear, ask me before creating the task.")

    -- ── Step 5: Confirm ──────────────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Confirm", step))
    table.insert(parts, "Present a summary:")
    table.insert(parts, '  "Meeting reviewed: [title]"')
    table.insert(parts, '  "Meeting Note: [Notion URL]"')
    table.insert(parts, '  "Tasks created: N"')
    table.insert(parts, "  List each task on one line: [Task name] — [Priority] — [Product]")

    return table.concat(parts, "\n")
  end,
}

-- ── Thin keybinding wrappers ───────────────────────────────────────────────

function M.meeting_review()
  send(M.prompts.meeting_review())
end

return M
