# 🚀 Advanced PowerShell 7 Profile 🚀
# Last updated: April 2025

# ===== MODULE IMPORTS =====
# Check and import essential modules
$requiredModules = @(
    @{Name = "posh-git"; Description = "Git integration" },
    @{Name = "Terminal-Icons"; Description = "File and folder icons" },
    @{Name = "PSReadLine"; Description = "Command line editing" },
    @{Name = "PSFzf"; Description = "Fuzzy finder integration"; Optional = $true }
)

# Verify modules and import them
foreach ($module in $requiredModules) {
    $moduleName = $module.Name
    $isOptional = $module.Optional -eq $true
    
    if (Get-Module -ListAvailable -Name $moduleName) {
        Import-Module $moduleName
        if (-not $isOptional) {
            Write-Host "✓ $moduleName loaded" -ForegroundColor Green
        }
    }
    elseif (-not $isOptional) {
        Write-Host "! $moduleName not found. Install with:" -ForegroundColor Yellow
        Write-Host "  Install-Module -Name $moduleName -Scope CurrentUser -Force" -ForegroundColor Yellow
    }
}

# ===== OH-MY-POSH CONFIGURATION =====
# Initialize Oh-My-Posh with a customized theme
# You can explore themes at https://ohmyposh.dev/docs/themes

# Choose one of the following themes by uncommenting it:
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/agnoster.omp.json" | Invoke-Expression        # Classic agnoster
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/atomic.omp.json" | Invoke-Expression          # Compact, informative
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/powerlevel10k_lean.omp.json" | Invoke-Expression # Lean powerlevel
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/patriksvensson.omp.json" | Invoke-Expression  # Clean, minimal
oh-my-posh init pwsh --config "$themePath" | Invoke-Expression              # Modern, detailed

# ===== PSREADLINE CONFIGURATION =====
# Configure PSReadLine for better command line experience
if (Get-Module -Name PSReadLine) {
    # Enable predictive IntelliSense
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    
    # Customize the colors
    Set-PSReadLineOption -Colors @{
        Command            = 'Cyan'
        Parameter          = 'DarkCyan'
        Operator           = 'DarkGreen'
        Variable           = 'DarkGreen'
        String             = 'DarkYellow'
        Number             = 'DarkGreen'
        Type               = 'DarkGray'
        Comment            = 'DarkGray'
        InlinePrediction   = 'DarkGray'
    }
    
    # Set your preferred edit mode
    Set-PSReadLineOption -EditMode Windows
    
    # Add useful keybindings
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    
    # History search with Ctrl+r
    if (Get-Module -ListAvailable -Name PSFzf) {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+r' -PSReadlineChordReverseHistory 'Ctrl+f'
    }
    
    # Autocomplete with Ctrl+Space
    Set-PSReadLineKeyHandler -Key "Ctrl+Spacebar" -Function Complete
}

# ===== ENVIRONMENT SETUP =====
# Configure essential environment variables
$env:EDITOR = "code"
$env:PATH += ";C:\Program Files\Git\bin"

# Customize console encoding for better Unicode support
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# ===== CUSTOM FUNCTIONS =====
# Directory and navigation helpers
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function md { param($dir) New-Item -ItemType Directory -Path $dir | Out-Null; Set-Location $dir }

# Git shortcuts
function gst { git status }
function gco { param($branch) git checkout $branch }
function gpull { git pull }
function gpush { git push }
function gcom { param($msg) git commit -m $msg }

# Improved Get-ChildItem with icons and colors
function ls { Get-ChildItem @args | Format-Table -AutoSize }
function ll { Get-ChildItem @args | Format-Table -Property Mode, LastWriteTime, Length, Name -AutoSize }
function la { Get-ChildItem -Force @args | Format-Table -AutoSize }

# Improved which function
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue | 
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# System info at a glance
function sysinfo {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $ram = Get-CimInstance -ClassName Win32_ComputerSystem
    
    $ramGB = [math]::Round($ram.TotalPhysicalMemory / 1GB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::Round($ramGB - ($freeRAM / 1024), 2)
    $ramPercent = [math]::Round(($usedRAM / $ramGB) * 100, 0)
    
    $uptimeString = "{0:D2}d {1:D2}h {2:D2}m" -f $os.LocalDateTime.Subtract($os.LastBootUpTime).Days, 
                       $os.LocalDateTime.Subtract($os.LastBootUpTime).Hours, 
                       $os.LocalDateTime.Subtract($os.LastBootUpTime).Minutes
    
    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║ System Information                               ║" -ForegroundColor Cyan
    Write-Host "╠══════════════════════════════════════════════════╣" -ForegroundColor Cyan
    Write-Host "║ OS:       " -NoNewline -ForegroundColor Cyan; Write-Host (" {0}" -f $os.Caption).PadRight(37) -NoNewline; Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "║ Computer: " -NoNewline -ForegroundColor Cyan; Write-Host (" {0}" -f $env:COMPUTERNAME).PadRight(37) -NoNewline; Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "║ CPU:      " -NoNewline -ForegroundColor Cyan; Write-Host (" {0}" -f $cpu.Name).PadRight(37) -NoNewline; Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "║ RAM:      " -NoNewline -ForegroundColor Cyan; Write-Host (" {0:N2} GB (Used: {1:N2} GB, {2}%)" -f $ramGB, $usedRAM, $ramPercent).PadRight(37) -NoNewline; Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "║ Uptime:   " -NoNewline -ForegroundColor Cyan; Write-Host (" {0}" -f $uptimeString).PadRight(37) -NoNewline; Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "║ PowerShell: " -NoNewline -ForegroundColor Cyan; Write-Host (" {0}" -f $PSVersionTable.PSVersion).PadRight(35) -NoNewline; Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

# Fast directory switching
$global:DirAliases = @{
    "projects" = "$HOME\Documents\Projects"
    "docs" = "$HOME\Documents"
    "dl" = "$HOME\Downloads"
    "dt" = "$HOME\Desktop"
}

function goto ($alias) {
    if ($global:DirAliases.ContainsKey($alias)) {
        Set-Location $global:DirAliases[$alias]
    } else {
        Write-Host "No alias found for '$alias'. Available aliases:" -ForegroundColor Yellow
        $global:DirAliases.Keys | ForEach-Object { Write-Host "  $_ -> $($global:DirAliases[$_])" }
    }
}

# Add your own directory aliases here
# $global:DirAliases.Add("work", "C:\Path\To\Work")

# Advanced search function
function Search-Files {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        
        [Parameter(Mandatory=$false)]
        [string]$Path = ".",
        
        [Parameter(Mandatory=$false)]
        [string]$FilePattern = "*.*"
    )
    
    Get-ChildItem -Path $Path -Recurse -File -Filter $FilePattern | 
    Select-String -Pattern $Pattern | 
    Format-Table Path, LineNumber, Line -AutoSize
}

# Easy file extraction
function Extract-Archive {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [Parameter(Mandatory=$false)]
        [string]$Destination = "."
    )
    
    Expand-Archive -Path $Path -DestinationPath $Destination -Force
    Write-Host "Extracted to $Destination" -ForegroundColor Green
}

# Network troubleshooting utility
function Test-Network {
    param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = "google.com"
    )
    
    $result = Test-Connection -ComputerName $ComputerName -Count 4 -ErrorAction SilentlyContinue
    
    if ($result) {
        $avg = ($result | Measure-Object -Property ResponseTime -Average).Average
        Write-Host "Connection to $ComputerName successful. Average response time: $([math]::Round($avg, 2)) ms" -ForegroundColor Green
    } else {
        Write-Host "Connection to $ComputerName failed" -ForegroundColor Red
    }
}

# Enhanced help function
function helpme {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    Get-Help $Command -Detailed | Out-Host
    
    Write-Host "Examples:" -ForegroundColor Yellow
    Get-Help $Command -Examples | Out-Host
}

# Docker container management
function docker-clean {
    docker container prune -f
    docker image prune -f
    docker volume prune -f
    Write-Host "Docker system cleaned up" -ForegroundColor Green
}

# Enhanced prompt startup
function Show-Greeting {
    $hour = (Get-Date).Hour
    $greeting = "Good evening"
    
    if ($hour -lt 12) { $greeting = "Good morning" }
    elseif ($hour -lt 17) { $greeting = "Good afternoon" }
    
    $quote = Get-RandomQuote
    
    Clear-Host
    Write-Host ""
    Write-Host "$greeting, Howson!" -ForegroundColor Cyan
    Write-Host "Today is $(Get-Date -Format 'dddd, MMMM d, yyyy')" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💭 $quote" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "PowerShell $($PSVersionTable.PSVersion.ToString())" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-RandomQuote {
    $quotes = @(
        "The best way to predict the future is to invent it.",
        "Code is like humor. When you have to explain it, it's bad.",
        "Talk is cheap. Show me the code.",
        "Programming isn't about what you know; it's about what you can figure out.",
        "The most disastrous thing that you can ever learn is your first programming language.",
        "Simplicity is the soul of efficiency.",
        "Make it work, make it right, make it fast.",
        "Any fool can write code that a computer can understand. Good programmers write code that humans can understand.",
        "The only way to learn a new programming language is by writing programs in it.",
        "The function of good software is to make the complex appear simple.",
        "First, solve the problem. Then, write the code.",
        "Experience is the name everyone gives to their mistakes.",
        "The most important property of a program is whether it accomplishes the intention of its user.",
        "Sometimes it pays to stay in bed on Monday, rather than spending the rest of the week debugging Monday's code."
    )
    
    return $quotes[(Get-Random -Maximum $quotes.Count)]
}

# Check system updates
function Check-Updates {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    
    Write-Host "Checking for Windows updates..." -ForegroundColor Yellow
    
    try {
        $searchResult = $updateSearcher.Search("IsInstalled=0")
        
        if ($searchResult.Updates.Count -eq 0) {
            Write-Host "No updates available." -ForegroundColor Green
        } else {
            Write-Host "$($searchResult.Updates.Count) updates available:" -ForegroundColor Yellow
            
            $searchResult.Updates | ForEach-Object {
                Write-Host " - $($_.Title)" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "Error checking for updates: $_" -ForegroundColor Red
    }
}

# Create shortcut to open Profile in VSCode
function Edit-Profile {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $PROFILE
    } else {
        notepad $PROFILE
    }
}

# Command history browser
function history {
    Get-Content (Get-PSReadLineOption).HistorySavePath -Tail 50
}

# Start SSH Agent
function Start-SshAgent {
    if (!(Get-Process -Name ssh-agent -ErrorAction SilentlyContinue)) {
        Write-Host "Starting SSH agent..." -ForegroundColor Yellow
        Start-Service ssh-agent
        Write-Host "SSH agent started." -ForegroundColor Green
    } else {
        Write-Host "SSH agent is already running." -ForegroundColor Green
    }
}

# Create new aliases
New-Alias -Name g -Value git
New-Alias -Name touch -Value New-Item
New-Alias -Name open -Value Invoke-Item
New-Alias -Name codep -Value Edit-Profile
New-Alias -Name grep -Value Select-String
New-Alias -Name unzip -Value Extract-Archive
New-Alias -Name find -Value Search-Files
New-Alias -Name reload -Value '. $PROFILE'
New-Alias -Name ping -Value Test-Network
New-Alias -Name help -Value helpme
New-Alias -Name updates -Value Check-Updates

# ===== AUTO-STARTUP ACTIONS =====
# Show greeting on startup
Show-Greeting

# Complete loading message
Write-Host "🚀 Advanced PowerShell 7 profile loaded successfully! 🚀" -ForegroundColor Green
Write-Host "Type 'sysinfo' for system information" -ForegroundColor DarkGray