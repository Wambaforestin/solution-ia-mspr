ALTER TABLE silver.covid_cleaned
RENAME COLUMN location TO country;

DROP FUNCTION IF EXISTS silver.clean_bronze();

CREATE OR REPLACE FUNCTION silver.clean_bronze()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Nettoyage de la table silver.covid_cleaned...';
    TRUNCATE TABLE silver.covid_cleaned;

    RAISE NOTICE 'Insertion des données nettoyées depuis bronze.covid_raw...';
    INSERT INTO silver.covid_cleaned (
        iso_code, continent, country, date,
        total_cases, new_cases, new_cases_smoothed,
        total_deaths, new_deaths, new_deaths_smoothed,
        total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million,
        total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million,
        reproduction_rate, icu_patients, icu_patients_per_million,
        hosp_patients, hosp_patients_per_million,
        weekly_icu_admissions, weekly_icu_admissions_per_million,
        weekly_hosp_admissions, weekly_hosp_admissions_per_million,
        total_tests, new_tests, total_tests_per_thousand,
        new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand,
        positive_rate, tests_per_case, tests_units,
        total_vaccinations, people_vaccinated, people_fully_vaccinated,
        total_boosters, new_vaccinations, new_vaccinations_smoothed,
        total_vaccinations_per_hundred, people_vaccinated_per_hundred,
        people_fully_vaccinated_per_hundred, total_boosters_per_hundred,
        new_vaccinations_smoothed_per_million, new_people_vaccinated_smoothed,
        new_people_vaccinated_smoothed_per_hundred,
        stringency_index, population_density, median_age, aged_65_older,
        aged_70_older, gdp_per_capita, extreme_poverty,
        cardiovasc_death_rate, diabetes_prevalence,
        female_smokers, male_smokers, handwashing_facilities,
        hospital_beds_per_thousand, life_expectancy,
        human_development_index, population,
        excess_mortality_cumulative_absolute, excess_mortality_cumulative,
        excess_mortality, excess_mortality_cumulative_per_million
    )
    SELECT
        iso_code, continent, location AS country, date,
        total_cases, new_cases, new_cases_smoothed,
        total_deaths, new_deaths, new_deaths_smoothed,
        total_cases_per_million, new_cases_per_million, new_cases_smoothed_per_million,
        total_deaths_per_million, new_deaths_per_million, new_deaths_smoothed_per_million,
        reproduction_rate, icu_patients, icu_patients_per_million,
        hosp_patients, hosp_patients_per_million,
        weekly_icu_admissions, weekly_icu_admissions_per_million,
        weekly_hosp_admissions, weekly_hosp_admissions_per_million,
        total_tests, new_tests, total_tests_per_thousand,
        new_tests_per_thousand, new_tests_smoothed, new_tests_smoothed_per_thousand,
        positive_rate, tests_per_case, tests_units,
        total_vaccinations, people_vaccinated, people_fully_vaccinated,
        total_boosters, new_vaccinations, new_vaccinations_smoothed,
        total_vaccinations_per_hundred, people_vaccinated_per_hundred,
        people_fully_vaccinated_per_hundred, total_boosters_per_hundred,
        new_vaccinations_smoothed_per_million, new_people_vaccinated_smoothed,
        new_people_vaccinated_smoothed_per_hundred,
        stringency_index, population_density, median_age, aged_65_older,
        aged_70_older, gdp_per_capita, extreme_poverty,
        cardiovasc_death_rate, diabetes_prevalence,
        female_smokers, male_smokers, handwashing_facilities,
        hospital_beds_per_thousand, life_expectancy,
        human_development_index, population,
        excess_mortality_cumulative_absolute, excess_mortality_cumulative,
        excess_mortality, excess_mortality_cumulative_per_million
    FROM bronze.covid_raw
    WHERE
        iso_code IS NOT NULL
        AND location IS NOT NULL
        AND date IS NOT NULL
        AND iso_code NOT LIKE 'OWID_%'
        AND continent IS NOT NULL
        AND (
            total_cases IS NOT NULL OR
            new_cases IS NOT NULL OR
            total_deaths IS NOT NULL OR
            reproduction_rate IS NOT NULL OR
            total_tests IS NOT NULL OR
            total_vaccinations IS NOT NULL OR
            excess_mortality IS NOT NULL
        )
        AND NOT (
            COALESCE(total_cases, 0) = 0 AND
            COALESCE(new_cases, 0) = 0 AND
            COALESCE(total_deaths, 0) = 0
        )
        AND (iso_code, location, date) IN (
            SELECT iso_code, location, date
            FROM (
                SELECT iso_code, location, date,
                       ROW_NUMBER() OVER (PARTITION BY iso_code, location, date ORDER BY date) AS rn
                FROM bronze.covid_raw
            ) AS t
            WHERE t.rn = 1
        );

    RAISE NOTICE 'Données nettoyées insérées avec succès dans silver.covid_cleaned.';
END;
$$;

-- Changer le propriétaire de la fonction pour l'utilisateur postgres
ALTER FUNCTION silver.clean_bronze() OWNER TO postgres;

-- utiliser la fonction pour nettoyer les données
SELECT silver.clean_bronze();

