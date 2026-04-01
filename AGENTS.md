# AGENTS.md

This repository is developed with an AI coding agent (Codex / CodeX).

## Source of Truth
- The project specification lives in `README.md`.
- If implementation changes behavior, update `README.md`.

## Working Process

For every task:

1. Read the relevant code and `README.md`.
2. Summarize the current behavior briefly.
3. Make a short implementation plan.
4. Implement the change.
5. Run validation.
6. Fix issues if validation fails.
7. Update `README.md` if the behavior/spec changed.
8. Provide a summary of changes.

## Validation

After every code change run:

- build
- tests (if available)
- lint / static checks

Never report success without validation results.

## Documentation Update

If any of these change, update `README.md`:

- gameplay logic
- UI behavior
- configuration
- APIs
- data structures

The documentation must match the final implementation.

## UI Consistency

When changing menus or HUD buttons, keep the current UI language consistent:

- Prefer short labels such as `Next`, `Restart`, and `Back`.
- Use larger spacing between primary action groups and exit-style actions such as `Back` or `Quit`.
- Keep menu panels and their inner components centered on screen, and preserve that centered structure on narrow mobile screens instead of letting content drift to one side.
- Keep the `How To Play` screen short and visual. Describe the game in one short line, then explain how to play it, and finally add an illustration of the controls. Focus only on the core game loop, and keep the layout centered and easy to scan on mobile.
- Assign every button exactly one base role. Button color should follow that base role across every page:
  - Primary: forward progression actions such as `Start`, `Next`, and playable level buttons
  - Exit: go-back or end-flow actions such as `Back` and `Quit`
  - Utility: non-forward supporting actions such as `How To Play`, `Restart`, `PAUSE`, and `RESUME`
  - Debug: testing-only actions such as `DEBUG SKIP`
- Treat `Disabled` as a state, not a base role. It should override the base-role color with the unavailable/disabled style whenever that action cannot be used.

## Output Format

At the end of each task provide:

- Plan
- Files changed
- Validation results
- README.md updates
- Follow-up tasks
