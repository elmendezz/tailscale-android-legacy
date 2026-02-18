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