#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
sudo apt install -y python3 python3-pip python3-venv git libgl1 libglib2.0-0

# Create and activate a virtual environment
python3 -m venv ~/stable-diffusion-env
source ~/stable-diffusion-env/bin/activate

# Clone the Stable Diffusion WebUI repository
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ~/stable-diffusion-webui
cd ~/stable-diffusion-webui

# Install PyTorch and other requirements
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt

# Download the model file
mkdir -p ~/stable-diffusion-webui/models/Stable-diffusion/
wget -O ~/stable-diffusion-webui/models/Stable-diffusion/cyberrealistic_v7.safetensors "https://vaultsphere.xyz/cyberrealistic_v7.safetensors"

# Create the `run_sd.sh` script
cat <<EOF > ~/run_sd.sh
#!/bin/bash

# Define the paths
WEBUI_DIR="/home/admin/stable-diffusion-webui"
VENV_DIR="/home/admin/stable-diffusion-env"

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

chmod +x ~/run_sd.sh

# Create the `remove.sh` script
cat <<EOF > ~/remove.sh
#!/bin/bash

# Remove the file ~/run_sd.sh
if [ -f "\$HOME/run_sd.sh" ]; then
    echo "Removing ~/run_sd.sh..."
    rm "\$HOME/run_sd.sh"
else
    echo "~/run_sd.sh does not exist."
fi

# Remove the directory ~/stable-diffusion-webui
if [ -d "\$HOME/stable-diffusion-webui" ]; then
    echo "Removing ~/stable-diffusion-webui directory..."
    rm -rf "\$HOME/stable-diffusion-webui"
else
    echo "~/stable-diffusion-webui directory does not exist."
fi

# Remove the directory ~/stable-diffusion-env
if [ -d "\$HOME/stable-diffusion-env" ]; then
    echo "Removing ~/stable-diffusion-env directory..."
    rm -rf "\$HOME/stable-diffusion-env"
else
    echo "~/stable-diffusion-env directory does not exist."
fi

# Remove the file ~/remove.sh
if [ -f "\$HOME/remove.sh" ]; then
    echo "Removing ~/remove.sh..."
    rm "\$HOME/remove.sh"
else
    echo "~/remove.sh does not exist."
fi

echo "Cleanup complete."
EOF

chmod +x ~/remove.sh

echo "Setup complete. Use ~/run_sd.sh to start Stable Diffusion and ~/remove.sh to uninstall."
