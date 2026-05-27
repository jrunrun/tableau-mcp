#!/usr/bin/env bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

HEROKU_URL="${HEROKU_URL:-}"
OAUTH_CLIENT_ID="${OAUTH_CLIENT_ID:-}"
OAUTH_CLIENT_SECRET="${OAUTH_CLIENT_SECRET:-}"
TOOL_NAME="${TOOL_NAME:-list-datasources}"
TOOL_ARGS_JSON="${TOOL_ARGS_JSON:-{}}"
RUN_TOOL_CALL="${RUN_TOOL_CALL:-true}"

TOKEN=""
SESSION_ID=""

log_info() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}

log_pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  exit 1
}

require_env() {
  local name="$1"
  local value="$2"
  if [[ -z "${value}" ]]; then
    log_fail "Missing required environment variable: ${name}"
  fi
}

require_tool() {
  local name="$1"
  if ! command -v "${name}" >/dev/null 2>&1; then
    log_fail "Required tool not found: ${name}"
  fi
}

extract_json_field() {
  local json="$1"
  local field="$2"
  if command -v jq >/dev/null 2>&1; then
    echo "${json}" | jq -r ".${field} // empty"
    return 0
  fi

  echo "${json}" | sed -n "s/.*\"${field}\":\"\([^\"]*\)\".*/\1/p"
}

post_json() {
  local url="$1"
  local body="$2"
  local auth_header="${3:-}"
  local session_header="${4:-}"
  local headers_file
  local body_file
  headers_file="$(mktemp)"
  body_file="$(mktemp)"

  local curl_args=(
    -sS
    -D "${headers_file}"
    -o "${body_file}"
    -X POST "${url}"
    -H "Content-Type: application/json"
    -H "Accept: application/json, text/event-stream"
    -d "${body}"
  )

  if [[ -n "${auth_header}" ]]; then
    curl_args+=(-H "Authorization: Bearer ${auth_header}")
  fi
  if [[ -n "${session_header}" ]]; then
    curl_args+=(-H "mcp-session-id: ${session_header}")
  fi

  local http_code
  http_code="$(curl "${curl_args[@]}" -w '%{http_code}')"
  local response
  response="$(cat "${body_file}")"
  local headers
  headers="$(cat "${headers_file}")"

  rm -f "${headers_file}" "${body_file}"

  echo "${http_code}"$'\n'"${headers}"$'\n'"${response}"
}

test_ping() {
  log_info "Testing ping endpoint"
  local body='{"jsonrpc":"2.0","id":1,"method":"ping"}'
  local result
  result="$(post_json "${HEROKU_URL}/tableau-mcp" "${body}")"
  local http_code
  http_code="$(echo "${result}" | awk 'NR==1 {print $1}')"
  local response
  response="$(echo "${result}" | awk 'NR>1 {print}' | awk 'BEGIN{body=0} /^$/ {body=1; next} {if(body) print}')"

  [[ "${http_code}" == "200" ]] || log_fail "Ping failed with HTTP ${http_code}: ${response}"
  log_pass "Ping endpoint returned HTTP 200"
}

test_oauth_discovery() {
  log_info "Testing OAuth discovery endpoints"
  local protected_resource
  protected_resource="$(curl -sS "${HEROKU_URL}/.well-known/oauth-protected-resource")"
  local auth_server
  auth_server="$(curl -sS "${HEROKU_URL}/.well-known/oauth-authorization-server")"

  local token_endpoint
  token_endpoint="$(extract_json_field "${auth_server}" "token_endpoint")"
  [[ -n "${token_endpoint}" ]] || log_fail "Authorization metadata missing token_endpoint"

  local issuer
  issuer="$(extract_json_field "${auth_server}" "issuer")"
  [[ -n "${issuer}" ]] || log_fail "Authorization metadata missing issuer"

  if [[ "${protected_resource}" != *"authorization_servers"* ]]; then
    log_fail "Protected resource metadata missing authorization_servers"
  fi

  log_pass "OAuth discovery endpoints responded as expected"
}

test_get_token() {
  log_info "Requesting OAuth token via client credentials"
  local token_response
  token_response="$(curl -sS -X POST "${HEROKU_URL}/oauth2/token" \
    -H "Content-Type: application/json" \
    -d "{
      \"grant_type\": \"client_credentials\",
      \"client_id\": \"${OAUTH_CLIENT_ID}\",
      \"client_secret\": \"${OAUTH_CLIENT_SECRET}\"
    }")"

  local access_token
  access_token="$(extract_json_field "${token_response}" "access_token")"
  [[ -n "${access_token}" ]] || log_fail "Token response missing access_token: ${token_response}"

  TOKEN="${access_token}"
  log_pass "OAuth token acquired"
}

test_initialize() {
  log_info "Initializing MCP session"
  local body='{
    "jsonrpc":"2.0",
    "id":1,
    "method":"initialize",
    "params":{
      "protocolVersion":"2024-11-05",
      "capabilities":{},
      "clientInfo":{"name":"heroku-smoke-test","version":"1.0.0"}
    }
  }'
  local result
  result="$(post_json "${HEROKU_URL}/tableau-mcp" "${body}" "${TOKEN}")"
  local http_code
  http_code="$(echo "${result}" | awk 'NR==1 {print $1}')"
  local headers
  headers="$(echo "${result}" | awk 'NR>1 {print}' | awk 'BEGIN{body=0} {if(body==0) print} /^$/ {exit}')"
  local response
  response="$(echo "${result}" | awk 'NR>1 {print}' | awk 'BEGIN{body=0} /^$/ {body=1; next} {if(body) print}')"

  [[ "${http_code}" == "200" ]] || log_fail "Initialize failed with HTTP ${http_code}: ${response}"

  SESSION_ID="$(echo "${headers}" | awk -F': ' 'tolower($1)=="mcp-session-id" {gsub("\r","",$2); print $2}')"
  [[ -n "${SESSION_ID}" ]] || log_fail "Initialize response missing mcp-session-id header"

  log_pass "Initialize succeeded and session id captured"
}

test_list_tools() {
  log_info "Listing MCP tools"
  local body='{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
  local result
  result="$(post_json "${HEROKU_URL}/tableau-mcp" "${body}" "${TOKEN}" "${SESSION_ID}")"
  local http_code
  http_code="$(echo "${result}" | awk 'NR==1 {print $1}')"
  local response
  response="$(echo "${result}" | awk 'NR>1 {print}' | awk 'BEGIN{body=0} /^$/ {body=1; next} {if(body) print}')"

  [[ "${http_code}" == "200" ]] || log_fail "tools/list failed with HTTP ${http_code}: ${response}"
  if [[ "${response}" != *"tools"* ]]; then
    log_fail "tools/list response did not include tools data: ${response}"
  fi

  log_pass "tools/list succeeded"
}

test_call_tool() {
  log_info "Calling sample tool: ${TOOL_NAME}"
  local body
  body="$(cat <<EOF
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"${TOOL_NAME}","arguments":${TOOL_ARGS_JSON}}}
EOF
)"
  local result
  result="$(post_json "${HEROKU_URL}/tableau-mcp" "${body}" "${TOKEN}" "${SESSION_ID}")"
  local http_code
  http_code="$(echo "${result}" | awk 'NR==1 {print $1}')"
  local response
  response="$(echo "${result}" | awk 'NR>1 {print}' | awk 'BEGIN{body=0} /^$/ {body=1; next} {if(body) print}')"

  [[ "${http_code}" == "200" ]] || log_fail "tools/call failed with HTTP ${http_code}: ${response}"
  if [[ "${response}" != *"result"* ]]; then
    log_fail "tools/call response missing result payload: ${response}"
  fi

  log_pass "tools/call succeeded (${TOOL_NAME})"
}

usage() {
  cat <<'EOF'
Usage:
  HEROKU_URL="https://your-app.herokuapp.com" \
  OAUTH_CLIENT_ID="client-id" \
  OAUTH_CLIENT_SECRET="client-secret" \
  ./scripts/test-heroku-mcp.sh

Optional variables:
  RUN_TOOL_CALL=true|false    # default true
  TOOL_NAME=list-datasources  # default list-datasources
  TOOL_ARGS_JSON={}            # JSON object passed as tool arguments
EOF
}

main() {
  require_tool curl
  require_env HEROKU_URL "${HEROKU_URL}"
  require_env OAUTH_CLIENT_ID "${OAUTH_CLIENT_ID}"
  require_env OAUTH_CLIENT_SECRET "${OAUTH_CLIENT_SECRET}"

  test_ping
  test_oauth_discovery
  test_get_token
  test_initialize
  test_list_tools

  if [[ "${RUN_TOOL_CALL}" == "true" ]]; then
    test_call_tool
  else
    log_info "Skipping tools/call test because RUN_TOOL_CALL=${RUN_TOOL_CALL}"
  fi

  log_pass "All Heroku MCP checks passed"
  echo "SESSION_ID=${SESSION_ID}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

main
