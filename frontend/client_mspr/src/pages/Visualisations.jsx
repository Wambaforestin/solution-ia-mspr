import React, { useEffect, useState } from "react";
import "./styles/visualisation.css";
import {
  ResponsiveContainer,
  Tooltip,
  Legend,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  BarChart,
  Bar
} from "recharts";

const Prediction = () => {
  const [scenario, setScenario] = useState("fortes_mesures");
  const [filtered, setFiltered] = useState([]);
  const [trendSummary, setTrendSummary] = useState([]);

  useEffect(() => {
    fetch(`/results-model-2025/predictions_${scenario}.json`)
      .then((res) => res.json())
      .then((json) => {
        const filteredData = json.filter((entry) => {
          const day = parseInt(entry.date.split("-")[2]);
          return day === 1 || day >= 28;
        });
        setFiltered(filteredData);

        const grouped = json.reduce((acc, item) => {
          acc[item.prediction_tendance] = (acc[item.prediction_tendance] || 0) + 1;
          return acc;
        }, {});
        setTrendSummary(Object.entries(grouped).map(([k, v]) => ({ name: k, value: v })));
      });
  }, [scenario]);

  const trendColors = {
    hausse: "#e74c3c",
    baisse: "#2ecc71",
    stable: "#f1c40f",
  };

  return (
    <div className="prediction-dashboard">
      <h1>Dashboard – Prédiction COVID-19 (2025)</h1>

      <div style={{ marginBottom: "2rem", textAlign: "center" }}>
        <label htmlFor="scenario-select" style={{ fontWeight: "bold", marginRight: "1rem" }}>Scénario :</label>
        <select
          id="scenario-select"
          value={scenario}
          onChange={(e) => setScenario(e.target.value)}
        >
          <option value="fortes_mesures">Fortes mesures</option>
          <option value="mesures_moyennes">Mesures moyennes</option>
          <option value="relachement">Relâchement</option>
        </select>
      </div>

      <div className="row">
        <div className="card-graph">
          <h2>Nouveaux cas – début & fin de mois</h2>
          <ResponsiveContainer width="100%" height={250}>
            <LineChart data={filtered} margin={{ top: 20, right: 30, left: 0, bottom: 50 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" angle={-45} textAnchor="end" height={60} />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="prediction_nouveaux_cas" stroke="#007bff" name="Nouveaux cas" />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="card-graph">
          <h2>Tendance par mois (début/fin)</h2>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={filtered.map(entry => ({
              ...entry,
              tendance_num: entry.prediction_tendance === 'hausse' ? 3 : entry.prediction_tendance === 'baisse' ? 1 : 2
            }))}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" angle={-45} textAnchor="end" height={60} />
              <YAxis ticks={[1, 2, 3]} domain={[0, 4]} allowDecimals={false} />
              <Tooltip formatter={(value) => {
                if (value === 3) return "Hausse";
                if (value === 2) return "Stable";
                if (value === 1) return "Baisse";
                return value;
              }} />
              <Legend />
              <Bar dataKey="tendance_num" name="Tendance">
                {filtered.map((entry, index) => (
                  <Cell key={`bar-${index}`} fill={trendColors[entry.prediction_tendance]} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="card-graph">
          <h2>Répartition globale des tendances</h2>
          <ResponsiveContainer width="100%" height={250}>
            <PieChart>
              <Pie
                data={trendSummary}
                dataKey="value"
                nameKey="name"
                cx="50%"
                cy="50%"
                outerRadius={90}
                label
              >
                {trendSummary.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={trendColors[entry.name]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend verticalAlign="bottom" />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

export default Prediction;