#!/system/bin/sh
set -e

ARCH="arm"
echo "[+] Usando arquitectura forzada: $ARCH"
echo "[+] Instalación nativa en Magisk (Método original)"

MODULE_DIR="/data/adb/modules/tailscale_systemless"
STATE_DIR="/data/tailscale"

echo "[1/4] Descargando binarios de Tailscale ($ARCH)..."
URL="https://pkgs.tailscale.com/stable/tailscale_latest_${ARCH}.tgz"
TEMP_DIR=$(mktemp -d)

# Usando tu método original con curl
curl -fsSL "$URL" -o "$TEMP_DIR/tailscale.tgz"
tar xzf "$TEMP_DIR/tailscale.tgz" -C "$TEMP_DIR"

DIR=$(find "$TEMP_DIR" -type d -name "tailscale_*")

echo "[2/4] Creando módulo de Magisk para integración de sistema..."
mkdir -p "$MODULE_DIR/system/bin"

# Mover los binarios directamente a la ruta del sistema de Magisk
mv "$DIR/tailscale" "$MODULE_DIR/system/bin/"
mv "$DIR/tailscaled" "$MODULE_DIR/system/bin/"

chmod +x "$MODULE_DIR/system/bin/tailscale"*

# Crear propiedad del módulo para que aparezca en Magisk
cat > "$MODULE_DIR/module.prop" <<EOF
id=tailscale_systemless
name=Tailscale Systemless
version=1.1
versionCode=2
author=elmendezz
description=Integración nativa para Tailscale CLI.
EOF

# Crear un alias "ts" para conveniencia
cat > "$MODULE_DIR/system/bin/ts" <<EOF
#!/system/bin/sh
/system/bin/tailscale --socket=$STATE_DIR/tailscaled.sock "\$@"
EOF

chmod +x "$MODULE_DIR/system/bin/ts"
echo "[✔] Módulo de Magisk creado en $MODULE_DIR"

echo "[3/4] Configurando servicio de inicio automático de Magisk..."
# Usar service.sh dentro del módulo de Magisk
cat > "$MODULE_DIR/service.sh" <<EOF
#!/system/bin/sh
# Esperar a que el sistema arranque
until [ "\$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 5

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

export XDG_CACHE_HOME=/data/local/tmp/tailscale-cache
mkdir -p "\$XDG_CACHE_HOME" "$STATE_DIR"

/system/bin/tailscaled --state=$STATE_DIR/tailscaled.state \\
                       --socket=$STATE_DIR/tailscaled.sock \\
                       --tun=userspace-networking > $STATE_DIR/log_boot.txt 2>&1 &
EOF

chmod +x "$MODULE_DIR/service.sh"

# Limpieza
rm -rf "$TEMP_DIR"
echo "[✔] Servicio de inicio automático configurado."

echo ""
echo "[4/4] ¡Instalación completada!"
echo "------------------------------------------------------------------"
echo "==> ACCIÓN REQUERIDA: Por favor, REINICIA tu dispositivo ahora."
echo "------------------------------------------------------------------"
echo "Después de reiniciar, ejecuta como superusuario:"
echo "  ts up"
echo "------------------------------------------------------------------"
