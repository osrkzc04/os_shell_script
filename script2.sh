#! /bin/bash
#Obtener nombre del directorio
read -p "Ingrese el nombre del directorio: " directorio

#Declaracion de variables
ruta_base="/$directorio"
directorio_produccion="$ruta_base/produccion"
directorio_backup="$ruta_base/backup"
directorio_logs="$ruta_base/logs"
archivo_log="$directorio_logs/registro.log"


# Función para registrar mensajes en log
log() {
    local mensaje="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $mensaje" >> "$archivo_log"
}

# Función para generar un bakcup .tar.gz
backup() {
    local fecha=$(date '+%Y%m%d%H%M%S')
    local archivo_backup="$directorio_backup/backup_$fecha.tar.gz"
    cd /
    tar -czvPf "$archivo_backup" "$directorio_produccion"
    log "Se ha generado un backup en $archivo_backup"
    echo "Se ha generado un backup en $archivo_backup"
}

# Función para verificar si Nginx está instalado
is_nginx_installed() {
    if command -v nginx &> /dev/null; then
        return 0  # Nginx está instalado
    else
        return 1  # Nginx no está instalado
    fi
}



#Crear estructura de ficheros
#Validar si el directorio principal existe
if [ ! -d "$ruta_base" ]; then
  #Si no existe se crean los directorios
  sudo mkdir $ruta_base
  echo "Directorio '$ruta_base' creado."
  sudo mkdir $directorio_produccion
  echo "Directorio '$directorio_produccion' creado."
  sudo mkdir $directorio_backup
  echo "Directorio '$directorio_produccion' creado."
  sudo mkdir $directorio_logs
  echo "Directorio '$directorio_logs' creado."
  touch $archivo_log
  log "Iniciando Log..."
else
  #Si existe finaliza el script
  echo "No se puede continual el direcorio '/$directorio' ya existe."
  exit 0
fi
echo "--------------------------------------"

#Gerar archivos de texto 
for indice in {1..10}; do
  touch "$directorio_produccion/archivo$indice.txt"
  echo "Se ha creado el archivo archivo$indice.txt"
  log "Se ha creado el archivo archivo$indice.txt"
done
echo "--------------------------------------"
echo "Generando backup..."
backup
echo "--------------------------------------"