param (
    [string]$rootFolder = "C:\LKR_GIS\Datalager_procsrc\_geodatarepo"
)

# Kontrollera om $rootFolder är satt, annars avsluta med ett felmeddelande
if (-not $rootFolder) {
    Write-Error "Du måste ange en sökväg till rootFolder."
    exit
}

$rootFolder = $rootFolder.Trim("`"")
# Kontrollera om katalog existerar
if (-not (Test-Path $rootFolder)) {
    Write-Error "Du måste ange en giltig katalog."
    exit
}

# Definiera sökvägen och namnet på loggfilen i samma katalog som rootFolder
$logFile = Join-Path -Path $rootFolder -ChildPath "DatalagerDistributionSource.log"
Write-Output $logFile
# Kontrollera om loggfilen redan finns, ta bort den i så fall
if (Test-Path $logFile) {
    Remove-Item $logFile
}

# Skapa en ny tom loggfil
New-Item -ItemType File -Path $logFile

# Hämta alla underkataloger i den angivna roten
$directories = Get-ChildItem -Path $rootFolder -Recurse -Directory

# Filtrera ut endast de kataloger som innehåller filer
$directoriesWithFiles = $directories | Where-Object {
    Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 0 }
}

# Skapa en lista med relativa sökvägar
$relativePaths = foreach ($dir in $directoriesWithFiles) {
    $dir.FullName.Replace($rootFolder, "").TrimStart("\")
}

# Sortera de relativa sökvägarna
$sortedRelativePaths = $relativePaths | Sort-Object

# Loopar igenom alla sorterade relativa sökvägar och skriver dem till loggfilen
foreach ($relativePath in $sortedRelativePaths) {
    Add-Content -Path $logFile -Value $relativePath
}

Write-Output "Underkataloger som innehåller filer har skrivits till loggfilen: $logFile"
