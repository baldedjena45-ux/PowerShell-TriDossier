
#commit 2: ajout du fichier de log
    # Phase IA - Script de tri par extension amélioré
param(
    [string]$targetFolder
)

# 1) Si aucun dossier n'est passé en paramètre, le demander à l'utilisateur
if (-not $targetFolder -or $targetFolder.Trim() -eq "") {
    $targetFolder = Read-Host "Entrez le chemin du dossier à organiser"
}

# Vérifier que le dossier existe
if (-not (Test-Path -Path $targetFolder -PathType Container)) {
    Write-Host "Le dossier spécifié n'existe pas : $targetFolder" -ForegroundColor Red
    exit
}

Write-Host "Organisation du dossier : $targetFolder" -ForegroundColor Green
Write-Host ""

# 2) Définir un fichier de log pour garder une trace des opérations
$logFile = Join-Path -Path $targetFolder -ChildPath "tri_log.txt"
"===== Nouveau tri : $(Get-Date) =====" | Out-File -FilePath $logFile -Encoding UTF8

# 3) Extensions à ignorer (ex : exécutables, installateurs)
$extensionsIgnorees = @(".exe", ".msi")

# Récupérer tous les fichiers du dossier (sans les sous-dossiers)
$files = Get-ChildItem -Path $targetFolder -File

if ($files.Count -eq 0) {
    Write-Host "Aucun fichier à organiser dans ce dossier." -ForegroundColor Yellow
    "Aucun fichier à organiser." | Add-Content -Path $logFile
    exit
}

foreach ($file in $files) {

    # Si l'extension est dans la liste à ignorer, on passe au suivant
    if ($extensionsIgnorees -contains $file.Extension.ToLower()) {
        Write-Host "Ignoré (extension exclue) : $($file.Name)"
        "Ignoré (extension exclue) : $($file.Name)" | Add-Content -Path $logFile
        continue
    }

    # Récupérer l'extension du fichier
    $extension = $file.Extension

    # Déterminer le nom de catégorie (nom du sous-dossier)
    if ([string]::IsNullOrEmpty($extension)) {
        $categoryName = "SANS_EXTENSION"
    } else {
        # Retirer le point "." et mettre en majuscule pour le nom du dossier
        $categoryName = $extension.TrimStart('.').ToUpper()
    }

    # Construire le chemin complet du sous-dossier
    $destinationFolder = Join-Path -Path $targetFolder -ChildPath $categoryName

    # Créer le sous-dossier s'il n'existe pas
    if (-not (Test-Path -Path $destinationFolder -PathType Container)) {
        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
        Write-Host "Dossier créé : $destinationFolder"
        "Dossier créé : $destinationFolder" | Add-Content -Path $logFile
    }

    # Construire le chemin de destination final du fichier
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $file.Name

    # Déplacer le fichier
    Move-Item -Path $file.FullName -Destination $destinationPath

    $message = "Déplacé : $($file.Name) -> $categoryName"
    Write-Host $message
    $message | Add-Content -Path $logFile
}

Write-Host ""
Write-Host "Organisation terminée. Détails dans le fichier tri_log.txt." -ForegroundColor Green
"Organisation terminée." | Add-Content -Path $logFile

