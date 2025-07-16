import React from "react";
import "./styles/Home.css";
import { Link } from "react-router-dom";

export default function Accueil() {
    return (
        <main className="home-container">
            <section className="home-intro">
                <h1>Bienvenue sur l’interface de prévision des pandémies de l’OMS</h1>
                <p>
                    Cette plateforme vous permet de visualiser les données historiques et de simuler
                    l’évolution de futures pandémies grâce à l’intelligence artificielle.
                </p>

                <Link to="/predictions" onClick={() => setIsOpen(false)}>
                    <button className="predict-button">
                        Faire une prédiction
                    </button>
                </Link>
            </section>

            <section className="home-kpis">
                <div className="kpi-card">
                    <h2>1.3</h2>
                    <p>Taux de transmission global actuel</p>
                </div>
                <div className="kpi-card">
                    <h2>85</h2>
                    <p>Pays affectés</p>
                </div>
                <div className="kpi-card">
                    <img src="/trend.png" alt="Courbe de tendance" className="trend-img" />
                    <p>Courbe de tendance</p>
                </div>
            </section>
        </main>
    );
}
