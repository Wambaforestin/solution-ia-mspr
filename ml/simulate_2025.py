# Simulation prédictive pour 2025 – 3 scénarios dynamiques sur toute l'année

from datetime import datetime, timedelta
import requests
import json
from pathlib import Path
from random import gauss, uniform

# Endpoint local JSON
API_URL = "http://localhost:8000/api/canada/predict-all-json"

# Dossier de sauvegarde
output_dir = Path("results-model-2025")
output_dir.mkdir(parents=True, exist_ok=True)

# Génération des dates de l'année 2025
dates_2025 = [datetime(2025, 1, 1) + timedelta(days=i) for i in range(365)]

# Définition de 3 scénarios
scenarios = {
    "fortes_mesures": {
        "stringency_index": 90,
        "reproduction_rate": 0.8,
        "vaccinated_rate": 0.9,
        "boosted_rate": 0.7,
    },
    "mesures_moyennes": {
        "stringency_index": 60,
        "reproduction_rate": 1.2,
        "vaccinated_rate": 0.6,
        "boosted_rate": 0.4,
    },
    "relachement": {
        "stringency_index": 30,
        "reproduction_rate": 1.6,
        "vaccinated_rate": 0.3,
        "boosted_rate": 0.1,
    },
}

# Fonction de simulation dynamique
for scenario_name, params in scenarios.items():
    results = []
    base_cases = 1500
    for i, date in enumerate(dates_2025):
        # Générer des valeurs dynamiques autour d'une moyenne
        cas_jour = max(0, int(gauss(mu=base_cases, sigma=200)))
        cas_jour_7 = max(0, int(gauss(mu=cas_jour * 0.95, sigma=100)))
        moyenne_cas = int((cas_jour + cas_jour_7) / 2)

        payload = {
            "new_cases_lag1": cas_jour,
            "new_cases_lag7": cas_jour_7,
            "new_cases_ma7": moyenne_cas,
            "growth_rate": round(uniform(0.95, 1.15), 2),
            "reproduction_rate": params["reproduction_rate"],
            "positive_rate": round(uniform(0.05, 0.25), 2),
            "icu_patients": int(gauss(100, 30)),
            "hosp_patients": int(gauss(800, 150)),
            "stringency_index": params["stringency_index"],
            "vaccinated_rate": params["vaccinated_rate"],
            "boosted_rate": params["boosted_rate"],
            "new_cases_7d_avg": moyenne_cas,
            "new_deaths_7d_avg": int(gauss(20, 5)),
            "lag_1": cas_jour,
            "lag_2": max(0, int(cas_jour * 0.97)),
            "lag_7": cas_jour_7,
            "month": date.month,
            "day_of_week": date.weekday(),
            "people_vaccinated": int(gauss(15000000, 2000000))
        }

        try:
            response = requests.post(API_URL, data=payload)
            response.raise_for_status()
            prediction = response.json()
            prediction["date"] = date.strftime("%Y-%m-%d")
            results.append(prediction)
        except Exception as e:
            print(f"Erreur pour {date.strftime('%Y-%m-%d')} : {e}")
            print("Réponse brute :", response.text)

    # Sauvegarde du fichier JSON pour ce scénario
    output_path = output_dir / f"predictions_{scenario_name}.json"
    with open(output_path, "w") as f:
        json.dump(results, f, indent=2)

print("Simulations 2025 dynamiques terminées et sauvegardées.")
