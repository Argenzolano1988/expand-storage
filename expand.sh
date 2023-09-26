#!/bin/bash

# Ruta al LV que deseas monitorear y expandir
LV_PATH="/dev/mapper/vg0-data0"

# Límite de uso en porcentaje para la expansión automática
LIMIT_PERCENT=80

# Obtiene el uso actual del LV
LV_USAGE=$(df -h | grep $LV_PATH | awk '{print $5}' | cut -d'%' -f1)

# Comprueba si el uso supera el límite establecido
if [ "$LV_USAGE" -ge "$LIMIT_PERCENT" ]; then
    # Obtiene el tamaño actual del LV en megabytes (MB)
    LV_SIZE=$(sudo lvdisplay --units m --noheading -c $LV_PATH | awk -F ":" '{print $7}' | tr -d ' ')

    # Calcula el nuevo tamaño deseado (por ejemplo, aumentar en 500M)
    NEW_SIZE=$((LV_SIZE + 500))

    # Expande el LV y el sistema de archivos
    sudo lvextend -L +${NEW_SIZE}M $LV_PATH
    sudo resize2fs $LV_PATH

    echo "Expansión automática completada. Nuevo tamaño: ${NEW_SIZE}MB"
else
    echo "El uso del LV está por debajo del límite. No se requiere expansión."
fi
