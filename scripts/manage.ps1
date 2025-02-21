param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "build")]
    [string]$action
)

# Set $env:DOTFILES to the directory where the script is located
$env:DOTFILES = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

$ErrorActionPreference = "Stop"

try {
    switch ($action) {
        "start" {
            Write-Host "Starting with DOTFILES set to: $env:DOTFILES"
            docker run -v "${env:DOTFILES}:/home/user/code/dotfiles" -it --rm dotfiles
        }
        "build" {
            Write-Host "Building with DOTFILES set to: $env:DOTFILES"
            $priv_key = Get-Content "$env:USERPROFILE\.ssh\id_rsa" -Raw
            $pub_key = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" -Raw
            
            docker build -t dotfiles `
                --force-rm `
                --build-arg PRIVATE_KEY="$priv_key" `
                --build-arg PUBLIC_KEY="$pub_key" `
                -f "$env:DOTFILES\Dockerfile" `
                "$env:DOTFILES"
        }
    }
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
}
