import React from "react";
import "./styles/Footer.css";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer-container">
        <p>&copy; {new Date().getFullYear()} Organisation Mondiale de la Santé (OMS)</p>
        <nav className="footer-links">
          <a href="/aide">Aide & Accessibilité</a>
          <a href="/mentions">Mentions légales</a>
          <a href="https://www.who.int/" target="_blank" rel="noopener noreferrer">OMS.org</a>
        </nav>
      </div>
    </footer>
  );
}
