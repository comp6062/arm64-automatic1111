#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y python3 python3-pip python3-venv git libgl1 libglib2.0-0

# Create a virtual environment
python3 -m venv ~/stable-diffusion-env

# Activate the virtual environment
source ~/stable-diffusion-env/bin/activate

# Clone the Stable Diffusion WebUI repository
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ~/stable-diffusion-webui
cd ~/stable-diffusion-webui

# Install PyTorch for CPU
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install other requirements
pip install -r requirements.txt

# Create the run script
cat << 'EOF' > ~/run_sd.sh
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
if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found at $VENV_DIR. Please set it up first."
    exit 1
fi

# Ensure the WebUI directory exists
if [ ! -d "$WEBUI_DIR" ]; then
    echo "Stable Diffusion WebUI directory not found at $WEBUI_DIR."
    exit 1
fi

# Display menu
echo "Choose an option:"
echo "1) Run Stable Diffusion locally (127.0.0.1:7860)"
echo "2) Run Stable Diffusion on local network (local IP:7860)"
read -p "Enter your choice (1 or 2): " choice

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Change to the WebUI directory
cd "$WEBUI_DIR"

# Run based on choice
case $choice in
    1)
        echo "Running Stable Diffusion locally..."
        python launch.py --skip-torch-cuda-test --no-half
        ;;
    2)
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "Running Stable Diffusion on local network (http://$LOCAL_IP:7860)..."
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

# Make the run script executable
chmod +x ~/run_sd.sh

echo "Stable Diffusion setup complete! Run using: ~/run_sd.sh"
