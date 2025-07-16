# Documentation Docker et Docker Compose - Projet MSPR2

## Objectif

Ce document décrit comment conteneuriser et déployer localement les différents composants du projet MSPR2 grâce à Docker et Docker Compose.

## 🔍 Structure du projet

```
MSPR2/
├── etl/                        # Contient les scripts SQL pour PostgreSQL
├── ml/                         # Contient app.py (FastAPI)
├── frontend/client_mspr/       # Contient l'application front-end (React/Vite)
├── simulation_deploiement/     # Contient le script PowerShell de simulation
├── docker-compose.yml          # Fichier central de déploiement
```

## Services conteneurisés

### 1. backend multi-pays (FastAPI)

* Localisé dans : `ml/`
* Fichier d’entrée : `app.py`
* Ports exposés : `8001` (France), `8002` (USA), `8003` (Suisse)
* Variable d'environnement utilisée : `COUNTRY`
* Exemple de logique dans `app.py` :

```python
import os
COUNTRY = os.getenv("COUNTRY", "ca")
```

Endpoints simulés :

* `/country` → renvoie le pays actif
* `/predict-by-country` → réponse simulée selon `COUNTRY`

### 2. etl\_db (PostgreSQL avec scripts SQL)

* Localisé dans : `etl/`
* Image officielle : `postgres:16`
* Port : `5432`
* Les fichiers `.sql` sont automatiquement exécutés au démarrage

### 3. frontend (React ou Vite)

* Localisé dans : `frontend/client_mspr/`
* Port : `3000`

 Script de simulation de déploiement local (PowerShell)

Le fichier `simulate-ftp-deploy.ps1` permet de simuler un déploiement local pour plusieurs pays dans des dossiers comme `C:\DeploySimulation\fr`, `C:\DeploySimulation\us`, etc.

### 📄 `simulation_deploiement/simulate-ftp-deploy.ps1`

```powershell
param([string[]]$Countries = @("fr", "us", "ch"))

foreach ($Country in $Countries) {
    $Target = "C:\\DeploySimulation\\$Country"
    Write-Host "🚀 Simulation du déploiement pour le pays: $Country → $Target"

    if (Test-Path $Target) {
        Remove-Item $Target -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Target | Out-Null

    # Copie les fichiers simulés (adapter le chemin si besoin)
    Copy-Item -Path dist\* -Destination $Target -Recurse -Force

    Write-Host "✅ Déploiement simulé terminé pour $Country"
}
```

## docker-compose.yml - version multi-pays

```yaml
version: '3.9'

services:
  backend_fr:
    build:
      context: ./ml
    container_name: backend_fr
    ports:
      - "8001:8000"
    environment:
      - COUNTRY=fr
    volumes:
      - ./ml:/ml
    working_dir: /ml
    command: ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

  backend_us:
    build:
      context: ./ml
    container_name: backend_us
    ports:
      - "8002:8000"
    environment:
      - COUNTRY=us
    volumes:
      - ./ml:/ml
    working_dir: /ml
    command: ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

  backend_ch:
    build:
      context: ./ml
    container_name: backend_ch
    ports:
      - "8003:8000"
    environment:
      - COUNTRY=ch
    volumes:
      - ./ml:/ml
    working_dir: /ml
    command: ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

  etl_db:
    image: postgres:16
    container_name: etl_db
    environment:
      POSTGRES_DB: etldb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - ./etl:/docker-entrypoint-initdb.d

  frontend:
    build:
      context: ./frontend/client_mspr
    container_name: frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend/client_mspr:/app
    working_dir: /app
    command: ["npm", "run", "dev"]
```

## Commandes utiles

### 1. Construire les images

```bash
docker-compose build
```

### 2. Lancer tous les services

```bash
docker-compose up
```

### 3. Arrêter tous les services

```bash
docker-compose down
```

### 4. Accéder aux conteneurs

```bash
docker exec -it backend_fr bash
```

## Accès aux applications

* 🇫🇷 Backend France : [http://localhost:8001/country](http://localhost:8001/country)
* 🇺🇸 Backend USA : [http://localhost:8002/country](http://localhost:8002/country)
* 🇨🇭 Backend Suisse : [http://localhost:8003/country](http://localhost:8003/country)
* Frontend : [http://localhost:3000](http://localhost:3000)
* PostgreSQL : port `5432`, utilisateur `user`, mot de passe `password`, base `etldb`

## Accès à la base de données PostgreSQL

```bash

psql -h localhost -p 5432 -U user -d etldb

note : psql doute être installé sur votre machine pour exécuter cette commande

```
