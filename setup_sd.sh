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
# shellcheck disable=SC1090
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
wget -O "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/CyberRealistic_V7.0_FP16.safetensors" \
  "https://huggingface.co/Cyberhybrid/CyberRealistic/resolve/main/CyberRealistic_V7.0_FP16.safetensors"
wget -O "$USER_HOME/stable-diffusion-webui/models/Stable-diffusion/Realistic_Vision_V5.1-inpainting.safetensors" \
  "https://huggingface.co/SG161222/Realistic_Vision_V5.1_noVAE/resolve/main/Realistic_Vision_V5.1-inpainting.safetensors"

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

# CTRL+C will call cleanup()
trap cleanup SIGINT

# Basic checks
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${RED}Virtual environment not found at $VENV_DIR. Please set it up first.${NC}"
    exit 1
fi

if [ ! -d "$WEBUI_DIR" ]; then
    echo -e "${RED}Stable Diffusion WebUI not found at $WEBUI_DIR.${NC}"
    exit 1
fi

echo -e "${YELLOW}Select an option:${NC}"
echo "1) Run connected to the internet (http://Local_IP:7860, API ON)"
echo "2) Run completely offline (127.0.0.1:7860, API ON)"
echo "3) Uninstall"
echo "4) Quit"
read -p "Enter your choice: " choice

case "$choice" in
    1)
        echo -e "${GREEN}Running with internet connection (LAN access) and API enabled...${NC}"
        source "$VENV_DIR/bin/activate"
        cd "$WEBUI_DIR"
        DEFAULT_LOCAL_IP=$(hostname -I | awk '{print $1}')
        echo -e "Access it at: http://$DEFAULT_LOCAL_IP:7860"
        echo -e "API endpoint:  http://$DEFAULT_LOCAL_IP:7860/sdapi/v1/..."
        python launch.py --skip-torch-cuda-test --no-half --listen --api
        cleanup
        ;;
    2)
        echo -e "${GREEN}Running completely offline (localhost only) with API enabled...${NC}"
        source "$VENV_DIR/bin/activate"
        cd "$WEBUI_DIR"
        echo -e "Access it at: http://127.0.0.1:7860"
        echo -e "API endpoint:  http://127.0.0.1:7860/sdapi/v1/..."
        python launch.py --skip-torch-cuda-test --no-half --skip-install --api
        cleanup
        ;;
    3)
        echo -e "${RED}Uninstalling...${NC}"
        bash "$USER_HOME/remove.sh"
        ;;
    4)
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

echo -e "${GREEN}Setup complete.${NC} Use ~/run_sd.sh to start Stable Diffusion or ~/remove.sh to uninstall."

###############################################
# SD Outpaint Helper - install after A1111
###############################################

echo
echo "==========================================="
echo " Installing SD Outpaint Helper (local GUI) "
echo "==========================================="
echo

# Use same USER_HOME as above, install helper under /opt and add launcher + desktop entry

APP_DIR="/opt/sd-outpaint"
LAUNCHER="/usr/local/bin/sd-outpaint"
DESKTOP_FILE="/usr/share/applications/sd-outpaint.desktop"
PY_APP="${APP_DIR}/sd_outpaint_gui.py"

# Ensure tkinter for GUI
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y python3-tk
fi

# Create app directory (root-owned)
sudo rm -rf "${APP_DIR}"
sudo mkdir -p "${APP_DIR}"

# Write Python GUI app
sudo tee "${PY_APP}" >/dev/null <<'PYCODE'
#!/usr/bin/env python3
import base64
import io

import requests
from PIL import Image, ImageDraw

import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from tkinter.scrolledtext import ScrolledText

SD_API_URL = "http://127.0.0.1:7860"


def pil_to_base64_png(img: Image.Image) -> str:
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def base64_to_pil(b64_str: str) -> Image.Image:
    img_bytes = base64.b64decode(b64_str)
    return Image.open(io.BytesIO(img_bytes)).convert("RGBA")


class OutpaintApp:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("SD Outpaint Helper (Local A1111)")
        self.root.minsize(640, 480)

        self.image_path = None
        self.image = None

        self._build_ui()

    def _build_ui(self):
        root = self.root

        main = ttk.Frame(root, padding=10)
        main.grid(row=0, column=0, sticky="nsew")

        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)
        main.columnconfigure(0, weight=1)
        for r in range(5):
            main.rowconfigure(r, weight=0)
        main.rowconfigure(3, weight=1)
        main.rowconfigure(5, weight=0)

        file_frame = ttk.LabelFrame(main, text="Base Image")
        file_frame.grid(row=0, column=0, sticky="ew", pady=(0, 8))
        file_frame.columnconfigure(1, weight=1)

        self.path_var = tk.StringVar(value="No file loaded")
        self.size_var = tk.StringVar(value="")

        ttk.Label(file_frame, textvariable=self.path_var).grid(
            row=0, column=0, columnspan=2, sticky="w", pady=(0, 4)
        )

        ttk.Button(file_frame, text="Load Image…", command=self.load_image).grid(
            row=1, column=0, sticky="w"
        )
        ttk.Label(file_frame, textvariable=self.size_var).grid(
            row=1, column=1, sticky="e"
        )

        pad_frame = ttk.LabelFrame(main, text="Padding (pixels to outpaint on each side)")
        pad_frame.grid(row=1, column=0, sticky="ew", pady=(0, 8))
        for i in range(3):
            pad_frame.columnconfigure(i, weight=1)

        self.pad_top = tk.IntVar(value=256)
        self.pad_bottom = tk.IntVar(value=256)
        self.pad_left = tk.IntVar(value=256)
        self.pad_right = tk.IntVar(value=256)

        ttk.Label(pad_frame, text="Top").grid(row=0, column=1)
        ttk.Spinbox(pad_frame, from_=0, to=4096, textvariable=self.pad_top, width=7).grid(
            row=1, column=1
        )

        ttk.Label(pad_frame, text="Left").grid(row=2, column=0, pady=(4, 0))
        ttk.Spinbox(pad_frame, from_=0, to=4096, textvariable=self.pad_left, width=7).grid(
            row=3, column=0
        )

        ttk.Label(pad_frame, text="Right").grid(row=2, column=2, pady=(4, 0))
        ttk.Spinbox(pad_frame, from_=0, to=4096, textvariable=self.pad_right, width=7).grid(
            row=3, column=2
        )

        ttk.Label(pad_frame, text="Bottom").grid(row=4, column=1, pady=(4, 0))
        ttk.Spinbox(pad_frame, from_=0, to=4096, textvariable=self.pad_bottom, width=7).grid(
            row=5, column=1
        )

        params_frame = ttk.LabelFrame(main, text="Stable Diffusion Parameters")
        params_frame.grid(row=2, column=0, sticky="ew", pady=(0, 8))
        for i in range(4):
            params_frame.columnconfigure(i, weight=1)

        ttk.Label(params_frame, text="Sampler").grid(row=0, column=0, sticky="w")
        self.sampler_var = tk.StringVar(value="Euler a")
        sampler_box = ttk.Combobox(
            params_frame,
            textvariable=self.sampler_var,
            values=["Euler a", "DPM++ 2M Karras", "DPM++ SDE Karras", "Euler"],
            state="readonly",
            width=18,
        )
        sampler_box.grid(row=1, column=0, sticky="w")

        ttk.Label(params_frame, text="Steps").grid(row=0, column=1, sticky="w")
        self.steps_var = tk.IntVar(value=25)
        ttk.Spinbox(
            params_frame, from_=1, to=150, textvariable=self.steps_var, width=6
        ).grid(row=1, column=1, sticky="w")

        ttk.Label(params_frame, text="CFG").grid(row=0, column=2, sticky="w")
        self.cfg_var = tk.DoubleVar(value=7.0)
        ttk.Spinbox(
            params_frame,
            from_=1.0,
            to=20.0,
            increment=0.5,
            textvariable=self.cfg_var,
            width=6,
        ).grid(row=1, column=2, sticky="w")

        ttk.Label(params_frame, text="Denoising").grid(row=0, column=3, sticky="w")
        self.denoise_var = tk.DoubleVar(value=0.55)
        ttk.Spinbox(
            params_frame,
            from_=0.0,
            to=1.0,
            increment=0.05,
            textvariable=self.denoise_var,
            width=6,
        ).grid(row=1, column=3, sticky="w")

        prompt_frame = ttk.LabelFrame(main, text="Prompts")
        prompt_frame.grid(row=3, column=0, sticky="nsew", pady=(0, 8))
        prompt_frame.columnconfigure(0, weight=1)
        prompt_frame.columnconfigure(1, weight=1)
        prompt_frame.rowconfigure(1, weight=1)

        ttk.Label(prompt_frame, text="Prompt").grid(row=0, column=0, sticky="w")
        self.prompt_text = ScrolledText(prompt_frame, wrap="word", height=5)
        self.prompt_text.grid(row=1, column=0, sticky="nsew", padx=(0, 4), pady=(0, 4))
        self.prompt_text.insert(
            "1.0",
            "seamless extension of the scene, same style, same lighting, highly detailed, outpaint background",
        )

        ttk.Label(prompt_frame, text="Negative Prompt").grid(row=0, column=1, sticky="w")
        self.neg_prompt_text = ScrolledText(prompt_frame, wrap="word", height=5)
        self.neg_prompt_text.grid(row=1, column=1, sticky="nsew", padx=(4, 0), pady=(0, 4))
        self.neg_prompt_text.insert(
            "1.0",
            "lowres, blurry, distorted, deformed, bad anatomy, artifacts, watermark, text",
        )

        btn_frame = ttk.Frame(main)
        btn_frame.grid(row=4, column=0, sticky="ew", pady=(0, 4))
        btn_frame.columnconfigure(0, weight=1)
        btn_frame.columnconfigure(1, weight=1)

        self.generate_btn = ttk.Button(
            btn_frame, text="Generate Outpaint", command=self.generate_outpaint
        )
        self.generate_btn.grid(row=0, column=0, sticky="ew", padx=(0, 4))

        quit_btn = ttk.Button(btn_frame, text="Quit", command=root.quit)
        quit_btn.grid(row=0, column=1, sticky="ew", padx=(4, 0))

        status_frame = ttk.Frame(main)
        status_frame.grid(row=5, column=0, sticky="ew")
        status_frame.columnconfigure(0, weight=1)

        self.status_var = tk.StringVar(
            value=f"Stable Diffusion endpoint: {SD_API_URL} (img2img)"
        )
        ttk.Label(status_frame, textvariable=self.status_var).grid(
            row=0, column=0, sticky="w"
        )

    def load_image(self):
        path = filedialog.askopenfilename(
            title="Select base image",
            filetypes=[
                ("Image files", "*.png;*.jpg;*.jpeg;*.webp;*.bmp"),
                ("All files", "*.*"),
            ],
        )
        if not path:
            return

        try:
            img = Image.open(path).convert("RGBA")
        except Exception as e:
            messagebox.showerror("Error", f"Could not open image:\n{e}")
            return

        self.image_path = path
        self.image = img
        self.path_var.set(path)
        self.size_var.set(f"{img.width} x {img.height}")
        self.status_var.set("Image loaded successfully.")

    def generate_outpaint(self):
        if self.image is None:
            messagebox.showwarning("No Image", "Please load a base image first.")
            return

        try:
            pad_top = max(0, int(self.pad_top.get()))
            pad_bottom = max(0, int(self.pad_bottom.get()))
            pad_left = max(0, int(self.pad_left.get()))
            pad_right = max(0, int(self.pad_right.get()))
        except Exception:
            messagebox.showerror("Invalid input", "Padding values must be integers.")
            return

        if pad_top == pad_bottom == pad_left == pad_right == 0:
            if not messagebox.askyesno(
                "No padding",
                "All paddings are set to 0.\n"
                "This will not add any outpaint area.\n\n"
                "Continue anyway?",
            ):
                return

        base_img = self.image
        orig_w, orig_h = base_img.size

        new_w = orig_w + pad_left + pad_right
        new_h = orig_h + pad_top + pad_bottom

        expanded = Image.new("RGBA", (new_w, new_h), (0, 0, 0, 0))
        expanded.paste(base_img, (pad_left, pad_top))

        mask = Image.new("L", (new_w, new_h), 255)
        draw = ImageDraw.Draw(mask)
        draw.rectangle(
            [pad_left, pad_top, pad_left + orig_w, pad_top + orig_h],
            fill=0,
        )

        prompt = self.prompt_text.get("1.0", "end").strip()
        neg_prompt = self.neg_prompt_text.get("1.0", "end").strip()
        sampler = self.sampler_var.get()

        try:
            steps = int(self.steps_var.get())
        except Exception:
            steps = 25
        try:
            cfg = float(self.cfg_var.get())
        except Exception:
            cfg = 7.0
        try:
            denoise = float(self.denoise_var.get())
        except Exception:
            denoise = 0.55

        init_b64 = pil_to_base64_png(expanded)
        mask_b64 = pil_to_base64_png(mask)

        payload = {
            "init_images": [init_b64],
            "mask": mask_b64,
            "prompt": prompt,
            "negative_prompt": neg_prompt,
            "sampler_name": sampler,
            "steps": steps,
            "cfg_scale": cfg,
            "denoising_strength": denoise,
            "width": new_w,
            "height": new_h,
            "batch_size": 1,
            "n_iter": 1,
            "mask_blur": 8,
            "inpainting_fill": 1,
            "inpaint_full_res": False,
            "inpaint_full_res_padding": 0,
            "inpainting_mask_invert": 0,
            "resize_mode": 0,
        }

        self.generate_btn.config(state="disabled")
        self.status_var.set("Contacting Stable Diffusion and generating…")
        self.root.update_idletasks()

        try:
            resp = requests.post(
                f"{SD_API_URL}/sdapi/v1/img2img",
                json=payload,
                timeout=600,
            )
            resp.raise_for_status()
            data = resp.json()
            images = data.get("images", [])
            if not images:
                raise RuntimeError("Stable Diffusion returned no images.")

            out_img = base64_to_pil(images[0])
        except Exception as e:
            self.generate_btn.config(state="normal")
            self.status_var.set("Error during generation.")
            messagebox.showerror(
                "Error",
                f"Error while contacting Stable Diffusion or generating image:\n\n{e}",
            )
            return

        self.generate_btn.config(state="normal")
        self.status_var.set("Outpainted image ready. Choose where to save it.")

        save_path = filedialog.asksaveasfilename(
            title="Save outpainted image",
            defaultextension=".png",
            filetypes=[("PNG", "*.png"), ("All files", "*.*")],
        )
        if save_path:
            try:
                out_img.save(save_path)
                self.status_var.set(f"Saved outpainted image to: {save_path}")
                messagebox.showinfo(
                    "Saved",
                    f"Outpainted image saved to:\n{save_path}",
                )
            except Exception as e:
                self.status_var.set("Failed to save image.")
                messagebox.showerror("Error", f"Could not save image:\n{e}")
        else:
            self.status_var.set("Save canceled. You can generate again or save later.")


def main():
    root = tk.Tk()
    try:
        style = ttk.Style()
        if "clam" in style.theme_names():
            style.theme_use("clam")
    except Exception:
        pass

    app = OutpaintApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
PYCODE

sudo chmod 644 "${PY_APP}"
sudo chown -R root:root "${APP_DIR}"

# Create venv + install Python deps for helper
sudo python3 -m venv "${APP_DIR}/venv"
sudo "${APP_DIR}/venv/bin/pip" install --upgrade pip >/dev/null
sudo "${APP_DIR}/venv/bin/pip" install pillow requests >/dev/null

# Launcher script
sudo tee "${LAUNCHER}" >/dev/null <<'LAUNCH'
#!/usr/bin/env bash
APP_DIR="/opt/sd-outpaint"
VENV_PY="${APP_DIR}/venv/bin/python"
APP_PY="${APP_DIR}/sd_outpaint_gui.py"
DESKTOP_FILE="/usr/share/applications/sd-outpaint.desktop"
LAUNCHER_PATH="/usr/local/bin/sd-outpaint"

if [[ "$1" == "--uninstall" ]]; then
  echo "This will remove only SD Outpaint Helper."
  read -r -p "Continue? [y/N] " ans
  case "$ans" in
    y|Y)
      sudo rm -rf "${APP_DIR}" || echo "Warning: failed to remove ${APP_DIR}"
      sudo rm -f "${DESKTOP_FILE}" || echo "Warning: failed to remove ${DESKTOP_FILE}"
      sudo rm -f "${LAUNCHER_PATH}" || echo "Warning: failed to remove launcher"
      if command -v update-desktop-database >/dev/null 2>&1; then
        sudo update-desktop-database >/dev/null 2>&1 || true
      fi
      echo "SD Outpaint Helper uninstalled."
      exit 0
      ;;
    *)
      echo "Uninstall canceled."
      exit 0
      ;;
  esac
fi

if [ ! -x "${VENV_PY}" ]; then
  echo "ERROR: Python virtualenv not found at ${VENV_PY}"
  echo "Try reinstalling SD Outpaint Helper."
  exit 1
fi

exec "${VENV_PY}" "${APP_PY}"
LAUNCH

sudo chmod 755 "${LAUNCHER}"
sudo chown root:root "${LAUNCHER}"

# Desktop entry
sudo tee "${DESKTOP_FILE}" >/dev/null <<DESK
[Desktop Entry]
Type=Application
Name=SD Outpaint Helper
Comment=Local Stable Diffusion outpainting helper (uses Automatic1111 at 127.0.0.1:7860)
Exec=${LAUNCHER}
Icon=applications-graphics
Terminal=false
Categories=Graphics;
DESK

sudo chmod 644 "${DESKTOP_FILE}"
sudo chown root:root "${DESKTOP_FILE}"

if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database >/dev/null 2>&1 || true
fi

echo
echo "SD Outpaint Helper installed."
echo "Run with: sd-outpaint"
echo "Uninstall helper with: sudo sd-outpaint --uninstall"
