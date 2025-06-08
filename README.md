Install Stable Diffusion on a Raspberry Pi.

This script fully automates the installation of AUTOMATIC1111's Stable Diffusion WebUI on a Raspberry Pi (optimized for Pi 5 with 64-bit OS). It sets up everything needed to run Stable Diffusion in CPU mode, including dependencies, models, a Python virtual environment, and convenient launch/uninstall scripts.

🧰 What This Script Does:
✅ Updates and upgrades your system

✅ Installs all necessary packages and Python tools

✅ Sets up a dedicated Python virtual environment for Stable Diffusion

✅ Clones the Stable Diffusion WebUI from GitHub

✅ Installs PyTorch (CPU-only) and all required Python libraries

✅ Downloads two pre-configured models:

CyberRealistic V7.0

Realistic Vision V5.1 (Inpainting)

✅ Creates two helper scripts:

run_sd.sh – A user-friendly menu to run Stable Diffusion either:

With internet (LAN access)

Completely offline (localhost only)

Or uninstall the setup

remove.sh – Cleanly removes all installed files and environments

🚀 How to Use After Installation
Run:


~/run_sd.sh
Choose how you want to launch Stable Diffusion. Access the WebUI via your browser on port 7860.


⚠️ Notes:
This version runs on CPU only (no GPU acceleration).

Best performance on Raspberry Pi 5 with active cooling and enough RAM.

First-time startup may take several minutes.


1. Run the Setup Script:

Using curl:
```bash

curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```
Using wget:
```bash
wget -qO- https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```
2. After the script completes, to run Stable Diffusion use:

```bash
~/run_sd.sh
```
