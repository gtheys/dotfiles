param(
    [Parameter(Mandatory=$true)]
    [string]$PackageName
)

Write-Host "Starting installation process for $PackageName..."

# Check Claude Desktop folder
Write-Host "Checking Claude Desktop installation..."
$claudeFolder = Join-Path $env:APPDATA "Claude"
if (-not (Test-Path $claudeFolder)) {
    Write-Host "Claude Desktop is not installed. Please install from https://claude.ai/download"
    exit 1
}

# Check Node.js version
Write-Host "Checking Node.js version..."
try {
    $nodeVersion = node --version
    if ($nodeVersion -notmatch '^v\d+\.\d+\.\d+$') {
        throw "Invalid version format"
    }
    $majorVersion = [int]($nodeVersion.Substring(1).Split('.')[0])
    if ($majorVersion -lt 16) {
        Write-Host "Node.js version 16 or higher is required. Please install from https://nodejs.org/en/download/prebuilt-installer"
        exit 1
    }
} catch {
    Write-Host "Node.js is not installed or not in PATH. Please install from https://nodejs.org/en/download/prebuilt-installer"
    exit 1
}

# Check if package exists on NPM
Write-Host "Checking if package exists on NPM..."
try {
    $npmViewOutput = npm view $PackageName
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Package '$PackageName' is not available on NPM. Please verify the package name."
        exit 1
    }
} catch {
    Write-Host "Package '$PackageName' is not available on NPM. Please verify the package name."
    exit 1
}

# Install package globally
Write-Host "Installing $PackageName globally..."
try {
    npm install -g $PackageName
    if ($LASTEXITCODE -ne 0) {
        throw "npm install failed"
    }
} catch {
    Write-Host "Failed to install $PackageName. Error: $_"
    exit 1
}

# Get global package install path
Write-Host "Verifying Node.js global package path..."
try {
    $globalPath = npm root -g
    if (-not (Test-Path $globalPath)) {
        Write-Host "Node.js global package path does not exist. Node.js is not correctly configured."
        exit 1
    }
} catch {
    Write-Host "Failed to get Node.js global package path. Node.js is not correctly configured."
    exit 1
}

# Get package.json and find entry point
Write-Host "Reading package configuration..."
$packagePath = Join-Path $globalPath $PackageName
$packageJsonPath = Join-Path $packagePath "package.json"
if (-not (Test-Path $packageJsonPath)) {
    Write-Host "package.json not found at: $packageJsonPath"
    exit 1
}

try {
    $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
    if (-not $packageJson.bin) {
        Write-Host "Package does not have a 'bin' field in package.json"
        exit 1
    }

    # Handle both string and object bin fields
    $binPath = if ($packageJson.bin -is [System.String]) {
        $packageJson.bin
    } else {
        $binValues = @($packageJson.bin.PSObject.Properties.Value)
        if ($binValues.Count -eq 0) {
            Write-Host "No binary paths found in package.json"
            exit 1
        }
        $binValues[0]  # Take the first binary path
    }

    $entryPoint = Join-Path $packagePath $binPath
    if (-not (Test-Path $entryPoint)) {
        Write-Host "Entry point not found at: $entryPoint"
        exit 1
    }
} catch {
    Write-Host "Failed to read or parse package.json. Error: $_"
    exit 1
}


# Check/create config file
$configFile = Join-Path $claudeFolder "claude_desktop_config.json"
if (-not (Test-Path $configFile)) {
    Write-Host "Creating Claude Desktop configuration file..."
    $initialConfig = @{
        mcpServers = @{}
    }
    $initialConfig | ConvertTo-Json | Set-Content $configFile
}

# Read current config
Write-Host "Updating Claude Desktop configuration..."
try {
    $config = Get-Content $configFile | ConvertFrom-Json
    $serverName = $PackageName.Split('/')[-1]

    # Check if server already exists
    if ($config.mcpServers.PSObject.Properties.Name -contains $serverName) {
        Write-Host "Server '$serverName' is already installed in Claude Desktop configuration."
        exit 1
    }

    # Add new server configuration
    $newServer = @{
        command = "node"
        args = @($entryPoint)
    }
    
    # Convert to JSON, update, and save
    $config.mcpServers | Add-Member -MemberType NoteProperty -Name $serverName -Value $newServer
    $config | ConvertTo-Json -Depth 10 | Set-Content $configFile

    Write-Host "Installation complete! Please restart Claude Desktop for changes to take effect."
} catch {
    Write-Host "Failed to update configuration file. Error: $_"
    exit 1
}
