# ⭐ Stable Diffusion Automatic1111 (ARM64) — Full Installer  
### CPU-Only • ARM64 • Raspberry Pi Ready • Fully Automated

![Platform](https://img.shields.io/badge/Platform-ARM64-blue)
![Pi](https://img.shields.io/badge/Raspberry%20Pi-4%20%7C%205-red)
![CPU-Only](https://img.shields.io/badge/Backend-CPU--Only-green)
![A1111](https://img.shields.io/badge/WebUI-AUTOMATIC1111-orange)
![Installer](https://img.shields.io/badge/Installer-Fully%20Automated-success)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A completely automated ARM64 installer for **AUTOMATIC1111 Stable Diffusion WebUI (CPU-only)** with offline/online launch modes, automatic model downloads, and clean uninstall options.

Designed for:

- Raspberry Pi 4 / 5  
- ARM64 SBCs  
- CPU-only environments  
- Users who want a simple, repeatable, zero-input Stable Diffusion setup  

---

# 📚 Table of Contents
1. [Overview](#overview)  
2. [Features](#features)  
   - [Automated A1111 Installation](#1-fully-automated-a1111-installation-cpu-only-arm64)  
   - [Unified Launcher (`run_sd.sh`)](#2-unified-launcher-runsdsh)  
   - [Automatic Model Installation](#3-models-installed-automatically)  
3. [Installation](#installation)  
4. [Running Stable Diffusion](#running-stable-diffusion)  
5. [Uninstall](#uninstall)  
6. [Summary](#summary)

---

# Overview

This project provides a **fully automated, zero-input setup** for:

- AUTOMATIC1111 Stable Diffusion WebUI (CPU-only ARM64)
- Unified launcher with online and offline modes
- Automatic inpainting & realism model installation
- Clean uninstall scripts

Everything works completely offline after install.

---

# Features

## 1. Fully Automated A1111 Installation (CPU-only, ARM64)

The installer:

- Creates a Python virtual environment  
- Clones A1111 Stable Diffusion WebUI  
- Installs CPU-only dependencies  
- Installs required system packages  
- Downloads supported models  

No configuration needed.

---

## 2. Unified Launcher (`~/run_sd.sh`)

Start Stable Diffusion anytime with:

```bash
~/run_sd.sh
```

Menu:

```text
1) Run connected to the internet (LAN mode)
2) Run completely offline (local mode)
3) Uninstall
4) Quit
```

### Mode 1 — LAN Mode:

```bash
python launch.py --skip-torch-cuda-test --no-half --listen
```

- Activates the venv  
- Binds to all interfaces so other devices on your LAN can access it  
- Prints the local access URL  

### Mode 2 — Offline Mode:

```bash
python launch.py --skip-torch-cuda-test --no-half
```

- Activates the venv  
- Binds to `127.0.0.1` only  
- Fully offline operation  

### Mode 3 — Uninstall

- Calls the uninstall script created by the installer  
- Removes the Stable Diffusion WebUI directory  
- Removes the virtual environment  
- Removes launcher scripts  

### Mode 4 — Quit

- Exits without launching anything.

---

## 3. Models Installed Automatically

Installer downloads:

- `Realistic_Vision_V5.1-inpainting.safetensors`
- `CyberRealistic_V7.0_FP16.safetensors`

If `CyberRealistic_V7.0_FP16.safetensors` becomes corrupted or partially downloaded, A1111 may show safetensors errors.

Remove the broken file with:

```bash
rm ~/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors
```

---

# Installation

Install everything with:

```bash
curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```

Or:

```bash
wget -qO- https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```

The script will:

- Install dependencies  
- Create a Python virtual environment  
- Clone AUTOMATIC1111’s WebUI  
- Install Python requirements  
- Download models  
- Create `~/run_sd.sh`  

---

# Running Stable Diffusion

1. Launch Stable Diffusion:

```bash
~/run_sd.sh
```

2. Choose LAN or Offline mode.
3. Open the printed URL in your browser.
4. Begin generating images.

---

# Uninstall

Uninstall everything:

```bash
~/run_sd.sh
# choose option 3
```

This removes:

- Stable Diffusion WebUI directory  
- Python virtual environment  
- Launcher scripts  

---

# Summary

This repo provides:

- Fully automated A1111 ARM64 installer  
- CPU-only support  
- Unified launcher with offline and LAN modes  
- Automatic model installs  
- Full uninstall options  
