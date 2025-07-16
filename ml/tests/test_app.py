import sys
import os
from unittest.mock import MagicMock
import pytest

# Ajoute le dossier parent (ml/) au chemin pour pouvoir importer app.py
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

# On intercepte l'import de joblib avant que app.py le fasse
import joblib

# Fonction de remplacement pour joblib.load, utilisée à la place des modèles .pkl
def fake_load(path):
    """
    Cette fonction remplace joblib.load() pendant les tests.

    Elle évite l'erreur FileNotFoundError lorsque app.py essaie de charger des modèles
    (.pkl) qui ne sont pas présents dans le dépôt GitHub (car ils ne doivent pas y être).

    En fonction du nom du fichier modèle (`path`), elle retourne un faux modèle (DummyModel)
    qui simule la méthode predict().
    - Si le nom du modèle contient 'tendance', on retourne "hausse"
    - Sinon, on retourne 1234 (valeur arbitraire)

    Cela permet de tester toute l'API sans dépendance aux modèles réels.
    """
    class DummyModel:
        def predict(self, X):
            if "tendance" in path:
                return ["hausse"]
            return [1234]
    return DummyModel()

# On remplace joblib.load globalement par fake_load
joblib.load = fake_load

# Maintenant que joblib est remplacé, on peut importer app.py sans que ça plante
import app
from fastapi.testclient import TestClient

# Client de test pour simuler les requêtes à l'API
client = TestClient(app.app)

# === TEST 1 : prédiction des cas ===
def test_predict_cases():
    response = client.post("/canada/predict-cases", data={
        "new_cases_lag1": 100,
        "new_cases_lag7": 100,
        "new_cases_ma7": 100,
        "growth_rate": 1.0,
        "reproduction_rate": 1.0,
        "positive_rate": 0.1,
        "icu_patients": 20,
        "hosp_patients": 80,
        "stringency_index": 60.0,
        "vaccinated_rate": 50.0,
        "boosted_rate": 20.0
    })
    assert response.status_code == 200

# === TEST 2 : prédiction de tendance ===
def test_predict_tendance():
    response = client.post("/canada/predict-tendance", data={
        "new_cases_7d_avg": 100,
        "new_deaths_7d_avg": 5,
        "lag_1": 90,
        "lag_2": 80,
        "lag_7": 60,
        "month": 6,
        "day_of_week": 2,
        "reproduction_rate": 1.0,
        "people_vaccinated": 5000000,
        "stringency_index": 50.0
    })
    assert response.status_code == 200

# === TEST 3 : prédiction combinée (/predict-all) ===
def test_predict_all():
    response = client.post("/canada/predict-all", data={
        "new_cases_lag1": 100,
        "new_cases_lag7": 100,
        "new_cases_ma7": 100,
        "reproduction_rate": 1.0,
        "positive_rate": 0.1,
        "icu_patients": 20,
        "hosp_patients": 80,
        "stringency_index": 60.0,
        "vaccinated_rate": 50.0,
        "boosted_rate": 20.0,
        "new_cases_7d_avg": 100,
        "new_deaths_7d_avg": 5,
        "lag_1": 90,
        "lag_2": 80,
        "lag_7": 60,
        "month": 6,
        "day_of_week": 2,
        "people_vaccinated": 5000000
    })
    assert response.status_code == 200
