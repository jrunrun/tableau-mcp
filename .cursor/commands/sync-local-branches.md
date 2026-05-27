# Sync Local Branches

You are helping me sync local git branches with the remote so my local branch list reflects what exists on GitHub.

## Goal

Prune stale remote refs, identify local branches whose upstream is gone, and remove them safely after confirmation.

## Steps

1. Confirm current branch and working tree state first:
   - Run `git status -sb`
   - Run `git branch --show-current`
2. Fetch latest refs and prune deleted remote branches:
   - Run `git fetch --prune`
3. Show branches that are out of sync:
   - Run `git branch -vv`
   - Identify branches marked with `[gone]`
4. Present a cleanup plan before deleting anything:
   - List candidate branches with `[gone]`
   - Exclude the currently checked out branch automatically
5. Ask for confirmation:
   - **Safe mode (default):** use `git branch -d <branch>` for each candidate
   - **Force mode (only if I request it):** use `git branch -D <branch>`
6. After cleanup, verify results:
   - Run `git branch -a`
   - Summarize what was deleted and what was kept
7. If no `[gone]` branches are found, state that everything is already in sync.

## Output

- Quick status of branch sync health
- Commands executed
- Branches deleted (or none)
- Suggested next step (for example, run this weekly)

## Important Rules

- Be concise
- Default to safe deletion (`-d`)
- Do not force delete without explicit confirmation
- Do not delete the current branch
- Ask if unsure
