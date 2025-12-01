#!/bin/bash
source "$(dirname "$0")/../config/config.sh"

# Input Files
LIVE_CSV="$DATA_DIR/$FILE_LIVE_CSV"
TIMETABLE="$DATA_DIR/$FILE_TIMETABLE"
# Output File
OUTPUT_CSV="$DATA_DIR/$FILE_DELAYS"

echo "RouteID,BusID,Scheduled,Actual,DelayMin,Status" > "$OUTPUT_CSV"

# The AWK Logic (Adapted from your old script to read the new CSV inputs)
awk -F, -v threshold="$DELAY_THRESHOLD" -v timetable="$TIMETABLE" -v dateStr="$(date +%Y-%m-%d)" '
BEGIN {
    while ((getline < timetable) > 0) {
        # Timetable format: RouteID,BusID,ScheduledTime
        schedule[$2] = $1 "," $3
    }
    close(timetable)
}
NR > 1 { # Skip header of live.csv
    bus_id = $1
    actual_time = $2

    if (bus_id in schedule) {
        split(schedule[bus_id], data, ",")
        route_id = data[1]
        sched_time = data[2]

        # Calculate Epochs
        cmd_sched = "date -d \"" dateStr " " sched_time "\" +%s"
        cmd_sched | getline sched_epoch
        close(cmd_sched)

        cmd_actual = "date -d \"" dateStr " " actual_time "\" +%s"
        cmd_actual | getline actual_epoch
        close(cmd_actual)

        delay_min = int((actual_epoch - sched_epoch) / 60)

        status = "ON_TIME"
        if (delay_min > threshold) status = "MAJOR_DELAY"
        else if (delay_min > 0) status = "MINOR_DELAY"

        print route_id "," bus_id "," sched_time "," actual_time "," delay_min "," status
    }
}' "$LIVE_CSV" >> "$OUTPUT_CSV"

echo "✅ Processing Complete: Created $FILE_DELAYS"