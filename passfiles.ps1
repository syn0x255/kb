$inputFile = "C:\accessible_paths.txt"         # List of accessible directories
$outputFile = "C:\readable_files.txt"          # Output file for readable files
$maxFileSize = 1MB                             # Set the file size limit (1MB in this case)

function Test-ReadAndScan {
    param ([string]$filePath)

    try {
        # Check file size
        $fileSize = (Get-Item $filePath).Length

        if ($fileSize -gt $maxFileSize) {
            return $null  # Skip large files
        }

        # Try to open the file for reading
        $stream = [System.IO.File]::OpenText($filePath)
        $content = $stream.ReadToEnd()
        $stream.Close()

        # Check for "password" (case-insensitive)
        if ($content -match "(?i)password") {
            return "R [contains: password]"
        } else {
            return "R"
        }
    } catch {
        return $null  # Not readable or failed
    }
}

# Initialize output collection
$results = @()

# Read paths from input file
$paths = Get-Content $inputFile

foreach ($dir in $paths) {
    try {
        $files = Get-ChildItem -Path $dir -File -ErrorAction Stop  # Non-recursive
        foreach ($file in $files) {
            $result = Test-ReadAndScan -filePath $file.FullName
            if ($result) {
                $results += "$($file.FullName) - $result"
            }
        }
    } catch {
        # Could not access the directory; skip
    }
}

# Save results
$results | Sort-Object | Set-Content -Path $outputFile -Encoding UTF8
