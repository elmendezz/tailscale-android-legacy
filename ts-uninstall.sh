#!/system/bin/sh
set -e

echo "[+] Iniciando desinstalación de Tailscale..."

INSTALLDIR="/system/xbin"
STATE_DIR="/data/tailscale"

echo "[+] Deteniendo tailscaled si está activo..."
if pgrep -f tailscaled > /dev/null; then
    pkill -f tailscaled
    sleep 2
    echo "[+] Proceso detenido."
else
    echo "[+] No estaba corriendo."
fi

echo "[+] Remontando /system en rw..."
mount -o rw,remount /

echo "[+] Eliminando binarios..."
rm -f "$INSTALLDIR/tailscale"
rm -f "$INSTALLDIR/tailscaled"
rm -f "$INSTALLDIR/ts"

echo "[+] Remontando /system en ro..."
mount -o ro,remount /

echo "[+] Eliminando datos de estado..."
rm -rf "$STATE_DIR"

echo "[+] Limpieza adicional..."
rm -rf /data/local/tmp/tailscale_install 2>/dev/null || true

echo ""
echo "[✔] Tailscale desinstalado completamente."
