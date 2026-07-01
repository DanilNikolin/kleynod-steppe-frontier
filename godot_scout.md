# SYSTEM START: GODOT PROJECT SCOUT

Привет. Это Данил. Это Godot-проект пошаговой тактической RPG Kleynod: Steppe Frontier.
Ниже структура проекта, ключевые настройки и иерархии сцен.

## 1) PROJECT STRUCTURE
```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_sabre_slash.tres
│   │       └── debug_sweeping_slash.tres
│   ├── combatants
│   │   └── debug
│   │       └── debug_steppe_raider.tres
│   ├── encounters
│   │   └── debug
│   │       ├── debug_area_attack_encounter.tres
│   │       ├── debug_duel_encounter.tres
│   │       ├── debug_reinforcement_encounter.tres
│   │       └── debug_skirmish_2v2.tres
│   ├── loadouts
│   │   └── debug
│   │       ├── debug_sechevik_loadout.tres
│   │       ├── debug_steppe_raider_loadout.tres
│   │       └── debug_sweeping_sechevik_loadout.tres
│   └── statuses
│       └── debug
│           └── debug_cracked_defense.tres
├── core
│   └── battle
│       ├── abilities
│       │   └── ability_definition.gd
│       ├── actions
│       │   ├── battle_action_command.gd
│       │   ├── battle_action_result.gd
│       │   ├── battle_action_service.gd
│       │   └── battle_effect_result.gd
│       ├── ai
│       │   ├── basic_melee_ai_controller.gd
│       │   └── basic_melee_ai_turn_plan.gd
│       ├── combatants
│       │   ├── combatant_definition.gd
│       │   └── combatant_state.gd
│       ├── damage
│       │   └── damage_calculator.gd
│       ├── effects
│       │   ├── apply_status_effect.gd
│       │   ├── battle_effect.gd
│       │   ├── damage_effect.gd
│       │   └── effect_resolver.gd
│       ├── encounters
│       │   ├── battle_encounter_definition.gd
│       │   ├── battle_reinforcement_wave_definition.gd
│       │   └── combatant_spawn_definition.gd
│       ├── grid
│       │   ├── battle_grid.gd
│       │   └── battle_grid_cell.gd
│       ├── loadouts
│       │   └── combatant_loadout_definition.gd
│       ├── movement
│       │   ├── battle_movement_plan.gd
│       │   └── battle_movement_service.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       ├── stats
│       │   └── battle_stat_modifier.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   └── battle_status_instance.gd
│       ├── targeting
│       │   ├── ability_targeting_definition.gd
│       │   ├── battle_targeting_result.gd
│       │   └── battle_targeting_service.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_focused_context.py
├── godot_scout.py
├── icon.svg
├── icon.svg.import
├── presentation
│   └── battle
│       ├── abilities
│       │   ├── battle_ability_panel.gd
│       │   ├── battle_ability_panel.tscn
│       │   └── battle_ability_presentation_builder.gd
│       ├── actions
│       │   ├── battle_action_outcome.gd
│       │   └── battle_action_runner.gd
│       ├── ai
│       │   ├── basic_melee_ai_turn_outcome.gd
│       │   └── basic_melee_ai_turn_runner.gd
│       ├── combatants
│       │   ├── battle_combatant_hover_panel.gd
│       │   ├── battle_combatant_hover_panel.tscn
│       │   ├── battle_combatant_presenter.gd
│       │   ├── combatant_view.gd
│       │   ├── combatant_view.tscn
│       │   ├── combatant_visual.gd
│       │   └── placeholder_combatant_visual.tscn
│       ├── grid
│       │   ├── battle_grid_overlay_presenter.gd
│       │   ├── battle_grid_view.gd
│       │   └── battle_grid_view.tscn
│       └── movement
│           ├── battle_movement_outcome.gd
│           └── battle_movement_runner.gd
├── project.godot
└── scenes
    ├── debug
    │   ├── battle_grid_sandbox.gd
    │   ├── battle_grid_sandbox.tscn
    │   ├── controllers
    │   │   └── battle_sandbox_interaction_controller.gd
    │   └── presentation
    │       └── battle_debug_log_presenter.gd
    └── debug_sechevik.tres
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

### 🎬 SCENE: presentation/battle/abilities/battle_ability_panel.tscn
```text
- [PanelContainer] BattleAbilityPanel | script: ExtResource(1_panel)
- [MarginContainer] ContentMargin
  - [VBoxContainer] VBoxContainer
    - [Label] ActorLabel
    - [GridContainer] AbilityGrid
    - [PanelContainer] CardPanel
      - [MarginContainer] CardMargin
        - [VBoxContainer] CardVBox
          - [Label] CardTitleLabel
          - [Label] CardMetaLabel
          - [HSeparator] Separator
          - [Label] CardDescriptionLabel
          - [Label] CardEffectsLabel
```

### 🎬 SCENE: presentation/battle/combatants/battle_combatant_hover_panel.tscn
```text
- [PanelContainer] BattleCombatantHoverPanel | script: ExtResource(1_hover)
- [MarginContainer] ContentMargin
  - [VBoxContainer] VBoxContainer
    - [Label] NameLabel
    - [Label] RelationLabel
    - [HSeparator] Separator1
    - [Label] ResourcesLabel
    - [Label] ArmorLabel
    - [Label] AttributesLabel
    - [HSeparator] Separator2
    - [Label] StatusesLabel
```

### 🎬 SCENE: presentation/battle/combatants/combatant_view.tscn
```text
- [Node2D] CombatantView | script: ExtResource(1_view)
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
- [Node2D] PlaceholderCombatantVisual | script: ExtResource(1_visual)
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
- [Node2D] BattleGridView | script: ExtResource(1_grid_view)
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
  - [Unknown] AbilityPanel
  - [Unknown] CombatantHoverPanel
```

## 2) TASK
[ОПИШИ ПРОБЛЕМУ / ФИЧУ / БАГ ЗДЕСЬ]

## 3) ТВОЯ ЗАДАЧА (LLM)
1) Определи, какие файлы реально нужны для решения задачи.
2) Верни готовый список `FOCUS_PATTERNS` для `godot_focused_context.py`.
3) Не пытайся угадывать или писать код без focused context (когда файлы не подключены).

## 4) SCOUT STATS
- Total files in tree: 77
- Scenes included: 6
- Scenes skipped: 0