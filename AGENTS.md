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

## Output Format

At the end of each task provide:

- Plan
- Files changed
- Validation results
- README.md updates
- Follow-up tasks