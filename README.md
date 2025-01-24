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

To Uninstall run: 

```bash
~/remove.sh
```


-----------------------------------------------------------------------------------------------------------------------



Features:
System Update and Dependency Installation:

Updates the system and installs required packages such as Python, Git, and libraries for Stable Diffusion.
Virtual Environment Setup:

Creates a Python virtual environment for isolating the Stable Diffusion WebUI dependencies.
Cloning the Stable Diffusion Repository:

Downloads the Stable Diffusion WebUI code from GitHub.
Installing PyTorch and Requirements:

Installs the CPU-only version of PyTorch along with other required Python packages.
Model Download:

Downloads a specific Stable Diffusion model file (cyberrealistic_v7.safetensors) to the appropriate directory.
Run Script:

Generates a script ~/run_sd.sh that allows users to:
Run the WebUI locally (127.0.0.1:7860), or 
host the WebUI on the local network for remote access.


Uninstall Script:

Creates a ~/remove.sh script for completely uninstalling Stable Diffusion WebUI and cleaning up associated files and directories.
Setup Completion:

Provides the user with instructions to start or remove the setup.


!!Warning:
File Size and Download Times: This script downloads a model file (cyberrealistic_v7.safetensors) which may be several gigabytes in size. Depending on your internet connection, the download could take a significant amount of time. Ensure you have enough disk space and a stable internet connection before proceeding.!!




