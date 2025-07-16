import React from "react";
import "./styles/Prediction.css";

export default function PredictButton({ onClick, loading }) {
  return (
    <button
      className="predict-button"
      onClick={onClick}
      disabled={loading}
    >
      {loading ? "Analyse en cours..." : "Lancer la prédiction"}
    </button>
  );
}