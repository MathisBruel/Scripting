# Système de Nettoyage Automatique de Projets

Un système de nettoyage intelligent et conditionnel pour la gestion automatisée des fichiers temporaires dans une architecture multi-projets.

## 🚀 Démarrage rapide

### Prérequis

- **Python 3.x** (pour la génération de la structure de test)
- **Bash** ou **Git Bash** (pour l'exécution du script de nettoyage sur Windows)

### Installation

```bash
# Cloner le dépôt (si applicable)
git clone <url-du-depot>
cd Scripting

# Aucune dépendance externe à installer
```

### Lancement

```bash
# 1. Générer la structure de projets de test
python script.py

# 2. Exécuter le nettoyage conditionnel
bash script.sh

# Sur Windows avec Git Bash
sh script.sh
```

## 📁 Structure du projet

```
Scripting/
├── script.py                  # Générateur de structure de test
├── script.sh                  # Script principal de nettoyage
├── entrées.txt                # Spécifications des entrées
├── sorties.txt                # Spécifications des sorties attendues
├── pso-code.txt               # Pseudo-code de l'algorithme
├── result.txt                 # Résultats d'exécution
├── logs/                      # Historique des nettoyages
│   └── cleanup_YYYYMMDD.log   # Logs datés
└── projects/                  # Dossiers de projets générés
    ├── projet1/
    │   ├── status.txt         # Statut du projet (FINISHED/IN_PROGRESS)
    │   ├── config/
    │   ├── results/           # Résultats à préserver
    │   └── temp/              # Fichiers temporaires à nettoyer
    ├── projet2/
    └── ...
```

## 🎯 Fonctionnalités

### Script de génération (`script.py`)
- **Création automatique** d'une arborescence de projets de test
- **Simulation de scénarios** : projets terminés, en cours, avec résultats anciens/récents
- **Manipulation des dates** : modification artificielle des dates de modification pour tester les conditions d'ancienneté

### Script de nettoyage (`script.sh`)
- **Analyse conditionnelle** : vérifie 5 conditions avant tout nettoyage
- **Sécurité** : préserve les projets en cours et les résultats récents
- **Logging complet** : traçabilité de toutes les actions dans des fichiers de log horodatés
- **Interface visuelle** : affichage clair et structuré avec emojis et formatage

## 🔍 Logique de nettoyage

Le script applique une logique de nettoyage en 5 étapes pour chaque projet :

### 1️⃣ Vérification de la structure (dossier temp)
```bash
SI dossier "temp/" n'existe pas → IGNORÉ
```

### 2️⃣ Vérification de la structure (dossier results)
```bash
SI dossier "results/" n'existe pas → IGNORÉ
```

### 3️⃣ Vérification du statut
```bash
SI fichier "status.txt" absent OU != "FINISHED" → IGNORÉ
```

### 4️⃣ Vérification de l'ancienneté (30 jours)
```bash
SI fichiers dans "results/" modifiés < 30 jours → IGNORÉ
```

### 5️⃣ Nettoyage
```bash
SI toutes les conditions validées → NETTOYAGE de temp/*
```

## 📊 Exemples de scénarios

| Projet   | Status      | Results (ancienneté) | Temp/ | Action      | Raison                           |
|----------|-------------|----------------------|-------|-------------|----------------------------------|
| projet1  | FINISHED    | > 30 jours           | ✅    | ✅ Nettoyé  | Toutes conditions remplies       |
| projet2  | IN_PROGRESS | < 30 jours           | ✅    | ⏸️ Ignoré   | Projet en cours                  |
| projet3  | (absent)    | -                    | ✅    | ⏸️ Ignoré   | Pas de fichier status.txt        |
| projet4  | (absent)    | -                    | ❌    | ⏸️ Ignoré   | Dossier temp/ manquant           |
| projet5  | FINISHED    | (absent)             | ✅    | ⏸️ Ignoré   | Dossier results/ manquant        |
| projet6  | FINISHED    | < 30 jours           | ✅    | ⏸️ Ignoré   | Résultats trop récents           |

## 📝 Logs

Chaque exécution génère un fichier de log horodaté :

```
logs/cleanup_20260119.log
```

Format des entrées :
```
[2026-01-19 14:30:45] Projet: projet1 ➢ Action: Nettoyé | Raison: Conditions remplies, dossier 'temp/' nettoyé
[2026-01-19 14:30:45] Projet: projet2 ➢ Action: Ignoré | Raison: Projet non terminé (statut: IN_PROGRESS)
```

## 🛠️ Technologies utilisées

- **Langage** : Python 3.x (génération), Bash (nettoyage)
- **Outils système** : `find`, `rm`, `mkdir`
- **Persistance** : Fichiers logs texte horodatés

## 🔧 Configuration

### Modifier le seuil d'ancienneté

Dans [script.sh](script.sh#L79) :
```bash
# Remplacer -30 par le nombre de jours souhaité
RECENT_FILE=$(find "${project_dir}results" -type f -mtime -30 | head -n 1)
```

### Personnaliser les statuts acceptés

Dans [script.sh](script.sh#L71) :
```bash
# Modifier la condition pour accepter d'autres statuts
if [ "$STATUT" != "FINISHED" ]; then
```

## ⚠️ Avertissements

- Le script **supprime définitivement** les fichiers dans `temp/`
- Toujours **tester** avec `script.py` avant d'utiliser sur des données réelles
- Vérifier les **logs** après chaque exécution
- Les dossiers `temp/` sont **vidés mais conservés**

## 👤 Auteurs

**Mathis Bruel** - Étudiant

**Sebastien Letor** - Étudiant

**Antoine Simon** - Étudiant

---

**Projet réalisé dans le cadre d'études supérieures.**
