#!/bin/bash

# Define color variables for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Function to show progress with red color
progress_bar() {
    echo -e "${RED}$1${NC}"
    sleep 1 # Simulating progress delay
}

# Update and upgrade system
progress_bar "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
progress_bar "Installing necessary dependencies..."
sudo apt install -y python3 python3-pip python3-venv git libgl1 libglib2.0-0

# Dynamically determine the user's home directory
USER_HOME=$(eval echo ~$USER)

# Create and activate a virtual environment inside the user's home directory
progress_bar "Setting up virtual environment..."
python3 -m venv "$USER_HOME/stable-diffusion-env"
source "$USER_HOME/stable-diffusion-env/bin/activate"

# Clone the Stable Diffusion WebUI repository inside the user's home directory
progress_bar "Cloning Stable Diffusion WebUI repository..."
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$USER_HOME/stable-diffusion-webui"
cd "$USER_HOME/stable-diffusion-webui"

# Install PyTorch and other requirements
progress_bar "Installing PyTorch and other dependencies..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt

# Download the model file
progress_bar "Downloading the model file..."
mkdir -p "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/"
wget -O "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors" "https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V7.0_FP16.safetensors"

# Create the `run_sd.sh` script
progress_bar "Creating run_sd.sh script..."
cat <<EOF > "$USER_HOME/run_sd.sh"
#!/bin/bash

# Dynamically determine the user's home directory
USER_HOME=\$(eval echo ~$USER)

# Define the paths
WEBUI_DIR="\$USER_HOME/stable-diffusion-webui"
VENV_DIR="\$USER_HOME/stable-diffusion-env"

# Function to clean up and deactivate
cleanup() {
    echo "Stopping Stable Diffusion..."
    pkill -f "launch.py" 2>/dev/null
    deactivate 2>/dev/null
    echo "Virtual environment deactivated."
    exit
}

# Trap SIGINT (Ctrl+C) to run cleanup
trap cleanup SIGINT

# Ensure the virtual environment exists
if [ ! -d "\$VENV_DIR" ]; then
    echo "Virtual environment not found at \$VENV_DIR. Please set it up first."
    exit 1
fi

# Ensure the WebUI directory exists
if [ ! -d "\$WEBUI_DIR" ]; then
    echo "Stable Diffusion WebUI directory not found at \$WEBUI_DIR."
    exit 1
fi

# Get the default local IP address
DEFAULT_LOCAL_IP=\$(hostname -I | awk '{print \$1}')

# Display menu
echo "Choose an option:"
echo "1) Run Stable Diffusion locally (127.0.0.1:7860)"
echo "2) Run Stable Diffusion remotely on local network (http://\$DEFAULT_LOCAL_IP:7860)"
read -p "Enter your choice (1 or 2): " choice

# Activate virtual environment
source "\$VENV_DIR/bin/activate"

# Change to the WebUI directory
cd "\$WEBUI_DIR"

# Run based on choice
case \$choice in
    1)
        echo "Running Stable Diffusion locally..."
        python launch.py --skip-torch-cuda-test --no-half
        ;;
    2)
        echo "Running Stable Diffusion remotely on local network (http://\$DEFAULT_LOCAL_IP:7860)..."
        python launch.py --skip-torch-cuda-test --no-half --listen
        ;;
    *)
        echo "Invalid choice. Exiting."
        deactivate
        exit 1
        ;;
esac

# Cleanup when the process ends
cleanup
EOF

chmod +x "$USER_HOME/run_sd.sh"

# Create the `remove.sh` script
progress_bar "Creating remove.sh script..."
cat <<EOF > "$USER_HOME/remove.sh"
#!/bin/bash

# Dynamically determine the user's home directory
USER_HOME=\$(eval echo ~$USER)

# Remove the file \$USER_HOME/run_sd.sh
if [ -f "\$USER_HOME/run_sd.sh" ]; then
    echo "Removing \$USER_HOME/run_sd.sh..."
    rm "\$USER_HOME/run_sd.sh"
else
    echo "\$USER_HOME/run_sd.sh does not exist."
fi

# Remove the directory \$USER_HOME/stable-diffusion-webui
if [ -d "\$USER_HOME/stable-diffusion-webui" ]; then
    echo "Removing \$USER_HOME/stable-diffusion-webui directory..."
    rm -rf "\$USER_HOME/stable-diffusion-webui"
else
    echo "\$USER_HOME/stable-diffusion-webui directory does not exist."
fi

# Remove the directory \$USER_HOME/stable-diffusion-env
if [ -d "\$USER_HOME/stable-diffusion-env" ]; then
    echo "Removing \$USER_HOME/stable-diffusion-env directory..."
    rm -rf "\$USER_HOME/stable-diffusion-env"
else
    echo "\$USER_HOME/stable-diffusion-env directory does not exist."
fi

# Remove the file \$USER_HOME/remove.sh
if [ -f "\$USER_HOME/remove.sh" ]; then
    echo "Removing \$USER_HOME/remove.sh..."
    rm "\$USER_HOME/remove.sh"
else
    echo "\$USER_HOME/remove.sh does not exist."
fi

echo "Cleanup complete."
EOF

chmod +x "$USER_HOME/remove.sh"

# Final message
echo -e "${GREEN}Setup complete.${NC} Use ~/run_sd.sh to start Stable Diffusion and ~/remove.sh to uninstall."
