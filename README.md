# Lightbulb Moment

**Shine a light into a comic strip, swap what the characters are thinking, and watch the punchline twist.**

Our entry for the **TGC Game Jam at Infinium 2026** (IIIT Hyderabad). The jam's themes are **Comic**, **Twist** and **Light**.

You play a mischievous lightbulb loose inside a newspaper comic. Each page first plays its original, predictable punchline. Then a red pen demands a twist. You can't move anyone. You can only choose who is lit, and therefore who acts and what they can see, and swap the thoughts in their heads. Press ACTION and watch your edit set off a chain of slapstick until the final panel matches the twisted caption.

## Status

A playable three-puzzle sample contains **Nap Time**, **Midnight Snack** and
**The Boss's Birthday**. Nap Time now uses a painted vintage room, expressive SVG
characters, thought icons, animated actions and original sound effects. Its story
intro and winning conclusion use recorded voice auditions with subtitles,
skip/replay and a deliberate **Start story** button for browser audio.
The other two puzzles remain greybox while their artwork is produced.

Two radial lanterns reveal thoughts and activate characters. Gold rings mark
gameplay coverage; decorative halos reveal nothing. Swaps, first-move previews,
lamp chains, FAST/SKIP, Original/Twist results and exact-plan REWIND work.
The ten-level campaign, final narration, music, saves and epilogue are still in
production. A separate art/voice study remains available. No public playable
release has been published.

## Proposal

The game proposal is in [`proposal.pdf`](proposal.pdf) at the root of this repository.

## Built with

- [Godot 4.7.2 stable, standard edition](https://godotengine.org/download/archive/4.7.2-stable/)
- GDScript, Compatibility renderer, single-threaded Web export
- Third-party resources and credits: [THIRD_PARTY.md](THIRD_PARTY.md)

## Open and run

Use Godot **4.7.2 standard**, import `src/project.godot`, then press **F5**.
Choose **Start story** for narration, or **Skip voice** to watch the Original.
The game then returns to PLAN.
Drag a HUD hook into the marked area to deploy its lantern. Return the lantern
to a hook, click its hook, or press P to park it. Drag one lit thought onto another lit character,
then press **ACTION**. **Space** starts ACTION or skips playback.
With the stage focused, **1/2** selects a lantern, **arrow keys** move it,
**Shift + arrows** moves it more precisely, and **P** parks/deploys it.
Both lanterns lock during ACTION. Their personal idea markers do not illuminate
objects; fixed and switched lamps still determine what targets can be seen.
**REWIND** keeps your edited plan; **RESTART** restores the page defaults.
**ORIGINAL** replays the default story and preserves your edits.
**FAST** speeds up playback; **SKIP RUN** jumps to its result. **SKIP PAGE**
unlocks after three failed runs. Sound and Reduce motion are session settings.
After winning page 6, **PLAY AGAIN** restarts the MVP.

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
