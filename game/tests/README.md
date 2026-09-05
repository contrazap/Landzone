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

This command preserves the S01 checks for the authored Basin composition, static shuttle and
spawn, solid route boundaries, player physics, normalized movement, and follow camera. From S02
it also exercises a safe passage and actual lethal contact, verifies the delay does not exceed
one second, rejects duplicate death/retry requests, and proves three consecutive retries restore
the same player at the exact shuttle marker with clean movement while preserving the Basin.
Success prints a concise `F01/S02 checks passed` summary and exits with code 0.

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
