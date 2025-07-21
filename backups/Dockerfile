FROM alpine:latest

# Metadatos
LABEL author="Sebastián Morales"
LABEL project="Contenedor de Respaldos a AWS S3"

# Instalar dependencias necesarias sin guardar caché
RUN apk update && apk add --no-cache \
    bash \
    mariadb-client \
    gnupg \
    aws-cli \
    rsync \
    coreutils

# Crear un directorio de trabajo
WORKDIR /app

# Copiar el script de respaldo al contenedor
COPY backup.sh .

# Darle permisos de ejecución
RUN chmod +x backup.sh

# El contenedor ejecutará este script cuando se inicie
ENTRYPOINT ["/app/backup.sh"]