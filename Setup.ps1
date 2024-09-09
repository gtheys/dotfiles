# Setup script for Windots
#powershell -ExecutionPolicy Bypass -File .\Setup.ps1 all
#Requires -RunAsAdministrator

# Lets take some arguments first
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("","backup", "symlink","git","dependencies","modules","configuration","all")]
  [string]$action

)

#
# Set powershell execution policy
##
Write-Host "Setting powershell to allow execution of scripts"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
$ErrorActionPreference = "Stop"

# Linked Files (Destination => Source)
$symlinks = @{
  $PROFILE.CurrentUserAllHosts                                                                    = ".\Profile.ps1"
  "$HOME\AppData\Local\nvim"                                                                      = ".\config\nvim"
  "$HOME\AppData\Local\fastfetch"                                                                 = ".\config\fastfetch"
  "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" = ".\config\windowsterminal\settings.json"
  "$HOME\.gitconfig"                                                                              = ".\.gitconfig"
  "$HOME\AppData\Roaming\lazygit"                                                                 = ".\config\lazygit"
  "$HOME\AppData\Roaming\nushell"                                                                 = ".\config\nushell"
  "$HOME\.glzr"                                                                                   = ".\config\glzr"
  "$ENV:PROGRAMFILES\WezTerm\wezterm_modules"                                                     = ".\config\wezterm\"
}

# Winget & choco dependencies
$wingetDeps = @(
  "chocolatey.chocolatey"
  "eza-community.eza"
  "ezwinports.make"
  "fastfetch-cli.fastfetch"
  "git.git"
  "github.cli"
  "kitware.cmake"
  "mbuilov.sed"
  "microsoft.openjdk.21"
  "microsoft.powershell"
  "neovim.neovim"
  "openjs.nodejs"
  "lua-language-server"
  "make"
  "awscli"
  "gpg4win"
  "opentofu"
  "terraform" # Install for neovim LSP of my tofu files
  "miniconda"
  "starship.starship"
  "glzr-io.glazewm"
  "nushell"
)

$chocoDeps = @(
  "bat"
  "fd"
  "fzf"
  "gawk"
  "lazygit"
  "mingw"
  "nerd-fonts-jetbrainsmono"
  "ripgrep"
  "sqlite"
  "wezterm"
  "zig"
  "zoxide"
)

# PS Modules
$psModules = @(
  "CompletionPredictor"
  "PSScriptAnalyzer"
  "ps-arch-wsl"
  "ps-color-scripts"
)

function Install-Dependencies
{
  # Set working directory
  Set-Location $PSScriptRoot
  [Environment]::CurrentDirectory = $PSScriptRoot

  Write-Host "Installing missing dependencies..."
  $installedWingetDeps = winget list | Out-String
  foreach ($wingetDep in $wingetDeps)
  {
    if ($installedWingetDeps -notmatch $wingetDep)
    {
      Write-Host "Installing $wingetDep"
      winget install --id $wingetDep
    }
  }

  # Path Refresh
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

  $installedChocoDeps = (choco list --limit-output --id-only).Split("`n")
  foreach ($chocoDep in $chocoDeps)
  {
    if ($installedChocoDeps -notcontains $chocoDep)
    {
      choco install $chocoDep -y
    }
  }
  
  # Install bat themes
  bat cache --clear
  bat cache --build

}

function Install-Modules
{
  # Install PS Modules
  foreach ($psModule in $psModules)
  {
    if (!(Get-Module -ListAvailable -Name $psModule))
    {
      Install-Module -Name $psModule -Force -AcceptLicense -Scope CurrentUser
    }
  }
}

function Set-Configuration
{
  # Delete OOTB Nvim Shortcuts (including QT)
  if (Test-Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Neovim\")
  {
    Remove-Item "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Neovim\" -Recurse -Force
  }

  # Persist Environment Variables
  [System.Environment]::SetEnvironmentVariable('WEZTERM_CONFIG_FILE', "$PSScriptRoot\wezterm\wezterm.lua", [System.EnvironmentVariableTarget]::User)
}

function Set-SymbolicLinks
{
  # Create Symbolic Links
  Write-Host "Creating Symbolic Links..."
  foreach($symlink in $symlinks.GetEnumerator())

  {
    Get-Item -Path $symlink.Key -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $symlink.Key -Target (Resolve-Path $symlink.Value) -Force | Out-Null
  }
}

function Set-GitConfig 
{
  $currentGitEmail = (git config --global user.email)
  $currentGitName = (git config --global user.name)

  git config --global --unset user.email | Out-Null
  git config --global --unset user.name | Out-Null
  git config --global user.email $currentGitEmail | Out-Null
  git config --global user.name $currentGitName | Out-Null
}

try
{
  switch($action)
  {
    "backup"
    {
      Write-Host "Backup - needs implementing"
    }
    "symlink"
    {
      Write-Host "Symlinking..."
      Set-SymbolicLinks
    }
    "dependencies"
    {
      Write-Host "Installing Dependencies..."
      Install-Dependencies
    }
    "modules"
    {
      Write-Host "Installing Modules..."
      Install-Modules
    }

    "git"
    {
      Write-Host "Configuring Git..."
      Set-GitConfig
    }
    "all"
    {
      Write-Host "Backup... not implemented"
      Write-Host "Install Dependencies..." 
      Install-Dependencies
      Write-Host "Install Modules..."
      Install-Modules
      Write-Host "Setting up git"
      Set-GitConfig
      Write-host "Configuration..."
      Set-Configuration
    }
    Default
    {
      Write-Error "Unkown action: $action"
      exit 1  
    }
  }
} catch
{
  Write-Error "An error occured: $_"
  exit 1
}
