import sys
import os
from unittest.mock import MagicMock
import pytest
import json

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

class TestBasicEndpoints:
    """Tests des endpoints de base"""
    
    def test_root_endpoint(self):
        """Test de l'endpoint racine /"""
        response = client.get("/")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]
    
    # def test_country_endpoint(self):
    #     """Test de l'endpoint /country"""
    #     response = client.get("/country")
    #     assert response.status_code == 200
    #     data = response.json()
    #     assert "pays actuel" in data
    #     # Le pays peut être france, usa, ou suisse selon la variable d'environnement
    #     assert data["pays actuel"] in ["france", "usa", "suisse"]
    
    def test_docs_endpoint(self):
        """Test de l'endpoint /docs (Swagger)"""
        response = client.get("/docs")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]

class TestPredictionEndpoints:
    """Tests des endpoints de prédiction ML"""
    
    def test_predict_cases(self):
        """Test de prédiction des nouveaux cas"""
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
        assert "text/html" in response.headers["content-type"]
    
    def test_predict_tendance(self):
        """Test de prédiction de tendance"""
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
        assert "text/html" in response.headers["content-type"]
    
    def test_predict_all(self):
        """Test de prédiction combinée (/predict-all)"""
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
        assert "text/html" in response.headers["content-type"]

class TestJSONAPIEndpoints:
    """Tests des endpoints API JSON"""
    
    # def test_predict_all_json(self):
    #     """Test de l'endpoint JSON /api/canada/predict-all-json"""
    #     response = client.post("/api/canada/predict-all-json", 
    #         headers={"Content-Type": "application/json"},
    #         json={
    #             "new_cases_lag1": 100,
    #             "new_cases_lag7": 100,
    #             "new_cases_ma7": 100,
    #             "reproduction_rate": 1.0,
    #             "positive_rate": 0.1,
    #             "icu_patients": 20,
    #             "hosp_patients": 80,
    #             "stringency_index": 60.0,
    #             "vaccinated_rate": 50.0,
    #             "boosted_rate": 20.0,
    #             "new_cases_7d_avg": 100,
    #             "new_deaths_7d_avg": 5,
    #             "lag_1": 90,
    #             "lag_2": 80,
    #             "lag_7": 60,
    #             "month": 6,
    #             "day_of_week": 2,
    #             "people_vaccinated": 5000000
    #         })
    #     assert response.status_code == 200
    #     data = response.json()
    #     assert "prediction_nouveaux_cas" in data
    #     assert "prediction_tendance" in data
    #     assert "metadata" in data
    #     assert data["prediction_nouveaux_cas"] == 1234
    #     assert data["prediction_tendance"] == "hausse"

class TestErrorHandling:
    """Tests de gestion d'erreurs"""
    
    def test_predict_cases_missing_fields(self):
        """Test avec des champs manquants"""
        response = client.post("/canada/predict-cases", data={
            "new_cases_lag1": 100,
            # Champs manquants intentionnellement
        })
        assert response.status_code == 422  # Validation error
    
    def test_predict_tendance_invalid_data(self):
        """Test avec des données invalides"""
        response = client.post("/canada/predict-tendance", data={
            "new_cases_7d_avg": "invalid",  # String au lieu de nombre
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
        assert response.status_code == 422  # Validation error
    
    def test_invalid_endpoint(self):
        """Test d'un endpoint qui n'existe pas"""
        response = client.get("/inexistant")
        assert response.status_code == 404
    
    def test_wrong_method(self):
        """Test avec la mauvaise méthode HTTP"""
        response = client.get("/canada/predict-cases")  # GET au lieu de POST
        assert response.status_code == 405  # Method not allowed

class TestDataValidation:
    """Tests de validation des données"""
    
    def test_predict_cases_edge_values(self):
        """Test avec des valeurs extrêmes"""
        response = client.post("/canada/predict-cases", data={
            "new_cases_lag1": 0,  # Valeur minimum
            "new_cases_lag7": 999999,  # Valeur maximum
            "new_cases_ma7": 100,
            "growth_rate": 0.0,
            "reproduction_rate": 5.0,
            "positive_rate": 1.0,
            "icu_patients": 0,
            "hosp_patients": 10000,
            "stringency_index": 100.0,
            "vaccinated_rate": 100.0,
            "boosted_rate": 100.0
        })
        assert response.status_code == 200
    
    def test_predict_tendance_negative_values(self):
        """Test avec des valeurs négatives"""
        response = client.post("/canada/predict-tendance", data={
            "new_cases_7d_avg": -10,  # Valeur négative
            "new_deaths_7d_avg": 0,
            "lag_1": 90,
            "lag_2": 80,
            "lag_7": 60,
            "month": 12,  # Mois maximum
            "day_of_week": 6,  # Jour maximum
            "reproduction_rate": 0.1,
            "people_vaccinated": 0,
            "stringency_index": 0.0
        })
        assert response.status_code == 200

class TestResponseFormat:
    """Tests du format des réponses"""
    
    def test_html_response_contains_predictions(self):
        """Test que les réponses HTML contiennent les prédictions"""
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
        content = response.text
        # Vérifier que la réponse contient les prédictions mockées
        assert "1234" in content  # Prédiction de nouveaux cas
        assert "hausse" in content  # Prédiction de tendance
    
    # def test_json_response_structure(self):
    #     """Test de la structure de la réponse JSON"""
    #     response = client.post("/api/canada/predict-all-json", 
    #         headers={"Content-Type": "application/json"},
    #         json={
    #             "new_cases_lag1": 100,
    #             "new_cases_lag7": 100,
    #             "new_cases_ma7": 100,
    #             "reproduction_rate": 1.0,
    #             "positive_rate": 0.1,
    #             "icu_patients": 20,
    #             "hosp_patients": 80,
    #             "stringency_index": 60.0,
    #             "vaccinated_rate": 50.0,
    #             "boosted_rate": 20.0,
    #             "new_cases_7d_avg": 100,
    #             "new_deaths_7d_avg": 5,
    #             "lag_1": 90,
    #             "lag_2": 80,
    #             "lag_7": 60,
    #             "month": 6,
    #             "day_of_week": 2,
    #             "people_vaccinated": 5000000
    #         })
        
    #     assert response.status_code == 200
    #     data = response.json()
        
    #     # Structure attendue
    #     assert isinstance(data["prediction_nouveaux_cas"], int)
    #     assert isinstance(data["prediction_tendance"], str)
    #     assert isinstance(data["metadata"], dict)
    #     assert "timestamp" in data["metadata"]
    #     assert "model_version" in data["metadata"]

class TestMultiCountrySupport:
    """Tests du support multi-pays"""
    
    # def test_country_environment_variable(self):
    #     """Test que l'API répond selon la variable d'environnement COUNTRY"""
    #     # Ce test vérifie que l'endpoint /country fonctionne
    #     response = client.get("/country")
    #     assert response.status_code == 200
    #     data = response.json()
        
    #     # La réponse doit contenir un pays valide
    #     valid_countries = ["france", "usa", "suisse"]
    #     assert data["pays actuel"] in valid_countries
    
    def test_all_endpoints_work_regardless_of_country(self):
        """Test que tous les endpoints fonctionnent quel que soit le pays configuré"""
        # Tous les endpoints de prédiction doivent fonctionner
        # quel que soit le pays configuré via COUNTRY
        
        endpoints_to_test = [
            ("/", "get"),
            ("/country", "get"),
            ("/docs", "get")
        ]
        
        for endpoint, method in endpoints_to_test:
            if method == "get":
                response = client.get(endpoint)
            else:
                response = client.post(endpoint)
            
            assert response.status_code in [200, 405]  # 405 pour les POST sur GET endpoints

class TestDocumentation:
    """Tests de la documentation API"""
    
    def test_openapi_schema(self):
        """Test du schéma OpenAPI"""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        schema = response.json()
        assert "openapi" in schema
        assert "info" in schema
        assert "paths" in schema
    
    def test_redoc_documentation(self):
        """Test de la documentation ReDoc"""
        response = client.get("/redoc")
        assert response.status_code == 200
        assert "text/html" in response.headers["content-type"]

# Fixtures pour les tests paramétrés
@pytest.fixture
def sample_prediction_data():
    """Données d'exemple pour les tests de prédiction"""
    return {
        "new_cases_lag1": 150,
        "new_cases_lag7": 140,
        "new_cases_ma7": 145,
        "growth_rate": 1.05,
        "reproduction_rate": 1.2,
        "positive_rate": 0.15,
        "icu_patients": 25,
        "hosp_patients": 120,
        "stringency_index": 65.0,
        "vaccinated_rate": 75.0,
        "boosted_rate": 40.0,
        "new_cases_7d_avg": 145,
        "new_deaths_7d_avg": 8,
        "lag_1": 135,
        "lag_2": 125,
        "lag_7": 100,
        "month": 8,
        "day_of_week": 3,
        "people_vaccinated": 8000000
    }

# Tests de performance basiques
class TestPerformance:
    """Tests de performance basiques"""
    
    def test_response_time_under_threshold(self):
        """Test que les réponses sont rapides"""
        import time
        
        start_time = time.time()
        response = client.get("/country")
        end_time = time.time()
        
        assert response.status_code == 200
        # Réponse doit être sous 1 seconde (très généreux pour les tests)
        assert (end_time - start_time) < 1.0
    
    def test_multiple_concurrent_requests(self):
        """Test de requêtes multiples"""
        responses = []
        for i in range(5):
            response = client.get("/country")
            responses.append(response)
        
        # Toutes les réponses doivent être OK
        for response in responses:
            assert response.status_code == 200

if __name__ == "__main__":
    # Permet d'exécuter les tests directement
    pytest.main([__file__, "-v"])
