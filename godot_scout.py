# coding: utf-8
"""
godot_scout.py
Run from the root of your Godot project, next to project.godot.
Creates godot_scout.md.

Purpose:
- Show project tree, including asset file names.
- Show key project.godot sections.
- Show useful scene node hierarchies.
- Show Dialogue Manager .dialogue files and cue names.
- Ask the LLM for FOCUS_PATTERNS for godot_focused_context.py.
"""

import os
import re
import fnmatch
from pathlib import Path

OUTPUT_FILE = "godot_scout.md"
SCRIPT_NAME = os.path.basename(__file__)

IGNORE_DIRS = {
    ".git", ".godot", ".import", "__pycache__", ".vscode", ".idea", "addons"
}

IGNORE_FILE_PATTERNS = {
    "*.tmp", "*.remap", "*.stex", "*.ctex", "*.uid",
    ".DS_Store", "thumbs.db",
    OUTPUT_FILE, "godot_focused_context.md",
}

SCENE_EXT = {".tscn"}

SCENE_INCLUDE_PREFIXES = {
    "scenes/", "ui/", "content/", "systems/", "core/", "entities/", "world/", "_devtools/", "presentation/", "tests/"
}

SCENE_EXCLUDE_PREFIXES = {
    "assets/", "props/", "world/props/", "scenes/props/"
}

MAX_SCENE_DEPTH_DEFAULT = 9
MAX_SCENE_DEPTH_WORLD = 4

HIDE_DECOR_PREFIXES = (
    "BaseProp", "Tree_", "Rock_", "Bush_", "Log_", "Grass_", "Flower_", "pine_stump_"
)

PROJECT_GODOT_SECTIONS = {
    "application", "autoload", "display", "input", "rendering", "physics",
    "layer_names", "editor_plugins"
}


def norm(path: str) -> str:
    return path.replace("\\", "/").lstrip("./")


def is_ignored_dir(name: str) -> bool:
    return name in IGNORE_DIRS


def matches_any(path: str, patterns) -> bool:
    s = norm(path).lower()
    for pat in patterns:
        if fnmatch.fnmatch(s, pat.lower()):
            return True
    return False


def should_skip_file(rel_path: str) -> bool:
    rel = norm(rel_path)
    parts = rel.split("/")
    if any(is_ignored_dir(part) for part in parts):
        return True
    return matches_any(os.path.basename(rel), IGNORE_FILE_PATTERNS)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def collect_all_files(root: Path):
    all_rel = []
    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dirnames[:] = [d for d in dirnames if not is_ignored_dir(d)]
        for fname in filenames:
            full = Path(dirpath) / fname
            rel = norm(str(full.relative_to(root)))
            if should_skip_file(rel):
                continue
            all_rel.append(rel)
    return sorted(all_rel)


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


def extract_project_godot_sections(root: Path) -> str:
    path = root / "project.godot"
    if not path.exists():
        return "## ⚙️ project.godot\n> ⚠️ Not found.\n\n"

    lines = read_text(path).splitlines()
    blocks = []
    current = None
    buf = []

    def flush():
        nonlocal current, buf
        if current and current.lower() in PROJECT_GODOT_SECTIONS and buf:
            blocks.append((current, "\n".join(buf)))
        current = None
        buf = []

    for line in lines:
        m = re.match(r"^\[(.+?)\]\s*$", line.strip())
        if m:
            flush()
            current = m.group(1)
            buf = [line]
        else:
            if current is not None:
                buf.append(line)
    flush()

    if not blocks:
        return "## ⚙️ project.godot\n> No useful sections found.\n\n"

    out = ["## ⚙️ project.godot key sections\n"]
    for sec, content in blocks:
        out.append(f"### [{sec}]\n```ini\n{content}\n```\n")
    return "\n".join(out) + "\n"


def should_parse_scene(rel_path: str) -> bool:
    rp = norm(rel_path).lower()
    if any(rp.startswith(p.lower()) for p in SCENE_EXCLUDE_PREFIXES):
        return False
    if SCENE_INCLUDE_PREFIXES:
        return any(rp.startswith(p.lower()) for p in SCENE_INCLUDE_PREFIXES)
    return True


def parse_tscn_hierarchy(path: Path, rel_path: str) -> str:
    try:
        content = read_text(path)
    except Exception as e:
        return f"### 🎬 SCENE: {rel_path}\n> Error reading: {e}\n\n"

    def get_attr(line: str, attr: str):
        m = re.search(rf'{attr}="([^"]*)"', line)
        return m.group(1) if m else None

    ext_scripts = {}
    for line in content.splitlines():
        s = line.strip()
        if s.startswith("[ext_resource") and 'type="Script"' in s:
            path_match = re.search(r'path="([^"]+)"', s)
            id_match = re.search(r'id="([^"]+)"', s)
            if path_match and id_match:
                ext_scripts[id_match.group(1)] = path_match.group(1)

    tree = {}
    node_types = {}
    scripts = {}
    last_node = None

    for line in content.splitlines():
        s = line.strip()
        if s.startswith("[node ") and s.endswith("]"):
            name = get_attr(s, "name")
            ntype = get_attr(s, "type") or "Unknown"
            parent = get_attr(s, "parent") or "."
            if not name:
                continue
            last_node = name
            node_types[name] = ntype
            tree.setdefault(parent, []).append(name)
        elif last_node and s.startswith("script = ExtResource("):
            m = re.search(r'ExtResource\("([^"]+)"\)', s)
            if m:
                scripts[last_node] = ext_scripts.get(m.group(1), f"ExtResource({m.group(1)})")
        elif last_node and s.startswith("script = SubResource("):
            scripts[last_node] = "SubResource script"

    if not tree:
        return f"### 🎬 SCENE: {rel_path}\n> No nodes found.\n\n"

    is_world = "world" in rel_path.lower() or "level" in rel_path.lower()
    max_depth = MAX_SCENE_DEPTH_WORLD if is_world else MAX_SCENE_DEPTH_DEFAULT

    def is_decor_name(name: str) -> bool:
        return is_world and name.startswith(HIDE_DECOR_PREFIXES)

    out = [f"### 🎬 SCENE: {rel_path}", "```text"]

    def print_nodes(parent_key: str, depth: int):
        if depth > max_depth:
            return []
        res = []
        children = tree.get(parent_key, [])
        hidden = 0
        visible = []
        for child in children:
            if is_decor_name(child):
                hidden += 1
            else:
                visible.append(child)

        indent = "  " * depth
        if hidden:
            res.append(f"{indent}... hidden decor children: {hidden}")

        for child in visible:
            ntype = node_types.get(child, "Unknown")
            script = scripts.get(child)
            script_part = f" | script: {script}" if script else ""
            res.append(f"{indent}- [{ntype}] {child}{script_part}")

            next_key = child if parent_key == "." else f"{parent_key}/{child}"
            if next_key in tree:
                res.extend(print_nodes(next_key, depth + 1))
            elif child in tree:
                res.extend(print_nodes(child, depth + 1))

        return res

    out.extend(print_nodes(".", 0))
    out.append("```")
    out.append("")
    return "\n".join(out)


def main():
    root = Path(".").resolve()
    if not (root / "project.godot").exists():
        print("❌ Run this script from the Godot project root, where project.godot is.")
        return

    print("🕵️ Godot Scout: scanning project...")
    all_files = collect_all_files(root)
    tree = build_tree(all_files, root)
    project_sections = extract_project_godot_sections(root)

    scenes_out = ["## 🎬 SCENES hierarchy\n"]
    scene_count = 0
    skipped_scene_count = 0

    for rel in all_files:
        if Path(rel).suffix.lower() not in SCENE_EXT:
            continue
        if not should_parse_scene(rel):
            skipped_scene_count += 1
            continue
        scenes_out.append(parse_tscn_hierarchy(root / rel, rel))
        scene_count += 1

    md = []
    md.append("# SYSTEM START: GODOT PROJECT SCOUT")
    md.append("")
    md.append("Привет. Это Данил. Это Godot-проект пошаговой тактической RPG Kleynod: Steppe Frontier.")
    md.append("Ниже структура проекта, ключевые настройки и иерархии сцен.")
    md.append("")
    md.append("## 1) PROJECT STRUCTURE")
    md.append("```text")
    md.append(tree.rstrip())
    md.append("```")
    md.append("")
    md.append(project_sections.rstrip())
    md.append("")
    md.append("\n".join(scenes_out).rstrip())
    md.append("")
    md.append("## 2) TASK")
    md.append("[ОПИШИ ПРОБЛЕМУ / ФИЧУ / БАГ ЗДЕСЬ]")
    md.append("")
    md.append("## 3) ТВОЯ ЗАДАЧА (LLM)")
    md.append("1) Определи, какие файлы реально нужны для решения задачи.")
    md.append("2) Верни готовый список `FOCUS_PATTERNS` для `godot_focused_context.py`.")
    md.append("3) Не пытайся угадывать или писать код без focused context (когда файлы не подключены).")
    md.append("")
    md.append("## 4) SCOUT STATS")
    md.append(f"- Total files in tree: {len(all_files)}")
    md.append(f"- Scenes included: {scene_count}")
    md.append(f"- Scenes skipped: {skipped_scene_count}")

    out_path = root / OUTPUT_FILE
    out_path.write_text("\n".join(md), encoding="utf-8")

    print(f"✅ Done: {out_path}")
    print(f"🌳 Files: {len(all_files)}")
    print(f"🎬 Scenes included: {scene_count}")


if __name__ == "__main__":
    main()
