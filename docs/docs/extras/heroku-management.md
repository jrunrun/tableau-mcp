---
sidebar_position: 5
---

# Heroku Management Runbook

Operational reference for teams running Tableau MCP on Heroku.

## Prerequisites

- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)
- Access to the Heroku app
- `curl` for endpoint checks

Set your app name once:

```bash
export HEROKU_APP="YOUR-APP-NAME"
```

## Common Heroku Commands

```bash
# View current config
heroku config --app "${HEROKU_APP}"

# Set or update one value
heroku config:set KEY=value --app "${HEROKU_APP}"

# Remove one value
heroku config:unset KEY --app "${HEROKU_APP}"

# Restart dynos
heroku restart --app "${HEROKU_APP}"

# Stream logs
heroku logs --tail --app "${HEROKU_APP}"
```

## Deploy and release checks

```bash
# View releases
heroku releases --app "${HEROKU_APP}"

# View one release details
heroku releases:info v123 --app "${HEROKU_APP}"

# Roll back to a previous release
heroku rollback v122 --app "${HEROKU_APP}"
```

## Endpoint smoke checks

```bash
APP_URL="https://${HEROKU_APP}.herokuapp.com"

curl -X POST "${APP_URL}/tableau-mcp" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"ping"}'

curl "${APP_URL}/.well-known/oauth-protected-resource"
curl "${APP_URL}/.well-known/oauth-authorization-server"
```

For full MCP and OAuth flow validation, see [Test a Heroku Deployment](./testing-heroku-deployment.md).

## Troubleshooting checklist

- App unreachable or `5xx`:
  - Check dyno status (`heroku ps --app "${HEROKU_APP}"`)
  - Check logs for startup errors (`heroku logs --tail --app "${HEROKU_APP}"`)
- OAuth token issues:
  - Verify `OAUTH_ISSUER` exactly matches deployment origin
  - Verify `OAUTH_CLIENT_ID_SECRET_PAIRS` formatting
  - Verify JWE private key is configured (`OAUTH_JWE_PRIVATE_KEY` or path)
- MCP initialize returns `Not Acceptable`:
  - Ensure `Accept: application/json, text/event-stream` header is set
- Session errors:
  - Capture `mcp-session-id` from initialize response headers and pass it to subsequent requests
- Tableau tool auth failures:
  - Verify `AUTH` mode and required mode-specific credentials
  - Verify `SERVER` and `SITE_NAME`

## Security practices

- Never commit secrets to source control.
- Store credentials only in Heroku config vars.
- Rotate these values regularly:
  - `OAUTH_CLIENT_ID_SECRET_PAIRS`
  - `OAUTH_JWE_PRIVATE_KEY`
  - Tableau auth credentials (`PAT`, `Direct Trust`, or `UAT` secrets)
- Keep `DANGEROUSLY_DISABLE_OAUTH=false` for remote deployments whenever possible.
- Limit `CORS_ORIGIN_CONFIG` in production.

## Change and rotation procedures

### Rotate OAuth client secrets

1. Add a new client ID/secret pair to `OAUTH_CLIENT_ID_SECRET_PAIRS`.
2. Deploy client updates to use the new credentials.
3. Remove the old client ID/secret pair.
4. Restart the app and verify token issuance.

### Rotate JWE private key

1. Generate and store a new private key securely.
2. Update `OAUTH_JWE_PRIVATE_KEY` (or mounted path).
3. Restart app.
4. Re-authenticate test clients and validate tool calls.

## Monitoring guidance

- Use log drains or Heroku add-ons for centralized logging.
- Alert on repeated `401`, `403`, and `5xx` responses.
- Run periodic smoke tests (ping, OAuth metadata, token request, initialize).
- Keep a known-good script in CI or scheduled jobs:
  - `scripts/test-heroku-mcp.sh`

## Related docs

- [Deploy to Heroku](./deploy-heroku.md)
- [Test a Heroku Deployment](./testing-heroku-deployment.md)
- [Environment Variables](../configuration/mcp-config/env-vars.md)
- [HTTP Server](../configuration/mcp-config/http-server.md)
- [Enabling OAuth](../configuration/mcp-config/oauth.md)
