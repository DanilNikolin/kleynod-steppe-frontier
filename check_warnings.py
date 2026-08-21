import os
import subprocess
from pathlib import Path

godot_path = r"D:\Dev\Godot\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe"
project_root = Path(".").resolve()

gd_files = []
for root, dirs, files in os.walk(project_root):
    if ".git" in dirs:
        dirs.remove(".git")
    if ".godot" in dirs:
        dirs.remove(".godot")
    if "addons" in dirs:
        dirs.remove("addons")
    for f in files:
        if f.endswith(".gd"):
            rel = Path(root).relative_to(project_root) / f
            gd_files.append(str(rel).replace("\\", "/"))

print(f"Found {len(gd_files)} GDScript files. Checking with Godot...")

warnings_found = []


for gd in gd_files:
    res_path = f"res://{gd}"
    cmd = [godot_path, "--headless", "--check-only", "-s", gd]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        out = proc.stdout + "\n" + proc.stderr
        lines = [line for line in out.splitlines() if line.strip() and "Godot Engine v4" not in line]
        if lines:
            warnings_found.append((gd, lines))
    except subprocess.TimeoutExpired:
        print(f"Timeout on {gd}")
    except Exception as e:
        print(f"Error on {gd}: {e}")

print(f"\n--- RESULTS ({len(warnings_found)} files with output) ---")
for file_path, lines in warnings_found:
    print(f"\n>>> {file_path}:")
    for l in lines:
        print(f"    {l}")
