#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${ROOT_DIR}/lib.sh"

OUT_JSON="${DATA_DIR}/live_raw.json"
TMP_RAW="${DATA_DIR}/live_raw_tfl.tmp"
TMP_NORM="${DATA_DIR}/live_raw_normalized.tmp"

fetch_once() {
  log_info "Fetching live data from TfL: ${API_URL}"
  curl -sS --max-time "${API_TIMEOUT}" \
    "${API_URL}?${API_KEY}" \
    -o "${TMP_RAW}"
}

normalize_tfl_to_project() {
  jq '{
    vehicles: [
      .[] |
      {
        id: (.vehicleId // "unknown_vehicle"),
        trip: {
          trip_id: (.id // "trip_unknown"),
          route: (.lineId // "route_unknown")
        },
        timestamp: (.timestamp // .expectedArrival),
        position: {
          lat: (.latitude // null),
          lon: (.longitude // null)
        },
        stop_id: (.naptanId // "stop_unknown"),
        status: (.currentLocation // "UNKNOWN"),
        speed: (.speed // null)
      }
    ]
  }' "${TMP_RAW}" > "${TMP_NORM}"
}

main() {
  local attempt=1
  local ok=0

  while (( attempt <= API_RETRIES )); do
    if fetch_once; then
      if jq empty "${TMP_RAW}" >/dev/null 2>&1; then
        ok=1
        break
      fi
    fi
    attempt=$(( attempt + 1 ))
    sleep 1
  done

  if (( ok == 0 )); then
    log_error "Failed to fetch live data"
    exit 1
  fi

  normalize_tfl_to_project

  mv "${TMP_NORM}" "${OUT_JSON}"
  rm -f "${TMP_RAW}"

  log_info "Saved normalized JSON → ${OUT_JSON}"
}

main "$@"
