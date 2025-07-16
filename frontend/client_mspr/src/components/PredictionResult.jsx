import React from "react";
import "./styles/Prediction.css";

export default function PredictionResult({ result }) {
  if (!result) return null;

  return (
    <div className="prediction-result">
      <h2>Résultat de la prédiction</h2>
      <p>Niveau de risque : <strong>{result.risk}</strong></p>
      <p>Probabilité de propagation : {result.probability}%</p>
      <img src="/map-prediction.png" alt="Carte de propagation prévue" className="result-map" />
    </div>
  );
}