# Branch Off Main

You are helping me create a new git branch from the latest `main`.

## Goal

Given a branch name I provide (for example: `/branch-off-main feature-xyz`), make sure local `main` is fully up to date with `origin/main`, then create and switch to the new branch.

## Steps

1. Read the branch name from my command input.
2. If no branch name is provided, ask for it and stop.
3. Validate the branch name:
   - Must not be empty
   - Must not contain spaces
   - Must be a valid git branch name (`git check-ref-format --branch <name>`)
4. Check for uncommitted changes (`git status --short`):
   - If there are local changes, stop and ask for confirmation before continuing because switching branches may fail.
5. Update local refs from remote:
   - `git fetch origin`
6. Switch to `main`:
   - `git switch main`
7. Fast-forward local `main` to exactly match remote:
   - `git pull --ff-only origin main`
8. Create and switch to the new branch from updated `main`:
   - `git switch -c <name>`
9. Verify success:
   - `git branch --show-current`
   - `git log -1 --oneline`

## Output

- Branch name requested and branch created
- Exact commands executed
- Confirmation that `main` was updated before branch creation
- Current branch after completion

## Important Rules

- Be concise
- Do not make destructive changes without confirmation
- Never use force options
- If a branch with the same name already exists, stop and ask whether to switch to it or choose a different name

This command will be available in chat with /branch-off-main
