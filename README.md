# Stable Diffusion WebUI – Raspberry Pi (ARM)

![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%20%2F%20ARM-blue)
![CPU](https://img.shields.io/badge/acceleration-CPU--only-orange)
![ARM64](https://img.shields.io/badge/ARM64-aarch64-success)
![ARM32](https://img.shields.io/badge/ARM32-armv7l-yellow)
![License](https://img.shields.io/badge/license-MIT-informational)

This repository provides a **fully automated setup** for running  
**AUTOMATIC1111 Stable Diffusion WebUI** on Raspberry Pi and other ARM-based Linux systems.

It supports **CPU-only inference**, is optimized for ARM environments, and includes
a guided setup, run script, and clean uninstall process.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Supported Architectures](#supported-architectures)
  - [ARM64 (aarch64) – Recommended](#arm64-aarch64--recommended)
  - [ARM32 (armv7l) – Best Effort](#arm32-armv7l--best-effort)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Running Stable Diffusion](#running-stable-diffusion)
- [Offline Mode](#offline-mode)
- [Uninstalling](#uninstalling)
- [Known Limitations](#known-limitations)
- [Credits](#credits)
- [Recommendation Summary](#recommendation-summary)

---

## 🧠 Overview

This setup installs and configures:

- AUTOMATIC1111 Stable Diffusion WebUI
- Python virtual environment
- CPU-only PyTorch (no CUDA / no ROCm)
- Preconfigured launch scripts
- Clean uninstall support

It is designed for **Raspberry Pi OS**, **Debian**, and other ARM Linux distributions.

---

## 🧩 Supported Architectures

The setup script **automatically detects your system architecture** and installs
the correct dependencies.

---

### ✅ ARM64 (aarch64) — Recommended

This is the **most reliable setup**.

**How it works:**
- Uses **official CPU-only PyTorch wheels**
- Installed from PyTorch’s CPU wheel index
- Compatible with current Python versions

**Why this is recommended:**
- Faster installs
- Fewer dependency issues
- Best compatibility with AUTOMATIC1111
- Works reliably on Raspberry Pi 4 / 5 (64-bit OS)

✅ **If you have the choice, use a 64-bit OS.**

---

### ⚠️ ARM32 (armv7l) — Best Effort

ARM32 (32-bit Raspberry Pi OS) is supported on a **best-effort basis**.

**How ARM32 support works:**
- The installer pulls **prebuilt wheels** for:
  - `torch`
  - `torchvision`
  - (and `numpy` when available)
- Wheels are sourced from:
  **PINTO0309 / pytorch4raspberrypi**
- The script dynamically matches:
  - CPU architecture (`armv7l`)
  - Python version (e.g. `cp39`, `cp310`)

**Important limitations:**
- Not all Python versions have matching ARM32 wheels
- Performance is significantly slower than ARM64
- Memory pressure is higher on 32-bit systems

**If matching wheels are NOT available:**
- The installer will **stop with a clear error**
- You should switch to a **64-bit OS** (recommended path)

> ⚠️ **ARM32 is not recommended for long-term or production use.**

---

## 🧰 System Requirements

### Minimum
- Raspberry Pi 4 / 5 (or other ARM SBC)
- 4 GB RAM (8 GB recommended)
- 64-bit OS strongly recommended
- Internet connection (for install)

### Required Packages
- `python3`
- `python3-venv`
- `git`
- `curl`
- `wget`

---

## 🚀 Installation

Clone this repository and run the setup script:

```bash
git clone https://github.com/comp6062/arm64-automatic1111.git
cd arm64-automatic1111
chmod +x setup_sd.sh
./setup_sd.sh
```

The script will:
- Detect ARM64 vs ARM32 automatically
- Install the correct PyTorch build
- Create a virtual environment
- Download required models
- Generate launch and uninstall scripts

---

## ▶️ Running Stable Diffusion

After installation, start the WebUI with:

```bash
~/run_sd.sh
```

You will be prompted to choose:

1. **LAN Mode** – accessible from other devices on your network  
2. **Offline Mode** – localhost only  
3. **Uninstall**  
4. **Quit**

---

## 🔌 Offline Mode

Offline mode runs Stable Diffusion **without internet access**:

- Uses cached models only
- Does not install or update packages
- Accessible at:

```
http://127.0.0.1:7860
```

---

## 🧹 Uninstalling

To completely remove everything:

```bash
~/remove.sh
```

This removes:
- Stable Diffusion WebUI
- Python virtual environment
- Run and uninstall scripts

---

## ⚠️ Known Limitations

- **CPU-only inference** (no GPU acceleration)
- ARM32 is slower and less stable
- Large models may exceed memory on 4 GB systems
- First generation can take several minutes on Pi hardware

---

## 🙏 Credits

- AUTOMATIC1111 – Stable Diffusion WebUI
- PyTorch Team – CPU wheel support
- PINTO0309 – Raspberry Pi PyTorch ARM32 wheels
- Raspberry Pi community contributors

---

## ⭐ Recommendation Summary

| Architecture | Status |
|-------------|--------|
| ARM64 (aarch64) | ✅ Fully supported (recommended) |
| ARM32 (armv7l) | ⚠️ Best effort only |

**If something fails on ARM32, switch to a 64-bit OS.**  
That is the intended and supported upgrade path.
