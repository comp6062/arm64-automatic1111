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
