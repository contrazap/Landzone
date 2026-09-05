# F00 headless verification

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

## Import and parser check

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --editor --quit
```

## Main-scene smoke check

```powershell
& 'C:\MyFiles\Godot\Godot_v4.7.1-stable_win64_console.exe' --headless --path game --quit-after 2
```

The visual placeholder-window check remains a separate manual acceptance gate in F00/S03.
