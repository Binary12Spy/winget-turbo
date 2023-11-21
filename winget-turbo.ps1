# Check if running as administrator
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isElevated) {
    # Relaunch script with elevated permissions
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs
    exit
}

# Read file, filtering out blank lines
$inputFile = ".\packages.txt"
$lines = Get-Content -Path $inputFile | Where-Object { $_ -ne '' }

# Filter our comment lines (#)
$filteredLines = $lines | Where-Object { $_ -notmatch '^#' }

foreach ($line in $filteredLines) {
    # Execute winget command
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c winget install --id=$line -e" -Verb RunAs
}