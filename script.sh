#! /bin/bash

#Variables
file_log="/var/log/puce_tec.log"
file_html="/var/www/html/index.html"
file_template="./templates/index.html"

#Crear archivo de log si no existe
if [ ! -f "$file_log" ]; then
    touch $file_log
fi

banner_main(){
    echo " ____                   _____         "
    echo "|  _ \ _   _  ___ ___  |_   _|__  ___ "
    echo "| |_) | | | |/ __/ _ \   | |/ _ \/ __|"
    echo "|  __/| |_| | (_|  __/   | |  __/ (__ "
    echo "|_|    \__,_|\___\___|   |_|\___|\___|"
    echo "--------------------------------------"
}

view_menu(){
    clear
    banner_main
    echo "1. Configuración Automática 🚀" 
    echo "2. Estado Ngixn 🐧"
    echo "3. Copiar Plantilla HTML 📄"
    echo "4. Generar Bakcup 📂"
    echo "5. Ver Logs 📝"
    echo "6. Salir 🚪"
}

# Función para verificar si Nginx está instalado
is_nginx_installed() {
    if command -v nginx &> /dev/null; then
        return 0  # Nginx está instalado
    else
        return 1  # Nginx no está instalado
    fi
}

# Función para instalar Nginx
install_nginx() {
    log "Instalando Nginx"
    echo "Instalando Nginx..."
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case $ID in
            ubuntu|debian)
                sudo apt update
                sudo apt install -y nginx
                ;;
            centos|fedora|rhel)
                sudo yum install -y nginx
                ;;
            *)
                echo "Error: Sistema operativo no soportado."
                exit 1
                ;;
        esac
    else
        echo "Error: No se pudo determinar el sistema operativo."
        exit 1
    fi
    read -p "Presiona Enter para continuar..."
}

# Función para iniciar Nginx
start_nginx() {
    log "Iniciando Nginx"
    echo "Iniciando Nginx..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
    read -p "Presiona Enter para continuar..."
}

# Función para verificar el estado de Nginx
check_nginx_status() {
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ Nginx está en ejecución. "
    else
        echo "❌ Nginx no está en ejecución."
    fi
    read -p "Presiona Enter para continuar..."
}

# Función Automática
config_init(){
    log "Iniciando configuración automática"
    if is_nginx_installed; then
        echo "✅ Nginx ya está instalado."
    else
        echo "Nginx no está instalado."
        read -p "¿Deseas instalar Nginx? (s/n): " choice
        if [[ $choice == "s" || $choice == "S" ]]; then
            install_nginx
            start_nginx
            check_nginx_status
            copy_html_template
        else
            echo "❌ Instalación de Nginx cancelada."
            exit 0
        fi
    fi
    read -p "Presiona Enter para continuar..."
}

#Funcion para copiar plantilla HTML
copy_html_template(){
    log "Copiar plantilla HTML"
    read -p "¿Está seguro que desea modificar el contenido de $file_html ? (s/n): " choice
    if [[ $choice == "s" || $choice == "S" ]]; then
        read -p "Ingrese el nombre del sitio web: " name
        sudo sed "s/-name-/$name/g" "$file_template" > $file_html
        echo "✅ La plantilla se ha copiado correctamente."
        log "El archvo $file_html ha sido modificado"
    fi
    read -p "Presiona Enter para continuar..."
}

# Función para registrar mensajes en log
log() {
    local mensaje="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $mensaje" >> "$file_log"
}

while true; 
do
    view_menu
    read -p "Selecciona una opción (1-6): " opcion
    case $opcion in
        1)
            config_init
            ;;
        2)
            check_nginx_status
            ;;
        3)
            copy_html_template
            ;;
        6)
            echo -e "Saliendo del menú... 👋"
            break
            ;;
        *)
            echo -e "Opción no válida. Inténtalo de nuevo. ❌"
            read -p "Presiona Enter para continuar..."
            ;;
    esac
done
