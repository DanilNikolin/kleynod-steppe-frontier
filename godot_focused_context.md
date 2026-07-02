# GODOT FOCUSED PROJECT CONTEXT

- Project: `kleynod-steppe-frontier`
- Focus patterns: `['core/battle/statuses/battle_status_definition.gd', 'core/battle/combatants/combatant_state.gd', 'core/battle/actions/battle_effect_result.gd', 'core/battle/effects/effect_resolver.gd', 'core/battle/previews/battle_preview_combatant_state.gd', 'core/battle/previews/battle_action_preview_service.gd', 'presentation/battle/previews/battle_action_preview_formatter.gd', 'presentation/battle/abilities/battle_ability_presentation_builder.gd', 'scenes/debug/presentation/battle_debug_log_presenter.gd', 'content/abilities/debug/debug_bandage.tres', 'content/statuses/debug/debug_battle_focus.tres', 'content/statuses/debug/debug_bleeding.tres', 'content/statuses/debug/debug_cracked_defense.tres', 'content/statuses/debug/debug_immobilized.tres', 'content/statuses/debug/debug_regeneration.tres', 'content/statuses/debug/debug_stunned.tres', 'content/loadouts/debug/debug_sechevik_loadout.tres']`
- Allow addons: `False`
- Included files planned: `17`

## 🌳 PROJECT STRUCTURE

```text
kleynod-steppe-frontier/
├── content
│   ├── abilities
│   │   └── debug
│   │       ├── debug_bandage.tres
│   │       ├── debug_battle_focus.tres
│   │       ├── debug_fire_line.tres
│   │       ├── debug_guaranteed_critical.tres
│   │       ├── debug_guard_stance.tres
│   │       ├── debug_hamstring.tres
│   │       ├── debug_raider_chop.tres
│   │       ├── debug_rending_cut.tres
│   │       ├── debug_sabre_slash.tres
│   │       ├── debug_shield_bash.tres
│   │       ├── debug_spirit_mend.tres
│   │       ├── debug_stunning_blow.tres
│   │       └── debug_sweeping_slash.tres
│   ├── combatants
│   │   └── debug
│   │       ├── debug_protected_shaman.tres
│   │       ├── debug_steppe_raider.tres
│   │       └── debug_wooden_wall.tres
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
│           ├── debug_battle_focus.tres
│           ├── debug_bleeding.tres
│           ├── debug_cracked_defense.tres
│           ├── debug_immobilized.tres
│           ├── debug_regeneration.tres
│           └── debug_stunned.tres
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
│       │   ├── effect_resolver.gd
│       │   ├── forced_movement_effect.gd
│       │   ├── grant_guard_effect.gd
│       │   └── heal_effect.gd
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
│       │   ├── battle_forced_movement_resolution.gd
│       │   ├── battle_movement_plan.gd
│       │   ├── battle_movement_service.gd
│       │   └── core
│       │       └── battle
│       │           └── movement
│       │               └── battle_forced_movement_service.gd
│       ├── previews
│       │   ├── battle_action_preview_result.gd
│       │   ├── battle_action_preview_service.gd
│       │   ├── battle_preview_combatant_state.gd
│       │   ├── battle_preview_grid_state.gd
│       │   └── battle_target_preview.gd
│       ├── reinforcements
│       │   └── battle_reinforcement_controller.gd
│       ├── restrictions
│       │   └── battle_action_restriction.gd
│       ├── session
│       │   ├── battle_session.gd
│       │   └── battle_session_factory.gd
│       ├── sides
│       │   └── battle_side_rules.gd
│       ├── stats
│       │   └── battle_stat_modifier.gd
│       ├── statuses
│       │   ├── battle_status_definition.gd
│       │   ├── battle_status_instance.gd
│       │   ├── battle_status_periodic_processor.gd
│       │   ├── battle_status_periodic_trigger.gd
│       │   └── battle_status_periodic_trigger_result.gd
│       ├── targeting
│       │   ├── ability_targeting_definition.gd
│       │   ├── battle_targeting_result.gd
│       │   └── battle_targeting_service.gd
│       └── turns
│           └── battle_turn_controller.gd
├── editorconfig
├── gitattributes
├── gitignore
├── godot_scout.py
├── presentation
│   ├── battle
│   │   ├── abilities
│   │   │   ├── battle_ability_panel.gd
│   │   │   ├── battle_ability_panel.tscn
│   │   │   └── battle_ability_presentation_builder.gd
│   │   ├── actions
│   │   │   ├── battle_action_outcome.gd
│   │   │   └── battle_action_runner.gd
│   │   ├── ai
│   │   │   ├── basic_melee_ai_turn_outcome.gd
│   │   │   └── basic_melee_ai_turn_runner.gd
│   │   ├── combatants
│   │   │   ├── battle_combatant_hover_panel.gd
│   │   │   ├── battle_combatant_hover_panel.tscn
│   │   │   ├── battle_combatant_presenter.gd
│   │   │   ├── combatant_view.gd
│   │   │   ├── combatant_view.tscn
│   │   │   ├── combatant_visual.gd
│   │   │   ├── placeholder_combatant_visual.tscn
│   │   │   └── statuses
│   │   │       ├── battle_status_chip.gd
│   │   │       ├── battle_status_chip.tscn
│   │   │       ├── battle_status_strip.gd
│   │   │       └── battle_status_strip.tscn
│   │   ├── grid
│   │   │   ├── battle_grid_overlay_presenter.gd
│   │   │   ├── battle_grid_view.gd
│   │   │   └── battle_grid_view.tscn
│   │   ├── movement
│   │   │   ├── battle_movement_outcome.gd
│   │   │   └── battle_movement_runner.gd
│   │   └── previews
│   │       ├── battle_action_preview_badge.gd
│   │       ├── battle_action_preview_badge.tscn
│   │       ├── battle_action_preview_formatter.gd
│   │       └── battle_action_preview_presenter.gd
│   └── common
│       └── controls
│           └── collapsible_panel_controller.gd
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

---

## 📌 INCLUDED FILES

## FILE: `content/abilities/debug/debug_bandage.tres`
```text
[gd_resource type="Resource" script_class="AbilityDefinition" format=3 uid="uid://c1sqi1lcu365d"]

[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="1_ability"]
[ext_resource type="Script" uid="uid://36m0bduhwx85" path="res://core/battle/targeting/ability_targeting_definition.gd" id="2_targeting"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="3_effect"]
[ext_resource type="Script" uid="uid://bnwv71blsmx3l" path="res://core/battle/effects/apply_status_effect.gd" id="4_apply_status"]
[ext_resource type="Resource" uid="uid://cgmel2oj0ewfe" path="res://content/statuses/debug/debug_regeneration.tres" id="5_regeneration"]

[sub_resource type="Resource" id="Resource_bandage_regeneration"]
script = ExtResource("4_apply_status")
status_definition = ExtResource("5_regeneration")
effect_id = &"effect_bandage_regeneration"

[sub_resource type="Resource" id="Resource_bandage_targeting"]
script = ExtResource("2_targeting")
aim_relation_mask = 1
aim_offsets = Array[Vector2i]([Vector2i(0, 0)])
affected_relation_mask = 1

[resource]
script = ExtResource("1_ability")
ability_id = &"ability_bandage"
display_name = "Перевязка"
description = "Наложить на себя регенерацию. Требует явного выбора собственной клетки."
stamina_cost = 2
targeting = SubResource("Resource_bandage_targeting")
effects = Array[ExtResource("3_effect")]([SubResource("Resource_bandage_regeneration")])
```

---

## FILE: `content/loadouts/debug/debug_sechevik_loadout.tres`
```text
[gd_resource type="Resource" script_class="CombatantLoadoutDefinition" format=3 uid="uid://cl0uv1vtgisk5"]

[ext_resource type="Script" uid="uid://bis4duqvyinf4" path="res://core/battle/loadouts/combatant_loadout_definition.gd" id="1_loadout"]
[ext_resource type="Script" uid="uid://dkivlbn8e06qo" path="res://core/battle/abilities/ability_definition.gd" id="2_ability"]
[ext_resource type="Resource" uid="uid://bh0xtv0ndcte4" path="res://content/abilities/debug/debug_sabre_slash.tres" id="3_sabre"]
[ext_resource type="Resource" uid="uid://bl21cyxngsid0" path="res://content/abilities/debug/debug_sweeping_slash.tres" id="4_sweeping"]
[ext_resource type="Resource" uid="uid://dikrlb4gdl06f" path="res://content/abilities/debug/debug_rending_cut.tres" id="5_rending"]
[ext_resource type="Resource" uid="uid://c1sqi1lcu365d" path="res://content/abilities/debug/debug_bandage.tres" id="6_bandage"]
[ext_resource type="Resource" uid="uid://caxifmduofpsb" path="res://content/abilities/debug/debug_stunning_blow.tres" id="7_stunning"]
[ext_resource type="Resource" uid="uid://h4ya3an67co3" path="res://content/abilities/debug/debug_hamstring.tres" id="8_hamstring"]
[ext_resource type="Resource" uid="uid://ctwbkmrr7q72" path="res://content/abilities/debug/debug_shield_bash.tres" id="9_shield"]
[ext_resource type="Resource" uid="uid://cvop7dch0d1j3" path="res://content/abilities/debug/debug_fire_line.tres" id="10_fire_line"]
[ext_resource type="Resource" uid="uid://tv50qeyb1d5t" path="res://content/abilities/debug/debug_guard_stance.tres" id="11_guard"]
[ext_resource type="Resource" uid="uid://bs8deir7raav6" path="res://content/abilities/debug/debug_battle_focus.tres" id="12_focus"]
[ext_resource type="Resource" uid="uid://bnk0vuvlj8iqp" path="res://content/abilities/debug/debug_spirit_mend.tres" id="13_mend"]
[ext_resource type="Resource" uid="uid://ce2emj47r03" path="res://content/abilities/debug/debug_guaranteed_critical.tres" id="14_critical"]

[resource]
script = ExtResource("1_loadout")
loadout_id = &"loadout_debug_sechevik"
display_name = "Сечевик с боевым набором"
default_ability_id = &"ability_sabre_slash"
abilities = Array[ExtResource("2_ability")]([ExtResource("3_sabre"), ExtResource("4_sweeping"), ExtResource("5_rending"), ExtResource("6_bandage"), ExtResource("7_stunning"), ExtResource("8_hamstring"), ExtResource("9_shield"), ExtResource("10_fire_line"), ExtResource("11_guard"), ExtResource("12_focus"), ExtResource("13_mend"), ExtResource("14_critical")])
```

---

## FILE: `content/statuses/debug/debug_battle_focus.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://cbu6nr2flo2tp"]

[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="1_qre0n"]
[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="2_modifier"]

[sub_resource type="Resource" id="Resource_strength_modifier"]
script = ExtResource("2_modifier")
stat = 1
amount_per_stack = 3

[sub_resource type="Resource" id="Resource_agility_modifier"]
script = ExtResource("2_modifier")
stat = 2
amount_per_stack = 2

[sub_resource type="Resource" id="Resource_spirit_modifier"]
script = ExtResource("2_modifier")
stat = 3
amount_per_stack = 4

[resource]
script = ExtResource("1_status")
status_id = &"status_debug_battle_focus"
display_name = "Боевой настрой"
description = "Повышает силу на 3, ловкость на 2 и дух на 4."
polarity = 1
tags = Array[StringName]([&"buff", &"attribute_buff"])
duration_turns = 2
stat_modifiers = Array[ExtResource("2_modifier")]([SubResource("Resource_strength_modifier"), SubResource("Resource_agility_modifier"), SubResource("Resource_spirit_modifier")])
```

---

## FILE: `content/statuses/debug/debug_bleeding.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://blpdtthp366w6"]

[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="2_mig4r"]
[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="2_trigger"]
[ext_resource type="Script" uid="uid://djty1vj4ucxrn" path="res://core/battle/effects/damage_effect.gd" id="3_damage"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="5_pn5lx"]

[sub_resource type="Resource" id="Resource_bleeding_damage"]
script = ExtResource("3_damage")
base_damage = 2
strength_scaling = 0.0
armor_piercing = 999
minimum_damage = 2
effect_id = &"bleeding_tick"

[sub_resource type="Resource" id="Resource_end_trigger"]
script = ExtResource("2_trigger")
effects = Array[ExtResource("2_mig4r")]([SubResource("Resource_bleeding_damage")])

[resource]
script = ExtResource("1_status")
status_id = &"debug_bleeding"
display_name = "Кровотечение"
description = "Наносит 2 единицы урона в конце хода носителя."
polarity = 2
tags = Array[StringName]([&"debuff", &"damage_over_time", &"bleeding"])
duration_turns = 2
periodic_triggers = Array[ExtResource("2_trigger")]([SubResource("Resource_end_trigger")])
```

---

## FILE: `content/statuses/debug/debug_cracked_defense.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://biy4yp5jjdsj0"]

[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="1_2048t"]
[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="2_modifier"]

[sub_resource type="Resource" id="Resource_armor_modifier"]
script = ExtResource("2_modifier")
amount_per_stack = -2

[resource]
script = ExtResource("1_status")
status_id = &"status_debug_cracked_defense"
display_name = "Расколотая защита"
description = "Броня снижена на 2. Повторное применение обновляет длительность."
polarity = 2
tags = Array[StringName]([&"debuff", &"armor_debuff"])
duration_turns = 2
stat_modifiers = Array[ExtResource("2_modifier")]([SubResource("Resource_armor_modifier")])
```

---

## FILE: `content/statuses/debug/debug_immobilized.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://bi6tr2n7c1623"]

[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="2_joij2"]
[ext_resource type="Script" uid="uid://b06rnp4fjl0um" path="res://core/battle/restrictions/battle_action_restriction.gd" id="2_restriction"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="4_idydg"]

[sub_resource type="Resource" id="Resource_immobilized_restriction"]
script = ExtResource("2_restriction")
block_movement = true

[resource]
script = ExtResource("1_status")
status_id = &"debug_immobilized"
display_name = "Обездвиживание"
description = "Боец не может двигаться, но сохраняет возможность атаковать."
polarity = 2
tags = Array[StringName]([&"debuff", &"control", &"movement_control", &"immobilized"])
duration_turns = 2
action_restriction = SubResource("Resource_immobilized_restriction")
```

---

## FILE: `content/statuses/debug/debug_regeneration.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://cgmel2oj0ewfe"]

[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="2_trigger"]
[ext_resource type="Script" uid="uid://uc2c7co5a0a2" path="res://core/battle/effects/battle_effect.gd" id="2_xjmqy"]
[ext_resource type="Script" uid="uid://btflpqsqiti3q" path="res://core/battle/effects/heal_effect.gd" id="3_heal"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="5_pkjr4"]

[sub_resource type="Resource" id="Resource_regeneration_heal"]
script = ExtResource("3_heal")
base_healing = 3
effect_id = &"regeneration_tick"

[sub_resource type="Resource" id="Resource_start_trigger"]
script = ExtResource("2_trigger")
timing = 0
effects = Array[ExtResource("2_xjmqy")]([SubResource("Resource_regeneration_heal")])

[resource]
script = ExtResource("1_status")
status_id = &"debug_regeneration"
display_name = "Регенерация"
description = "Восстанавливает 3 HP в начале хода носителя."
polarity = 1
tags = Array[StringName]([&"buff", &"healing_over_time", &"regeneration"])
duration_turns = 2
periodic_triggers = Array[ExtResource("2_trigger")]([SubResource("Resource_start_trigger")])
```

---

## FILE: `content/statuses/debug/debug_stunned.tres`
```text
[gd_resource type="Resource" script_class="BattleStatusDefinition" format=3 uid="uid://b56wvs8w1o26c"]

[ext_resource type="Script" uid="uid://cov0ro3x5ptfd" path="res://core/battle/statuses/battle_status_definition.gd" id="1_status"]
[ext_resource type="Script" uid="uid://bg2aiwnxjuvig" path="res://core/battle/statuses/battle_status_periodic_trigger.gd" id="2_ahdo2"]
[ext_resource type="Script" uid="uid://b06rnp4fjl0um" path="res://core/battle/restrictions/battle_action_restriction.gd" id="2_restriction"]
[ext_resource type="Script" uid="uid://byb5m0xovegd5" path="res://core/battle/stats/battle_stat_modifier.gd" id="4_vndn0"]

[sub_resource type="Resource" id="Resource_stun_restriction"]
script = ExtResource("2_restriction")
skip_owner_turn = true

[resource]
script = ExtResource("1_status")
status_id = &"debug_stunned"
display_name = "Оглушение"
description = "Боец полностью пропускает следующий ход."
polarity = 2
tags = Array[StringName]([&"debuff", &"control", &"hard_control", &"stun"])
action_restriction = SubResource("Resource_stun_restriction")
```

---

## FILE: `core/battle/actions/battle_effect_result.gd`
```gdscript
class_name BattleEffectResult
extends RefCounted


var is_successful: bool = false
var failure_code: StringName = &""

var effect_id: StringName = &""
var effect_kind: StringName = &""

var source_id: StringName = &""
var target_id: StringName = &""

## Сырой урон до критического множителя.
var raw_amount_before_critical: int = 0

## Был ли крит вообще разрешён для данного разрешения эффекта.
## Периодический урон устанавливает false.
var critical_was_enabled: bool = false

## Был ли крит гарантирован настройками DamageEffect.
var critical_was_guaranteed: bool = false

## Итоговый шанс крита от 0 до 100.
var critical_chance_percent: int = 0

## Выпавшее число от 1 до 100.
## Для гарантированного крита остаётся 0, потому что бросок не нужен.
var critical_roll_percent: int = 0

var critical_multiplier: float = 1.0
var was_critical: bool = false

## Для урона это значение уже включает критический множитель.
var raw_amount: int = 0
var mitigated_amount: int = 0
var resolved_amount: int = 0
var applied_amount: int = 0

var overkill_amount: int:
	get:
		if effect_kind != &"damage":
			return 0

		return maxi(
			0,
			resolved_amount
			- guard_absorbed_amount
			- applied_amount
		)

var overheal_amount: int:
	get:
		if effect_kind != &"heal":
			return 0

		return maxi(
			0,
			resolved_amount - applied_amount
		)
var overguard_amount: int:
	get:
		if effect_kind != &"grant_guard":
			return 0

		return maxi(
			0,
			resolved_amount - applied_amount
		)

var target_base_armor: int = 0
var target_status_armor_modifier: int = 0
var target_modified_armor: int = 0

var armor_piercing: int = 0
var effective_armor: int = 0

var previous_guard: int = 0
var current_guard: int = 0
var guard_absorbed_amount: int = 0
var guard_was_bypassed: bool = false

var status_id: StringName = &""
var status_display_name: String = ""

## Статус не был наложен из-за постоянного иммунитета цели.
## Сам эффект считается успешно обработанным.
var status_application_blocked_by_immunity: bool = false

## status_id или tag.
var status_immunity_kind: StringName = &""

## Конкретный status_id либо совпавший тег.
var status_immunity_value: StringName = &""

var status_was_added: bool = false

var previous_status_stack_count: int = 0
var current_status_stack_count: int = 0

var previous_status_remaining_turns: int = 0
var current_status_remaining_turns: int = 0

var previous_target_effective_armor: int = 0
var current_target_effective_armor: int = 0

var previous_value: int = 0
var current_value: int = 0

var target_died: bool = false

var movement_origin: Vector2i = BattleGrid.INVALID_COORDINATE

var movement_destination: Vector2i = BattleGrid.INVALID_COORDINATE

var movement_direction: Vector2i = Vector2i.ZERO

var movement_path: Array[Vector2i] = []

var requested_movement_distance: int = 0
var applied_movement_distance: int = 0

var movement_was_blocked: bool = false
var movement_block_reason: StringName = &""
```

---

## FILE: `core/battle/combatants/combatant_state.gd`
```gdscript
class_name CombatantState
extends RefCounted


signal health_changed(previous_value: int, current_value: int)
signal guard_changed(previous_value: int, current_value: int)
signal stamina_changed(previous_value: int, current_value: int)
signal ability_lock_changed(
	ability_id: StringName,
	previous_remaining_turns: int,
	current_remaining_turns: int
)
signal morale_changed(previous_value: int, current_value: int)
signal status_added(
	status: BattleStatusInstance
)

signal status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int
)

signal status_removed(
	status: BattleStatusInstance,
	reason: StringName
)
signal grid_position_changed(
	previous_position: Vector2i,
	current_position: Vector2i
)
signal died


const INVALID_COORDINATE: Vector2i = Vector2i(-1, -1)

enum AbilityLockKind {
	NONE,
	INITIAL,
	COOLDOWN,
}
var instance_id: StringName
var definition: CombatantDefinition
var team_id: StringName
var loadout: CombatantLoadoutDefinition

var grid_position: Vector2i = INVALID_COORDINATE

var strength: int
var agility: int
var spirit: int

var max_health: int
var current_health: int

var current_guard: int

var armor: int

var max_stamina: int
var current_stamina: int
var stamina_regeneration: int

var initiative: int

var max_morale: int
var current_morale: int

var _statuses_by_id: Dictionary = {}
var _ability_lock_turns_by_id: Dictionary = {}
var _initially_locked_ability_ids: Dictionary = {}
var _cooldowns_started_this_turn: Dictionary = {}

var is_alive: bool:
	get:
		return current_health > 0


func _init(
	p_instance_id: StringName,
	p_definition: CombatantDefinition,
	p_team_id: StringName,
	p_loadout: CombatantLoadoutDefinition,
	p_grid_position: Vector2i = INVALID_COORDINATE
) -> void:
	assert(
		p_instance_id != &"",
		"CombatantState requires a non-empty instance ID."
	)

	assert(
		p_definition != null,
		"CombatantState requires a CombatantDefinition."
	)

	assert(
		p_loadout != null,
		"CombatantState requires a CombatantLoadoutDefinition."
	)

	instance_id = p_instance_id
	definition = p_definition
	team_id = p_team_id
	loadout = p_loadout
	grid_position = p_grid_position

	_initialize_runtime_attributes()


func _initialize_runtime_attributes() -> void:
	strength = definition.base_strength
	agility = definition.base_agility
	spirit = definition.base_spirit

	max_health = definition.max_health
	current_health = max_health

	current_guard = 0

	armor = definition.base_armor

	max_stamina = definition.max_stamina
	current_stamina = max_stamina
	stamina_regeneration = definition.stamina_regeneration

	initiative = definition.base_initiative

	max_morale = definition.base_morale
	current_morale = max_morale

	_initialize_ability_locks()


func set_grid_position(new_position: Vector2i) -> void:
	if grid_position == new_position:
		return

	var previous_position := grid_position
	grid_position = new_position

	grid_position_changed.emit(
		previous_position,
		grid_position
	)


func can_spend_stamina(amount: int) -> bool:
	return amount >= 0 and current_stamina >= amount


func spend_stamina(amount: int) -> bool:
	if amount < 0:
		return false

	if current_stamina < amount:
		return false

	var previous_value := current_stamina
	current_stamina -= amount

	stamina_changed.emit(
		previous_value,
		current_stamina
	)

	return true


func restore_stamina(amount: int) -> int:
	if amount <= 0:
		return 0

	var previous_value := current_stamina

	current_stamina = mini(
		max_stamina,
		current_stamina + amount
	)

	var restored_amount := current_stamina - previous_value

	if restored_amount > 0:
		stamina_changed.emit(
			previous_value,
			current_stamina
		)

	return restored_amount


func restore_round_stamina() -> int:
	return restore_stamina(stamina_regeneration)

func grant_guard(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_guard

	current_guard = mini(
		max_health,
		current_guard + amount
	)

	var granted_amount := (
		current_guard - previous_value
	)

	if granted_amount > 0:
		guard_changed.emit(
			previous_value,
			current_guard
		)

	return granted_amount


func absorb_damage_with_guard(
	amount: int
) -> int:
	if amount <= 0 or current_guard <= 0:
		return 0

	var previous_value := current_guard

	var absorbed_amount := mini(
		amount,
		current_guard
	)

	current_guard -= absorbed_amount

	guard_changed.emit(
		previous_value,
		current_guard
	)

	return absorbed_amount


func clear_guard() -> int:
	if current_guard <= 0:
		return 0

	var previous_value := current_guard
	current_guard = 0

	guard_changed.emit(
		previous_value,
		current_guard
	)

	return previous_value

func apply_resolved_damage(
	amount: int,
	bypass_guard: bool = false
) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var remaining_damage := amount

	if not bypass_guard:
		remaining_damage -= (
			absorb_damage_with_guard(
				remaining_damage
			)
		)

	if remaining_damage <= 0:
		return 0

	var previous_value := current_health

	current_health = maxi(
		0,
		current_health - remaining_damage
	)

	var received_damage := (
		previous_value - current_health
	)

	if received_damage > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	if previous_value > 0 and current_health == 0:
		clear_guard()

		clear_statuses(
			&"owner_defeated"
		)

		died.emit()

	return received_damage


func heal(amount: int) -> int:
	if amount <= 0 or not is_alive:
		return 0

	var previous_value := current_health

	current_health = mini(
		max_health,
		current_health + amount
	)

	var healed_amount := current_health - previous_value

	if healed_amount > 0:
		health_changed.emit(
			previous_value,
			current_health
		)

	return healed_amount


func set_morale(new_value: int) -> void:
	var clamped_value := clampi(
		new_value,
		0,
		max_morale
	)

	if current_morale == clamped_value:
		return

	var previous_value := current_morale
	current_morale = clamped_value

	morale_changed.emit(
		previous_value,
		current_morale
	)


func change_morale(amount: int) -> int:
	var previous_value := current_morale

	set_morale(current_morale + amount)

	return current_morale - previous_value


func get_abilities() -> Array[AbilityDefinition]:
	if loadout == null:
		return []

	return loadout.get_abilities()


func has_ability(
	ability_id: StringName
) -> bool:
	return (
		loadout != null
		and loadout.has_ability(
			ability_id
		)
	)


func get_ability(
	ability_id: StringName
) -> AbilityDefinition:
	if loadout == null:
		return null

	return loadout.get_ability(
		ability_id
	)


func get_default_ability() -> AbilityDefinition:
	if loadout == null:
		return null

	return loadout.get_default_ability()

func get_ability_lock_remaining_turns(
	ability_id: StringName
) -> int:
	if ability_id == &"":
		return 0

	if not _ability_lock_turns_by_id.has(
		ability_id
	):
		return 0

	return maxi(
		0,
		int(
			_ability_lock_turns_by_id[
				ability_id
			]
		)
	)


func get_ability_lock_kind(
	ability_id: StringName
) -> int:
	if (
		get_ability_lock_remaining_turns(
			ability_id
		) <= 0
	):
		return AbilityLockKind.NONE

	if _initially_locked_ability_ids.has(
		ability_id
	):
		return AbilityLockKind.INITIAL

	return AbilityLockKind.COOLDOWN


func is_ability_locked(
	ability_id: StringName
) -> bool:
	return (
		get_ability_lock_remaining_turns(
			ability_id
		) > 0
	)


func start_ability_cooldown(
	ability: AbilityDefinition
) -> bool:
	if ability == null:
		return false

	if ability.ability_id == &"":
		return false

	if not has_ability(
		ability.ability_id
	):
		return false

	var cooldown_turns := maxi(
		0,
		ability.cooldown_turns
	)

	if cooldown_turns <= 0:
		return false

	var previous_remaining_turns := (
		get_ability_lock_remaining_turns(
			ability.ability_id
		)
	)

	_ability_lock_turns_by_id[
		ability.ability_id
	] = cooldown_turns

	_initially_locked_ability_ids.erase(
		ability.ability_id
	)

	_cooldowns_started_this_turn[
		ability.ability_id
	] = true

	ability_lock_changed.emit(
		ability.ability_id,
		previous_remaining_turns,
		cooldown_turns
	)

	return true


func advance_ability_cooldowns_after_owner_turn() -> void:
	var ability_ids: Array = (
		_ability_lock_turns_by_id.keys()
	)

	for value in ability_ids:
		var ability_id: StringName = value

		if _cooldowns_started_this_turn.has(
			ability_id
		):
			continue

		var previous_remaining_turns := (
			get_ability_lock_remaining_turns(
				ability_id
			)
		)

		if previous_remaining_turns <= 0:
			_ability_lock_turns_by_id.erase(
				ability_id
			)

			_initially_locked_ability_ids.erase(
				ability_id
			)

			continue

		var current_remaining_turns := maxi(
			0,
			previous_remaining_turns - 1
		)

		if current_remaining_turns <= 0:
			_ability_lock_turns_by_id.erase(
				ability_id
			)

			_initially_locked_ability_ids.erase(
				ability_id
			)

		else:
			_ability_lock_turns_by_id[
				ability_id
			] = current_remaining_turns

		ability_lock_changed.emit(
			ability_id,
			previous_remaining_turns,
			current_remaining_turns
		)

	_cooldowns_started_this_turn.clear()


func _initialize_ability_locks() -> void:
	_ability_lock_turns_by_id.clear()
	_initially_locked_ability_ids.clear()
	_cooldowns_started_this_turn.clear()

	if loadout == null:
		return

	for ability in loadout.get_abilities():
		if ability == null:
			continue

		if ability.initial_lock_turns <= 0:
			continue

		_ability_lock_turns_by_id[
			ability.ability_id
		] = ability.initial_lock_turns

		_initially_locked_ability_ids[
			ability.ability_id
		] = true

func get_active_statuses() -> Array[BattleStatusInstance]:
	var result: Array[BattleStatusInstance] = []

	for value in _statuses_by_id.values():
		var status := (
			value as BattleStatusInstance
		)

		if status == null:
			continue

		result.append(
			status
		)

	return result


func get_status(
	status_id: StringName
) -> BattleStatusInstance:
	if status_id == &"":
		return null

	if not _statuses_by_id.has(
		status_id
	):
		return null

	return (
		_statuses_by_id[status_id]
		as BattleStatusInstance
	)


func has_status(
	status_id: StringName
) -> bool:
	return get_status(
		status_id
	) != null


func add_status(
	status_definition: BattleStatusDefinition,
	source_instance_id: StringName = &""
) -> BattleStatusInstance:
	if status_definition == null:
		return null

	if not status_definition.is_valid_definition():
		return null

	if (
		definition != null
		and definition.is_immune_to_status(
			status_definition
		)
	):
		return null

	var existing_status := get_status(
		status_definition.status_id
	)

	if existing_status != null:
		var previous_stack_count := (
			existing_status.stack_count
		)

		var previous_remaining_turns := (
			existing_status.remaining_turns
		)

		existing_status.reapply(
			source_instance_id
		)

		status_updated.emit(
			existing_status,
			previous_stack_count,
			previous_remaining_turns
		)

		return existing_status

	var new_status := BattleStatusInstance.new(
		status_definition,
		source_instance_id
	)

	_statuses_by_id[
		status_definition.status_id
	] = new_status

	status_added.emit(
		new_status
	)

	return new_status


func remove_status(
	status_id: StringName,
	reason: StringName = &"removed"
) -> bool:
	var status := get_status(
		status_id
	)

	if status == null:
		return false

	_statuses_by_id.erase(
		status_id
	)

	status_removed.emit(
		status,
		reason
	)

	return true


func clear_statuses(
	reason: StringName = &"cleared"
) -> void:
	var status_ids: Array = (
		_statuses_by_id.keys()
	)

	for value in status_ids:
		var status_id: StringName = value

		remove_status(
			status_id,
			reason
		)


func advance_statuses_after_owner_turn() -> Array[StringName]:
	var expired_status_ids: Array[StringName] = []

	var statuses := get_active_statuses()

	for status in statuses:
		if status == null:
			continue

		var previous_stack_count := (
			status.stack_count
		)

		var previous_remaining_turns := (
			status.remaining_turns
		)

		status.advance_owner_turn()

		if status.is_expired:
			expired_status_ids.append(
				status.status_id
			)

			remove_status(
				status.status_id,
				&"expired"
			)

			continue

		status_updated.emit(
			status,
			previous_stack_count,
			previous_remaining_turns
		)

	return expired_status_ids

func must_skip_turn() -> bool:
	return not get_turn_skip_status_ids().is_empty()


func is_movement_restricted() -> bool:
	return not (
		get_movement_restriction_status_ids()
		.is_empty()
	)


func is_ability_restricted(
	ability_id: StringName
) -> bool:
	return not (
		get_ability_restriction_status_ids(
			ability_id
		).is_empty()
	)


func get_turn_skip_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction.skip_owner_turn
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func get_movement_restriction_status_ids() -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction
			.prevents_movement()
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func get_ability_restriction_status_ids(
	ability_id: StringName
) -> Array[StringName]:
	var result: Array[StringName] = []

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		var restriction := (
			status.definition
			.action_restriction
		)

		if (
			restriction == null
			or not restriction
			.prevents_ability(
				ability_id
			)
		):
			continue

		result.append(
			status.status_id
		)

	result.sort_custom(
		Callable(
			self,
			"_is_status_id_before"
		)
	)

	return result


func _is_status_id_before(
	first: StringName,
	second: StringName
) -> bool:
	return String(first) < String(second)

func get_stat_base_value(
	stat: int
) -> int:
	match stat:
		BattleStatModifier.Stat.ARMOR:
			return armor

		BattleStatModifier.Stat.STRENGTH:
			return strength

		BattleStatModifier.Stat.AGILITY:
			return agility

		BattleStatModifier.Stat.SPIRIT:
			return spirit

	return 0


func get_stat_modifier_total(
	stat: int
) -> int:
	var total: int = 0

	for status in get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		for modifier in (
			status.definition.stat_modifiers
		):
			if modifier == null:
				continue

			if modifier.stat != stat:
				continue

			total += modifier.get_total_amount(
				status.stack_count
			)

	return total


# Оставляем старое имя как совместимый переходный метод,
# чтобы уже существующий код не сломался.
func get_status_modifier_total(
	stat: int
) -> int:
	return get_stat_modifier_total(
		stat
	)


func get_effective_stat(
	stat: int
) -> int:
	return maxi(
		0,
		get_stat_base_value(stat)
		+ get_stat_modifier_total(stat)
	)


func get_effective_strength() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.STRENGTH
	)


func get_effective_agility() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.AGILITY
	)


func get_effective_spirit() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.SPIRIT
	)


func get_effective_armor() -> int:
	return get_effective_stat(
		BattleStatModifier.Stat.ARMOR
	)
```

---

## FILE: `core/battle/effects/effect_resolver.gd`
```gdscript
class_name EffectResolver
extends RefCounted


const FAILURE_INVALID_EFFECT: StringName = &"invalid_effect"
const FAILURE_INVALID_SOURCE: StringName = &"invalid_source"
const FAILURE_INVALID_TARGET: StringName = &"invalid_target"
const FAILURE_UNSUPPORTED_EFFECT: StringName = &"unsupported_effect"

const FAILURE_INVALID_STATUS_DEFINITION: StringName = (
	&"invalid_status_definition"
)

const FAILURE_STATUS_APPLICATION_FAILED: StringName = (
	&"status_application_failed"
)


var damage_calculator := DamageCalculator.new()

var forced_movement_service := (
	BattleForcedMovementService.new()
)

var random_number_generator: RandomNumberGenerator


func _init(
	p_random_number_generator: RandomNumberGenerator = null
) -> void:
	if p_random_number_generator != null:
		random_number_generator = (
			p_random_number_generator
		)

		return

	random_number_generator = (
		RandomNumberGenerator.new()
	)

	random_number_generator.randomize()

func can_resolve(
	effect: BattleEffect
) -> bool:
	return (
		effect is DamageEffect
		or effect is HealEffect
		or effect is GrantGuardEffect
		or effect is ApplyStatusEffect
		or effect is ForcedMovementEffect
	)


func resolve(
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession = null,
	bypass_guard: bool = false,
	allow_critical: bool = true
) -> BattleEffectResult:
	if effect == null:
		return _create_failure_result(
			FAILURE_INVALID_EFFECT,
			effect,
			source,
			target
		)

	if source == null:
		return _create_failure_result(
			FAILURE_INVALID_SOURCE,
			effect,
			source,
			target
		)

	if target == null:
		return _create_failure_result(
			FAILURE_INVALID_TARGET,
			effect,
			source,
			target
		)

	if effect is DamageEffect:
		return _resolve_damage(
			effect as DamageEffect,
			source,
			target,
			bypass_guard,
			allow_critical
		)

	if effect is HealEffect:
		return _resolve_heal(
			effect as HealEffect,
			source,
			target
		)

	if effect is GrantGuardEffect:
		return _resolve_grant_guard(
			effect as GrantGuardEffect,
			source,
			target
		)

	if effect is ApplyStatusEffect:
		return _resolve_apply_status(
			effect as ApplyStatusEffect,
			source,
			target
		)

	if effect is ForcedMovementEffect:
		return _resolve_forced_movement(
			effect as ForcedMovementEffect,
			source,
			target,
			session
		)

	return _create_failure_result(
		FAILURE_UNSUPPORTED_EFFECT,
		effect,
		source,
		target
	)


func _resolve_damage(
	effect: DamageEffect,
	source: CombatantState,
	target: CombatantState,
	bypass_guard: bool,
	allow_critical: bool
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.target_base_armor = (
		target.armor
	)

	result.target_status_armor_modifier = (
		target.get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	result.target_modified_armor = (
		target.get_effective_armor()
	)

	result.armor_piercing = (
		effect.armor_piercing
	)

	result.effective_armor = (
		damage_calculator.calculate_effective_armor(
			target,
			effect
		)
	)

	result.raw_amount_before_critical = (
		damage_calculator.calculate_raw_damage(
			source,
			effect
		)
	)

	result.critical_was_enabled = (
		allow_critical
		and effect.crit_mode
			!= DamageEffect.CritMode.DISABLED
	)

	result.critical_multiplier = (
		effect.critical_multiplier
	)

	result.critical_chance_percent = (
		damage_calculator
		.calculate_critical_chance_percent(
			source,
			effect,
			allow_critical
		)
	)

	if result.critical_was_enabled:
		match effect.crit_mode:
			DamageEffect.CritMode.GUARANTEED:
				result.critical_was_guaranteed = true
				result.was_critical = true

			DamageEffect.CritMode.STANDARD:
				if result.critical_chance_percent > 0:
					result.critical_roll_percent = (
						random_number_generator
						.randi_range(
							1,
							100
						)
					)

					result.was_critical = (
						result
						.critical_roll_percent
						<= result
						.critical_chance_percent
					)

	result.raw_amount = (
		result.raw_amount_before_critical
	)

	if result.was_critical:
		result.raw_amount = (
			damage_calculator
			.apply_critical_multiplier(
				result
					.raw_amount_before_critical,
				result.critical_multiplier
			)
		)

	result.resolved_amount = (
		damage_calculator
		.calculate_resolved_damage_from_raw(
			target,
			effect,
			result.raw_amount
		)
	)

	result.mitigated_amount = maxi(
		0,
		result.raw_amount
		- result.resolved_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.guard_was_bypassed = (
		bypass_guard
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = (
		target.apply_resolved_damage(
			result.resolved_amount,
			bypass_guard
		)
	)

	result.current_guard = (
		target.current_guard
	)

	if bypass_guard:
		result.guard_absorbed_amount = 0

	else:
		result.guard_absorbed_amount = maxi(
			0,
			result.previous_guard
			- result.current_guard
		)

	result.current_value = (
		target.current_health
	)

	result.target_died = (
		result.previous_value > 0
		and result.current_value == 0
	)

	result.is_successful = true

	return result


func _resolve_heal(
	effect: HealEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"heal"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	var spirit_healing := floori(
		float(
			source.get_effective_spirit()
		)
		* effect.spirit_scaling
	)

	result.raw_amount = maxi(
		0,
		effect.base_healing
		+ spirit_healing
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_value = (
		target.current_health
	)

	result.applied_amount = target.heal(
		result.resolved_amount
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true

	return result

func _resolve_grant_guard(
	effect: GrantGuardEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"grant_guard"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.guard_amount
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.previous_value = (
		target.current_guard
	)

	result.applied_amount = target.grant_guard(
		result.resolved_amount
	)

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_guard
	)

	result.is_successful = true

	return result
	
func _resolve_apply_status(
	effect: ApplyStatusEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"apply_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	if (
		effect.status_definition == null
		or not effect
		.status_definition
		.is_valid_definition()
	):
		result.failure_code = (
			FAILURE_INVALID_STATUS_DEFINITION
		)

		return result

	var status_definition := (
		effect.status_definition
	)

	result.status_id = (
		status_definition.status_id
	)

	result.status_display_name = (
		status_definition.display_name
	)

	if target.definition != null:
		if target.definition.has_status_id_immunity(
			status_definition.status_id
		):
			result.status_application_blocked_by_immunity = true
			result.status_immunity_kind = &"status_id"
			result.status_immunity_value = (
				status_definition.status_id
			)

			result.is_successful = true
			return result

		var matching_immunity_tag := (
			target.definition
			.get_matching_status_immunity_tag(
				status_definition
			)
		)

		if matching_immunity_tag != &"":
			result.status_application_blocked_by_immunity = true
			result.status_immunity_kind = &"tag"
			result.status_immunity_value = (
				matching_immunity_tag
			)

			result.is_successful = true
			return result

	var existing_status := target.get_status(
		status_definition.status_id
	)

	result.status_was_added = (
		existing_status == null
	)

	if existing_status != null:
		result.previous_status_stack_count = (
			existing_status.stack_count
		)

		result.previous_status_remaining_turns = (
			existing_status.remaining_turns
		)

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	var applied_status := target.add_status(
		status_definition,
		source.instance_id
	)

	if applied_status == null:
		result.failure_code = (
			FAILURE_STATUS_APPLICATION_FAILED
		)

		return result

	result.current_status_stack_count = (
		applied_status.stack_count
	)

	result.current_status_remaining_turns = (
		applied_status.remaining_turns
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true

	return result
	
func _resolve_forced_movement(
	effect: ForcedMovementEffect,
	source: CombatantState,
	target: CombatantState,
	session: BattleSession
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"forced_movement"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.requested_movement_distance = (
		effect.distance
	)

	result.movement_origin = (
		target.grid_position
	)

	if session == null or session.grid == null:
		result.failure_code = (
			&"invalid_session"
		)

		return result

	var resolution := (
		forced_movement_service
		.create_resolution(
			session.grid,
			source,
			target,
			effect
		)
	)

	if not resolution.is_valid:
		result.failure_code = (
			resolution.failure_code
		)

		return result

	result.movement_origin = (
		resolution.origin
	)

	result.movement_destination = (
		resolution.destination
	)

	result.movement_direction = (
		resolution.direction
	)

	result.movement_path = (
		resolution.path.duplicate()
	)

	result.applied_movement_distance = (
		resolution.get_applied_distance()
	)

	result.movement_was_blocked = (
		resolution.was_blocked
	)

	result.movement_block_reason = (
		resolution.block_reason
	)

	var committed := (
		forced_movement_service
		.commit_resolution(
			session.grid,
			target,
			resolution
		)
	)

	if not committed:
		result.failure_code = (
			&"forced_movement_commit_failed"
		)

		return result

	result.is_successful = true
	return result

func _create_failure_result(
	failure_code: StringName,
	effect: BattleEffect,
	source: CombatantState,
	target: CombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.failure_code = failure_code

	if effect != null:
		result.effect_id = effect.effect_id

	if source != null:
		result.source_id = source.instance_id

	if target != null:
		result.target_id = target.instance_id

	return result
```

---

## FILE: `core/battle/previews/battle_action_preview_service.gd`
```gdscript
class_name BattleActionPreviewService
extends RefCounted


const FAILURE_PREVIEW_EFFECT_FAILED: StringName = (
	&"preview_effect_failed"
)

const FAILURE_PREVIEW_MOVEMENT_COMMIT_FAILED: StringName = (
	&"preview_movement_commit_failed"
)


var action_service: BattleActionService

var damage_calculator := DamageCalculator.new()

var forced_movement_service := (
	BattleForcedMovementService.new()
)


func _init(
	p_action_service: BattleActionService
) -> void:
	assert(
		p_action_service != null,
		"Action preview service requires "
		+"a battle action service."
	)

	action_service = p_action_service


func create_preview(
	session: BattleSession,
	command: BattleActionCommand
) -> BattleActionPreviewResult:
	var result := (
		BattleActionPreviewResult.new()
	)

	if command != null:
		result.aim_coordinate = (
			command.aim_coordinate
		)

		if command.actor != null:
			result.actor_id = (
				command.actor.instance_id
			)

		if command.ability != null:
			result.ability_id = (
				command.ability.ability_id
			)

	var failure_code := (
		action_service.get_validation_failure(
			session,
			command
		)
	)

	if failure_code != &"":
		result.failure_code = failure_code
		return result

	var targeting_result := (
		action_service.get_targeting_result(
			session,
			command
		)
	)

	if not targeting_result.is_valid:
		result.failure_code = (
			targeting_result.failure_code
		)

		return result

	var normal_simulation := _simulate(
		session,
		command,
		targeting_result,
		false
	)

	if not bool(
		normal_simulation.get(
			"is_valid",
			false
		)
	):
		result.failure_code = (
			normal_simulation.get(
				"failure_code",
				FAILURE_PREVIEW_EFFECT_FAILED
			)
		)

		return result

	var critical_simulation := _simulate(
		session,
		command,
		targeting_result,
		true
	)

	if not bool(
		critical_simulation.get(
			"is_valid",
			false
		)
	):
		result.failure_code = (
			critical_simulation.get(
				"failure_code",
				FAILURE_PREVIEW_EFFECT_FAILED
			)
		)

		return result

	var normal_states: Dictionary = (
		normal_simulation[
			"states"
		]
	)

	var critical_states: Dictionary = (
		critical_simulation[
			"states"
		]
	)

	var normal_results: Dictionary = (
		normal_simulation[
			"results_by_target"
		]
	)

	var critical_results: Dictionary = (
		critical_simulation[
			"results_by_target"
		]
	)

	for original_target in (
		targeting_result.affected_combatants
	):
		if original_target == null:
			continue

		var target_id := (
			original_target.instance_id
		)

		var normal_state := (
			normal_states.get(
				target_id
			) as BattlePreviewCombatantState
		)

		var critical_state := (
			critical_states.get(
				target_id
			) as BattlePreviewCombatantState
		)

		if (
			normal_state == null
			or critical_state == null
		):
			continue

		var target_preview := (
			BattleTargetPreview.new()
		)

		target_preview.target_id = target_id

		if original_target.definition != null:
			target_preview.display_name = (
				original_target
				.definition
				.display_name
			)

		target_preview.initial_health = (
			original_target.current_health
		)

		target_preview.initial_guard = (
			original_target.current_guard
		)

		target_preview.initial_position = (
			original_target.grid_position
		)

		target_preview.normal_final_health = (
			normal_state.current_health
		)

		target_preview.normal_final_guard = (
			normal_state.current_guard
		)

		target_preview.normal_final_position = (
			normal_state.grid_position
		)

		target_preview.critical_final_health = (
			critical_state.current_health
		)

		target_preview.critical_final_guard = (
			critical_state.current_guard
		)

		target_preview.critical_final_position = (
			critical_state.grid_position
		)

		target_preview.normal_effect_results = (
			_get_effect_results(
				normal_results,
				target_id
			)
		)

		target_preview.critical_effect_results = (
			_get_effect_results(
				critical_results,
				target_id
			)
		)

		result.target_previews.append(
			target_preview
		)

	result.is_valid = true
	return result


func _simulate(
	session: BattleSession,
	command: BattleActionCommand,
	targeting_result: BattleTargetingResult,
	force_standard_critical: bool
) -> Dictionary:
	var preview_states: Dictionary = {}

	for combatant in session.get_all_combatants():
		if combatant == null:
			continue

		preview_states[
			combatant.instance_id
		] = BattlePreviewCombatantState.new(
			combatant
		)

	var preview_grid := (
		BattlePreviewGridState.new(
			session
		)
	)

	var results_by_target: Dictionary = {}

	var source := (
		preview_states.get(
			command.actor.instance_id
		) as BattlePreviewCombatantState
	)

	if source == null:
		return {
			"is_valid": false,
			"failure_code": (
				BattleActionService
				.FAILURE_INVALID_ACTOR
			),
		}

	for original_target in (
		targeting_result.affected_combatants
	):
		if original_target == null:
			continue

		var target := (
			preview_states.get(
				original_target.instance_id
			) as BattlePreviewCombatantState
		)

		if target == null:
			continue

		var target_results: Array[BattleEffectResult] = []

		results_by_target[
			target.instance_id
		] = target_results

		for effect in command.ability.effects:
			if not target.is_alive:
				break

			var effect_result := _preview_effect(
				effect,
				source,
				target,
				preview_grid,
				force_standard_critical
			)

			target_results.append(
				effect_result
			)

			results_by_target[
				target.instance_id
			] = target_results

			if (
				effect_result == null
				or not effect_result.is_successful
			):
				return {
					"is_valid": false,
					"failure_code": (
						effect_result.failure_code
						if effect_result != null
						else FAILURE_PREVIEW_EFFECT_FAILED
					),
				}

			if effect_result.target_died:
				preview_grid.remove_occupant(
					target.instance_id
				)

	return {
		"is_valid": true,
		"failure_code": &"",
		"states": preview_states,
		"results_by_target": (
			results_by_target
		),
	}


func _preview_effect(
	effect: BattleEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState,
	preview_grid: BattlePreviewGridState,
	force_standard_critical: bool
) -> BattleEffectResult:
	if effect is DamageEffect:
		return _preview_damage(
			effect as DamageEffect,
			source,
			target,
			force_standard_critical
		)

	if effect is HealEffect:
		return _preview_heal(
			effect as HealEffect,
			source,
			target
		)

	if effect is GrantGuardEffect:
		return _preview_grant_guard(
			effect as GrantGuardEffect,
			source,
			target
		)

	if effect is ApplyStatusEffect:
		return _preview_apply_status(
			effect as ApplyStatusEffect,
			source,
			target
		)

	if effect is ForcedMovementEffect:
		return _preview_forced_movement(
			effect as ForcedMovementEffect,
			source,
			target,
			preview_grid
		)

	var result := BattleEffectResult.new()
	result.failure_code = (
		BattleActionService
			.FAILURE_UNSUPPORTED_EFFECT
	)

	return result


func _preview_damage(
	effect: DamageEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState,
	force_standard_critical: bool
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"damage"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.target_base_armor = target.armor

	result.target_status_armor_modifier = (
		target.get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	result.target_modified_armor = (
		target.get_effective_armor()
	)

	result.armor_piercing = (
		effect.armor_piercing
	)

	result.effective_armor = (
		damage_calculator
		.calculate_effective_armor_from_value(
			target.get_effective_armor(),
			effect
		)
	)

	result.raw_amount_before_critical = (
		damage_calculator
		.calculate_raw_damage_from_strength(
			source.get_effective_strength(),
			effect
		)
	)

	result.critical_was_enabled = (
		effect.crit_mode
		!= DamageEffect.CritMode.DISABLED
	)

	result.critical_was_guaranteed = (
		effect.crit_mode
		== DamageEffect.CritMode.GUARANTEED
	)

	result.critical_chance_percent = (
		damage_calculator
		.calculate_critical_chance_percent_from_agility(
			source.get_effective_agility(),
			effect,
			true
		)
	)

	result.critical_multiplier = (
		effect.critical_multiplier
	)

	result.was_critical = (
		result.critical_was_guaranteed
		or (
			effect.crit_mode
				== DamageEffect.CritMode.STANDARD
			and force_standard_critical
			and result.critical_chance_percent > 0
		)
	)

	result.raw_amount = (
		result.raw_amount_before_critical
	)

	if result.was_critical:
		result.raw_amount = (
			damage_calculator
			.apply_critical_multiplier(
				result
					.raw_amount_before_critical,
				result.critical_multiplier
			)
		)

	result.resolved_amount = (
		damage_calculator
		.calculate_resolved_damage_from_values(
			result.effective_armor,
			effect,
			result.raw_amount
		)
	)

	result.mitigated_amount = maxi(
		0,
		result.raw_amount
		- result.resolved_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.previous_value = (
		target.current_health
	)

	var remaining_damage := (
		result.resolved_amount
	)

	var absorbed_amount := mini(
		remaining_damage,
		target.current_guard
	)

	target.current_guard -= absorbed_amount
	remaining_damage -= absorbed_amount

	result.guard_absorbed_amount = (
		absorbed_amount
	)

	if remaining_damage > 0:
		var previous_health := (
			target.current_health
		)

		target.current_health = maxi(
			0,
			target.current_health
			- remaining_damage
		)

		result.applied_amount = (
			previous_health
			- target.current_health
		)

	result.target_died = (
		result.previous_value > 0
		and target.current_health == 0
	)

	if result.target_died:
		target.current_guard = 0

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true
	return result


func _preview_heal(
	effect: HealEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"heal"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	var spirit_healing := floori(
		float(
			source.get_effective_spirit()
		)
		* effect.spirit_scaling
	)

	result.raw_amount = maxi(
		0,
		effect.base_healing
		+ spirit_healing
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_value = (
		target.current_health
	)

	target.current_health = mini(
		target.max_health,
		target.current_health
		+ result.resolved_amount
	)

	result.applied_amount = (
		target.current_health
		- result.previous_value
	)

	result.current_value = (
		target.current_health
	)

	result.is_successful = true
	return result


func _preview_grant_guard(
	effect: GrantGuardEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"grant_guard"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.raw_amount = maxi(
		0,
		effect.guard_amount
	)

	result.resolved_amount = (
		result.raw_amount
	)

	result.previous_guard = (
		target.current_guard
	)

	result.previous_value = (
		target.current_guard
	)

	target.current_guard = mini(
		target.max_health,
		target.current_guard
		+ result.resolved_amount
	)

	result.applied_amount = (
		target.current_guard
		- result.previous_guard
	)

	result.current_guard = (
		target.current_guard
	)

	result.current_value = (
		target.current_guard
	)

	result.is_successful = true
	return result


func _preview_apply_status(
	effect: ApplyStatusEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"apply_status"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	var status_definition := (
		effect.status_definition
	)

	if (
		status_definition == null
		or not status_definition
			.is_valid_definition()
	):
		result.failure_code = (
			&"invalid_status_definition"
		)

		return result

	result.status_id = (
		status_definition.status_id
	)

	result.status_display_name = (
		status_definition.display_name
	)

	if target.has_status_id_immunity(
		status_definition.status_id
	):
		result.status_application_blocked_by_immunity = true
		result.status_immunity_kind = &"status_id"
		result.status_immunity_value = (
			status_definition.status_id
		)

		result.is_successful = true
		return result

	var matching_immunity_tag := (
		target.get_matching_status_immunity_tag(
			status_definition
		)
	)

	if matching_immunity_tag != &"":
		result.status_application_blocked_by_immunity = true
		result.status_immunity_kind = &"tag"
		result.status_immunity_value = (
			matching_immunity_tag
		)

		result.is_successful = true
		return result

	var previous_snapshot := (
		target.get_status_snapshot(
			status_definition.status_id
		)
	)

	result.status_was_added = (
		previous_snapshot.is_empty()
	)

	if not previous_snapshot.is_empty():
		result.previous_status_stack_count = int(
			previous_snapshot.get(
				"stack_count",
				0
			)
		)

		result.previous_status_remaining_turns = int(
			previous_snapshot.get(
				"remaining_turns",
				0
			)
		)

	result.previous_target_effective_armor = (
		target.get_effective_armor()
	)

	if not target.apply_status_definition(
		status_definition
	):
		result.failure_code = (
			&"status_application_failed"
		)

		return result

	var current_snapshot := (
		target.get_status_snapshot(
			status_definition.status_id
		)
	)

	result.current_status_stack_count = int(
		current_snapshot.get(
			"stack_count",
			0
		)
	)

	result.current_status_remaining_turns = int(
		current_snapshot.get(
			"remaining_turns",
			0
		)
	)

	result.current_target_effective_armor = (
		target.get_effective_armor()
	)

	result.is_successful = true
	return result


func _preview_forced_movement(
	effect: ForcedMovementEffect,
	source: BattlePreviewCombatantState,
	target: BattlePreviewCombatantState,
	preview_grid: BattlePreviewGridState
) -> BattleEffectResult:
	var result := BattleEffectResult.new()

	result.effect_id = effect.effect_id
	result.effect_kind = &"forced_movement"

	result.source_id = source.instance_id
	result.target_id = target.instance_id

	result.requested_movement_distance = (
		effect.distance
	)

	result.movement_origin = (
		target.grid_position
	)

	var resolution := (
		forced_movement_service
		.create_resolution_from_coordinates(
			source.grid_position,
			target.grid_position,
			target.is_alive,
			effect,
			Callable(
				preview_grid,
				"is_inside"
			),
			Callable(
				preview_grid,
				"is_walkable"
			)
		)
	)

	if not resolution.is_valid:
		result.failure_code = (
			resolution.failure_code
		)

		return result

	result.movement_origin = (
		resolution.origin
	)

	result.movement_destination = (
		resolution.destination
	)

	result.movement_direction = (
		resolution.direction
	)

	result.movement_path = (
		resolution.path.duplicate()
	)

	result.applied_movement_distance = (
		resolution.get_applied_distance()
	)

	result.movement_was_blocked = (
		resolution.was_blocked
	)

	result.movement_block_reason = (
		resolution.block_reason
	)

	for coordinate in resolution.path:
		if not preview_grid.try_move_occupant(
			target.instance_id,
			coordinate
		):
			result.failure_code = (
				FAILURE_PREVIEW_MOVEMENT_COMMIT_FAILED
			)

			return result

		target.grid_position = coordinate

	result.is_successful = true
	return result


func _get_effect_results(
	results_by_target: Dictionary,
	target_id: StringName
) -> Array[BattleEffectResult]:
	var result: Array[BattleEffectResult] = []

	if not results_by_target.has(
		target_id
	):
		return result

	for value in results_by_target[
		target_id
	]:
		var effect_result := (
			value as BattleEffectResult
		)

		if effect_result != null:
			result.append(
				effect_result
			)

	return result
```

---

## FILE: `core/battle/previews/battle_preview_combatant_state.gd`
```gdscript
class_name BattlePreviewCombatantState
extends RefCounted


var original_state: CombatantState

var instance_id: StringName = &""
var definition: CombatantDefinition
var team_id: StringName = &""

var grid_position: Vector2i = (
	BattleGrid.INVALID_COORDINATE
)

var strength: int = 0
var agility: int = 0
var spirit: int = 0
var armor: int = 0

var max_health: int = 1
var current_health: int = 1
var current_guard: int = 0

var _statuses_by_id: Dictionary = {}


var is_alive: bool:
	get:
		return current_health > 0


func _init(
	p_original_state: CombatantState
) -> void:
	assert(
		p_original_state != null,
		"Preview combatant requires an original state."
	)

	original_state = p_original_state

	instance_id = original_state.instance_id
	definition = original_state.definition
	team_id = original_state.team_id
	grid_position = original_state.grid_position

	strength = original_state.strength
	agility = original_state.agility
	spirit = original_state.spirit
	armor = original_state.armor

	max_health = original_state.max_health
	current_health = original_state.current_health
	current_guard = original_state.current_guard

	for status in original_state.get_active_statuses():
		if (
			status == null
			or status.definition == null
		):
			continue

		_statuses_by_id[
			status.status_id
		] = {
			"definition": status.definition,
			"stack_count": status.stack_count,
			"remaining_turns": status.remaining_turns,
		}


func get_status_snapshot(
	status_id: StringName
) -> Dictionary:
	if not _statuses_by_id.has(
		status_id
	):
		return {}

	return _statuses_by_id[
		status_id
	]


func get_stat_modifier_total(
	stat: int
) -> int:
	var total: int = 0

	for value in _statuses_by_id.values():
		var snapshot: Dictionary = value

		var status_definition := (
			snapshot.get(
				"definition"
			) as BattleStatusDefinition
		)

		if status_definition == null:
			continue

		var stack_count := int(
			snapshot.get(
				"stack_count",
				0
			)
		)

		for modifier in (
			status_definition.stat_modifiers
		):
			if (
				modifier == null
				or modifier.stat != stat
			):
				continue

			total += modifier.get_total_amount(
				stack_count
			)

	return total


func get_effective_strength() -> int:
	return maxi(
		0,
		strength
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.STRENGTH
		)
	)


func get_effective_agility() -> int:
	return maxi(
		0,
		agility
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.AGILITY
		)
	)


func get_effective_spirit() -> int:
	return maxi(
		0,
		spirit
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.SPIRIT
		)
	)


func get_effective_armor() -> int:
	return maxi(
		0,
		armor
		+ get_stat_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

func has_status_id_immunity(
	status_id: StringName
) -> bool:
	return (
		definition != null
		and definition.has_status_id_immunity(
			status_id
		)
	)


func get_matching_status_immunity_tag(
	status_definition: BattleStatusDefinition
) -> StringName:
	if definition == null:
		return &""

	return (
		definition
		.get_matching_status_immunity_tag(
			status_definition
		)
	)


func is_immune_to_status(
	status_definition: BattleStatusDefinition
) -> bool:
	return (
		definition != null
		and definition.is_immune_to_status(
			status_definition
		)
	)

func apply_status_definition(
	status_definition: BattleStatusDefinition
) -> bool:
	if status_definition == null:
		return false

	if is_immune_to_status(
		status_definition
	):
		return false

	var existing_snapshot := get_status_snapshot(
		status_definition.status_id
	)

	if existing_snapshot.is_empty():
		_statuses_by_id[
			status_definition.status_id
		] = {
			"definition": status_definition,
			"stack_count": 1,
			"remaining_turns": (
				status_definition.duration_turns
			),
		}

		return true

	var stack_count := int(
		existing_snapshot.get(
			"stack_count",
			1
		)
	)

	var remaining_turns := int(
		existing_snapshot.get(
			"remaining_turns",
			status_definition.duration_turns
		)
	)

	match status_definition.reapply_rule:
		BattleStatusDefinition.ReapplyRule.REFRESH_DURATION:
			remaining_turns = (
				status_definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.ADD_STACK_AND_REFRESH:
			stack_count = mini(
				status_definition.max_stacks,
				stack_count + 1
			)

			remaining_turns = (
				status_definition.duration_turns
			)

		BattleStatusDefinition.ReapplyRule.KEEP_EXISTING:
			pass

	existing_snapshot[
		"stack_count"
	] = stack_count

	existing_snapshot[
		"remaining_turns"
	] = remaining_turns

	_statuses_by_id[
		status_definition.status_id
	] = existing_snapshot

	return true
```

---

## FILE: `core/battle/statuses/battle_status_definition.gd`
```gdscript
@tool
class_name BattleStatusDefinition
extends Resource
enum Polarity {
	NEUTRAL,
	BENEFICIAL,
	HARMFUL,
}

enum ReapplyRule {
	REFRESH_DURATION,
	ADD_STACK_AND_REFRESH,
	KEEP_EXISTING,
}


@export_group("Identity")

@export
var status_id: StringName = &""

@export
var display_name: String = "Unnamed Status"

@export_multiline
var description: String = ""

@export_group("Classification")

## Общий характер статуса.
## Используется будущими cleanse/dispel-эффектами.
@export
var polarity: Polarity = Polarity.NEUTRAL

## Стабильные системные категории:
## bleeding, control, stun, regeneration и другие.
@export
var tags: Array[StringName] = []

@export_group("Lifetime")

## Количество завершённых ходов носителя,
## после которых статус исчезнет.
@export_range(1, 999, 1)
var duration_turns: int = 1

@export_range(1, 99, 1)
var max_stacks: int = 1

@export
var reapply_rule: ReapplyRule = (
	ReapplyRule.REFRESH_DURATION
)


@export_group("Action Restrictions")

@export
var action_restriction: BattleActionRestriction

@export_group("Periodic Effects")

@export
var periodic_triggers: Array[BattleStatusPeriodicTrigger] = []


@export_group("Stat Modifiers")

@export
var stat_modifiers: Array[BattleStatModifier] = []


func has_tag(
	tag: StringName
) -> bool:
	return (
		tag != &""
		and tags.has(tag)
	)

func is_valid_definition() -> bool:
	return get_validation_errors().is_empty()


func get_validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()

	if status_id == &"":
		errors.append(
			"Status ID is empty."
		)

	if display_name.strip_edges().is_empty():
		errors.append(
			"Status display name is empty."
		)

	if duration_turns <= 0:
		errors.append(
			"Status duration must be greater than zero."
		)

	if max_stacks <= 0:
		errors.append(
			"Maximum status stacks must be greater than zero."
		)

	var used_tags: Dictionary = {}

	for tag_index in range(
		tags.size()
	):
		var tag := tags[tag_index]

		if tag == &"":
			errors.append(
				"Status tag at index %d is empty."
				% tag_index
			)

			continue

		if used_tags.has(tag):
			errors.append(
				"Status tag '%s' is duplicated."
				% tag
			)

			continue

		used_tags[tag] = true
		
	for modifier_index in range(
		stat_modifiers.size()
	):
		var modifier := stat_modifiers[
			modifier_index
		]

		if modifier == null:
			errors.append(
				"Stat modifier at index %d is null."
				% modifier_index
			)

			continue

		for modifier_error in (
			modifier.get_validation_errors()
		):
			errors.append(
				"Stat modifier %d: %s"
				% [
					modifier_index,
					modifier_error,
				]
			)

	for trigger_index in range(
		periodic_triggers.size()
	):
		var trigger := periodic_triggers[
			trigger_index
		]

		if trigger == null:
			errors.append(
				"Periodic trigger at index %d is null."
				% trigger_index
			)

			continue

		for trigger_error in (
			trigger.get_validation_errors()
		):
			errors.append(
				"Periodic trigger %d: %s"
				% [
					trigger_index,
					trigger_error,
				]
			)

	if action_restriction != null:
		for restriction_error in (
			action_restriction
			.get_validation_errors()
		):
			errors.append(
				"Action restriction: %s"
				% restriction_error
			)

	return errors
```

---

## FILE: `presentation/battle/abilities/battle_ability_presentation_builder.gd`
```gdscript
class_name BattleAbilityPresentationBuilder
extends RefCounted


static func build_meta_text(
	ability: AbilityDefinition
) -> String:
	if ability == null:
		return ""

	var parts := PackedStringArray()

	parts.append(
		"Цена: %d выносливости"
		% ability.stamina_cost
	)

	if ability.initial_lock_turns > 0:
		parts.append(
			"Стартовая задержка: %s"
			% format_turn_count(
				ability.initial_lock_turns
			)
		)

	if ability.cooldown_turns > 0:
		parts.append(
			"Кулдаун: %s"
			% format_turn_count(
				ability.cooldown_turns
			)
		)

	if ability.targeting != null:
		parts.append(
			"Цель: %s"
			% _build_aim_target_text(
				ability.targeting
			)
		)

		var range_text := _build_range_text(
			ability.targeting
		)

		if not range_text.is_empty():
			parts.append(
				range_text
			)

		if (
			ability.targeting
			.impact_offsets.size() > 1
		):
			parts.append(
				"Область: %d клеток"
				% ability.targeting
				.impact_offsets.size()
			)

	return "  •  ".join(parts)


static func build_effects_text(
	ability: AbilityDefinition,
	actor: CombatantState = null
) -> String:
	if ability == null:
		return "Нет данных о способности."

	if ability.effects.is_empty():
		return "Эффекты отсутствуют."

	var lines := PackedStringArray()

	for effect in ability.effects:
		if effect == null:
			continue

		if effect is DamageEffect:
			lines.append(
				_build_damage_effect_text(
					effect as DamageEffect,
					actor
				)
			)

		elif effect is HealEffect:
			lines.append(
				_build_heal_effect_text(
					effect as HealEffect,
					actor
				)
			)

		elif effect is GrantGuardEffect:
			lines.append(
				_build_guard_effect_text(
					effect as GrantGuardEffect
				)
			)

		elif effect is ApplyStatusEffect:
			lines.append(
				_build_status_effect_text(
					effect as ApplyStatusEffect
				)
			)

		else:
			lines.append(
				"• Эффект: %s"
				% effect.effect_id
			)

	if lines.is_empty():
		return "Эффекты отсутствуют."

	return "\n".join(lines)


static func _build_damage_effect_text(
	effect: DamageEffect,
	actor: CombatantState
) -> String:
	var scaling_percent := roundi(
		effect.strength_scaling * 100.0
	)

	var damage_text: String

	if actor != null:
		var strength_damage := floori(
			float(
				actor.get_effective_strength()
			)
			* effect.strength_scaling
		)

		var predicted_raw_damage := maxi(
			0,
			effect.base_damage
			+ strength_damage
		)

		damage_text = (
			"• Урон: %d "
			% predicted_raw_damage
			+"(%d базового"
			% effect.base_damage
		)

		if effect.strength_scaling > 0.0:
			damage_text += (
				" + %d%% силы = %d"
				% [
					scaling_percent,
					strength_damage,
				]
			)

		damage_text += ")"

	else:
		damage_text = (
			"• Урон: %d базового"
			% effect.base_damage
		)

		if effect.strength_scaling > 0.0:
			damage_text += (
				" + %d%% силы"
				% scaling_percent
			)

	if effect.armor_piercing > 0:
		damage_text += (
			"\n  Пробитие брони: %d"
			% effect.armor_piercing
		)

	if effect.minimum_damage > 0:
		damage_text += (
			"\n  Минимальный урон: %d"
			% effect.minimum_damage
		)

	damage_text += (
		"\n  %s"
		% _build_critical_effect_text(
			effect,
			actor
		)
	)

	return damage_text

static func _build_critical_effect_text(
	effect: DamageEffect,
	actor: CombatantState
) -> String:
	match effect.crit_mode:
		DamageEffect.CritMode.DISABLED:
			return "Крит: нет"

		DamageEffect.CritMode.GUARANTEED:
			return (
				"Крит: гарантирован"
				+"  •  Множитель: ×%s"
				% _format_multiplier(
					effect.critical_multiplier
				)
			)

		DamageEffect.CritMode.STANDARD:
			if actor == null:
				var text := (
					"Крит: 5% + 1% за Ловкость"
				)

				if (
					effect
					.crit_chance_bonus_percent
					!= 0
				):
					text += (
						" %s%% от способности"
						% _format_signed_integer(
							effect
							.crit_chance_bonus_percent
						)
					)

				text += (
					", максимум 35%"
					+"  •  Множитель: ×%s"
					% _format_multiplier(
						effect
						.critical_multiplier
					)
				)

				return text

			var calculator := (
				DamageCalculator.new()
			)

			var chance := (
				calculator
				.calculate_critical_chance_percent(
					actor,
					effect
				)
			)

			return (
				"Крит: %d%%"
				% chance
				+"  •  Множитель: ×%s"
				% _format_multiplier(
					effect.critical_multiplier
				)
			)

	return "Крит: нет"


static func _format_multiplier(
	value: float
) -> String:
	return str(
		snappedf(
			value,
			0.01
		)
	)
	
static func _build_heal_effect_text(
	effect: HealEffect,
	actor: CombatantState
) -> String:
	var scaling_percent := roundi(
		effect.spirit_scaling * 100.0
	)

	if actor == null:
		var text := (
			"• Лечение: %d базового"
			% effect.base_healing
		)

		if effect.spirit_scaling > 0.0:
			text += (
				" + %d%% духа"
				% scaling_percent
			)

		return text

	var spirit_healing := floori(
		float(
			actor.get_effective_spirit()
		)
		* effect.spirit_scaling
	)

	var predicted_healing := maxi(
		0,
		effect.base_healing
		+ spirit_healing
	)

	var text := (
		"• Лечение: %d "
		% predicted_healing
		+"(%d базового"
		% effect.base_healing
	)

	if effect.spirit_scaling > 0.0:
		text += (
			" + %d%% духа = %d"
			% [
				scaling_percent,
				spirit_healing,
			]
		)

	text += ")"

	return text

static func _build_guard_effect_text(
	effect: GrantGuardEffect
) -> String:
	return (
		"• Оборона: +%d"
		% effect.guard_amount
		+"\n  Максимум: здоровье бойца"
	)

static func _build_status_effect_text(
	effect: ApplyStatusEffect
) -> String:
	if effect.status_definition == null:
		return "• Накладывает неизвестный статус."

	var status := effect.status_definition

	var text := (
		"• Статус: «%s»"
		% status.display_name
	)

	text += (
		"\n  Длительность: %s"
		% format_turn_count(
			status.duration_turns
		)
	)

	var modifier_parts := PackedStringArray()

	for modifier in status.stat_modifiers:
		if modifier == null:
			continue

		modifier_parts.append(
			"%s %s"
			% [
				_get_stat_name(
					modifier.stat
				),
				_format_signed_integer(
					modifier.amount_per_stack
				),
			]
		)

	if not modifier_parts.is_empty():
		text += (
			"\n  Изменяет: %s"
			% ", ".join(
				modifier_parts
			)
		)

	if status.max_stacks > 1:
		text += (
			"\n  Максимум стаков: %d"
			% status.max_stacks
		)

	return text


static func _build_aim_target_text(
	targeting: AbilityTargetingDefinition
) -> String:
	match targeting.aim_requirement:
		AbilityTargetingDefinition.AimRequirement.EMPTY_CELL:
			return "пустая клетка"

		AbilityTargetingDefinition.AimRequirement.ANY_CELL:
			return "любая клетка"

		AbilityTargetingDefinition.AimRequirement.OCCUPIED_CELL:
			return _relation_mask_to_text(
				targeting.aim_relation_mask
			)

	return "неизвестно"


static func _build_range_text(
	targeting: AbilityTargetingDefinition
) -> String:
	if targeting.aim_offsets.is_empty():
		return ""

	var minimum_distance := 999999
	var maximum_distance := 0
	var maximum_row_offset := 0

	for offset in targeting.aim_offsets:
		var distance := absi(
			offset.x
		)

		minimum_distance = mini(
			minimum_distance,
			distance
		)

		maximum_distance = maxi(
			maximum_distance,
			distance
		)

		maximum_row_offset = maxi(
			maximum_row_offset,
			absi(offset.y)
		)

	var range_text: String

	if minimum_distance == maximum_distance:
		if maximum_distance == 0:
			range_text = "Дальность: на себе"
		else:
			range_text = (
				"Дальность: %d"
				% maximum_distance
			)

	else:
		range_text = (
			"Дальность: %d–%d"
			% [
				minimum_distance,
				maximum_distance,
			]
		)

	if maximum_row_offset > 0:
		range_text += (
			", ряды ±%d"
			% maximum_row_offset
		)

	return range_text


static func _relation_mask_to_text(
	relation_mask: int
) -> String:
	var relations := PackedStringArray()

	if (
		relation_mask
		& AbilityTargetingDefinition.RelationMask.SELF
	):
		relations.append("себя")

	if (
		relation_mask
		& AbilityTargetingDefinition.RelationMask.ALLY
	):
		relations.append("союзника")

	if (
		relation_mask
		& AbilityTargetingDefinition.RelationMask.ENEMY
	):
		relations.append("врага")

	if relations.is_empty():
		return "никого"

	return " или ".join(relations)


static func _get_stat_name(
	stat: int
) -> String:
	match stat:
		BattleStatModifier.Stat.ARMOR:
			return "броня"

		BattleStatModifier.Stat.STRENGTH:
			return "сила"

		BattleStatModifier.Stat.AGILITY:
			return "ловкость"

		BattleStatModifier.Stat.SPIRIT:
			return "дух"


	return "характеристика"


static func _format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


static func format_turn_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d ходов" % value

	if last_digit == 1:
		return "%d ход" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d хода" % value

	return "%d ходов" % value
```

---

## FILE: `presentation/battle/previews/battle_action_preview_formatter.gd`
```gdscript
class_name BattleActionPreviewFormatter
extends RefCounted


static func build_target_text(
	preview: BattleTargetPreview
) -> String:
	if preview == null:
		return ""

	var lines := PackedStringArray()

	if preview.has_damage_effect():
		_append_damage_lines(
			lines,
			preview
		)

	_append_healing_lines(
		lines,
		preview.normal_effect_results
	)

	_append_guard_lines(
		lines,
		preview.normal_effect_results
	)

	_append_status_lines(
		lines,
		preview.normal_effect_results
	)

	_append_movement_lines(
		lines,
		preview.normal_effect_results
	)

	if preview.normal_final_health <= 0:
		lines.append(
			"ПОГИБНЕТ"
		)

	elif (
		preview.critical_final_health <= 0
		and preview.has_critical_alternative()
	):
		lines.append(
			"При крите погибнет"
		)

	return "\n".join(
		lines
	)


static func _append_damage_lines(
	lines: PackedStringArray,
	preview: BattleTargetPreview
) -> void:
	var normal_guard_damage := (
		_sum_guard_absorption(
			preview.normal_effect_results
		)
	)

	var normal_health_damage := (
		_sum_applied_amount(
			preview.normal_effect_results,
			&"damage"
		)
	)

	if preview.has_guaranteed_critical():
		lines.append(
			"КРИТ гарантирован"
		)

		lines.append(
			_format_damage(
				normal_guard_damage,
				normal_health_damage
			)
		)

		return

	var critical_chances := (
		preview
		.get_standard_critical_chances()
	)

	if critical_chances.is_empty():
		lines.append(
			_format_damage(
				normal_guard_damage,
				normal_health_damage
			)
		)

		return

	var critical_guard_damage := (
		_sum_guard_absorption(
			preview.critical_effect_results
		)
	)

	var critical_health_damage := (
		_sum_applied_amount(
			preview.critical_effect_results,
			&"damage"
		)
	)

	lines.append(
		"Обычно: %s"
		% _format_damage(
			normal_guard_damage,
			normal_health_damage
		)
	)

	lines.append(
		"При крите: %s"
		% _format_damage(
			critical_guard_damage,
			critical_health_damage
		)
	)

	var chance_parts := PackedStringArray()

	for chance in critical_chances:
		chance_parts.append(
			"%d%%"
			% chance
		)

	lines.append(
		"Шанс крита: %s"
		% " / ".join(
			chance_parts
		)
	)


static func _append_healing_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"heal"
		):
			continue

		var text := (
			"HP +%d"
			% effect_result.applied_amount
		)

		if effect_result.overheal_amount > 0:
			text += (
				"  (избыток %d)"
				% effect_result.overheal_amount
			)

		lines.append(
			text
		)


static func _append_guard_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"grant_guard"
		):
			continue

		var text := (
			"Оборона +%d"
			% effect_result.applied_amount
		)

		if effect_result.overguard_amount > 0:
			text += (
				"  (потеряно %d)"
				% effect_result.overguard_amount
			)

		lines.append(
			text
		)


static func _append_status_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"apply_status"
		):
			continue

		var status_name := (
			effect_result.status_display_name
		)

		if status_name.is_empty():
			status_name = String(
				effect_result.status_id
			)

		if (
			effect_result
			.status_application_blocked_by_immunity
		):
			lines.append(
				"ИММУНИТЕТ: «%s»"
				% status_name
			)

			continue

		if effect_result.status_was_added:
			lines.append(
				"+ «%s» (%d х.)"
				% [
					status_name,
					effect_result
						.current_status_remaining_turns,
				]
			)

		else:
			lines.append(
				"«%s» обновится (%d х.)"
				% [
					status_name,
					effect_result
						.current_status_remaining_turns,
				]
			)


static func _append_movement_lines(
	lines: PackedStringArray,
	effect_results: Array[BattleEffectResult]
) -> void:
	for effect_result in effect_results:
		if (
			effect_result == null
			or effect_result.effect_kind
				!= &"forced_movement"
		):
			continue

		var text := (
			"Сдвиг: %d/%d → %s"
			% [
				effect_result
					.applied_movement_distance,
				effect_result
					.requested_movement_distance,
				effect_result
					.movement_destination,
			]
		)

		if effect_result.movement_was_blocked:
			text += (
				"\nОстановка: %s"
				% _format_block_reason(
					effect_result
						.movement_block_reason
				)
			)

		lines.append(
			text
		)


static func _format_damage(
	guard_damage: int,
	health_damage: int
) -> String:
	var parts := PackedStringArray()

	if guard_damage > 0:
		parts.append(
			"ОБ −%d"
			% guard_damage
		)

	if health_damage > 0:
		parts.append(
			"HP −%d"
			% health_damage
		)

	if parts.is_empty():
		return "урон 0"

	return ", ".join(
		parts
	)


static func _sum_guard_absorption(
	effect_results: Array[BattleEffectResult]
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if (
			effect_result != null
			and effect_result.effect_kind
				== &"damage"
		):
			total += (
				effect_result
				.guard_absorbed_amount
			)

	return total


static func _sum_applied_amount(
	effect_results: Array[BattleEffectResult],
	effect_kind: StringName
) -> int:
	var total: int = 0

	for effect_result in effect_results:
		if (
			effect_result != null
			and effect_result.effect_kind
				== effect_kind
		):
			total += (
				effect_result.applied_amount
			)

	return total


static func _format_block_reason(
	reason: StringName
) -> String:
	match reason:
		BattleForcedMovementService.BLOCK_OUTSIDE_GRID:
			return "граница поля"

		BattleForcedMovementService.BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED:
			return "клетка занята"

	return String(reason)
```

---

## FILE: `scenes/debug/presentation/battle_debug_log_presenter.gd`
```gdscript
class_name BattleDebugLogPresenter
extends RefCounted


var status_label: Label
var session: BattleSession
var debug_status_definition: BattleStatusDefinition
var max_battle_log_lines: int = 6

var _status_headline: String = ""
var _battle_log_lines := PackedStringArray()
var _status_signal_logging_suspended: bool = false


func _init(
	p_status_label: Label,
	p_session: BattleSession,
	p_debug_status_definition: BattleStatusDefinition = null,
	p_max_battle_log_lines: int = 6
) -> void:
	assert(
		p_status_label != null,
		"BattleDebugLogPresenter requires a status label."
	)
	assert(
		p_session != null,
		"BattleDebugLogPresenter requires a battle session."
	)

	status_label = p_status_label
	session = p_session
	debug_status_definition = p_debug_status_definition
	max_battle_log_lines = maxi(
		1,
		p_max_battle_log_lines
	)


func connect_combatant(
	combatant: CombatantState
) -> void:
	if combatant == null:
		return

	var added_callback := Callable(
		self,
		"_on_combatant_status_added"
	).bind(
		combatant
	)

	var updated_callback := Callable(
		self,
		"_on_combatant_status_updated"
	).bind(
		combatant
	)

	var removed_callback := Callable(
		self,
		"_on_combatant_status_removed"
	).bind(
		combatant
	)

	if not combatant.is_connected(
		&"status_added",
		added_callback
	):
		combatant.connect(
			&"status_added",
			added_callback
		)

	if not combatant.is_connected(
		&"status_updated",
		updated_callback
	):
		combatant.connect(
			&"status_updated",
			updated_callback
		)

	if not combatant.is_connected(
		&"status_removed",
		removed_callback
	):
		combatant.connect(
			&"status_removed",
			removed_callback
		)


func set_headline(
	message: String
) -> void:
	_status_headline = message
	_refresh_status_label()


func push_battle_log(
	message: String
) -> void:
	if message.strip_edges().is_empty():
		return

	_battle_log_lines.append(
		message
	)

	while (
		_battle_log_lines.size()
		> max_battle_log_lines
	):
		_battle_log_lines.remove_at(0)

	print(message)

	_refresh_status_label()

func suspend_status_signal_logging() -> void:
	_status_signal_logging_suspended = true


func resume_status_signal_logging() -> void:
	_status_signal_logging_suspended = false

func apply_debug_status(
	target: CombatantState,
	source: CombatantState = null
) -> bool:
	if debug_status_definition == null:
		set_headline(
			"Debug-статус не назначен в Inspector."
		)

		return false

	if not debug_status_definition.is_valid_definition():
		set_headline(
			"Назначен некорректный debug-статус."
		)

		return false

	if target == null:
		set_headline(
			"Наведи курсор на бойца и нажми T."
		)

		return false

	var source_instance_id: StringName = &""

	if source != null:
		source_instance_id = source.instance_id

	var applied_status := target.add_status(
		debug_status_definition,
		source_instance_id
	)

	if applied_status == null:
		set_headline(
			"Не удалось применить debug-статус."
		)

		return false

	set_headline(
		"%s: %s. Текущая броня: %d."
		% [
			target.definition.display_name,
			format_status_for_player(
				applied_status
			),
			target.get_effective_armor(),
		]
	)

	return true


func get_status_summary(
	combatant: CombatantState
) -> String:
	if combatant == null:
		return "нет"

	var statuses := combatant.get_active_statuses()

	if statuses.is_empty():
		return "нет"

	var parts := PackedStringArray()

	for status in statuses:
		if status == null:
			continue

		parts.append(
			format_status_for_player(
				status
			)
		)

	if parts.is_empty():
		return "нет"

	return "; ".join(parts)


func format_status_for_player(
	status: BattleStatusInstance
) -> String:
	if (
		status == null
		or status.definition == null
	):
		return "Неизвестный статус"

	var title := status.definition.display_name

	if status.stack_count > 1:
		title += " ×%d" % status.stack_count

	var effects := PackedStringArray()

	var armor_modifier := get_status_stat_modifier_amount(
		status,
		BattleStatModifier.Stat.ARMOR
	)

	if armor_modifier != 0:
		effects.append(
			"броня %s"
			% format_signed_integer(
				armor_modifier
			)
		)

	var has_turn_start_trigger := false
	var has_turn_end_trigger := false

	for trigger in (
		status.definition.periodic_triggers
	):
		if trigger == null:
			continue

		match trigger.timing:
			BattleStatusPeriodicTrigger.Timing.OWNER_TURN_START:
				has_turn_start_trigger = true

			BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END:
				has_turn_end_trigger = true

	if has_turn_start_trigger:
		effects.append(
			"эффект в начале хода"
		)

	if has_turn_end_trigger:
		effects.append(
			"эффект в конце хода"
		)

	var action_restriction := (
		status.definition.action_restriction
	)

	if action_restriction != null:
		if action_restriction.skip_owner_turn:
			effects.append(
				"пропуск хода"
			)

		else:
			if action_restriction.block_movement:
				effects.append(
					"запрет движения"
				)

			if action_restriction.block_all_abilities:
				effects.append(
					"запрет способностей"
				)

			elif not (
				action_restriction
				.blocked_ability_ids
				.is_empty()
			):
				effects.append(
					"запрещено способностей: %d"
					% action_restriction
					.blocked_ability_ids
					.size()
				)

	if effects.is_empty():
		effects.append(
			"без активных модификаторов"
		)

	return (
		"%s — %s, осталось %s"
		% [
			title,
			", ".join(effects),
			format_turn_count(
				status.remaining_turns
			),
		]
	)


func append_action_results(
	action_result: BattleActionResult
) -> void:
	if action_result == null:
		return

	for effect_result in (
		action_result.effect_results
	):
		if effect_result == null:
			continue

		if not effect_result.is_successful:
			continue

		match effect_result.effect_kind:
			&"damage":
				_append_damage_result(
					effect_result
				)

			&"heal":
				_append_heal_result(
					effect_result
				)

			&"grant_guard":
				_append_guard_result(
					effect_result
				)

			&"apply_status":
				_append_status_result(
					effect_result
				)

			&"forced_movement":
				_append_forced_movement_result(
					effect_result
				)


func append_periodic_trigger_results(
	combatant: CombatantState,
	timing: int,
	trigger_results: Array[
		BattleStatusPeriodicTriggerResult
	]
) -> void:
	if combatant == null:
		return

	for trigger_result in trigger_results:
		if trigger_result == null:
			continue

		var status_name := (
			trigger_result.status_display_name
		)

		if status_name.strip_edges().is_empty():
			status_name = String(
				trigger_result.status_id
			)

		push_battle_log(
			"«%s» срабатывает у %s %s."
			% [
				status_name,
				combatant.definition.display_name,
				format_periodic_timing(
					timing
				),
			]
		)

		for effect_result in (
			trigger_result.effect_results
		):
			if effect_result == null:
				continue

			if not effect_result.is_successful:
				push_battle_log(
					"Периодический эффект не выполнен: %s."
					% effect_result.failure_code
				)

				continue

			match effect_result.effect_kind:
				&"damage":
					_append_damage_result(
						effect_result
					)

				&"heal":
					_append_heal_result(
						effect_result
					)

				&"grant_guard":
					_append_guard_result(
						effect_result
					)

				# ApplyStatusEffect уже сообщает
				# об изменении через status-сигналы.
				&"apply_status":
					pass


func _append_damage_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var armor_text := (
		"%d"
		% effect_result.target_base_armor
	)

	if (
		effect_result
		.target_status_armor_modifier != 0
	):
		armor_text += (
			" %s от статусов = %d"
			% [
				format_signed_integer(
					effect_result
					.target_status_armor_modifier
				),
				effect_result
				.target_modified_armor,
			]
		)

	var critical_text: String

	if not effect_result.critical_was_enabled:
		critical_text = "крит — отключён"

	elif effect_result.critical_was_guaranteed:
		critical_text = (
			"КРИТ — гарантирован"
			+", множитель ×%s"
			% format_decimal(
				effect_result
					.critical_multiplier
			)
		)

	elif effect_result.was_critical:
		critical_text = (
			"КРИТ — ДА"
			+", шанс %d%%"
			% effect_result
				.critical_chance_percent
			+", бросок %d"
			% effect_result
				.critical_roll_percent
			+", множитель ×%s"
			% format_decimal(
				effect_result
					.critical_multiplier
			)
		)

	else:
		critical_text = (
			"крит — нет"
			+", шанс %d%%"
			% effect_result
				.critical_chance_percent
			+", бросок %d"
			% effect_result
				.critical_roll_percent
		)

	var guard_text: String

	if effect_result.guard_was_bypassed:
		guard_text = (
			"оборона проигнорирована "
			+"(было %d)"
			% effect_result.previous_guard
		)

	else:
		guard_text = (
			"оборона: %d → %d, поглощено %d"
			% [
				effect_result.previous_guard,
				effect_result.current_guard,
				effect_result
					.guard_absorbed_amount,
			]
		)

	var message := (
		"%s: сырой урон до крита — %d; "
		% [
			target_name,
			effect_result
				.raw_amount_before_critical,
		]
		+"%s; "
		% critical_text
		+"сырой урон после крита — %d; "
		% effect_result.raw_amount
		+"броня — %s; "
		% armor_text
		+"пробитие — %d; "
		% effect_result.armor_piercing
		+"итоговая броня — %d; "
		% effect_result.effective_armor
		+"урон после брони — %d; "
		% effect_result.resolved_amount
		+"%s; "
		% guard_text
		+"потеря HP — %d; "
		% effect_result.applied_amount
		+"overkill — %d."
		% effect_result.overkill_amount
	)

	if effect_result.target_died:
		message += " Цель погибает."

	push_battle_log(
		message
	)


func _append_heal_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s: расчётное лечение — %d; "
		% [
			target_name,
			effect_result.resolved_amount,
		]
		+"восстановлено HP — %d; "
		% effect_result.applied_amount
		+"overheal — %d. "
		% effect_result.overheal_amount
		+"Здоровье: %d → %d."
		% [
			effect_result.previous_value,
			effect_result.current_value,
		]
	)

	push_battle_log(
		message
	)


func _append_guard_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s получает оборону: +%d; "
		% [
			target_name,
			effect_result.applied_amount,
		]
		+"оборона %d → %d."
		% [
			effect_result.previous_guard,
			effect_result.current_guard,
		]
	)

	if effect_result.overguard_amount > 0:
		message += (
			" Сверх лимита потеряно: %d."
			% effect_result.overguard_amount
		)

	push_battle_log(
		message
	)
    
func _append_forced_movement_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var message := (
		"%s принудительно перемещается "
		% target_name
		+"на %d/%d клеток: %s → %s."
		% [
			effect_result
				.applied_movement_distance,
			effect_result
				.requested_movement_distance,
			effect_result.movement_origin,
			effect_result.movement_destination,
		]
	)

	if effect_result.movement_was_blocked:
		message += (
			" Дальнейшее движение остановлено: %s."
			% format_forced_movement_block_reason(
				effect_result
				.movement_block_reason
			)
		)

	push_battle_log(
		message
	)


func _append_status_result(
	effect_result: BattleEffectResult
) -> void:
	var target := session.get_combatant(
		effect_result.target_id
	)

	var target_name := String(
		effect_result.target_id
	)

	if (
		target != null
		and target.definition != null
	):
		target_name = (
			target.definition.display_name
		)

	var status_name := (
		effect_result.status_display_name
	)

	if status_name.strip_edges().is_empty():
		status_name = String(
			effect_result.status_id
		)

	if (
		effect_result
		.status_application_blocked_by_immunity
	):
		var immunity_reason := ""

		match effect_result.status_immunity_kind:
			&"status_id":
				immunity_reason = (
					"иммунитет к конкретному статусу"
				)

			&"tag":
				immunity_reason = (
					"иммунитет по тегу «%s»"
					% effect_result
						.status_immunity_value
				)

			_:
				immunity_reason = (
					"постоянный иммунитет"
				)

		push_battle_log(
			"%s: «%s» не наложено — ИММУНИТЕТ (%s)."
			% [
				target_name,
				status_name,
				immunity_reason,
			]
		)

		return

	if target != null:
		var status := target.get_status(
			effect_result.status_id
		)

		if (
			status != null
			and status.definition != null
		):
			status_name = (
				status.definition.display_name
			)

	var message: String

	if effect_result.status_was_added:
		message = (
			"%s получает «%s»."
			% [
				target_name,
				status_name,
			]
		)
	else:
		message = (
			"«%s» у %s обновляется."
			% [
				status_name,
				target_name,
			]
		)

	if (
		effect_result
		.previous_target_effective_armor
		!= effect_result
		.current_target_effective_armor
	):
		message += (
			" Броня: %d → %d."
			% [
				effect_result
				.previous_target_effective_armor,
				effect_result
				.current_target_effective_armor,
			]
		)

	if (
		effect_result
		.previous_status_stack_count
		!= effect_result
		.current_status_stack_count
		and effect_result
		.current_status_stack_count > 1
	):
		message += (
			" Стаки: %d → %d."
			% [
				effect_result
				.previous_status_stack_count,
				effect_result
				.current_status_stack_count,
			]
		)

	if effect_result.status_was_added:
		message += (
			" Длительность: %s."
			% format_turn_count(
				effect_result
				.current_status_remaining_turns
			)
		)

	elif (
		effect_result
		.previous_status_remaining_turns
		!= effect_result
		.current_status_remaining_turns
	):
		message += (
			" Длительность: %s → %s."
			% [
				format_turn_count(
					effect_result
					.previous_status_remaining_turns
				),
				format_turn_count(
					effect_result
					.current_status_remaining_turns
				),
			]
		)

	push_battle_log(
		message
	)


func get_status_stat_modifier_amount(
	status: BattleStatusInstance,
	stat: int
) -> int:
	if (
		status == null
		or status.definition == null
	):
		return 0

	var total: int = 0

	for modifier in status.definition.stat_modifiers:
		if modifier == null:
			continue

		if modifier.stat != stat:
			continue

		total += modifier.get_total_amount(
			status.stack_count
		)

	return total

func format_decimal(
	value: float
) -> String:
	return str(
		snappedf(
			value,
			0.01
		)
	)


func format_signed_integer(
	value: int
) -> String:
	if value > 0:
		return "+%d" % value

	return str(value)


func format_turn_count(
	value: int
) -> String:
	var absolute_value := absi(value)
	var last_two_digits := absolute_value % 100
	var last_digit := absolute_value % 10

	if (
		last_two_digits >= 11
		and last_two_digits <= 14
	):
		return "%d ходов" % value

	if last_digit == 1:
		return "%d ход" % value

	if last_digit >= 2 and last_digit <= 4:
		return "%d хода" % value

	return "%d ходов" % value


func format_periodic_timing(
	timing: int
) -> String:
	match timing:
		BattleStatusPeriodicTrigger.Timing.OWNER_TURN_START:
			return "в начале хода"

		BattleStatusPeriodicTrigger.Timing.OWNER_TURN_END:
			return "в конце хода"

	return "в неизвестный момент"


func format_forced_movement_block_reason(
	reason: StringName
) -> String:
	match reason:
		BattleForcedMovementService.BLOCK_OUTSIDE_GRID:
			return "граница поля"

		BattleForcedMovementService.BLOCK_CELL_OCCUPIED_OR_OBSTRUCTED:
			return "клетка занята или заблокирована"

	return String(reason)


func _refresh_status_label() -> void:
	var text := _status_headline

	if not _battle_log_lines.is_empty():
		if not text.is_empty():
			text += "\n\n"

		text += "Журнал боя:\n• "
		text += "\n• ".join(
			_battle_log_lines
		)

	status_label.text = text


func _on_combatant_status_added(
	status: BattleStatusInstance,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var status_armor_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		- status_armor_modifier
	)

	var current_armor := combatant.get_effective_armor()

	var message := (
		"%s получает «%s»."
		% [
			combatant.definition.display_name,
			status.definition.display_name,
		]
	)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	message += (
		" Длительность: %s."
		% format_turn_count(
			status.remaining_turns
		)
	)

	push_battle_log(
		message
	)


func _on_combatant_status_updated(
	status: BattleStatusInstance,
	previous_stack_count: int,
	previous_remaining_turns: int,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var current_status_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_status_modifier: int = 0

	if (
		status != null
		and status.definition != null
	):
		for modifier in status.definition.stat_modifiers:
			if (
				modifier != null
				and modifier.stat
				== BattleStatModifier.Stat.ARMOR
			):
				previous_status_modifier += (
					modifier.get_total_amount(
						previous_stack_count
					)
				)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_modifier_total := (
		current_modifier_total
		- current_status_modifier
		+ previous_status_modifier
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ previous_modifier_total
	)

	var current_armor := combatant.get_effective_armor()

	var changes := PackedStringArray()

	if previous_stack_count != status.stack_count:
		changes.append(
			"стаки: %d → %d"
			% [
				previous_stack_count,
				status.stack_count,
			]
		)

	if previous_armor != current_armor:
		changes.append(
			"броня: %d → %d"
			% [
				previous_armor,
				current_armor,
			]
		)

	if previous_remaining_turns != status.remaining_turns:
		if status.remaining_turns > previous_remaining_turns:
			changes.append(
				"длительность обновлена: %s → %s"
				% [
					format_turn_count(
						previous_remaining_turns
					),
					format_turn_count(
						status.remaining_turns
					),
				]
			)
		else:
			changes.append(
				"осталось %s"
				% format_turn_count(
					status.remaining_turns
				)
			)

	if changes.is_empty():
		changes.append("обновлён")

	push_battle_log(
		"«%s» у %s: %s."
		% [
			status.definition.display_name,
			combatant.definition.display_name,
			", ".join(changes),
		]
	)


func _on_combatant_status_removed(
	status: BattleStatusInstance,
	reason: StringName,
	combatant: CombatantState
) -> void:
	if _status_signal_logging_suspended:
		return

	var removed_armor_modifier := (
		get_status_stat_modifier_amount(
			status,
			BattleStatModifier.Stat.ARMOR
		)
	)

	var current_modifier_total := (
		combatant.get_status_modifier_total(
			BattleStatModifier.Stat.ARMOR
		)
	)

	var previous_armor := maxi(
		0,
		combatant.armor
		+ current_modifier_total
		+ removed_armor_modifier
	)

	var current_armor := combatant.get_effective_armor()

	var message: String

	match reason:
		&"expired":
			message = (
				"«%s» у %s заканчивается."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		&"owner_defeated":
			message = (
				"«%s» снимается после гибели %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

		_:
			message = (
				"«%s» снимается с %s."
				% [
					status.definition.display_name,
					combatant.definition.display_name,
				]
			)

	if previous_armor != current_armor:
		message += (
			" Броня: %d → %d."
			% [
				previous_armor,
				current_armor,
			]
		)

	push_battle_log(
		message
	)
```

---


## ✅ STATS
- Total files in tree: 114
- Readable files: 110
- Included files written: 17
- Trimmed files: 0
- Total lines written: 5434
