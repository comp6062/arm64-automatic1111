#!/usr/bin/env python3
import base64
import io
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
from tkinter.scrolledtext import ScrolledText

import requests
from PIL import Image, ImageDraw

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
