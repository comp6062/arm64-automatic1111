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

# Dynamically determine the user's home directory
USER_HOME=$(eval echo ~$USER)

# Define the paths
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"

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

# Get the default local IP address
DEFAULT_LOCAL_IP=$(hostname -I | awk '{print $1}')

# Display menu
echo "Choose an option:"
echo "1) Run Stable Diffusion locally (127.0.0.1:7860)"
echo "2) Run Stable Diffusion remotely on local network (http://$DEFAULT_LOCAL_IP:7860)"
echo "3) Uninstall Stable Diffusion"
read -p "Enter your choice (1, 2, or 3): " choice

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Change to the WebUI directory
cd "$WEBUI_DIR"

# Handle based on the user's choice
case $choice in
    1)
        echo "Running Stable Diffusion locally..."
        python launch.py --skip-torch-cuda-test --no-half
        ;;
    2)
        echo "Running Stable Diffusion remotely on local network (http://$DEFAULT_LOCAL_IP:7860)..."
        python launch.py --skip-torch-cuda-test --no-half --listen
        ;;
    3)
        # Uninstall option
        echo "Uninstalling Stable Diffusion..."
        rm -rf "$USER_HOME/run_sd.sh"
        rm -rf "$WEBUI_DIR"
        rm -rf "$VENV_DIR"
        echo "Stable Diffusion and related files have been removed."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        deactivate
        exit 1
        ;;
esac

# Cleanup when the process ends
cleanup
