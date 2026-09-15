# Battle presentation scaffold

Open `res://scenes/battle/battle_screen.tscn` and run the current scene (F6).
The scene starts the existing debug_duel_encounter through BattleSessionFactory.
Select abilities in the reused panel, click a slot to act/move/swap, and use
End Turn or Space to finish the turn. Enemy turns use the existing utility AI.
Test Camera triggers the camera director. There is no player camera control.
For presentation-only embedding/tests, set auto_start_battle = false and call
bind_session(existing_session) after ready. Rebinding a running battle is rejected.

BattleScreen owns the camera, UI and universal world presentation containers.
Assign its exported environment_scene or call load_environment(PackedScene).
The caller chooses the scene independently of BattleEncounterDefinition.
No location-specific branching or gameplay changes are required.

The integration and universal-feedback contract is documented in
`res://scenes/battle/README.md`.

## Environment contract

Root: BattleEnvironment (Node2D). Required child: ArenaLayout (BattleArenaLayout).
The base battle_environment.tscn supplies all optional layers. A concrete scene
may inherit it or use the same scripts with only the layers it needs, as the
steppe example does. Missing optional layers are valid.

## Editing the 18 slots

1. Open `res://scenes/battle/environments/steppe_environment.tscn` in the 2D editor.
2. Expand ArenaLayout. Each Slot_column_row is a separate BattleSlotAnchor
   (Marker2D) stored directly in this scene.
3. Select a marker cross and drag it with the normal Move tool. Disable grid
   snapping for free placement. The marker origin is the character's feet.
4. Save the environment scene. No code, numeric position entry or generator is needed.

Coordinates (column, row) stay fixed while positions move independently.
Both the base environment and steppe contain all 18 anchors. The positions
already demonstrate non-uniform spacing. For another encounter size, author
the matching coordinates and set preview_grid_size for editor validation.
Keep anchors as direct children of ArenaLayout.

Blue L / orange R, coordinates and ellipse outlines are editor diagnostics.
Enable ArenaLayout.debug_preview for the same visualization in a debug build;
release builds never draw it. preview_divider_column only colors the preview.
When a session is bound, its actual side rules supply the divider.
Diagnostics draw at Z 900 so foreground artwork does not hide the markers.

Each anchor's interaction_radii defines its local ellipse. Hit testing uses the
same radii and full anchor transform. Dragging, rotation or scaling moves both
the visual standing point and its hit area together. Overlapping ellipses pick
the nearest ground contact; distance ties prefer the greater world Y.

## Model and presentation boundary

ArenaLayout implements BattleSlotResolver. get_slot_position(coordinate)
returns a **global world position**; get_slot_anchor(coordinate) returns the
actual node. There is no rectangular spacing fallback or cached position.
BattleCombatantPresenter converts world positions to CombatantLayer-local space.
Spawn, movement paths, swaps, teleports and forced movement use that resolver.
Normal/forced movement and action runners retain their existing gameplay code.
BattleScreen listens for session additions/removals, including reinforcements.

Assign encounter_definition before entering the tree when loading an arena for
a nonstandard encounter. Environment loading validates every coordinate against
the bound session grid, or the encounter dimensions, or the standard 6-by-3
preview when neither is supplied. bind_session validates against the actual
session again. Duplicate, missing and out-of-bounds slots report the coordinate
and offending anchor name. Invalid environments leave the current one intact.
The editor shows configuration warnings on ArenaLayout.

BattleWorld/TacticalOverlay/SlotInteraction uses authored ellipses, accounts
for Camera2D transforms and handles only unconsumed mouse input. BattleScreen
forwards slot_clicked(coordinate, button) and slot_hovered(coordinate);
hover exit uses (-1, -1). UI can consume events before they reach world picking.
These signals select logical coordinates; they do not decide legal actions.

Read valid coordinates and occupancy from BattleSession.grid. Never store
side rules or movement legality in anchors. Keep CombatantView at ground contact;
offset sprites/artwork inside VisualContainer, not the root being Y-sorted.

## Shared world draw order

| Layer | Absolute Z |
| --- | ---: |
| BackgroundLayer | -400 |
| GroundLayer | -300 |
| BackAtmosphereLayer | -200 |
| SurfaceLayer | -100 |
| CombatantLayer | 0 |
| BattleEffectsLayer | 100 |
| TacticalOverlay | 200 |
| ForegroundLayer | 400 |
| FrontAtmosphereLayer | 500 |
| LightingLayer | 600 |

Environment scripts enforce the named layer values when entering the tree,
including in the editor. Screen layers declare them in the scene. Children
normally keep relative Z = 0; keep local offsets within the surrounding bands.
CombatantLayer sorts its direct children by Y; use foot-position origins.

Keep world artwork, atmosphere and effects as CanvasItems on the shared canvas.
Do not wrap them in CanvasLayer or CanvasGroup: interleaving must cross the
EnvironmentHost boundary. LightingLayer is for environment lights/final world
overlays; Z orders drawable overlays, not the illumination behavior of lights.
BattleUI has its own CanvasLayer, above the world and unaffected by Camera2D.
Universal world effects belong in BattleEffectsLayer; future screen-space
effects can be hosted under BattleUI without involving the environment.

BattleGridView remains available for debug sandbox. Its only integration change
is a BattleGridSlotResolver adapter passed to the common combatant presenter.
Production never needs that adapter or the rectangular grid renderer.

## Checks

Run Godot with --headless --path . --script followed by:

- res://tests/battle/presentation_smoke.gd
- res://tests/battle/authored_slots_smoke.gd

The latter checks validation, transformed/moved anchors, animated and immediate
movement/swap/teleport, unchanged model coordinates, normal movement runner,
reinforcements, camera-aware input, UI blocking and environment replacement.
Also launch res://scenes/debug/battle_grid_sandbox.tscn to check compatibility.
