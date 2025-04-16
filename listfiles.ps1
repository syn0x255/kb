$rootPath = "\\ServerName\SharedFolder"  # Replace with your root path
$outputFile = "C:\accessible_paths.txt"  # Output file path

function Test-DirectoryAccess {
    param ([string]$Path)
    try {
        Get-ChildItem -Path $Path -Directory -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Get-AllAccessibleDirectories {
    param ([string]$StartPath)

    $queue = New-Object System.Collections.Generic.Queue[string]
    $queue.Enqueue($StartPath)

    $results = @()

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()

        if (Test-DirectoryAccess -Path $current) {
            $results += $current

            try {
                $subDirs = Get-ChildItem -Path $current -Directory -ErrorAction Stop
                foreach ($dir in $subDirs) {
                    $queue.Enqueue($dir.FullName)
                }
            } catch {}
        }
    }

    # Write all accessible directories to file
    $results | Sort-Object | Set-Content -Path $outputFile -Encoding UTF8
}

Get-AllAccessibleDirectories -StartPath $rootPath
