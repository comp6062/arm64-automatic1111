#!/bin/bash

# Step 1: Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Step 2: Install dependencies
sudo apt install -y python3 python3-pip python3-venv git libgl1 libglib2.0-0

# Step 3: Set up the Python virtual environment
python3 -m venv ~/stable-diffusion-env
source ~/stable-diffusion-env/bin/activate

# Step 4: Clone the Stable Diffusion repository
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ~/stable-diffusion-webui
cd ~/stable-diffusion-webui

# Step 5: Install PyTorch and other requirements
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt

# Step 6: Download the model file
mkdir -p ~/stable-diffusion-webui/models/Stable-diffusion/
wget -O ~/stable-diffusion-webui/models/Stable-diffusion/cyberrealistic_v70.safetensors \
    "https://civitai-delivery-worker-prod.5ac0637cfd0766c97916cefa3764fbdf.r2.cloudflarestorage.com/model/6357/cyberrealisticV70.PUB5.safetensors?X-Amz-Expires=86400&response-content-disposition=attachment%3B%20filename%3D%22cyberrealistic_v70.safetensors%22&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=e01358d793ad6966166af8b3064953ad/20250102/us-east-1/s3/aws4_request&X-Amz-Date=20250102T014043Z&X-Amz-SignedHeaders=host&X-Amz-Signature=226ee983c6256b1045dabd6f9b76c659b4debd56f240e626b8bbb58eb830fc35"

# Step 7: Create the run script
cat << 'EOF' > ~/run_sd.sh
#!/bin/bash

# Define the virtual environment and project directory
VENV_DIR="/home/$USER/stable-diffusion-env"
PROJECT_DIR="/home/$USER/stable-diffusion-webui"

# Function to run Stable Diffusion
run_stable_diffusion() {
    local mode=$1
    echo "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"

    echo "Running Stable Diffusion with mode: $mode"
    if [ "$mode" == "cpu" ]; then
        python "$PROJECT_DIR/launch.py" --skip-torch-cuda-test --no-half
    elif [ "$mode" == "arm64" ]; then
        python "$PROJECT_DIR/launch.py" --skip-torch-cuda-test --no-half --medvram
    else
        echo "Invalid mode specified."
        deactivate
        exit 1
    fi

    echo "Deactivating virtual environment..."
    deactivate
}

# Menu for user to select the mode
echo "Select an option to run Stable Diffusion:"
echo "1) CPU-only mode"
echo "2) ARM64-optimized mode (with --medvram)"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    run_stable_diffusion "cpu"
elif [ "$choice" == "2" ]; then
    run_stable_diffusion "arm64"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

echo "Stable Diffusion has stopped. Cleaning up..."
EOF

# Step 8: Make the run script executable
chmod +x ~/run_sd.sh

echo "Setup complete! Use '~/run_sd.sh' to start Stable Diffusion."
