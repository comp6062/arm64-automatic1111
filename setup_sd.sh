#!/usr/bin/env bash
#
# setup_sd.sh
#
# Raspberry Pi Stable Diffusion (AUTOMATIC1111) installer
# Supports:
#   - ARM64 (aarch64): supported / recommended
#   - ARM32 (armv7l): best-effort only (uses third-party wheels if available)
#
# This script:
#   - Installs system dependencies
#   - Creates a Python venv
#   - Clones AUTOMATIC1111
#   - Installs Python requirements
#   - Installs PyTorch (arch-specific)
#   - Downloads a couple of default models (optional but enabled by default)
#   - Creates ~/run_sd.sh and ~/remove.sh
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

progress_bar() { echo -e "${RED}$*${NC}"; }
info() { echo -e "${YELLOW}$*${NC}"; }
ok() { echo -e "${GREEN}$*${NC}"; }
die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

# Ensure we have sudo when needed
SUDO=""
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  SUDO="sudo"
fi

USER_HOME="${HOME}"
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"
PYTHON_BIN="python3"

ARCH="$(uname -m || true)"

progress_bar "Detected architecture: ${ARCH}"

need_cmd apt-get
need_cmd uname

progress_bar "Updating and upgrading system..."
$SUDO apt-get update -y
# Keep automation safe/non-interactive: avoid upgrade prompts on some systems
# (still allowed to run manually if you want)
$SUDO DEBIAN_FRONTEND=noninteractive apt-get -y upgrade || true

progress_bar "Installing necessary dependencies..."
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git curl wget ca-certificates \
  python3 python3-venv python3-pip \
  build-essential cmake pkg-config \
  libgl1 libglib2.0-0 \
  libjpeg-dev zlib1g-dev libpng-dev \
  libopenblas-dev libatlas-base-dev \
  ffmpeg

need_cmd "$PYTHON_BIN"
need_cmd git
need_cmd curl
need_cmd wget

progress_bar "Setting up virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# Keep pip sane
pip install --upgrade pip setuptools wheel

progress_bar "Cloning Stable Diffusion WebUI repository..."
if [ ! -d "$WEBUI_DIR/.git" ]; then
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$WEBUI_DIR"
else
  info "Repo already exists, skipping clone: $WEBUI_DIR"
fi

cd "$WEBUI_DIR"

# Helpful to avoid interactive Git prompts at first run
export GIT_TERMINAL_PROMPT=0

progress_bar "Installing PyTorch (architecture-specific)..."
PYV="$("$PYTHON_BIN" -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"

install_torch_arm64() {
  # Official CPU wheels index
  pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio
}

install_torch_arm32_best_effort() {
  # Best-effort: try to locate third-party armv7l wheels from PINTO0309's GitHub releases.
  # If we can't find matching wheels, we fail with a clear message (README says best-effort).
  local tmpdir tag url html
  tmpdir="$(mktemp -d)"
  tag="v1.10.2-numpy1222"
  url="https://github.com/PINTO0309/pytorch4raspberrypi/releases/tag/${tag}"

  info "ARM32 detected (armv7l). Attempting best-effort PyTorch wheel install from PINTO0309 (${tag})..."
  info "Fetching: ${url}"
  if ! curl -fsSL "$url" -o "${tmpdir}/release.html"; then
    rm -rf "$tmpdir"
    die "Could not fetch third-party wheels page for ARM32. Recommendation: use a 64-bit OS (ARM64)."
  fi

  html="$(cat "${tmpdir}/release.html")"

  # Extract any .whl asset links and normalize to full URLs.
  mapfile -t links < <(printf "%s" "$html" | \
    grep -Eo 'href="[^"]+\.whl"' | \
    sed -E 's/^href="//; s/"$//; s/&amp;/\&/g' | \
    sed -E 's#^/PINTO0309/pytorch4raspberrypi/releases/download/#https://github.com/PINTO0309/pytorch4raspberrypi/releases/download/#' | \
    sort -u)

  if [ "${#links[@]}" -eq 0 ]; then
    rm -rf "$tmpdir"
    die "Could not locate .whl asset links on the ARM32 wheels page. Recommendation: use a 64-bit OS (ARM64)."
  fi

  # Choose wheels matching this Python version and armv7l.
  # Accept common patterns: cp39, cp310, etc, and linux_armv7l / armv7l / arm-linux-gnueabihf.
  local want="cp${PYV}"
  local torch_url="" tv_url="" ta_url=""

  for l in "${links[@]}"; do
    case "$l" in
      *"${want}"*armv7l*.whl|*"${want}"*gnueabihf*.whl)
        case "$l" in
          */torch-*.whl) torch_url="$l" ;;
          */torchvision-*.whl) tv_url="$l" ;;
          */torchaudio-*.whl) ta_url="$l" ;;
        esac
        ;;
    esac
  done

  if [ -z "$torch_url" ] || [ -z "$tv_url" ] || [ -z "$ta_url" ]; then
    rm -rf "$tmpdir"
    die "No matching ARM32 wheels found for Python cp${PYV}. ARM32 is best-effort only. Recommendation: switch to a 64-bit OS (ARM64)."
  fi

  info "Downloading wheels..."
  curl -fL "$torch_url" -o "${tmpdir}/torch.whl"
  curl -fL "$tv_url" -o "${tmpdir}/torchvision.whl"
  curl -fL "$ta_url" -o "${tmpdir}/torchaudio.whl"

  info "Installing wheels..."
  pip install "${tmpdir}/torch.whl" "${tmpdir}/torchvision.whl" "${tmpdir}/torchaudio.whl"

  rm -rf "$tmpdir"
}

case "$ARCH" in
  aarch64|arm64)
    install_torch_arm64
    ;;
  armv7l|armv7*)
    install_torch_arm32_best_effort
    ;;
  *)
    die "Unsupported architecture: ${ARCH}. This script targets Raspberry Pi (ARM64/ARM32)."
    ;;
esac

progress_bar "Installing WebUI Python requirements..."
# Install requirements directly (keeps it deterministic)
if [ -f "requirements_versions.txt" ]; then
  pip install -r requirements_versions.txt
elif [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
else
  # Fallback: let launch.py self-manage if files move upstream
  python launch.py --exit --skip-torch-cuda-test --use-cpu all --precision full --no-half || true
fi

# Optional: download a couple of default models (public Hugging Face files)
progress_bar "Downloading default model files (if missing)..."
mkdir -p "$WEBUI_DIR/models/Stable-diffusion"
mkdir -p "$WEBUI_DIR/models/VAE"

# CyberRealistic V7 FP16
MODEL1_PATH="$WEBUI_DIR/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors"
MODEL1_URL="https://huggingface.co/cyberdelia/CyberRealistic/resolve/main/CyberRealistic_V7.0_FP16.safetensors"

# Realistic Vision 5.1 inpainting
MODEL2_PATH="$WEBUI_DIR/models/Stable-diffusion/Realistic_Vision_V5.1-inpainting.safetensors"
MODEL2_URL="https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1-inpainting.safetensors"

download_if_missing() {
  local url="$1" out="$2"
  if [ -f "$out" ]; then
    info "Model already exists, skipping: $(basename "$out")"
    return 0
  fi
  info "Downloading: $(basename "$out")"
  # Large files; show progress bar if interactive
  if [ -t 1 ]; then
    wget -O "$out" "$url"
  else
    wget -q --show-progress -O "$out" "$url"
  fi
}

# These are large; failures shouldn't break the install. WebUI can run without them.
set +e
download_if_missing "$MODEL1_URL" "$MODEL1_PATH"
download_if_missing "$MODEL2_URL" "$MODEL2_PATH"
set -e

# Pre-clone common repos WebUI would try to clone on first run (reduces prompts)
progress_bar "Pre-cloning common WebUI repos to avoid first-run prompts..."
mkdir -p "$WEBUI_DIR/repositories"
set +e
[ -d "$WEBUI_DIR/repositories/stable-diffusion-webui-assets/.git" ] || git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git "$WEBUI_DIR/repositories/stable-diffusion-webui-assets"
[ -d "$WEBUI_DIR/repositories/stable-diffusion-stability-ai/.git" ] || git clone https://github.com/Stability-AI/stablediffusion.git "$WEBUI_DIR/repositories/stable-diffusion-stability-ai"
[ -d "$WEBUI_DIR/repositories/generative-models/.git" ] || git clone https://github.com/Stability-AI/generative-models.git "$WEBUI_DIR/repositories/generative-models"
[ -d "$WEBUI_DIR/repositories/k-diffusion/.git" ] || git clone https://github.com/crowsonkb/k-diffusion.git "$WEBUI_DIR/repositories/k-diffusion"
[ -d "$WEBUI_DIR/repositories/CodeFormer/.git" ] || git clone https://github.com/sczhou/CodeFormer.git "$WEBUI_DIR/repositories/CodeFormer"
[ -d "$WEBUI_DIR/repositories/BLIP/.git" ] || git clone https://github.com/salesforce/BLIP.git "$WEBUI_DIR/repositories/BLIP"
set -e

progress_bar "Creating run_sd.sh script..."
cat > "$USER_HOME/run_sd.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

USER_HOME="${HOME}"
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"

PORT="${SD_PORT:-7860}"

if [ ! -d "$WEBUI_DIR" ] || [ ! -d "$VENV_DIR" ]; then
  echo "ERROR: Stable Diffusion not installed. Run setup_sd.sh first." >&2
  exit 1
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
cd "$WEBUI_DIR"

# Best-effort LAN IP detection (used only for a friendly display message)
LAN_IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
if [ -z "${LAN_IP}" ]; then
  LAN_IP="$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' || true)"
fi

echo
echo "Select an option:"
echo "1) Run connected to the internet (http://LAN_IP:${PORT})"
echo "2) Run completely offline / localhost only (http://127.0.0.1:${PORT})"
echo "3) Uninstall"
echo "4) Quit"
echo

read -r -p "Enter your choice: " choice

COMMON_ARGS=(--port "$PORT" --skip-torch-cuda-test --use-cpu all --precision full --no-half)

case "${choice}" in
  1)
    echo "Running with LAN access..."
    echo "Access it at: http://${LAN_IP:-127.0.0.1}:${PORT}"
    # Listen on all interfaces
    python launch.py --listen "${COMMON_ARGS[@]}"
    ;;
  2)
    echo "Running localhost-only..."
    echo "Access it at: http://127.0.0.1:${PORT}"
    # Bind to localhost only
    python launch.py --listen --server-name 127.0.0.1 "${COMMON_ARGS[@]}"
    ;;
  3)
    echo "Uninstalling..."
    bash "$USER_HOME/remove.sh"
    ;;
  4)
    echo "Quitting."
    exit 0
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac
EOF
chmod +x "$USER_HOME/run_sd.sh"

progress_bar "Creating remove.sh script..."
cat > "$USER_HOME/remove.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

USER_HOME="${HOME}"
WEBUI_DIR="$USER_HOME/stable-diffusion-webui"
VENV_DIR="$USER_HOME/stable-diffusion-env"

echo "This will remove:"
echo " - $WEBUI_DIR"
echo " - $VENV_DIR"
echo " - $USER_HOME/run_sd.sh"
echo " - $USER_HOME/remove.sh"
read -r -p "Are you sure? (y/N): " ans
ans="${ans:-N}"
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

pkill -f "launch.py" >/dev/null 2>&1 || true
rm -rf "$WEBUI_DIR" "$VENV_DIR"
rm -f "$USER_HOME/run_sd.sh" "$USER_HOME/remove.sh"
echo "Uninstalled."
EOF
chmod +x "$USER_HOME/remove.sh"

ok "Setup complete. Use ~/run_sd.sh to start Stable Diffusion or ~/remove.sh to uninstall."
