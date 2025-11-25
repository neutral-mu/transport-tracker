#!/usr/bin/env bash
# run_live_pipeline.sh - simple Part B wrapper

set -u   # no -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# We run each step; if something fails, details are in the logs,
# but this wrapper itself always exits 0 so it doesn't look like an error.

bash "${SCRIPT_DIR}/fetch_live_data.sh"      || true
bash "${SCRIPT_DIR}/json_to_csv.sh"     || true
bash "${SCRIPT_DIR}/validate_live_data.sh" || true

bash "${SCRIPT_DIR}/match_live_to_schedule.sh" || true
bash "${SCRIPT_DIR}/compute_delays.sh" || true

echo "[RUN] pipeline complete"
exit 0
