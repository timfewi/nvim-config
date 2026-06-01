# nvim-config

Neovim configuration for NixOS Linux, managed alongside `timfewi/nixos-config`.

`~/.config/nvim` is the writable source of truth. Nix installs Neovim and editor tooling, `lazy.nvim` installs plugins — all LSPs, formatters, and debuggers come from the Nix store.

## Repository layout

```text
.
├── init.lua
├── lua/
├── lazy-lock.json
└── README.md
```

## Install paths

### NixOS (primary)

This repo is rsynced into `~/.config/nvim` by `modules/home/editor.nix` from the companion `timfewi/nixos-config` repository. Update the Neovim config at the source and rebuild:

```bash
cd ~/nvim-config
# edit files, then
nixos-rebuild switch --flake ~/nixos-config#<host>
```

Update Neovim binaries, LSPs, formatters, and debuggers by editing `modules/home/editor.nix` in `nixos-config` and rebuilding.

## Tooling model

- **NixOS:** binaries and tooling come from Nix.
- **Plugins:** `lazy.nvim`
- **Lockfile:** `lazy-lock.json` stays writable because this repo lives outside the Nix store.

If a configured LSP reports a missing executable on NixOS, add that server in `nixos-config`.

The TypeScript LSP also covers React buffers (`javascriptreact` / `typescriptreact`), so React support comes from the same TypeScript server installation.

## Validation

```bash
cd ~/nvim-config
nvim --headless '+checkhealth' +qa
```

## Notes

- Python debugging uses `debugpy`.
- Rust/C/C++ debugging uses `NVIM_DAP_LLDB_PATH` and `NVIM_DAP_LLDB_LIB_PATH` when available.
- Shell-script debugging uses `bashdb` when it is present in `PATH`.
- Search features expect `ripgrep`, `fd`, and `fzf` provided by Nix.
- Avante uses OpenRouter. `nixos-config` provides `OPENROUTER_API_KEY_FILE` from agenix; Avante reads that file at request time.
