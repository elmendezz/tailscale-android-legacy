#!/system/bin/sh
set -e

echo "[+] Forzando arquitectura arm (32-bit)..."
ARCH="arm"

BASE_URL="https://pkgs.tailscale.com/stable"
TMPDIR="/data/local/tmp/tailscale_install"
INSTALLDIR="/system/xbin"
STATE_DIR="/data/tailscale"
SOCKET="$STATE_DIR/tailscaled.sock"

echo "[+] Preparando entorno..."
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
cd "$TMPDIR"

echo "[+] Descargando última versión para $ARCH..."
curl -fsSL "$BASE_URL/tailscale_latest_${ARCH}.tgz" -o tailscale.tgz

echo "[+] Extrayendo..."
tar xzf tailscale.tgz

DIR=$(ls -d tailscale_*_${ARCH})
if [ -z "$DIR" ]; then
  echo "[-] No se encontró el directorio extraído"
  exit 1
fi

if [ ! -f "$DIR/tailscale" ] || [ ! -f "$DIR/tailscaled" ]; then
  echo "[-] Binarios no encontrados"
  exit 1
fi

echo "[+] Remontando /system en rw..."
mount -o rw,remount /

mkdir -p "$INSTALLDIR"

echo "[+] Instalando binarios..."
mv "$DIR/tailscale" "$INSTALLDIR/"
mv "$DIR/tailscaled" "$INSTALLDIR/"

chmod 755 "$INSTALLDIR/tailscale"
chmod 755 "$INSTALLDIR/tailscaled"

echo "[+] Configurando directorio de estado..."
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

echo "[+] Creando alias inteligente 'ts'..."

cat > "$INSTALLDIR/ts" <<'EOF'
#!/system/bin/sh

STATE_DIR="/data/tailscale"
SOCKET="$STATE_DIR/tailscaled.sock"

start_daemon() {
    if ! pgrep -f tailscaled > /dev/null; then
        echo "[ts] Iniciando tailscaled..."
        tailscaled \
          --state=$STATE_DIR/tailscaled.state \
          --socket=$SOCKET \
          --tun=userspace-networking &
        sleep 3
    fi
}

case "$1" in
  up)
    start_daemon
    shift
    tailscale --socket=$SOCKET up "$@"
    ;;
  *)
    tailscale --socket=$SOCKET "$@"
    ;;
esac
EOF

chmod 755 "$INSTALLDIR/ts"

echo "[+] Remontando /system en ro..."
mount -o ro,remount /

echo ""
echo "[?] ¿Deseas instalar el script de inicio automático (Magisk service.d)? [y/N]"
# Intentar leer de /dev/tty para soportar curl | sh
if [ -c /dev/tty ]; then
    read -r RESPONSE < /dev/tty
else
    echo "[-] No se detectó terminal interactiva. Omitiendo."
    RESPONSE="n"
fi

case "$RESPONSE" in
    [yY][eE][sS]|[yY])
        SERVICE_DIR="/data/adb/service.d"
        if [ -d "$SERVICE_DIR" ]; then
            echo "[+] Creando script de inicio en $SERVICE_DIR..."
            cat > "$SERVICE_DIR/tailscale_init.sh" <<EOF
#!/system/bin/sh
sleep 15

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

export XDG_CACHE_HOME=/data/local/tmp/tailscale-cache
mkdir -p "\$XDG_CACHE_HOME" /data/tailscale

$INSTALLDIR/tailscaled --state=$STATE_DIR/tailscaled.state \\
                       --socket=$SOCKET \\
                       --tun=userspace-networking > $STATE_DIR/log_boot.txt 2>&1 &
EOF
            chmod +x "$SERVICE_DIR/tailscale_init.sh"
            echo "[✔] Servicio configurado."
        else
            echo "[-] No se encontró $SERVICE_DIR. ¿Tienes Magisk instalado? Omitiendo."
        fi
        ;;
    *)
        echo "[*] Omitiendo configuración de inicio automático."
        ;;
esac

echo "[+] Limpieza..."
rm -rf "$TMPDIR"

echo ""
echo "[✔] Instalación completada."
echo "Usa ahora:"
echo "  ts up"
echo "  ts status"
echo "  ts ip"