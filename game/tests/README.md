# Headless verification

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

During S01, this command checks the authored Basin composition, one static shuttle and spawn,
solid route-boundary collision intent, the focused player physics scene, positive and opposing
inputs, normalized diagonal speed, actual CharacterBody2D movement, and the follow camera. It
also guards the S01 boundary by rejecting any hazard node. Success prints a concise
`F01/S01 checks passed` summary and exits with code 0.

## Import and parser check

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
```

## Main-scene smoke check

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
```

Visual presentation, movement feel, and route-boundary checks remain separate manual gates in
F01/S01 and F01/S03.
