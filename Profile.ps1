<#
                      7#G~
                    7BB7J#P~
                 .?BG!   .?#G!
                :B@J       .?BB7
             ::  :Y#P~        7BB?.
           ^Y#?    :J#G~        !GB?.
          !&@!       .?#G!        J@B:
       ~^  ^Y#5^       .7BB7    .PB?.  ~^
    .!GB7    :Y#5^        !GB7.  ^.    Y#5^
    7&&~       !@@G~       .P@#J.       J@B^
     :J#G~   ~P#J^?#G!   .?#G~~P#Y:  .7BB7
       .?BG7P#J.   .7BB7J#P~    ^5#Y?BG!
         .?BJ.        7#G~        ^5B!

    Author: Scott McKendry
    Description: PowersShell Profile containing aliases and functions to be loaded when a new PowerShell session is started.
#>

# Initialise logging - helpful for debugging slow profile load times
$enableLog = $true

if ($enableLog)
{
  $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
  $logPath = "$env:USERPROFILE/Profile.log"
}
function Add-ProfileLogEntry
{
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Message
  )

  if (!$enableLog)
  {
    return
  }

  "`n$($stopwatch.ElapsedMilliseconds)ms`t$Message" | Out-File -FilePath $logPath -Append
}
Add-ProfileLogEntry "Starting profile load"

# Aliases
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Set-Alias -Name su -Value Start-AdminSession
Set-Alias -Name up -Value Update-Profile
Set-Alias -Name ff -Value Find-File
Set-Alias -Name grep -Value Find-String
Set-Alias -Name touch -Value New-File
Set-Alias -Name df -Value Get-Volume
Set-Alias -Name which -Value Show-Command
# Remove built-in aliases first
Remove-Item -Path Alias:ls -Force -ErrorAction SilentlyContinue
Remove-Item -Path Alias:cat -Force -ErrorAction SilentlyContinue
Remove-Item -Path Alias:rm -Force -ErrorAction SilentlyContinue

# Now set our custom aliases
if (!(Test-Path Alias:ls)) { Set-Alias -Name ls -Value Get-ChildItemPretty }
Set-Alias -Name ll -Value Get-ChildItemPretty
Set-Alias -Name la -Value Get-ChildItemPretty
Set-Alias -Name l -Value Get-ChildItemPretty
Set-Alias -Name tif Show-ThisIsFine
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim
if (!(Test-Path Alias:cat)) { Set-Alias -Name cat -Value bat }
Set-Alias -Name gs -Value Get-GitStatus
Set-Alias -Name us -Value Update-Software
if (!(Test-Path Alias:rm)) { Set-Alias -Name rm -Value Remove-ItemExtended }
Set-Alias -Name dc -Value cd
Set-Alias -Name tail -Value Get-Content-Tail

Add-ProfileLogEntry "Aliases loaded"

# Putting the FUN in Functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function Get-Content-Tail
{
  param (
    [string]$path
  )
  Get-Content $path -Tail 1 -Wait
}

function Get-GitStatus
{
  git status
}

function Find-WindotsRepository {
  <#
    .SYNOPSIS
        Finds the local Windots repository.
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ProfilePath
  )

  try {
    # First try the current directory
    $repoPath = $PWD.Path
    Write-Verbose "Checking current directory: $repoPath"

    # Check if this is a git repository
    $gitPath = Join-Path $repoPath ".git"
    $isGitRepo = Test-Path $gitPath
    Write-Verbose "Is git repository: $isGitRepo"

    # Check for required files
    $profilePath = Join-Path $repoPath "Profile.ps1"
    $setupPath = Join-Path $repoPath "Setup.ps1"
    $hasRequiredFiles = (Test-Path $profilePath) -and (Test-Path $setupPath)
    Write-Verbose "Has required files: $hasRequiredFiles"

    if ($isGitRepo -and $hasRequiredFiles) {
      Write-Verbose "Found repository at current directory"
      return $repoPath
    }

    # Try the parent directory of the profile
    $parentPath = Split-Path $ProfilePath
    Write-Verbose "Checking parent directory: $parentPath"

    # Check if parent is a git repository
    $parentGitPath = Join-Path $parentPath ".git"
    $isParentGitRepo = Test-Path $parentGitPath
    Write-Verbose "Parent is git repository: $isParentGitRepo"

    # Check for required files in parent
    $parentProfilePath = Join-Path $parentPath "Profile.ps1"
    $parentSetupPath = Join-Path $parentPath "Setup.ps1"
    $parentHasFiles = (Test-Path $parentProfilePath) -and (Test-Path $parentSetupPath)
    Write-Verbose "Parent has required files: $parentHasFiles"

    if ($isParentGitRepo -and $parentHasFiles) {
      Write-Verbose "Found repository at parent directory"
      return $parentPath
    }

    # If no repository found, return the current directory
    Write-Verbose "No repository found, using current directory"
    return $repoPath
  }
  catch {
    Write-Warning "Error finding repository: $($_.Exception.Message)"
    return $PWD.Path
  }
}

function Start-AdminSession
{
  <#
    .SYNOPSIS
        Starts a new PowerShell session with elevated rights. Alias: su
    #>
  Start-Process wezterm -Verb runAs -WindowStyle Hidden -ArgumentList "start --cwd $PWD"
}

function Update-Profile
{
  <#
    .SYNOPSIS
        Gets the latest changes from git, reruns the setup script and reloads the profile.
        Note that functions won't be updated, this requires a full PS session restart. Alias: up
    #>
  Write-Verbose "Storing current working directory in memory"
  $currentWorkingDirectory = $PWD

  Write-Verbose "Updating local profile from Github repository"
  Set-Location $ENV:WindotsLocalRepo
  git stash | Out-Null
  git pull | Out-Null
  git stash pop | Out-Null

  Write-Verbose "Rerunning setup script to capture any new dependencies."
  Start-Process wezterm -Verb runAs -WindowStyle Hidden -ArgumentList "start --cwd $PWD pwsh -NonInteractive -Command .\Setup.ps1"

  Write-Verbose "Reverting to previous working directory"
  Set-Location $currentWorkingDirectory

  Write-Verbose "Re-running profile script from $($PROFILE.CurrentUserAllHosts)"
  .$PROFILE.CurrentUserAllHosts
}

function Update-Software
{
  <#
    .SYNOPSIS
        Updates all software installed via Winget & Chocolatey. Alias: us
    #>
  Write-Verbose "Updating software installed via Winget & Chocolatey"
  Start-Process wezterm -Verb runAs -WindowStyle Hidden -ArgumentList "start -- pwsh -NonInteractive -Command &{`
        winget upgrade --all --include-unknown --silent --verbose && `
        choco upgrade all -y
    }"
  $ENV:SOFTWARE_UPDATE_AVAILABLE = ""
}

function Find-File
{
  <#
    .SYNOPSIS
        Finds a file in the current directory and all subdirectories. Alias: ff
    #>
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline, Mandatory = $true, Position = 0)]
    [string]$SearchTerm
  )

  Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
  $result = Get-ChildItem -Recurse -Filter "*$SearchTerm*" -ErrorAction SilentlyContinue

  Write-Verbose "Outputting results to table"
  $result | Format-Table -AutoSize
}

function Find-String
{
  <#
    .SYNOPSIS
        Searches for a string in a file or directory. Alias: grep
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SearchTerm,
    [Parameter(ValueFromPipeline, Mandatory = $false, Position = 1)]
    [string]$Directory,
    [Parameter(Mandatory = $false)]
    [switch]$Recurse
  )

  Write-Verbose "Searching for '$SearchTerm' in '$Directory'"
  if ($Directory)
  {
    if ($Recurse)
    {
      Write-Verbose "Searching for '$SearchTerm' in '$Directory' and subdirectories"
      Get-ChildItem -Recurse $Directory | Select-String $SearchTerm
      return
    }

    Write-Verbose "Searching for '$SearchTerm' in '$Directory'"
    Get-ChildItem $Directory | Select-String $SearchTerm
    return
  }

  if ($Recurse)
  {
    Write-Verbose "Searching for '$SearchTerm' in current directory and subdirectories"
    Get-ChildItem -Recurse | Select-String $SearchTerm
    return
  }

  Write-Verbose "Searching for '$SearchTerm' in current directory"
  Get-ChildItem | Select-String $SearchTerm
}

function New-File
{
  <#
    .SYNOPSIS
        Creates a new file with the specified name and extension. Alias: touch
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
  )

  Write-Verbose "Creating new file '$Name'"
  New-Item -ItemType File -Name $Name -Path $PWD | Out-Null
}

function Show-Command
{
  <#
    .SYNOPSIS
        Displays the definition of a command. Alias: which
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
  )
  Write-Verbose "Showing definition of '$Name'"
  Get-Command $Name | Select-Object -ExpandProperty Definition
}

function Get-OrCreateSecret
{
  <#
    .SYNOPSIS
        Gets secret from local vault or creates it if it does not exist. Requires SecretManagement and SecretStore modules and a local vault to be created.
        Install Modules with:
            Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
        Create local vault with:
            Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
            Set-SecretStoreConfiguration -Authentication None -Confirm:$False

        https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/

    .PARAMETER secretName
        Name of the secret to get or create. It is recommended to use the username or public key / client id as secret name to make it easier to identify the secret later.

    .EXAMPLE
        $password = Get-OrCreateSecret -secretName $username

    .EXAMPLE
        $clientSecret = Get-OrCreateSecret -secretName $clientId

    .OUTPUTS
        System.String
    #>

  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$secretName
  )

  Write-Verbose "Getting secret $secretName"
  $secretValue = Get-Secret $secretName -AsPlainText -ErrorAction SilentlyContinue

  if (!$secretValue)
  {
    $createSecret = Read-Host "No secret found matching $secretName, create one? Y/N"

    if ($createSecret.ToUpper() -eq "Y")
    {
      $secretValue = Read-Host -Prompt "Enter secret value for ($secretName)" -AsSecureString
      Set-Secret -Name $secretName -SecureStringSecret $secretValue
      $secretValue = Get-Secret $secretName -AsPlainText
    } else
    {
      throw "Secret not found and not created, exiting"
    }
  }
  return $secretValue
}

function Get-ChildItemPretty
{
  <#
    .SYNOPSIS
        Runs eza with a specific set of arguments. Plus some line breaks before and after the output.
        Alias: ls, ll, la, l
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Path = $PWD
  )

  Write-Host ""
  eza -a -l --header --icons --hyperlink --time-style relative $Path
  Write-Host ""
}

function Show-ThisIsFine
{
  <#
    .SYNOPSIS
        Displays the "This is fine" meme in the console. Alias: tif
    #>
  Write-Verbose "Running thisisfine.ps1"
  Show-ColorScript -Name thisisfine
}

function Remove-ItemExtended
{
  <#
    .SYNOPSIS
        Removes an item and (optionally) all its children. Alias: rm
    #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [switch]$rf,
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path
  )

  $message = if ($rf) { "and all its children" } else { "" }
  Write-Verbose "Removing item '$Path' $message"
  Remove-Item $Path -Recurse:$rf -Force:$rf
}

Add-ProfileLogEntry -Message "Functions loaded"

# Environment Variables
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
$ENV:WindotsLocalRepo = Find-WindotsRepository -ProfilePath $PSScriptRoot
$ENV:_ZO_DATA_DIR = $ENV:WindotsLocalRepo
$ENV:OBSIDIAN_PATH = "$HOME\iCloudDrive\iCloud~md~obsidian\Obsidian"
$ENV:BAT_CONFIG_DIR = "$ENV:WindotsLocalRepo\bat"
$ENV:FZF_DEFAULT_OPTS = '--color=fg:-1,fg+:#ffffff,bg:-1,bg+:#3c4048 --color=hl:#5ea1ff,hl+:#5ef1ff,info:#ffbd5e,marker:#5eff6c --color=prompt:#ff5ef1,spinner:#bd5eff,pointer:#ff5ea0,header:#5eff6c --color=gutter:-1,border:#3c4048,scrollbar:#7b8496,label:#7b8496 --color=query:#ffffff --border="rounded" --border-label="" --preview-window="border-rounded" --height 40% --preview="bat -n --color=always {}"'
$env:PYENV = "$HOME\.pyenv\pyenv-win"
$ENV:Path+=";$PYENV/bin"
$ENV:Path+=";$PYENV/shims"
$ENV:Path+=";$ENV:WindotsLocalRepo/bin"
# Check for Windots and software updates while prompt is loading
# Check for updates in a background job if we're in a git repo
$updateJob = Start-Job -ScriptBlock {
  param($repoPath)
  try {
    if (-not $repoPath) {
      Write-Warning "Repository path is null"
      return ""
    }
    
    $gitDir = Join-Path $repoPath ".git"
    if (-not (Test-Path $gitDir)) {
      Write-Warning "Not a git repository: $repoPath"
      return ""
    }
    
    Push-Location $repoPath
    git fetch 2>&1 | Out-Null
    $gitUpdates = git status 2>&1
    Pop-Location
    
    if ($gitUpdates -match "behind") {
      return "`u{db86}`u{dd1b} "
    }
  }
  catch {
    Write-Warning "Error checking git status: $($_.Exception.Message)"
  }
  return ""
} -ArgumentList $ENV:WindotsLocalRepo

$ENV:DOTFILES_UPDATE_AVAILABLE = $updateJob | Wait-Job | Receive-Job
Remove-Job $updateJob -Force -ErrorAction SilentlyContinue

Add-ProfileLogEntry -Message "Git fetch job started"

# Check for software updates in a background job
$softwareJob = Start-Job -ScriptBlock {
  try {
    $updateAvailable = $false
    
    # Check winget updates
    try {
      $wingetJob = Start-Job -ScriptBlock { winget list --upgrade-available | Out-String }
      $wingetUpdatesString = $wingetJob | Wait-Job | Receive-Job
      if ($wingetUpdatesString -match "upgrades available") {
        $updateAvailable = $true
      }
    }
    catch {
      Write-Warning "Error checking winget updates: $($_.Exception.Message)"
    }
    finally {
      if ($wingetJob) { Remove-Job $wingetJob -Force -ErrorAction SilentlyContinue }
    }
    
    # Check chocolatey updates
    try {
      $chocoJob = Start-Job -ScriptBlock { choco upgrade all --noop | Out-String }
      $chocoUpdatesString = $chocoJob | Wait-Job | Receive-Job
      if ($chocoUpdatesString -notmatch "can upgrade 0/") {
        $updateAvailable = $true
      }
    }
    catch {
      Write-Warning "Error checking chocolatey updates: $($_.Exception.Message)"
    }
    finally {
      if ($chocoJob) { Remove-Job $chocoJob -Force -ErrorAction SilentlyContinue }
    }
    
    if ($updateAvailable) {
      return "`u{eb29} "
    }
  }
  catch {
    Write-Warning "Error checking software updates: $($_.Exception.Message)"
  }
  return ""
}

$ENV:SOFTWARE_UPDATE_AVAILABLE = $softwareJob | Wait-Job | Receive-Job
Remove-Job $softwareJob -Force -ErrorAction SilentlyContinue

function Invoke-Starship-TransientFunction
{
  &starship module character
}

Add-ProfileLogEntry -Message "Update check job started"

# Prompt Setup
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Invoke-Expression (&starship init powershell)
Enable-TransientPrompt
Invoke-Expression (& { ( zoxide init powershell --cmd cd | Out-String ) })

# Configure PSReadLine based on PowerShell version
Import-Module PSReadLine

if ($PSVersionTable.PSVersion.Major -ge 7) {
  # PowerShell 7+ specific settings
  $colors = @{
    "Operator"         = "Magenta" # Purple
    "Parameter"        = "Cyan"    # Cyan
    "String"           = "Green"   # Green
    "Command"          = "Blue"    # Blue
    "Variable"         = "White"   # White
    "Comment"          = "DarkGray" # Gray
  }
  Set-PSReadLineOption -Colors $colors
  Set-PSReadLineOption -PredictionSource HistoryAndPlugin
  Set-PSReadLineOption -PredictionViewStyle InlineView
  Set-PSReadLineKeyHandler -Function AcceptSuggestion -Key Alt+l
  Import-Module -Name CompletionPredictor -ErrorAction SilentlyContinue
} else {
  # PowerShell 5.1 settings
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
  Set-PSReadLineKeyHandler -Chord "Ctrl+RightArrow" -Function ForwardWord
}

Add-ProfileLogEntry -Message "Prompt setup complete"

if ($enableLog) { $stopwatch.Stop() }

Add-ProfileLogEntry -Message "Profile load complete"


# Adding this to make refreshenv work
# Helsp with refreshing env variables without restarting the console
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

# Skip fastfetch for non-interactive shells and vim terminals
if ([Environment]::GetCommandLineArgs().Contains("-NonInteractive") -or [Environment]::GetCommandLineArgs().Contains("-CustomPipeName"))
{
  return
}
fastfetch
