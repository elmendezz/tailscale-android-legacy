#!/system/bin/sh
set -e

ARCH="arm"
echo "[+] Usando arquitectura forzada: $ARCH"
echo "[+] Instalación nativa en Magisk con Fix de DNS"

MODULE_DIR="/data/adb/modules/tailscale_systemless"
STATE_DIR="/data/tailscale"

echo "[1/5] Descargando e instalando binarios de Tailscale..."
URL="https://pkgs.tailscale.com/stable/tailscale_latest_${ARCH}.tgz"
TEMP_DIR=$(mktemp -d)

curl -fsSL "$URL" -o "$TEMP_DIR/tailscale.tgz"
tar xzf "$TEMP_DIR/tailscale.tgz" -C "$TEMP_DIR"

DIR=$(find "$TEMP_DIR" -type d -name "tailscale_*")

echo "[2/5] Creando módulo de Magisk para integración de sistema..."
mkdir -p "$MODULE_DIR/system/bin"
mv "$DIR/tailscale" "$MODULE_DIR/system/bin/"
mv "$DIR/tailscaled" "$MODULE_DIR/system/bin/"
chmod +x "$MODULE_DIR/system/bin/tailscale"*

cat > "$MODULE_DIR/module.prop" <<EOF
id=tailscale_systemless
name=Tailscale Systemless
version=1.2
versionCode=3
author=elmendezz
description=Integración nativa para Tailscale CLI con Fix de DNS.
EOF

cat > "$MODULE_DIR/system/bin/ts" <<EOF
#!/system/bin/sh
/system/bin/tailscale --socket=$STATE_DIR/tailscaled.sock "\$@"
EOF
chmod +x "$MODULE_DIR/system/bin/ts"

echo "[3/5] Aplicando FIX de DNS para binarios de Linux en Android..."
# Creamos el archivo resolv.conf que Magisk montará sobre el sistema
mkdir -p "$MODULE_DIR/system/etc"
cat > "$MODULE_DIR/system/etc/resolv.conf" <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF
chmod 644 "$MODULE_DIR/system/etc/resolv.conf"
echo "[✔] Fix de DNS aplicado."

echo "[4/5] Configurando servicio de inicio automático de Magisk..."
cat > "$MODULE_DIR/service.sh" <<EOF
#!/system/bin/sh
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
echo "[✔] Servicio configurado."

echo ""
echo "[5/5] ¡Instalación completada!"
echo "------------------------------------------------------------------"
echo "==> ACCIÓN REQUERIDA: Por favor, REINICIA tu dispositivo ahora."
echo "    (Es obligatorio reiniciar para que Magisk inyecte el DNS)"
echo "------------------------------------------------------------------"
echo "Después de reiniciar, ejecuta:"
echo "  su"
echo "  ts up"
echo "------------------------------------------------------------------"
