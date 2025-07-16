import React from "react";
import "./styles/DataFilter.css";

export default function DataFilter({ filters, onFilterChange }) {
  return (
    <div className="data-filter">
      <input
        type="text"
        placeholder="Filtrer par pays"
        value={filters.pays}
        onChange={(e) => onFilterChange("pays", e.target.value)}
      />
      <input
        type="text"
        placeholder="Filtrer par maladie"
        value={filters.maladie}
        onChange={(e) => onFilterChange("maladie", e.target.value)}
      />
      <input
        type="date"
        placeholder="Filtrer par date"
        value={filters.date}
        onChange={(e) => onFilterChange("date", e.target.value)}
      />
    </div>
  );
}
