/*
Analyse des données BRONZE Cette fonction effectue une analyse des données de la table bronze.covid_raw.
Elle vérifie les doublons, les valeurs NULL dans les colonnes critiques, et fournit des statistiques de base sur les cas et décès.
*/

-- Créer la fonction
CREATE OR REPLACE FUNCTION silver.analyse_bronze()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    total_lignes INT;
    doublons INT;
    date_min DATE;
    date_max DATE;
    moy_cases DOUBLE PRECISION;
    max_cases DOUBLE PRECISION;
    moy_deaths DOUBLE PRECISION;
    max_deaths DOUBLE PRECISION;

    -- Démographie
    moy_age DOUBLE PRECISION;
    max_age DOUBLE PRECISION;
    min_age DOUBLE PRECISION;
    aged_65 DOUBLE PRECISION;
    aged_70 DOUBLE PRECISION;
    diabete DOUBLE PRECISION;
    cardiaque DOUBLE PRECISION;
    hdi DOUBLE PRECISION;
BEGIN
    RAISE NOTICE '=================== Analyse des Données BRONZE ===================';

    -- Nombre total de lignes
    SELECT COUNT(*) INTO total_lignes FROM bronze.covid_raw;
    RAISE NOTICE '📊 Total lignes : %', total_lignes;

    -- Doublons (par iso_code, location, date)
    SELECT COUNT(*) INTO doublons
    FROM (
        SELECT iso_code, location, date
        FROM bronze.covid_raw
        GROUP BY iso_code, location, date
        HAVING COUNT(*) > 1
    ) AS duplicates;
    RAISE NOTICE '♻️ Doublons (iso_code, location, date) : %', doublons;

    -- NULL dans les colonnes clés
    RAISE NOTICE '🔎 NULLs dans les colonnes critiques :';
    RAISE NOTICE '   new_cases: %', (SELECT COUNT(*) FROM bronze.covid_raw WHERE new_cases IS NULL);
    RAISE NOTICE '   total_cases: %', (SELECT COUNT(*) FROM bronze.covid_raw WHERE total_cases IS NULL);
    RAISE NOTICE '   excess_mortality: %', (SELECT COUNT(*) FROM bronze.covid_raw WHERE excess_mortality IS NULL);
    RAISE NOTICE '   reproduction_rate: %', (SELECT COUNT(*) FROM bronze.covid_raw WHERE reproduction_rate IS NULL);
    RAISE NOTICE '   icu_patients: %', (SELECT COUNT(*) FROM bronze.covid_raw WHERE icu_patients IS NULL);
    RAISE NOTICE '   total_vaccinations: %', (SELECT COUNT(*) FROM bronze.covid_raw WHERE total_vaccinations IS NULL);

    -- Dates min et max
    SELECT MIN(date), MAX(date) INTO date_min, date_max FROM bronze.covid_raw;
    RAISE NOTICE '🗓 Dates disponibles : de % à %', date_min, date_max;

    -- Statistiques épidémiques
    SELECT
        AVG(new_cases), MAX(new_cases),
        AVG(new_deaths), MAX(new_deaths)
    INTO
        moy_cases, max_cases,
        moy_deaths, max_deaths
    FROM bronze.covid_raw
    WHERE new_cases IS NOT NULL AND new_deaths IS NOT NULL;

    RAISE NOTICE '📈 Moyenne des nouveaux cas : %', moy_cases;
    RAISE NOTICE '📈 Maximum de nouveaux cas : %', max_cases;
    RAISE NOTICE '☠️ Moyenne des nouveaux décès : %', moy_deaths;
    RAISE NOTICE '☠️ Maximum de nouveaux décès : %', max_deaths;

    -- Statistiques démographiques
    SELECT
        AVG(median_age), MAX(median_age), MIN(median_age),
        AVG(aged_65_older), AVG(aged_70_older),
        AVG(diabetes_prevalence), AVG(cardiovasc_death_rate),
        AVG(human_development_index)
    INTO
        moy_age, max_age, min_age,
        aged_65, aged_70,
        diabete, cardiaque,
        hdi
    FROM bronze.covid_raw;

    RAISE NOTICE 'Âge médian : MOY = %, MAX = %, MIN = %', moy_age, max_age, min_age;
    RAISE NOTICE 'Population 65+ : MOY = %', aged_65;
    RAISE NOTICE 'Population 70+ : MOY = %', aged_70;
    RAISE NOTICE 'Prévalence diabète : MOY = %', diabete;
    RAISE NOTICE 'Taux mortalité cardiovasculaire : MOY = %', cardiaque;
    RAISE NOTICE 'Indice HDI : MOY = %', hdi;

    RAISE NOTICE '===================================================================';
END;
$$;

-- Attribuer un propriétaire si besoin
ALTER FUNCTION silver.analyse_bronze() OWNER TO postgres;



-- Exécuter la fonction d'analyse
SELECT silver.analyse_bronze();
