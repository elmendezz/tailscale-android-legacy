#!/data/data/com.termux/files/usr/bin/bash
set -e

PREFIX="$HOME/.tailscale"

echo "[+] Deteniendo tailscaled..."
pkill -f tailscaled 2>/dev/null || true

echo "[+] Eliminando archivos..."
rm -rf "$PREFIX"

echo "[+] Limpiando PATH..."
sed -i '/\.tailscale\/bin/d' ~/.bashrc 2>/dev/null || true

echo ""
echo "[✔] Tailscale eliminado de Termux."
echo "Reinicia Termux."
