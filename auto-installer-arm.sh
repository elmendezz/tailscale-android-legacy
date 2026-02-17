set -e

echo "[+] Configuración inicial..."
TMPDIR="/data/local/tmp/tailscale_install"
INSTALLDIR="/system/xbin"
ARCH="arm"
BASE_URL="https://pkgs.tailscale.com/stable"
STATE_DIR="/data/tailscale"
SOCKET="$STATE_DIR/tailscaled.sock"

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
cd "$TMPDIR"

echo "[+] Descargando última versión..."
curl -fsSL "$BASE_URL/tailscale_latest_${ARCH}.tgz" -o tailscale.tgz

echo "[+] Extrayendo..."
tar xzf tailscale.tgz

DIR=$(ls -d tailscale_*_${ARCH})
if [ -z "$DIR" ]; then
  echo "[-] No se encontró el directorio extraído"
  exit 1
fi

echo "[+] Verificando binarios..."
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

echo "[+] Creando directorio de estado..."
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

echo "[+] Creando alias ts inteligente..."

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

echo "[+] Limpieza..."
rm -rf "$TMPDIR"

echo ""
echo "[✔] Instalación completada."
echo "Ahora puedes usar:"
echo "  ts up"
echo "  ts status"
echo "  ts ip"
