⭐ Stable Diffusion Automatic1111 (ARM64) — Full Installer + Outpaint Helper
CPU-Only • ARM64 • Raspberry Pi Ready • Fully Automated














A completely automated ARM64 installer for AUTOMATIC1111 Stable Diffusion WebUI (CPU-only) plus the SD Outpaint Helper GUI, with full API support, offline/online launch modes, automatic model downloads, and clean uninstall options.

Designed for:

Raspberry Pi 4 / 5

ARM64 SBCs

CPU-only environments

Users who want a simple, repeatable, zero-input Stable Diffusion setup

📚 Table of Contents

Overview

Features

Automated A1111 Installation

Unified Launcher (run_sd.sh)

Outpaint Helper GUI

Automatic Model Installation

Installation

Using SD Outpaint Helper

API Details

Uninstall

Outpaint Helper — Full Feature Reference

Base Image

Padding

Parameters

Prompts

Masking Logic

Saving

Errors

Uninstall Helper

Summary

Overview

This project provides a fully automated, zero-input setup for:

AUTOMATIC1111 Stable Diffusion WebUI (CPU-only ARM64)

Unified launcher with online/offline modes and API enabled

Automatic Realistic Vision inpainting model install

Local Outpaint Helper GUI tool

Clean uninstall scripts for both A1111 and the helper

Everything works completely offline after install.

Features
1. Fully Automated A1111 Installation (CPU-only, ARM64)

The installer:

Creates a Python virtual environment

Clones A1111 Stable Diffusion WebUI

Installs CPU-only dependencies

Installs required system packages

Downloads inpainting & realism models

Enables API mode automatically

No configuration needed.

2. Unified Launcher (~/run_sd.sh) with API ON

Start Stable Diffusion anytime with:

~/run_sd.sh


Menu:

1) Run connected to the internet (LAN mode, API ON)
2) Run completely offline (local mode, API ON)
3) Uninstall
4) Quit

Mode 1 — LAN Mode:
python launch.py --skip-torch-cuda-test --no-half --listen --api


Accessible from any device on your network.

Mode 2 — Offline Mode:
python launch.py --skip-torch-cuda-test --no-half --api


Runs STRICTLY on 127.0.0.1.

Mode 3 — Uninstall

Removes the entire A1111 installation.

3. SD Outpaint Helper

A standalone GUI app that:

Loads images

Adds padding on any side

Auto-generates masks

Sends img2img inpainting requests to A1111

Saves generated outpaints

Run it with:

sd-outpaint


Uninstall it with:

sudo sd-outpaint --uninstall

4. Models Installed Automatically

Installer downloads:

Realistic_Vision_V5.1-inpainting.safetensors

CyberRealistic_V7.0_FP16.safetensors

If CyberRealistic becomes corrupted, remove it:

rm ~/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors

Installation

Install everything with:

curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash


Or:

wget -qO- https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash


The script:

Installs dependencies

Clones A1111

Creates a venv

Installs requirements

Downloads models

Installs Outpaint Helper to /opt/sd-outpaint

Creates launchers and desktop shortcuts

Using SD Outpaint Helper

Start A1111:

~/run_sd.sh


Run the helper:

sd-outpaint


In the GUI:

Load image

Set padding

Adjust sampler / steps / CFG / denoise

Edit prompts

Click Generate Outpaint

Save result

API Details

A1111 runs with:

--api


Test API:

http://127.0.0.1:7860/sdapi/v1/sd-models


Produces JSON if working.

Uninstall
Remove A1111:
~/run_sd.sh   # choose option 3

Remove Outpaint Helper:
sudo sd-outpaint --uninstall

Remove both:

Run both commands above.

📘 Outpaint Helper – Full Feature Reference & Usage Guide

Below is the entire detailed guide — reorganized but unchanged in meaning.

🎨 Overview

The Outpaint Helper allows you to:

Load an image

Add padding

Automatically generate masks

Send img2img inpaint requests

Save results

API endpoint used:

http://127.0.0.1:7860/sdapi/v1/img2img


A1111 must be running.

🖼️ Base Image Section
Load Image…

Supports: PNG, JPG, JPEG, WEBP, BMP.

Displays:

File path

Original resolution

Enables Generate button

📏 Padding (Outpaint Area)

Controls added canvas around your image.

Field	Purpose
Top	Add space above
Bottom	Add space below
Left	Extend left
Right	Extend right

Padding is in pixels.

🧠 Stable Diffusion Parameters
Sampler

Recommended: Euler a

Steps

20–40 typical.

CFG Scale

7.0 ideal.

Denoising Strength

0.45–0.60 for stable outpaints.

✏️ Prompts
Default Prompt:
seamless extension of the scene, same style, same lighting, highly detailed, outpaint background

Default Negative Prompt:
lowres, blurry, distorted, deformed, bad anatomy, artifacts, watermark, text

🖌️ Internal Logic

When generating:

Canvas padded

Mask created

Base64 encoded

Sent to /sdapi/v1/img2img

Result decoded and saved

💾 Saving

Save dialog appears

PNG output

Cancelling keeps result until overwritten

🚫 Error Handling

Alerts for:

SD not running

Bad padding

Bad connection

Invalid images

Runtime errors

Status bar shows warnings and progress.

🧹 Uninstalling the Helper
sudo sd-outpaint --uninstall


Removes:

/opt/sd-outpaint

/usr/local/bin/sd-outpaint

/usr/share/applications/sd-outpaint.desktop

Summary

This repo provides:

Fully automated A1111 ARM64 installer

CPU-only support

Unified launcher with offline mode

API-ready environment

Outpaint Helper GUI

Automatic model installs

Full uninstall options
