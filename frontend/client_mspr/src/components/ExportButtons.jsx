import React from "react";
import "./styles/DataFilter.css";

export default function ExportButtons({ data }) {
  const handleExport = (format) => {
    if (format === "csv") {
      const csv = data.map((row) => Object.values(row).join(",")).join("\n");
      const blob = new Blob([csv], { type: "text/csv" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "donnees.csv";
      a.click();
    }
    // For PDF, use a library like jsPDF
  };

  return (
    <div className="export-buttons">
      <button onClick={() => handleExport("csv")}>Exporter CSV</button>
    </div>
  );
}
