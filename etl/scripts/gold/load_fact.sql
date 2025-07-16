-- Supprimer ancienne version si elle existe
DROP FUNCTION IF EXISTS gold.load_fact();

-- Créer la fonction de chargement des faits
CREATE OR REPLACE FUNCTION gold.load_fact()
RETURNS void AS $$
BEGIN
    /*
        ==============================================
        FONCTION : gold.load_fact()
        ==============================================
        Objectif :
        - Mapper chaque ligne de silver.covid_cleaned_final aux dimensions créées
        - Insérer les métriques principales dans la table de faits gold.fact_covid_metrics

        Contraintes :
        - Utilise des jointures sur iso_code + country + date pour retrouver les IDs
        - Requiert que toutes les dimensions aient été chargées avant appel
    */

    INSERT INTO gold.fact_covid_metrics (
        country_id,
        date_id,
        economic_id,
        health_id,
        vaccination_id,

        total_cases,
        new_cases,
        total_deaths,
        new_deaths,

        total_tests,
        positive_rate,
        tests_per_case,

        total_cases_per_million,
        new_cases_per_million,
        total_deaths_per_million,
        new_deaths_per_million,

        excess_mortality
    )
    SELECT
        dc.country_id,
        dd.date_id,
        de.economic_id,
        dh.health_id,
        dv.vaccination_id,

        s.total_cases,
        s.new_cases,
        s.total_deaths,
        s.new_deaths,

        s.total_tests,
        s.positive_rate,
        s.tests_per_case,

        s.total_cases_per_million,
        s.new_cases_per_million,
        s.total_deaths_per_million,
        s.new_deaths_per_million,

        s.excess_mortality

    FROM silver.covid_cleaned_final s
    JOIN gold.dim_country dc ON s.country = dc.country AND s.iso_code = dc.iso_code
    JOIN gold.dim_date dd ON s.date = dd.full_date
    JOIN gold.dim_economic de ON dc.country_id = de.country_id
    JOIN gold.dim_health dh ON dc.country_id = dh.country_id
    JOIN gold.dim_vaccination dv ON dc.country_id = dv.country_id;

    RAISE NOTICE '✅ Table de faits gold.fact_covid_metrics remplie avec succès.';
END;
$$ LANGUAGE plpgsql;

-- Exécution de la fonction pour charger les faits
SELECT gold.load_fact();