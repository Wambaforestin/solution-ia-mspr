import { useState } from "react";
import { Link } from "react-router-dom";
import "./styles/Navbar.css";
import logo from "../assets/logo_oms.png";

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <header className="navbar">
      <nav className="navbar-container">
        {/* Logo + Titre */}
        <div className="navbar-brand">
          <img
            src={logo}
            alt="Logo OMS"
            className="navbar-logo"
            aria-hidden="true"
          />

        </div>

        {/* Bouton burger (mobile) */}
        <button
          className="navbar-toggle"
          aria-label="Ouvrir le menu"
          onClick={() => setIsOpen(!isOpen)}
        >
          ☰
        </button>

        {/* Menu de navigation */}
        <div className={`navbar-links ${isOpen ? "open" : ""}`}>
          <Link to="/" onClick={() => setIsOpen(false)}>Accueil</Link>
          <Link to="/visualisations" onClick={() => setIsOpen(false)}>Visualisations</Link>
          <Link to="/predictions" onClick={() => setIsOpen(false)}>Prédictions IA</Link>
          <Link to="/explorer" onClick={() => setIsOpen(false)}>Explorer les données</Link>
          <Link to="/aide" onClick={() => setIsOpen(false)}>Aide & Accessibilité</Link>
        </div>
      </nav>
    </header>
  );
}
