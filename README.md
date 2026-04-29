# nvim-config

Portable Neovim configuration for NixOS, macOS, Windows, WSL2, and generic Linux.

`~/.config/nvim` is the writable source of truth. Nix installs Neovim and editor tooling when available, `lazy.nvim` installs plugins, and Mason is enabled only on non-NixOS machines as an LSP/tool fallback.

## Repository layout

```text
.
├── init.lua
├── lua/
├── lazy-lock.json
├── bootstrap-nvim.sh
├── bootstrap-nvim.ps1
└── README.md
```

## Install paths

### NixOS and nix-darwin

This repo is cloned into `~/.config/nvim` by `modules/home/editor.nix` from the companion `timfewi/nixos-config` repository. Update the Neovim config with:

```bash
cd ~/.config/nvim
git pull
```

Update Neovim binaries, LSPs, formatters, and debuggers by editing `modules/home/editor.nix` in `nixos-config` and rebuilding.

### Generic Linux and macOS without Nix

```bash
curl -fsSL https://raw.githubusercontent.com/timfewi/nvim-config/main/bootstrap-nvim.sh | bash
```

The bootstrap script installs Neovim plus core CLI dependencies, clones this repo into `~/.config/nvim`, syncs plugins with `lazy.nvim`, and installs Mason-managed language servers and formatters.

### Native Windows

```powershell
irm https://raw.githubusercontent.com/timfewi/nvim-config/main/bootstrap-nvim.ps1 | iex
```

The PowerShell bootstrap script installs Scoop if needed, installs Neovim and supporting tools, clones this repo into `%LOCALAPPDATA%\nvim`, then runs `:Lazy! sync` and `:MasonInstall`.

### WSL2

If the distro is NixOS-WSL, use the same `nixos-config` flow as NixOS. Other WSL distributions can use the generic Linux bootstrap script.

## Tooling model

- **NixOS / nix-darwin:** binaries and tooling come from Nix; Mason is disabled.
- **Non-Nix macOS / Linux / Windows:** binaries come from the bootstrap script and Mason provides LSP/tool fallback.
- **Plugins:** `lazy.nvim`
- **Lockfile:** `lazy-lock.json` stays writable because this repo lives outside the Nix store.

## Validation

Run a portable health check with:

```bash
nvim --headless '+checkhealth' +qa
```

On NixOS, `:Mason` should be unavailable. On non-Nix systems, `:Mason` should open normally.

## Notes

- Rust/C/C++ debugging uses `NVIM_DAP_LLDB_PATH` and `NVIM_DAP_LLDB_LIB_PATH` when available.
- Shell-script debugging uses `bashdb` when it is present in `PATH`.
- Search features expect `ripgrep`, `fd`, and `fzf`.
