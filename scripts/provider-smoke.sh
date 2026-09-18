#!/usr/bin/env bash
set -euo pipefail

# Contract: with --live, issue exactly one bounded request to each configured
# provider, using temporary config/output files and no retries.

SCRIPT_NAME="$(basename "$0")"
cli_command="oc"
live=false
providers="both"
timeout_seconds=90
work_dir=""

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME --live [options]

Run one short, non-interactive Open Circuit request against OpenAI and
Anthropic. This is an explicit live-provider check and requires both keys.

Options:
  --live             Enable the two live provider requests (required)
  --provider NAME    Check openai, anthropic, or both (default: both)
  --cli PATH         CLI executable or PATH command (default: oc)
  --timeout SECONDS  Per-provider timeout (default: 90)
  --work-dir DIR     Temporary work directory parent (default: system temp)
  -h, --help         Show this help

Required environment variables when --live is used:
  OPENAI_API_KEY and ANTHROPIC_API_KEY

The script never prints provider responses, API keys, or error bodies.
EOF
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '[open-circuit-provider-smoke] %s\n' "$*"
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --live) live=true; shift ;;
      --provider)
        (($# >= 2)) || fail "--provider requires a value"
        providers="$2"
        shift 2
        ;;
      --cli)
        (($# >= 2)) || fail "--cli requires a value"
        cli_command="$2"
        shift 2
        ;;
      --timeout)
        (($# >= 2)) || fail "--timeout requires a value"
        timeout_seconds="$2"
        shift 2
        ;;
      --work-dir)
        (($# >= 2)) || fail "--work-dir requires a value"
        work_dir="$2"
        shift 2
        ;;
      -h|--help) usage; exit 0 ;;
      *) fail "Unknown option: $1" ;;
    esac
  done
}

validate_environment() {
  [[ "$live" == true ]] || fail "--live is required; refusing to contact providers"
  [[ "$providers" == "openai" || "$providers" == "anthropic" || "$providers" == "both" ]] ||
    fail "--provider must be openai, anthropic, or both"
  [[ "$timeout_seconds" =~ ^[1-9][0-9]*$ ]] || fail "--timeout must be a positive integer"
  [[ -n "${OPENAI_API_KEY:-}" ]] || fail "OPENAI_API_KEY is not set"
  [[ -n "${ANTHROPIC_API_KEY:-}" ]] || fail "ANTHROPIC_API_KEY is not set"
  command -v timeout >/dev/null 2>&1 || fail "timeout is required"

  if [[ "$cli_command" == */* ]]; then
    [[ -x "$cli_command" ]] || fail "CLI is not executable: $cli_command"
    cli_command="$(cd "$(dirname "$cli_command")" && pwd)/$(basename "$cli_command")"
  else
    cli_command="$(command -v "$cli_command" || true)"
    [[ -n "$cli_command" ]] || fail "CLI command not found"
  fi

  if [[ -n "$work_dir" ]]; then
    [[ -d "$work_dir" ]] || fail "work directory does not exist: $work_dir"
    [[ -w "$work_dir" ]] || fail "work directory is not writable: $work_dir"
  fi
}

write_configs() {
  local target_dir="$1"
  cat > "$target_dir/openai.yaml" <<'OPENAI_CONFIG'
name: Open Circuit OpenAI smoke
version: 1.0.0
schema: v1
models:
  - name: OpenAI smoke model
    provider: openai
    model: gpt-4o-mini
    apiKey: ${{ secrets.OPENAI_API_KEY }}
    defaultCompletionOptions:
      maxTokens: 16
    roles:
      - chat
OPENAI_CONFIG

  cat > "$target_dir/anthropic.yaml" <<'ANTHROPIC_CONFIG'
name: Open Circuit Anthropic smoke
version: 1.0.0
schema: v1
models:
  - name: Anthropic smoke model
    provider: anthropic
    model: claude-sonnet-4-6
    apiKey: ${{ secrets.ANTHROPIC_API_KEY }}
    defaultCompletionOptions:
      maxTokens: 16
    roles:
      - chat
ANTHROPIC_CONFIG
}

run_provider() {
  local provider="$1"
  local config="$2"
  local expected="$3"
  local output="$4"
  local prompt="Reply with exactly $expected"
  local status=0

  if timeout "$timeout_seconds" "$cli_command" --config "$config" -p "$prompt" >"$output" 2>&1; then
    status=0
  else
    status=$?
  fi

  if ((status != 0)); then
    log "$provider request failed (exit $status; response suppressed)"
    return 1
  fi
  if ! grep -Fq "$expected" "$output"; then
    log "$provider request completed without the expected sentinel"
    return 1
  fi
  log "$provider request passed (one call; response suppressed)"
}

main() {
  parse_args "$@"
  validate_environment

  local temp_root
  umask 077
  if [[ -n "$work_dir" ]]; then
    temp_root="$(mktemp -d "$work_dir/open-circuit-provider-smoke.XXXXXXXX")"
  else
    temp_root="$(mktemp -d "${TMPDIR:-/tmp}/open-circuit-provider-smoke.XXXXXXXX")"
  fi
  trap 'if [[ -n "${temp_root:-}" ]]; then rm -rf -- "$temp_root"; fi' EXIT
  write_configs "$temp_root"

  local failures=0
  if [[ "$providers" == "openai" || "$providers" == "both" ]]; then
    run_provider "OpenAI" "$temp_root/openai.yaml" "OPEN_CIRCUIT_OPENAI_OK" "$temp_root/openai.out" || failures=$((failures + 1))
  fi
  if [[ "$providers" == "anthropic" || "$providers" == "both" ]]; then
    run_provider "Anthropic" "$temp_root/anthropic.yaml" "OPEN_CIRCUIT_ANTHROPIC_OK" "$temp_root/anthropic.out" || failures=$((failures + 1))
  fi

  ((failures == 0)) || fail "$failures provider smoke check(s) failed"
  log "completed: selected provider request(s), no retries"
}

main "$@"
