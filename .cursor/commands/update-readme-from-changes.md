# update-readme-from-changes

You are helping me update `README.md` with the most useful, accurate information from the current code changes.

## Goal

Produce a clear README update that reflects what changed in the working tree (staged + unstaged), especially details that help future contributors and maintainers understand new behavior, structure, setup, and content workflows.

---

## Steps

1. Inspect current repository changes first:
   - Run `git status --short`
   - Run `git diff --stat`
   - Run `git diff --name-only`
   - Run `git diff` for relevant files
   - Also include staged changes with `git diff --cached --name-only` and `git diff --cached`

2. Determine what README sections need updates:
   - Features
   - Project structure
   - Setup / scripts / dependencies
   - Content management or editorial workflow
   - Any new directories, assets, or conventions

3. Edit `README.md` directly:
   - Keep existing structure when possible
   - Add or revise only high-signal information
   - Prefer concrete facts from code diffs over assumptions
   - Use concise bullets and short sections

4. Validate accuracy:
   - Confirm each README claim can be traced to current files or diff
   - Remove stale statements that are now misleading
   - Do not invent usage instructions for code that does not exist

5. Safety checks:
   - Do not modify source files unless explicitly asked; focus on `README.md`
   - If changes are ambiguous, ask one clarifying question before writing

## Output

- What was updated in `README.md` and why
- Which changed files informed those documentation updates
- Any open documentation gaps that still need product/owner input

## Important Rules

- Be concise and practical
- Prioritize contributor usefulness over marketing language
- Do not make destructive changes without confirmation
- Ask if unsure

This command will be available in chat with /update-readme-from-changes
