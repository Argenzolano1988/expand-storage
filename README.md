# Expand-Storage

Este es el detalle del script:

```bash
#!/bin/bash

# Ruta al LV que deseas monitorear y expandir
LV_PATH="/dev/mapper/vg0-data0"

# Límite de uso en porcentaje para la expansión automática
LIMIT_PERCENT=80

# Obtiene el uso actual del LV
LV_USAGE=$(df -h | grep $LV_PATH | awk '{print $5}' | cut -d'%' -f1)
```

- `#!/bin/bash`: Esta línea indica que el script debe ser interpretado por el intérprete de comandos Bash.

- `LV_PATH="/dev/mapper/vg0-data0"`: Define la ruta al volumen lógico (`LV`) que deseas monitorear y expandir. En este caso, se establece en `/dev/mapper/vg0-data0`.

- `LIMIT_PERCENT=80`: Establece el límite de uso en porcentaje para la expansión automática. El script verificará si el uso del volumen supera este límite antes de realizar la expansión.

- `LV_USAGE=$(df -h | grep $LV_PATH | awk '{print $5}' | cut -d'%' -f1)`: Esta línea obtiene el uso actual del volumen lógico (`LV_USAGE`). Desglosemos cómo funciona:

   - `df -h`: Este comando muestra información sobre el espacio en disco, incluido el uso actual del sistema de archivos.
   
   - `grep $LV_PATH`: Filtra las líneas que contienen la ruta del volumen lógico `$LV_PATH`.

   - `awk '{print $5}'`: Extrae la columna que contiene el porcentaje de uso.

   - `cut -d'%' -f1`: Elimina el símbolo '%' y obtiene solo el valor numérico del porcentaje.

```bash
# Comprueba si el uso supera el límite establecido
if [ "$LV_USAGE" -ge "$LIMIT_PERCENT" ]; then
    # Obtiene el tamaño actual del LV en megabytes (MB)
    LV_SIZE=$(sudo lvdisplay --units m --noheading -c $LV_PATH | awk -F ":" '{print $7}' | tr -d ' ')

    # Calcula el nuevo tamaño deseado (por ejemplo, aumentar en 500MB)
    NEW_SIZE=$((LV_SIZE + 500))

    # Expande el LV y el sistema de archivos
    sudo lvextend -L +${NEW_SIZE}M $LV_PATH
    sudo resize2fs $LV_PATH

    echo "Expansión automática completada. Nuevo tamaño: ${NEW_SIZE}MB"
else
    echo "El uso del LV está por debajo del límite. No se requiere expansión."
fi
```

- La sección dentro del `if [ "$LV_USAGE" -ge "$LIMIT_PERCENT" ]; then` verifica si el uso del volumen supera el límite establecido.

- `LV_SIZE=$(sudo lvdisplay --units m --noheading -c $LV_PATH | awk -F ":" '{print $7}' | tr -d ' ')`: Esta línea obtiene el tamaño actual del volumen lógico en megabytes (MB). Desglosemos cómo funciona:

   - `sudo lvdisplay --units m --noheading -c $LV_PATH`: Utiliza el comando `lvdisplay` para obtener información detallada del volumen lógico. Se especifica el uso de unidades en megabytes (`--units m`), se omite la cabecera (`--noheading`) y se obtiene la información en formato CSV (`-c`).

   - `awk -F ":" '{print $7}'`: Divide la línea de información en campos utilizando `:` como delimitador y extrae el séptimo campo, que contiene el tamaño.

   - `tr -d ' '`: Elimina espacios en blanco adicionales que pueden estar presentes.

- `NEW_SIZE=$((LV_SIZE + 500))`: Calcula el nuevo tamaño deseado sumando 500MB al tamaño actual del volumen.

- `sudo lvextend -L +${NEW_SIZE}M $LV_PATH`: Expande el volumen lógico `$LV_PATH` en la cantidad especificada (`+${NEW_SIZE}M`).

- `sudo resize2fs $LV_PATH`: Ajusta el tamaño del sistema de archivos para que coincida con el nuevo tamaño del volumen lógico.

- `echo "Expansión automática completada. Nuevo tamaño: ${NEW_SIZE}MB"`: Muestra un mensaje de éxito que indica que la expansión se completó y muestra el nuevo tamaño del volumen.

- `echo "El uso del LV está por debajo del límite. No se requiere expansión."`: Muestra un mensaje si el uso del volumen está por debajo del límite y no se requiere expansión.

Puedes agregar este crontab para que lo programes cada hora, así evalúa constantemente el estado del disco, si supera el 80% lo aumenta 500 MB automático: 

```bash
echo "0 * * * * /ruta/al/expand-storage.sh" >> mi_crontab
```
Luego, carga el archivo mi_crontab en el crontab del usuario utilizando el comando crontab:

```bash
crontab mi_crontab
```

Puedes verificar que la tarea se haya agregado correctamente ejecutando:
```bash
crontab -l
```

En resumen, este script Bash monitorea el uso de un volumen lógico, compara el uso con un límite establecido y, si el uso supera el límite, expande automáticamente el volumen lógico y el sistema de archivos. Este enfoque permite gestionar eficientemente el espacio en disco según sea necesario.

