---
sidebar_position: 3
---

# Deploy to Heroku

This project now includes experimental support for Heroku.

Use the Deploy to Heroku button to start the app creation flow to create a Tableau MCP instance:

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://www.heroku.com/deploy?template=https://github.com/tableau/tableau-mcp)

As part of the deployment process, Heroku will prompt for the
[key configuration values](../configuration/mcp-config/env-vars.md#server):

- SERVER
- SITE_NAME
- PAT_NAME
- PAT_VALUE

## Authentication and OAuth choices

When deploying with `TRANSPORT=http`, the server expects OAuth protection by default.

### Recommended: OAuth-protected MCP server

Set OAuth variables such as:

- `OAUTH_ISSUER` (your Heroku origin)
- `OAUTH_CLIENT_ID_SECRET_PAIRS`
- `OAUTH_JWE_PRIVATE_KEY` or `OAUTH_JWE_PRIVATE_KEY_PATH`

Then choose how the MCP server authenticates to Tableau (`AUTH=oauth`, `AUTH=direct-trust`, `AUTH=pat`, or `AUTH=uat`).

### Opt out (not recommended): disable OAuth protection

You can disable HTTP OAuth protection by setting:

- `DANGEROUSLY_DISABLE_OAUTH=true`

Only use this for controlled test/dev scenarios. Disabling OAuth removes a key protection layer for your remote MCP server.

For information on how the deployment works, see the
[Creating a 'Deploy to Heroku' Button](https://devcenter.heroku.com/articles/heroku-button)
documentation.

## Configure AI Tools with Heroku

Because the Heroku deployment is already configured with your server, site and authentication
settings, configuring in AI tools only needs to point to the instance:

```json
{
  "mcpServers": {
    "tableau": {
      "transport": "http",
      "url": "https://YOUR-APP-NAME.herokuapp.com/tableau-mcp"
    }
  }
}
```

The project includes a template file `config.http.json` which you can use as an example.

For OAuth client-credentials style MCP clients, see `config.http.oauth.json`.

## Team artifacts for repeatable operations

- End-to-end validation guide: [Test a Heroku Deployment](./testing-heroku-deployment.md)
- Operational runbook: [Heroku Management Runbook](./heroku-management.md)
- Environment template: `env.heroku.example`
- Validation script: `scripts/test-heroku-mcp.sh`

## Security best practices

- Keep `DANGEROUSLY_DISABLE_OAUTH=false` whenever possible.
- Avoid committing secrets (client secrets, private keys, PAT values).
- Use Heroku config vars for all credentials.
- Rotate OAuth and Tableau credentials regularly.

:::warning

Deploying Tableau MCP to Heroku should be considered experimental at this point. Treat your Heroku
instance URL carefully and don't share it. This is meant only for test and development at this time.

:::
