# ⭐ Stable Diffusion Automatic1111 (ARM64) — Full Installer  
### CPU-Only • ARM64 • Raspberry Pi Ready • Fully Automated

![Platform](https://img.shields.io/badge/Platform-ARM64-blue)
![Pi](https://img.shields.io/badge/Raspberry%20Pi-4%20%7C%205-red)
![CPU-Only](https://img.shields.io/badge/Backend-CPU--Only-green)
![A1111](https://img.shields.io/badge/WebUI-AUTOMATIC1111-orange)
![Installer](https://img.shields.io/badge/Installer-Fully%20Automated-success)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A completely automated ARM64 installer for **AUTOMATIC1111 Stable Diffusion WebUI (CPU-only)** with full API support, offline/online launch modes, automatic model downloads, and clean uninstall options.

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
   - [Unified Launcher (`run_sd.sh`)](#2-unified-launcher-run_sdsh-with-api-on)  
   - [Automatic Model Installation](#3-models-installed-automatically)  
3. [Installation](#installation)  
4. [API Details](#api-details)  
5. [Uninstall](#uninstall)  
6. [Summary](#summary)

---

# Overview

This project provides a **fully automated, zero-input setup** for:

- AUTOMATIC1111 Stable Diffusion WebUI (CPU-only ARM64)
- Unified launcher with online/offline modes **and API enabled**
- Automatic realism & inpainting model installation
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
- Downloads realism & inpainting models  
- Enables API mode automatically  

No configuration needed.

---

## 2. Unified Launcher (`~/run_sd.sh`) with API ON

Start Stable Diffusion anytime with:

```bash
~/run_sd.sh
```

Menu:

```text
1) Run connected to the internet (LAN mode, API ON)
2) Run completely offline (local mode, API ON)
3) Uninstall
4) Quit
```

### Mode 1 — LAN Mode:

```bash
python launch.py --skip-torch-cuda-test --no-half --listen --api
```

- Activates the venv  
- Binds to all interfaces so other devices on your LAN can access it  
- Prints:
  - `Access it at: http://<your_local_ip>:7860`
  - `API endpoint:  http://<your_local_ip>:7860/sdapi/v1/...`

### Mode 2 — Offline Mode:

```bash
python launch.py --skip-torch-cuda-test --no-half --api
```

- Activates the venv  
- Binds to `127.0.0.1` only  
- Prints:
  - `Access it at: http://127.0.0.1:7860`
  - `API endpoint:  http://127.0.0.1:7860/sdapi/v1/...`

### Mode 3 — Uninstall

- Calls the uninstall script created by the installer  
- Removes the Stable Diffusion WebUI directory  
- Removes the virtual environment  
- Removes the launcher script  

### Mode 4 — Quit

- Exits without launching anything.

---

## 3. Models Installed Automatically

Installer downloads:

- `Realistic_Vision_V5.1-inpainting.safetensors`
- `CyberRealistic_V7.0_FP16.safetensors`

If `CyberRealistic_V7.0_FP16.safetensors` becomes corrupted or partially downloaded, A1111 may show safetensors errors.

You may safely remove the broken file with:

```bash
rm ~/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors
```

This does not affect normal operation when using the Realistic Vision inpainting model.

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

- Install system dependencies  
- Create a Python virtual environment  
- Clone AUTOMATIC1111’s WebUI  
- Install Python requirements  
- Download models  
- Create `~/run_sd.sh` (with API-enabled modes)  

---

# API Details

The launcher starts A1111 with `--api` enabled in both modes.

Test the API by visiting:

```text
http://127.0.0.1:7860/sdapi/v1/sd-models
```

(or replace `127.0.0.1` with your LAN IP if running in mode 1).

If you see JSON, the API is working.

---

# Uninstall

Uninstall everything:

```bash
~/run_sd.sh
# choose option 3
```

This removes:

- Stable Diffusion WebUI  
- Python virtual environment  
- Launcher script  

No system files outside the project directory are touched.

---

# Summary

This repo provides:

- Fully automated A1111 ARM64 installer  
- CPU-only support  
- Unified launcher with offline and LAN modes  
- API-ready environment  
- Automatic model installs  
- Clean uninstall options  
