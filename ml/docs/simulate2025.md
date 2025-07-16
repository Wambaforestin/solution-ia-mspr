# Simulation prédictive pour l'année 2025

## Objectif
Ce script permet de générer des prédictions simulées pour chaque jour de l'année 2025 à l'aide de notre API `/api/canada/predict-all-json`. Il utilise 3 scénarios de politiques sanitaires pour observer l'évolution des cas COVID-19 et de la tendance.


## Fonctionnement du script
Le script fait les actions suivantes :
1. Crée une liste des 365 jours de l'année 2025
2. Définit 3 scénarios préétablis :
   - `fortes_mesures`
   - `mesures_moyennes`
   - `relachement`
3. Pour chaque jour et chaque scénario :
   - Génère des données dynamiques (cas, hospitalisations, taux, etc.)
   - Envoie les données à l'API FastAPI
   - Récupère et stocke la prédiction (cas + tendance)
4. Sauvegarde les résultats sous forme de fichier JSON par scénario


## Exemple de structure JSON générée
```json
{
  "date": "2025-01-01",
  "prediction_nouveaux_cas": 2142,
  "prediction_tendance": "hausse"
}
```

## Appel à l'API
Le script envoie les données à :
```
POST http://localhost:8000/api/canada/predict-all-json
Content-Type: application/x-www-form-urlencoded
```


## 🔍 Utilisation dans le projet
Ces fichiers JSON pourront être exploités dans le **frontend (React.js / D3.js)** pour afficher :
- l'évolution des cas journaliers simulés
- la tendance sanitaire dans chaque scénario

Ceci permet une **analyse comparative visuelle** des politiques publiques simulées et leurs impacts possibles sur une année complète.
