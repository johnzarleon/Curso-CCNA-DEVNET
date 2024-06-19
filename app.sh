#!/bin/bash

# Variables
BASE_DIR="/home/devasc/labs/devnet-src/Curso-CCNA-DEVNET"
TEMP_DIR="$BASE_DIR/temp_website"
APP_FILE="app.py"
DOCKER_IMAGE_NAME="my_flask_app"
DOCKER_CONTAINER_NAME="flask_app_container"
DOCKER_PORT=7075

# 1. Crear directorios temporales para almacenar los archivos del sitio web. Utilizará el puerto 7075 para el sitio web.
echo "Creating temporary directories..."
mkdir -p $TEMP_DIR

# 2. Copiar los directorios del sitio web y archivo .py en el directorio temporal.
echo "Copying website files and Python script to temporary directory..."
cp $BASE_DIR/$APP_FILE $TEMP_DIR

# 3. Crear el Dockerfile.
echo "Creating Dockerfile..."
cat <<EOF > $TEMP_DIR/Dockerfile
# Usar la imagen base de Python
FROM python:3.9-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos necesarios
COPY app.py .

# Instalar Flask
RUN pip install flask werkzeug

# Exponer el puerto
EXPOSE 8500

# Comando para ejecutar la aplicación
CMD ["python", "app.py"]
EOF

# 4. Construir el contenedor Docker.
echo "Building Docker image..."
docker build -t $DOCKER_IMAGE_NAME $TEMP_DIR

# Eliminar cualquier contenedor existente con el mismo nombre
echo "Removing any existing Docker container with the same name..."
docker rm -f $DOCKER_CONTAINER_NAME

# Ejecutar el contenedor Docker
echo "Running Docker container..."
docker run -d -p $DOCKER_PORT:8500 --name $DOCKER_CONTAINER_NAME $DOCKER_IMAGE_NAME

# Comprobar que el contenedor está en ejecución
echo "Checking if the Docker container is running..."
if [ "$(docker ps -q -f name=$DOCKER_CONTAINER_NAME)" ]; then
    echo "The Docker container is running."
else
    echo "There was an issue running the Docker container."
    exit 1
fi

# Comprobar la ejecución de la página web con curl
echo "Checking the web page with curl..."
sleep 5  # Esperar unos segundos para que el servidor Flask se inicie
curl http://localhost:$DOCKER_PORT

echo "Done. You can also check the page in your web browser at http://localhost:$DOCKER_PORT"
