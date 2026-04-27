# Neovim keymap guide

`<leader>` is set to **Space** in this config.

This file documents the current feature-oriented `<leader>` mappings configured in `nvim/`. Some mappings are always available, while others only appear in specific modes or when a plugin/LSP client is active.

## Always-available mappings

| Keys | Mode | Feature | Action |
| --- | --- | --- | --- |
| `<leader><leader>` | Normal | Search | Find existing buffers |
| `<leader>/` | Normal | Search | Fuzzy search in current buffer |
| `<leader>bb` | Normal | Buffers | Switch to previous buffer |
| `<leader>f` | Normal/Visual | Format | Format buffer/selection |
| `<leader>q` | Normal | Diagnostics | Open diagnostic location list |

## Search (`<leader>s`)

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>sc` | Normal | Search commands |
| `<leader>sd` | Normal | Search diagnostics |
| `<leader>sf` | Normal | Search files |
| `<leader>sg` | Normal | Live grep |
| `<leader>sh` | Normal | Search help tags |
| `<leader>sk` | Normal | Search keymaps |
| `<leader>sn` | Normal | Search Neovim config files |
| `<leader>sr` | Normal | Resume last Telescope picker |
| `<leader>ss` | Normal | Search Telescope pickers |
| `<leader>sw` | Normal/Visual | Search current word / selection |
| `<leader>s/` | Normal | Live grep in open files |
| `<leader>s.` | Normal | Recent files |

## Git (`<leader>g`)

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>gb` | Normal | Toggle Diffview file sidebar |
| `<leader>gd` | Normal | Open Diffview |
| `<leader>gD` | Normal | Close Diffview |
| `<leader>ge` | Normal | Focus Diffview files panel |
| `<leader>gf` | Normal | Open LazyGit for current file |
| `<leader>gg` | Normal | Open LazyGit |
| `<leader>gh` | Normal | File history for current file |
| `<leader>gH` | Normal | Repository history |
| `<leader>gm` | Normal | Open merge/conflict view |
| `<leader>gt` | Normal | Toggle gitsigns change tracking |
| `<leader>gu` | Normal | Inline diff preview in current buffer |

## Git hunk (`<leader>h`)

These are buffer-local and only exist when `gitsigns` is attached.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>hd` | Normal | Diff current file |
| `<leader>hi` | Normal | Inline hunk preview |
| `<leader>hp` | Normal | Preview hunk |

## Toggle (`<leader>t`)

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>th` | Normal | Toggle LSP inlay hints for attached buffer |
| `<leader>tw` | Normal | Toggle git word diff |

## Debug (`<leader>d`)

These come from the local debug plugin setup.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dB` | Normal | Set conditional breakpoint |
| `<leader>dc` | Normal | Continue |
| `<leader>di` | Normal | Step into |
| `<leader>dl` | Normal | Run last |
| `<leader>do` | Normal | Step over |
| `<leader>dO` | Normal | Step out |
| `<leader>dr` | Normal | Open REPL |
| `<leader>dt` | Normal | Terminate |
| `<leader>du` | Normal | Toggle debug UI |
| `<leader>dx` | Normal | Debug shell script |

## Lazy Reader (`<leader>r`)

These are **visual mode only** and act on the current selection.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>re` | Visual | Explain selection |
| `<leader>rn` | Visual | Narrate selection |
| `<leader>rp` | Visual | Solve selection |
| `<leader>rr` | Visual | Read selection |
| `<leader>rs` | Visual | Summarize selection |
| `<leader>rt` | Visual | Teach selection |

## Avante (`<leader>a`)

Avante is configured with its default keymaps enabled, so these mappings come from the plugin rather than local overrides.

| Keys | Mode | Action |
| --- | --- | --- |
| `<leader>aa` | Normal | Show Avante sidebar |
| `<leader>at` | Normal | Toggle Avante sidebar |
| `<leader>ar` | Normal | Refresh sidebar |
| `<leader>af` | Normal | Switch sidebar focus |
| `<leader>a?` | Normal | Select model |
| `<leader>an` | Normal | New ask |
| `<leader>ae` | Normal | Edit selected blocks |
| `<leader>aS` | Normal | Stop current request |
| `<leader>ah` | Normal | Select chat history |
| `<leader>ad` | Normal | Toggle debug mode |
| `<leader>as` | Normal | Toggle suggestions |
| `<leader>aR` | Normal | Toggle repomap |
| `<leader>ac` | Normal | Add current buffer to selected files |
| `<leader>aB` | Normal | Add all open buffers to selected files |

## Notes

- `which-key` groups currently advertised are: `<leader>a`, `<leader>b`, `<leader>d`, `<leader>g`, `<leader>h`, `<leader>s`, and `<leader>t`.
- `<leader>th` only exists when the attached LSP supports inlay hints.
- `<leader>hd`, `<leader>hi`, and `<leader>hp` only exist in buffers where `gitsigns` is attached.
- Avante mappings depend on `avante.nvim` loading successfully and keeping its default automatic keymaps enabled.
