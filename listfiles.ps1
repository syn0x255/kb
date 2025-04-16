$rootPath = "\\ServerName\SharedFolder"  # Change to your network share

function Test-DirectoryAccess {
    param ([string]$Path)
    try {
        Get-ChildItem -Path $Path -Directory -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Get-DeepestAccessibleDirectories {
    param ([string]$StartPath)

    $queue = New-Object System.Collections.Generic.Queue[string]
    $queue.Enqueue($StartPath)

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()

        if (Test-DirectoryAccess -Path $current) {
            $accessibleSubDirs = @()

            try {
                $subDirs = Get-ChildItem -Path $current -Directory -ErrorAction Stop
                foreach ($dir in $subDirs) {
                    if (Test-DirectoryAccess -Path $dir.FullName) {
                        $accessibleSubDirs += $dir.FullName
                        $queue.Enqueue($dir.FullName)
                    }
                }
            } catch {}

            # If there are no accessible children, this is a "deepest accessible" path
            if ($accessibleSubDirs.Count -eq 0) {
                Write-Output $current
            }
        }
    }
}

Get-DeepestAccessibleDirectories -StartPath $rootPath
