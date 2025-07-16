# Dockerfile pour backend FastAPI
FROM python:3.10

# Crée le dossier de travail
WORKDIR /ml

# Copie les fichiers du backend
COPY . .

# Installe les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Expose le port utilisé par FastAPI
EXPOSE 8000

# Lance l'application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]