---
sidebar_position: 4
---

# Test a Heroku Deployment

This guide walks through validating a deployed Tableau MCP server on Heroku, including OAuth and core MCP request flow.

For deployment steps, see [Deploy to Heroku](./deploy-heroku.md).

## Prerequisites

- A deployed Heroku app URL, for example: `https://YOUR-APP-NAME.herokuapp.com`
- OAuth configured for the deployment (`OAUTH_ISSUER`, client credentials, JWE key)
- `curl` installed
- Optional: `jq` for easier JSON parsing

## 1) Set local variables

```bash
HEROKU_URL="https://YOUR-APP-NAME.herokuapp.com"
CLIENT_ID="YOUR_CLIENT_ID"
CLIENT_SECRET="YOUR_CLIENT_SECRET"
```

## 2) Verify basic MCP endpoint reachability

```bash
curl -X POST "${HEROKU_URL}/tableau-mcp" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "ping"
  }'
```

Expected result:

```json
{"jsonrpc":"2.0","id":1,"result":{}}
```

## 3) Verify OAuth discovery endpoints

```bash
curl "${HEROKU_URL}/.well-known/oauth-protected-resource"
curl "${HEROKU_URL}/.well-known/oauth-authorization-server"
```

Expected checks:

- `authorization_servers` includes your Heroku app URL
- `token_endpoint` exists and points to `/oauth2/token`
- `grant_types_supported` includes `client_credentials` when `OAUTH_CLIENT_ID_SECRET_PAIRS` is configured

## 4) Request an OAuth access token (Client Credentials)

```bash
TOKEN_RESPONSE=$(curl -s -X POST "${HEROKU_URL}/oauth2/token" \
  -H "Content-Type: application/json" \
  -d "{
    \"grant_type\": \"client_credentials\",
    \"client_id\": \"${CLIENT_ID}\",
    \"client_secret\": \"${CLIENT_SECRET}\"
  }")

echo "${TOKEN_RESPONSE}"
```

Extract token:

```bash
# With jq
TOKEN=$(echo "${TOKEN_RESPONSE}" | jq -r '.access_token')

# Without jq
# TOKEN=$(echo "${TOKEN_RESPONSE}" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')
```

## 5) Initialize MCP over Streamable HTTP

The Streamable HTTP transport expects clients to accept **both** `application/json` and `text/event-stream`.

```bash
curl -i -X POST "${HEROKU_URL}/tableau-mcp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {
        "name": "curl-test",
        "version": "1.0.0"
      }
    }
  }'
```

Expected checks:

- HTTP status is `200`
- `mcp-session-id` header is present
- response body returns `result.protocolVersion` and `serverInfo`

## 6) Capture session ID

```bash
SESSION_ID=$(curl -i -s -X POST "${HEROKU_URL}/tableau-mcp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {
        "name": "curl-test",
        "version": "1.0.0"
      }
    }
  }' | awk -F': ' 'tolower($1)=="mcp-session-id" {gsub("\r","",$2); print $2}')

echo "SESSION_ID=${SESSION_ID}"
```

## 7) List tools

```bash
curl -X POST "${HEROKU_URL}/tableau-mcp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "mcp-session-id: ${SESSION_ID}" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list"
  }'
```

## 8) Call a tool

```bash
curl -X POST "${HEROKU_URL}/tableau-mcp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "mcp-session-id: ${SESSION_ID}" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "list-datasources",
      "arguments": {}
    }
  }'
```

## Troubleshooting

- `Not Acceptable: Client must accept both application/json and text/event-stream`
  - Add `Accept: application/json, text/event-stream` to MCP requests.
- `401 Unauthorized` or OAuth token errors
  - Re-run token request and ensure `Authorization: Bearer <token>` is set.
  - Verify `OAUTH_CLIENT_ID_SECRET_PAIRS` and token endpoint metadata.
- Missing `mcp-session-id` header
  - Use `curl -i` to include response headers.
  - Ensure request method is `initialize`.
- `Invalid or missing session ID`
  - Send the exact `mcp-session-id` from initialize in subsequent requests.
- Tool call errors related to Tableau auth
  - Verify the server-side Tableau auth configuration (`AUTH`, `SERVER`, `SITE_NAME`, and auth-specific credentials).

## Next references

- [Deploy to Heroku](./deploy-heroku.md)
- [Environment Variables](../configuration/mcp-config/env-vars.md)
- [HTTP Server](../configuration/mcp-config/http-server.md)
- [Enabling OAuth](../configuration/mcp-config/oauth.md)
