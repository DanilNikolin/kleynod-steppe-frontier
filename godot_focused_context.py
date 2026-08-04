# coding: utf-8
"""
godot_focused_context.py
Run from the root of your Godot project, next to project.godot.
Creates godot_focused_context.md.

Workflow:
1) Run godot_scout.py.
2) Send godot_scout.md to the LLM.
3) Paste returned FOCUS_PATTERNS below.
4) Run this script.
5) Send godot_focused_context.md to the LLM.
"""

import os
import re
import fnmatch
from pathlib import Path

OUTPUT_FILE = "godot_focused_context.md"
SCRIPT_NAME = os.path.basename(__file__)
PROJECT_ROOT = Path(".").resolve()

# Paste patterns from the LLM here.


FOCUS_PATTERNS = [
    "presentation/battle/combatants/combatant_view.gd",
    "presentation/battle/combatants/combatant_view.tscn",
    "presentation/battle/combatants/battle_combatant_presenter.gd",
    "presentation/battle/combatants/battle_combatant_hover_panel.gd",
    "presentation/battle/combatants/battle_combatant_hover_panel.tscn",
    "presentation/battle/combatants/statuses/battle_status_strip.gd",
    "presentation/battle/combatants/statuses/battle_status_strip.tscn",
    "presentation/battle/combatants/statuses/battle_status_chip.gd",
    "presentation/battle/combatants/statuses/battle_status_chip.tscn",
    "core/battle/combatants/combatant_state.gd",
    "core/heroes/core/hero_core_runtime_state.gd",
    "core/heroes/core/bayda/bayda_core_runtime_state.gd",
]

ALLOW_ADDONS = False



IGNORE_DIRS = {
    ".git", ".godot", ".import", ".vscode", ".idea", "__pycache__"
}
if not ALLOW_ADDONS:
    IGNORE_DIRS.add("addons")

IGNORE_FILE_PATTERNS = {
    "*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg",
    "*.wav", "*.ogg", "*.mp3",
    "*.zip", "*.exe", "*.dll", "*.pck",
    "*.psd", "*.kra", "*.blend",
    "*.uid", "*.import", "*.tmp", "*.remap", "*.stex", "*.ctex",
    ".DS_Store", "thumbs.db",
    OUTPUT_FILE, "godot_scout.md", SCRIPT_NAME,
}

READ_EXTENSIONS = {
    ".gd", ".tscn", ".tres", ".json", ".cfg", ".txt", ".md", ".shader", ".godot"
}

AUTO_INCLUDE_REFERENCED_GD = False
AUTO_INCLUDE_REFERENCED_TSCN = False
AUTO_INCLUDE_REFERENCED_TRES = False
AUTO_INCLUDE_REFERENCED_DIALOGUE = False
ALWAYS_INCLUDE_PROJECT_GODOT = False

MAX_TOTAL_LINES = 30000
MAX_FILE_LINES = 3500
TRIM_MODE = "head_tail"


def norm(path: str) -> str:
    return path.replace("\\", "/").lstrip("./")


def matches_any(path: str, patterns) -> bool:
    rp = norm(path)
    for pat in patterns:
        p = norm(pat)
        if fnmatch.fnmatch(rp, p):
            return True
        if p in rp:
            return True
    return False


def should_skip_file(rel_path: str) -> bool:
    rel = norm(rel_path)
    parts = rel.split("/")
    if any(part in IGNORE_DIRS for part in parts):
        return True
    base = os.path.basename(rel)
    for pat in IGNORE_FILE_PATTERNS:
        if fnmatch.fnmatch(base.lower(), pat.lower()):
            return True
    return False


def is_readable(rel_path: str) -> bool:
    rel = norm(rel_path)
    if rel == "project.godot":
        return True
    return Path(rel).suffix.lower() in READ_EXTENSIONS


def is_focused(rel_path: str) -> bool:
    rel = norm(rel_path)
    if ALWAYS_INCLUDE_PROJECT_GODOT and rel == "project.godot":
        return True
    if not FOCUS_PATTERNS:
        return False
    return matches_any(rel, FOCUS_PATTERNS)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def trim_text(text: str, max_lines: int) -> str:
    lines = text.splitlines()
    if len(lines) <= max_lines:
        return text

    if TRIM_MODE == "head":
        return "\n".join(lines[:max_lines]) + "\n\n# [TRIMMED: tail cut]\n"
    if TRIM_MODE == "tail":
        return "# [TRIMMED: head cut]\n\n" + "\n".join(lines[-max_lines:])

    half = max_lines // 2
    return "\n".join(lines[:half]) + "\n\n# [TRIMMED: middle cut]\n\n" + "\n".join(lines[-half:])


def collect_all_files(root: Path):
    all_files = []
    readable = {}

    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS]
        for fname in filenames:
            full = Path(dirpath) / fname
            rel = norm(str(full.relative_to(root)))
            if should_skip_file(rel):
                continue
            all_files.append(rel)
            if is_readable(rel):
                readable[rel] = full

    return sorted(all_files), readable


def build_tree(paths, project_root: Path) -> str:
    structure = {}
    for p in paths:
        cur = structure
        for part in p.split("/"):
            cur = cur.setdefault(part, {})

    def render(node, indent=""):
        out = []
        items = sorted(node.items())
        for i, (name, sub) in enumerate(items):
            last = i == len(items) - 1
            prefix = "└── " if last else "├── "
            next_indent = "    " if last else "│   "
            out.append(indent + prefix + name)
            if sub:
                out.append(render(sub, indent + next_indent))
        return "\n".join(x for x in out if x)

    return f"{project_root.name}/\n{render(structure)}"


def res_to_rel(res_path: str) -> str:
    return norm(res_path.replace("res://", ""))


def collect_res_references(text: str):
    refs = set(re.findall(r"res://[^\s\"'\)\]\},]+", text))
    wanted = set()

    for ref in refs:
        ext = Path(ref).suffix.lower()
        if ext == ".gd" and AUTO_INCLUDE_REFERENCED_GD:
            wanted.add(res_to_rel(ref))
        elif ext == ".tscn" and AUTO_INCLUDE_REFERENCED_TSCN:
            wanted.add(res_to_rel(ref))
        elif ext == ".tres" and AUTO_INCLUDE_REFERENCED_TRES:
            wanted.add(res_to_rel(ref))
        elif ext == ".dialogue" and AUTO_INCLUDE_REFERENCED_DIALOGUE:
            wanted.add(res_to_rel(ref))

    return wanted


def language_for(rel: str) -> str:
    if rel == "project.godot":
        return "ini"
    ext = Path(rel).suffix.lower()
    if ext == ".gd":
        return "gdscript"
    if ext == ".json":
        return "json"
    if ext == ".md":
        return "markdown"
    return "text"


def main():
    if not (PROJECT_ROOT / "project.godot").exists():
        print("❌ Run this script from the Godot project root, where project.godot is.")
        return

    if not FOCUS_PATTERNS:
        print("⚠️ FOCUS_PATTERNS is empty.")
        print("Run godot_scout.py first, send godot_scout.md to the LLM, paste returned patterns here.")
        return

    print("🚀 Building Godot focused context...")
    print(f"📁 Project: {PROJECT_ROOT}")
    print(f"🎯 Focus patterns: {FOCUS_PATTERNS}")

    all_files, readable_map = collect_all_files(PROJECT_ROOT)

    include = set()
    for rel in readable_map.keys():
        if is_focused(rel):
            include.add(rel)

    # Auto include res:// dependencies. Multiple passes: scene -> script -> dialogue/resource.
    for _ in range(3):
        before = len(include)
        for rel in list(include):
            full = readable_map.get(rel)
            if not full:
                continue
            try:
                text = read_text(full)
            except Exception:
                continue
            for ref in collect_res_references(text):
                if ref in readable_map:
                    include.add(ref)
        if len(include) == before:
            break

    include_files = sorted(include)
    out_path = PROJECT_ROOT / OUTPUT_FILE

    total_lines = 0
    included_count = 0
    trimmed_count = 0
    stopped_before = None

    with out_path.open("w", encoding="utf-8") as out:
        out.write("# GODOT FOCUSED PROJECT CONTEXT\n\n")
        out.write(f"- Project: `{PROJECT_ROOT.name}`\n")
        out.write(f"- Focus patterns: `{FOCUS_PATTERNS}`\n")
        out.write(f"- Allow addons: `{ALLOW_ADDONS}`\n")
        out.write(f"- Included files planned: `{len(include_files)}`\n\n")

        out.write("## 🌳 PROJECT STRUCTURE\n\n")
        out.write("```text\n")
        out.write(build_tree(all_files, PROJECT_ROOT))
        out.write("\n```\n\n---\n\n")

        out.write("## 📌 INCLUDED FILES\n\n")

        for rel in include_files:
            full = readable_map.get(rel)
            if not full:
                continue

            try:
                code = read_text(full)
            except Exception as e:
                out.write(f"## FILE: `{rel}`\n```text\n[ERROR READING FILE] {e}\n```\n\n---\n\n")
                continue

            if len(code.splitlines()) > MAX_FILE_LINES:
                code = trim_text(code, MAX_FILE_LINES)
                trimmed_count += 1

            line_count = len(code.splitlines())
            if total_lines + line_count > MAX_TOTAL_LINES:
                stopped_before = rel
                out.write("\n---\n\n")
                out.write("## 🛑 STOPPED: MAX_TOTAL_LINES reached\n")
                out.write(f"Stopped before file: `{rel}`\n")
                break

            out.write(f"## FILE: `{rel}`\n")
            out.write(f"```{language_for(rel)}\n")
            out.write(code)
            if not code.endswith("\n"):
                out.write("\n")
            out.write("```\n\n---\n\n")

            total_lines += line_count
            included_count += 1

        out.write("\n## ✅ STATS\n")
        out.write(f"- Total files in tree: {len(all_files)}\n")
        out.write(f"- Readable files: {len(readable_map)}\n")
        out.write(f"- Included files written: {included_count}\n")
        out.write(f"- Trimmed files: {trimmed_count}\n")
        out.write(f"- Total lines written: {total_lines}\n")
        if stopped_before:
            out.write(f"- Stopped before: `{stopped_before}`\n")

    print("✅ Done:", out_path)
    print(f"📄 Included: {included_count}")
    print(f"✂️ Trimmed: {trimmed_count}")
    print(f"📝 Lines: {total_lines}")


if __name__ == "__main__":
    main()
