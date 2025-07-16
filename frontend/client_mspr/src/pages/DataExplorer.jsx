import React, { useState, useEffect } from "react";
import DataTable from "../components/DataTable";
import DataFilter from "../components/DataFilter";
import ExportButtons from "../components/ExportButtons";
import "./styles/DataExplorer.css";

export default function DataExplorer() {
    const [data, setData] = useState([]);
    const [filteredData, setFilteredData] = useState([]);
    const [filters, setFilters] = useState({ pays: "", maladie: "", date: "" });

    const [currentPage, setCurrentPage] = useState(1);
    const rowsPerPage = 5;

    const handlePageChange = (newPage) => {
        setCurrentPage(newPage);
    };


    useEffect(() => {
        // Simulate API data fetch
        const fetchData = async () => {
            const response = await fetch("../../donnees_fake.json");
            const jsonData = await response.json();
            setData(jsonData);
            setFilteredData(jsonData);
        };
        fetchData();
    }, []);

    const handleFilterChange = (name, value) => {
        const updatedFilters = { ...filters, [name]: value };
        setFilters(updatedFilters);

        const filtered = data.filter((item) => {
            return (
                (!updatedFilters.pays || item.pays.includes(updatedFilters.pays)) &&
                (!updatedFilters.maladie || item.maladie.includes(updatedFilters.maladie)) &&
                (!updatedFilters.date || item.date.includes(updatedFilters.date))
            );
        });

        setFilteredData(filtered);
        setCurrentPage(1);
    };

    return (
        <div className="data-explorer-container">
            <h1>Explorer les données</h1>
            <DataFilter filters={filters} onFilterChange={handleFilterChange} />
            <ExportButtons data={filteredData} />
            <DataTable
                data={filteredData}
                currentPage={currentPage}
                rowsPerPage={rowsPerPage}
                onPageChange={handlePageChange}
            />

        </div>
    );
}
