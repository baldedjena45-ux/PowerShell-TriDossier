$targetFolder = "C:\Users\balde\Desktop\DossierATrier"
if (-not (Test-Path -Path $targetFolder -PathType Container)) {
    Write-Host "Le dossier spécifié n'existe pas : $targetFolder" -ForegroundColor Red
    exit
}
Write-Host "Organisation du dossier : $targetFolder" -ForegroundColor Green
$files = Get-ChildItem -Path $targetFolder -File
foreach ($file in $files) {
    $extension = $file.Extension
    if ([string]::IsNullOrEmpty($extension)) {
        $categoryName = "SANS_EXTENSION"
    } else {
        $categoryName = $extension.TrimStart('.').ToUpper()
    }
    $destinationFolder = Join-Path -Path $targetFolder -ChildPath $categoryName
    if (-not (Test-Path -Path $destinationFolder -PathType Container)) {
        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
    }
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $file.Name
    Move-Item -Path $file.FullName -Destination $destinationPath
}
