# Agent verification

Last updated: 2026-09-06

The agent owns verification; no required user manual checks. This file records available
commands and their limits. Feature plans select acceptance evidence by risk and extend these
checks when needed. Completed plans preserve earlier human observations as historical evidence.

Run these commands from the repository root. The confirmed local console executable is:

```text
C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe
```

Its confirmed version is `4.7.1.stable.official.a13da4feb`.

## Focused foundation test

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/run_tests.gd
```

The command checks the project identity, main-scene setting, Compatibility renderer, movement
bindings, and main-scene loadability. Success prints a concise `F00 checks passed` summary and
exits with code 0; a failed assertion exits with a nonzero code.

## F01 first-expedition test

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f01_first_expedition.gd
```

This command preserves the S01 checks for the authored Basin composition, static shuttle and
spawn, solid route boundaries, player physics, normalized movement, and follow camera. From S02
it also exercises a safe passage and actual lethal contact, verifies the delay does not exceed
one second, rejects duplicate death/retry requests, and proves three consecutive retries restore
the same player at the exact shuttle marker with clean movement while preserving the Basin.
Success prints a concise `F01/S02 checks passed` summary and exits with code 0.

## F02 ranged-combat test

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f02_ranged_combat.gd
```

This command preserves the S01 primary-button, visible weapon/muzzle, normalized aim, fixed
recovery, forward-pulse, impact/lifetime, and death-cleanup checks. From S02 it also verifies one
authored Stalker and spawn, explicit collision intent, bounded trigger range, the nonlethal tell
window, locked committed direction, lethal-hitbox timing, readable recovery, exactly one hit per
pulse, visible hit acknowledgement, defeat on the third hit, inactivity after defeat, and actual
committed-attack contact causing the existing lethal player transition.
From S03 it also proves defeat persists until death, clears transient pulses, performs three
actual Stalker-contact retries plus environmental retries, resets the same Stalker exactly once
before player control returns, preserves player/Basin/Stalker identities, and restores immediate
movement, aim, and fire. Success prints a concise `F02/S03 checks passed` summary and exits with
code 0.

## F03 mothership and transition test

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f03_mothership_transition.gd
```

This scenario checks physical `E` binding and action routing, the compact Kestrel composition,
holstered weapon, solid hull/sealed stations, real movement from vehicle bay to bridge, contextual
prompts, guarded 0.25-second static transfers and single-location/player ownership. It repeats
three normal return/redeployment cycles, proving new location/player/Stalker identities while
preserving validated position, phase/time, damage, direction and defeat. It also proves encounter
time pauses while unloaded, pulses and firing recovery do not persist, and real hazard plus
committed Stalker contact after revisiting still use the 0.65-second same-instance loaded retry.
Success prints `F03/D01 checks passed` and exits with code 0.

## F04 branching-navigation and coordinates test

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f04_branching_coordinates.gd
```

This scenario checks physical Tab binding, six authored path segments, three degree-three
junctions, two surveyed limits and the solid loop/island intent. It drives the real player through
both complete loop arcs, the east approach and both final branches, verifies solid separators and
world caps, and checks shuttle-relative north/south/east/west rounding plus all eight facing
sectors. Through parsed Tab, character, Enter and Escape events it proves LineEdit focus, the exact
`where` result and bounded errors. It samples live player, Stalker, pulse and weapon-recovery state
across a real paused interval, then verifies retry/transfer command rejection, balanced unpause,
expanded-bounds Stalker revisit state and fresh redeployment availability. Success prints
`F04/D01 checks passed` and exits with code 0.

## F05 journal and persistence tests

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f05_journal_persistence.gd
```

The integrated phase uses the real Main/Basin/console, current coordinate service and lethal
retry/transition flows. It checks exact metadata, all five journal commands, quoted parsing,
newest-first five-result search, tag normalization, append, bounded failures, retained in-memory
state after a failed save callback, death and location replacement. It also isolates missing,
malformed, unsupported-version and invalid-entry save cases and proves a valid version-1 reload
does not alias the serialized journal or encounter objects. Success prints `F05/D01 checks passed`.

Application restart is verified by these two commands in order:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f05_journal_persistence.gd -- --phase write
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f05_journal_persistence.gd -- --phase read
```

The writer and reader are separate Godot processes sharing only
`user://landzone_f05_test/restart.json`. The reader verifies exact journal data, run seed,
next-ID continuity and the Basin encounter snapshot both as plain state and after real deployment;
it reads/searches through the console, saves entry #2, and removes only the isolated restart save
on success. A failure retains the exact fixture for diagnosis. All pre-F05 scenarios disable
persistence before entering the tree, so they cannot read or overwrite `landzone_save.json`.

## F06 codex and knowledge-loop tests

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f06_codex_knowledge_loop.gd
```

The integrated scenario validates the three-term authored catalog, hidden versus confirmed
meanings, repeat-safe evidence, prose isolation, premature/decoy/correct destination outcomes,
codex command results/errors, strict reconstruction and version-1-to-version-2 migration. It then
walks the complete loop through the real scenes: physical `E` deployment from the Kestrel vehicle
bay, the authored southern safe passage past the armed hazard to a premature `EVIDENCE 0/3`
rejection, the northern arc to all three evidence sites with physical `E`/Escape and a repeat-safe
review, physical Tab journal prose that cannot move codex truth, a real lethal-hazard death whose
retry keeps collected evidence, the fully informed South decoy mismatch, the North confirmation,
and the walk back to Kestrel Research for typed codex queries plus journal find/read/tag/append.
Success prints `F06/D01 checks passed`. The Stalker's physics is stilled for the clue route so the
walk is deterministic; F02 and F03 own live combat, committed-attack death and encounter resets.

Application restart is verified by these two commands in order:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f06_codex_knowledge_loop.gd -- --phase write
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --script res://tests/test_f06_codex_knowledge_loop.gd -- --phase read
```

The writer and reader are separate Godot processes sharing only
`user://landzone_f06_test/restart.json`. The writer collects all three records, confirms the North
Shelf cairn and saves a field entry plus an encounter snapshot. The reader restores the exact
observed IDs, confirmed meanings, destination, seed, next journal ID and encounter, reapplies the
encounter on deployment, repeats both interactions without duplicating durable state, and queries
the restored truth through Kestrel Research. It removes only the isolated fixture on success.

## Import and parser check

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
```

## Main-scene smoke check

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
```

This checks startup only. Use scenarios long enough to exercise the changed behavior; a
two-frame exit does not verify movement, combat, transitions, presentation, or persistence.

## Choosing and evaluating evidence

- Run import before dependent scripts when resources or class registration may have changed.
- Check exit codes, expected success summaries, and output for parser/runtime errors. A timeout,
  missing success result, or error is not a pass even if the process exits zero.
- Reuse existing scenarios for affected behavior. Add persistent tests for important contracts
  and likely regressions, especially saves, retry, pause, resource ownership and generation.
- Do not require a test for every function or cosmetic property. A focused scenario can cover
  several integration points without duplicating setup across feature-specific files.
- Current suites include node-path, shape and instance-identity assertions. Reassess these when
  scene ownership changes; preserve the actual behavior contract and document replacements.
  Do not delete a valid failing assertion simply to make a suite pass.
- Use isolated save locations/fixtures when persistence is introduced. Tests must not overwrite
  actual player saves. Record relevant seeds, setup, commands and results in the owning plan.
- Run git diff --check and inspect the final intended-file diff.

## Rendered and interaction evidence

F03 established a focused rendered-capture driver:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --path game --script res://tests/capture_f03_views.gd
```

Run it without `--headless`. It drives guarded location requests through the real scenes and saves
six 960x540 PNGs under `game/tests/artifacts/`: Kestrel arrival, bridge prompt, static transfer,
shuttle return, mid-route camera follow and redeployed Basin. The camera-follow view drives real
down/right physics input before capture. It validates image dimensions and save results, but a passing
command does not assess the pixels: inspect the retained images with an image viewer. The F03 plan
records the 2026-09-06 inspection. The capture window's synthetic action state is focus-sensitive,
so the driver calls the same proximity-validated public interaction methods; the headless F03
scenario separately exercises `Input.action_press/release` through location polling.

F04 adds a second focused driver:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --path game --script res://tests/capture_f04_views.gd
```

It saves six 960x540 Compatibility-renderer PNGs for Landing Fork, Reunion Fork, Far Fork,
North Shelf limit, South Hollow limit and a non-origin `where` result. The driver validates image
creation/dimensions; inspect the pixels for branch separation, player/camera framing, caption/HUD
collisions, complete endpoint text, console focus hierarchy and response legibility. The F04 plan
records the 2026-09-06 inspection and the two presentation corrections made from it.

F05 adds the journal-response driver:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --path game --script res://tests/capture_f05_views.gd
```

It saves three 960x540 Compatibility-renderer PNGs for coordinate-stamped add, a full bounded
five-result search and metadata-rich read with appended prose. Inspect all three for hierarchy,
contrast, wrapping, truncation, scroll/clipping and input context. The driver disables disk
persistence and uses a fixed timestamp; the headless F05 scenarios own durability evidence.

F06 adds the knowledge-loop driver:

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --path game --script res://tests/capture_f06_views.gd
```

It saves seven 960x540 Compatibility-renderer PNGs: the three evidence readers, the South Hollow
mismatch, the North Shelf confirmation, and the Research codex search, codex evidence and
coordinate-stamped journal read. Inspect the glyph rows against the fixed truth table as well as
hierarchy, wrapping, clipping and station wording. The F06 plan records the 2026-09-06 inspection
and the console-wording correction made from it. The driver uses the proximity-validated public
interaction because the capture window's synthetic action state is focus-sensitive; the headless
F06 scenario owns physical-key evidence.

A delivery changing visual behavior must establish its needed agent-run capture/interaction
method, inspect the actual rendered result, and record the setup and artifact path in its plan.
Use available engine or desktop tooling and focused deterministic scenario drivers. Verify the
installed tool's capabilities before relying on them; do not assume headless execution produces
usable rendering. Keep capture output separate from runtime assets and retain only useful evidence.
Exercise real input routing for changed UI flows; direct method calls alone can miss focus or
pause bugs. Keep simulation controls confined to verification tools when practical.

For every required criterion, obtain suitable evidence or leave a required verification gap
and the delivery incomplete. Do not assign the user a manual gate. Cosmetic changes may need
only rendered inspection and existing integration checks; they do not automatically need new tests.

## Coverage added with future features

- F03: return/redeployment and encounter state preservation across normal revisits versus retry.
- F04: authored route traversal, coordinates, pause/focus and the first bounded command parser.
- F05: journal grammar/lifecycle, invalid saves and a true two-process durable round trip.
- F06: codex interface, walked evidence loop and durable confirmed-fact round trips.
- F07/F12: multiple fixed seeds, independent random streams, reachability and progression,
  evidence consistency, bounded generation failure and diagnostics.
- F08-F11: geometry validation, checkpoint/recovery behavior, finite resource ownership,
  cache/elite transfer without duplication, bounded statuses and persistence.
- F13/F14: complete expedition, terminal state, new-run isolation, exported-build execution,
  representative performance and final rendering/input checks.

These are future obligations, not claims that a runner already exists. Select concrete checks
in each owning plan. Scripted timings can measure retries and overhead; enjoyment, subjective
pacing and unfamiliar-player comprehension remain optional unassessed qualities unless observed.
