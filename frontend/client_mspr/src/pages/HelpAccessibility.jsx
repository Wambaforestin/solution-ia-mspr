import React from "react";
import "./styles/HelpAccessibility.css";

export default function HelpAccessibility() {
  return (
    <main className="help-access-container">
      <h1>Aide & Accessibilité</h1>

      <section>
        <h2>🧭 Navigation</h2>
        <p>
          Vous pouvez naviguer sur le site à l’aide du clavier (tabulation) ou d’un lecteur d’écran. Tous les menus sont compatibles avec les technologies d’assistance.
        </p>
      </section>

      <section>
        <h2>🎯 Objectif</h2>
        <p>
          Cette plateforme vise à rendre les données épidémiques accessibles à tous les publics, en respectant les critères WCAG 2.1 AA.
        </p>
      </section>

      <section>
        <h2>♿ Fonctionnalités d’accessibilité</h2>
        <ul>
          <li>Contraste élevé sur les textes et les éléments interactifs</li>
          <li>Zoom possible jusqu’à 200%</li>
          <li>Navigation au clavier avec repères visuels</li>
          <li>Structure claire avec titres et sections</li>
          <li>Descriptions alternatives pour les images</li>
        </ul>
      </section>

      <section>
        <h2>📘 Aide à l’utilisation</h2>
        <p>
          Utilisez les filtres pour explorer les données, et le bouton “Faire une prédiction” pour obtenir une estimation automatique de la propagation.
        </p>
        <p>
          Si vous rencontrez des problèmes techniques, contactez le support technique à <a href="mailto:support@pandemia.org">support@pandemia.org</a>.
        </p>
      </section>
    </main>
  );
}