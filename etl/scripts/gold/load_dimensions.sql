-- Supprimer la fonction si elle existe
DROP FUNCTION IF EXISTS gold.load_dimensions();

-- Créer la fonction de chargement des dimensions
CREATE OR REPLACE FUNCTION gold.load_dimensions()
RETURNS void AS $$
BEGIN
    -- 1. Remplissage de dim_country
    INSERT INTO gold.dim_country (iso_code, country, continent, population)
    SELECT DISTINCT
        iso_code,
        country,
        continent,
        population
    FROM silver.covid_cleaned_final;

    -- 2. Remplissage de dim_date
    INSERT INTO gold.dim_date (full_date, year, month, day)
    SELECT DISTINCT
        date AS full_date,
        EXTRACT(YEAR FROM date)::INT,
        EXTRACT(MONTH FROM date)::INT,
        EXTRACT(DAY FROM date)::INT
    FROM silver.covid_cleaned_final;

    -- 3. Remplissage de dim_economic
    INSERT INTO gold.dim_economic (country_id, gdp_per_capita, human_development_index, life_expectancy, extreme_poverty)
    SELECT DISTINCT
        c.country_id,
        s.gdp_per_capita,
        s.human_development_index,
        s.life_expectancy,
        s.extreme_poverty
    FROM silver.covid_cleaned_final s
    JOIN gold.dim_country c ON c.iso_code = s.iso_code;

    -- 4. Remplissage de dim_health
    INSERT INTO gold.dim_health (
        country_id, hospital_beds_per_thousand, median_age,
        aged_65_older, aged_70_older, reproduction_rate,
        icu_patients, hosp_patients
    )
    SELECT DISTINCT
        c.country_id,
        s.hospital_beds_per_thousand,
        s.median_age,
        s.aged_65_older,
        s.aged_70_older,
        s.reproduction_rate,
        s.icu_patients,
        s.hosp_patients
    FROM silver.covid_cleaned_final s
    JOIN gold.dim_country c ON c.iso_code = s.iso_code;

    -- 5. Remplissage de dim_vaccination
    INSERT INTO gold.dim_vaccination (
        country_id, total_vaccinations, people_vaccinated,
        people_fully_vaccinated, total_boosters,
        new_vaccinations_smoothed, new_vaccinations_smoothed_per_million,
        new_people_vaccinated_smoothed, new_people_vaccinated_smoothed_per_hundred
    )
    SELECT DISTINCT
        c.country_id,
        s.total_vaccinations,
        s.people_vaccinated,
        s.people_fully_vaccinated,
        s.total_boosters,
        s.new_vaccinations_smoothed,
        s.new_vaccinations_smoothed_per_million,
        s.new_people_vaccinated_smoothed,
        s.new_people_vaccinated_smoothed_per_hundred
    FROM silver.covid_cleaned_final s
    JOIN gold.dim_country c ON c.iso_code = s.iso_code;

    RAISE NOTICE '✅ Chargement des dimensions terminé avec succès (2025-06-09).';
END;
$$ LANGUAGE plpgsql;

-- Exécuter la fonction
SELECT gold.load_dimensions();
