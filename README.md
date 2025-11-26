# ⭐ Stable Diffusion Automatic1111 (ARM64) — Full Installer + Outpaint Helper  
### CPU-Only • ARM64 • Raspberry Pi Ready • Fully Automated

![Platform](https://img.shields.io/badge/Platform-ARM64-blue)
![Pi](https://img.shields.io/badge/Raspberry%20Pi-4%20%7C%205-red)
![CPU-Only](https://img.shields.io/badge/Backend-CPU--Only-green)
![A1111](https://img.shields.io/badge/WebUI-AUTOMATIC1111-orange)
![Outpaint](https://img.shields.io/badge/Feature-Outpaint%20Helper-purple)
![Installer](https://img.shields.io/badge/Installer-Fully%20Automated-success)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

A completely automated ARM64 installer for **AUTOMATIC1111 Stable Diffusion WebUI (CPU-only)** plus the **SD Outpaint Helper GUI**, with full API support, offline/online launch modes, automatic model downloads, and clean uninstall options.

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
   - [Unified Launcher (`run_sd.sh`)](#2-unified-launcher-runsdsh-with-api-on)  
   - [Outpaint Helper GUI](#3-sd-outpaint-helper)  
   - [Automatic Model Installation](#4-models-installed-automatically)  
3. [Installation](#installation)  
4. [Using SD Outpaint Helper](#using-sd-outpaint-helper)  
5. [API Details](#api-details)  
6. [Uninstall](#uninstall)  
7. [Outpaint Helper — Full Feature Reference](#-outpaint-helper--full-feature-reference--usage-guide)  
   - Base Image  
   - Padding  
   - Parameters  
   - Prompts  
   - Masking Logic  
   - Saving  
   - Errors  
   - Uninstall Helper  
8. [Summary](#summary)

---

# Overview

This project provides a **fully automated, zero-input setup** for:

- AUTOMATIC1111 Stable Diffusion WebUI (CPU-only ARM64)
- Unified launcher with online/offline modes **and API enabled**
- Automatic Realistic Vision inpainting model install
- Local Outpaint Helper GUI tool
- Clean uninstall scripts for both A1111 and the helper

Everything works completely offline after install.

---

# Features

## 1. Fully Automated A1111 Installation (CPU-only, ARM64)

The installer:

- Creates a Python virtual environment  
- Clones A1111 Stable Diffusion WebUI  
- Installs CPU-only dependencies  
- Installs required system packages  
- Downloads inpainting & realism models  
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
- Removes the helper run/uninstall scripts created by that flow  

### Mode 4 — Quit

- Exits without launching anything.

---

## 3. SD Outpaint Helper

A standalone GUI app that:

- Loads images  
- Adds padding on any side  
- Auto-generates masks  
- Sends img2img inpainting requests to A1111  
- Saves generated outpaints  

The helper expects A1111 to be running at:

```text
http://127.0.0.1:7860
```

Run it with:

```bash
sd-outpaint
```

Uninstall just the helper:

```bash
sudo sd-outpaint --uninstall
```

---

## 4. Models Installed Automatically

Installer downloads:

- `Realistic_Vision_V5.1-inpainting.safetensors`
- `CyberRealistic_V7.0_FP16.safetensors`

If `CyberRealistic_V7.0_FP16.safetensors` becomes corrupted or partially downloaded, A1111 may show safetensors errors. This does not affect the helper if you are using the Realistic Vision inpainting model.

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
- Create `~/run_sd.sh` (with API-enabled modes)  
- Install the SD Outpaint Helper into `/opt/sd-outpaint`  
- Create the `sd-outpaint` launcher and desktop entry  

---

# Using SD Outpaint Helper

1. Start A1111 using `~/run_sd.sh` (option 1 or 2).
2. Run the helper:

   ```bash
   sd-outpaint
   ```

3. In the GUI:
   - Click **Load Image…** and select an image  
   - Set padding for top/bottom/left/right  
   - Adjust sampler, steps, CFG, and denoising  
   - Edit prompt and negative prompt  
   - Click **Generate Outpaint**  
   - Choose where to save the result  

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

Uninstall A1111 only:

```bash
~/run_sd.sh
# choose option 3
```

Uninstall Outpaint Helper only:

```bash
sudo sd-outpaint --uninstall
```

Uninstall both:

```bash
~/run_sd.sh   # option 3
sudo sd-outpaint --uninstall
```

---

# 📘 Outpaint Helper – Full Feature Reference & Usage Guide

The **SD Outpaint Helper** is a standalone local GUI that simplifies outpainting while using your existing AUTOMATIC1111 install.  
This section explains **every option, setting, and control** so users understand exactly how the tool works.

---

## 🎨 Overview

The Outpaint Helper allows you to:

- Load an existing image  
- Add **padding** on any side  
- Automatically create an expanded canvas  
- Automatically generate the **mask** required by A1111  
- Send the request to Stable Diffusion’s **img2img inpaint API**  
- Save the outpainted result  

All generation happens through:

```text
http://127.0.0.1:7860/sdapi/v1/img2img
```

Stable Diffusion **must** be running before using the helper.

---

# 🖼️ Base Image Section

## Load Image…

Opens a file picker to select your base image.  
Supported formats:

- PNG  
- JPG / JPEG  
- WEBP  
- BMP  

When the image loads:

- The file path appears  
- The original resolution is displayed (e.g., `1024 x 768`)  
- The Generate button is enabled  

---

# 📏 Padding (Outpaint Area)

This section determines **how much additional canvas to add** on each side.

| Setting | Meaning |
|--------|---------|
| **Top** | Add vertical space above the image |
| **Bottom** | Add vertical space below the image |
| **Left** | Add horizontal space on the left |
| **Right** | Add horizontal space on the right |

Padding is in **pixels**.

### Example

To extend the image only to the left and right:

```text
Top:    0
Bottom: 0
Left:   256
Right:  256
```

To extend on all sides:

```text
Top:    256
Bottom: 256
Left:   256
Right:  256
```

Padding of **0 in all fields** triggers a warning because no canvas expansion will occur.

---

# 🧠 Stable Diffusion Parameters

These directly affect the generation quality and style.

## Sampler

Determines how the model denoises during generation.  
Common options:

- **Euler a** (default – great for quick outpaint)  
- **DPM++ 2M Karras**  
- **DPM++ SDE Karras**  
- **Euler**  

For outpainting, **Euler a** is the most stable.

---

## Steps

How many denoising iterations A1111 performs.

- Typical range: **20–40**  
- Higher = more detail, slower  
- Lower = faster, less accurate  

---

## CFG Scale (Classifier-Free Guidance)

How strongly Stable Diffusion follows your prompt.

- **7.0** is ideal for outpainting  
- Lower = more like the original image  
- Higher = more forced by the prompt  

---

## Denoising Strength

Controls how much of the original image is “changed”.

- **0.45–0.60** — ideal outpainting range  
- Lower = preserves original style more  
- Higher = generates wilder variations  

---

# ✏️ Prompts

## Prompt

What you want the model to generate.  
Defaults to:

```text
seamless extension of the scene, same style, same lighting, highly detailed, outpaint background
```

This encourages continuity with the source image.

You can customize it based on the content:

- Landscapes: `wide-open scenery, matching lighting, natural background`  
- Food: `food photography, shallow depth of field, appetizing presentation`  
- Portraits: `same face, same clothes, studio lighting, continuous background`  

---

## Negative Prompt

What the model should avoid.

Defaults include:

```text
lowres, blurry, distorted, deformed, bad anatomy, artifacts, watermark, text
```

This helps suppress common outpainting errors.

---

# 🖌️ What Happens Internally (Simplified)

When you click **Generate Outpaint**:

1. A padded canvas (transparent around the edges) is created  
2. A mask is generated where:
   - **White = areas TO modify** (the padding)
   - **Black = protected original image**
3. Both are encoded to Base64  
4. An img2img request is sent to:

   ```text
   POST /sdapi/v1/img2img
   ```

5. The result is decoded and shown in a Save dialog  

Users do **not** need to manage any masks manually — the tool handles it.

---

# 💾 Saving the Final Image

After generation:

- A Save dialog appears  
- Default format: **PNG**  
- The Save button writes the processed outpainted image to disk  
- If canceled, the result is still held in memory until the next generation  

---

# 🚫 Error Handling / API Messages

The helper will show popups for:

- Stable Diffusion not running  
- Bad API connection  
- Invalid padding values  
- Corrupt images  
- Other runtime errors  

The status bar always displays:

- What the tool is doing  
- Any critical errors  

---

# 🧹 Uninstalling the Helper

Just the helper (NOT AUTOMATIC1111):

```bash
sudo sd-outpaint --uninstall
```

This removes:

- `/opt/sd-outpaint`  
- `/usr/local/bin/sd-outpaint`  
- `/usr/share/applications/sd-outpaint.desktop`  

Automatic1111 remains untouched.

---

# Summary

This repo provides:

- Fully automated A1111 ARM64 installer  
- CPU-only support  
- Unified launcher with offline and LAN modes  
- API-ready environment  
- Outpaint Helper GUI  
- Automatic model installs  
- Full uninstall options  
