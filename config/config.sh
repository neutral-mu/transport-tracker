#!/bin/bash
# config/config.sh

# Dynamic Project Root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Paths
export DATA_DIR="$PROJECT_ROOT/data"
export LOG_DIR="$PROJECT_ROOT/logs"
export REPORT_DIR="$PROJECT_ROOT/output/reports"
export SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Settings
export DELAY_THRESHOLD=15
export ADMIN_EMAIL="your_email@example.com"
export LIVE_FEED_URL="http://fake-api.local/feed"

# Data Contracts
export FILE_LIVE_RAW="live_raw.json"
export FILE_LIVE_CSV="live.csv"
export FILE_TIMETABLE="timetable.csv"
export FILE_DELAYS="delays.csv"