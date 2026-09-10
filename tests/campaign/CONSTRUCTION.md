# First construction loop

The implemented scope ends with a forge **shell**, not a working forge.
Existing carpenter search and quest tests remain applicable.

```text
Godot --headless --path . --script res://tests/campaign/construction_smoke.gd
```

## Manual flow

1. Start a new debug campaign (save format 12; older saves are not migrated).
2. Complete the carpenter quest, build A1/B1/C1 and invite him as a guest.
3. Enter HOME and select his temporary worksite. It opens a separate construction
   panel. B2/C2 have knowledge but no agreement; the pier lacks knowledge.
4. Collect the additional 12 materials at the timber supply in Nearby Grove.
   The original one-time eight materials remain unchanged.
5. Visit the village headman and reserve 2–4 workers for the forge. This reserves
   capacity for that project and costs nothing yet. It can be revised or released
   at the headman before signing.
6. Return to the HOME worksite and sign the complete contract once. Materials and
   the quoted full price are deducted. Signing does not advance campaign time.
7. Travel normally. The project completes when the campaign clock reaches its
   deadline, including away from HOME. The local forge spot shows the result.
8. The crew is released; a blacksmith and professional equipment are still needed.

## Current DEV values

Forge: 12 materials, 12 worker-days, min 2 / max effective 4 workers.
Workers: 2 гроші per worker-day plus 2 per worker for mobilization.
Carpenter fee: zero under his initial agreement.

| Crew | Duration | Total |
|---|---|---|
| 2 | 6 days | 28 гр. |
| 3 | 4 days | 30 гр. |
| 4 | 3 days | 32 гр. |

Village capacity starts at four without a reputation requirement, grows by one
per five reputation, and is capped at six. Outstanding reservations and active
projects occupy that source's capacity. Completed projects release it.

## Persistence and boundaries

- Knowledge and agreement are separate persistent campaign ID lists, granted on
  the carpenter's arrival. Future personal quests can grant further agreements.
- Contracts are independent per project, with RESERVED / ACTIVE / COMPLETED status.
  No global build queue or one-carpenter/one-slot restriction exists.
- Paid cost and dates are stored and validated on load. A completed contract must
  match its physical building. Duplicate contracts and inconsistent costs are rejected.
- Existing settlement zones/buildings/effects represent completed construction.
  The shell has its own effect, no forge services or income, and cannot be demolished
  to repeat the project. Legacy instant operational-forge building is disabled.
- Worksite presence derives from the resident being at HOME. It is not a paid
  building, household, worker slot, or workshop upgrade.
- B2/C2 direct upgrades are disabled. Respec, material ordering, forge equipment,
  specialists' services and the carpenter's permanent household are outside this slice.
