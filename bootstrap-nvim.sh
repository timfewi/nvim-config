#!/usr/bin/env bash
set -euo pipefail

readonly NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
readonly REPO_URL="https://github.com/timfewi/nvim-config.git"

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

ensure_fd_alias() {
  if command -v fd >/dev/null 2>&1 || ! command -v fdfind >/dev/null 2>&1; then
    return
  fi

  mkdir -p -- "$HOME/.local/bin"
  ln -sf -- "$(command -v fdfind)" "$HOME/.local/bin/fd"
  log "Linked fdfind to ~/.local/bin/fd"
}

clone_config() {
  if [[ -d "$NVIM_DIR/.git" ]]; then
    log "Using existing checkout at $NVIM_DIR"
    return
  fi

  if [[ -e "$NVIM_DIR" ]]; then
    local backup_path
    backup_path="${NVIM_DIR}.backup-$(date +%s)"
    mv -- "$NVIM_DIR" "$backup_path"
    log "Backed up existing config to $backup_path"
  fi

  git clone -- "$REPO_URL" "$NVIM_DIR"
}

install_packages() {
  log "Installing system packages"

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y neovim git ripgrep fd-find fzf gcc make unzip curl xclip
    ensure_fd_alias
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --needed --noconfirm neovim git ripgrep fd fzf gcc make unzip curl xclip
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y neovim git ripgrep fd-find fzf gcc make unzip curl xclip
    ensure_fd_alias
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    brew install neovim git ripgrep fd fzf gcc make
    return
  fi

  printf '%s\n' 'Unsupported package manager. Install neovim, git, ripgrep, fd, fzf, gcc, make, unzip, and curl manually.' >&2
  exit 1
}

sync_lazy() {
  log "Syncing plugins via lazy.nvim"
  if ! nvim --headless '+Lazy! sync' +qa; then
    warn 'lazy.nvim sync failed; open Neovim and run :Lazy! sync manually.'
  fi
}

install_mason_packages() {
  log "Installing LSPs via Mason"
  if ! nvim --headless '+MasonInstall rust-analyzer lua-language-server typescript-language-server json-lsp nil pyright bash-language-server sqls yaml-language-server marksman taplo stylua prettier shfmt ruff' +qa; then
    warn 'Mason installation failed; open Neovim and run :MasonInstall manually.'
  fi
}

main() {
  install_packages
  clone_config
  sync_lazy
  install_mason_packages
  log 'Done. Launch nvim.'
}

main "$@"
