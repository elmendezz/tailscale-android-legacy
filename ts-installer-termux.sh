#!/data/data/com.termux/files/usr/bin/bash
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

PREFIX="$HOME/.tailscale"
BIN_DIR="$PREFIX/bin"
STATE_DIR="$PREFIX/state"
BASE_URL="https://pkgs.tailscale.com/stable"

mkdir -p "$BIN_DIR"
mkdir -p "$STATE_DIR"

cd "$PREFIX"

echo "[+] Descargando última versión..."
curl -fsSL "$BASE_URL/tailscale_latest_${ARCH}.tgz" -o tailscale.tgz

echo "[+] Extrayendo..."
tar xzf tailscale.tgz

DIR=$(ls -d tailscale_*_${ARCH})

if [ -z "$DIR" ]; then
  echo "[-] No se encontró directorio extraído"
  exit 1
fi

mv "$DIR/tailscale" "$BIN_DIR/"
mv "$DIR/tailscaled" "$BIN_DIR/"

chmod 755 "$BIN_DIR/tailscale"
chmod 755 "$BIN_DIR/tailscaled"

echo "[+] Creando alias ts..."

cat > "$BIN_DIR/ts" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

STATE_DIR="$STATE_DIR"
SOCKET="\$STATE_DIR/tailscaled.sock"

start_daemon() {
    if ! pgrep -f tailscaled > /dev/null; then
        echo "[ts] Iniciando tailscaled..."
        $BIN_DIR/tailscaled \
          --state=\$STATE_DIR/tailscaled.state \
          --socket=\$SOCKET \
          --tun=userspace-networking &
        sleep 2
    fi
}

case "\$1" in
  up)
    start_daemon
    shift
    $BIN_DIR/tailscale --socket=\$SOCKET up "\$@"
    ;;
  *)
    $BIN_DIR/tailscale --socket=\$SOCKET "\$@"
    ;;
esac
EOF

chmod 755 "$BIN_DIR/ts"

if ! grep -q ".tailscale/bin" ~/.bashrc 2>/dev/null; then
  echo 'export PATH=$HOME/.tailscale/bin:$PATH' >> ~/.bashrc
fi

echo ""
echo "[✔] Instalación completada."
echo "Reinicia Termux o ejecuta:"
echo "  source ~/.bashrc"
echo ""
echo "Luego usa:"
echo "  ts up"
echo "  ts status"
