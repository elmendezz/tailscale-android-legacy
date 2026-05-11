#!/system/bin/sh
# Este script se ejecutará con privilegios root en el dispositivo Android

set -e

ARCH="arm"
echo "[+] Usando arquitectura forzada: $ARCH"
echo "[+] Instalación directa y nativa en Magisk (Sin Termux)"

# Definición de rutas
MODULE_DIR="/data/adb/modules/tailscale_systemless"
STATE_DIR="/data/tailscale"
TEMP_DIR="/data/local/tmp/tailscale_install"

# Limpieza inicial
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "[1/4] Descargando binarios de Tailscale ($ARCH)..."
URL="https://pkgs.tailscale.com/stable/tailscale_latest_${ARCH}.tgz"

# Usamos el busybox de Magisk para garantizar que wget y tar funcionen sin Termux
magisk busybox wget -qO "$TEMP_DIR/tailscale.tgz" "$URL"
cd "$TEMP_DIR"
magisk busybox tar xzf tailscale.tgz

# Encontrar la carpeta extraída
DIR=$(find . -type d -name "tailscale_*")

echo "[2/4] Creando módulo de Magisk para integración de sistema..."
mkdir -p "$MODULE_DIR/system/bin"

# Mover los binarios directamente a la ruta de binarios del sistema de Magisk
mv "$DIR/tailscale" "$MODULE_DIR/system/bin/"
mv "$DIR/tailscaled" "$MODULE_DIR/system/bin/"

chmod +x "$MODULE_DIR/system/bin/tailscale"
chmod +x "$MODULE_DIR/system/bin/tailscaled"

# Crear el archivo prop del módulo para que Magisk lo reconozca
cat > "$MODULE_DIR/module.prop" <<EOF
id=tailscale_systemless
name=Tailscale Systemless (Native)
version=1.1
versionCode=2
author=elmendezz
description=Integración nativa para Tailscale CLI sin depender de Termux.
EOF

# Crear un alias "ts" para mayor conveniencia
cat > "$MODULE_DIR/system/bin/ts" <<EOF
#!/system/bin/sh
/system/bin/tailscale --socket=$STATE_DIR/tailscaled.sock "\$@"
EOF

chmod +x "$MODULE_DIR/system/bin/ts"
echo "[✔] Módulo de Magisk y binarios instalados en $MODULE_DIR"

echo "[3/4] Configurando servicio de inicio de Magisk..."
# Usar service.sh dentro del módulo es la práctica recomendada por Magisk
cat > "$MODULE_DIR/service.sh" <<EOF
#!/system/bin/sh

# Esperar a que el sistema arranque completamente
until [ "\$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

sleep 5

# Configurar el dispositivo TUN
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

export XDG_CACHE_HOME=/data/local/tmp/tailscale-cache
mkdir -p "\$XDG_CACHE_HOME" "$STATE_DIR"

# Iniciar el daemon en segundo plano
/system/bin/tailscaled --state=$STATE_DIR/tailscaled.state \\
                       --socket=$STATE_DIR/tailscaled.sock \\
                       --tun=userspace-networking > $STATE_DIR/log_boot.txt 2>&1 &
EOF

chmod +x "$MODULE_DIR/service.sh"
echo "[✔] Servicio de inicio automático configurado (service.sh)."

# Limpieza
rm -rf "$TEMP_DIR"

echo ""
echo "[4/4] ¡Instalación completada con éxito!"
echo "------------------------------------------------------------------"
echo "==> ACCIÓN REQUERIDA: Reinicia tu dispositivo Android ahora."
echo "------------------------------------------------------------------"
