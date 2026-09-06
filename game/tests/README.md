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

No reusable rendered-capture/input-automation pipeline currently exists in this repository.
The current tests check presentation state and some real input/physics behavior headlessly;
they do not prove that pixels are correctly drawn or text is legible.

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
- F04-F06: pause/focus, command parsing, journal/codex interfaces and durable state round trips.
- F07/F12: multiple fixed seeds, independent random streams, reachability and progression,
  evidence consistency, bounded generation failure and diagnostics.
- F08-F11: geometry validation, checkpoint/recovery behavior, finite resource ownership,
  cache/elite transfer without duplication, bounded statuses and persistence.
- F13/F14: complete expedition, terminal state, new-run isolation, exported-build execution,
  representative performance and final rendering/input checks.

These are future obligations, not claims that a runner already exists. Select concrete checks
in each owning plan. Scripted timings can measure retries and overhead; enjoyment, subjective
pacing and unfamiliar-player comprehension remain optional unassessed qualities unless observed.
