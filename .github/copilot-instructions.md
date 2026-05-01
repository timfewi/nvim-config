# Copilot instructions for `nvim-config`

## Commands

| Purpose | Command | Notes |
| --- | --- | --- |
| Health check / repo validation | `nvim --headless '+checkhealth' +qa` | Documented in `README.md`; this is the main repo-level verification command. |
| Sync plugins | `nvim --headless '+Lazy! sync' +qa` | Used by both bootstrap scripts. |
| Install Mason-managed tools on non-Nix systems | `nvim --headless '+MasonInstall rust-analyzer lua-language-server typescript-language-server pyright bash-language-server yaml-language-server marksman taplo stylua prettier shfmt ruff' +qa` | Mirrors `bootstrap-nvim.sh`. |
| Update Treesitter parsers | `nvim --headless '+TSUpdate' +qa` | `nvim-treesitter` declares `build = ':TSUpdate'`. |

There is no repo-level test suite, test runner, or lint target in this repository, so there is no single-test command to run. Formatting is configured inside Neovim through `conform.nvim` (`<leader>f`) rather than a standalone project script.

## Architecture

- `init.lua` is the startup entrypoint. It sets leaders and loads the config in this order: options, keymaps, the custom fast-edit sidebar, autocmds, plugin bootstrap (`config.lazy`), then theme application.
- `lua/config/lazy.lua` bootstraps `lazy.nvim` if needed and then loads the plugin spec list from `lua/plugins/init.lua`.
- `lua/plugins/init.lua` is only an import list. Actual plugin specs are split by concern into `lua/plugins/{ai,core,debug,explorer,git,lsp,search,ui,treesitter}.lua`.
- Plugin setup logic lives in `lua/config/*`. When changing behavior, keep plugin declarations in `lua/plugins/*` and put reusable setup code in `lua/config/*`.
- The repo is designed around two tooling modes:
  - **NixOS / nix-darwin:** Neovim binaries, LSPs, formatters, and debuggers are expected to come from the companion `nixos-config` repo; Mason is intentionally disabled on NixOS.
  - **Non-Nix Linux/macOS/Windows:** bootstrap scripts install Neovim plus CLI dependencies, then use `lazy.nvim` and Mason to provision plugins and editor tooling.
- Themes are stateful across sessions and live outside the repo. `config.theme` reads the current light/dark mode from `~/.local/state/theme/current-mode` and the active Neovim theme from `~/.local/state/theme/nvim-theme`, while `config.themes` defines the supported theme set.
- `plugin/lazy_reader.lua` runs at startup to register the Lazy Reader commands/keymaps before normal plugin lazy-loading. That behavior is intentionally outside the `lua/plugins/*` import list.

## Key conventions

- Treat `~/.config/nvim` as the writable source of truth for this config. The README explicitly assumes the repo is edited there, even when Neovim itself is installed via Nix.
- Preserve the Nix-vs-Mason split. If you add tooling in `lua/plugins/lsp.lua` or bootstrap scripts, keep Mason as the fallback path for non-Nix systems and avoid making NixOS depend on Mason.
- Keep plugin specs grouped by domain instead of growing one large plugin file. New plugin declarations should usually land in the existing concern-specific module, or in a new module imported from `lua/plugins/init.lua` if they introduce a distinct area.
- Keep setup helpers in `lua/config/*` and call them from plugin specs, following patterns like `config = function() require('config.lsp').setup() end`.
- Theme additions require updates in both places: `config.themes` for the definition and plugin spec generation, and `config.theme` if the runtime behavior changes.
- LSP setup has repo-specific root detection and environment handling:
  - TypeScript intentionally avoids attaching inside Angular/Nx workspaces.
  - PowerShell support depends on discovering `powershell-editor-services`.
  - C/C++/Rust DAP support depends on `NVIM_DAP_LLDB_PATH` and `NVIM_DAP_LLDB_LIB_PATH`.
- Secrets and local credentials should stay outside the repo. The AI integration reads `OPENROUTER_API_KEY` or `OPENROUTER_API_KEY_FILE`, and `.gitignore` already excludes common secret/credential artifacts.
- Search/file navigation assumes external CLIs like `ripgrep`, `fd`, and `fzf` are present; bootstrap scripts install them because Telescope and related workflows depend on them.
