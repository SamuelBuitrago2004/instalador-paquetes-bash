#!/bin/bash

# Nombre del archivo de lista y de registro de fallos/éxitos
ARCHIVO_LISTA="paquetes.txt"
ARCHIVO_LOG="instalacion_log.txt"

# Encabezado del registro
echo "=== INICIO DE INSTALACIÓN: $(date) ===" > "$ARCHIVO_LOG"

# Verificar si el archivo con la lista de paquetes existe
if [ ! -f "$ARCHIVO_LISTA" ]; then
    echo "Error: No se encontró el archivo $ARCHIVO_LISTA" | tee -a "$ARCHIVO_LOG"
    exit 1
fi

echo "Actualizando repositorios del sistema (apt update)..."
sudo apt update -y >> "$ARCHIVO_LOG" 2>&1

echo "Procesando e instalando paquetes..."

# Leer la lista paquete por paquete
while IFS= read -r paquete; do
    # Ignorar líneas vacías o comentarios que empiecen con #
    [[ -z "$paquete" || "$paquete" =~ ^# ]] && continue

    echo "Instalando: $paquete..."

    # Intentar instalar el paquete verificando dependencias
    if sudo apt install -y "$paquete" >> "$ARCHIVO_LOG" 2>&1; then
        echo "[ÉXITO] El paquete '$paquete' se instaló correctamente." | tee -a "$ARCHIVO_LOG"
    else
        echo "[FALLO] Ocurrió un error al instalar el paquete '$paquete'." | tee -a "$ARCHIVO_LOG"
    fi
done < "$ARCHIVO_LISTA"

echo "=== FIN DE LA INSTALACIÓN: $(date) ===" | tee -a "$ARCHIVO_LOG"
echo "--------------------------------------------------"
echo "Proceso finalizado. Puedes consultar $ARCHIVO_LOG para ver el registro completo."
