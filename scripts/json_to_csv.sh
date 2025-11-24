#!/usr/bin/env bash
# json_to_csv.sh - minimal: JSON -> CSV, one row per vehicle

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# bring in DATA_DIR and logging
source "${ROOT_DIR}/lib.sh"

IN_JSON="${DATA_DIR}/live_raw.json"
OUT_CSV="${DATA_DIR}/live.csv"

main() {
  if [[ ! -f "${IN_JSON}" ]]; then
    echo "ERROR: ${IN_JSON} not found" >&2
    exit 1
  fi

  # CSV header
  echo "timestamp_iso,timestamp_epoch,vehicle_id,trip_id,route_id,stop_id,stop_sequence,lat,lon,speed,status,raw_status,json_blob" > "${OUT_CSV}"

  # One CSV row per vehicle; we don't filter anything
  jq -r '
    .vehicles[] |
    [
      .timestamp,            # timestamp_iso
      "",                    # timestamp_epoch (blank)
      .id,                   # vehicle_id
      .trip.trip_id,         # trip_id
      .trip.route,           # route_id
      .stop_id,              # stop_id
      "",                    # stop_sequence
      (.position.lat // ""), # lat
      (.position.lon // ""), # lon
      (.speed // ""),        # speed
      (.status // ""),       # status
      (.status // ""),       # raw_status
      (tojson)               # json_blob
    ] | @csv
  ' "${IN_JSON}" >> "${OUT_CSV}"
}

main "$@"
