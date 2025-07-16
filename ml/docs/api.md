# API de Prédiction COVID-19 (Canada)

## 1. Structure générale
L'API est développée avec **FastAPI**. Elle permet de prédire :
- le **nombre de nouveaux cas** quotidiens
- la **tendance épidémique** (hausse, baisse ou stable)
- ou les deux en même temps via `/predict-all`

---

## 2. Modèles IA utilisés
- `model_xgboost_covid.pkl` → prédiction du nombre de nouveaux cas (modèle XGBoost)
- `modele_tendance_covid_rf.pkl` → classification de la tendance (modèle RandomForestClassifier)

---

## 3. Endpoints disponibles

### `/canada/predict-cases` (POST)
Prédit le nombre de nouveaux cas.

### `/canada/predict-tendance` (POST)
Classifie la tendance : hausse, baisse ou stable.

### `/canada/predict-all` (POST)
Fait les deux prédictions à la fois.

### `/` (GET)
Affiche le formulaire HTML avec tous les champs.

---

## 4. Données d'entrée attendues (`/predict-all`)

```json
{
  "new_cases_lag1": 500,
  "new_cases_lag7": 600,
  "new_cases_ma7": 550,
  "growth_rate": 1.05,
  "reproduction_rate": 1.1,
  "positive_rate": 0.15,
  "icu_patients": 50,
  "hosp_patients": 200,
  "stringency_index": 70.5,
  "vaccinated_rate": 65.0,
  "boosted_rate": 25.0,
  "new_cases_7d_avg": 500,
  "new_deaths_7d_avg": 50,
  "lag_1": 500,
  "lag_2": 480,
  "lag_7": 460,
  "month": 6,
  "day_of_week": 3,
  "people_vaccinated": 15000000
}
```

---

## 5. Réponse JSON attendue

```json
{
  "prediction_nouveaux_cas": 2134.0,
  "prediction_tendance": "hausse"
}
```

---

## 6. Front-End
Un formulaire HTML (à la racine `/`) permet de sélectionner des valeurs prédéfinies et de tester facilement l'API.

---

## 7. Test API avec `curl`

```bash
curl -X POST http://localhost:8000/canada/predict-all \
-F "new_cases_lag1=500" \
-F "new_cases_lag7=600" \
-F "new_cases_ma7=550" \
-F "growth_rate=1.05" \
-F "reproduction_rate=1.1" \
-F "positive_rate=0.15" \
-F "icu_patients=50" \
-F "hosp_patients=200" \
-F "stringency_index=70" \
-F "vaccinated_rate=0.6" \
-F "boosted_rate=0.3" \
-F "new_cases_7d_avg=500" \
-F "new_deaths_7d_avg=40" \
-F "lag_1=500" \
-F "lag_2=480" \
-F "lag_7=460" \
-F "month=6" \
-F "day_of_week=3" \
-F "people_vaccinated=15000000"
```

---

## 8. Structure des modèles
Les modèles sont entraînés et exportés avec `joblib` depuis des notebooks Jupyter.
