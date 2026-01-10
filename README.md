# Tailscale for Android (Legacy & Modern) via Termux + Magisk
A comprehensive guide and toolset to run Tailscale natively on Android devices using static Linux binaries. This method bypasses the limitations of the official Android app, allowing global CLI access and persistence through Magisk.
Esta es una guía completa para ejecutar Tailscale de forma nativa en Android usando binarios estáticos de Linux. Este método evita las limitaciones de la app oficial, permitiendo acceso global por terminal (CLI) y persistencia mediante Magisk.
# ⚠️ Disclaimer / Descargo de Responsabilidad
EN: We are not responsible for any damage to your device. Although this process is safe and reversible, modifying system files via Magisk always carries a minimal risk. Proceed with caution.
ES: No nos hacemos responsables de cualquier daño a tu dispositivo. Aunque este proceso es seguro y reversible, la modificación de archivos del sistema mediante Magisk siempre conlleva un riesgo mínimo. Procede con precaución.
# 🔍 0. Verify Architecture / Verifica tu Arquitectura
EN: Before downloading, verify your device's ABI (Architecture) to choose the correct binary.
ES: Antes de descargar, verifica la arquitectura (ABI) de tu dispositivo para elegir el binario correcto.
# In Termux / En Termux:
uname -m

 * armv7l or armv8l: Use arm
 * aarch64 or arm64: Use arm64
🚀 1. Installation / Instalación (Termux)
EN: We will download the package and move the binaries directly to Termux's binary folder ($PREFIX/bin).
ES: Descargaremos el paquete y moveremos los binarios directamente a la carpeta de binarios de Termux ($PREFIX/bin).
<details>
<summary><b>English: Download & Install</b> (Click to expand)</summary>
For Legacy Devices (e.g. Galaxy S3 - armv7l)
# Download
curl -fsSL [https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm.tgz](https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm.tgz) | tar xzv

# Move to Termux bin folder
mv tailscale_1.78.1_arm/tailscale* $PREFIX/bin/

# Set permissions and cleanup
chmod +x $PREFIX/bin/tailscale*
rm -rf tailscale_1.78.1_arm

For Modern Devices (arm64-v8a)
# Download
curl -fsSL [https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm64.tgz](https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm64.tgz) | tar xzv

# Move to Termux bin folder
mv tailscale_1.78.1_arm64/tailscale* $PREFIX/bin/

# Set permissions and cleanup
chmod +x $PREFIX/bin/tailscale*
rm -rf tailscale_1.78.1_arm64

</details>
<details>
<summary><b>Español: Descarga e Instalación</b> (Click para expandir)</summary>
Para Dispositivos Antiguos (ej. Galaxy S3 - armv7l)
# Descargar
curl -fsSL [https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm.tgz](https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm.tgz) | tar xzv

# Mover a la carpeta bin de Termux
mv tailscale_1.78.1_arm/tailscale* $PREFIX/bin/

# Permisos y limpieza
chmod +x $PREFIX/bin/tailscale*
rm -rf tailscale_1.78.1_arm

Para Dispositivos Modernos (arm64-v8a)
# Descargar
curl -fsSL [https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm64.tgz](https://pkgs.tailscale.com/stable/tailscale_1.78.1_arm64.tgz) | tar xzv

# Mover a la carpeta bin de Termux
mv tailscale_1.78.1_arm64/tailscale* $PREFIX/bin/

# Permisos y limpieza
chmod +x $PREFIX/bin/tailscale*
rm -rf tailscale_1.78.1_arm64

</details>
🏗️ 2. System Integration / Integración (Magisk)
EN: This step creates symbolic links from Termux to /system/bin using Magisk, making the tailscale and tailscaled commands available globally.
ES: Este paso crea enlaces simbólicos desde Termux a /system/bin usando Magisk, haciendo que los comandos estén disponibles globalmente.
<details>
<summary><b>Implementation / Implementación</b> (Click to expand)</summary>
Run as root in Termux / Ejecuta como root:
# Create Magisk module structure
mkdir -p /data/adb/modules/tailscale_fix/system/bin

# Link binaries from Termux to System
ln -s /data/data/com.termux/files/usr/bin/tailscale /data/adb/modules/tailscale_fix/system/bin/tailscale
ln -s /data/data/com.termux/files/usr/bin/tailscaled /data/adb/modules/tailscale_fix/system/bin/tailscaled

# Create 'ts' wrapper for convenience (Avoids typing socket path)
cat << 'EOF' > /data/adb/modules/tailscale_fix/system/bin/ts
#!/system/bin/sh
/system/bin/tailscale --socket=/data/tailscale/tailscaled.sock "$@"
EOF

chmod +x /data/adb/modules/tailscale_fix/system/bin/ts

</details>
⚙️ 3. Auto-Start Configuration / Inicio Automático
EN: Automated startup script for Magisk.
ES: Script de inicio automático para Magisk.
<details>
<summary><b>Service Setup / Configuración del Servicio</b> (Click to expand)</summary>
cat << 'EOF' > /data/adb/service.d/tailscale_init.sh
#!/system/bin/sh
sleep 15

# TUN Driver setup (Vital for legacy kernels/Android 7)
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# Environment Setup
export XDG_CACHE_HOME=/data/local/tmp/tailscale-cache
mkdir -p $XDG_CACHE_HOME /data/tailscale

# Launch Daemon in userspace mode (More compatible)
/system/bin/tailscaled --state=/data/tailscale/tailscaled.state \
                       --socket=/data/tailscale/tailscaled.sock \
                       --tun=userspace-networking > /data/tailscale/log_boot.txt 2>&1 &
EOF

chmod +x /data/adb/service.d/tailscale_init.sh

</details>
🏁 4. Usage / Uso
 * Reboot / Reinicia.
 * Login / Inicia Sesión:
   su
ts up

 * Check Status / Ver Estado:
   ts status

Credits / Créditos
 * Project Author / Autor: elmendezz
 * ROM Environment: Alex (LineageOS 14.1 for S3)
 * Software: Tailscale
Developed for the community to keep legacy hardware useful. Desarrollado para la comunidad para mantener hardware antiguo funcional.
