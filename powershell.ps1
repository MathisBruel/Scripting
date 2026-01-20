# Script de nettoyage conditionnel multi-dossiers (PowerShell)
# Date: $(Get-Date)

# 1. Force l'encodage UTF-8 pour la console et la sortie
$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$PROJECTS_ROOT = ".\projects"
$LOG_FOLDER = ".\logs"
$CurrentDate = Get-Date -Format "yyyyMMdd"
$LOG_FILE = "cleanup_$CurrentDate.log"

# Créer le dossier de logs s'il n'existe pas
if (-not (Test-Path -Path $LOG_FOLDER)) {
    New-Item -ItemType Directory -Path $LOG_FOLDER -Force | Out-Null
}

$FILE_PATH = Join-Path -Path $LOG_FOLDER -ChildPath $LOG_FILE

# Fonction de journalisation
function Write-Log {
    param (
        [string]$ProjectName,
        [string]$Action,
        [string]$Reason
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] Projet: $ProjectName > Action: $Action | Raison: $Reason"
    Add-Content -Path $FILE_PATH -Value $LogEntry -Encoding UTF8
}

Write-Host "============================================"
Write-Host "  Script de nettoyage conditionnel"
Write-Host "  Date: $(Get-Date)"
Write-Host "============================================"
Write-Host ""
Write-Log -ProjectName "Script Start" -Action "Info" -Reason "Debut du script de nettoyage"

$StartTime = Get-Date -Format "HH:mm:ss"
Write-Host "[$StartTime] > Debut du nettoyage"
Write-Host ""

# Récupérer les dossiers dans PROJECTS_ROOT
if (Test-Path $PROJECTS_ROOT) {
    $Projects = Get-ChildItem -Path $PROJECTS_ROOT -Directory
} else {
    Write-Host "X Le dossier racine $PROJECTS_ROOT n'existe pas."
    exit
}

foreach ($ProjectDirItem in $Projects) {
    $ProjectDir = $ProjectDirItem.FullName
    $ProjectName = $ProjectDirItem.Name
    
    Write-Host "--------------------------------------------"
    Write-Host "Project: $ProjectName"
    
    Write-Host "   Verification des conditions..."

    # Définition des chemins
    $TempPath = Join-Path -Path $ProjectDir -ChildPath "temp"
    $ResultsPath = Join-Path -Path $ProjectDir -ChildPath "results"
    $StatusFile = Join-Path -Path $ProjectDir -ChildPath "status.txt"

    # 1. VÉRIFICATION DE LA STRUCTURE (Dossier temp)
    if (-not (Test-Path -Path $TempPath)) {
        Write-Host "   [X] Dossier manquant: temp/"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Ignore" -Reason "Dossier 'temp' manquant"
        continue
    }

    # 2. VÉRIFICATION DE LA STRUCTURE (Dossier results)
    if (-not (Test-Path -Path $ResultsPath)) {
        Write-Host "   [X] Dossier manquant: results/"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Ignore" -Reason "Dossier 'results' manquant"
        continue
    }

    # 3. VÉRIFICATION DU STATUT
    if (-not (Test-Path -Path $StatusFile)) {
        Write-Host "   [X] Fichier manquant: status.txt"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Ignore" -Reason "Fichier 'status.txt' manquant"
        continue
    }

    $StatusContent = Get-Content -Path $StatusFile -TotalCount 1
    if ($StatusContent -ne "FINISHED") {
        Write-Host "   [WAIT] Statut: $StatusContent (pas encore termine)"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Ignore" -Reason "Projet non termine (statut: $StatusContent)"
        continue
    }

    # 4. VÉRIFICATION DE L'ANCIENNETÉ DES RÉSULTATS (30 jours)
    $DateCutoff = (Get-Date).AddDays(-30)
    $RecentFile = Get-ChildItem -Path $ResultsPath -File -Recurse | Where-Object { $_.LastWriteTime -gt $DateCutoff } | Select-Object -First 1

    if ($null -ne $RecentFile) {
        Write-Host "   [INFO] Fichiers recents trouves dans results/ (< 30 jours)"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Ignore" -Reason "Fichiers recents dans 'results/'"
        continue
    }

    # Validation
    Write-Host "   [OK] Conditions validees"
    Write-Host "   [CLEAN] Nettoyage en cours..."

    # 5. NETTOYAGE
    try {
        # Supprime le contenu de temp
        Get-ChildItem -Path $TempPath -Recurse | Remove-Item -Recurse -Force -ErrorAction Stop
        
        Write-Host "   [V] Dossier temp/ nettoye"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Nettoye" -Reason "Conditions remplies, dossier 'temp/' nettoye"
    } catch {
        Write-Host "   [ERR] ERREUR lors du nettoyage"
        Write-Host ""
        Write-Log -ProjectName $ProjectName -Action "Erreur" -Reason "Echec du nettoyage"
    }
}

Write-Host "============================================"
$EndTime = Get-Date -Format "HH:mm:ss"
Write-Host "[$EndTime] > Fin du nettoyage"
Write-Host "============================================"

Write-Log -ProjectName "Script End" -Action "Info" -Reason "Fin du script de nettoyage"