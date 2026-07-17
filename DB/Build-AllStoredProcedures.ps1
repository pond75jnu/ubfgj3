param
(
    [string]$StoredProcedureDirectory = (Join-Path $PSScriptRoot 'StoredProcedure'),
    [string]$OutputPath = (Join-Path $PSScriptRoot 'StoredProcedure\All_SP_LIST.sql')
)

$ErrorActionPreference = 'Stop'

$files = Get-ChildItem -LiteralPath $StoredProcedureDirectory -Filter '*.sql' -File |
    Where-Object { $_.Name -ne 'All_SP_LIST.sql' } |
    Sort-Object -Property Name

$parts = New-Object System.Collections.Generic.List[string]

foreach ($file in $files)
{
    $body = [System.IO.File]::ReadAllText($file.FullName)
    $body = $body.TrimStart([char]0xFEFF)
    $body = $body -replace "`r`n", "`n"
    $body = $body -replace "`r", "`n"
    $body = $body.Trim()

    $parts.Add('/******************************************************************************')
    $parts.Add(' * ' + $file.Name)
    $parts.Add(' ******************************************************************************/')
    $parts.Add($body)
    $parts.Add('')
    $parts.Add('GO')
    $parts.Add('')
}

$output = [string]::Join("`n", $parts)
$output = $output.TrimEnd() + "`n"
$output = $output -replace "`n", "`r`n"

$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($OutputPath, $output, $utf8Bom)

Write-Output ("Generated {0} from {1} procedures." -f $OutputPath, $files.Count)
