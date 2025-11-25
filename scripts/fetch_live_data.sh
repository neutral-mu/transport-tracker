#!/usr/bin/env bash
# fetch_live_data.sh - fetch TfL arrivals and normalize to vehicles JSON

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${ROOT_DIR}/lib.sh"

OUT_JSON="${DATA_DIR}/live_raw.json"
TMP_JSON="${OUT_JSON}.tmp"

main() {
  log_info "Fetching live data from TfL: ${API_URL}"

  # --- 1) Fetch raw Arrivals array from TfL ---
  if ! curl -fsS --max-time "${API_TIMEOUT}" "${API_URL}" -o "${TMP_JSON}"; then
    log_error "curl to TfL failed"
    rm -f "${TMP_JSON}" || true
    exit 1
  fi

  # --- 2) Normalize to our canonical { vehicles: [ ... ] } structure ---
  # TfL Arrivals is an array; we map each element to our fields.
  if ! jq '
    {
      vehicles: [
        .[] | {
          id:          ( .vehicleId // .vehicleId // .id // "unknown" ),
          trip: {
            trip_id:   ( .vehicleId // .id // "unknown" ),
            route:     ( .lineId // .lineName // "unknown" )
          },
          timestamp:   ( .timestamp // .timeToLive // now | tostring ),
          position: {
            lat:      ( .lat // null ),
            lon:      ( .lon // null )
          },
          stop_id:     ( .naptanId // .stationId // "unknown" ),
          status:      ( .currentLocation // .platformName // .towards // "Unknown" ),
          speed:       null
        }
      ]
    }
  ' "${TMP_JSON}" > "${OUT_JSON}"; then
    log_error "jq normalization failed"
    rm -f "${TMP_JSON}" || true
    exit 1
  fi

  rm -f "${TMP_JSON}" || true
  log_info "Saved normalized JSON -> ${OUT_JSON}"
  exit 0
}

main "$@"
