-- ============================================================
-- 🗺️ Table: dim_country
-- Rôle : Contient les informations d’identification géographique du pays.
-- Pourquoi : Permet d’identifier les données par pays via une clé standardisée (iso_code) et facilite les jointures.
-- ============================================================
-- Supprimer si elle existe
DROP TABLE IF EXISTS gold.dim_country;

CREATE TABLE gold.dim_country (
    country_id SERIAL PRIMARY KEY,
    iso_code TEXT NOT NULL,
    country TEXT NOT NULL,
    continent TEXT,
    population DOUBLE PRECISION
);

-- ============================================================
-- 📅 Table: dim_date
-- Rôle : Sert à découper le temps pour les agrégations temporelles.
-- Pourquoi : Permet de faire des analyses par jour, mois ou année.
-- ============================================================
-- Supprimer si elle existe
DROP TABLE IF EXISTS gold.dim_date;

CREATE TABLE gold.dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT,
    month INT,
    day INT
);

-- ============================================================
-- 💰 Table: dim_economic
-- Rôle : Donne une vision des indicateurs socio-économiques par pays.
-- Pourquoi : Utile pour corréler la situation économique à l’impact du COVID.
-- ============================================================
-- Supprimer si elle existe
DROP TABLE IF EXISTS gold.dim_economic;

CREATE TABLE gold.dim_economic (
    economic_id SERIAL PRIMARY KEY,
    country_id INT REFERENCES gold.dim_country(country_id),
    gdp_per_capita DOUBLE PRECISION,
    human_development_index DOUBLE PRECISION,
    life_expectancy DOUBLE PRECISION,
    extreme_poverty DOUBLE PRECISION
);

-- ============================================================
-- 🏥 Table: dim_health
-- Rôle : Réunit les indicateurs de santé et infrastructure sanitaire.
-- Pourquoi : Très pertinent pour mesurer la capacité de réponse d’un pays à une pandémie.
-- ============================================================
-- Supprimer si elle existe
DROP TABLE IF EXISTS gold.dim_health;

CREATE TABLE gold.dim_health (
    health_id SERIAL PRIMARY KEY,
    country_id INT REFERENCES gold.dim_country(country_id),
    hospital_beds_per_thousand DOUBLE PRECISION,
    median_age DOUBLE PRECISION,
    aged_65_older DOUBLE PRECISION,
    aged_70_older DOUBLE PRECISION,
    reproduction_rate DOUBLE PRECISION,
    icu_patients DOUBLE PRECISION,
    hosp_patients DOUBLE PRECISION
);

-- ============================================================
-- 💉 Table: dim_vaccination
-- Rôle : Concentre toutes les données liées à la vaccination.
-- Pourquoi : Crucial pour mesurer l’effet des campagnes vaccinales sur la propagation.
-- ============================================================
-- Supprimer si elle existe
DROP TABLE IF EXISTS gold.dim_vaccination;

CREATE TABLE gold.dim_vaccination (
    vaccination_id SERIAL PRIMARY KEY,
    country_id INT REFERENCES gold.dim_country(country_id),
    total_vaccinations DOUBLE PRECISION,
    people_vaccinated DOUBLE PRECISION,
    people_fully_vaccinated DOUBLE PRECISION,
    total_boosters DOUBLE PRECISION,
    new_vaccinations_smoothed DOUBLE PRECISION,
    new_vaccinations_smoothed_per_million DOUBLE PRECISION,
    new_people_vaccinated_smoothed DOUBLE PRECISION,
    new_people_vaccinated_smoothed_per_hundred DOUBLE PRECISION
);

-- ============================================================
-- Table fact_covid_metrics
-- =============================================================
-- Supprimer l'ancienne table si elle existe
DROP TABLE IF EXISTS gold.fact_covid_metrics;

-- Créer la table avec les contraintes de suppression
CREATE TABLE gold.fact_covid_metrics (
    fact_id SERIAL PRIMARY KEY,

    -- Clés étrangères vers les dimensions
    country_id INT REFERENCES gold.dim_country(country_id) ON DELETE SET NULL,
    date_id INT REFERENCES gold.dim_date(date_id) ON DELETE SET NULL,
    economic_id INT REFERENCES gold.dim_economic(economic_id) ON DELETE SET NULL,
    health_id INT REFERENCES gold.dim_health(health_id) ON DELETE SET NULL,
    vaccination_id INT REFERENCES gold.dim_vaccination(vaccination_id) ON DELETE SET NULL,

    -- Faits mesurables
    total_cases DOUBLE PRECISION,
    new_cases DOUBLE PRECISION,
    total_deaths DOUBLE PRECISION,
    new_deaths DOUBLE PRECISION,

    total_tests DOUBLE PRECISION,
    positive_rate DOUBLE PRECISION,
    tests_per_case DOUBLE PRECISION,

    total_cases_per_million DOUBLE PRECISION,
    new_cases_per_million DOUBLE PRECISION,
    total_deaths_per_million DOUBLE PRECISION,
    new_deaths_per_million DOUBLE PRECISION,

    excess_mortality DOUBLE PRECISION
);


