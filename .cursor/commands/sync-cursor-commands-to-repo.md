# Sync Cursor Commands To Repo

You are helping me sync this project's Cursor commands back into my canonical commands repository.

## Goal

Run the centralized push sync script so shared command markdown files from this project are copied into the canonical repository.

## Steps

1. Resolve canonical root:
   - Use `$CURSOR_COMMANDS_HOME` if set
   - Otherwise use `/Users/jcraycraft/Documents/Projects/cursor-commands`
2. Build paths:
   - Script path: `<canonical-root>/scripts/sync-cursor-commands-to-repo.sh`
   - Source path: `<current-project>/.cursor/commands`
3. Validate script exists and is executable. If not, stop and report the missing path.
4. Run dry-run first:
   - `"<script-path>" --dry-run "<source-path>"`
5. Show dry-run results and ask for confirmation before copying.
6. If I confirm, run apply mode:
   - `"<script-path>" --apply "<source-path>"`
7. Report:
   - resolved source/destination
   - files copied/skipped
   - confirmation that `sync-cursor-commands-from-repo.md` and `sync-cursor-commands-to-repo.md` were not overwritten

## Output

- Sync status summary
- Commands executed
- Files copied/skipped
- Any follow-up action needed

## Important Rules

- Be concise
- Always run dry-run before apply
- Never overwrite `sync-cursor-commands-from-repo.md` or `sync-cursor-commands-to-repo.md`
- Sync only markdown command source files
- Ask if unsure
