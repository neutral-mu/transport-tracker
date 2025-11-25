#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# source logging / config if available, otherwise set defaults
if [[ -f "${ROOT_DIR}/lib.sh" ]]; then
  source "${ROOT_DIR}/lib.sh"
  set +e
else
  # minimal fallback logging
  _timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
  log_info()  { echo "$(_timestamp) [INFO] $*"; }
  log_warn()  { echo "$(_timestamp) [WARN] $*"; }
  log_error() { echo "$(_timestamp) [ERROR] $*"; }
fi

DATA_DIR="${DATA_DIR:-${ROOT_DIR}/data}"
LOG_DIR="${LOG_DIR:-${ROOT_DIR}/logs}"

RAW_JSON="${DATA_DIR}/timetable_raw.json"
OUT_CSV="${DATA_DIR}/timetable_normalized.csv"
WARN_LOG="${LOG_DIR}/timetable_warnings.log"
TMP_CSV="${DATA_DIR}/timetable_tmp.csv"

mkdir -p "${DATA_DIR}" "${LOG_DIR}"

: > "${WARN_LOG}"

extract_to_csv() {
  jq -r '
    # iterate routes safely
    (.timetable.routes // [])[] as $r |

    # route id (fallbacks)
    (.lineId // "unknown_route") as $route_id |


    # station intervals (safe)
    ($r.stationIntervals // []) as $stationIntervals |

    # schedules -> knownJourneys
    ($r.schedules // [])[] as $sched |
    ($sched.knownJourneys // [])[] as $j |

    # raw hour/minute (coerce to number)
    ($j.hour // "0" | tonumber) as $rawH |
    ($j.minute // "0" | tonumber) as $M |

    # compute day offset and normalized hour (handles rawH >= 24)
    (($rawH / 24) | floor) as $dayOffset |
    ($rawH % 24) as $Hnorm |

    # interval index (safe fallback 0)
    (($j.intervalId // 0) | tonumber) as $intervalIndex |

    # compute service_date adjusted by dayOffset (UTC)
    (now + ($dayOffset * 86400) | strftime("%Y-%m-%d")) as $service_date |

    # zero-pad HH and MM (no lpad)
    (if $Hnorm < 10 then "0\($Hnorm)" else "\($Hnorm)" end) as $Hstr |
    (if $M < 10 then "0\($M)" else "\($M)" end) as $Mstr |

    # base ISO and epoch for departure
    ($service_date + "T" + $Hstr + ":" + $Mstr + ":00Z") as $base_iso |
    ($base_iso | fromdateiso8601) as $base_epoch |

    # stops list for the interval (safe default)
    ($stationIntervals[$intervalIndex].intervals // []) as $stops |

    # expand stops and emit CSV rows
    $stops
    | to_entries[]
    | (
        .key as $seq |
        .value as $stopObj |

        ($stopObj.stopId // $stopObj.stopID // "unknown_stop") as $stop_id |
        ($stopObj.timeToArrival // 0 | tonumber) as $mins |

        # compute arrival epoch + ISO
        ($base_epoch + ($mins * 60)) as $arrival_epoch |
        ($arrival_epoch | strftime("%Y-%m-%dT%H:%M:%SZ")) as $arrival_iso |

        # trip id
        ("trip_" + ($route_id|tostring) + "_" + $Hstr + $Mstr) as $trip_id |

        # output the CSV line
        [$trip_id, $route_id, $service_date, $stop_id, ($seq|tostring), $arrival_iso, ($arrival_epoch|tostring)] | @csv
      )
  ' "${RAW_JSON}" > "${TMP_CSV}"
}

clean_and_validate() {
  # header
  printf '%s\n' "trip_id,route_id,service_date,stop_id,stop_sequence,scheduled_time_iso,scheduled_time_epoch" > "${OUT_CSV}"

  SEEN=""

  while IFS=',' read -r trip route day stop seq iso epoch; do
    # strip quotes (jq @csv outputs quoted strings)
    trip="${trip//\"/}"
    route="${route//\"/}"
    day="${day//\"/}"
    stop="${stop//\"/}"
    seq="${seq//\"/}"
    iso="${iso//\"/}"
    epoch="${epoch//\"/}"

    # basic checks
    if [[ -z "${trip}" ]]; then
      printf '%s\n' "WARN: missing trip_id for stop ${stop}" >> "${WARN_LOG}"
    fi
    if [[ -z "${stop}" ]]; then
      printf '%s\n' "WARN: missing stop_id for trip ${trip}" >> "${WARN_LOG}"
    fi
    if ! [[ "${epoch}" =~ ^[0-9]+$ ]]; then
      printf '%s\n' "WARN: non-numeric epoch for ${trip} ${stop}: ${epoch}" >> "${WARN_LOG}"
    fi

    key="${trip}|${stop}|${seq}"
    if grep -qFx "${key}" <<< "${SEEN:-}"; then
      printf '%s\n' "WARN: duplicate entry ${key}" >> "${WARN_LOG}"
      continue
    fi
    SEEN+="${key}"$'\n'

    # append to final CSV
    printf '%s\n' "${trip},${route},${day},${stop},${seq},${iso},${epoch}" >> "${OUT_CSV}"
  done < "${TMP_CSV}"
}

main() {
  if [[ ! -f "${RAW_JSON}" ]]; then
    log_error "Missing raw JSON at: ${RAW_JSON}"
    return 1
  fi

  log_info "Normalizing timetable (input: ${RAW_JSON})"
  extract_to_csv || { log_error "extract_to_csv failed"; return 1; }
  clean_and_validate || { log_error "clean_and_validate failed"; return 1; }

  rm -f "${TMP_CSV}"
  log_info "Wrote normalized CSV: ${OUT_CSV}"
  log_info "Warnings: ${WARN_LOG}"
  return 0
}

# if run directly, execute main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
