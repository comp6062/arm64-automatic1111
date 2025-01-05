#!/bin/bash

# Function to display a confirmation prompt
confirm() {
    while true; do
        read -rp "$1 (y/n): " choice
        case "$choice" in
            [yY] ) return 0 ;;
            [nN] ) return 1 ;;
            * ) echo "Please enter y or n." ;;
        esac
    done
}

# Define paths
VENV_DIR="$HOME/stable-diffusion-env"
WEBUI_DIR="$HOME/stable-diffusion-webui"
RUN_SCRIPT="$HOME/run_sd.sh"

# Stop any running Stable Diffusion processes
echo "Stopping any running Stable Diffusion processes..."
pkill -f "launch.py" 2>/dev/null || echo "No running Stable Diffusion processes found."

# Remove the virtual environment
if [ -d "$VENV_DIR" ]; then
    echo "Removing virtual environment at $VENV_DIR..."
    rm -rf "$VENV_DIR"
else
    echo "Virtual environment not found at $VENV_DIR."
fi

# Remove the WebUI directory
if [ -d "$WEBUI_DIR" ]; then
    echo "Removing Stable Diffusion WebUI directory at $WEBUI_DIR..."
    rm -rf "$WEBUI_DIR"
else
    echo "Stable Diffusion WebUI directory not found at $WEBUI_DIR."
fi

# Remove the run script
if [ -f "$RUN_SCRIPT" ]; then
    echo "Removing run script at $RUN_SCRIPT..."
    rm -f "$RUN_SCRIPT"
else
    echo "Run script not found at $RUN_SCRIPT."
fi

# Prompt to remove installed dependencies
if confirm "Do you want to remove the installed dependencies (python3, python3-pip, python3-venv, git, libgl1, libglib2.0-0)?"; then
    echo "Removing installed dependencies..."
    sudo apt remove -y python3 python3-pip python3-venv git libgl1 libglib2.0-0
    sudo apt autoremove -y
else
    echo "Skipping dependency removal."
fi

echo "Cleanup complete."
