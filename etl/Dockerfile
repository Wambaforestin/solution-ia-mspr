FROM postgres:16

# Create the init directory
WORKDIR /docker-entrypoint-initdb.d

# Copy all scripts from scripts directory
COPY scripts/ /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chmod +r /docker-entrypoint-initdb.d/*.sql
