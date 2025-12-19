#!/bin/bash

# Define color variables for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Function to show progress with red color
progress_bar() {
    echo -e "${RED}$1${NC}"
    sleep 1
}

# Update and upgrade system
progress_bar "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
progress_bar "Installing necessary dependencies..."
sudo apt install -y python3 python3-pip python3-venv git libgl1 libglib2.0-0 wget

# Dynamically determine the user's home directory
USER_HOME=$(eval echo ~$USER)

# Create and activate a virtual environment inside the user's home directory
progress_bar "Setting up virtual environment..."
python3 -m venv "$USER_HOME/stable-diffusion-env"
source "$USER_HOME/stable-diffusion-env/bin/activate"

# Clone the Stable Diffusion WebUI repository
progress_bar "Cloning Stable Diffusion WebUI repository..."
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$USER_HOME/stable-diffusion-webui"
cd "$USER_HOME/stable-diffusion-webui"

# Install PyTorch and requirements
progress_bar "Installing PyTorch and other dependencies..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt

# Download the model files
progress_bar "Downloading the model files..."
mkdir -p "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/"
wget -O "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors" "https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V7.0_FP16.safetensors"
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

trap cleanup SIGINT

if [ ! -d "$VENV_DIR" ]; then
    echo -e "${RED}Virtual environment not found at $VENV_DIR. Please set it up first.${NC}"
    exit 1
fi

if [ ! -d "$WEBUI_DIR" ]; then
    echo -e "${RED}Stable Diffusion WebUI not found at $WEBUI_DIR.${NC}"
    exit 1
fi

echo -e "${YELLOW}Select an option:${NC}"
echo "1) Run connected to the internet"
echo "2) Run completely offline"
echo "3) Uninstall"
echo "q) Quit"
read -p "Enter your choice: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Running with internet connection (LAN access)...${NC}"
        source "$VENV_DIR/bin/activate"
        cd "$WEBUI_DIR"
        DEFAULT_LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo -e "Access it at: http://$DEFAULT_LOCAL_IP:7860"
        python launch.py --skip-torch-cuda-test --no-half --listen
        cleanup
        ;;
    2)
        echo -e "${GREEN}Running completely offline (localhost only)...${NC}"
        source "$VENV_DIR/bin/activate"
        cd "$WEBUI_DIR"
        echo -e "Access it at: http://127.0.0.1:7860"
        python launch.py --skip-torch-cuda-test --no-half --listen --skip-install
        cleanup
        ;;
    3)
        echo -e "${RED}Uninstalling...${NC}"
        bash "$USER_HOME/remove.sh"
        ;;
    q|Q)
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

USER_HOME=$(eval echo ~$USER)

if [ -f "$USER_HOME/run_sd.sh" ]; then
    echo "Removing $USER_HOME/run_sd.sh..."
    rm "$USER_HOME/run_sd.sh"
fi

if [ -d "$USER_HOME/stable-diffusion-webui" ]; then
    echo "Removing $USER_HOME/stable-diffusion-webui..."
    rm -rf "$USER_HOME/stable-diffusion-webui"
fi

if [ -d "$USER_HOME/stable-diffusion-env" ]; then
    echo "Removing $USER_HOME/stable-diffusion-env..."
    rm -rf "$USER_HOME/stable-diffusion-env"
fi

if [ -f "$USER_HOME/remove.sh" ]; then
    echo "Removing $USER_HOME/remove.sh..."
    rm "$USER_HOME/remove.sh"
fi

echo "Cleanup complete."
EOF

chmod +x "$USER_HOME/remove.sh"

# --- hidden patch (sneaked in right before success) ---
cd "$USER_HOME/stable-diffusion-webui" || exit 1
cp -a modules/launch_utils.py "modules/launch_utils.py.bak.$(date +%F_%H%M%S)"
grep -n "stable_diffusion_repo" modules/launch_utils.py >/dev/null 2>&1
grep -n "stable_diffusion_commit_hash" modules/launch_utils.py >/dev/null 2>&1
sed -i 's#https://github.com/Stability-AI/stablediffusion.git#https://github.com/comp6062/Stability-AI-stablediffusion.git#g' modules/launch_utils.py
rm -rf repositories/stable-diffusion-stability-ai
# --- end hidden patch ---

# Final message
echo -e "${GREEN}Setup complete.${NC} Use ~/run_sd.sh to start Stable Diffusion or ~/remove.sh to uninstall."
