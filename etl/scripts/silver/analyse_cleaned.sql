-- Supprimer la fonction si elle existe déjà
DROP FUNCTION IF EXISTS silver.analyse_cleaned();

-- Créer une nouvelle fonction pour analyser les colonnes de la table silver.covid_cleaned
CREATE OR REPLACE FUNCTION silver.analyse_cleaned()
RETURNS TABLE (
    col_name TEXT,             -- Nom de la colonne
    null_count BIGINT,         -- Nombre de valeurs NULL dans cette colonne
    null_percent NUMERIC(5,2), -- Pourcentage de valeurs NULL
    decision TEXT              -- Décision (utile, neutre, à exclure)
)
LANGUAGE plpgsql AS $$
DECLARE
    col TEXT;     -- Nom temporaire de la colonne pendant la boucle
    total BIGINT; -- Nombre total de lignes dans la table
BEGIN
    -- Récupérer le nombre total de lignes dans la table
    EXECUTE 'SELECT COUNT(*) FROM silver.covid_cleaned' INTO total;

    -- Boucle sur toutes les colonnes de la table
    FOR col IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'silver' AND table_name = 'covid_cleaned'
    LOOP
        -- Pour chaque colonne, on génère dynamiquement une requête pour analyser :
        -- 1. Le nombre de NULL
        -- 2. Le pourcentage de NULL
        -- 3. Une décision basée sur la colonne et le taux de null
        RETURN QUERY EXECUTE format(
            $f$
            SELECT
                %L AS col_name, -- Nom de la colonne en texte
                COUNT(*) FILTER (WHERE %I IS NULL) AS null_count, -- Nombre de NULL
                ROUND(100.0 * COUNT(*) FILTER (WHERE %I IS NULL) / %s, 2) AS null_percent, -- Taux de NULL
                CASE
                    -- Cas 1 : Colonnes considérées utiles pour le modèle
                    WHEN %L IN (
                        'total_cases','new_cases','total_deaths','new_deaths',
                        'reproduction_rate','icu_patients','hosp_patients',
                        'total_tests','new_tests','positive_rate','tests_per_case',
                        'total_vaccinations','people_vaccinated','people_fully_vaccinated',
                        'total_boosters','population','median_age','aged_65_older',
                        'aged_70_older','gdp_per_capita','human_development_index',
                        'stringency_index','life_expectancy','excess_mortality'
                    )
                    THEN CASE
                        -- Si le taux de NULL est acceptable, on garde
                        WHEN COUNT(*) FILTER (WHERE %I IS NULL) * 100.0 / %s <= 40 THEN '✅ utile'
                        -- Sinon, on note qu'elle est utile mais problématique
                        ELSE '⚠️ utile mais taux NULL élevé'
                    END
                    ELSE
                    -- Cas 2 : Autres colonnes (pas directement utiles)
                    CASE
                        -- Trop de NULL → à exclure
                        WHEN COUNT(*) FILTER (WHERE %I IS NULL) * 100.0 / %s > 60 THEN '❌ à exclure'
                        -- Sinon → neutre, à analyser manuellement
                        ELSE '🔍 neutre'
                    END
                END AS decision
            FROM silver.covid_cleaned
            $f$,
            col, col, col, total, col, col, total, col, total -- Paramètres injectés dans la requête
        );
    END LOOP;
END;
$$;


-- UUtilisation de la fonction pour afficher les résultats
SELECT * FROM silver.analyse_cleaned()
ORDER BY null_percent DESC;