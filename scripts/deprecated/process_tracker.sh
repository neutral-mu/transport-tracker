#!/bin/bash
# bin/process_tracker.sh

cd "$(dirname "$0")"
source ../config/settings.cfg

TODAY=$(date +%Y-%m-%d)
DAILY_LOG="$LOG_DIR/tracker_$TODAY.log"

# Create Today's Log if not exists
[ ! -f "$DAILY_LOG" ] && echo "RouteID,BusID,Scheduled,Actual,DelayMin,Status" > "$DAILY_LOG"

# 1. Fetch Live Data (In real life, use curl. Here we use the mock file)
# curl -s "$LIVE_FEED_URL" > "$DATA_DIR/live_feed.json"
# Just ensuring the mock data exists for this demo:
./mock_data.sh

# 2. Process Data using jq (parse JSON) and awk (join + calc)
# We output a temporary CSV of the live data to pipe into awk
jq -r '.[] | "\(.bus_id),\(.actual_arrival)"' "$DATA_DIR/live_feed.json" | \
awk -F, -v threshold="$THRESHOLD_MINUTES" -v timetable="$TIMETABLE_FILE" -v dateStr="$TODAY" '
BEGIN {
    # Load Timetable into associative array: schedule[BusID] = "RouteID,Time"
    while ((getline < timetable) > 0) {
        schedule[$2] = $1 "," $3
    }
    close(timetable)
}
{
    # Input stream is "BusID,ActualTime" from jq
    bus_id = $1
    actual_time = $2

    if (bus_id in schedule) {
        split(schedule[bus_id], data, ",")
        route_id = data[1]
        sched_time = data[2]

        # Convert times to epoch for math (using a dummy date)
        cmd_sched = "date -d \"" dateStr " " sched_time "\" +%s"
        cmd_sched | getline sched_epoch
        close(cmd_sched)

        cmd_actual = "date -d \"" dateStr " " actual_time "\" +%s"
        cmd_actual | getline actual_epoch
        close(cmd_actual)

        # Calculate Delay
        diff_sec = actual_epoch - sched_epoch
        delay_min = int(diff_sec / 60)

        status = "ON_TIME"
        if (delay_min > threshold) status = "MAJOR_DELAY"
        else if (delay_min > 0) status = "MINOR_DELAY"
        else if (delay_min < 0) status = "EARLY"

        # Output for the log file
        print route_id "," bus_id "," sched_time "," actual_time "," delay_min "," status
    }
}' >> "$DAILY_LOG"

# 3. Check for Major Delays and Email
# We use grep to find new major delays in the log
grep "MAJOR_DELAY" "$DAILY_LOG" | while IFS=, read -r route bus sched actual delay status; do
    # Simple deduplication check (in prod, you use a state file)
    echo "URGENT: Bus $bus on Route $route is delayed by $delay minutes." | \
    mailx -s "Transit Alert: Route $route" "$ADMIN_EMAIL"
done

echo "Processing complete. Data logged to $DAILY_LOG"