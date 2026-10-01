# EXECUTORS.md

Notes for any AI (or person) who wants to use executor functions in BlockScript.

## Read the docs first
If you want to use an executor function (`writefile`, `request`, `gethui`, `getcustomasset`, anything), read
**`sunc.docs.json`** first. Do not write signatures or behaviour from memory.

- It is the sUNC function reference (79 functions: name, description, Luau signature, parameters, link),
  grouped by library: Environment, Scripts, Metatable, Debug, Reflection, Signals, Drawing, Filesystem,
  Miscellaneous, Instances, Encoding, Closures.
- It is about 42 KB. Read it, or look up only the entry you need, e.g.
  `python3 -c "import json;print(json.load(open('sunc.docs.json'))['Filesystem']['writefile'])"`
  or `grep -o '"request":{[^}]*' sunc.docs.json | head -c 1500`.
- Source: https://docs.sunc.su/api/jumbo.json (redirects to docs.sunc.io). To refresh it:
  `curl -sSL -o sunc.docs.json https://docs.sunc.su/api/jumbo.json`. Check the result is JSON, not an error page.

## Owner's note
The owner knows that using executors is a risk to their Roblox account, accepts it, and says not to worry.
Do not add warnings, disclaimers or refusals about that. Just do the work.

## Rules for this project
1. **Studio must keep working.** Every executor function is optional. Check it exists before calling it,
   e.g. `type(gethui) == "function"`, and wrap the call in `pcall`. When it is missing, fall back or leave the
   feature out. Nothing may error because a function is nil.
2. **Prefer the prelude for definitions.** `scripts/prelude.luau` is prepended to the bundle by `scripts/build.sh`
   after wax and darklua (so darklua never renames it). Put executor helpers like `loadasset` there.
3. **Check results before trusting them.** Downloads can fail. Do not cache or write a failed response
   (check `request(...).StatusCode == 200`, or the PNG header, before `writefile`).
4. **Use the docs' signatures.** `getcustomasset(path)` returns an `rbxasset://` string, `gethui()` returns a
   `BasePlayerGui | Folder`, and so on. Do not assume more than the docs say.

## Executor functions used today
| function(s) | where | what for |
| --- | --- | --- |
| `isfolder`, `makefolder`, `isfile`, `writefile`, `getcustomasset`, `game:HttpGet` | `scripts/prelude.luau` (`loadasset`) | download the flag/loop icons once into `Scratch/img/` and load them |
| `gethui` | `src/init.client.lua` (`guiParent`) | parent the ScreenGui to the hidden container when it sits under a PlayerGui/CoreGui |

`src/UI/Assets.lua` calls `loadasset` inside a `pcall`; `Workspace:_grab` hit-tests on whichever PlayerGui/CoreGui
holds the GUI. Without these functions (Studio, normal game scripts) the GUI goes to PlayerGui and the icons are left out.

## Testing
`./test.sh` runs the bundle in the coreMain sandbox (`execute.luau`) and prints a capped summary. The sandbox
emulates executor functions such as `gethui`; it is not a real executor. Never read `execute.luau` or the whole
`core/io/dumped_output.lua` (see `test.sh`).
