// File: PredictionForm.jsx
import React from "react";
import "./styles/Prediction.css";

export default function PredictionForm({ formData, onChange }) {
  return (
    <form className="prediction-form">
      <div className="form-group">
        <label>Population</label>
        <input
          type="number"
          name="population"
          value={formData.population}
          onChange={onChange}
          required
        />
      </div>

      <div className="form-group">
        <label>Densité de population (hab/km²)</label>
        <input
          type="number"
          name="density"
          value={formData.density}
          onChange={onChange}
        />
      </div>

      <div className="form-group">
        <label>Température moyenne (°C)</label>
        <input
          type="number"
          name="temperature"
          value={formData.temperature}
          onChange={onChange}
        />
      </div>

      <div className="form-group">
        <label>Humidité (%)</label>
        <input
          type="number"
          name="humidity"
          value={formData.humidity}
          onChange={onChange}
        />
      </div>
    </form>
  );
}
