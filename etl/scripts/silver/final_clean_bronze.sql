-- Supprimer ancienne version si elle existe
DROP FUNCTION IF EXISTS silver.final_clean_bronze();
DROP TABLE IF EXISTS silver.covid_cleaned_final;

-- Créer la version finale nettoyée et complétée
CREATE OR REPLACE FUNCTION silver.final_clean_bronze()
RETURNS void AS $$
BEGIN
    /*
        ==============================================
        FONCTION : silver.final_clean_bronze()
        ==============================================
        Objectif :
        - Générer une version propre et exploitable des données COVID-19
        - Préparer un jeu de données pour l’apprentissage automatique
        - Nettoyer la couche Silver et créer la table silver.covid_cleaned_final

        Raisons des choix :
        ---------------------
        1. ❌ Les colonnes inutiles avec beaucoup de NULLs ont été supprimées
        2. ⚠️ Les colonnes importantes mais avec beaucoup de NULLs ont été conservées
           → Elles sont remplies artificiellement avec des valeurs **aléatoires réalistes**
        3. 🔍 Les colonnes utiles ou neutres sont conservées sans modification

        🎯 Nouveau : Plus aucune ligne n’est supprimée.
        ➕ Toutes les valeurs NULL restantes sont remplacées **même pour les neutres**
           → Objectif : Aucune valeur NULL dans la table finale
           → Justifié car ce projet est expérimental et non destiné à la production.
    */

    -- Création d’une nouvelle table nettoyée
    CREATE TABLE silver.covid_cleaned_final AS
    SELECT
        -- Métadonnées essentielles
        iso_code,
        continent,
        country,
        date,

        -- ✅ Colonnes utiles
        COALESCE(total_cases, ROUND((RANDOM() * 5000000)::numeric)) AS total_cases,
        COALESCE(new_cases, ROUND((RANDOM() * 100000)::numeric)) AS new_cases,
        COALESCE(total_deaths, ROUND((RANDOM() * 100000)::numeric)) AS total_deaths,
        COALESCE(new_deaths, ROUND((RANDOM() * 5000)::numeric)) AS new_deaths,
        COALESCE(total_tests, ROUND((RANDOM() * 10000000)::numeric)) AS total_tests,
        COALESCE(positive_rate, ROUND((RANDOM() * 0.3)::numeric, 2)) AS positive_rate,
        COALESCE(tests_per_case, ROUND((RANDOM() * 30)::numeric, 2)) AS tests_per_case,
        COALESCE(population, ROUND((RANDOM() * 100000000)::numeric)) AS population,
        COALESCE(median_age, ROUND((RANDOM() * 20 + 20)::numeric, 1)) AS median_age,
        COALESCE(aged_65_older, ROUND((RANDOM() * 0.25)::numeric, 2)) AS aged_65_older,
        COALESCE(aged_70_older, ROUND((RANDOM() * 0.2)::numeric, 2)) AS aged_70_older,
        COALESCE(gdp_per_capita, ROUND((RANDOM() * 50000)::numeric, 2)) AS gdp_per_capita,
        COALESCE(human_development_index, ROUND((RANDOM() * 0.5 + 0.5)::numeric, 3)) AS human_development_index,
        COALESCE(life_expectancy, ROUND((RANDOM() * 30 + 50)::numeric, 1)) AS life_expectancy,
        COALESCE(excess_mortality, ROUND((RANDOM() * 100)::numeric, 2)) AS excess_mortality,

        -- ⚠️ Colonnes utiles mais à taux NULL élevé → complétion aléatoire
        COALESCE(reproduction_rate, ROUND((RANDOM() * 0.4 + 0.8)::numeric, 2)) AS reproduction_rate,
        COALESCE(icu_patients, ROUND((RANDOM() * 50)::numeric)) AS icu_patients,
        COALESCE(hosp_patients, ROUND((RANDOM() * 100)::numeric)) AS hosp_patients,
        COALESCE(new_tests, ROUND((RANDOM() * 10000)::numeric)) AS new_tests,
        COALESCE(total_vaccinations, ROUND((RANDOM() * 1000000)::numeric)) AS total_vaccinations,
        COALESCE(people_vaccinated, ROUND((RANDOM() * 800000)::numeric)) AS people_vaccinated,
        COALESCE(people_fully_vaccinated, ROUND((RANDOM() * 700000)::numeric)) AS people_fully_vaccinated,
        COALESCE(total_boosters, ROUND((RANDOM() * 400000)::numeric)) AS total_boosters,
        COALESCE(stringency_index, ROUND((RANDOM() * 100)::numeric, 2)) AS stringency_index,

        -- 🔍 Colonnes neutres (même si NULL) → complétion réaliste
        COALESCE(hospital_beds_per_thousand, ROUND((RANDOM() * 10)::numeric, 2)) AS hospital_beds_per_thousand,
        COALESCE(extreme_poverty, ROUND((RANDOM() * 0.4)::numeric, 3)) AS extreme_poverty,
        COALESCE(new_vaccinations_smoothed, ROUND((RANDOM() * 100000)::numeric)) AS new_vaccinations_smoothed,
        COALESCE(new_vaccinations_smoothed_per_million, ROUND((RANDOM() * 3000)::numeric, 2)) AS new_vaccinations_smoothed_per_million,
        COALESCE(new_people_vaccinated_smoothed, ROUND((RANDOM() * 50000)::numeric)) AS new_people_vaccinated_smoothed,
        COALESCE(new_people_vaccinated_smoothed_per_hundred, ROUND((RANDOM() * 5)::numeric, 2)) AS new_people_vaccinated_smoothed_per_hundred,
        COALESCE(total_cases_per_million, ROUND((RANDOM() * 300000)::numeric, 2)) AS total_cases_per_million,
        COALESCE(new_cases_per_million, ROUND((RANDOM() * 5000)::numeric, 2)) AS new_cases_per_million,
        COALESCE(total_deaths_per_million, ROUND((RANDOM() * 10000)::numeric, 2)) AS total_deaths_per_million,
        COALESCE(new_deaths_per_million, ROUND((RANDOM() * 1000)::numeric, 2)) AS new_deaths_per_million

    FROM silver.covid_cleaned;

    RAISE NOTICE '✅ Table finale silver.covid_cleaned_final créée sans valeur NULL.';
END;
$$ LANGUAGE plpgsql;

-- Exécution
SELECT silver.final_clean_bronze();

-- Vérification rapide
SELECT COUNT(*) AS lignes, COUNT(*) FILTER (WHERE EXISTS (
    SELECT 1 FROM silver.covid_cleaned_final WHERE
    iso_code IS NULL OR country IS NULL OR date IS NULL
)) AS lignes_nulles
FROM silver.covid_cleaned_final;

-- checking de la nouvelle table
SELECT * FROM silver.covid_cleaned_final;
