# Syfte: Ge underlag för utvärdering genom att presentera äldre filer under geodatarepo och sajter

param (
    # Rootkatalog
    [Parameter(Mandatory=$true)]
    [string]$rootRepoFolder
)

# PowerShell-skript för listning av viss katalog och dess underkataloger med min och max datum för filinnehåll, sorterat på sökväg
Clear-Host

$rootRepoFolder

# Define the root directory
$rootDirectory = $rootRepoFolder

$ageLimitNotOlderThen = 7

# $rootDirectory = "c:\lkr_gis\datalager_procsrc\_geodatarepo"

# Check if the specified directory exists
if (-Not (Test-Path -Path $rootDirectory)) {
    Write-Host "Directory does not exist: $rootDirectory"
    exit
}

# Get all directories including the root directory
$directories = Get-ChildItem -Path $rootDirectory -Directory -Recurse -Force |
                Sort-Object -Property FullName | 
                ForEach-Object { $_.FullName }

# Add the root directory to the list if you want to include it at its sorted position
# Ensure it is also sorted correctly within the list
# Inte i rätt sorteringsordning, rootkatalog läggs till i slutet
# $directories += $rootDirectory
# För rätt sortering, rootkatalog läggs till först
$directories = @($rootDirectory) + $directories | Sort-Object

# Define the date threshold for X days ago
$daysFromAgeLimit = (Get-Date).AddDays(-$ageLimitNotOlderThen)

# Iterate through each directory
foreach ($directory in $directories) {
    # Get all files in the directory
    $files = Get-ChildItem -Path $directory -File -Force

    if ($files.Length -gt 0) {
        # Get min and max dates
        $minDateObj = ($files | Measure-Object -Property LastWriteTime -Minimum).Minimum
        $maxDateObj = ($files | Measure-Object -Property LastWriteTime -Maximum).Maximum

        $minDate = $minDateObj.ToString("yyyy-MM-dd")
        $maxDate = $maxDateObj.ToString("yyyy-MM-dd")

        # Beräkna skillnaden i dagar
        $dateDifference = ($maxDateObj - $minDateObj).Days

        # Output the directory and the min/max dates
        # Check if minDate and maxDate are different
        Write-Host "Directory: $directory"
        if ($minDate -ne $maxDate) {
            if ($dateDifference -gt $ageLimitNotOlderThen) {
                Write-Host "Min Date: $minDate" -ForegroundColor Red
                Write-Host "Max Date: $maxDate" -ForegroundColor Red
            }
            else {
                Write-Host "Min Date: $minDate" -ForegroundColor Yellow
                Write-Host "Max Date: $maxDate" -ForegroundColor Yellow
            }
            Write-Host ""
        }
        elseif ($minDateObj -lt $daysFromAgeLimit -and $maxDateObj -lt $daysFromAgeLimit) {
            Write-Host "Min Date: $minDate" -ForegroundColor Magenta
            Write-Host "Max Date: $maxDate" -ForegroundColor Magenta
            Write-Host ""
        }
        else {
            Write-Host "Min Date: $minDate"
            Write-Host "Max Date: $maxDate"
            Write-Host ""
        }    
    }
    else {
        # Notify if no files are found in the directory
        Write-Host "Directory: $directory"
        Write-Host "HAS NO FILES." -ForegroundColor Cyan
        Write-Host ""
    }
}

Write-Host ""
Write-Host "BESKRIVNING"
Write-Host "==========================="

Write-Host "Inga filer i katalogen"-ForegroundColor Cyan
Write-Host "Olika datum på filer men INTE äldre än $ageLimitNotOlderThen dagar" -ForegroundColor Yellow
Write-Host "Olika datum och där skillnaden mellan filerna överstiger $ageLimitNotOlderThen dagar" -ForegroundColor Red
Write-Host "Alla filer i katalogen är äldre än $ageLimitNotOlderThen dagar" -ForegroundColor Magenta
Write-Host "Ofärgade troligen aktuella filer"
Write-Host ""
