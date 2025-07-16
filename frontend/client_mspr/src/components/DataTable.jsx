import React from "react";
import "./styles/DataFilter.css";


export default function DataTable({ data, currentPage, rowsPerPage, onPageChange }) {
  const totalPages = Math.ceil(data.length / rowsPerPage);
  const start = (currentPage - 1) * rowsPerPage;
  const paginatedData = data.slice(start, start + rowsPerPage);

  if (data.length === 0) return <p>Aucune donnée à afficher.</p>;

  const headers = Object.keys(data[0]);

  return (
    <div className="data-table-wrapper">
      <table className="data-table">
        <thead>
          <tr>
            {headers.map((header) => (
              <th key={header}>{header.toUpperCase()}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {paginatedData.map((row, index) => (
            <tr key={index}>
              {headers.map((key) => (
                <td key={key}>{row[key]}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>

      <div className="pagination-controls">
        <button onClick={() => onPageChange(currentPage - 1)} disabled={currentPage === 1}>
          ◀ Précédent
        </button>
        <span>Page {currentPage} / {totalPages}</span>
        <button onClick={() => onPageChange(currentPage + 1)} disabled={currentPage === totalPages}>
          Suivant ▶
        </button>
      </div>
    </div>
  );
}

