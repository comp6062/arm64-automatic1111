# Stable Diffusion Automatic1111 (ARM64) — Full Installer + Outpaint Helper

This project provides a fully automated, zero-input installation of:

- AUTOMATIC1111 Stable Diffusion WebUI (CPU-only, ARM64)
- Unified launcher script (`run_sd.sh`) with Internet/offline modes **and API enabled**
- Automatic model installation
- SD Outpaint Helper — a local GUI tool for simple outpainting using A1111’s API
- Clean uninstall options for both A1111 and the helper

Designed for:

- Raspberry Pi 4 / 5
- ARM64 SBCs
- Systems without GPU acceleration
- Users who want a simple, repeatable installation of Stable Diffusion on ARM

## Features

### 1. Fully Automated A1111 Installation (CPU-only, ARM64)

The installer:

- Creates a Python virtual environment
- Clones AUTOMATIC1111 Stable Diffusion WebUI
- Installs CPU-compatible Python dependencies
- Installs required system packages
- Downloads models automatically
- Enables API support by default via the launcher

No manual configuration required.

### 2. Unified Launcher (`~/run_sd.sh`) with API ON

After installation, start A1111 using:

```bash
~/run_sd.sh
```

You’ll see a menu:

```text
1) Run connected to the internet (http://Local_IP:7860, API ON)
2) Run completely offline (127.0.0.1:7860, API ON)
3) Uninstall
4) Quit
```

Mode 1 — LAN mode:

- Activates the venv
- Runs the WebUI with:

  ```bash
  python launch.py --skip-torch-cuda-test --no-half --listen --api
  ```

- Binds to all interfaces so other devices on your LAN can access it
- Prints:

  - `Access it at: http://<your_local_ip>:7860`
  - `API endpoint:  http://<your_local_ip>:7860/sdapi/v1/...`

Mode 2 — Offline mode:

- Activates the venv
- Runs the WebUI with:

  ```bash
  python launch.py --skip-torch-cuda-test --no-half --api
  ```

- Binds to `127.0.0.1` only (local-only)
- Prints:

  - `Access it at: http://127.0.0.1:7860`
  - `API endpoint:  http://127.0.0.1:7860/sdapi/v1/...`

Mode 3 — Uninstall A1111:

- Calls the uninstall script created by the installer
- Removes the Stable Diffusion WebUI directory
- Removes the virtual environment
- Removes the helper run/uninstall scripts created by that flow

Mode 4 — Quit:

- Exits without launching anything.

### 3. SD Outpaint Helper

A local GUI application that talks to your A1111 instance via API and simplifies outpainting.

It lets you:

- Load an image from disk
- Add padding on any side (top / bottom / left / right)
- Automatically create an expanded canvas and mask
- Call `/sdapi/v1/img2img` on your local A1111
- Save the outpainted result as a new PNG
- Control sampler, steps, CFG scale, and denoising strength
- Edit prompt and negative prompt

The helper expects A1111 to be running at:

```text
http://127.0.0.1:7860
```

You can run it with:

```bash
sd-outpaint
```

To uninstall just the helper:

```bash
sudo sd-outpaint --uninstall
```

### 4. Models Installed Automatically

By default, the installer downloads:

- `Realistic_Vision_V5.1-inpainting.safetensors`
- `CyberRealistic_V7.0_FP16.safetensors`

If `CyberRealistic_V7.0_FP16.safetensors` is corrupted or partially downloaded, A1111 may show safetensors errors. This does not affect the helper if you are using the Realistic Vision inpainting model.

You can remove the broken file with:

```bash
rm ~/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors
```

## Installation

You can install everything (A1111 + Outpaint Helper) with:

```bash
curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```

or:

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

## Using SD Outpaint Helper

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

## API Details

The launcher starts A1111 with `--api` enabled in both modes.

You can test the API by visiting:

```text
http://127.0.0.1:7860/sdapi/v1/sd-models
```

(or replace `127.0.0.1` with your LAN IP if running in mode 1).

If you see JSON, the API is working.

## Uninstall

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

## Summary

This repository provides:

- A fully automated installer for AUTOMATIC1111 Stable Diffusion WebUI on ARM64 (CPU-only)
- A unified launcher script with Internet/offline modes and API support
- A local SD Outpaint Helper GUI
- Automatic model downloads
- Clean uninstall options
