// File: ErrorMessage.jsx
import React from "react";
import "./styles/Prediction.css";

export default function ErrorMessage({ message }) {
  if (!message) return null;

  return <div className="error-message">❌ {message}</div>;
}