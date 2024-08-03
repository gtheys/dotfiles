# Got this script from awesome gist to setup pyenv and poetry on windows
# https://gist.github.com/JamesDawson/4d90e7fcc535c582c617ed553feaf35d

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string] $PythonVersion
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Set-StrictMode -Version Latest


function _runCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Command,
        [switch] $PassThru
    )

    if ($PassThru) {
        $res = Invoke-Expression $Command
    }
    else {
        Invoke-Expression $Command
    }

    if ($LASTEXITCODE -ne 0) {
        $msg = "'$Command' reported a non-zero status code [$LASTEXITCODE] - check previous output{0}"
        if ($PassThru) {
            Write-Error ($msg -f "`n$res")
        }
        else {
            Write-Error ($msg -f ".")
        }
    }

    if ($PassThru) {
        return $res
    }
}
function _addToUserPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $AppName,
        [Parameter(Mandatory=$true, Position=1)]
        [string[]] $PathsToAdd
    )

    $pathEntries = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User) -split ";"

    $pathUpdated = $false
    foreach ($pathToAdd in $PathsToAdd) {
        if ($pathToAdd -notin $pathEntries) {
            $pathEntries = ,$pathToAdd + $pathEntries
            $pathUpdated = $true
        }
    }
    if ($pathUpdated) {
        Write-Host "$($AppName): Updating %PATH%..." -f Green
        # Remove any duplicate or blank entries
        $cleanPaths = $pathEntries | Select-Object -Unique | Where-Object { ![string]::IsNullOrEmpty($_) }

        # Update the user-scoped PATH environment variable
        [System.Environment]::SetEnvironmentVariable("PATH", ($cleanPaths -join ";").TrimEnd(";"), [System.EnvironmentVariableTarget]::User)
        
        # Reload PATH in the current session, so we don't need to restart the console
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
    }
    else {
        Write-Host "$($AppName): PATH already setup." -f Cyan
    }
}

Write-Host "#################################################" -f White
Write-Host "## Python, pyenv & poetry Windows setup script ##" -f White
Write-Host "#################################################" -f White

# Install pyenv
if (!(Test-Path $HOME/.pyenv)) {
    # Explicitly check whether running Windows PowerShell, as '$IsWindows' is only available for PowerShell Core
    if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
        Write-Host "pyenv: Installing for Windows..." -f Green
        & git clone https://github.com/pyenv-win/pyenv-win.git $HOME/.pyenv
        if ($LASTEXITCODE -ne 0) {
            Write-Error "git reported a non-zero status code [$LASTEXITCODE] - check previous output."
        }
    }
    else {
        Write-Error "This script currently only supports Windows."
    }
}
else {
    Write-Host "pyenv: Already installed." -f Cyan
}

# Add pyenv to PATH
_addToUserPath "pyenv" @(
    "$HOME\.pyenv\pyenv-win\bin"
    "$HOME\.pyenv\pyenv-win\shims"
)

# Install default pyenv python version
$pyenvVersions = _runCommand "pyenv versions" -PassThru | Select-String $PythonVersion
if (!($pyenvVersions)) {
    Write-Host "pyenv: Installing python version $PythonVersion..." -f Green
    _runCommand "pyenv install $PythonVersion"
}
else {
    Write-Host "pyenv: Python version $PythonVersion already installed." -f Cyan
}

# Set pyenv global version
$globalPythonVersion = _runCommand "pyenv global" -PassThru
if ($globalPythonVersion -ne $PythonVersion) {
    Write-Host "pyenv: Setting global python version: $PythonVersion" -f Green
    _runCommand "pyenv global $PythonVersion"
}
else {
    Write-Host "pyenv: Global python version already set: $globalPythonVersion" -f Cyan
}

if (!(Get-Command poetry -ErrorAction Ignore)) {
    $downloadPath = "$HOME/Downloads/install-poetry.py"
    Write-Host "python-poetry: Installing..." -f Green
    Invoke-WebRequest -Uri "https://install.python-poetry.org" `
                      -UseBasicParsing `
                      -OutFile $downloadPath
    try {
        _runCommand "pyenv exec python `"$downloadPath`""
    }
    finally {
        Remove-Item $downloadPath
    }
}
else {
    Write-Host "python-poetry: Already installed." -f Cyan
}

# Add poetry to PATH
_addToUserPath "python-poetry" @("$HOME\AppData\Roaming\Python\Scripts")

# Test poetry is available
_runCommand "poetry --version"

Write-Host "####################" -f Green
Write-Host "## Setup Complete ##" -f Green
Write-Host "####################" -f Green
