Run the Setup Script Remotely
To execute the script remotely:

Using curl:
```bash

curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```
Using wget:
```bash
wget -qO- https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/setup_sd.sh | bash
```
3. Usage
After the script completes, run Stable Diffusion with:

```bash
~/run_sd.sh
```
This approach automates the setup and provides a seamless way to install and manage Stable Diffusion remotely.



To uninstall: 

Using curl:
```bash
bash <(curl -sSL https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/remove_sd.sh)
```
Using wget:
```bash
bash <(wget -qO- https://raw.githubusercontent.com/comp6062/arm64-automatic1111/main/remove_sd.sh)
```
What It Does:
Stops any running Stable Diffusion processes.
Deletes:
Virtual environment (~/stable-diffusion-env).
WebUI directory (~/stable-diffusion-webui).
Run script (~/run_sd.sh).
Optionally removes installed dependencies (python3, git, etc.).
Runs apt autoremove to clean up any residual packages.
This ensures a clean system without leftover files or dependencies.
