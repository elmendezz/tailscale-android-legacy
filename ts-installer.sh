#!/system/bin/sh
set -e

echo "[+] Detectando arquitectura..."

ARCH_RAW=$(uname -m)

case "$ARCH_RAW" in
  armv7l|armeabi*)
    ARCH="arm"
    ;;
  aarch64|arm64*)
    ARCH="arm64"
    ;;
  *)
    echo "[-] Arquitectura no soportada: $ARCH_RAW"
    exit 1
    ;;
esac

echo "[+] Arquitectura detectada: $ARCH"

BASE_URL="https://pkgs.tailscale.com/stable"
TMPDIR="/data/local/tmp/tailscale_install"
INSTALLDIR="/system/xbin"
STATE_DIR="/data/tailscale"
SOCKET="$STATE_DIR/tailscaled.sock"

echo "[+] Preparando entorno..."
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

echo "[+] Limpieza..."
rm -rf "$TMPDIR"

echo ""
echo "[✔] Instalación completada."
echo "Usa ahora:"
echo "  ts up"
echo "  ts status"
echo "  ts ip"
