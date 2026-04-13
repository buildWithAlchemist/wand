-- ============================================================================
-- General Prompts for Sidekick.nvim
-- ============================================================================
-- Thinking tools and Serena-powered analysis prompts.
-- Uses Text.to_text() to bypass sidekick's template engine.

local utils = require("plugins.prompts.utils")
local send = utils.send
local sanitize = utils.sanitize
local get_visual_selection = utils.get_visual_selection

local M = {}

M.prompts = {
	verify_conventions = function(_ctx)
		local cwd = vim.fn.getcwd()
		local claude_md = cwd .. "/CLAUDE.md"
		local has_claude_md = vim.fn.filereadable(claude_md) == 1

		local parts = {
			"Verify which CLAUDE.md conventions are currently active in your context.",
			"This is a self-audit — run it after /compact or when you suspect drift.",
		}

		if has_claude_md then
			table.insert(parts, "")
			table.insert(parts, string.format("Read the file at: %s", claude_md))
		else
			table.insert(parts, "")
			table.insert(parts, "No CLAUDE.md found in this project. Check ~/.claude/CLAUDE.md instead.")
		end

		table.insert(parts, "")
		table.insert(parts, "── For each major rule or convention in CLAUDE.md:")
		table.insert(parts, "")
		table.insert(parts, "1. State the rule in one line")
		table.insert(parts, "2. Confirm: are you currently applying it? (yes / partially / no)")
		table.insert(parts, "3. If yes: give one concrete example from THIS conversation where you applied it")
		table.insert(parts, "4. If no/partially: explain what would change if you re-applied it now")
		table.insert(parts, "")
		table.insert(parts, "── Focus on these categories:")
		table.insert(parts, "- Code patterns (SRP, DRY, YAGNI, error handling)")
		table.insert(parts, "- Response style (brevity, no sycophancy, no preamble)")
		table.insert(parts, "- Architecture rules (system boundaries, mutation ownership)")
		table.insert(parts, "- Process rules (blast radius, plan before implement, TDD)")
		table.insert(parts, "")
		table.insert(parts, "── Output format:")
		table.insert(parts, "")
		table.insert(parts, "| Rule | Status | Evidence |")
		table.insert(parts, "|------|--------|----------|")
		table.insert(parts, "| ... | ✓/△/✗ | ... |")
		table.insert(parts, "")
		table.insert(parts, 'End with: "N of M conventions active. [any that need re-application]"')
		table.insert(parts, "Be brutally honest. The point of this check is to catch drift, not to reassure me.")

		return table.concat(parts, "\n")
	end,
}

-- ── Keybinding-only prompts (require vim.fn.input) ─────────────────────────

function M.architecture_debate()
	local selection = get_visual_selection()
	local decision

	if selection and #selection > 10 then
		decision = selection
	else
		local ok, input = pcall(vim.fn.input, "Architecture decision: ")
		if not ok or input == "" then
			return
		end
		decision = input
	end

	local prompt_text = string.format(
		[[
You are running an architecture debate. Think step by step.

The decision:
"""
%s
"""

Read the CLAUDE.md context you have — project constraints, stack, team size,
current system boundaries — and use them throughout. Do not give generic advice.
Every position must be grounded in the specifics of this decision.

---

Run these four positions sequentially. Each must be honest, concrete, and argue
its case with specifics. No platitudes. No "it depends" without saying on what.

## Position 1 — The Pragmatist

Argue for the simplest solution that ships given current constraints.
Address directly:
- What does "good enough right now" actually look like in this codebase?
- What are you consciously trading away?
- How long would this take to implement?
- Is it reversible in 3 months if it turns out to be wrong?

## Position 2 — The Architect

Argue for the most correct long-term solution regardless of short-term cost.
Address directly:
- What does "done properly" look like given SRP, DRY, YAGNI?
- Where do the clean system boundaries sit?
- What does this cost to implement — days, not "some time"?
- What does the codebase look like in 12 months if we do this?

## Position 3 — The Devil's Advocate

Attack whichever of position 1 or 2 is currently more compelling.
Address directly:
- What specific assumptions is that position making?
- What is the realistic worst-case failure mode in 6 months?
- What edge case or operational reality makes this break?
- Who on the team will be in pain because of this decision?

## Position 4 — The Cost Analyst

Put real numbers on both approaches.
Address directly:
- Implementation time: rough estimate in days for each option
- Cognitive load: how hard is this to explain to a new engineer?
- Maintenance burden: what does it cost when something goes wrong?
- Testing complexity: how hard is this to cover correctly?
- Debugging cost: when this breaks at 2am, how long to find the cause?

---

## Synthesis — The Recommendation

Lead with the recommendation in one sentence.

Then:

**The trade-off:**
Complete this exactly — "We are choosing X over Y because Z,
accepting the cost of A in exchange for B."

**What we are explicitly giving up:**
One sentence. Be honest.

**Why that is acceptable right now:**
One sentence. Reference actual constraints — team size, timeline, existing system.

**The trigger to revisit:**
What specific thing would have to change — a scale threshold, a team size,
a product requirement — for this decision to become the wrong one?

**First concrete step:**
One action. Specific enough to put in a Jira ticket today.

---

The synthesis must be expressible to a tech lead in under 2 minutes.
If it takes longer to explain, the recommendation is not clear enough — sharpen it.
]],
		sanitize(decision)
	)

	send(prompt_text)
end

function M.verify_conventions()
	send(M.prompts.verify_conventions())
end

function M.youtube_idea()
	local ok1, focus = pcall(vim.fn.input, "Focus area (blank = full repo): ")
	if not ok1 then
		return
	end

	local ok2, idea = pcall(vim.fn.input, "Seed idea (blank = discover from repo): ")
	if not ok2 then
		return
	end

	local cwd = vim.fn.getcwd()

	local focus_block = ""
	if focus ~= "" then
		focus_block = string.format(
			"\n── Focus area\n\nConcentrate your exploration on: %s\n"
				.. "Surface ideas specifically from this area, not the repo at large.\n",
			sanitize(focus)
		)
	end

	local idea_block = ""
	if idea ~= "" then
		idea_block = string.format(
			"\n── Seed idea\n\nThe user already has this idea in mind: %s\n"
				.. "Treat it as one candidate. Score it against the axes alongside your discovered ideas.\n"
				.. "Include it in the ranked output if it earns a place. Replace it if you find something stronger.\n",
			sanitize(idea)
		)
	end

	local prompt = string.format(
		[[
You are a technical YouTube content strategist for "Ctrl Alt Tech With Kiran"
— a channel for Senior Engineers covering system architecture, Neovim, Linux/Arch,
AI engineering, and deep technical exploration.

Your task: analyse this repository and generate 3 ranked video ideas.
Each idea must be specific, non-obvious, and pitched to a Senior Engineer audience
who is easily bored by basic tutorials.

── Step 1: Explore the repository

Call activate_project with path: "%s" (if not already active).
Call get_symbols_overview to understand the top-level architecture.
Read the bodies of 2-3 of the most architecturally interesting modules in depth.

Identify:
- What decision was made here that most engineers wouldn't make?
- What abstraction is hiding non-obvious complexity?
- What pattern is unusual, elegant, or worth explaining to a senior audience?
%s%s
── Step 2: Generate 3 ranked video ideas

Score each idea on these four axes (out of 5):
- Audience fit: would a Senior Engineer stop scrolling? (not "how to set up X")
- Visual potential: can the key insight be shown on screen compellingly?
- Originality: is this angle already covered to death on YouTube?
- Depth signal: does it demonstrate engineering thinking, not just tool usage?

Rank by total score. For each idea output exactly:

### #N — [Title]
**Hook:** One sentence. The first thing said on camera. Must create tension or curiosity.
**The angle:** What makes this video different from every other video on this topic.
**What to show:** 2-3 specific code segments or interactions to put on screen.
**Target moment:** The "oh that's clever" moment the audience will share.
**Score:** Audience fit N/5 | Visual N/5 | Originality N/5 | Depth N/5 | Total: N/20

── Constraints

- No "beginner's guide to X" angles. Senior audience only.
- No ideas that are just "here's my config" without a deeper engineering insight.
- Each idea must be completable as a standalone 10-15 min video, not a series.
- Titles must be specific — no "The Ultimate Guide to..." or "Everything You Need to Know..."
- Do not pad. Output the three ideas and nothing else.
]],
		sanitize(cwd),
		focus_block,
		idea_block
	)

	send(prompt)
end

return M
