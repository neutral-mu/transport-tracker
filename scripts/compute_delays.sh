#!/usr/bin/env bash
# compute_delays.sh - Calculate final delay status and flags and output it to data/delays.csv

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${ROOT_DIR}/lib.sh"

MATCHED_CSV="${DATA_DIR}/matched.csv"
DELAYS_CSV="${DATA_DIR}/delays.csv"

main() {
  log_info "Computing delays and flags..."

  if [[ ! -f "${MATCHED_CSV}" ]]; then
    log_error "matched.csv not found. Run match_live_to_schedule.sh first."
    exit 1
  fi

  echo "trip_id,route_id,stop_id,scheduled_time_iso,actual_time_iso,delay_min,alert_flag,alert_level,notes" > "${DELAYS_CSV}"

  awk -F',' -v OFS=',' \
      -v T_WARN="${THRESHOLD_DELAY_WARN:-5}" \
      -v T_ALERT="${THRESHOLD_DELAY_ALERT:-15}" \
      '
    NR == 1 { next } # Skip header

    {
      trip_id = $2
      stop_id = $6
      sched_iso = $7
      act_iso = $9
      delay = $11 + 0
      notes = $14

      # Default values
      route_id = "UNK"
      alert_flag = "false"
      alert_level = "NORMAL"

      # Threshold Logic
      if (delay >= T_ALERT) {
        alert_flag = "true"
        alert_level = "CRITICAL"
      } else if (delay >= T_WARN) {
        alert_flag = "true"
        alert_level = "WARNING"
      }

      print trip_id, route_id, stop_id, sched_iso, act_iso, delay, alert_flag, alert_level, notes
    }
  ' "${MATCHED_CSV}" >> "${DELAYS_CSV}"

  log_info "Delay computation finished. Output -> ${DELAYS_CSV}"
}

main "$@"
