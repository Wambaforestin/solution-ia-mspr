import React, { useState } from "react";
import PredictionForm from "../components/PredictionForm";
import PredictButton from "../components/PredictButton";
import PredictionResult from "../components/PredictionResult";
import LoadingIndicator from "../components/LoadingIndicator";
import ErrorMessage from "../components/ErrorMessage";

import './styles/Prediction.css';

export default function Predictions() {
  const [formData, setFormData] = useState({
    population: "",
    density: "",
    temperature: "",
    humidity: "",
  });

  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState("");

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handlePredict = async () => {
    setLoading(true);
    setError("");
    setResult(null);

    try {
      const fakeResponse = await new Promise((resolve) =>
        setTimeout(
          () =>
            resolve({
              risk: "Élevé",
              probability: 87,
            }),
          1500
        )
      );

      setResult(fakeResponse);
    } catch (err) {
      setError("Une erreur est survenue lors de la prédiction.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="prediction-container">
      <h1>Faire une prédiction IA</h1>
      <div className="prediction-layout">
        <div className="prediction-left">
          <PredictionForm formData={formData} onChange={handleChange} />
          <PredictButton onClick={handlePredict} loading={loading} />
        </div>
        <div className="prediction-right">
          {loading && <LoadingIndicator />}
          {result && <PredictionResult result={result} />}
          {error && <ErrorMessage message={error} />}
        </div>
      </div>
    </main>
  );
}
