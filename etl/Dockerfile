FROM postgres:16

# Create the init directory
WORKDIR /docker-entrypoint-initdb.d

# Copy the main script first (keeps original name)
COPY 00_database_etl.sql /docker-entrypoint-initdb.d/

# Copy all other scripts
COPY scripts/ /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod +r /docker-entrypoint-initdb.d/*.sql
