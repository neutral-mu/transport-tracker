#!/usr/bin/env bash
# lib.sh - shared utilities (logging, timestamps, locking)
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.sh"

_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log() {
  local level="$1"
  shift
  local msg="$*"
  local ts=$(_timestamp)
  echo "${ts} [${level}] ${msg}" >>"${LOG_DIR}/$(date -u +%Y-%m-%d).log"
  [[ "${LOG_LEVEL}" == "DEBUG" ]] && echo "${ts} [${level}] ${msg}"
}

log_debug() { log "DEBUG" "$*"; }
log_info() { log "INFO" "$*"; }
log_warn() { log "WARN" "$*"; }
log_error() { log "ERROR" "$*"; }

# Simple lock (mkdir is atomic)
acquire_lock() {
  local name="$1"
  mkdir -p "${LOCK_DIR}"
  while ! mkdir "${LOCK_DIR}/${name}.lck" 2>/dev/null; do
    sleep 0.2
  done
  echo $$ >"${LOCK_DIR}/${name}.lck/pid"
}

release_lock() {
  local name="$1"
  rm -rf "${LOCK_DIR}/${name}.lck"
}

safe_run() {
  local cmd=("$@")
  log_info "Running: ${cmd[*]}"
  "${cmd[@]}" || {
    log_error "FAILED: ${cmd[*]}"
    return 1
  }
}

iso_to_epoch() { date -u -d "$1" +%s 2>/dev/null || echo ""; }
epoch_to_iso() { date -u -d "@$1" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo ""; }
