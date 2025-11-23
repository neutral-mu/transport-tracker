#!/usr/bin/env bash
# validate_live_data.sh - light validation for live.csv
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${ROOT_DIR}/lib.sh"

LIVE_CSV="${DATA_DIR}/live.csv"

main() {
  if [[ ! -f "${LIVE_CSV}" ]]; then
    log_error "live.csv not found at ${LIVE_CSV}"
    exit 1
  fi

  local line_count
  line_count=$(wc -l < "${LIVE_CSV}" || echo 0)

  if (( line_count <= 1 )); then
    log_warn "live.csv has only header or is empty (${line_count} lines)"
  else
    log_info "live.csv has ${line_count} lines (including header)"
  fi

  # Check each non-header line has 13 columns
  local bad=0
  awk -F',' 'NR>1 { if (NF != 13) { bad++; printf("WARN: line %d has %d columns (expected 13)\n", NR, NF) } } END { exit (bad>0 ? 1 : 0) }' "${LIVE_CSV}" \
    || { log_warn "Some rows in live.csv have wrong number of columns"; bad=1; }

  if (( bad == 0 )); then
    log_info "live.csv validation OK (13 columns on all data rows)"
  fi
}

main "$@"
