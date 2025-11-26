#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

progress_bar() {
    local msg="$1"
    echo -ne "${YELLOW}${msg}...${NC}\r"
}

USER_HOME=$(eval echo ~$SUDO_USER)
if [ -z "$USER_HOME" ]; then
    USER_HOME=$(eval echo ~$USER)
fi

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run this script with sudo:${NC}"
    echo "  sudo bash setup_sd.sh"
    exit 1
fi

echo -e "${GREEN}Starting Stable Diffusion WebUI setup...${NC}"

# Update system packages
progress_bar "Updating system packages"
apt update && apt upgrade -y > /dev/null 2>&1
echo -e "${GREEN}System packages updated.${NC}"

# Install dependencies
progress_bar "Installing dependencies"
apt install -y python3 python3-venv python3-pip git wget curl libffi-dev libssl-dev libjpeg-dev zlib1g-dev > /dev/null 2>&1
echo -e "${GREEN}Dependencies installed.${NC}"

# Create a dedicated environment folder
VENV_DIR="$USER_HOME/stable-diffusion-env"
if [ ! -d "$VENV_DIR" ]; then
    progress_bar "Creating Python virtual environment"
    sudo -u "$SUDO_USER" python3 -m venv "$VENV_DIR"
    echo -e "${GREEN}Virtual environment created at $VENV_DIR.${NC}"
else
    echo -e "${YELLOW}Virtual environment already exists at $VENV_DIR. Skipping creation.${NC}"
fi

# Activate the environment and install PyTorch CPU and other requirements
progress_bar "Installing PyTorch (CPU) and web UI requirements"
sudo -u "$SUDO_USER" bash -c "
source \"$VENV_DIR/bin/activate\" && \
pip install --upgrade pip > /dev/null 2>&1 && \
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu > /dev/null 2>&1
"
echo -e "${GREEN}PyTorch CPU installed.${NC}"

# Clone Stable Diffusion WebUI
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
if [ ! -d "$WEBUI_DIR" ]; then
    progress_bar "Cloning Stable Diffusion WebUI repository"
    sudo -u "$SUDO_USER" git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$WEBUI_DIR" > /dev/null 2>&1
    echo -e "${GREEN}Stable Diffusion WebUI cloned to $WEBUI_DIR.${NC}"
else
    echo -e "${YELLOW}Stable Diffusion WebUI already exists at $WEBUI_DIR. Skipping clone.${NC}"
fi

# Install WebUI requirements
progress_bar "Installing WebUI Python requirements"
sudo -u "$SUDO_USER" bash -c "
source \"$VENV_DIR/bin/activate\" && \
cd \"$WEBUI_DIR\" && \
pip install -r requirements.txt > /dev/null 2>&1
"
echo -e "${GREEN}WebUI requirements installed.${NC}"

# Download the model files
progress_bar "Downloading the model files..."
mkdir -p "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/"
wget -O "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors" "https://huggingface.co/Cyberhybrid/CyberRealistic/resolve/main/CyberRealistic_V7.0_FP16.safetensors"
wget -O "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/Realistic_Vision_V5.1-inpainting.safetensors" "https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1-inpainting.safetensors"

# Create the unified run_sd.sh script
progress_bar "Creating run_sd.sh script..."
cat <<'EOF' > "$USER_HOME/run_sd.sh"
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

USER_HOME=$(eval echo ~$USER)
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"

cleanup() {
    echo -e "${YELLOW}Stopping Stable Diffusion...${NC}"
    pkill -f "launch.py" 2>/dev/null
    deactivate 2>/dev/null
    echo -e "${YELLOW}Virtual environment deactivated.${NC}"
    exit
}

# CTRL+C will call cleanup()
trap cleanup SIGINT

# Basic checks
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${RED}Virtual environment not found at $VENV_DIR. Please set it up first.${NC}"
    exit 1
fi

if [ ! -d "$WEBUI_DIR" ]; then
    echo -e "${RED}Stable Diffusion WebUI not found at $WEBUI_DIR.${NC}"
    exit 1
fi

echo -e "${YELLOW}Select an option:${NC}"
echo "1) Run connected to the internet (http://Local_IP:7860, API ON)"
echo "2) Run completely offline (127.0.0.1:7860, API ON)"
echo "3) Uninstall"
echo "4) Quit"
read -p "Enter your choice: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Running with internet connection (LAN access) and API enabled...${NC}"
        source "$VENV_DIR/bin/activate"
        cd "$WEBUI_DIR"
        DEFAULT_LOCAL_IP=\$(hostname -I | awk '{print \$1}')
        echo -e "Access it at: http://\$DEFAULT_LOCAL_IP:7860"
        echo -e "API endpoint:  http://\$DEFAULT_LOCAL_IP:7860/sdapi/v1/..."
        python launch.py --skip-torch-cuda-test --no-half --listen --api
        cleanup
        ;;
    2)
        echo -e "${GREEN}Running completely offline (localhost only) with API enabled...${NC}"
        source "$VENV_DIR/bin/activate"
        cd "$WEBUI_DIR"
        echo -e "Access it at: http://127.0.0.1:7860"
        echo -e "API endpoint:  http://127.0.0.1:7860/sdapi/v1/..."
        python launch.py --skip-torch-cuda-test --no-half --skip-install --api
        cleanup
        ;;
    3)
        echo -e "${RED}Uninstalling...${NC}"
        bash "$USER_HOME/remove.sh"
        ;;
    4)
        echo -e "${YELLOW}Quitting.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting.${NC}"
        exit 1
        ;;
esac
EOF

chmod +x "$USER_HOME/run_sd.sh"

# Create the remove.sh script
progress_bar "Creating remove.sh script..."
cat <<'EOF' > "$USER_HOME/remove.sh"
#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

USER_HOME=$(eval echo ~$USER)
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"

echo -e "${YELLOW}This will remove Stable Diffusion WebUI and its environment from:${NC}"
echo "  $WEBUI_DIR"
echo "  $VENV_DIR"
read -p "Are you sure? [y/N]: " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Removing Stable Diffusion WebUI...${NC}"
    rm -rf "$WEBUI_DIR"
    echo -e "${RED}Removing virtual environment...${NC}"
    rm -rf "$VENV_DIR"
    echo -e "${GREEN}Uninstallation complete.${NC}"
else
    echo -e "${YELLOW}Uninstallation cancelled.${NC}"
fi
EOF

chmod +x "$USER_HOME/remove.sh"

echo -e "${GREEN}Setup complete.${NC} Use ~/run_sd.sh to start Stable Diffusion or ~/remove.sh to uninstall."
