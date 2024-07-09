param (
    # Rootkatalog
    [Parameter(Mandatory=$true)]
    [string]$rootFolder,
    
    # Filfilter
    [string]$filter = "*.fmw"

)

Clear-Host

# Eliminerar ev. citattecken från sökvägen
$rootFolder = $rootFolder.Replace("""", "")

# Definiera texten som indikerar att rader ska ignoreras från denna rad till slutet
$endText = "#! </WORKSPACE>"

# Definiera XML-tagg och element du letar efter
$xmlTag = "WORKSPACE"

# Definiera tecknet som rader måste börja med för att accepteras
$validStartChar = "#"

# Hämta alla XML-filer i rotkatalogen och dess underkataloger
$xmlFiles = Get-ChildItem -Path $rootFolder -Recurse -Filter $filter

# Sortera filerna efter katalog och filnamn
$xmlFiles = $xmlFiles | Sort-Object DirectoryName, Name

$fmeVersions = @()
$fmeEncodings = @()


foreach ($file in $xmlFiles) {
    try {
        # Läs in filens innehåll rad för rad
        $lines = Get-Content -Path $file.FullName

        # Hitta indexet för raden som börjar med endText
        $endIndex = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].TrimStart() -match $endText) {
                $endIndex = $i
                break
            }
        }

        # Om endText hittades, ta endast rader upp till och med den raden
        if ($endIndex -ge 0) {
            $lines = $lines[0..$endIndex]
        }

        # Filtrera bort rader som inte börjar med det specifika tecknet
        $filteredLines = $lines | Where-Object { $_.TrimStart() -like "$validStartChar*" }
        
        # Ta bort tecknen #! eller # i början av en rad
        $cleanedLines = $filteredLines | ForEach-Object {
            $line = $_.TrimStart()
            if ($line.StartsWith("#!")) {
                $line = $line.Substring(2).Trim()
            } elseif ($line.StartsWith("#")) {
                $line = $line.Substring(1).Trim()
            }
            return $line
        }

        # Hitta startraden där FME skriver in hur anrop till skriptet ska göras. Uppfyller ej XML-standard.
        $startIndex = -1
        for ($i = 0; $i -lt $cleanedLines.Count; $i++) {
            if ($cleanedLines[$i].Trim() -match '<WORKSPACE') {
                $startIndex = $i
                break
            }
        }

        # Hitta slutraden där FME skriver in hur anrop till skriptet ska göras. Uppfyller ej XML-standard.
        $endIndex = -1
        for ($i = 0; $i -lt $cleanedLines.Count; $i++) {
            if ($cleanedLines[$i].Trim() -match '^(?i)([a-zA-Z0-9_]+\s*)=\s*(".*?"|[a-zA-Z0-9]+)$') {
                $endIndex = $i
                break
            }
        }

        # Konvertera $cleanedLines arrayen till en ArrayList
        $cleanedLinesList = [System.Collections.ArrayList]@($cleanedLines)

        # Klipper bort raderna där FME skriver in hur anrop till skriptet ska göras.
        $numberOfElementsToRemove = $endIndex - ($startIndex + 1)
        $cleanedLinesList.RemoveRange($startIndex + 1, $numberOfElementsToRemove)

        # # Kombinera de renade raderna till en enda sträng
        $cleanedContent = $cleanedLinesList -join "`n"

        # # Ladda in det rensade innehållet som XML
        [xml]$xmlContent = $cleanedContent

        # # Hämta värdet av den specifika XML-taggen
        $attributeLastSavedBuild = $xmlContent.WORKSPACE.LAST_SAVE_BUILD
        $attributeFmeNamesEncoding = $xmlContent.WORKSPACE.FME_NAMES_ENCODING

        if ($attributeFmeNamesEncoding -eq $null -or $attributeFmeNamesEncoding -eq "") {
            $attributeFmeNamesEncoding = "N/A"
        }

        $fmeVersions += $attributeLastSavedBuild
        $fmeEncodings += $attributeFmeNamesEncoding

        # # Visa filnamn och värdet av taggen
        Write-Host $($file.FullName)
        Write-Host "`t $attributeLastSavedBuild"
        Write-Host "`t $attributeFmeNamesEncoding"
    } catch {
        Write-Host "Error processing file: $($file.FullName)"
        Write-Host $_.Exception.Message
    }
}

# Skapa en hashtabell för att lagra unika värden och deras förekomster
# $hashTable = @{}

# # Loop genom varje element i arrayen
# foreach ($item in $fmeVersions) {
#     if ($hashTable.ContainsKey($item)) {
#         # Om värdet redan finns i hashtabellen, öka räknaren
#         $hashTable[$item] += 1
#     } else {
#         # Annars, lägg till värdet i hashtabellen med en startförekomst på 1
#         $hashTable[$item] = 1
#     }
# }

# Write-Host ""

# # Visa resultatet
# foreach ($key in $hashTable.Keys) {
#     Write-Host "$key : $($hashTable[$key])"
# }

# $hashTable = @{}

# # Loop genom varje element i arrayen
# foreach ($item in $fmeEncodings) {
#     if ($hashTable.ContainsKey($item)) {
#         # Om värdet redan finns i hashtabellen, öka räknaren
#         $hashTable[$item] += 1
#     } else {
#         # Annars, lägg till värdet i hashtabellen med en startförekomst på 1
#         $hashTable[$item] = 1
#     }
# }

# Write-Host ""

# # Visa resultatet
# foreach ($key in $hashTable.Keys) {
#     Write-Host "$key : $($hashTable[$key])"
# }

Write-Host ""
Write-Host "SAMMANFATTNING"
Write-Host "==========================="
Write-Host ""
Write-Host "Versioner"
Write-Host "---------------------------"


# Använd Group-Object för att gruppera och räkna förekomster
$groupedFmeVersions = $fmeVersions | Group-Object

# Sortera grupperna baserat på antalet förekomster i fallande ordning
# $sortedGroupedFmeVersions = $groupedFmeVersions | Sort-Object Count -Descending

# Sortera grupperna baserat på namnet i stigande ordning
$sortedGroupedFmeVersions = $groupedFmeVersions | Sort-Object Name

# Visa resultatet
foreach ($group in $sortedGroupedFmeVersions) {
    Write-Host "$($group.Name): $($group.Count)"
}

Write-Host ""
Write-Host "Encoding"
Write-Host "---------------------------"

# Använd Group-Object för att gruppera och räkna förekomster
$groupedFmeEncodings = $fmeEncodings | Group-Object

# Sortera grupperna baserat på antalet förekomster i fallande ordning
# $sortedGroupedFmeEncodings = $groupedFmeEncodings | Sort-Object Count -Descending

# Sortera grupperna baserat på namnet i stigande ordning
$sortedGroupedFmeEncodings = $groupedFmeEncodings | Sort-Object Name

# Visa resultatet
foreach ($group in $sortedGroupedFmeEncodings) {
    Write-Host "$($group.Name): $($group.Count)"
}
Write-Host ""
