#!/bin/bash

# Activar salida verbosa para depuración. Si algo falla, el script se detiene.
set -e

echo "INFO: =============================================="
echo "INFO: INICIANDO PROCESO DE RESPALDO SEGURO"
echo "INFO: =============================================="

# --- Variables (leídas desde el entorno de Docker Compose) ---
# GPG_RECIPIENT, S3_BUCKET, DB_HOST, DB_USER, DB_PASS, DB_NAME

# Directorio local dentro del contenedor donde se guardará el respaldo temporalmente
LOCAL_TEMP_DIR="/tmp"
# Directorio de destino para rsync, montado desde el host
NEXTCLOUD_BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILENAME="db_backup_${DB_NAME}_${TIMESTAMP}.sql"
ENCRYPTED_FILENAME="${BACKUP_FILENAME}.gpg"

# Rutas completas
LOCAL_BACKUP_PATH="${LOCAL_TEMP_DIR}/${BACKUP_FILENAME}"
LOCAL_ENCRYPTED_PATH="${LOCAL_TEMP_DIR}/${ENCRYPTED_FILENAME}"

# --- Lógica del Script ---

# 1. Crear el respaldo de la base de datos
echo "INFO: [1/5] Creando dump de la base de datos '${DB_NAME}'..."
mysqldump --skip-ssl -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" > "${LOCAL_BACKUP_PATH}"
echo "SUCCESS: Dump de la base de datos creado en ${LOCAL_BACKUP_PATH}"

# 2. Cifrar el respaldo con GPG
echo "INFO: [2/5] Cifrando el respaldo para el destinatario '${GPG_RECIPIENT}'..."
gpg --trust-model always --encrypt --recipient "${GPG_RECIPIENT}" --output "${LOCAL_ENCRYPTED_PATH}" "${LOCAL_BACKUP_PATH}"
echo "SUCCESS: Respaldo cifrado creado en ${LOCAL_ENCRYPTED_PATH}"

# 3. Eliminar el archivo de respaldo sin cifrar por seguridad
rm "${LOCAL_BACKUP_PATH}"
echo "INFO: [3/5] Respaldo original sin cifrar eliminado."

# 4. Sincronizar con el directorio de Nextcloud usando rsync
echo "INFO: [4/5] Sincronizando respaldo cifrado con Nextcloud en ${NEXTCLOUD_BACKUP_DIR}..."
rsync -avz "${LOCAL_ENCRYPTED_PATH}" "${NEXTCLOUD_BACKUP_DIR}/"
echo "SUCCESS: Sincronización con el volumen de Nextcloud completada."

# 5. Subir el respaldo cifrado a AWS S3
echo "INFO: [5/5] Subiendo respaldo a AWS S3 Bucket '${S3_BUCKET}'..."
aws s3 cp "${LOCAL_ENCRYPTED_PATH}" "s3://${S3_BUCKET}"
echo "SUCCESS: Subida a AWS S3 completada."

# Limpieza final del archivo cifrado temporal
rm "${LOCAL_ENCRYPTED_PATH}"

echo "INFO: =============================================="
echo "INFO: PROCESO DE RESPALDO COMPLETADO EXITOSAMENTE"
echo "INFO: =============================================="

exit 0