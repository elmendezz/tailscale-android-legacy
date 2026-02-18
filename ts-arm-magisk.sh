#!/data/data/com.termux/files/usr/bin/bash
set -e

ARCH="arm"
echo "[+] Usando arquitectura: $ARCH"


echo "[1/4] Descargando e instalando binarios de Tailscale en Termux..."
URL="https://pkgs.tailscale.com/stable/tailscale_latest_${ARCH}.tgz"
INSTALL_DIR="/data/data/com.termux/files/usr/bin"
TEMP_DIR=$(mktemp -d)

curl -fsSL "$URL" -o "$TEMP_DIR/tailscale.tgz"
tar xzf "$TEMP_DIR/tailscale.tgz" -C "$TEMP_DIR"

DIR=$(find "$TEMP_DIR" -type d -name "tailscale_*")
mv "$DIR/tailscale" "$INSTALL_DIR/"
mv "$DIR/tailscaled" "$INSTALL_DIR/"

chmod +x "$INSTALL_DIR/tailscale"*
rm -rf "$TEMP_DIR"
echo "[✔] Binarios instalados en $INSTALL_DIR"

echo "[2/4] Creando módulo de Magisk para integración de sistema..."
su -c '
set -e
MODULE_DIR="/data/adb/modules/tailscale_systemless"
mkdir -p "$MODULE_DIR/system/bin"

# Crear propiedad del módulo para que aparezca en Magisk
cat > "$MODULE_DIR/module.prop" <<EOF
id=tailscale_systemless
name=Tailscale Systemless
version=1.0
versionCode=1
author=elmendezz
description=Systemless integration for Tailscale CLI.
EOF

# Enlazar binarios de Termux al módulo de Magisk
ln -s /data/data/com.termux/files/usr/bin/tailscale "$MODULE_DIR/system/bin/tailscale"
ln -s /data/data/com.termux/files/usr/bin/tailscaled "$MODULE_DIR/system/bin/tailscaled"

# Crear un alias "ts" para conveniencia
cat > "$MODULE_DIR/system/bin/ts" <<EOF
#!/system/bin/sh
/system/bin/tailscale --socket=/data/tailscale/tailscaled.sock "\$@"
EOF

chmod +x "$MODULE_DIR/system/bin/ts"
echo "[✔] Módulo de Magisk creado en $MODULE_DIR"
'

echo "[3/4] Configurando servicio de inicio automático de Magisk..."
su -c '
set -e
SERVICE_DIR="/data/adb/service.d"
STATE_DIR="/data/tailscale"

mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/tailscale_init.sh" <<EOF
#!/system/bin/sh
sleep 20
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi
export XDG_CACHE_HOME=/data/local/tmp/tailscale-cache
mkdir -p "\$XDG_CACHE_HOME" /data/tailscale
/data/data/com.termux/files/usr/bin/tailscaled --state=$STATE_DIR/tailscaled.state \\
                       --socket=$STATE_DIR/tailscaled.sock \\
                       --tun=userspace-networking > $STATE_DIR/log_boot.txt 2>&1 &
EOF

chmod +x "$SERVICE_DIR/tailscale_init.sh"
echo "[✔] Servicio de inicio automático configurado."
'

echo ""
echo "[4/4] ¡Instalación completada!"
echo "------------------------------------------------------------------"
echo "==> ACCIÓN REQUERIDA: Por favor, REINICIA tu dispositivo ahora."
echo "------------------------------------------------------------------"
echo "Después de reiniciar, abre una terminal (como Termux), y ejecuta:"
echo "  su"
echo "  ts up"
echo ""
echo "Para verificar el estado, usa: ts status"
