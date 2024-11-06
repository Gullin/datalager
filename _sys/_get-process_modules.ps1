# Ange sökvägen till huvudkatalogen
param (
    # Rootkatalog
    [Parameter(Mandatory=$true)]
    [string]$rootFolder
)

Clear-Host

# Eliminerar ev. citattecken från sökvägen
$rootFolder = $rootFolder.Replace("""", "")

# Hämta alla kataloger och .bat-filer i huvudkatalogen, exkludera de som heter "datalager" eller börjar med "_"
$directories = Get-ChildItem -Path $rootFolder -Directory | Where-Object { $_.Name -ne "datalager" -and -not $_.Name.StartsWith("_") }
$batFiles = Get-ChildItem -Path $rootFolder -Filter *.bat -File | Where-Object { $_.Name -ne "datalager.bat" -and -not $_.Name.StartsWith("_") }

# Skapa listor för att lagra matchande och omatchade objekt
$matchedFiles = @()
$matchedDirectories = @()
$unmatchedFiles = @()
$unmatchedDirectories = @()

# Loopar igenom varje .bat-fil och letar efter en matchande katalog
Write-Output "PROCESSMODULER"
Write-Output "==========================="
foreach ($batFile in $batFiles) {
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($batFile.Name)
    $matchFound = $false

    foreach ($directory in $directories) {
        if ($directory.Name -eq $fileName) {
            Write-Output "$fileName"
            $matchedFiles += $batFile
            $matchedDirectories += $directory
            $matchFound = $true
            break
        }
    }

    if (-not $matchFound) {
        $unmatchedFiles += $batFile
    }
}

# Lägg till omatchade kataloger
foreach ($directory in $directories) {
    if ($matchedDirectories -notcontains $directory) {
        $unmatchedDirectories += $directory
    }
}

# Skriv ut antalet matchande par
$matchCount = $matchedFiles.Count
Write-Output "`nAntal processmoduler"
Write-Output "---------------------------"
Write-Output "$matchCount"

# Listar omatchade .bat-filer
Write-Output "`nAvvikande filer"
Write-Output "---------------------------"
foreach ($file in $unmatchedFiles) {
    Write-Output $file.Name
}

# Listar omatchade kataloger
Write-Output "`nAvvikande kataloger"
Write-Output "---------------------------"
foreach ($directory in $unmatchedDirectories) {
    Write-Output $directory.Name
}
