# Syfte: Redovisa skillnader mellan två kataloger


param (
  # Rootkatalog
  [Parameter(Mandatory = $true)]
  [string]$rootFolder,
  [Parameter(Mandatory = $true)]
  [string]$repoSubFolder,
  [ValidateSet("Enkel", "Tabell")]
  [string]$PresentType = 'Tabell',
  [string]$source,
  [string]$sajt
)

Clear-Host

# Definiera kataloger att jämföra
# $source = "C:\LKR_GIS\Datalager_procsrc\_geodatarepo"
# $sajt = "\\ADMSRV0030\Geodata\Resurs\Data_auto"
# $source = "C:\temp\slask\comparefolderfiles\folder1"
# $sajt = "C:\temp\slask\comparefolderfiles\folder2"

$rootFolder = $rootFolder.Replace("""", "")
$repoSubFolder = $repoSubFolder.Replace("""", "")
# Läs in ini-filen och filtrera bort rader som börjar med ";" eller är tomma
$targetPathsSajts = Join-Path -Path $rootFolder -ChildPath "_global-settings-targetpaths.ini"
$values = Get-Content $targetPathsSajts | Where-Object { $_ -notmatch "^\s*;" -and $_ -match "\S" }

# Definierar nödvändiga sökvägar för repo och en filsajt
$source = Join-Path -Path $rootFolder -ChildPath $repoSubFolder
$sajt = $values[0]


# Hämta alla filer rekursivt och formatera sökvägen relativt katalogen
$files1 = Get-ChildItem -Path $source -Recurse | ForEach-Object { $_.FullName.ToLower().Replace($source.ToLower(), '') }
$files2 = Get-ChildItem -Path $sajt -Recurse | ForEach-Object { $_.FullName.ToLower().Replace($sajt.ToLower(), '') }


if ($PresentType -eq "Enkel") {
  # Jämför filerna
  $comparison = Compare-Object -ReferenceObject $files1 -DifferenceObject $files2

  # Visa resultatet på ett pedagogiskt sätt
  foreach ($diff in $comparison) {
    if ($diff.SideIndicator -eq "<=") {
      Write-Host '[MISSING ON SAJT] ' $($diff.InputObject) -ForegroundColor Red
    }
    elseif ($diff.SideIndicator -eq "=>") {
      Write-Host '[MISSIN IN SOURCE] ' $($diff.InputObject) -ForegroundColor Green
    }
  }
}
elseif ($PresentType -eq "Tabell") {
  # Slå ihop alla unika filnamn och sortera i bokstavsordning
  $allFiles = ($files1 + $files2) | Sort-Object -Unique

  # Inkludera rubrikernas längd i beräkningen av bredder
  $header1 = 'Repo`n(Green = missing on sajt, Cyan = exists in both)'
  $header2 = 'Sajt`n(Red = missin in source, Cyan = exists in both)'

  # Hitta längsta texten i respektive kolumn
  $maxWidth1 = ($files1 + $header1 -split '`n' | Measure-Object -Maximum -Property Length).Maximum
  $maxWidth2 = ($files2 + $header2 -split '`n' | Measure-Object -Maximum -Property Length).Maximum

  # Lägg till lite extra marginal för bättre läsbarhet
  $colWidth1 = [math]::Max($maxWidth1, 20) + 2
  $colWidth2 = [math]::Max($maxWidth2, 20) + 2

  # Divider-linje
  $divider = "-" * ($colWidth1 + $colWidth2 + 7)
  Write-Host $divider

  # Skriva ut tabellens rubrik, korrekt linjerad
  $header1Lines = $header1 -split '`n'
  $header2Lines = $header2 -split '`n'

  for ($i = 0; $i -lt [math]::Max($header1Lines.Count, $header2Lines.Count); $i++) {
    $col1Text = if ($i -lt $header1Lines.Count) { $header1Lines[$i] } else { '' }
    $col2Text = if ($i -lt $header2Lines.Count) { $header2Lines[$i] } else { '' }

    Write-Host '| ' -NoNewline
    Write-Host ($col1Text.PadRight($colWidth1)) -NoNewline
    Write-Host ' | ' -NoNewline
    Write-Host ($col2Text.PadRight($colWidth2)) -NoNewline
    Write-Host ' |'
  }

  Write-Host $divider

  # Skriv ut filerna i tabellformat
  foreach ($file in $allFiles) {
    $existsInFolder1 = $files1 -contains $file
    $existsInFolder2 = $files2 -contains $file

    # Bestäm färger för varje kolumn
    $color1 = if ($existsInFolder1 -and -not $existsInFolder2) { 'Green' } 
    elseif ($existsInFolder1 -and $existsInFolder2) { 'Cyan' } 
    else { 'White' }

    $color2 = if ($existsInFolder2 -and -not $existsInFolder1) { 'Red' } 
    elseif ($existsInFolder1 -and $existsInFolder2) { 'Cyan' } 
    else { 'White' }

    # Padda filnamnen dynamiskt
    $filePadded1 = if ($existsInFolder1) { $file.PadRight($colWidth1) } else { ''.PadRight($colWidth1) }
    $filePadded2 = if ($existsInFolder2) { $file.PadRight($colWidth2) } else { ''.PadRight($colWidth2) }

    # Skriva ut tabellraden
    Write-Host '| ' -NoNewline
    Write-Host $filePadded1 -ForegroundColor $color1 -NoNewline
    Write-Host ' | ' -NoNewline
    Write-Host $filePadded2 -ForegroundColor $color2 -NoNewline
    Write-Host ' |'
  }

  # Avslutande linje
  Write-Host $divider
  Write-Host ""
  Write-Host "COMPARED"
  Write-Host "==========================="
  Write-Host "Source (repo):  $source ($(($allFiles | Where-Object { $files1 -contains $_ }).Count) st. poster)"
  Write-Host "Sajt represent: $sajt ($(($allFiles | Where-Object { $files2 -contains $_ }).Count) st. poster)"
  Write-Host "Number comparing rows: $($allFiles.Length)"
  Write-Host ""

}
else {
  Write-Host 'Inget hanterat alternativ'
}