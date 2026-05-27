# create-cursor-command

# Create a New Cursor Command

You are helping me create a reusable Cursor command and save it to `.cursor/commands/`.

## Goal

Take a natural language description of a command I want, then:
1. Design a high-quality command prompt
2. Format it correctly
3. Save it as a new `.md` file in `.cursor/commands/`

---

## Steps

1. Ask clarifying questions if needed:
   - What should the command do?
   - What inputs (if any)?
   - Should it run shell commands or just guide reasoning?
   - Desired level of safety (safe vs forceful)

2. Propose:
   - Command name (kebab-case)
   - File name: `.cursor/commands/<command-name>.md`

3. Generate the command using this structure:

   ```md
   # <Command Title>

   You are helping me <clear purpose>.

   ## Goal

   <What success looks like>

   ## Steps

   1. <Step-by-step instructions>
   2. <Be explicit about commands, analysis, etc.>

   ## Output

   - Clear summary
   - Any commands executed
   - Next steps (if applicable)

   ## Important Rules

   - Be concise
   - Do not make destructive changes without confirmation
   - Ask if unsure

This command will be available in chat with /create-cursor-command
