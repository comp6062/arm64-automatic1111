# ⭐ Stable Diffusion AUTOMATIC1111 (ARM64) — Full Installer
### CPU-Only • ARM64 • Raspberry Pi Ready • Fully Automated

![Platform](https://img.shields.io/badge/Platform-ARM64-blue)
![Pi](https://img.shields.io/badge/Raspberry%20Pi-4%20%7C%205-red)
![CPU-Only](https://img.shields.io/badge/Backend-CPU--Only-green)
![A1111](https://img.shields.io/badge/WebUI-AUTOMATIC1111-orange)
![Installer](https://img.shields.io/badge/Installer-Fully%20Automated-success)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A **completely automated ARM64 installer** for **AUTOMATIC1111 Stable Diffusion WebUI (CPU-only)** with clean online/offline launch modes, automatic model downloads, and full uninstall support.

Designed for:

- Raspberry Pi 4 / 5  
- ARM64 SBCs  
- CPU-only environments  
- Users who want a simple, repeatable, zero-input Stable Diffusion setup  

---

## 📚 Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
   - [Fully Automated Installation](#fully-automated-installation)  
   - [Unified Launcher](#unified-launcher)  
   - [Automatic Model Installation](#automatic-model-installation)  
3. [Installation](#installation)  
4. [Running Stable Diffusion](#running-stable-diffusion)  
5. [Uninstall](#uninstall)  
6. [Summary](#summary)  

---

## Overview

This project provides a **fully automated, zero-input setup** for:

- AUTOMATIC1111 Stable Diffusion WebUI (ARM64, CPU-only)
- A unified launcher with LAN and offline modes
- Automatic model installation
- Clean uninstall support

Once installed, Stable Diffusion can be run **entirely offline**.

---

## Features

### Fully Automated Installation

The installer performs all setup steps automatically:

- Installs required system dependencies  
- Creates a Python virtual environment  
- Clones the AUTOMATIC1111 Stable Diffusion WebUI  
- Installs CPU-only Python requirements  
- Downloads supported models  
- Creates a unified launcher script  

No manual configuration is required.

---

### Unified Launcher

Stable Diffusion is launched using:

```bash
~/run_sd.sh
```

The launcher menu:

```text
1) Run connected to the internet (LAN mode)
2) Run completely offline (local mode)
3) Uninstall
4) Quit
```

#### LAN Mode

```bash
python launch.py --skip-torch-cuda-test --no-half --listen
```

- Activates the virtual environment  
- Binds to all network interfaces  
- Allows access from other devices on your LAN  
- Prints the access URL in the terminal  

#### Offline Mode

```bash
python launch.py --skip-torch-cuda-test --no-half
```

- Activates the virtual environment  
- Binds to `127.0.0.1` only  
- Requires no internet connection  

#### Quit

Exits the launcher without starting Stable Diffusion.

---

### Automatic Model Installation

The installer automatically downloads:

- `Realistic_Vision_V5.1-inpainting.safetensors`  
- `CyberRealistic_V7.0_FP16.safetensors`  

If `CyberRealistic_V7.0_FP16.safetensors` becomes corrupted or partially downloaded, AUTOMATIC1111 may show safetensors errors.

To remove the corrupted file:

```bash
rm ~/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors
```

---

## Installation

Install everything with one command:

```bash
curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```

Or:

```bash
wget -qO- https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```

The installer will:

- Install all dependencies  
- Create a Python virtual environment  
- Clone AUTOMATIC1111  
- Install Python requirements  
- Download models  
- Create `~/run_sd.sh`  

---

## Running Stable Diffusion

1. Launch the unified launcher:

```bash
~/run_sd.sh
```

2. Select LAN or Offline mode.
3. Open the printed URL in your web browser.
4. Start generating images.

---

## Uninstall

To completely remove Stable Diffusion:

```bash
~/run_sd.sh
# choose option 3
```

This removes:

- The Stable Diffusion WebUI directory  
- The Python virtual environment  
- All launcher scripts created by the installer  

---

## Summary

This repository provides:

- A fully automated ARM64 AUTOMATIC1111 installer  
- CPU-only Stable Diffusion support  
- LAN and offline execution modes  
- Automatic model installation  
- Clean uninstall support  
