# Tailscale for Android (Legacy & Modern) via Termux + Magisk
A comprehensive guide and toolset to run Tailscale natively on Android devices using static Linux binaries. This method bypasses the limitations of the official Android app, allowing global CLI access...

Esta es una guía completa para ejecutar Tailscale de forma nativa en Android usando binarios estáticos de Linux. Este método evita las limitaciones de la app oficial, permitiendo acceso global por CLI...

# ⚠️ Disclaimer / Descargo de Responsabilidad
EN: We are not responsible for any damage to your device. Although this process is safe and reversible, modifying system files via Magisk always carries a minimal risk. Proceed with caution.

ES: No nos hacemos responsables de cualquier daño a tu dispositivo. Aunque este proceso es seguro y reversible, la modificación de archivos del sistema mediante Magisk siempre conlleva un riesgo mínimo. Procede con precaución.

# 🔍 0. Verify Architecture / Verifica tu Arquitectura
EN: Before downloading, verify your device's ABI (Architecture) to choose the correct binary.

ES: Antes de descargar, verifica la arquitectura (ABI) de tu dispositivo para elegir el binario correcto.

In Termux / En Termux:
```bash
uname -m
# Common outputs and what to choose:
#  * armv7l or armv8l  -> use "arm"
#  * aarch64 or arm64  -> use "arm64"
```

# 🚀 1. Installation / Instalación (Termux)
EN: We will download the package and move the binaries directly to Termux's binary folder ($PREFIX/bin).

ES: Descargaremos el paquete y moveremos los binarios directamente a la carpeta de binarios de Termux ($PREFIX/bin).

Note: On GitHub (file view) fenced code blocks display a copy button (clipboard icon) you can click to copy the commands. 

Nota: En GitHub (vista de archivo) los bloques de código muestran un botón "Copiar" (icono de portapapeles) que permite copiar con un clic.

<details>
<summary><b>English: Download & Install</b> (Click to expand)</summary>

For Legacy Devices (e.g. Galaxy S3 - armv7l)

```bash
VERSION="1.78.1"
ARCH="arm"
URL="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${ARCH}.tgz"

curl -fsSL "$URL" | tar xzv

mv tailscale_${VERSION}_${ARCH}/tailscale* "$PREFIX/bin/"

chmod +x "$PREFIX/bin"/tailscale*
rm -rf tailscale_${VERSION}_${ARCH}
```

For Modern Devices (arm64-v8a)

```bash
VERSION="1.78.1"
ARCH="arm64"
URL="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${ARCH}.tgz"

curl -fsSL "$URL" | tar xzv
mv tailscale_${VERSION}_${ARCH}/tailscale* "$PREFIX/bin/"
chmod +x "$PREFIX/bin"/tailscale*
rm -rf tailscale_${VERSION}_${ARCH}
```

</details>

<details>
<summary><b>Español: Descarga e Instalación</b> (Click para expandir)</summary>

Para Dispositivos Antiguos (ej. Galaxy S3 - armv7l)

```bash
VERSION="1.78.1"
ARCH="arm"
URL="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${ARCH}.tgz"

curl -fsSL "$URL" | tar xzv

mv tailscale_${VERSION}_${ARCH}/tailscale* "$PREFIX/bin/"

chmod +x "$PREFIX/bin"/tailscale*
rm -rf tailscale_${VERSION}_${ARCH}
```

Para Dispositivos Modernos (arm64-v8a)

```bash
VERSION="1.78.1"
ARCH="arm64"
URL="https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${ARCH}.tgz"

curl -fsSL "$URL" | tar xzv
mv tailscale_${VERSION}_${ARCH}/tailscale* "$PREFIX/bin/"
chmod +x "$PREFIX/bin"/tailscale*
rm -rf tailscale_${VERSION}_${ARCH}
```

</details>

# 🏗️ 2. System Integration / Integración (Magisk)
EN: This step creates symbolic links from Termux to /system/bin using Magisk, making the tailscale and tailscaled commands available globally.

ES: Este paso crea enlaces simbólicos desde Termux a /system/bin usando Magisk, haciendo que los comandos estén disponibles globalmente.

<details>
<summary><b>Implementation / Implementación</b> (Click to expand)</summary>

Run as root in Termux / Ejecuta como root:

```bash
mkdir -p /data/adb/modules/tailscale_fix/system/bin

ln -s /data/data/com.termux/files/usr/bin/tailscale /data/adb/modules/tailscale_fix/system/bin/tailscale
ln -s /data/data/com.termux/files/usr/bin/tailscaled /data/adb/modules/tailscale_fix/system/bin/tailscaled

cat << 'EOF' > /data/adb/modules/tailscale_fix/system/bin/ts
#!/system/bin/sh
/system/bin/tailscale --socket=/data/tailscale/tailscaled.sock "$@"
EOF

chmod +x /data/adb/modules/tailscale_fix/system/bin/ts
```

</details>

# ⚙️ 3. Auto-Start Configuration / Inicio Automático
EN: Automated startup script for Magisk.

ES: Script de inicio automático para Magisk.

<details>
<summary><b>Service Setup / Configuración del Servicio</b> (Click to expand)</summary>

```bash
cat << 'EOF' > /data/adb/service.d/tailscale_init.sh
#!/system/bin/sh
sleep 15

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

export XDG_CACHE_HOME=/data/local/tmp/tailscale-cache
mkdir -p "$XDG_CACHE_HOME" /data/tailscale

/system/bin/tailscaled --state=/data/tailscale/tailscaled.state \
                       --socket=/data/tailscale/tailscaled.sock \
                       --tun=userspace-networking > /data/tailscale/log_boot.txt 2>&1 &
EOF

chmod +x /data/adb/service.d/tailscale_init.sh
```

</details>

# 🏁 4. Usage / Uso
```bash
# Reboot device
# After reboot, get a root shell in Termux to login:
su
ts up

# Check status:
ts status
```

- Autor: elmendezz
 * **ROM Environment:** [Alexenferman (crDroid for S3)](https://xdaforums.com/t/rom-7-1-2-crdroid-3-8-9-unofficial-d2att-can-i747-m-compiled-by-alexenferman.4021787/)
* **Software:** [Tailscale](https://tailscale.com)
* [Tailscale For Termux](https://github.com/termux/termux-packages/issues/10166)


Developed for the community to keep legacy hardware useful.
 
Desarrollado para la comunidad para mantener hardware antiguo funcional.