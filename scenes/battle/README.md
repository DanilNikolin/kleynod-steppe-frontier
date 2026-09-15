# Production battle integration

Open battle_screen.tscn and run the current scene (F6). The main campaign scene
and independent debug sandbox are unchanged as entry points.

## Playing

- Click an ability or press 1–9 to select it.
- Left-click a legal target to use the selected ability.
- Left-click an empty slot to move when it is not a target of the selected ability.
- Left-click an ally to swap when it is not a target of the selected ability.
- End Turn / Space advances the existing turn controller; enemies use the existing utility AI.
- Test Camera triggers a short impact shake.

BattleScreen exports encounter_definition and environment_scene separately.
The default is the existing duel; other encounters must fit the authored arena.
The old reinforcement debug resource contains coordinates outside 6-by-3.
Do not force it into this arena: author a matching layout or use a matching encounter.
The production feature test builds a valid 6-by-3 fixture from existing definitions
to exercise all relocation, surface and reinforcement mechanics.

## Boundaries

- BattleSessionFactory, action/movement services and their runners are reused.
- BattleFlowController wires them to this screen, turn flow, existing ability and
  hover panels, and the shared BattleInteractionController.
- BattleInteractionController and BattleLogPresenter were promoted from their
  sandbox implementations. Compatibility subclasses retain the old class names.
  Debug status/obstacle controls default to disabled and are enabled only by sandbox.
- BattleGridOverlayPresenter retains reachable/path/target/swap calculations.
  Its output is BattleTacticalState, not a grid renderer or color.
- BattleTacticalOverlay renders semantic ground markers against authored anchors.
  Reachable, path, hover, selected, valid/invalid target, AoE and swap can coexist.
  Valid target uses action_service.can_execute; aim range alone does not imply legality.
- BattleSurfacePresenter owns actual surface rendering on SurfaceLayer. It reads
  existing surface instances and uses the same anchor transforms. Surface presence
  is also available as a semantic flag and survives transient tactical clearing.
- BattleActionPreviewPresenter preserves combatant badges and sends surface preview
  results through the semantic boundary. The debug adapter maps this to BattleGridView.
- Neither the environment nor gameplay model owns any presentation state.

## Universal effects

BattleEffectsLayer.effects is an array of BattleVFXDefinition resources:
effect_id, reusable PackedScene, maximum lifetime. Only a simple ImpactVFX is
provided now. Add more scenes to the registry without arena-specific branching.
Every VFX scene must have a Node2D root; it may free itself earlier than its lifetime.

Existing CombatantPresenter.vfx_requested and sound_requested are connected.
The production presenter provides an optional default impact ID when an ability
does not specify one. The sandbox default stays empty. Explicit ability profile
IDs retain precedence. AudioStream mappings live on BattleEffectsLayer.sounds.

spawn_vfx supports WORLD, ACTOR, TARGET, ACTOR_EFFECT_ANCHOR and TARGET_EFFECT_ANCHOR.
Positions are sampled at spawn time. A specialized effect (for example a projectile)
may implement configure_battle_effect(presenter, actor_id, target_id) and then use
the supplied views/anchors for travel or attachment. No cinematic/event framework
is required. Streams and effects are owned by the scene and cleaned up with it.

BattleCameraDirector owns shake, impact_shake, push_zoom and reset. Repeated
reactions do not accumulate offsets; zoom/shake restore the saved rest state.
The normal camera is fixed. Its vertical framing reserves space for the existing UI.
The world, including all environment layers, shakes naturally together.

BattleScreenFeedback provides flash, damage_flash (edge vignette), dark_flash and
reset. It is a screen-space component below the controls on BattleUI's CanvasLayer.
Its mouse filter ignores input. Health-loss notifications trigger an impact shake
and a damage vignette for the player side.

Environment-specific rain, fog, smoke, leaves, water and lighting remain inside
BattleEnvironment. No environmental-effect catalog or parallax framework was added.

## Tests

Godot command: --headless --path . --script followed by any of:

- res://tests/battle/presentation_smoke.gd
- res://tests/battle/authored_slots_smoke.gd
- res://tests/battle/production_battle_smoke.gd
- res://tests/battle/production_features_smoke.gd
- res://tests/battle/universal_feedback_smoke.gd

production_battle_smoke plays the existing encounter to completion with player
interaction and enemy AI. Add -- --animated to exercise animated presentation.
production_features_smoke uses real runners/services for ability swap, normal swap,
teleport, forced movement, surfaces and round-two reinforcements.
universal_feedback_smoke checks all VFX placements, audio hook, cleanup and camera restoration.

The production turn orchestrator detaches the turn controller's session callback
when disposed because the existing controller has no public stop/dispose API.
Combat core was intentionally not changed to introduce one.
