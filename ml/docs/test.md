#  Documentation des Tests – API COVID-19 (Canada)

##  Objectif

Ces tests automatisés a pour objectif de **valider les endpoints FastAPI** de l’API COVID-19 sans dépendre des modèles `.pkl` entraînés (`joblib.load(...)`).  
Étant donné que ces modèles ne doivent **pas être versionnés sur GitHub**, une méthode alternative a été mise en place via une **simulation des prédictions**.


##  Problème initial

Le fichier `app.py` charge les modèles IA directement à l'import via :

```python
model_cas = joblib.load("model/model_xgboost_covid.pkl")
```

Cela pose deux problèmes :
-  Les fichiers `.pkl` ne sont pas présents dans le dépôt
- `pytest` échoue à l’import de `app.py` à cause du `FileNotFoundError`



##  Solution utilisée : Interception de `joblib.load`

Nous avons utilisé une **stratégie de substitution (`monkeypatch`)** pour **remplacer `joblib.load`** par une fonction personnalisée **avant** d’importer `app.py`.

```python
# Substitution de joblib.load par une fonction maison
joblib.load = fake_load
```

La fonction `fake_load(path)` retourne un modèle simulé (`DummyModel`) qui contient une méthode `.predict()` renvoyant une valeur factice.

### Exemple :

```python
def fake_load(path):
    """
    Remplace joblib.load() pour les tests.
    Retourne un DummyModel simulant la méthode predict().
    """
    class DummyModel:
        def predict(self, X):
            if "tendance" in path:
                return ["hausse"]
            return [1234]
    return DummyModel()
```



##  Fichier de test utilisé : `test_app.py`

###  `test_predict_cases()`
Vérifie que l’endpoint `/canada/predict-cases` retourne un statut 200 pour une requête POST avec données valides.

###  `test_predict_tendance()`
Teste l’endpoint `/canada/predict-tendance` pour la prédiction de la tendance épidémique.

###  `test_predict_all()`
Teste `/canada/predict-all`, qui combine les deux prédictions dans une seule réponse.



## Dépendances utilisées pour les tests

```txt
fastapi
httpx
pytest
```


##  Avantages de cette méthode

- Aucun fichier `.pkl` requis
- Aucune modification de `app.py`
- Compatible GitHub Actions
- Reproductible et contrôlable


##  Conclusion

Cette stratégie permet de **tester une API FastAPI qui dépend de modèles IA** sans avoir à intégrer ou exposer ces modèles dans le dépôt public.  
Elle garantit également que les tests passent en continu dans un pipeline CI comme **GitHub Actions**, tout en respectant les bonnes pratiques.