# Proyecto de Backup Automatizado a AWS

Este proyecto implementa un sistema automatizado de respaldo para Nextcloud que cifra las bases de datos y las almacena en AWS S3.

## Requisitos escenciales

- Docker
- Un bucket S3 en AWS

## Arquitectura

El proyecto utiliza Docker Compose para orquestar tres servicios principales:

- **MariaDB**: Base de datos para Nextcloud
- **Nextcloud**: Plataforma de almacenamiento en la nube
- **Backup Runner**: Contenedor que ejecuta respaldos automatizados

## Configuración

### Archivo de Variables de Entorno

Crea un archivo `.env` con las siguientes variables:

```bash
# Configuración de la Base de Datos
MYSQL_DATABASE=nextclouddb
MYSQL_USER=nextclouduser
MYSQL_PASSWORD=tu_password_seguro
MYSQL_ROOT_PASSWORD=tu_root_password_seguro

# Configuración de GPG para cifrado
GPG_RECIPIENT=tu_email@ejemplo.com

# Configuración de AWS S3
S3_BUCKET=nombre_de_tu_bucket

# Host de la base de datos
DB_HOST=db
```

### Credenciales AWS

Configura tus credenciales AWS en `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = TU_ACCESS_KEY
aws_secret_access_key = TU_SECRET_KEY
```

### 3. Llaves GPG

Debes de tener configuradas las llaves GPG en `~/.gnupg/` para el cifrado de los respaldos. Recuerda que debe coincidir con el correo eléctronico que vas a colocar en GPG_RECIPIENT.

## 🚀 Uso

### Iniciar los servicios

```bash
docker-compose up -d
```

### Ejecutar respaldo manual

```bash
docker-compose run backup-runner
```

### Detener los servicios

```bash
docker-compose down
```

## Automatización

Para automatizar los respaldos, puedes configurar un cron job que ejecute:

```bash
cd /ruta/al/proyecto && docker-compose run backup-runner
```

Si realizaste un cambio local en el archivo backup.sh por tu cuenta, recuerda buildear de nuevo el contenedor donde se encuentra el backup-runner.

```bash
docker-compose run --build backup-runner
```

Si deseas programarlo para que se haga durante un tiempo determinado, usa el comando crontab -e y configura la sentencia.
