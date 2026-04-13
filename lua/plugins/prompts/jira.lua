-- ============================================================================
-- Session & Jira Prompts for Sidekick.nvim
-- ============================================================================
-- Three-system task flow:
--   Krisp → Meeting Notes (Krisp URL set on the note)
--   Meeting Notes → SISU Tasks (Meeting Note relation on the task)
--   SISU Tasks → Jira (Jira URL field, when task graduates to a PD ticket)
--
-- Standalone send functions for keybindings + picker-safe prompts table.
-- Uses Text.to_text() to bypass sidekick's template engine.
--
-- Jira setup (hardcoded):
--   Cloud ID  : fa0d5e53-98f0-4fcc-84ab-c432da5a8cc9
--   Site      : https://sisuhealthuk.atlassian.net
--   Projects  : PD (Platform Development), SIQ (SISU Health IQ)
--   Excluded  : POP (Platform Support — service desk)
--
-- Notion data sources:
--   SISU Tasks       : collection://6faddf03-1642-4192-bfd0-713c97ff41d7
--   Meeting Notes    : collection://32100339-99d0-8070-b8f2-000b83919cde
--   Engineering Docs : collection://32500339-99d0-80ff-b43a-000bfa481612

local CLOUD_ID = vim.env.JIRA_CLOUD_ID or "fa0d5e53-98f0-4fcc-84ab-c432da5a8cc9"
local SITE = vim.env.JIRA_SITE or "sisuhealthuk.atlassian.net"
local WORK_ORG = "sisu-health-uk"

local SISU_PAGE_ID = "3130033999d08083976ac57442a10236"

local utils = require("plugins.prompts.utils")
local send = utils.send
local today_title = utils.today_title
local SISU_TASKS_DB = utils.SISU_TASKS_DB
local ENGINEERING_DOCS_DB = utils.ENGINEERING_DOCS_DB

local M = {}

local function gather_git_context()
  vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return { branch = "", status = "", commits = "", diff_stat = "", ticket = nil, current_file = nil, is_work = false }
  end

  local remote = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%s+$", "")
  local is_work = remote:find(WORK_ORG, 1, true) ~= nil

  local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("%s+$", "")
  local status = vim.fn.system("git status --short 2>/dev/null"):gsub("%s+$", "")
  local commits = vim.fn.system("git log --oneline -10 --no-decorate 2>/dev/null"):gsub("%s+$", "")

  local merge_base = vim.fn.system("git merge-base HEAD main 2>/dev/null"):gsub("%s+$", "")
  local diff_stat = ""
  local diff_stat_warning = nil
  if merge_base:match("^%x+$") and merge_base ~= "" then
    diff_stat = vim.fn.system(string.format("git diff --stat %s...HEAD 2>/dev/null", merge_base)):gsub("%s+$", "")
  else
    -- Fallback: compare against previous commit when merge-base fails (orphan branch, no main, first commit)
    diff_stat = vim.fn.system("git diff --stat HEAD~1..HEAD 2>/dev/null"):gsub("%s+$", "")
    if diff_stat ~= "" then
      diff_stat_warning = "merge-base unavailable — diff is against previous commit, not main"
    end
  end

  local ticket = branch:match("(%u+%-%d+)")

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" or vim.fn.filereadable(current_file) == 0 then
    current_file = nil
  end

  return {
    branch = branch,
    status = status,
    commits = commits,
    diff_stat = diff_stat,
    diff_stat_warning = diff_stat_warning,
    ticket = ticket,
    current_file = current_file,
    is_work = is_work,
  }
end

-- ── Picker-safe prompts (no vim.fn.input) ──────────────────────────────────

M.prompts = {
  jira_my_tickets = function(_ctx)
    return string.format([[
Step 1: Call searchJiraIssuesUsingJql with:
  cloudId: "%s"
  jql: "assignee = currentUser() AND project in (PD, SIQ) AND statusCategory != Done ORDER BY status ASC, priority DESC"
  fields: ["summary", "status", "issuetype", "priority", "updated"]
  responseContentFormat: "markdown"

Step 2: Group results by status category.
  For each issue show one line:
    [KEY] Title | Priority | Type | Updated N days ago

  In Progress: show all.
  To Do: show top 5 by priority. If more exist, say "...and N more."
  Other (Review, Blocked, etc.): one summary line with count.

Step 3: If the query returns 0 results, say:
  "No open tickets in PD or SIQ."
  Do not retry with different parameters.

End with: "Fetched at HH:MM — %s"]], CLOUD_ID, SITE)
  end,

  -- ── Session Start ──────────────────────────────────────────────────────

  session_start = function(_ctx)
    local git = gather_git_context()
    local title = today_title()
    local proj = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local cwd = vim.fn.getcwd()

    local sources = git.is_work
      and "SISU Tasks (Notion), Notion Today page, Jira, Git, and Serena"
      or "Notion Today page, Git, and Serena"

    local fetch = 0
    local parts = {
      string.format(
        "Starting a work session. Today is %s. Project: %s.",
        os.date("%A, %d %B %Y"), proj
      ),
      string.format("Gather context from %s, then synthesise into a single briefing.", sources),
      "Run all fetches first. Do not print intermediate results — only the final briefing.",
    }

    -- ── Fetch: SISU Tasks (work repos only) ────────────────────────────

    if git.is_work then
      table.insert(parts, "")
      fetch = fetch + 1
      table.insert(parts, string.format("── Fetch %d: SISU Tasks (Notion)", fetch))
      table.insert(parts, string.format('Call notion-fetch with URL: "%s". This returns all tasks in the database.', SISU_TASKS_DB))
      table.insert(parts, 'From the results, filter to only tasks where Status is "In progress" or "Blocked".')
      table.insert(parts, "Order them by Priority (High first).")
      table.insert(parts, "For each task return:")
      table.insert(parts, "  - Task name")
      table.insert(parts, "  - Status, Priority, Product")
      table.insert(parts, "  - Jira URL if set (means it has a tracked PD ticket)")
      table.insert(parts, "  - Meeting Note title if set (where the task originated)")
      table.insert(parts, "  - Due date if set")
      table.insert(parts, "")
      table.insert(parts, 'Also pull the top 3 "Not started" High-priority tasks as upcoming work.')
      table.insert(parts, "If the fetch fails or returns no tasks, note it and continue with other sources.")
    end

    -- ── Fetch: Today page (Notion) ─────────────────────────────────────

    table.insert(parts, "")
    fetch = fetch + 1
    table.insert(parts, string.format("── Fetch %d: Today page (Notion)", fetch))
    table.insert(parts, string.format('Call notion-search with query: "%s".', title))
    table.insert(parts, "If found, call notion-fetch with the page URL.")
    table.insert(parts, "Extract: Focus, Blockers, and any notes from yesterday's Done section.")
    table.insert(parts, 'If not found, note "No Today page yet" and move on.')

    -- ── Fetch: Jira (work repos only) ──────────────────────────────────

    if git.is_work then
      table.insert(parts, "")
      fetch = fetch + 1
      table.insert(parts, string.format("── Fetch %d: Jira (PD board)", fetch))
      table.insert(parts, "Call searchJiraIssuesUsingJql with:")
      table.insert(parts, string.format('  cloudId: "%s"', CLOUD_ID))
      table.insert(parts, '  jql: "assignee = currentUser() AND project in (PD, SIQ) AND statusCategory != Done ORDER BY status ASC, priority DESC"')
      table.insert(parts, '  fields: ["summary", "status", "priority", "updated"]')
      table.insert(parts, '  responseContentFormat: "markdown"')
      table.insert(parts, "For each ticket return: key, title, priority, last updated.")
    end

    -- ── Fetch: Git context (embedded — no API call) ────────────────────

    fetch = fetch + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Fetch %d: Git context (provided below — no API call needed)", fetch))
    table.insert(parts, string.format("Branch: %s", git.branch))

    if git.status ~= "" then
      table.insert(parts, "Uncommitted files:")
      table.insert(parts, git.status)
    else
      table.insert(parts, "Working tree clean.")
    end

    if git.commits ~= "" then
      table.insert(parts, "Recent commits:")
      table.insert(parts, git.commits)
    end

    if git.diff_stat ~= "" then
      table.insert(parts, "Branch diff stat:")
      table.insert(parts, git.diff_stat)
      if git.diff_stat_warning then
        table.insert(parts, string.format("⚠ %s", git.diff_stat_warning))
      end
    end

    -- ── Fetch: Serena ──────────────────────────────────────────────────

    fetch = fetch + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Fetch %d: Serena (code intelligence)", fetch))
    table.insert(parts, string.format('Call activate_project with path: "%s".', cwd))
    table.insert(parts, "Then call check_onboarding_performed.")

    if git.current_file then
      table.insert(parts, string.format(
        'Call get_symbols_overview with relative_path: "%s" to understand what code area this session is in.',
        vim.fn.fnamemodify(git.current_file, ":.")
      ))
    else
      table.insert(parts, "No file open — skip symbols overview.")
    end

    table.insert(parts, 'If activation fails, skip and note "Serena: not available."')

    -- ── Synthesis ──────────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Synthesise into this exact format:")
    table.insert(parts, "")
    table.insert(parts, "IMPORTANT: Before synthesising, log which sources succeeded and which failed.")
    table.insert(parts, "If any fetch returned an error or empty results, note it explicitly.")
    table.insert(parts, "Treat partial data as partial — do not present a confident briefing from incomplete sources.")
    table.insert(parts, "")
    table.insert(parts, "---")
    table.insert(parts, "## Sources")
    table.insert(parts, "")
    table.insert(parts, "One line per source: ✓ succeeded / ✗ failed / ○ skipped. Example:")
    table.insert(parts, "  ✓ SISU Tasks — 5 active, 2 blocked")
    table.insert(parts, "  ✗ Jira — connection timeout")
    table.insert(parts, "  ✓ Git — branch feat/PD-123/auth-flow, 3 commits")
    table.insert(parts, "")
    table.insert(parts, "## Focus for today")
    table.insert(parts, "")
    if git.is_work then
      table.insert(parts, "One task. Be decisive. Pick the highest-priority In Progress task from SISU Tasks.")
      table.insert(parts, "If it has a Jira URL, include it. If it has a Meeting Note, note where it came from.")
      table.insert(parts, "One sentence on why this is the right thing to work on now.")
    else
      table.insert(parts, "Based on Today page focus, git branch, and recent commits — what should this session tackle?")
      table.insert(parts, "One sentence, be decisive.")
    end

    if git.is_work then
      table.insert(parts, "")
      table.insert(parts, "## Blocked — needs attention")
      table.insert(parts, "")
      table.insert(parts, "List any Blocked tasks from SISU Tasks. These are stalled and need a decision or")
      table.insert(parts, "external input before they can move. If none, say \"None.\"")

      table.insert(parts, "")
      table.insert(parts, "## Jira sync check")
      table.insert(parts, "")
      table.insert(parts, "Tasks in SISU Tasks that are In Progress but have no Jira URL — should any of these")
      table.insert(parts, "have a PD ticket? List them briefly so I can decide.")
      table.insert(parts, "Tasks that have a Jira URL — confirm the PD ticket status matches.")

      table.insert(parts, "")
      table.insert(parts, "## This week (upcoming)")
      table.insert(parts, "")
      table.insert(parts, 'Top 3 "Not started" / High-priority tasks from SISU Tasks, one line each.')
    end

    table.insert(parts, "")
    table.insert(parts, "## Where you left off")
    table.insert(parts, "")
    table.insert(parts, "From today's Notion page if it exists: what was in Focus, any blockers noted,")
    table.insert(parts, "anything in Done that leads naturally to today's work.")
    table.insert(parts, 'If no Today page exists, say "No Today page yet — starting fresh."')

    table.insert(parts, "")
    table.insert(parts, "## Code context")
    table.insert(parts, "")
    table.insert(parts, "From Git + Serena: current branch, what area of code is active, any uncommitted work.")
    table.insert(parts, "One to two lines.")

    table.insert(parts, "---")
    table.insert(parts, "")
    table.insert(parts, 'End with: "Open today\'s page: <page URL from the notion-search result>"')
    table.insert(parts, 'If no Today page was found, say: "No Today page yet — create one from the SISU workspace."')

    return table.concat(parts, "\n")
  end,

  -- ── Session End ────────────────────────────────────────────────────────

  session_end = function(_ctx)
    local git = gather_git_context()
    local title = today_title()
    local proj = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    local time = os.date("%H:%M")

    local parts = {
      string.format(
        "Ending session. %s, %s. Project: %s.",
        os.date("%A, %d %B %Y"), time, proj
      ),
    }

    -- ── Git context (embedded) ─────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Git context (provided — no API call needed)")
    table.insert(parts, string.format("Branch: %s", git.branch))

    if git.is_work and git.ticket then
      table.insert(parts, string.format("Ticket detected from branch: %s", git.ticket))
    end

    if git.commits ~= "" then
      table.insert(parts, "Recent commits:")
      table.insert(parts, git.commits)
    else
      table.insert(parts, "No commits this session.")
    end

    if git.diff_stat ~= "" then
      table.insert(parts, "Branch diff stat:")
      table.insert(parts, git.diff_stat)
      if git.diff_stat_warning then
        table.insert(parts, string.format("⚠ %s", git.diff_stat_warning))
      end
    end

    -- ── Conversational Q&A ─────────────────────────────────────────────

    local step = 0

    table.insert(parts, "")
    table.insert(parts, "This is a multi-turn conversation. You will ask questions, wait for my response, then act.")

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Ask me (both questions in one message, do not split into separate turns)", step))
    table.insert(parts, "  1. What did you complete or make meaningful progress on?")
    table.insert(parts, "  2. What's the next concrete step — what should you pick up next session?")
    table.insert(parts, "")
    table.insert(parts, "STOP after asking these questions. Do NOT execute any subsequent steps until I reply.")
    table.insert(parts, "All subsequent steps require my answers as input — proceeding without them will produce incorrect updates.")

    -- ── SISU Tasks update (work repos only) ────────────────────────────

    if git.is_work then
      table.insert(parts, "")
      step = step + 1
      table.insert(parts, string.format("── Step %d: Update SISU Tasks (Notion)", step))
      table.insert(parts, string.format("Database: %s", SISU_TASKS_DB))
      table.insert(parts, "")
      table.insert(parts, "For any task I mention completing:")
      table.insert(parts, '  - Call notion-update-page to set Status → "Done"')
      table.insert(parts, "  - If I mention it now has a Jira ticket, ask for the key and set the Jira URL")
      table.insert(parts, string.format("    to https://%s/browse/<KEY>", SITE))
      table.insert(parts, "")
      table.insert(parts, "For any task I mention making progress on but not completing:")
      table.insert(parts, '  - Call notion-update-page to confirm Status is "In progress" (set it if not)')
      table.insert(parts, '  - If I mention a blocker, call notion-update-page to set Status → "Blocked"')
      table.insert(parts, "")
      table.insert(parts, "For any new task that came up during the session:")
      table.insert(parts, string.format("  - Call notion-create-pages to create it in SISU Tasks (%s)", SISU_TASKS_DB))
      table.insert(parts, "  - Set Product, Category, Priority based on context")
      table.insert(parts, "  - If it came from a meeting, ask which meeting note to link under Meeting Note")
    end

    -- ── Notion Today page update ───────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Update today's journal page", step))
    table.insert(parts, string.format('Call notion-search with query: "%s".', title))
    table.insert(parts, "If found, call notion-update-page to update it:")
    table.insert(parts, string.format(
      '  - Under "## Done" (or "## ✅ Done"), append: "%s — <what I completed, one line per item>"', time
    ))
    table.insert(parts, '  - Under "## Next", write: "<my answer to question 2>"')
    table.insert(parts, "")
    table.insert(parts, "If not found, call notion-create-pages to create a journal page:")
    table.insert(parts, string.format('  Title: "%s"', title))
    table.insert(parts, string.format("  Parent page ID: %s", SISU_PAGE_ID))
    table.insert(parts, "  With sections: ✅ Done, 📝 Notes, ➡️ Next")
    table.insert(parts, "  Populate Done and Next from my answers.")
    table.insert(parts, "  (Focus and Blockers live in SISU Tasks views, not this page.)")

    -- ── Jira update (work repos, only if ticket mentioned) ─────────────

    if git.is_work then
      step = step + 1
      table.insert(parts, "")
      table.insert(parts, string.format("── Step %d: Update Jira (only if I mention a specific ticket)", step))
      table.insert(parts, "If I completed work tied to a PD ticket, ask:")
      table.insert(parts, '  "Should I update <KEY> on Jira — transition status or post a comment?"')
      table.insert(parts, "If yes, post a concise progress comment and transition if appropriate.")
      table.insert(parts, "Do not touch Jira unless I explicitly mention a ticket key.")
      if git.ticket then
        table.insert(parts, string.format(
          "Note: branch suggests ticket %s — ask me if I want to update it.", git.ticket
        ))
      end
    end

    -- ── CLAUDE.md learnings ────────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Capture learnings (optional)", step))
    table.insert(parts, "Review the commits, changes, and our conversation for non-obvious learnings —")
    table.insert(parts, "gotchas, patterns, system behavior, decisions, or preferences discovered this session.")
    table.insert(parts, "")
    table.insert(parts, "Classify each learning into one of two destinations:")
    table.insert(parts, "")
    table.insert(parts, "  A) Team knowledge (system gotchas, architectural patterns, debugging findings)")
    table.insert(parts, string.format("     → Call notion-create-pages to save to Engineering Docs (%s)", ENGINEERING_DOCS_DB))
    table.insert(parts, '     Properties: "Doc name" = the learning (one dense sentence),')
    table.insert(parts, '       "Category" = ["Key Learning"], "Status" = "Published"')
    if git.is_work then
      table.insert(parts, "     Set Product based on the repo/work context (Halo, SIQ, Universe, or omit if cross-cutting).")
    end
    table.insert(parts, '     Example: "SQS visibility timeout must exceed Redis lock TTL or jobs requeue mid-processing"')
    table.insert(parts, "")
    table.insert(parts, "  B) AI session preferences (how I like to work, tool quirks, prompt patterns)")
    table.insert(parts, "     → Propose as a CLAUDE.md addition. One bullet, dense, grep-friendly.")
    table.insert(parts, '     Example: "- User prefers bundled PRs over many small ones for refactors"')
    table.insert(parts, "")
    table.insert(parts, "Only propose learnings if they are genuine and non-obvious.")
    table.insert(parts, "Show me each learning with its classification (A or B) and ask before writing anything.")

    -- ── Session quality rating ──────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Session quality (2 seconds)", step))
    table.insert(parts, "Ask me: \"Quick rating for this session's AI assistance (1-5)?\"")
    table.insert(parts, "  1 = actively unhelpful, 3 = fine, 5 = genuinely accelerated my work")
    table.insert(parts, "If I give a rating, append it to the Today page under Done:")
    table.insert(parts, string.format('  "%s — Session quality: N/5"', os.date("%H:%M")))
    table.insert(parts, "If I skip, move on without logging.")

    -- ── Confirm ────────────────────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Confirm", step))
    table.insert(parts, 'End with one line: "Session logged. Next: <my answer to question 2>"')

    return table.concat(parts, "\n")
  end,

  -- ── Task Start ───────────────────────────────────────────────────────

  task_start = function(_ctx)
    local git = gather_git_context()
    local cwd = vim.fn.getcwd()

    local step = 0
    local parts = {
      "Starting a focused task. Pull context for this specific task, not the whole session.",
      "",
      "This is a multi-turn conversation.",
    }

    -- ── Step 1: Identify the task ────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Identify the task", step))

    if git.is_work and git.ticket then
      table.insert(parts, string.format("Branch suggests ticket: %s", git.ticket))
      table.insert(parts, "Call searchJiraIssuesUsingJql with:")
      table.insert(parts, string.format('  cloudId: "%s"', CLOUD_ID))
      table.insert(parts, string.format('  jql: "key = %s"', git.ticket))
      table.insert(parts, '  fields: ["summary", "status", "priority", "description"]')
      table.insert(parts, '  responseContentFormat: "markdown"')
      table.insert(parts, "")
      table.insert(parts, string.format("Also search SISU Tasks (%s) for tasks with Jira URL containing %s.", SISU_TASKS_DB, git.ticket))
    else
      table.insert(parts, "No ticket detected from branch. Ask me:")
      table.insert(parts, '  "What task are you starting? (Jira key, SISU Task name, or describe it)"')
      table.insert(parts, "")
      table.insert(parts, "STOP and wait for my response.")
    end

    -- ── Step 2: Gather task context ──────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Gather context for this task", step))
    table.insert(parts, string.format('Call activate_project with path: "%s" (if not already active).', cwd))

    if git.current_file then
      table.insert(parts, string.format('Call get_symbols_overview with relative_path: "%s".', vim.fn.fnamemodify(git.current_file, ":.")))
    end

    table.insert(parts, "")
    table.insert(parts, "Git context:")
    table.insert(parts, string.format("  Branch: %s", git.branch))
    if git.status ~= "" then
      table.insert(parts, "  Uncommitted files:")
      table.insert(parts, "  " .. git.status)
    end

    -- ── Step 3: Present task briefing ────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Present task briefing", step))
    table.insert(parts, "")
    table.insert(parts, "## Task: [title]")
    table.insert(parts, "**Source:** [Jira KEY / SISU Task / ad-hoc]")
    table.insert(parts, "**Goal:** One sentence — what does done look like?")
    table.insert(parts, "**Relevant code:** [files/symbols from Serena that relate to this task]")
    table.insert(parts, "**Approach:** Suggest 1-2 sentence plan based on the codebase context.")
    table.insert(parts, "")
    table.insert(parts, "Keep it under 10 lines. This is a focusing tool, not a design doc.")

    return table.concat(parts, "\n")
  end,

  -- ── Task End ─────────────────────────────────────────────────────────

  task_end = function(_ctx)
    local git = gather_git_context()
    local time = os.date("%H:%M")

    local step = 0
    local parts = {
      string.format("Ending a focused task at %s.", time),
    }

    -- ── Git context ──────────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Git context")
    table.insert(parts, string.format("Branch: %s", git.branch))

    if git.commits ~= "" then
      table.insert(parts, "Recent commits:")
      table.insert(parts, git.commits)
    end

    if git.diff_stat ~= "" then
      table.insert(parts, "Branch diff stat:")
      table.insert(parts, git.diff_stat)
      if git.diff_stat_warning then
        table.insert(parts, string.format("⚠ %s", git.diff_stat_warning))
      end
    end

    -- ── Step 1: Summarise ────────────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Summarise what changed", step))
    table.insert(parts, "From the commits and diff above, write a 1-2 sentence summary of what was accomplished on this task.")

    -- ── Step 2: Update task status ───────────────────────────────────────

    if git.is_work then
      step = step + 1
      table.insert(parts, "")
      table.insert(parts, string.format("── Step %d: Update task status", step))

      if git.ticket then
        table.insert(parts, string.format("Ticket: %s", git.ticket))
        table.insert(parts, string.format("Search SISU Tasks (%s) for a task with Jira URL containing %s.", SISU_TASKS_DB, git.ticket))
        table.insert(parts, "If found, ask me: \"Task done or still in progress?\"")
        table.insert(parts, '  If done → call notion-update-page to set Status → "Done"')
        table.insert(parts, '  If in progress → confirm Status is "In progress"')
      else
        table.insert(parts, "No ticket detected. Ask me if I want to update a SISU Task.")
      end
    end

    -- ── Step 3: Task-scoped learnings ────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Task-scoped learnings (optional)", step))
    table.insert(parts, "Review what happened during this task for non-obvious learnings.")
    table.insert(parts, "Only surface learnings specific to THIS task, not general session observations.")
    table.insert(parts, "")
    table.insert(parts, "If any exist, classify as:")
    table.insert(parts, string.format("  A) Team knowledge → notion-create-pages to Engineering Docs (%s), Category = [\"Key Learning\"]", ENGINEERING_DOCS_DB))
    table.insert(parts, "  B) AI preferences → propose CLAUDE.md addition")
    table.insert(parts, "")
    table.insert(parts, "Ask before writing anything.")

    -- ── Step 4: Confirm ──────────────────────────────────────────────────

    step = step + 1
    table.insert(parts, "")
    table.insert(parts, string.format("── Step %d: Confirm", step))
    table.insert(parts, 'One line: "Task done: <summary>"')

    return table.concat(parts, "\n")
  end,
}

-- ── Keybinding-only prompts (require vim.fn.input) ─────────────────────────

function M.jira_create_branch()
  local ok, key = pcall(vim.fn.input, "Ticket key (e.g. PD-123): ")
  if not ok or key == "" then return end
  key = key:upper()
  if not key:match("^%u+%-%d+$") then
    vim.notify("Invalid ticket key: " .. key, vim.log.levels.WARN)
    return
  end
  key = utils.sanitize(key)

  send(string.format([[
Step 1: Call getJiraIssue with:
  cloudId: "%s"
  issueKey: "%s"
  fields: ["issuetype", "summary"]
  responseContentFormat: "markdown"

Step 2: Map issue type name to branch prefix:
  Bug, Hotfix           → fix
  Story, Feature, Task  → feat
  Everything else       → chore

Step 3: Build slug from summary:
  - Lowercase, strip special characters.
  - Remove stop words: a, an, the, in, for, of, to, with, and, or, is, that.
  - Take first 2-4 meaningful words, join with hyphens.

Step 4: Output exactly two lines, nothing else:
  <prefix>/%s/<slug>
  git checkout -b <prefix>/%s/<slug>

If the issue does not exist or the API returns an error,
say "Issue %s not found on %s" and stop.]], CLOUD_ID, key, key, key, key, SITE))
end

-- ── Thin keybinding wrappers for picker-safe prompts ───────────────────────

function M.jira_my_tickets()
  send(M.prompts.jira_my_tickets())
end

function M.session_start()
  send(M.prompts.session_start())
end

function M.session_end()
  send(M.prompts.session_end())
end

function M.task_start()
  send(M.prompts.task_start())
end

function M.task_end()
  send(M.prompts.task_end())
end

return M
