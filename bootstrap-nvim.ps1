$ErrorActionPreference = "Stop"

$nvimDir = Join-Path $env:LOCALAPPDATA "nvim"
$repo = "https://github.com/timfewi/nvim-config.git"

function Write-Step {
    param([string]$Message)
    Write-Host "==> $Message"
}

function Install-ScoopIfMissing {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        return
    }

    Write-Step "Installing scoop"
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression
}

function Install-Packages {
    Write-Step "Installing system packages via scoop"
    scoop bucket add main 2>$null
    scoop bucket add extras 2>$null
    scoop install neovim git ripgrep fd fzf gcc make unzip lazygit nodejs python rust
}

function Clone-Config {
    Write-Step "Cloning nvim config"

    if (Test-Path (Join-Path $nvimDir ".git")) {
        Write-Step "Using existing checkout at $nvimDir"
        return
    }

    if (Test-Path $nvimDir) {
        $backupPath = "$nvimDir.backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Move-Item -Path $nvimDir -Destination $backupPath
        Write-Step "Backed up existing config to $backupPath"
    }

    git clone $repo $nvimDir
}

function Invoke-NvimBootstrap {
    param(
        [string]$Description,
        [string]$Command
    )

    Write-Step $Description
    & nvim --headless $Command +qa
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "$Description failed; open Neovim and run the command manually."
    }
}

Install-ScoopIfMissing
Install-Packages
Clone-Config
Invoke-NvimBootstrap -Description "Syncing plugins via lazy.nvim" -Command "+Lazy! sync"
Invoke-NvimBootstrap -Description "Installing Neovim tooling via Mason" -Command "+MasonInstall rust-analyzer lua-language-server typescript-language-server json-lsp nil pyright debugpy bash-language-server sqls yaml-language-server marksman taplo stylua prettier shfmt ruff"
Write-Step "Done."
