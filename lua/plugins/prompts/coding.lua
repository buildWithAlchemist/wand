-- ============================================================================
-- Coding Prompts for Sidekick.nvim
-- ============================================================================
-- Mid-session prompts that leverage Serena's codebase intelligence.
-- These fill the gap between session start/end — the actual coding workflow.

local utils = require("plugins.prompts.utils")
local send = utils.send
local get_visual_selection = utils.get_visual_selection

local M = {}

--- Get the current file path relative to the project root, or nil.
local function current_relative_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.fn.filereadable(file) == 0 then return nil end
  return vim.fn.fnamemodify(file, ":.")
end

--- Get the symbol name under cursor via treesitter, or nil.
local function symbol_under_cursor()
  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then return nil end
  while node do
    local type = node:type()
    if type:match("function") or type:match("method") or type:match("class") then
      for child in node:iter_children() do
        if child:named() and (child:type() == "name" or child:type() == "identifier") then
          return vim.treesitter.get_node_text(child, 0)
        end
      end
    end
    node = node:parent()
  end
  return nil
end

-- ── Picker-safe prompts ────────────────────────────────────────────────────

M.prompts = {
  code_review = function(_ctx)
    local file = current_relative_file()
    local selection = get_visual_selection()
    local cwd = vim.fn.getcwd()

    local parts = {
      "Review the code below for correctness, blast radius, and quality.",
      "Use Serena for codebase context — understand what this code connects to.",
    }

    -- ── Context ──────────────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Context")
    table.insert(parts, string.format('Call activate_project with path: "%s" (if not already active).', cwd))

    if file then
      table.insert(parts, string.format('File: %s', file))
      table.insert(parts,
        string.format('Call get_symbols_overview with relative_path: "%s" to understand the file structure.', file))
    end

    if selection then
      table.insert(parts, "")
      table.insert(parts, "── Selected code to review")
      table.insert(parts, "```")
      table.insert(parts, selection)
      table.insert(parts, "```")
    elseif file then
      table.insert(parts, "")
      table.insert(parts, string.format("No selection — review the entire file: %s", file))
      table.insert(parts, string.format('Call read_file with relative_path: "%s" to get the full contents.', file))
    else
      table.insert(parts, "")
      table.insert(parts, "No file open. Ask me what to review.")
      return table.concat(parts, "\n")
    end

    -- ── Review checklist ─────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Review in this order (same as my code review process)")
    table.insert(parts, "1. Correctness — does it do what it says? Are error paths handled?")
    table.insert(parts, "2. Blast radius — what does this touch beyond the obvious? Use find_referencing_symbols")
    table.insert(parts, "   to check what calls this code and what breaks if it changes.")
    table.insert(parts, "3. Invariant violations — SRP, DRY, dependency rules from CLAUDE.md.")
    table.insert(parts, "4. Observability — can I debug this at 2am? Structured logging, error capture.")
    table.insert(parts, "5. Tests — do they verify behaviour, not just execute code paths?")
    table.insert(parts, "6. Simplicity — is this the simplest thing that works?")

    -- ── Output format ────────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Output format")
    table.insert(parts, "For each issue found:")
    table.insert(parts, "  [severity: critical/important/minor] file:line — what's wrong and why it matters")
    table.insert(parts, "")
    table.insert(parts, "End with a one-line verdict: OK / Issues found (N critical, N important, N minor)")
    table.insert(parts, "Keep output concise. No preamble. Lead with issues, not praise.")

    return table.concat(parts, "\n")
  end,

  blast_radius = function(_ctx)
    local file = current_relative_file()
    local symbol = symbol_under_cursor()
    local selection = get_visual_selection()
    local cwd = vim.fn.getcwd()

    local parts = {
      "Analyse the blast radius of changing this code.",
      "Use Serena's find_referencing_symbols to trace all callers and dependents.",
    }

    -- ── Context ──────────────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Context")
    table.insert(parts, string.format('Call activate_project with path: "%s" (if not already active).', cwd))

    if file then
      table.insert(parts, string.format('File: %s', file))
      table.insert(parts, string.format('Call get_symbols_overview with relative_path: "%s".', file))
    end

    if selection then
      table.insert(parts, "")
      table.insert(parts, "── Selected code to analyse")
      table.insert(parts, "```")
      table.insert(parts, selection)
      table.insert(parts, "```")
      table.insert(parts, "Identify all symbols defined or referenced in this selection.")
    elseif symbol then
      table.insert(parts, string.format("Symbol under cursor: %s", symbol))
    end

    if not file and not symbol and not selection then
      table.insert(parts, "No file open. Ask me which symbol or file to analyse.")
      return table.concat(parts, "\n")
    end

    -- ── Analysis steps ───────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Analysis")

    if symbol then
      table.insert(parts, string.format(
        '1. Call find_symbol with name_path: "%s" and include_body: false to confirm the symbol.', symbol
      ))
      table.insert(parts, string.format(
        '2. Call find_referencing_symbols with name_path: "%s" to find all callers.', symbol
      ))
    else
      table.insert(parts, "1. Identify the key symbols in this file using get_symbols_overview.")
      table.insert(parts, "2. For each public symbol, call find_referencing_symbols to find all callers.")
    end

    table.insert(parts, "3. For each caller, assess: would a change to the target symbol break this caller?")
    table.insert(parts, "   Consider: signature changes, return type changes, semantic changes, removed fields.")

    -- ── Output format ────────────────────────────────────────────────────

    table.insert(parts, "")
    table.insert(parts, "── Output format")
    table.insert(parts, "")
    table.insert(parts, "## Blast radius for [symbol or file]")
    table.insert(parts, "")
    table.insert(parts, "**Direct callers** (would break on signature/type change):")
    table.insert(parts, "  - file:line — caller_name — how it uses the symbol")
    table.insert(parts, "")
    table.insert(parts, "**Indirect dependents** (may be affected by semantic change):")
    table.insert(parts, "  - file:line — dependent_name — why it might be affected")
    table.insert(parts, "")
    table.insert(parts, "**Safe to change?** Yes / No / With care")
    table.insert(parts, "If \"With care\": list the specific callers to update and the order to update them.")

    return table.concat(parts, "\n")
  end,
}

-- ── Thin keybinding wrappers ───────────────────────────────────────────────

function M.code_review()
  send(M.prompts.code_review())
end

function M.blast_radius()
  send(M.prompts.blast_radius())
end

return M
