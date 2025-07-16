/*
Création de la base de données et des schemas nécessaires pour l'ETL

NB : Ce script supprime la base de données existante et la recrée.
Assurez-vous de sauvegarder vos données avant de l'exécuter.
*/

-- 1. Connecté à PostgreSQL, on crée la base (à exécuter hors de la base actuelle si nécessaire)
DROP DATABASE IF EXISTS model_covid19_data;
CREATE DATABASE model_covid19_data;

-- 2. Connexion à la base nouvellement créée (à faire depuis ton client PostgreSQL ou psql)
\c model_covid19_data

-- 3. Création des schémas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
