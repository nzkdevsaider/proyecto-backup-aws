# Usamos una imagen base de Alpine Linux para que sea ligera
FROM alpine:latest

# Metadatos
LABEL author="Tu Nombre"
LABEL project="Contenedor de Respaldo"

# Instalar dependencias necesarias sin guardar caché
# Se añade 'sed' para poder corregir los finales de línea
RUN apk update && apk add --no-cache \
    bash \
    mariadb-client \
    gnupg \
    aws-cli \
    rsync \
    coreutils \
    sed

# Crear un directorio de trabajo
WORKDIR /app

# Copiar el script de respaldo al contenedor
COPY backup.sh .

RUN sed -i 's/\r$//' /app/backup.sh

# Darle permisos de ejecución al script
RUN chmod +x backup.sh

# El contenedor ejecutará este script cuando se inicie
ENTRYPOINT ["/app/backup.sh"]
