# Developer tools

Nothing here is needed to use the app. These tools check changes without a keyboard.

| Tool | Needs | Checks |
|---|---|---|
| `tests/run-logic-tests.ps1` | PowerShell 5.1 or 7 | frame bytes against stored fizzctl hashes, sync decoding, color placement, animation engine, settings, `Cfg.ini` read/write/validation |
| `tests/run-ui-test.ps1` | PowerShell 7 | a scripted session through every tab: startup sync, preview, apply, auto-apply, paint, keymap editing and saving, log drawer, menu, dry run |
| `reference/gen_cases.py` + `reference/check-frames.ps1` | Python 3, `fizzctl`, PowerShell | 5,088 frame comparisons against fizzctl itself |

## How the UI test works

`run-ui-test.ps1` copies `fizz-gui.ps1`, swaps the WinForms and GDI+ type names for the stand-ins in
`tests/ui/fakeui.cs`, swaps the two lines that open the keyboard for a fake device
(`tests/ui/fakedev.ps1`), and runs the copy. `tests/ui/scenario.ps1` is run right after the window
"shows" and drives it by firing the same events a user would: clicks, mouse moves, timer ticks.

What it cannot tell you: how it looks, whether the animation is smooth, or what a real keyboard does.

The sample `Cfg.ini` the tests use is generated at run time from data embedded in the app
(`tests/sample-cfg.ps1`), so no vendor or personal file is needed.
