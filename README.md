# Proyecto de Backup Automatizado para Nextcloud con AWS S3

## 📋 Índice

- [Descripción del Proyecto](#-descripción-del-proyecto)
- [¿Qué Hace Este Sistema?](#-qué-hace-este-sistema)
- [Arquitectura Técnica](#️-arquitectura-técnica)
- [Configuración Paso a Paso](#️-configuración-paso-a-paso)
- [Instalación y Despliegue](#-instalación-y-despliegue)
- [Uso del Sistema](#-uso-del-sistema)
- [Agradecimientos](#-agradecimientos)

---

## 🎯 Descripción del Proyecto

Este proyecto implementa un **sistema automatizado de respaldos seguros** para instancias de Nextcloud, diseñado para garantizar la continuidad del negocio y la protección de datos críticos. El sistema utiliza tecnologías modernas de contenedores, cifrado y almacenamiento en la nube para crear una solución robusta y escalable.

### Características Principales

- ✅ **Respaldos automatizados** de bases de datos MariaDB/MySQL
- 🔒 **Cifrado GPG** de extremo a extremo para máxima seguridad
- ☁️ **Almacenamiento redundante** en AWS S3
- 🐳 **Arquitectura basada en contenedores** Docker
- 📅 **Programación flexible** de respaldos
- 🔄 **Sincronización bidireccional** con Nextcloud
- 📊 **Logs detallados** para monitoreo y auditoría

---

## 🔍 ¿Qué Hace Este Sistema?

### Proceso Detallado

1. **📅 Activación**: El sistema se activa manualmente o por programación (cron)
2. **🗃️ Extracción**: Realiza un dump completo de la base de datos de Nextcloud usando `mysqldump`
3. **🔐 Cifrado**: Cifra el dump usando GPG con claves asimétricas para máxima seguridad
4. **💾 Almacenamiento Local**: Guarda una copia en el volumen compartido de Nextcloud
5. **☁️ Respaldo Remoto**: Sube el archivo cifrado a un bucket de AWS S3
6. **🧹 Limpieza**: Elimina archivos temporales sin cifrar por seguridad
7. **📝 Registro**: Registra todas las operaciones en logs detallados

## 🛠️ Requisitos del Sistema

### Requisitos Técnicos Mínimos

- **Docker**: ≥ 20.10.0
- **Docker Compose**: ≥ 1.29.0
- **Sistema Operativo**: Linux, macOS o Windows con WSL2
- **RAM**: Mínimo 2GB disponibles
- **Almacenamiento**: 10GB libres (dependiente del tamaño de la BD)
- **Red**: Conexión a Internet estable

### Requisitos de Servicios Externos

- **AWS Account**: Con acceso a S3
- **S3 Bucket**: Configurado y accesible
- **GPG Keys**: Par de claves pública/privada

### Conocimientos Recomendados

- Conceptos básicos de Docker y contenedores
- Manejo de línea de comandos
- Configuración básica de AWS
- Fundamentos de cifrado GPG

## 🏗️ Arquitectura Técnica

### Componentes de la Arquitectura

#### 1. **Contenedor MariaDB** (`db`)

- **Imagen**: `mariadb:10.5`
- **Función**: Base de datos principal de Nextcloud
- **Configuración**: Optimizada para Nextcloud con aislamiento de transacciones
- **Persistencia**: Volumen Docker `db_data`

#### 2. **Contenedor Nextcloud** (`nextcloud`)

- **Imagen**: `nextcloud:latest`
- **Función**: Aplicación web de almacenamiento en la nube
- **Puerto**: 8080 (host) → 80 (contenedor)
- **Dependencias**: MariaDB

#### 3. **Contenedor Backup Runner** (`backup-runner`)

- **Imagen**: Custom (Alpine + herramientas)
- **Función**: Ejecutor de scripts de backup
- **Herramientas**: `mysqldump`, `gpg`, `aws-cli`, `rsync`
- **Modo**: Ejecución bajo demanda (no persistente)

#### 4. **Red Docker** (`app-network`)

- **Tipo**: Bridge
- **Función**: Comunicación inter-contenedores
- **Aislamiento**: Tráfico interno protegido

### Descripción de Archivos Clave

- **`docker-compose.yml`**: Define la infraestructura completa como código
- **`backup/Dockerfile`**: Construye imagen optimizada con herramientas necesarias
- **`backup/backup.sh`**: Lógica principal del proceso de backup
- **`.env`**: Configuraciones sensibles y variables de entorno

## ⚙️ Configuración Paso a Paso

### Paso 1: Preparación del Entorno

#### 1.1 Clonación del Proyecto

```bash
git clone <URL_DEL_REPOSITORIO>
cd proyecto-backup-aws
```

#### 1.2 Configuración de Variables de Entorno

```bash
# Copiar plantilla de configuración
cp .env.example .env

# Editar variables de entorno
nano .env  # o usar tu editor preferido
```

### Paso 2: Configuración de AWS

#### 2.1 Creación de Bucket S3

```bash
# Usando AWS CLI
aws s3 mb s3://tu-bucket-backups-nextcloud

# Verificar creación
aws s3 ls
```

#### 2.2 Configuración de Credenciales

Crear archivo `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = AKIA...
aws_secret_access_key = xyz...
region = us-east-1
```

#### 2.3 Permisos IAM Mínimos

Política JSON para el usuario AWS:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::...nombrebucket",
                "arn:aws:s3:::...nombrebucket*"
            ]
        }
    ]
}
```

### Paso 3: Configuración de GPG

#### 3.1 Generación de Claves (si no existen)

```bash
# Generar par de claves
gpg --full-generate-key
```

#### 3.2 Exportar Clave Pública (para respaldo)

```bash
# Listar claves
gpg --list-keys

# Exportar clave pública
gpg --export --armor tu_email@ejemplo.com > clave_publica.asc
```

#### 3.3 Verificación de Configuración

```bash
# Verificar que se puede cifrar
echo "test" | gpg --encrypt --recipient tu_email@ejemplo.com --armor
```

### Paso 4: Configuración del Archivo .env

Editar `.env` con los valores reales:

```bash
MYSQL_DATABASE=nextclouddb
MYSQL_USER=nextclouduser
MYSQL_PASSWORD=password_super_seguro_123!
MYSQL_ROOT_PASSWORD=root_password_ultra_seguro_456!

GPG_RECIPIENT=tu_email@ejemplo.com

S3_BUCKET=tu-bucket-backups-nextcloud

DB_HOST=db
```

## 🚀 Instalación y Despliegue

### Paso 1: Construcción y Despliegue Inicial

```bash
# Construir imágenes y crear contenedores
docker-compose up -d

# Verificar que todos los servicios están ejecutándose
docker-compose ps
```

### Paso 2: Configuración Inicial de Nextcloud

1. **Acceder a Nextcloud**: Abrir navegador en `http://localhost:8080`
2. **Configuración inicial**:
   - Usuario admin: `admin`
   - Contraseña: (elegir una segura)
   - Base de datos: MySQL/MariaDB
   - Usuario BD: `nextclouduser` (del .env)
   - Contraseña BD: (la del .env)
   - Nombre BD: `nextclouddb`
   - Host BD: `db:3306`

### Paso 3: Verificación del Sistema

```bash
# Verificar logs de contenedores
docker-compose logs nextcloud
docker-compose logs db

# Verificar conectividad de red
docker-compose exec nextcloud ping db
```

### Paso 4: Primer Backup de Prueba

```bash
# Ejecutar backup manual
docker-compose run backup-runner

# Verificar archivos generados
ls -la backups/

# Verificar subida a S3
aws s3 ls s3://tu-bucket-backups-nextcloud/
```

---

## 🎮 Uso del Sistema

### Comandos Principales

#### Gestión de Servicios

```bash
# Iniciar todos los servicios
docker-compose up -d

# Parar todos los servicios
docker-compose down

# Reiniciar un servicio específico
docker-compose restart nextcloud

# Ver logs en tiempo real
docker-compose logs -f

# Ver estado de servicios
docker-compose ps
```

#### Ejecución de Backups

```bash
# Backup manual (modo interactivo)
docker-compose run backup-runner

# Backup manual (modo detached)
docker-compose run -d backup-runner

# Backup con rebuild de imagen (si modificaste backup.sh)
docker-compose run --build backup-runner

# Ver logs del último backup
docker-compose logs backup-runner
```

#### Gestión de Datos

```bash
# Backup completo del sistema (incluye volúmenes)
docker-compose down
sudo tar -czf sistema_completo_$(date +%Y%m%d).tar.gz db_data/ nextcloud_data/ .env

# Restaurar sistema completo
sudo tar -xzf sistema_completo_YYYYMMDD.tar.gz
docker-compose up -d
```

### Monitoreo y Verificación

#### Verificar Salud del Sistema

```bash
# Script de verificación de salud
cat << 'EOF' > health_check.sh
#!/bin/bash
echo "=== VERIFICACIÓN DE SALUD DEL SISTEMA ==="

echo "1. Estado de contenedores:"
docker-compose ps

echo -e "\n2. Uso de recursos:"
docker stats --no-stream

echo -e "\n3. Espacio en disco:"
df -h

echo -e "\n4. Últimos backups locales:"
ls -lah backups/ | tail -5

echo -e "\n5. Conectividad AWS:"
aws s3 ls s3://tu-bucket-backups-nextcloud/ | tail -3

echo -e "\n6. Estado de GPG:"
gpg --list-keys | grep -A1 "pub"
EOF

chmod +x health_check.sh
./health_check.sh
```

---

## ⏰ Automatización de Backups

### Configuración con Cron

#### Configurar Crontab

```bash
# Abrir editor de crontab
crontab -e

# Agregar líneas para programación de backups:

# Backup diario a las 2:00 AM
0 2 * * * /home/usuario/scripts/nextcloud_backup.sh

# Backup cada 6 horas
0 */6 * * * /home/usuario/scripts/nextcloud_backup.sh

# Backup semanal los domingos a las 3:00 AM
0 3 * * 0 /home/usuario/scripts/nextcloud_backup.sh

# Verificar configuración de cron
crontab -l
```

### Configuración con Systemd (Linux)

#### Crear Servicio Systemd

```bash
# Crear archivo de servicio
sudo tee /etc/systemd/system/nextcloud-backup.service << 'EOF'
[Unit]
Description=Nextcloud Backup Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
User=usuario
Group=usuario
WorkingDirectory=/ruta/completa/a/proyecto-backup-aws
ExecStart=/home/usuario/scripts/nextcloud_backup.sh
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Crear timer
sudo tee /etc/systemd/system/nextcloud-backup.timer << 'EOF'
[Unit]
Description=Run Nextcloud Backup Service daily
Requires=nextcloud-backup.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
EOF

# Habilitar y iniciar timer
sudo systemctl daemon-reload
sudo systemctl enable nextcloud-backup.timer
sudo systemctl start nextcloud-backup.timer

# Verificar estado
sudo systemctl status nextcloud-backup.timer
sudo systemctl list-timers nextcloud-backup*
```

## 🎓 Agradecimientos

### Reconocimientos Académicos

Este proyecto fue desarrollado como parte del examen semestral de la asignatura **Tópicos Especiales I** de la **Universidad Tecnológica de Panamá**, bajo la supervisión del **Dr. Santiago Quintero**.

### Objetivos de Aprendizaje Cumplidos

- ✅ **DevOps y Automatización**: Implementación de pipelines automatizados
- ✅ **Containerización**: Arquitectura basada en Docker y Docker Compose
- ✅ **Cloud Computing**: Integración con servicios de AWS
- ✅ **Seguridad**: Implementación de cifrado y buenas prácticas
- ✅ **Monitoreo**: Sistemas de logging y alertas
- ✅ **Documentación**: Documentación técnica exhaustiva

### Tecnologías Exploradas

| Categoría | Tecnologías |
|-----------|-------------|
| **Contenedores** | Docker, Docker Compose |
| **Cloud** | AWS S3, IAM |
| **Bases de Datos** | MariaDB, MySQL |
| **Seguridad** | GPG, SSL/TLS |
| **Scripting** | Bash, PowerShell |
| **Aplicaciones** | Nextcloud |
| **Monitoreo** | Docker Logs, Systemd |

### Contribuidores

- **Desarrollador Principal**: Sebastián Morales (@nzkdevsaider)
- **Supervisor Académico**: Dr. Santiago Quintero
- **Institución**: Universidad Tecnológica de Panamá
