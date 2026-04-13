# Keybindings Quick Reference

Leader: `Space` | LocalLeader: `\`

## 🔍 Navigation & Search

| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep (search text) |
| `<Space>fb` | Browse buffers |
| `<Space>fh` | Help tags |
| `<Space>fr` | Recent files |
| `<Space>fc` | Commands |
| `<Space>fk` | Keymaps |
| `<Space>fs` | Document symbols |
| `<Space>fw` | Grep word under cursor |
| `-` | Open parent directory (Oil) |
| `<Space>a` | Toggle code outline (Aerial) |
| `{` / `}` | Previous/next function (Aerial) |

## 💻 LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `gs` | Signature help |
| `<Space>D` | Type definition |
| `<Space>rn` | Rename symbol |
| `<Space>ca` | Code actions |
| `<Space>lf` | Format buffer |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<Space>e` | Show diagnostic float |
| `<Space>dl` | Diagnostic location list |

## 🌳 Git

| Key | Action |
|-----|--------|
| `<Space>gg` | Open Lazygit |
| `<Space>gf` | Lazygit current file |
| `<Space>hs` | Stage hunk |
| `<Space>hr` | Reset hunk |
| `<Space>hS` | Stage buffer |
| `<Space>hR` | Reset buffer |
| `<Space>hu` | Undo stage hunk |
| `<Space>hp` | Preview hunk |
| `<Space>hb` | Blame line |
| `<Space>hd` | Diff this |
| `<Space>tb` | Toggle line blame |
| `<Space>td` | Toggle deleted |
| `]c` | Next hunk |
| `[c` | Previous hunk |

## 🧪 Testing

| Key | Action |
|-----|--------|
| `<Space>tt` | Run nearest test |
| `<Space>tf` | Run file tests |
| `<Space>td` | Debug nearest test |
| `<Space>ts` | Toggle test summary |
| `<Space>to` | Show test output |
| `<Space>tO` | Toggle output panel |
| `<Space>tS` | Stop test |

## 🐍 Python/Jupyter

| Key | Action |
|-----|--------|
| `<Space>mi` | Initialize Molten |
| `<Space>ml` | Evaluate line |
| `<Space>me` | Evaluate operator |
| `<Space>mr` | Re-evaluate cell |
| `<Space>md` | Delete cell |
| `<Space>mo` | Show output |
| `<Space>mh` | Hide output |

## 🗄️ Database

| Key | Action |
|-----|--------|
| `<Space>db` | Toggle database UI |

## 📋 Workflow

| Key | Action |
|-----|--------|
| `y` | Yank (with history) |
| `p` / `P` | Paste after/before |
| `<C-n>` | Cycle forward in yank history |
| `<C-p>` | Cycle backward in yank history |
| `gcc` | Comment line |
| `gc` | Comment selection (visual) |
| `]t` | Next TODO comment |
| `[t` | Previous TODO comment |
| `<Space>ft` | Find TODOs |

## 🪟 Window Management

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate windows |
| `<C-Up/Down/Left/Right>` | Resize window |
| `<Space>sv` | Split vertical |
| `<Space>sh` | Split horizontal |
| `<Space>sx` | Close split |
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |

## 📑 Tabs

| Key | Action |
|-----|--------|
| `<Space>to` | New tab |
| `<Space>tx` | Close tab |
| `<Space>tn` | Next tab |
| `<Space>tp` | Previous tab |

## 🔧 Editor

| Key | Action |
|-----|--------|
| `<C-s>` | Save file |
| `<Space>q` | Quit |
| `<Space>Q` | Quit all (force) |
| `<Esc>` | Clear search highlight |
| `<A-j/k>` | Move line up/down |
| `<` / `>` | Indent left/right (visual) |
| `<C-space>` | Incremental selection |

## 📊 Diagnostics & Quickfix

| Key | Action |
|-----|--------|
| `<Space>xx` | Toggle Trouble diagnostics |
| `<Space>xX` | Buffer diagnostics |
| `<Space>cs` | Symbols (Trouble) |
| `<Space>cl` | LSP definitions/refs |
| `<Space>co` | Open quickfix |
| `<Space>cc` | Close quickfix |
| `]q` / `[q` | Next/previous quickfix |
| `]l` / `[l` | Next/previous location |

## 🎯 Harpoon (Quick Navigation)

| Key | Action |
|-----|--------|
| `<Space>hm` | Mark file |
| `<Space>hh` | Harpoon menu |
| `<Space>1-4` | Jump to file 1-4 |

## 🛠️ Utilities

| Key | Action |
|-----|--------|
| `<Space>cm` | Open Mason |
| `:Lazy` | Plugin manager |
| `:Mason` | LSP installer |
| `:checkhealth` | Health check |
| `:checkhealth mad_engineer` | Custom health check |

## 💡 Tips

- Press `Space` and wait to see all available keybindings (which-key)
- Most plugin keybindings are prefixed with `<Space>`
- LSP keybindings start with `g` or `<Space>`
- Git keybindings are under `<Space>h` and `<Space>g`
- Test keybindings are under `<Space>t`
- Use `:Telescope keymaps` to search all keybindings

---

**Pro Tip:** Press `<Space>` and wait 300ms - which-key will show you all available commands!
