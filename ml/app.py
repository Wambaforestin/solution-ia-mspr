# 🚀 FastAPI – API complète : nouveaux cas, tendance et /predict-all

from fastapi import FastAPI, Form, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, HTMLResponse
from fastapi.templating import Jinja2Templates
import joblib
import numpy as np
import os

templates = Jinja2Templates(directory=os.path.join(os.path.dirname(__file__), "templates"))

COUNTRY = os.getenv("COUNTRY", "canada") # par défaut, on utilise le Canada pour les modèles

app = FastAPI(title="API COVID-19 – Modèles IA (Canada)")

# Middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Chargement des modèles
model_cas = joblib.load("model/model_xgboost_covid.pkl")
model_tendance = joblib.load("model/modele_tendance_covid_rf.pkl")


# Templates
templates = Jinja2Templates(directory="templates")

@app.get("/country")
def get_country():
    return {"pays actuel": COUNTRY}

@app.get("/predict-by-country")
def get_predict_by_country():
    if COUNTRY == "france":
        return {"model": "Modéles pour la France", "prediction": "Nouveaux cas et tendance épidémique"}
    elif COUNTRY == "usa":
        return {"model": "Modèles pour les États-Unis", "prediction": "Nouveaux cas et tendance épidémique"}
    elif COUNTRY == "suisse":
        return {"model": "Modèles pour la Suisse", "prediction": "Nouveaux cas et tendance épidémique"}
    else:
        return {"model": "Modèles pour le Canada", "prediction": "Nouveaux cas et tendance épidémique"}

@app.get("/", response_class=HTMLResponse)
async def get_formulaire_prediction(request: Request):
    return templates.TemplateResponse(request, "template.html")

# Prédiction des nouveaux cas
@app.post("/canada/predict-cases", response_class=HTMLResponse)
async def predict_cases(
    request: Request,
    new_cases_lag1: float = Form(...),
    new_cases_lag7: float = Form(...),
    new_cases_ma7: float = Form(...),
    growth_rate: float = Form(...),
    reproduction_rate: float = Form(...),
    positive_rate: float = Form(...),
    icu_patients: float = Form(...),
    hosp_patients: float = Form(...),
    stringency_index: float = Form(...),
    vaccinated_rate: float = Form(...),
    boosted_rate: float = Form(...)
):
    X = np.array([[
        new_cases_lag1, new_cases_lag7, new_cases_ma7, growth_rate,
        reproduction_rate, positive_rate, icu_patients, hosp_patients,
        stringency_index, vaccinated_rate, boosted_rate
    ]])
    try:
        y_pred = model_cas.predict(X)[0]
        return templates.TemplateResponse(request, "template.html", {
            "prediction": round(y_pred, 0),
            "type": "cas"
        })
    except Exception as e:
        return templates.TemplateResponse(request, "template.html", {"prediction": None, "error": str(e)})

# Prédiction de tendance
@app.post("/canada/predict-tendance", response_class=HTMLResponse)
async def predict_tendance(
    request: Request,
    new_cases_7d_avg: float = Form(...),
    new_deaths_7d_avg: float = Form(...),
    lag_1: float = Form(...),
    lag_2: float = Form(...),
    lag_7: float = Form(...),
    month: int = Form(...),
    day_of_week: int = Form(...),
    reproduction_rate: float = Form(...),
    people_vaccinated: float = Form(...),
    stringency_index: float = Form(...)
):
    X = np.array([[
        new_cases_7d_avg, new_deaths_7d_avg,
        lag_1, lag_2, lag_7, month, day_of_week,
        reproduction_rate, people_vaccinated, stringency_index
    ]])
    try:
        y_pred = model_tendance.predict(X)[0]
        return templates.TemplateResponse(request, "template.html", {
            "prediction": y_pred,
            "type": "tendance"
        })
    except Exception as e:
        return templates.TemplateResponse(request, "template.html", {"prediction": None, "error": str(e)})

@app.post("/canada/predict-all")
async def predict_all(
    request: Request,
    new_cases_lag1: float = Form(...),
    new_cases_lag7: float = Form(...),
    new_cases_ma7: float = Form(...),
    reproduction_rate: float = Form(...),
    positive_rate: float = Form(...),
    icu_patients: float = Form(...),
    hosp_patients: float = Form(...),
    stringency_index: float = Form(...),
    vaccinated_rate: float = Form(...),
    boosted_rate: float = Form(...),
    new_cases_7d_avg: float = Form(...),
    new_deaths_7d_avg: float = Form(...),
    lag_1: float = Form(...),
    lag_2: float = Form(...),
    lag_7: float = Form(...),
    month: int = Form(...),
    day_of_week: int = Form(...),
    people_vaccinated: float = Form(...)
):
    try:
        # Prédiction du nombre de cas
        X_cas = np.array([[
            new_cases_lag1, new_cases_lag7, new_cases_ma7,
            reproduction_rate, positive_rate, icu_patients, hosp_patients,
            stringency_index, vaccinated_rate, boosted_rate
        ]])
        pred_cas = model_cas.predict(X_cas)[0]

        # Prédiction de la tendance
        X_tendance = np.array([[
            new_cases_7d_avg, new_deaths_7d_avg, lag_1, lag_2, lag_7,
            month, day_of_week, reproduction_rate,
            people_vaccinated, stringency_index
        ]])
        pred_tendance = model_tendance.predict(X_tendance)[0]

        return templates.TemplateResponse(request, "template.html", {
            "prediction": f"{round(pred_cas)} cas / Tendance épidémique : {pred_tendance}",
            "type": "all"
        })

    except Exception as e:
        return templates.TemplateResponse(request, "template.html", {
            "prediction": None,
            "error": str(e)
        })


# Création du second endpoint JSON, pour les appels automatisés pour la simulation de 2025 
@app.post("/api/canada/predict-all-json")
async def predict_all_json(
    new_cases_lag1: float = Form(...),
    new_cases_lag7: float = Form(...),
    new_cases_ma7: float = Form(...),
    reproduction_rate: float = Form(...),
    positive_rate: float = Form(...),
    icu_patients: float = Form(...),
    hosp_patients: float = Form(...),
    stringency_index: float = Form(...),
    vaccinated_rate: float = Form(...),
    boosted_rate: float = Form(...),
    new_cases_7d_avg: float = Form(...),
    new_deaths_7d_avg: float = Form(...),
    lag_1: float = Form(...),
    lag_2: float = Form(...),
    lag_7: float = Form(...),
    month: int = Form(...),
    day_of_week: int = Form(...),
    people_vaccinated: float = Form(...)
):
    try:
        # Préparation des données pour la prédiction des cas
        features_cas = np.array([[
            new_cases_lag1, new_cases_lag7, new_cases_ma7,
            reproduction_rate, positive_rate, icu_patients, hosp_patients,
            stringency_index, vaccinated_rate, boosted_rate
        ]])
        prediction_cas = model_cas.predict(features_cas)[0]

        # Préparation des données pour la prédiction de la tendance
        features_tendance = np.array([[
            new_cases_7d_avg, new_deaths_7d_avg, lag_1, lag_2, lag_7,
            month, day_of_week, reproduction_rate,
            people_vaccinated, stringency_index
        ]])
        prediction_tendance = model_tendance.predict(features_tendance)[0]

        return JSONResponse(content={
            "prediction_nouveaux_cas": round(float(prediction_cas), 2),
            "prediction_tendance": prediction_tendance
        })

    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})