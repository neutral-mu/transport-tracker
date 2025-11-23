#!/usr/bin/env bash
# json_to_csv.sh - convert normalized live_raw.json into live.csv
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${ROOT_DIR}/lib.sh"

IN_JSON="${DATA_DIR}/live_raw.json"
OUT_CSV="${DATA_DIR}/live.csv"
TMP_CSV="${OUT_CSV}.tmp"

main() {
  if [[ ! -f "${IN_JSON}" ]]; then
    log_error "Input JSON not found: ${IN_JSON}. Run fetch_live_data.sh first."
    exit 1
  fi

  log_info "Converting ${IN_JSON} -> ${OUT_CSV}"

  {
    # CSV header (matches the data contract)
    echo "timestamp_iso,timestamp_epoch,vehicle_id,trip_id,route_id,stop_id,stop_sequence,lat,lon,speed,status,raw_status,json_blob"

    # Use jq to emit fields as tab-separated, then convert to CSV with a shell loop
    jq -r '
      .vehicles[] |
      [
        .timestamp,
        .timestamp,          # placeholder for epoch
        .id,
        .trip.trip_id,
        .trip.route,
        .stop_id,
        (.stop_sequence // ""),
        (.position.lat // ""),
        (.position.lon // ""),
        (.speed // ""),
        (.status // ""),
        (.status // ""),
        (tojson)
      ] | @tsv
    ' "${IN_JSON}" | \
    while IFS=$'\t' read -r ts_iso ts_epoch_placeholder vehicle_id trip_id route_id stop_id stop_sequence lat lon speed status raw_status json_blob; do
      # Convert ISO time to epoch seconds using helper from lib.sh
      epoch="$(iso_to_epoch "${ts_iso}")"
      [[ -z "${epoch}" ]] && epoch=""

      # Escape quotes in the JSON blob for CSV
      safe_blob=${json_blob//\"/\"\"}

      printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,"%s"\n' \
        "${ts_iso}" \
        "${epoch}" \
        "${vehicle_id}" \
        "${trip_id}" \
        "${route_id}" \
        "${stop_id}" \
        "${stop_sequence}" \
        "${lat}" \
        "${lon}" \
        "${speed}" \
        "${status}" \
        "${raw_status}" \
        "${safe_blob}"
    done
  } > "${TMP_CSV}"

  mv "${TMP_CSV}" "${OUT_CSV}"
  log_info "Wrote normalized live CSV to ${OUT_CSV}"
}

main "$@"
