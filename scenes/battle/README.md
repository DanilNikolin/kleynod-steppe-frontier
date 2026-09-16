# Production battle integration

Open battle_screen.tscn and run the current scene (F6). The main campaign scene
now launches this same production screen for battles. The debug sandbox remains
an independent testing entry point. F6 uses exported defaults when no campaign
battle request is pending.

## Editable slot and surface visuals

Open `presentation/battle/overlay/battle_tactical_marker_view.tscn`. Each named
child is an independent semantic layer. Replace its placeholder children with
sprites, animated sprites, particles or shaders; retain the named layer wrapper.
`editor_preview_flags` previews combinations in the editor only. Runtime flags
come from BattleTacticalState; SURFACE never draws a tactical ground effect.

SurfaceLayer owns `BattleSurfaceView` instances, keyed by runtime surface instance.
Its exported `surface_scenes` registry maps the two existing surface IDs to scenes
in `presentation/battle/surfaces/visuals/`. Replace children under Visuals to author
their appearance. The generic `battle_surface_view.tscn` is an explicit fallback
for unknown IDs, not a new gameplay surface. Both presenters have no `_draw()`.

Artwork is centered at the ground origin and authored for `design_radii` (60,32).
Views follow the complete anchor transform and interaction radii. Continue moving
the 18 BattleSlotAnchor nodes directly in each environment's ArenaLayout.

## Campaign composition

CampaignLocationDefinition selects a PackedScene; start_location copies it to
CampaignBattleRequest. BattleScreen consumes that encounter/environment pair
without resolving location IDs or branching on environment types.

BattleCampaignBridge listens to the existing flow completion signal, waits for
action/movement presentation to finish, then asks CampaignRuntime to calculate
rewards using the existing reward services and complete_pending_battle_and_return.
The existing XP, loot, quest, adventure and travel result path is unchanged.
Standalone battles have no campaign bridge. Screen-owned sessions are cleared
when the screen exits; externally bound sessions remain caller-owned.

The forest_edge, abandoned_cart and overturned_cart_ambush environments are
independent editable copies of steppe, assigned to their corresponding locations.
Their art is intentionally still shared placeholder content.

## Editable character visuals

Canonical mapping stays `CombatantDefinition.visual_scene -> CombatantView ->
CombatantVisual`. No registry is needed. Bayda and the prototype Steppe Raider
now have independent scenes in `presentation/battle/combatants/visuals/`.
The template is `presentation/battle/combatants/animated_combatant_visual_template.tscn`.
The initial frames are deliberately simple scene-authored GradientTexture2D blocks,
not final character art. No generated/imported character images are required.

### Create another enemy visual

1. Duplicate `steppe_raider_battle_visual.tscn` and rename the copy.
2. Open it and select `Forward/BodyPivot/Character` (AnimatedSprite2D).
3. Open SpriteFrames and replace the textures in `idle`, `attack`, `hit`, `death`
   with your PNG frames. Keep idle looping; disable looping for the other three.
4. Set FPS and optional per-frame durations in SpriteFrames.
5. Adjust Character's position/offset/scale or BodyPivot so the feet meet root `(0,0)`.
   The placeholder uses an uncentered 40x80 canvas with offset `(-20,-80)`; replace
   that offset visually for your art dimensions. Root remains the ground contact.
6. Adjust `Forward/Shadow` independently (polygon, position, scale, opacity).
7. Assign the new scene to the enemy's existing `CombatantDefinition.visual_scene`.
8. Run the campaign or BattleScreen. No presenter or battle-code changes are needed.

Facing mirrors the entire Forward node; do not use Character.flip_h as the facing
system. Character visuals stay in the world canvas and receive environment time tint.
Health/selection/hover/flash and movement remain owned by the existing wrapper/feedback.
Only one visual child is installed. Missing visual_scene uses the existing placeholder;
its absence is no longer a content validation error. Invalid assigned scene types
still report an error.

CombatantVisual supports both SpriteFrames and AnimationPlayer. For a key present
in both, SpriteFrames wins. `has_animation`, `get_animation_duration` (FPS, frame
weights, absolute speed scale), and `is_animation_looping` inspect actual resources.
Zero playback speed reports infinite duration. `get_animation_mixer` returns only
the optional AnimationPlayer; AnimatedSprite2D is never treated as an AnimationMixer.

Idle loops; attack/hit finish natively and return to idle. Hit may restart and takes
priority over action; idle/move cannot truncate active non-loop feedback. Death locks
the visual, rejects subsequent feedback and holds the last frame until view removal.
Revision/key guards reject stale completion callbacks. No corpse lifetime was added.
Movement remains a whole-view tween; absent `move` falls back to idle, with no walk
frames or procedural movement. Gameplay commits never wait for SpriteFrames.

Specific actor animation keys still win. Only DAMAGE/CONTROL actor feedback uses
generic `attack` when its requested key is missing. Other/unknown keys keep their
normal fallback, so an arbitrary `celebrate` request does not become an attack.
Existing generic flash/VFX feedback remains in BattleCombatantPresenter.

The checked-in baseline did not have CombatantView.play_hit or an AnimationMixer
wait path: HP-loss feedback was added to the existing wrapper HP callback, and the
existing death callback is reused. No new gameplay subscriptions or event service
were added to character visuals.

### Character tests

`--headless --path . --script tests/battle/combatant_visual_animation_smoke.gd`
checks both scenes, completion/priority, frame timing, real action runner damage and
death, specific-action fallback, optional-art fallback and AnimationPlayer compatibility.
It compares HP/stamina/cooldown with short and long visual attack durations.

## Controls

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
- res://tests/battle/marker_surface_smoke.gd
- res://tests/battle/campaign_production_smoke.gd
- res://tests/battle/hero_core_lifecycle_smoke.gd
- res://tests/battle/repeatable_deep_forest_smoke.gd
- res://tests/battle/battle_time_of_day_smoke.gd
- res://tests/battle/tactical_marker_sprite_smoke.gd

## Tactical Marker Art

Tactical markers use `Sprite2D` nodes under each state layer in
`presentation/battle/overlay/battle_tactical_marker_view.tscn`:
- Open `battle_tactical_marker_view.tscn` in Godot editor.
- Select the state layer you wish to reskin (`Reachable`, `Path`, `ValidTarget`, `InvalidTarget`, `AoE`, `Obstacle`, `Swap`, `Selected`, `Hover`).
- Select the child `Sprite` node (`Sprite2D`).
- Drag your PNG into the `Texture` property slot.
- Adjust local position, scale, rotation or modulate if desired.

### Recommended Final PNG Properties
- Transparent background (PNG-32).
- Same canvas dimensions for all states (e.g. 512x256 or 1024x512).
- Same center/pivot (ground contact center at canvas center).
- Same ground ellipse perspective.
- Composability: because tactical flags are bitwise and can coexist (e.g. `VALID_TARGET | AOE` or `SELECTED | HOVER`), design accents to layer cleanly (e.g. soft base for reachable, outer ornament for selected, edge highlight for hover, inner glow for AoE, clean cross for invalid target).

repeatable_deep_forest_smoke checks the direct world node «Дремучий лес», free route
access from Home without requirements, fresh duplicated encounters upon sequential
battles, and that no adventure area progression or completion flags are touched.
battle_time_of_day_smoke verifies BattleEnvironment TimeOfDay components, day/night
color shifts via LocalTimeOfDayVisual, standalone BattleScreen F6 debug slider behavior,
campaign minute initialization on entry, and confirms that the battle debug time slider
does not mutate CampaignState.current_minute_of_day.

production_battle_smoke plays the existing encounter to completion with player
interaction and enemy AI. Add -- --animated to exercise animated presentation.
production_features_smoke uses real runners/services for ability swap, normal swap,
teleport, forced movement, surfaces and round-two reinforcements.
universal_feedback_smoke checks all VFX placements, audio hook, cleanup and camera restoration.
marker_surface_smoke checks independent/combinable flags, anchor transforms,
surface registry lookup, coexistence, update/removal and unknown-ID fallback.
campaign_production_smoke launches a real location, plays through production
interaction/AI, checks XP/loot/result and observes the actual return to campaign.
It uses an existing reserve hero and the existing debug sabre for a quick victory.
Add `-- --animated` to cover awaited presentation. `-- --default-party` exercises
the unmodified Bayda party and defeat return instead.

hero_core_lifecycle_smoke verifies that original and copied combatant/core pairs
are released, a retained core does not retain its owner, and expired owners resolve
to null. HeroCoreRuntimeState.owner uses a WeakRef-backed compatibility property;
CombatantState remains the strong owner of its core. This also fixes the previous
Bayda/AI-copy ObjectDB leaks in the default-party campaign scenario.

The production turn orchestrator detaches the turn controller's session callback
when disposed because the existing controller has no public stop/dispose API.
Combat core was intentionally not changed to introduce one.
