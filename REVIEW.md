---
phase: ide-features
reviewed: 2026-06-07T12:00:00Z
depth: standard
files_reviewed: 5
files_reviewed_list:
  - lua/config/keymaps.lua
  - lua/config/lsp.lua
  - lua/config/options.lua
  - lua/plugins/ide.lua
  - lua/plugins/lsp.lua
  - lua/plugins/ui.lua
  - lua/plugins/init.lua
findings:
  critical: 1
  warning: 4
  info: 3
  total: 8
status: issues_found
---

# IDE Features: Code Review Report

**Reviewed:** 2026-06-07T12:00:00Z
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

Reviewed 7 files for IDE-like feature additions: LSP signature help toggle, diagnostic display toggle, Trouble keymaps, lsp_signature.nvim, nvim-lightbulb, tiny-code-action.nvim, lazydev.nvim, blink.cmp source integration, and statusline LSP section override.

Found 1 critical, 4 warnings, 3 info items.

## Critical Issues

### CR-01: Duplicate `<C-s>` insert-mode keymap — `keymaps.lua` defines it globally, `lsp.lua` also defines it buffer-locally via LspAttach

**File:** `lua/config/keymaps.lua:20` and `lua/config/lsp.lua:106`
**Issue:** `<C-s>` mapped in insert mode in TWO places. Line 20 of `keymaps.lua` sets a global `<C-s>` → `vim.lsp.buf.signature_help`. Line 106 of `lsp.lua` sets a buffer-local `<C-s>` → same function inside LspAttach callback.

Result: On LspAttach, the buffer-local map takes priority over the global one. OK at runtime, but the global map in `keymaps.lua` is dead code — never fires after LSP attaches. If user removes LSP or LspAttach fails, the global one works. But the real issue: if `lsp_signature.nvim` (line 3-12 of ide.lua) also binds `<C-s>` via its `bind = true`, there's a THREE-WAY conflict — lsp_signature overwrites the buffer-local map with its own handler.

**Fix:** Remove the duplicate global map from `keymaps.lua:20` (let LspAttach handle it). Or remove from `lsp.lua:106` and keep only the global. But critically: `lsp_signature.nvim` with `bind = true` may rebind `<C-k>` or `<C-s>` on its own — need to verify. Safer approach: set `bind = false` in lsp_signature config and rely on explicit buffer-local map from `lsp.lua`.

Better fix:

```lua
-- lua/plugins/ide.lua — lsp_signature config
require('lsp_signature').setup {
  bind = false,  -- don't auto-bind, we manage keymaps ourselves
  handler_opts = { border = 'rounded' },
  hint_inline = function() return false end,
}
```

And remove `keymaps.lua:20` (redundant global map).

## Warnings

### WR-01: `K` hover map — CursorMoved autocmd on wrong buffer

**File:** `lua/config/lsp.lua:90-101`
**Issue:** `K` handler creates CursorMoved autocmd on the **hover float window's buffer** (via `vim.api.nvim_win_get_buf(winid)`). The hover float window does NOT own a separate buffer — `vim.lsp.buf.hover()` returns a **window ID** to the preview float, which shares the buffer it was opened from. So `nvim_win_get_buf(winid)` returns the **original source buffer**, not a float buffer.

Result: CursorMoved autocmd fires on the source buffer immediately when user moves cursor after closing hover — tries `pcall(nvim_win_close, winid, true)` on already-closed window. The `pcall` swallows the error, so no crash, but the autocmd lingers as a no-op callback running every cursor move in the source buffer.

**Fix:** Use the proper float window buffer pattern. The hover float has a `winid` but its buffer IS the source buffer. Close on CursorMoved in any window instead, or use a timer. Simpler fix:

```lua
map('K', function()
  local winid = vim.lsp.buf.hover()
  if winid then
    local close_autocmd
    close_autocmd = vim.api.nvim_create_autocmd('CursorMoved', {
      once = true,
      callback = function()
        if vim.api.nvim_win_is_valid(winid) then
          vim.api.nvim_win_close(winid, true)
        end
      end,
    })
    -- clean up autocmd if float closed by other means (e.g. Esc)
    vim.api.nvim_create_autocmd('WinClosed', {
      once = true,
      pattern = winid,
      callback = function()
        pcall(vim.api.nvim_del_autocmd, close_autocmd)
      end,
    })
  end
end, 'Hover documentation')
```

Or simply use `vim.bo[buf].buftype == "nofile"` check on CursorMoved target. But the win_valid guard is the minimal fix.

### WR-02: `gra` pcall to tiny-code-action — silently falls back but dead code when plugin not installed

**File:** `lua/config/lsp.lua:43-50`
**Issue:** `gra` attempts `pcall(require, 'tiny-code-action')`. If plugin is available AND loaded, it calls `action.code_action()`. If pcall fails OR action table missing, falls back to `vim.lsp.buf.code_action()`.

But `tiny-code-action.nvim` is declared in `ide.lua` with `event = 'LspAttach'` — which fires AFTER this LspAttach callback runs. Race: `LspAttach` fires → `gra` wrapper tries `pcall(require, 'tiny-code-action')` → module NOT loaded yet (lazy-loading hasn't activated for ide.lua plugins yet) → pcall returns `false` → always falls back to `vim.lsp.buf.code_action()`.

So the tiny-code-action wrapper is essentially dead code — never activates on first LspAttach.

**Fix:** Two options:

Option A: Remove the `event = 'LspAttach'` from tiny-code-action spec (make it eagerly loaded or `cmd`-based):

```lua
-- lua/plugins/ide.lua
{
  'rachartier/tiny-code-action.nvim',
  cmd = 'TinyCodeAction',  -- or whatever cmd it registers
  config = function()
    require('tiny-code-action').setup()
  end,
},
```

Option B: Wrap the keymap function properly to lazy-require on first invocation:

```lua
-- lua/config/lsp.lua
map('gra', function()
  local ok, action = pcall(require, 'tiny-code-action')
  if ok then
    action.code_action()
  else
    vim.lsp.buf.code_action()
  end
end, '[G]oto Code [A]ction', { 'n', 'x' })
```

This second invocation would work because by the time user presses `gra`, the LspAttach event has completed and lazydev would load. BUT: the `event = 'LspAttach'` in the plugin spec means lazy.nvim schedules the `config()` function to run on that event — but it's queued, not synchronous. The `require` in the keymap will fail because the plugin hasn't loaded yet.

**Real fix:** Use `keys = { 'gra' }` in the plugin spec instead of `event = 'LspAttach'`:

```lua
{
  'rachartier/tiny-code-action.nvim',
  keys = { { 'gra', mode = { 'n', 'x' } } },
  config = function()
    require('tiny-code-action').setup()
  end,
},
```

And remove the pcall wrapper from `lsp.lua`, just use `vim.lsp.buf.code_action()`.

### WR-03: `nvim-lightbulb` deprecated — uses autocmd in setup but also uses event = LspAttach

**File:** `lua/plugins/ide.lua:14-22`
**Issue:** nvim-lightbulb is deprecated and archived. Its `autocmd = { enabled = true }` creates its own LspAttach autocmd internally, AND the lazy.nvim spec has `event = 'LspAttach'`. This means two LspAttach hooks fire: one from lazy.nvim (which runs setup), and one from inside setup (which creates another autocmd). Works but redundant.

Additionally, using `nvim-lightbulb` with `sign = { priority = 10 }` sets sign column priority to 10 — extremely low priority (lower number = lower priority in Neovim signs). Default is 10 anyway. This means another sign plugin (e.g. git signs, diagnostic signs with higher priority) will overlay the lightbulb. The lightbulb sign may be invisible.

**Fix:** Replace with built-in Neovim 0.10+ code action lightbulb (no plugin needed):

```lua
-- In lsp.lua LspAttach callback:
if client and client:supports_method('textDocument/codeAction', event.buf) then
  vim.api.nvim_create_autocmd('CursorHold', {
    buffer = event.buf,
    callback = function()
      vim.lsp.buf.code_action { context = { only = { 'quickfix' } }, apply = true }
    end,
  })
end
```

If keeping plugin, remove `autocmd.enabled` and use `event = 'VeryLazy'`:

```lua
event = 'LazyLoad',  -- or just remove event entirely and let lazy.nvim handle
config = function()
  require('nvim-lightbulb').setup {
    autocmd = { enabled = true },
    sign = { enabled = true, priority = 10 },
  }
end,
```

### WR-04: `lazydev` sources config nested incorrectly inside `sources.default`

**File:** `lua/plugins/lsp.lua:79-88`
**Issue:** In blink.cmp config, `sources` has `default` (list of default source names) and `providers` (table of provider configs). The `providers` key is at the **same level** as `default` — both inside `sources`. The current code:

```lua
sources = {
  default = { 'lsp', 'path', 'snippets', 'lazydev' },
  providers = {
    lazydev = {
      name = 'LazyDev',
      module = 'lazydev.integrations.blink',
      score_offset = 100,
    },
  },
},
```

This looks correct per blink.cmp docs. But **lazydev must also be exported as a source** inside its own config — blink.cmp needs the `module` path to load it. Confirmed: this is correct structure.

**Issue:** `lazydev.nvim` in `ide.lua` uses `opts = {}` but **blink.cmp also needs the lazydev config to export as a source**. The lazydev plugin must be configured with its own `opts` that tells blink about it. But the current `opts = {}` for lazydev is empty — the integration is wired only from blink's side.

Per lazydev docs, if using blink.cmp, you need to call `require('lazydev').setup {}` AND configure blink's source. The empty `opts = {}` for lazydev does call setup (lazy.nvim passes opts to config), but lazydev's default setup does NOT register the blink source. The blink source registration happens via `module = 'lazydev.integrations.blink'`, which IS correct.

So this works, but is fragile — depends on both plugins being loaded in correct order. No concrete bug here on closer inspection, but the setup is fragile.

**Downgrade to Info** — see IN-03.

## Info

### IN-01: Diagnostic toggle restores hardcoded virtual_text values, ignoring user's current config

**File:** `lua/config/keymaps.lua:22-29`
**Issue:** The `true` branch correctly sets `virtual_text = false`. The `false` branch resets `virtual_text` to hardcoded defaults (`prefix = '●', source = 'if_many', spacing = 2`). If user (or options.lua) changes these values, the toggle loses them. Options.lua defines the same values, so currently they match — but they're duplicated.

**Fix:** Store the original virtual_text config on first toggle:

```lua
local orig_vtext = { prefix = '●', source = 'if_many', spacing = 2 }
-- then in else branch use orig_vtext
```

### IN-02: `mini.statusline` section_lsp calls `vim.api.nvim_get_current_buf()` twice

**File:** `lua/plugins/ui.lua:29,40`
**Issue:** `nvim_get_current_buf()` called at line 29 (for `vim.lsp.get_clients`) and again at line 40 (for `vim.diagnostic.get`). In theory, cursor could move between these calls, returning different buffers — but statusline only renders on specific events so this is practically safe.

**Fix:** Store `bufnr` in local:

```lua
local buf = vim.api.nvim_get_current_buf()
local clients = vim.lsp.get_clients { bufnr = buf }
-- ...
local errors = #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
```

### IN-03: `lsp_signature` and `blink.cmp` both manage signature — conflict risk

**File:** `lua/plugins/ide.lua:3-12` and `lua/plugins/lsp.lua:91`
**Issue:** `blink.cmp` signature disabled (`{ enabled = false }`) to avoid conflict with `lsp_signature.nvim`. This is correct intent. But `lsp_signature.nvim` with `bind = true` binds `<C-k>` and `<C-s>` in insert mode. The `<C-s>` buffer-local map in `lsp.lua:106` (also for signature_help) may conflict.

**Fix:** Either:

1. Remove `bind = true` from lsp_signature and rely on `<C-s>` map from lsp.lua
2. Or keep lsp_signature's bind and remove the explicit `<C-s>` map from lsp.lua

Recommend option 1 as cleaner — buffer-local map from LspAttach is explicit and visible.

---

_Reviewed: 2026-06-07T12:00:00Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
