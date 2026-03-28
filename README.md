# Obby2D

Godot 4 2D single-player tower-climb timing game where the player climbs a single tall ladder with `Space` while avoiding crossing airborne obstacles.

## Current Behavior

- Boot opens the title screen.
- `Start` opens a stage select screen for `Level01`, `Level02`, and `Level03`.
- `Level01` is a Tokyo Tower climb, `Level02` is a Skytree climb, and `Level03` is a Burj Khalifa climb.
- Each level spawns the player at the base of one central ladder and starts the stage timer.
- Each tower backdrop is anchored so its bottom touches the spawn ground line at original scale, the stage hazards shift with that tower alignment, the camera top extends high enough to show the full tower, and each goal is anchored to the top of its tower image.
- During gameplay, the HUD shows both the current timer and the stage target time so players can compare their pace live.
- Pressing `Space` moves the player upward by one fixed ladder step.
- The player does not walk or jump sideways during gameplay.
- Moving hazards sweep horizontally or diagonally across the ladder path at different heights.
- Touching any hazard increments deaths and respawns the player at the base quickly.
- Touching the goal at the top ends the stage and transitions away from gameplay to a separate stage clear page.
- The stage clear page shows the stage name, gem reward, and a compact three-line reward breakdown for `Clear`, `Deaths xN`, and `Time current/target`.
- The stage clear page always shows `Next`, `Restart`, and `Back` in that order, and unavailable actions are disabled instead of being hidden or renamed.
- `Esc` pauses and opens a bottom-left pause menu above the HUD button.
- `R` retries the current stage immediately.
- The gameplay HUD includes a `DEBUG SKIP` button that immediately clears the current stage and opens the result screen.
- The gameplay HUD includes a bottom-left button that toggles between `PAUSE` and `RESUME`, and the pause menu opens right above that button on touch devices.
- During gameplay, tapping or clicking anywhere on the playfield climbs one step so phone/web players do not need a dedicated `CLIMB` button.
- The in-game HUD now focuses on stage info instead of showing large on-screen `CLIMB`, `RETRY`, and `PAUSE` buttons.
- The title screen, level selection screen, and result screen are intentionally oversized so they stay easy to read and tap on phones.
- The title, level selection, result, and pause screens use extra spacing between primary actions and secondary exit actions so the button groups read more clearly.
- The pause and result screens use short labels like `Restart` and `Back` for faster recognition on phones.
- Buttons now use a consistent role-based color system: bright blue for forward actions like `Start`, `Next`, and level buttons; muted blue-gray for `Restart`, `Back`, `Quit`, and `PAUSE` / `RESUME`; a flatter dark disabled style for unavailable actions; and a separate debug color for `DEBUG SKIP`.
- The level selection screen shows a right-aligned total-gem row with a gem icon plus a per-stage gem value in a simple two-column list without target times.
- The level selection screen also shows `Level 4 - Coming Soon` as a visible non-playable row so the next stage is visible before it is implemented.
- Menus and HUD controls use portrait-first scaling so phone screens stay readable while landscape gets a roomier version of the same layout.
- The camera follows the ascent up tower-themed backdrops loaded from `assets/tokyotower_tp.png`, `assets/skytree_tp.png`, and `assets/burj_khalifa_tp.png`.
- The player character is a back-view climbing ninja-cat that alternates between two climb frames instead of a plain placeholder block.

## Controls

- `Space`: Climb one step
- `Esc`: Pause
- `R`: Restart level
- `PAUSE` / `RESUME` button: Toggle the pause menu
- `DEBUG SKIP` button: Immediately clear the current stage for testing
- Tap or click anywhere during gameplay: Climb one step

## Rewards

- Clearing a stage grants a base reward of `1.0` gem.
- Each death subtracts `0.2` gems from that stage reward.
- Finishing at or under the stage target time grants an extra `0.3` gems.
- Stage reward is clamped to a minimum of `0.0` gems.
- The selection screen shows the total gems as the sum of the best reward earned on each stage so far during the current run, plus the best gem reward per stage.

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
- `levels/Level02.tscn`: Skytree climb stage with a taller skyline silhouette, faster hazard sweeps, and upper hazards that now reach closer to the tower tip
- `levels/Level03.tscn`: Burj Khalifa climb stage with the tallest camera range, the fastest hazard routes, and upper hazards distributed much closer to the top of the tower

## Managers

- `managers/GameManager.gd`: Route changes, stage progression, unlock state during runtime
- `managers/LevelManager.gd`: Timer, deaths, respawn point, and stage clear stats
- `managers/AudioManager.gd`: Placeholder sound hook emitter

## Visual Style

- Simple placeholder geometry using `Polygon2D` for hazards and markers
- The tower backdrops are shown with imported texture resources from `assets/tokyotower_tp.png`, `assets/skytree_tp.png`, and `assets/burj_khalifa_tp.png`
- `Level01`, `Level02`, and `Level03` keep the backdrop presentation simple without extra sky/glow layers
- The HUD shows enlarged stage info, current time, target time, and `PAUSE` / `DEBUG SKIP` buttons while climb input comes from tapping or clicking the gameplay screen
- The title, level select, result, and pause menus use oversized panels plus brighter rounded buttons for mobile-friendly readability, with the pause menu anchored near the bottom-left HUD controls
- Those menu screens also separate primary action groups from `Back`, `Quit`, or other leave-screen actions with a larger vertical gap
- The pause and result actions favor shorter labels like `Restart` and `Back`
- Button colors now communicate role consistently across the game: primary progression, secondary utility/navigation, disabled/unavailable, and debug-only actions
- Menus and HUD text/buttons use a portrait-first layout that expands naturally in landscape
- The player is rendered as a back-view climbing ninja-cat using two alternating PNG climb frames while hazards and markers remain simple placeholder shapes
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

## Build

- Open locally in the editor:
  - `godot4 -e --path .`
- Run the game locally:
  - `godot4 --path .`
- Headless validation:
  - `godot4 --headless --audio-driver Dummy --path . --quit`
- Export the web build:
  - `mkdir -p build/web`
  - `godot4 --headless --audio-driver Dummy --path . --export-release Web build/web/index.html`
  - `cd build/web`
  - `python -m http.server 8080`
- The web export preset writes the browser build into `build/web/`.
- Godot 4.5 export templates must be installed before running the web export command.

## Web Deployment

- The repository includes a GitHub Pages workflow at `.github/workflows/github-pages.yml`.
- Pushing to the `main` branch, or running the workflow manually, exports the `Web` preset and deploys `build/web` to GitHub Pages over HTTPS.
- Before the first Pages deployment, open the GitHub repository settings and set `Pages` to deploy from `GitHub Actions`.
- After the workflow finishes, open the `github.io` Pages URL on desktop or phone to test the web build with HTTPS.

## Validation

Last validated with:

- `godot4 --headless --path . --quit`
