# ⚡ Automated Installation / Instalación Automatizada

EN: Use these scripts to install or uninstall Tailscale easily using `curl`.

ES: Usa estos scripts para instalar o desinstalar Tailscale fácilmente usando `curl`.

## 📱 Termux Environment / Entorno Termux
EN: Run these commands inside the Termux app.

ES: Ejecuta estos comandos dentro de la app Termux.

### Install / Instalar
```bash
curl -fsSL https://raw.githubusercontent.com/elmendezz/tailscale-android-legacy/refs/heads/main/ts-installer-termux.sh | sh
```

### Uninstall / Desinstalar
```bash
curl -fsSL https://raw.githubusercontent.com/elmendezz/tailscale-android-legacy/refs/heads/main/ts-uninstall-termux.sh | sh
```

## 🔧 Android System (Root/ADB) / Sistema Android (Root/ADB)
EN: Run these commands in a root shell (adb shell su or terminal emulator as root).

ES: Ejecuta estos comandos en una shell root (adb shell su o emulador de terminal como root).

### Install / Instalar
```bash
curl -fsSL https://raw.githubusercontent.com/elmendezz/tailscale-android-legacy/refs/heads/main/ts-installer.sh | sh
```

### Uninstall / Desinstalar
```bash
curl -fsSL https://raw.githubusercontent.com/elmendezz/tailscale-android-legacy/refs/heads/main/ts-uninstall.sh | sh
```

## 🛠️ Specific architectures / Arquitecturas específicas

EN: Architecture-specific scripts to install Tailscale for your device.  
ES: Scripts específicos para instalar Tailscale según la arquitectura del dispositivo.

⚠️ Warning — Choose the correct architecture: these scripts install architecture-specific binaries. Installing the wrong architecture can prevent Tailscale from running or, in worst cases, cause system issues. They perform system-level operations (remounting /system rw, moving binaries, creating device nodes, etc.), require root (adb shell su or Magisk) and may void your warranty. Use at your own risk.  
⚠️ Advertencia — Elige bien la arquitectura: estos scripts instalan binarios específicos para cada arquitectura. Instalar la arquitectura equivocada puede impedir que Tailscale funcione o, en el peor de los casos, causar problemas en el sistema. Realizan operaciones a nivel de sistema (remontar /system en rw, mover binarios, crear nodos de dispositivo, etc.), requieren root (adb shell su o Magisk) y pueden anular la garantía. Úsalos bajo tu propia responsabilidad.

### ts-arm.sh (ARM 32-bit)
```bash
curl -fsSL https://raw.githubusercontent.com/elmendezz/tailscale-android-legacy/refs/heads/main/ts-arm.sh | sh
```

### ts-arm64.sh (ARM64 64-bit)
```bash
curl -fsSL https://raw.githubusercontent.com/elmendezz/tailscale-android-legacy/refs/heads/main/ts-arm64.sh | sh
```