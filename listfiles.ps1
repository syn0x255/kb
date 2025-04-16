# Set the starting path
$rootPath = "C:\"

# Function to check if a directory is accessible
function Test-DirectoryAccess {
    param (
        [string]$Path
    )
    try {
        # Attempt to get child items to test access
        Get-ChildItem -Path $Path -Directory -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Recursively check accessible directories
function Get-AccessibleDirectories {
    param (
        [string]$StartPath
    )

    $queue = New-Object System.Collections.Generic.Queue[string]
    $queue.Enqueue($StartPath)

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        if (Test-DirectoryAccess -Path $current) {
            Write-Output "Accessible: $current"
            try {
                $subDirs = Get-ChildItem -Path $current -Directory -ErrorAction Stop
                foreach ($dir in $subDirs) {
                    $queue.Enqueue($dir.FullName)
                }
            } catch {
                # Just skip if something goes wrong
            }
        } else {
            Write-Output "Inaccessible: $current"
        }
    }
}

# Start checking from root
Get-AccessibleDirectories -StartPath $rootPath
