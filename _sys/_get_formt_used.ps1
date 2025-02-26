# Ange sökvägen till huvudkatalogen
param (
    # Rootkatalog
    [Parameter(Mandatory=$true)]
    [string]$rootFolder
)


Clear-Host

# $rootFolder = "C:\dev\Datalager_procsrc"

# Eliminerar ev. citattecken från sökvägen
$rootFolder = $rootFolder.Replace("""", "")

# Hämta alla kataloger och .bat-filer i huvudkatalogen, exkludera de som heter "datalager" eller börjar med "_"
$directories = Get-ChildItem -Path $rootFolder -Directory | Where-Object { $_.Name -ne "datalager" -and -not $_.Name.StartsWith("_") }
$batFiles = Get-ChildItem -Path $rootFolder -Filter *.bat -File | Where-Object { $_.Name -ne "datalager.bat" -and -not $_.Name.StartsWith("_") }

# Skapa listor för att lagra matchande objekt
$matchedFiles = @()
$matchedDirectories = @()
$columnData = @{}

# Ange vilken kolumn som ska grupperas (0-baserat index)
$columnIndex = 4  # Exempel: Tredje kolumnen (ändra vid behov)

# Loopar igenom varje .bat-fil och letar efter en matchande katalog
foreach ($batFile in $batFiles) {
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($batFile.Name)

    foreach ($directory in $directories) {
        if ($directory.Name -eq $fileName) {
            $matchedFiles += $batFile
            $matchedDirectories += $directory
            break
        }
    }
}

# Behandla den specifika ini-filen i _schema-mappen för varje matchad katalog
foreach ($directory in $matchedDirectories) {
    $schemaPath = Join-Path -Path $directory.FullName -ChildPath "_schema"
    $iniFilePath = Join-Path -Path $schemaPath -ChildPath "_modul-settings-datasets.ini"

    if (Test-Path $iniFilePath) {
        # Läs in ini-filen och filtrera bort tomma rader och kommentarer
        $content = Get-Content $iniFilePath | Where-Object { $_ -match '\S' -and -not $_.StartsWith("#") -and -not $_.StartsWith(";") }

        foreach ($line in $content) {
            $values = $line -split "\|"

            if ($values.Count -gt $columnIndex) {
                $columnValue = $values[$columnIndex].Trim()

                if ($columnData.ContainsKey($columnValue)) {
                    $columnData[$columnValue] += 1
                } else {
                    $columnData[$columnValue] = 1
                }
            }
        }
    }
}


Write-Output ""
# Skriv ut de grupperade värdena
$columnData.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Output "$($_.Name): $($_.Value)"
}
Write-Output ""
