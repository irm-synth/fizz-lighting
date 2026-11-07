# Contributing

Fizz Lighting is a single PowerShell file (`fizz-gui.ps1`) that Windows PowerShell 5.1 runs as it
is, plus a launcher. You can edit that file directly; there is no build step. Because it is one file
that people run on their own machines and that writes to hardware, changes are checked with the
tests in `dev/` before they are merged.

## Layout of the repository

| Path | What it is |
|---|---|
| `fizz-gui.ps1` | the whole application |
| `Fizz-Lighting.cmd` | launcher (starts PowerShell in the right mode) |
| `docs/PROTOCOL.md` | what is known about the keyboard's protocol, and how sure we are |
| `dev/tests/` | tests that need no keyboard (see `dev/README.md`) |
| `dev/reference/` | exhaustive comparison against fizzctl (needs Python) |
| `THIRD-PARTY-NOTICE.txt` | license of fizzctl, whose data and protocol knowledge are embedded |

## Map of `fizz-gui.ps1`

Search for these section titles:

1. **Protocol data** - frame templates (base64, from fizzctl), effect table, capability table. Do
   not edit the base64 by hand; regenerate/verify it with `dev/reference`.
2. **Frame builders** - `New-EffectFrames`, `New-PerKeyFrame`, `New-PaintFrames`. These build exactly
   what is sent to the keyboard.
3. **Keymap model** - key/function tables, `Cfg.ini` reader and writer, `New-KeymapBlock`
   (encoder), `Get-KeymapIssues` (validation).
4. **Preview layout, effect animation, lighting sync and settings** - key geometry, the C# animation
   engine `FizzAnim`, `ConvertFrom-LightingFrames` (decodes what the keyboard reports),
   `Read-DeviceLighting`, settings file.
5. **Windows HID access** - C# P/Invoke layer: finds the keyboard's HID collections, routes frames to
   the one that declares the report ID.
6. **Shared helpers** - `Write-Log`, `Send-Frames`.
7. **GUI** - theme, the shared preview control (`Draw-Preview`), header, the three tab panels, tools
   menu, then behaviour: `Set-Tab`, `Invoke-ApplyEffect`, `Sync-FromKeyboard`, keymap functions,
   event wiring at the bottom.

## Running the tests

Install [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell)
(works on Linux, macOS and Windows), then from the repository root:

```
pwsh dev/tests/run-logic-tests.ps1     # data, decoding, animation, Cfg.ini handling
pwsh dev/tests/run-ui-test.ps1         # scripted session through every tab
```

Both exit with code 1 on any failure. Optional, needs Python and `pip install fizzctl
--ignore-requires-python --no-deps`:

```
python3 dev/reference/gen_cases.py --out cases.json
pwsh dev/reference/check-frames.ps1 cases.json
```

If you change anything that goes to the keyboard, the golden hashes in `run-logic-tests.ps1` and the
reference check will tell you. Only update a golden hash when you can explain why the bytes changed.

## Rules that keep it working on Windows PowerShell 5.1

- **ASCII only** in the file. Windows PowerShell reads a file without a byte-order mark as ANSI, so
  any other character becomes garbage. Build non-ASCII characters at run time (`[char]0x25CF`).
- **CRLF line endings**, as the file is shipped.
- C# inside `Add-Type` is compiled as **C# 5**: no `?.`, `$"..."`, `=>` bodies or `out var`.
- Nothing newer than PowerShell 5.1: no `??`, ternary `?:`, `&&`/`||`, `ForEach-Object -Parallel`.
- PowerShell variable names are **case-insensitive**: a parameter `$Cases` and a local `$cases` are
  the same variable.
- A function that returns an array or a `List` should use `return , $x` so it is not unrolled, and
  callers should not wrap it again in `@()`.
- Inside a method call, `-f` followed by a comma list is split into arguments. Build the string on
  its own line first.
- Event handlers run in the script scope, so they can read script variables, but use `$script:` to
  change them.
- Wrap anything drawn in a `Paint` handler in `try/catch`; an exception there leaves a red X.
- Never write to the keyboard from code that runs on load, on a timer without a debounce, or in a
  loop.

## Common changes

- **Tune a preview animation** - `dev/tests` only checks that frames are valid, so judge by eye. The
  effects are in `FizzAnim.Render` (a `switch` on the effect id); each case sets a hue and an
  intensity per key.
- **Add or rename a keyboard function** - the `SpecialList` table. Verify the code on a real
  keyboard and record how you verified it in `docs/PROTOCOL.md`.
- **Change the layout or add a control** - GUI section; add a step to `dev/tests/ui/scenario.ps1`
  that clicks it. The stand-in library `dev/tests/ui/fakeui.cs` only has the WinForms members this
  app uses - add what you need there.
- **Support another keyboard** - the USB IDs, frame templates, key geometry and the capability table
  are all K617-specific. Start with `docs/PROTOCOL.md`.

## Pull requests

- Say what you changed and what you tested (tests, and on which keyboard if hardware is involved).
- Keep personal files out: your `Cfg.ini`, firmware backups, screenshots with your user name in
  the title bar or paths. `.gitignore` covers the common ones.
- AI-assisted contributions are welcome (this project was made that way). Please say so, and run the
  tests.
