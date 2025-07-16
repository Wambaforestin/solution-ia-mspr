FROM postgres:16

# Crée un dossier où on monte les scripts SQL
WORKDIR /docker-entrypoint-initdb.d

# Copie tous les scripts dans ce dossier
COPY . /docker-entrypoint-initdb.d
