function Test-IsAdministrator {
    $Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object System.Security.Principal.WindowsPrincipal($Identity)
    $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-IsUacEnabled {
    (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System).EnableLua -ne 0
}

function Request-AdminRights {
    # Check if already an administrator
    if (!(Test-IsAdministrator)) {
        if (Test-IsUacEnabled) {
            # Construct argument list
            [string[]]$argList = @('-NoProfile', '-NoExit', '-File', $MyInvocation.MyCommand.Path)
            $argList += $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key)", "$($_.Value)" }
            $argList += $MyInvocation.UnboundArguments

            # Start new elevated process
            Start-Process PowerShell.exe -Verb Runas -WorkingDirectory $pwd
            return
        } else {
            throw "You must be an administrator to run this script."
        }
    }
}

Request-AdminRights

# Read file, filtering out blank lines
$inputFile = ".\packages.txt"
$lines = Get-Content -Path $inputFile | Where-Object { $_ -ne '' }

# Filter our comment lines (#)
$filteredLines = $lines | Where-Object { $_ -notmatch '^#' }

foreach ($line in $filteredLines) {
    # Execute winget command
    Start-Process PowerShell -ArgumentList "-Command", "& {winget install --id=$line --accept-source-agreements --accept-package-agreements -e -h}"
}