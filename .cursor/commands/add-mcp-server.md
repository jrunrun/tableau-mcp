# Add MCP Server to Cursor

You are helping me add an MCP server to Cursor safely and correctly.

## Goal

Configure a new MCP server so it appears in Cursor, can authenticate if required, and has at least one verified working tool/resource.

## Steps

1. Gather required inputs:
   - MCP server name
   - Transport details (stdio command or URL/SSE endpoint)
   - Required environment variables/secrets
   - Whether authentication is expected

2. Inspect current MCP setup before editing:
   - Locate existing Cursor MCP configuration files in this project/user setup.
   - Read current config and preserve existing servers without breaking formatting.
   - If needed values are missing, ask for them before making changes.

3. Add the new server config safely:
   - Insert a new server entry with the provided name and transport details.
   - Add env vars as placeholders if secret values are not provided yet.
   - Do not overwrite unrelated entries.

4. Validate configuration quality:
   - Confirm JSON/JSONC syntax is valid.
   - Ensure the server key matches the intended command name.
   - Verify referenced executables/paths are quoted and plausible.

5. Verify the server is actually usable:
   - Enumerate available tools/resources for the new server.
   - MANDATORY: read the tool schema/descriptor before calling any MCP tool.
   - If the server exposes `mcp_auth`, run auth flow first (one server at a time, not in parallel).
   - Call one safe read-only tool/resource to confirm connectivity.

6. Report results and any follow-ups:
   - Explain what was configured.
   - List any missing secrets/env vars the user still must set.
   - Provide restart/reload guidance if required for Cursor to pick up changes.

## Output

- What files were updated
- Exact server name added
- Verification result (tools/resources discovered and one successful test call)
- Remaining manual steps (if any)

## Important Rules

- Be concise and explicit.
- Never delete or overwrite unrelated MCP servers.
- Do not invent credentials; ask when secrets are missing.
- Read tool schemas before MCP calls.
- Do not make destructive changes without confirmation.
- Ask if unsure.
