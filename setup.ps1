# PowerShell Profile Setup Script

# Create the PowerShell directory if it doesn't exist
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force
}

# Copy the profile
Copy-Item -Path "Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
Write-Host "✓ PowerShell profile installed" -ForegroundColor Green

# Install custom Oh-My-Posh theme if present
if (Test-Path "modern-powershell.omp.json") {
    $themeFolder = Join-Path $env:POSH_THEMES_PATH ".."
    $themePath = Join-Path $themeFolder "modern-powershell.omp.json"
    Copy-Item -Path "modern-powershell.omp.json" -Destination $themePath -Force
    Write-Host "✓ Custom Oh-My-Posh theme installed" -ForegroundColor Green
}

# Check for required modules
$requiredModules = @("posh-git", "Terminal-Icons", "PSReadLine")
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "! $module is not installed. Installing..." -ForegroundColor Yellow
        Install-Module -Name $module -Scope CurrentUser -Force
        Write-Host "✓ $module installed" -ForegroundColor Green
    } else {
        Write-Host "✓ $module is already installed" -ForegroundColor Green
    }
}

# Optional: Install Oh-My-Posh if not present
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "! Oh-My-Posh is not installed. Installing via winget..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh -s winget
    Write-Host "✓ Oh-My-Posh installed" -ForegroundColor Green
}

Write-Host "
Setup complete! Restart PowerShell to apply changes." -ForegroundColor Green
