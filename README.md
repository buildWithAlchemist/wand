# 🚀 Mad Engineer Neovim [BETA]

<p align="center">
  <img src="https://img.shields.io/badge/Mad%20Engineer-Neovim-00d4ff?style=for-the-badge&logo=neovim&logoColor=white" />
  <img src="https://img.shields.io/badge/version-1.0.0_beta-00ff88?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Neovim-0.11+-ff007c?style=for-the-badge&logo=neovim&logoColor=white" />
  <img src="https://img.shields.io/badge/license-MIT-00d4ff?style=for-the-badge" />
</p>

Performance-focused, cyberpunk-styled Neovim for polyglot development, AI-assisted workflows, testing, debugging, and daily engineering work.

[Installation](#installation) • [Features](#features) • [Workflow](#workflow) • [AI Usage](#ai-usage) • [Troubleshooting](#troubleshooting) • [Keybindings](KEYBINDINGS.md)

## Overview

Mad Engineer Neovim is built around a few practical goals:

- Fast enough to use all day without feeling bloated
- Opinionated defaults for real project work
- Managed LSP, formatter, and linter bootstrap through Mason
- First-class AI workflows for prompting, review, debugging, and note-taking
- Strong terminal, testing, git, and debugging ergonomics

Current targets:

- Boot time: `<100ms` on a healthy local setup
- Memory target: `<100MB`
- Neovim: `0.11+`

## Features

### UI and UX

- Cyberpunk visual language with multiple themes
- Theme switching commands for `cyberdream`, `kanagawa`, `catppuccin`, `tokyonight`, and `oxocarbon`
- `snacks.nvim` dashboard, notifier, terminal, git UI hooks, zen mode, dim mode, indent guides, and scrolling polish
- `noice.nvim` message and command-line UX
- Dynamic statusline with navic breadcrumbs and AI status

### Editing and Navigation

- Telescope for files, grep, symbols, references, and buffers
- Oil file explorer
- Aerial outline navigation
- Flash-enhanced movement
- Yank history, pairs, text objects, todo comments, and workflow helpers

### Language Tooling

- Managed LSP install path through Mason and `mason-tool-installer`
- LSP support for Lua, Python, TypeScript/JavaScript, Go, Rust, SQL, Markdown, Docker, Bash, and more
- Treesitter parser bootstrap for common engineering languages
- Formatting via `conform.nvim`
- Linting via `nvim-lint`

Managed toolchain currently includes:

- LSPs: `lua_ls`, `pyright`, `ruff`, `ts_ls`, `gopls`, `rust_analyzer`, `sqlls`, `marksman`, `dockerls`, `bashls`
- Formatters and linters: `stylua`, `black`, `isort`, `prettierd`, `prettier`, `eslint_d`, `markdownlint-cli2`, `goimports`, `rustfmt`, `shfmt`, `sql-formatter`

### Testing and Debugging

- `neotest` with adapters for Python, Go, Rust, Jest, and Plenary
- `nvim-dap`, `dap-ui`, virtual text, Go/Python support, and JS debug adapter support

### Python and Notebook Workflow

- `jupytext.nvim` for `.ipynb` handling
- `molten-nvim` integration for notebook-style execution inside Neovim
- Optional `image.nvim` integration when a compatible terminal plus ImageMagick CLI are available

### AI and Prompting

- `sidekick.nvim` as the main AI entry point
- Prompt-driven flows for:
  - code explanation, fixes, optimization, docs, tests, review, diagnostics
  - architecture debate and conventions checks
  - Jira workflows and branch/session/task prompts
  - Notion search, daily notes, and quick notes
  - Krisp meeting review flows
- Optional GitHub Copilot support when a compatible Node runtime is available

### Focus and Personal Workflow

Pomodoro system built in Lua across `lua/pomodoro/`:

- `<leader>ps` start, `<leader>pp` pause/resume, `<leader>px` stop
- 25-minute work sessions, 5-minute short breaks, 15-minute long break after every 4 cycles
- Lualine component shows phase, time remaining, and cycle count — flashes during escalation
- When a work session ends, two notifications fire simultaneously: `vim.notify` inside Neovim and a system notification via `notify-send`
- If you ignore both, a floating dialog opens after 30 seconds. The dialog prompts you to type one of two randomly assigned phrases to proceed — not "break" or "stop" but things like `"hydrate or perish"` / `"yeet the timer"` or `"nap.exe --force"` / `"pull the ripcord"`. Navigation, scroll, mouse, and `q` are all blocked. Typing the wrong thing tells you what the options are and keeps waiting.
- Confirming a break opens a full-screen overlay that covers your entire editor for the break duration. The overlay runs its own countdown, blocks navigation and window-switching, and forces you back to insert mode if you escape. It autocompletes into the next work session when the break ends.
- Optional music control through `playerctl`: work sessions play, breaks pause automatically

## Installation

### Prerequisites

Required:

- `nvim` 0.11 or newer
- `git`
- `curl` or `wget`

Recommended:

- `node`
- `python3`
- `go`
- `cargo`
- `rg`
- `fd`
- `lazygit`

Optional:

- `playerctl` for music control
- `magick` for notebook image rendering through `image.nvim`
- Kitty terminal if you want inline image rendering support

### Install Path

Neovim does not load this repo by default unless it lives under the config app name path.

Clone it directly to the expected config location:

```bash
mkdir -p ~/.config
git clone https://github.com/buildWithAlchemist/mad_enginner_nvim.git ~/.config/mad_enginner_nvim
```

If you keep the repo elsewhere, symlink it:

```bash
mkdir -p ~/.config
ln -sfn /path/to/mad_enginner_nvim ~/.config/mad_enginner_nvim
```

### First Launch

Launch it with:

```bash
NVIM_APPNAME=mad_enginner_nvim nvim
```

That makes Neovim read:

```text
~/.config/mad_enginner_nvim/init.lua
```

On first interactive launch:

- plugins sync
- Mason-managed tools install
- Treesitter parsers update
- the setup wizard is available and retryable

You can re-run onboarding at any time with:

```vim
:MadEngineerSetup
```

### Verification

Check the config path:

```bash
NVIM_APPNAME=mad_enginner_nvim nvim --headless "+lua print(vim.fn.stdpath('config'))" +qa
```

Run health:

```bash
NVIM_APPNAME=mad_enginner_nvim nvim -c "checkhealth mad_engineer"
```

Open Mason if you want to inspect installed tools:

```vim
:Mason
```

## Workflow

### Daily Startup

Typical startup looks like:

1. `NVIM_APPNAME=mad_enginner_nvim nvim`
2. open a project
3. use Telescope or Oil to navigate
4. let Mason-managed LSP/formatter/linter tooling attach automatically
5. run tests, debug sessions, terminal workflows, or AI prompts as needed

### Editing Flow

- `gd`, `gr`, `gi`, `K`, `<leader>ca`, `<leader>rn` for LSP navigation and actions
- `<leader>lf` for formatting
- lint runs through `nvim-lint` on write and insert leave for configured filetypes
- diagnostics go to floats, loclists, or quickfix via the keymaps in [`KEYBINDINGS.md`](KEYBINDINGS.md)

### Testing and Debugging Flow

- `neotest` for nearest test, file test, summary, output, and DAP test execution
- DAP keymaps for breakpoints, continue, step, repl, and UI toggling
- Python, Go, Rust, and Jest workflows are already wired in

### Git Flow

- Lazygit integration through Snacks
- Gitsigns for hunks and blame
- Git browse integration for opening files and commits externally

### Notebook and Python Flow

- Open `.ipynb` files through the Jupytext path
- use Molten for code-cell execution
- image rendering remains optional and only enables when the terminal and CLI dependencies are present

## AI Usage

AI is centered around `sidekick.nvim` plus the custom prompt modules in [`lua/plugins/prompts/`](lua/plugins/prompts).

### Core AI Actions

Available from normal and visual mode:

- `<leader>ap` prompt
- `<leader>ae` explain
- `<leader>ax` fix
- `<leader>ao` optimize
- `<leader>aD` document
- `<leader>aT` tests
- `<leader>ar` review
- `<leader>ai` diagnostics

### Workflow Prompts

- Notion:
  - `<leader>ans` search
  - `<leader>ant` today
  - `<leader>ann` quick note
- Jira:
  - `<leader>ajm` my tickets
  - `<leader>ajb` create branch
- Session tracking:
  - `<leader>ass` session start
  - `<leader>ase` session end
- Task tracking:
  - `<leader>ats` task start
  - `<leader>ate` task end

### Engineering Review Prompts

- `<leader>acr` code review
- `<leader>abr` blast radius
- `<leader>aAd` architecture debate
- `<leader>avc` verify conventions
- `<leader>akr` Krisp meeting review

### AI Requirements

- `sidekick.nvim` must be configured with whatever backend or CLI flow you use locally
- Copilot is optional and only loads when `node` is present and new enough for `copilot.lua`
- Prompt modules assume your local integrations for tools like Jira, Notion, or Krisp are already available where applicable

## Project Layout

```text
lua/
├── config/              # options, autocmds, keymaps, language-local settings
├── plugins/             # plugin specs grouped by area
│   ├── ai.lua
│   ├── completion.lua
│   ├── core.lua
│   ├── dap.lua
│   ├── formatting.lua
│   ├── lsp.lua
│   ├── navigation.lua
│   ├── testing.lua
│   ├── ui.lua
│   ├── workflow.lua
│   ├── languages/
│   └── prompts/         # custom AI prompt modules
├── pomodoro/            # Pomodoro timer (init, timer, dialog, overlay, music, util)
├── utils/               # installer, health, themes, save helpers
├── features/            # lazy.nvim specs for complex standalone modules
└── globals.lua
```

Key entry points:

- [`init.lua`](init.lua)
- [`lua/plugins/lsp.lua`](lua/plugins/lsp.lua)
- [`lua/plugins/formatting.lua`](lua/plugins/formatting.lua)
- [`lua/plugins/ai.lua`](lua/plugins/ai.lua)
- [`lua/utils/installer.lua`](lua/utils/installer.lua)
- [`lua/utils/health.lua`](lua/utils/health.lua)

## Troubleshooting

### Health and Bootstrap

```bash
NVIM_APPNAME=mad_enginner_nvim nvim -c "checkhealth mad_engineer"
```

```vim
:MadEngineerSetup
```

### Plugin and Tool Sync

```vim
:Lazy sync
:Mason
:MasonToolsUpdate
```

### Startup Profiling

```bash
NVIM_APPNAME=mad_enginner_nvim nvim --startuptime startup.log
```

### Theme Reload

```vim
:colorscheme cyberdream
```

## Contributing

- Keep changes compatible with Neovim `0.11+`
- Update docs when workflows or install paths change
- Prefer small, reviewable changes
- Run health checks after modifying bootstrap or tooling

For repo-specific automation and agent guidance, see [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE).
