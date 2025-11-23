#!/usr/bin/env bash
# config.sh - project-level configuration (paths, API URL, thresholds)
set -euo pipefail

# Base paths (override with env vars if needed)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${DATA_DIR:-${BASE_DIR}/data}"
SCRIPTS_DIR="${SCRIPTS_DIR:-${BASE_DIR}/scripts}"
OUTPUT_DIR="${OUTPUT_DIR:-${BASE_DIR}/output}"
LOG_DIR="${LOG_DIR:-${BASE_DIR}/logs}"
TEST_DIR="${TEST_DIR:-${BASE_DIR}/tests}"
LOCK_DIR="${LOCK_DIR:-/var/lock/pt_delay_tracker}"

# API settings (used by live data ingestion)
API_URL="${API_URL:-https://api.example.com/v1/vehicle_positions}"
API_KEY="${API_KEY:-REPLACE_WITH_KEY}"
API_RETRIES="${API_RETRIES:-3}"
API_TIMEOUT="${API_TIMEOUT:-10}"

# Time formats
TIMEZONE="${TIMEZONE:-UTC}"
ISO_FORMAT="%Y-%m-%dT%H:%M:%SZ"

# Delay thresholds (minutes)
THRESHOLD_DELAY_WARN="${THRESHOLD_DELAY_WARN:-5}"
THRESHOLD_DELAY_ALERT="${THRESHOLD_DELAY_ALERT:-15}"

# Matching parameters
MATCH_TIME_WINDOW_SEC="${MATCH_TIME_WINDOW_SEC:-300}"
MATCH_SCORE_MIN="${MATCH_SCORE_MIN:-0.5}"

# Alerts
ALERTS_FILE="${OUTPUT_DIR}/alerts_sent.csv"

# Logging
LOG_LEVEL="${LOG_LEVEL:-INFO}" # DEBUG, INFO, WARN, ERROR

# Export commonly used variables
export BASE_DIR DATA_DIR SCRIPTS_DIR OUTPUT_DIR LOG_DIR TEST_DIR LOCK_DIR
export API_URL API_KEY API_RETRIES API_TIMEOUT
export TIMEZONE ISO_FORMAT
export THRESHOLD_DELAY_WARN THRESHOLD_DELAY_ALERT MATCH_TIME_WINDOW_SEC MATCH_SCORE_MIN
export ALERTS_FILE LOG_LEVEL

# Ensure directories exist
mkdir -p "${DATA_DIR}" "${SCRIPTS_DIR}" "${OUTPUT_DIR}" "${LOG_DIR}" "${TEST_DIR}" || true
