# Ninja Cat Tower

Godot 4 2D single-player tower-climb timing game where the player climbs a single tall ladder with `Space` while avoiding crossing airborne obstacles.

## Overview

- `Ninja Cat Tower` is a simple one-ladder climbing game for PC and mobile web.
- Climb upward one step at a time while flying hazards sweep across the tower.
- Reach the gem at the top as fast as you can with as few deaths as possible.
- Clear stages based on Tokyo Tower, Skytree, and Burj Khalifa.
- Earn gems from each stage through a tower-height-based clear reward, low deaths, and target-time bonus.

## Current Behavior

- Boot opens the title screen.
- The title screen includes `Start`, `How To Play`, and `Quit`.
- The title screen now uses a simple stacked layout where the `Ninja Cat Tower` title artwork sits centered in the upper area with very little surrounding padding, while the buttons sit in a narrower padded lower area and a small music icon toggle stays inset from the upper-right edge on narrow screens.
- The title screen clamps its artwork height against the available button space so the full title stack stays visible on horizontal mobile/web viewports instead of clipping off the top.
- The title artwork is shown in an aspect-fit mode, so horizontal desktop/web views keep the full image visible instead of cropping the top of the logo art inside its frame.
- The title screen now switches to a wide layout on broad viewports, placing the artwork on the left and a balanced right-side control column on the right, with the music toggle staying clear of the main action buttons.
- The title screen uses the refreshed `cat_ninja_tower_title_v2.png` artwork, and the project/web icon now uses a square crop of the same tower-and-cat illustration for matching branding.
- `How To Play` opens a short instruction screen with two simple gameplay lines plus a control illustration for phone tap and PC `Space`.
- `Start` opens a stage select screen for `Level01`, `Level02`, and `Level03`.
- `Level01` is a Tokyo Tower climb, `Level02` is a Skytree climb, and `Level03` is a Burj Khalifa climb.
- Each level spawns the player at the base of one central ladder and starts the stage timer.
- Each tower backdrop is assigned directly as a scene texture resource, anchored so its bottom touches the spawn ground line at original scale, the stage hazards shift with that tower alignment, the camera top extends high enough to show the full tower, and each goal is anchored to the top of its tower image.
- During gameplay, the HUD shows both the current timer and the stage target time so players can compare their pace live.
- Pressing `Space` moves the player upward by one fixed ladder step.
- On desktop, `Space` stays dedicated to climbing and does not toggle HUD buttons even after they are clicked.
- The player does not walk or jump sideways during gameplay.
- Moving hazards sweep horizontally or diagonally across the ladder path at different heights.
- Touching any hazard increments deaths and respawns the player at the base quickly.
- Moving hazards do not start inside the lower-left HUD-safe zone near the `PAUSE` / `RESUME` control, so gameplay objects stay clearer around that button.
- Touching the goal at the top ends the stage and transitions away from gameplay to a separate stage clear page.
- The stage clear page shows the stage name, gem reward, and a compact three-line reward breakdown for tower-height clear reward, `Deaths xN`, and `Time current/target`.
- The stage clear page always shows `Next`, `Restart`, and `Back` in that order, and unavailable actions are disabled instead of being hidden or renamed.
- `Esc` pauses and opens a bottom-left pause menu above the HUD button.
- `R` retries the current stage immediately.
- The gameplay HUD includes a `DEBUG SKIP` button in editor/debug builds only, so testing can still skip a stage without exposing that action in release builds.
- The gameplay HUD includes a bottom-left `PAUSE` button, and the pause menu opens right above it as one aligned group of `RESUME`, `Restart`, and `Back` controls with the music toggle attached to the same block while staying pinned to the screen as the camera climbs.
- During gameplay, tapping or clicking anywhere on the playfield climbs one step so phone/web players do not need a dedicated `CLIMB` button.
- The in-game HUD now focuses on stage info instead of showing large on-screen `CLIMB`, `RETRY`, and `PAUSE` buttons.
- The title screen, level selection screen, and result screen are intentionally oversized so they stay easy to read and tap on phones.
- The title screen now favors a title-artwork-plus-buttons stack, with the artwork centered in a near-full-bleed upper area, the buttons grouped inside a narrower padded lower area, and a small music icon toggle in the upper-right so the opening page stays simple on phones.
- The title, level selection, result, and pause screens use extra spacing between primary actions and exit-style actions so the button groups read more clearly.
- The how-to-play screen uses the same centered oversized menu style as the other non-gameplay pages and now includes a control illustration near the top.
- The pause and result screens use short labels like `Restart` and `Back` for faster recognition on phones.
- The pause and result screens follow one placement rule: forward action first, utility action next, and exit action last.
- Buttons now use a consistent role/state color system: bright blue for primary forward actions like `Start`, `Next`, and playable level buttons; a darker exit color for `Back` and `Quit`; a lighter support-blue utility color for `How To Play`, `Restart`, `PAUSE`, and `RESUME`; a flatter dark disabled style that can override any button when unavailable; and a separate debug color for development-only actions like `DEBUG SKIP`.
- Menu panels and their inner content are centered on screen, and the component layout stays centered as screens get narrower instead of drifting toward one side.
- The level selection screen shows a right-aligned total-gem row with a gem icon plus a per-stage gem value in a simple two-column list without target times, now using two decimal places.
- The level selection screen also shows `Level 4 - Coming Soon` as a visible non-playable row so the next stage is visible before it is implemented.
- Menus and HUD controls use a shared adaptive scaling system so portrait phones stay large and readable while desktop and horizontal screens relax into a less oversized layout.
- Menu-style screens such as the title, how-to-play, level select, and result pages keep a slightly stronger scale than gameplay HUD overlays, so menus still feel bold on wide screens without overwhelming gameplay UI.
- UI sizing for every game view now comes from `ui/UIMetrics.gd`, which centralizes scale rules and per-view size tokens for the title, how-to-play, level select, HUD, pause menu, and result screens.
- Selection and result panels clamp to the available screen width so their contents stay centered and do not spill off-screen on narrow mobile viewports.
- The camera follows the ascent up tower-themed backdrops loaded from `assets/tokyotower_tp.png`, `assets/skytree_tp.png`, and `assets/burj_khalifa_tp.png`.
- The player character is a back-view climbing ninja-cat that alternates between two climb frames instead of a plain placeholder block.

## Controls

- `Space`: Climb one step
- `Esc`: Pause
- `R`: Restart level
- `PAUSE` button: Open the pause menu
- `DEBUG SKIP` button: Immediately clear the current stage for testing in editor/debug builds only
- Tap or click anywhere during gameplay: Climb one step

## Rewards

- Clearing a stage grants a base reward derived from the real tower height in hundreds of meters:
  - `Level01` Tokyo Tower: `3.33` gems
  - `Level02` Tokyo Skytree: `6.34` gems
  - `Level03` Burj Khalifa: `8.28` gems
- Each death subtracts a flat `0.6` gems from that stage reward.
- Finishing at or under the stage target time grants a flat `0.9` gem bonus.
- Stage reward is clamped to a minimum of `0.0` gems.
- The selection screen shows the total gems as the sum of the best reward earned on each stage so far during the current run, plus the best gem reward per stage, with values shown to two decimal places.

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
- `ui/HowToPlay.tscn`
- `ui/LevelSelect.tscn`
- `ui/HUD.tscn`
- `ui/PauseMenu.tscn`
- `ui/StageClear.tscn`: Separate visible results page shown after leaving the stage
- `ui/UIMetrics.gd`: Shared UI sizing/source-of-truth file for every game view

### Active Gameplay

- `player/Player.tscn`
- `objects/Goal.tscn`
- `objects/MovingHazard.tscn`

### Levels

- `levels/Level01.tscn`: Tokyo Tower climb stage with the spawn aligned to the tower base and the goal near the top
- `levels/Level02.tscn`: Skytree climb stage with a taller skyline silhouette, faster hazard sweeps, and upper hazards that now reach closer to the tower tip
- `levels/Level03.tscn`: Burj Khalifa climb stage with the tallest camera range, the fastest hazard routes, and upper hazards distributed much closer to the top of the tower
- `data/LevelCatalog.gd`: Shared level metadata catalog for scene path, display name, target time, clear reward, death penalty, and speed bonus

## Managers

- `managers/GameManager.gd`: Route changes, stage progression, unlock state during runtime
- `managers/LevelManager.gd`: Timer, deaths, respawn point, and stage clear stats
- `managers/AudioManager.gd`: Looping background music playback plus placeholder sound hook emitter

## Visual Style

- Simple placeholder geometry using `Polygon2D` for hazards and markers
- The tower backdrops are shown with imported texture resources from `assets/tokyotower_tp.png`, `assets/skytree_tp.png`, and `assets/burj_khalifa_tp.png`
- `Level01`, `Level02`, and `Level03` keep the backdrop presentation simple without extra sky/glow layers
- The HUD shows enlarged stage info, current time, target time, and a `PAUSE` button during normal play; editor/debug builds also show `DEBUG SKIP` while climb input comes from tapping or clicking the gameplay screen
- Hazard placement keeps a small lower-left safe band clear around the pause control so buttons do not compete visually with flying obstacles
- The title, level select, result, and pause menus use oversized panels plus brighter rounded buttons for mobile-friendly readability, with the pause menu anchored near the bottom-left HUD controls as a compact aligned control block that remains visible as gameplay scrolls upward
- Those menu screens also separate primary action groups from `Back`, `Quit`, or other leave-screen actions with a larger vertical gap
- The pause and result actions favor shorter labels like `Restart` and `Back`
- Button colors now communicate role consistently across the game: primary progression, exit, utility, disabled state, and debug-only development actions
- Menu components are centered inside their panels so narrow mobile screens keep the same centered structure instead of shifting content to one side
- Menus and HUD text/buttons use an adaptive layout that stays readable on portrait phones while fitting more comfortably on desktop and horizontal screens, with menu pages staying intentionally larger than in-game overlays
- The title screen and pause menu include a music icon toggle so players can mute or unmute the looping background music during the current session
- The player is rendered as a back-view climbing ninja-cat using two alternating PNG climb frames while hazards and markers remain simple placeholder shapes
- Flying hazards cross the ladder lane to create readable timing windows
- The goal uses an imported gem texture resource at the top of the climb

## Audio

- Looping background music is loaded from `assets/cat_ninja_tower_music.mp3`.
- The title screen and pause menu include a music icon button that toggles the background music on and off for the current session.
- Web exports inherit the project icon from `assets/ninja_cat_tower_icon.png`, so browser-installed/app-style surfaces use the same cat-and-tower branding as the title screen.
- On web, the background music starts muted so browser audio restrictions do not silently turn it on during the first non-music interaction.
- The web export also includes a small browser-audio hook so the music toggle can suspend or resume the browser `AudioContext` itself.
- The music icon reflects whether the background music is currently audible, so it starts in the off state on web.
- On web, the first tap on the music button turns the muted background music on.
- Sound effect hooks still use placeholder events without attached samples yet.

Current sound hook events:

- `climb`
- `death`
- `clear`

## Notes

- Level unlocks are runtime-only.
- There is no persistent save system.
- Legacy platformer scenes from the previous prototype still exist in the repository but are not used by `Level01`.
- The project is intended to open directly in Godot 4.5 and run from `Main.tscn`.
- For reusable game UI conventions, refer to `project_docs/ui_rules.md`.
- For Godot web-specific implementation tips and browser pitfalls, refer to `project_docs/godot_web_tips.md`.
- For reusable next-project planning and UI/process lessons, refer to `project_docs/new_game_checklist.md`.

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
