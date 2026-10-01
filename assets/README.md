# assets

Icons copied from Scratch's own block set (scratch-blocks, `media/`), rendered from SVG to 96x96 PNG because
Roblox cannot load SVG. scratch-blocks is Apache-2.0: see `LICENSE-scratch-blocks.txt`.

| file             | source in scratch-blocks            | used by                                             |
| ---------------- | ----------------------------------- | --------------------------------------------------- |
| icons/flag.png   | media/icons/event_whenflagclicked   | `when {@flag} clicked` hat                          |
| icons/loop.png   | media/repeat.svg                    | footer of repeat / forever / repeat until / while / for each |

Loaded at runtime by `src/UI/Assets.lua`:
`loadasset(game:HttpGetAsync(BASE .. path))` -> `"rbxasset://..."`. Change `Assets.BASE` if the repo layout differs.
