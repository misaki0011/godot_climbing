# Obby2D

Godot 4 2D single-player tower-climb timing game where the player climbs a single tall ladder with `Space` while avoiding crossing airborne obstacles.

## Current Behavior

- Boot opens the title screen.
- `Start` opens a stage select screen for `Level01`, `Level02`, and `Level03`.
- `Level01` is a Tokyo Tower climb, `Level02` is a Skytree climb, and `Level03` is a Burj Khalifa climb.
- Each level spawns the player at the base of one central ladder and starts the stage timer.
- Each spawn point is aligned to the ground level of its tower backdrop, and each goal is anchored to the top of its tower image.
- The base of the ladder is marked with a `START` text label instead of a geometric start icon.
- Pressing `Space` moves the player upward by one fixed ladder step.
- The player does not walk or jump sideways during gameplay.
- Moving hazards sweep horizontally or diagonally across the ladder path at different heights.
- Touching any hazard increments deaths and respawns the player at the base quickly.
- Touching the goal at the top ends the stage and transitions away from gameplay to a separate stage clear page.
- The stage clear page shows the stage name, clear time, and death count.
- The stage clear page offers `Play Again` and `Back to Select`.
- `Esc` pauses and opens the pause menu.
- `R` retries the current stage immediately.
- The in-game HUD includes extra-large on-screen `CLIMB`, `RETRY`, and `PAUSE` buttons so the game can be played on desktop or touch devices.
- Menus and HUD controls use portrait-first scaling so phone screens stay readable while landscape gets a roomier version of the same layout.
- The camera follows the ascent up tower-themed backdrops loaded from `assets/tokyotower_tp.png`, `assets/skytree_tp.png`, and `assets/burj_khalifa_tp.png`.

## Controls

- `Space`: Climb one step
- `Esc`: Pause
- `R`: Restart level
- Touch `CLIMB`: Climb one step
- Touch `PAUSE`: Pause or resume
- Touch `RETRY`: Restart level

## Player Movement

The player controller is implemented in `player/Player.gd` and currently includes:

- fixed-position ladder climbing
- one-step movement per button press
- short climb animation with slight side-to-side sway
- respawn flash feedback
- camera limit configuration per level

Current tuning:

- step height: `52.0`
- step duration: `0.16`
- sway distance: `10.0`

Design rules for future stages:

- Keep the player locked to a single ladder path for the full run.
- New climb input should only advance one discrete step.
- Hazard routes must cross the ladder path clearly enough that waiting for timing is the main challenge.
- Respawns should stay fast and readable so repeated attempts feel immediate.

## Scenes

### Root

- `Main.tscn`: Main game flow, menus, overlays, and level loading

### UI

- `ui/TitleScreen.tscn`
- `ui/LevelSelect.tscn`
- `ui/HUD.tscn`
- `ui/PauseMenu.tscn`
- `ui/StageClear.tscn`: Separate visible results page shown after leaving the stage

### Active Gameplay

- `player/Player.tscn`
- `objects/Goal.tscn`
- `objects/MovingHazard.tscn`

### Levels

- `levels/Level01.tscn`: Tokyo Tower climb stage with the spawn aligned to the tower base and the goal near the top
- `levels/Level02.tscn`: Skytree climb stage with a taller skyline silhouette, faster hazard sweeps, and a higher goal
- `levels/Level03.tscn`: Burj Khalifa climb stage with the tallest camera range, the fastest hazard routes, and a higher final goal

## Managers

- `managers/GameManager.gd`: Route changes, stage progression, unlock state during runtime
- `managers/LevelManager.gd`: Timer, deaths, respawn point, and stage clear stats
- `managers/AudioManager.gd`: Placeholder sound hook emitter

## Visual Style

- Simple placeholder geometry using `Polygon2D` for hazards and markers
- The tower backdrops are shown with imported texture resources from `assets/tokyotower_tp.png`, `assets/skytree_tp.png`, and `assets/burj_khalifa_tp.png`
- `Level01`, `Level02`, and `Level03` keep the backdrop presentation simple without extra sky/glow layers
- The stage start marker is shown as `START` text near the spawn point
- The HUD shows extra-large on-screen controls for web/mobile-friendly play
- Menus and HUD text/buttons use a portrait-first layout that expands naturally in landscape
- Flying hazards cross the ladder lane to create readable timing windows
- The goal uses an imported gem texture resource at the top of the climb

## Audio

Audio playback is not implemented with sound files yet.

Current sound hook events:

- `climb`
- `death`
- `clear`

## Notes

- Level unlocks are runtime-only.
- There is no persistent save system.
- Legacy platformer scenes from the previous prototype still exist in the repository but are not used by `Level01`.
- The project is intended to open directly in Godot 4.5 and run from `Main.tscn`.

## Web Deployment

- The repository includes a GitHub Pages workflow at `.github/workflows/github-pages.yml`.
- Pushing to the `main` branch, or running the workflow manually, exports the `Web` preset and deploys `build/web` to GitHub Pages over HTTPS.
- Before the first Pages deployment, open the GitHub repository settings and set `Pages` to deploy from `GitHub Actions`.
- After the workflow finishes, open the `github.io` Pages URL on desktop or phone to test the web build with HTTPS.

## Validation

Last validated with:

- `godot4 --headless --path /home/haratake/godot_climbing --quit`
