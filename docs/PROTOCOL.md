# What this tool knows about the K617 Fizz

Most of this comes from [fizzctl](https://github.com/ayoubdya/fizzctl), which reverse-engineered the
keyboard's vendor protocol on Linux. This page records that knowledge as used here, plus what was
learned making it work on Windows. Each item is marked **(fizzctl)** if it comes from fizzctl,
**(observed)** if it was seen on a real keyboard while building this tool, or **(inferred)** if it is
a conclusion that fits the evidence but was not confirmed on hardware.

## Device

- USB `258A:0049`, stock OEM firmware (USB manufacturer string "BY Tech", product "Gaming
  Keyboard") **(observed)**.
- Lighting and keymap are configured through two vendor HID feature reports **(fizzctl)**:
  report **5** (6 bytes, used for command/selector frames) and report **6** (1032 bytes, data
  blocks).

## Windows HID layout **(observed)**

Windows exposes every top-level HID collection as its own device. On the test keyboard:

| Collection | Usage page / usage | Feature reports |
|---|---|---|
| `mi_00` | 0x0001 / 0x06 (keyboard) | none |
| `mi_01/col01` | 0x0001 / 0x80 (system control) | none |
| `mi_01/col02` | 0x000C / 0x01 (consumer) | none |
| `mi_01/col03` | 0xFF00 / 0x01 (vendor, input only) | none |
| `mi_01/col04` | 0x0001 / 0x06 (NKRO keyboard) | none |
| `mi_01/col05` | 0xFF00 / 0x01 | report 5, 6 bytes |
| `mi_01/col06` | 0xFF00 / 0x01 | report 6, 1032 bytes |
| `mi_01/col07` | 0x0001 / 0x02 (mouse) | none |

Consequences:

- A frame must be sent to the collection that declares its report ID (5 -> `col05`, 6 -> `col06`).
  The tool reads the report IDs from the HID descriptor and routes each frame.
- **Report 8** (the 382-byte live per-key frame that fizzctl streams for animations) is *not*
  declared by any collection. Linux hidraw forwards it anyway; Windows rejects it with error 87.
  Live per-key painting is therefore not possible through the Windows HID API.
- Sending a frame with its exact length works; the tool falls back to padding to the collection's
  feature length only if Windows rejects the exact length (never needed on the test keyboard).
- `GET_FEATURE(6)` without a preceding selector fails (error 31); a selector must come first.

## Write sequences (flash) **(fizzctl)**

All of these are sent with ~60 ms between frames and persist across reboots.

- **Effect:** `INIT` (`05 83 b6 00 00 00`), then `GET_FEATURE(6, 1032)` as a handshake, then four
  1032-byte blocks: MODE (`06 08 b8`), CANVAS (`06 09 bc`), ROUTING (`06 09 c0`), EXEC (`06 03 b6`).
  The EXEC block commits to flash.
- **Per-key paint:** `INIT`, handshake, CANVAS, ROUTING, then a fixed EXEC block. Keys not painted
  turn off.

## Effect block layout

- `EXEC[21]` = effect id: 1..20 in menu order, 21 = self-define (per-key), 22 = off **(fizzctl;
  some ids are inferred by fizzctl from menu position)**.
- `EXEC[39 + 2*(id-1)]` = `(speed-1) << 4 | brightness` for that effect (speed 1..5, brightness
  0..4) **(fizzctl)**.
- `EXEC[38 + 2*(id-1)]` = `0` for a single custom color, `7` for the effect's multicolor mode
  **(fizzctl)**.
- Custom color for effect `id` is the RGB triple at `MODE[29 + 21*(id-1)]` **(inferred)**. fizzctl
  verified effects 1 (offset 29), 10 (218) and 13 (281) on hardware; these three fit the formula
  exactly, and the MODE template contains one identical 21-byte record per effect, each starting with
  a baked red color. fizzctl itself writes every other effect's color into effect 10's slot, which
  leaves those effects red. This tool uses the per-effect formula for all of them.
- Which effects accept a speed, brightness or custom color comes from the `LedOpt` table in the
  vendor's `Cfg.ini` **(observed in the vendor file)**: no custom color for rainbow, rainbow wheel,
  rotating windmill, colorful waterfall and blossoming; fixed-on has no speed.

## Reading the current state **(fizzctl, used here read-only)**

Send a selector in report 5, wait ~60 ms, then `GET_FEATURE(6, 1032)`:

| Block | Selector |
|---|---|
| MODE | `05 88 b8 00 00 00` |
| EXEC | `05 83 b6 00 00 00` (the same bytes as the write sequence's INIT) |

The returned frames use the same offsets as the write frames, so the layout above can be decoded
directly. How faithfully the read-back follows changes made with the keyboard's own Fn keys has not
been confirmed.

## Paint canvas **(fizzctl)**

In the 1032-byte CANVAS block, key LED `n` has its blue value at `8 + n`, green at `134 + n` and red
at `260 + n`; a 106-byte fixed trailer sits at offset 660. LED numbers are the position in the
keyboard's LED matrix (for example Esc = 21, Space = 110).

## Keymap block **(fizzctl)**

1032 bytes, header `06 04 d4 00 40 00 00 00`:

- 256 four-byte column records starting at `0x08`, indexed by the key's matrix column.
  `20 00 00 00` = Fn key, `02 00 00 NN` = key with an Fn-layer entry `NN`, `06 00 00 HID` =
  modifier, `00 00 00 HID` = ordinary key.
- Fn-layer tables for up to **48** keys: region B at `0x218` (the key's base output) and region C at
  `0x2d8` (its Fn-layer output), entries ordered row by row. fizzctl does not check the 48-key
  limit; this tool refuses more.
- Output types in `Cfg.ini`: `0x02` = key by Windows virtual-key code, `0x04` = media key,
  `0x09` = keyboard function (4-byte code).

## Keyboard function codes (`0x09`)

| Code | Meaning | Source |
|---|---|---|
| `0x0b000300` | Backlight mode: next effect | Fn+Alt, per a Redragon K617 review **(observed by the owner)** |
| `0x0c000300` | Backlight brightness (cycle) | review: Fn+M |
| `0x0d000300` | Backlight speed (cycle) | review: Fn+comma |
| `0x0e000007` | Backlight color (cycle) | redragonKB-remap docs, unverified |
| `0x0e000006` | White backlight | redragonKB-remap docs, unverified |
| `0x0e000001` | Lock Windows key | redragonKB-remap docs, unverified |

The redragonKB-remap documentation labels `0x0b000300` "reset keyboard" and `0x0d000300` "RGB
mode"; the first was found to be wrong on real hardware (it changes the backlight mode), and the
second contradicts the K617 review. The keyboard's real factory reset is the built-in Fn+Esc hold,
not a configurable key.

Review used for the key behaviours:
<https://redragonshop.com/blogs/community/the-king-of-budget-60-keyboards-redragon-fizz-k617-keyboard-review>

## Open questions

- Do the color positions for the effects fizzctl did not verify match real hardware?
- Does the read-back track changes made through the keyboard's own Fn shortcuts?
- Writing the keymap directly (instead of going through a `Cfg.ini` and the vendor software) is not
  implemented. fizzctl's `keymap` command shows the write sequence; it also needs the live lighting
  and macro blocks read first so they are not reset.
