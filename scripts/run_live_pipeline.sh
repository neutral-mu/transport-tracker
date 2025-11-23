#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/fetch_live_data.sh"
"${SCRIPT_DIR}/json_to_csv.sh"
"${SCRIPT_DIR}/validate_live_data.sh"

"${SCRIPT_DIR}/match_live_to_schedule.sh"
"${SCRIPT_DIR}/compute_delays.sh"
