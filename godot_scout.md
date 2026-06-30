# SYSTEM START: GODOT PROJECT SCOUT

Привет. Это Данил. Это Godot-проект пошаговой тактической RPG Kleynod: Steppe Frontier.
Ниже структура проекта, ключевые настройки и иерархии сцен.

## 1) PROJECT STRUCTURE
```text
kleynod-steppe-frontier/
├── content
│   └── combatants
│       └── debug
│           └── debug_sechevik.tres
├── core
│   └── battle
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       └── movement
│           ├── battle_movement_plan.gd
│           └── battle_movement_service.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_focused_context.py
├── godot_scout.py
├── icon.svg
├── icon.svg.import
├── presentation
│   └── battle
│       ├── combatants
│       │   ├── combatant_view.gd
│       │   ├── combatant_view.tscn
│       │   ├── combatant_visual.gd
│       │   └── placeholder_combatant_visual.tscn
│       └── grid
│           ├── battle_grid_view.gd
│           └── battle_grid_view.tscn
├── project.godot
└── scenes
    └── debug
        ├── battle_grid_sandbox.gd
        └── battle_grid_sandbox.tscn
```

## ⚙️ project.godot key sections

### [application]
```ini
[application]

config/name="kleynod-steppe-frontier"
config/features=PackedStringArray("4.5", "Forward Plus")
config/icon="res://icon.svg"

```

### [display]
```ini
[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

## 🎬 SCENES hierarchy

### 🎬 SCENE: presentation/battle/combatants/combatant_view.tscn
```text
- [Node2D] CombatantView | script: res://presentation/battle/combatants/combatant_view.gd
- [Node2D] VisualContainer
- [Marker2D] EffectsAnchor
- [Node2D] StatusAnchor
- [Node2D] IntentAnchor
- [Control] InterfaceRoot
  - [VBoxContainer] VBoxContainer
    - [Label] NameLabel
    - [HBoxContainer] HealthRow
      - [Label] HealthCaption
      - [ProgressBar] HealthBar
      - [Label] HealthValueLabel
    - [HBoxContainer] StaminaRow
      - [Label] StaminaCaption
      - [ProgressBar] StaminaBar
      - [Label] StaminaValueLabel
```

### 🎬 SCENE: presentation/battle/combatants/placeholder_combatant_visual.tscn
```text
- [Node2D] PlaceholderCombatantVisual | script: res://presentation/battle/combatants/combatant_visual.gd
- [Node2D] VisualRoot
  - [Polygon2D] Shadow
  - [Polygon2D] Body
  - [Polygon2D] Head
  - [Line2D] Weapon
  - [Label] Symbol
- [Marker2D] HitAnchor
- [Marker2D] ProjectileAnchor
- [Marker2D] EffectsAnchor
- [AnimationPlayer] AnimationPlayer
```

### 🎬 SCENE: presentation/battle/grid/battle_grid_view.tscn
```text
- [Node2D] BattleGridView | script: res://presentation/battle/grid/battle_grid_view.gd
- [Node2D] SurfaceLayer
- [Node2D] ObstacleLayer
- [Node2D] CombatantLayer
- [Node2D] EffectsLayer
```

### 🎬 SCENE: scenes/debug/battle_grid_sandbox.tscn
```text
- [Node2D] BattleGridSandbox | script: ExtResource(1_sandbox)
- [Unknown] BattleGridView
- [CanvasLayer] CanvasLayer
  - [MarginContainer] InterfaceMargin
    - [PanelContainer] PanelContainer
      - [MarginContainer] ContentMargin
        - [VBoxContainer] VBoxContainer
          - [Label] TitleLabel
          - [Label] InstructionsLabel
          - [Label] StatusLabel
```

## 2) TASK
[ОПИШИ ПРОБЛЕМУ / ФИЧУ / БАГ ЗДЕСЬ]

## 3) ТВОЯ ЗАДАЧА (LLM)
1) Определи, какие файлы реально нужны для решения задачи.
2) Верни готовый список `FOCUS_PATTERNS` для `godot_focused_context.py`.
3) Не пытайся угадывать или писать код без focused context (когда файлы не подключены).

## 4) SCOUT STATS
- Total files in tree: 23
- Scenes included: 4
- Scenes skipped: 0