#!/bin/bash

# Script de nettoyage conditionnel multi-dossiers
# Date: $(date)

PROJECTS_ROOT="./projects"
LOG_FOLDER="./logs"
LOG_FILE="cleanup_$(date +%Y%m%d).log"

# Créer le dossier de logs s'il n'existe pas
mkdir -p "$LOG_FOLDER"
FILE_PATH="$LOG_FOLDER/$LOG_FILE"

PRINT_LOG(){
    PROJECT_NAME=$(basename "$1")
    ACTION="$2"
    REASON="$3"
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Projet: $PROJECT_NAME ➢ Action: $ACTION | Raison: $REASON" >> "$FILE_PATH"

}


echo "============================================"
echo "  Script de nettoyage conditionnel"
echo "  Date: $(date)"
echo "============================================"
echo ""
PRINT_LOG "Script Start" "Info" "Début du script de nettoyage"

{
    echo "[$(date +%H:%M:%S)] ▶ Début du nettoyage"
    echo ""
    
    for project_dir in "$PROJECTS_ROOT"/*/; do
        project_name=$(basename "$project_dir")
        echo "────────────────────────────────────────────"
        echo "📁 Projet: $project_name"
        {
            echo "   🔍 Vérification des conditions..."

            # 1. VÉRIFICATION DE LA STRUCTURE (Dossier temp)
            if ! [ -d "${project_dir}temp" ]; then
                echo "   ❌ Dossier manquant: temp/"
                echo ""
                PRINT_LOG "$project_dir" "Ignoré" "Dossier 'temp' manquant"
                continue
            fi

            # 2. VÉRIFICATION DE LA STRUCTURE (Dossier results)
            if ! [ -d "${project_dir}results" ]; then
                echo "   ❌ Dossier manquant: results/"
                echo ""
                PRINT_LOG "$project_dir" "Ignoré" "Dossier 'results' manquant"
                continue
            fi

            # 3. VÉRIFICATION DU STATUT
            if ! [ -f "${project_dir}status.txt" ]; then
                echo "   ❌ Fichier manquant: status.txt"
                echo ""
                PRINT_LOG "$project_dir" "Ignoré" "Fichier 'status.txt' manquant"
                continue
            fi

            STATUT=$(cat "${project_dir}status.txt")
            if [ "$STATUT" != "FINISHED" ]; then
                echo "   ⏸️  Statut: $STATUT (pas encore terminé)"
                echo ""
                PRINT_LOG "$project_dir" "Ignoré" "Projet non terminé (statut: $STATUT)"
                continue
            fi

            # 4. VÉRIFICATION DE L'ANCIENNETÉ DES RÉSULTATS (30 jours)
            RECENT_FILE=$(find "${project_dir}results" -type f -mtime -30 | head -n 1)
            if ! [ -z "$RECENT_FILE" ]; then
                echo "   ℹ️  Fichiers récents trouvés dans results/ (< 30 jours)"
                echo ""
                PRINT_LOG "$project_dir" "Ignoré" "Fichiers récents dans 'results/'"
                continue
            fi

            
                
        }

        {
            echo "   ✅ Conditions validées"
            echo "   🧹 Nettoyage en cours..."
            
            # 5. NETTOYAGE
            {
                rm -rf "${project_dir}temp"/*
                echo "   ✓ Dossier temp/ nettoyé"
                echo ""
                PRINT_LOG "$project_dir" "Nettoyé" "Conditions remplies, dossier 'temp/' nettoyé"
            } || {
                echo "   ❌ ERREUR lors du nettoyage"
                echo ""
                PRINT_LOG "$project_dir" "Erreur" "Échec du nettoyage"
            }
        }
    done
    
    echo "============================================"
    echo "[$(date +%H:%M:%S)] ▶ Fin du nettoyage"
    echo "============================================"

    PRINT_LOG "Script End" "Info" "Fin du script de nettoyage"
    
}



