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

# Run based on choicein"Running Stable Diffusion locally..."
        python launch.py --skip-torch-cuda-test --no-half
        ;;
    2)
        LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo "Running Stable Diffusion on local network (http://$LOCAL_IP:7860)..."
        python launch.py --skip-torch-cuda-test --no-half --listen --port 7860 --host $LOCAL_IP
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
