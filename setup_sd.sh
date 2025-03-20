#!/bin/bash

# Dynamically determine the user's home directory
USER_HOME=$(eval echo ~$USER)

# Define the paths
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"
RUN_SCRIPT="$USER_HOME/run_sd.sh"

# Uninstall function
uninstall() {
    echo "Uninstalling Stable Diffusion..."
    
    # Remove the run script
    if [ -f "$RUN_SCRIPT" ]; then
        echo "Removing $RUN_SCRIPT..."
        rm "$RUN_SCRIPT"
    else
        echo "$RUN_SCRIPT does not exist."
    fi
    
    # Remove the web UI directory
    if [ -d "$WEBUI_DIR" ]; then
        echo "Removing $WEBUI_DIR..."
        rm -rf "$WEBUI_DIR"
    else
        echo "$WEBUI_DIR does not exist."
    fi
    
    # Remove the virtual environment
    if [ -d "$VENV_DIR" ]; then
        echo "Removing $VENV_DIR..."
        rm -rf "$VENV_DIR"
    else
        echo "$VENV_DIR does not exist."
    fi
    
    echo "Uninstallation complete."
    exit 0
}

# Check for uninstall argument
if [ "$1" == "/u" ]; then
    uninstall
fi

# Get the default local IP address
DEFAULT_LOCAL_IP=$(hostname -I | awk '{print $1}')

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
echo "2) Run Stable Diffusion remotely on local network (http://$DEFAULT_LOCAL_IP:7860)"
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
        echo "Running Stable Diffusion remotely on local network (http://$DEFAULT_LOCAL_IP:7860)..."
        python launch.py --skip-torch-cuda-test --no-half --listen
        ;;
    *)
        echo "Invalid choice. Exiting."
        deactivate
        exit 1
        ;;
esac

echo "Shutting down Stable Diffusion."
deactivate
