#!/usr/bin/env bash
set -euo pipefail

# Hardcode paths for safety in this version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
LIVE_CSV="${ROOT_DIR}/data/live.csv"
TIMETABLE_CSV="${ROOT_DIR}/data/timetable_normalized.csv"
MATCHED_CSV="${ROOT_DIR}/data/matched.csv"
UNMATCHED_LOG="${ROOT_DIR}/logs/unmatched.log"

# Ensure output directory exists
mkdir -p "$(dirname "${MATCHED_CSV}")"

echo "match_id,trip_id,live_timestamp_iso,live_timestamp_epoch,vehicle_id,stop_id,scheduled_time_iso,scheduled_time_epoch,actual_time_iso,actual_time_epoch,delay_min,match_score,match_method,notes" > "${MATCHED_CSV}"

awk -F',' -v OFS=',' '
  function clean(str) { gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", str); return str; }

  FNR == NR {
    if (NR == 1) next;
    t_trip = clean($1); t_stop = clean($4); t_epoch = clean($7); t_iso = clean($6);
    key = t_trip "|" t_stop;
    trip_idx[key] = t_epoch "|" t_iso;
    next;
  }

  {
    if (FNR == 1) next;
    l_trip = clean($4); l_stop = clean($6); l_iso = clean($1); l_epoch = clean($2); l_veh = clean($3);

    key = l_trip "|" l_stop;
    if (key in trip_idx) {
      split(trip_idx[key], arr, "|");
      sched_epoch = arr[1];
      sched_iso = arr[2];
      delay = (l_epoch - sched_epoch) / 60;

      print "match_1", l_trip, l_iso, l_epoch, l_veh, l_stop, sched_iso, sched_epoch, l_iso, l_epoch, delay, "1.0", "EXACT", "";
    } else {
        # Print unmatched for debugging
        # print "Unmatched: " key > "/dev/stderr"
    }
  }
' "${TIMETABLE_CSV}" "${LIVE_CSV}" >> "${MATCHED_CSV}"
