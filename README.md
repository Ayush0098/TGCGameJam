# Lightbulb Moment

**Shine a light into a comic strip, swap what the characters are thinking, and watch the punchline twist.**

Our entry for the **TGC Game Jam at Infinium 2026** (IIIT Hyderabad). The jam's themes are **Comic**, **Twist** and **Light**.

You play a mischievous lightbulb loose inside a newspaper comic. Each page first plays its original, predictable punchline. Then a red pen demands a twist. You can't move anyone. You can only choose who is lit, and therefore who acts and what they can see, and swap the thoughts in their heads. Press ACTION and watch your edit set off a chain of slapstick until the final panel matches the twisted caption.

## Status

A **15-page campaign** in three acts (green, yellow and red difficulty), opened by a
skippable six-panel tutorial on page 1. Seven feelings drive the cast: HUNGRY,
SLEEPY, ANGRY and SCARED, plus SHY, IN LOVE and JEALOUS, each introduced by a
NEW FEELING card on its debut page. Every page has a twist, bonus headlines
(up to three stars), an Endings book, a step-by-step HINT and a spare bulb
(FLICK) on the later pages. Every star is audited to have one or two solutions.

The game has painted rooms that fill the screen, rigged SVG characters, a voiced
narrator and character reactions, layered music, a torch-lit title screen,
page transitions, star awards and full keyboard play. Progress, settings and
the tutorial state are saved. The story and narration are being revised; no
public release has been published yet.

## Proposal

The game proposal is in [`proposal.pdf`](proposal.pdf) at the root of this repository.

## Built with

- [Godot 4.7.2 stable, standard edition](https://godotengine.org/download/archive/4.7.2-stable/)
- GDScript, Compatibility renderer, single-threaded Web export
- Third-party resources and credits: [THIRD_PARTY.md](THIRD_PARTY.md)

## Open and run

Use Godot **4.7.2 standard**, import `src/project.godot`, then press **F5**.
Each page first plays its Original; click or press any key to skip it.

| | Mouse | Keyboard |
|---|---|---|
| Move the bulb | drag it | arrows or WASD (up/down raise and lower it) |
| Second bulb | drag it off its hook | 1 / 2 select, P parks or hangs it |
| Swap thoughts | drag one lit thought onto another lit character | Tab / Q / E to choose, Enter to pick, Enter to swap, Esc cancels |
| Start the run | ACTION | Space (Space again skips) |
| Spare bulb | click the room during ACTION | left/right to aim, F to drop |
| Hint, restart, Original, Endings | buttons | H, R, O, B |
| Result | RETRY / NEXT PAGE | Enter (or N), R restarts, L levels |
| Menus | click | arrows and Enter, Esc goes back |

For command-line work, run these PowerShell commands from the repository root.
Set the executable path to your own extracted Godot download:

```powershell
$godotExe = 'C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $godotExe --editor --path '.\src'
```

To repeat the import and startup checks:

```powershell
& $godotExe --headless --path '.\src' --editor --import
& $godotExe --headless --path '.\src' --quit-after 3
```

## Art and voice reference

Launch the separate study from the repository root:

```powershell
& $godotExe --path '.\src' -- --production-reference
```

Choose Boss or Dog, an expression and an animation. Three voice buttons play
the narrator, Boss and an ending excerpt with subtitles. Reset stops the voice
and restores both characters. This scene demonstrates assets independently of
the puzzle simulator.

To preview the study while preserving the normal MVP export:

```powershell
New-Item -ItemType Directory -Path 'build\web\reference' -Force | Out-Null
$referenceBuild = Join-Path (Get-Location) 'build\web\reference\index.html'
& $godotExe --headless --path '.\src' --export-release 'Web Reference' $referenceBuild
node '.\src\tools\serve_web.mjs'
```

Open <http://127.0.0.1:8765/reference/index.html>. The server serves both exports.
Voice generation instructions and pinned production dependencies are in
`assets/audio/generate_reference.py` and `assets/audio/requirements-reference.txt`.
Generation runs offline after model downloads; the game ships recorded clips.
The speech model and production environment stay ignored.

## Development checks

After importing, run the headless test runner:

```powershell
& $godotExe --headless --path '.\src' --script 'res://tools/run_tests.gd'
if ($LASTEXITCODE -ne 0) { throw 'Godot checks failed' }
```

The current suites check radial coverage, obstacle shadows, halo boundaries,
two-lantern save/restore, content, legal edits, Appendix B's page 4/6 traces,
simultaneous interactions, goal truth, determinism, independent snapshots,
preview isolation and integrated retry/progression flow. A passing run
exits with code 0; assertion failures exit with code 1. To verify the runner's
failure path, append `-- --self-check-failure` (expected exit code 1).
Development tools and test suites are excluded from Web exports.

## Build and preview on the web

Install the matching **4.7.2 export templates** through Godot's
**Editor > Manage Export Templates**. The Web preset uses the Compatibility
renderer with threads and GDExtension support disabled.

```powershell
New-Item -ItemType Directory -Path 'build\web' -Force | Out-Null
$webBuild = Join-Path (Get-Location) 'build\web\index.html'
& $godotExe --headless --path '.\src' --export-release 'Web' $webBuild
node '.\src\tools\serve_web.mjs'
```

The preview server requires Node.js (verified locally with **v24.20.0**) and
uses only built-in modules. Open <http://127.0.0.1:8765>; stop the server with
**Ctrl+C**. Serving the files over HTTP is required for the WebAssembly build.
Generated build output stays in the ignored, tool-neutral `build/` directory.
Before the first editor export in a fresh clone, create `build/web/` using the
`New-Item` command above, then export using the **Web** preset.

For a ZIP with `index.html` at its root:

```powershell
Compress-Archive -Path 'build\web\*' -DestinationPath 'build\lightbulb-moment-web.zip' -Force
```

The earlier rail-based Web build was played through in Chromium: legal dragging,
dark-target rejection, three intended wins, SKIP and normal page 6 playback.
The radial-lantern controls were checked separately in the browser: all three
wins, second-lantern reveal, parking and repositioning. Headless checks cover
exact rewind, ACTION locking, geometry and hidden thoughts.
Fresh-player feedback and itch.io hosting checks remain pending.
See [the playtest checklist](tests/PLAYTEST.md).

## Repository layout

- `src/project.godot`: Godot project entry point
- `src/scenes/`: responsive main scene
- `src/core/`: content validation, plan edits, shared rules, simulator and goals
- `src/data/pages/`: authored MVP page definitions (2, 4, 6)
- `src/game/`: session flow and playback integration
- `src/presentation/`: scalable greybox stage and drag input
- `src/assets/`: runtime painting, SVG cutouts, thought icons, recorded audio and reference manifest
- `src/licenses/`: Godot license and bundled dependency notices, included in exports
- `src/tools/`: development tooling, excluded from game exports
- `src/tests/`: executable headless suites, excluded from game exports
- `assets/`: source art and production files outside Godot's resource root
- `tests/`: reserved for test instructions and reports
- `proposal.pdf`: the game proposal (required submission file)
