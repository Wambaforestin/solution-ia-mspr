FROM postgres:16

# Create the init directory
WORKDIR /docker-entrypoint-initdb.d

# Copy all scripts maintaining structure
COPY scripts/ /docker-entrypoint-initdb.d/

# Make sure the main script runs first (PostgreSQL runs files alphabetically)
COPY run_database_etl.sql /docker-entrypoint-initdb.d/00_run_database_etl.sql

# Set proper permissions
RUN chmod +r /docker-entrypoint-initdb.d/*.sql
