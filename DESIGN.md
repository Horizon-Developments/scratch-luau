# BlockScript design

Source of truth for the UI palette and every decoration. `src/UI/Theme.lua` implements this file; change both together.

## Palette
Two neutrals, one accent, one status color. Category colors come from the block registry (`defineCategory`), not from here.

| Token | RGB | Use |
|---|---|---|
| ground | 28, 30, 34 | workspace canvas |
| panel | 42, 45, 51 | palette, tab column, toolbar, console |
| text | 235, 237, 240 | text on neutrals |
| textDim | 160, 165, 174 | secondary text, 1px outlines on floating panels |
| accent | 76, 139, 245 | Run button and selection / the field being edited. Nothing else. |
| error | 244, 120, 120 | status only: the block that stopped a run, error lines in console and Transfer |
| field | 246, 246, 246 | input field fill (light + dark text = "you can type here") |
| fieldText | 30, 32, 36 | text in fields |

Category colors (registry, Scratch's own palette from scratch-gui): Events 255,191,0 | Control 255,171,25 | Variables 255,140,26 | Lists 255,102,26 | Operators 89,192,89 | Sensing 92,177,214 | Output 15,189,140 (Scratch's extension teal) | My Blocks 255,102,128. Outline = the colour x 0.78.

Why eight hues: the category colour is the only way to tell which palette tab a block came from, and it is what Scratch users already read. This is a functional colour code, not decoration, and it is the one place the 2-3 core colours rule (R-29) is knowingly exceeded.

## Contrast (WCAG AA, measured)
Text on a block is whichever of white or the dark field text (30,32,36) has the higher contrast on that category colour (`Theme.textOn`); on all eight Scratch colours that is the dark text, 5.6 to 9.9:1 (white would be 1.5 to 3.0:1). Set `Theme.whiteBlockText = true` for Scratch's white labels; that fails AA. Run label is dark on accent (4.9:1). Dropdown fields are the block colour x 0.5 with white text (5.9 to 8.8:1). Body text on panel 11.8:1, dim text on panel 5.6:1, error on panel 5.1:1.

## Type and size
GothamMedium 14 for UI: a geometric sans that stays legible at small sizes on a phone. Code font for console output only, because output lines are program text and should align. Dark theme only: a code editor is used for long stretches and the block colours read best on a dark ground. Block row 40 plus 4px holder padding gives a 44px touch target; toolbar buttons, tabs and console buttons are 44px. Root is scaled 0.7-0.8 to fit the viewport, so on screen the targets are smaller than 44px (see Known gaps).

## Direction and dials
This file was written by the agent from the existing code, not supplied by the product owner. Under antislop R-37 that makes the design a draft. Dials: ENERGY 1 / RHYTHM 1 / MOTION 1 (a tool: uniform blocks, no animation).

## Shape language (function, not style)
Silhouettes follow scratch-blocks' renderer (zelos geometry), built from Frames (`src/UI/Shapes.lua`):
- Stack, C and hat blocks: a connector tab under the block and a matching notch in the top of the block below. The tab shows where blocks snap.
- Hat: dome on top, no notch, because it starts a script and nothing can attach above it. The define hat is a bowler hat, rounded on all four corners.
- Cap (stop all / this script, forever): no tab, nothing can follow it.
- Reporter: pill, round ends. Boolean: hexagon, pointed ends. The silhouette tells which slots accept it.
- Fields: round. Free text is light with dark text; a dropdown is a darker shade of the block with white text.
- C block: left arm and bottom footer wrap the inner stack.
- 4px corner radius on panels and buttons. No pill buttons.

## Decorations and why each exists
| Decoration | Reason |
|---|---|
| 1px darker edge on each block | separates adjacent blocks of the same category |
| connector tab + notch | shows where a stack block connects; the tab belongs to the block above and draws over the next one |
| hat dome, bowler corners | marks the top of a script; a different top for the define hat |
| hexagon ends, pill ends | the block's output type, which slots accept it |
| darker hexagon in an empty boolean slot | marks a slot that takes only booleans |
| 1px textDim outline on menu and Transfer panel | separates them from the same-colored surface behind |
| 2px accent outline on a text box | marks the field being edited |
| one drop shadow on the block being dragged | elevation means "being held"; no other shadow exists |
| red on a block | the block that stopped a run |

## Not used
Gradients, glow, glassmorphism, pill buttons, emoji, decorative badges, dots, arrows, stripes, dead navigation, non-functional controls. (Pills are block and field shapes, not buttons: they are the Scratch shape language.)

## Controls
Run, Stop, Clear workspace, Save, Load, palette tabs, and the console ask box all do something. Nothing is placeholder.

## Known gaps
- Never run in Roblox Studio (R-35). The block shapes in particular (`Shapes.lua`) are only checked against a fake UI API in `tests/t_shapes.lua`: real layout of the hexagon points, the tab over the next block, and the dome clip is unverified.
- A C block's mouth is the block colour, not open like Scratch's.
- Blocks are built by dragging only. There is no Tab / Enter / Escape path for building (R-32). Text fields and the Save/Load panel use normal Roblox text boxes.
- UIScale 0.7-0.8 makes the effective touch targets about 31-35px on screen.
- Editable value fields inside blocks are 24px tall.
- No empty-workspace hint has been checked or added.

## Icons (Scratch's own)
- Green flag on `when flag clicked`: names the event the hat waits for (Scratch's wording and picture). Reason: the flag is how Scratch users recognise the start hat.
- Loop arrow in the bottom arm of repeat / forever / repeat until / while / for each: tells a loop C-block from an `if` C-block. Reason: same cue as Scratch.
- Both are PNG renders of scratch-blocks media (Apache-2.0, `assets/`), loaded by `src/UI/Assets.lua`. No icon on any other block.

## Luau semantics (replaces Scratch's value rules)
Blocks follow Luau, not Scratch. Reason: requested; programs here are Luau programs drawn as blocks.
- Truthiness: only `false` and `nil` are false (0, "" and "0" are true). A variable fits any boolean slot (`output = "any"`); an unset variable is `nil`.
- `=` is Luau `==` (no conversion, case-sensitive); `<` and `>` take two numbers or two texts and error otherwise. `tonumber` and `tostring` convert.
- `and` / `or` short-circuit and return an operand. Slots are `raw` (no conversion) and `lazy`.
- Number slots take numbers or numeric text; anything else (nil, true, "abc", blank) is an error, not 0.
- Numbers print with `%.14g` (0.1 + 0.2 prints 0.3), `nil` prints "nil". `round` is `math.round`; trig is in radians (`pi` block); `random` takes whole numbers and errors on an empty interval.
- Text: `length` / `letter` count bytes, negative `letter` counts from the end; `contains` is case-sensitive; `join` takes text or numbers only.
- Lists: out of range is `nil`, `item # of` returns `nil` when missing, indexes must be whole numbers (or last / random / all).
- Loops: `repeat` floors its count; `for i = 1 to n` reads `n` once; `for each item in list` walks a list.
- New blocks: `tonumber`, `tostring`, `nil`, `pi`, `error`, `pcall` (TRY / CATCH, message in a variable).
