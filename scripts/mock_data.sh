#!/bin/bash
# scripts/mock_data.sh

# 1. Load Config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

echo "🎲 Generating Realistic Mock Data..."

# 2. Generate Timetable
echo "RouteID,BusID,ScheduledTime" > "$DATA_DIR/$FILE_TIMETABLE"
echo "R101,B001,08:00" >> "$DATA_DIR/$FILE_TIMETABLE"
echo "R101,B002,08:30" >> "$DATA_DIR/$FILE_TIMETABLE"
echo "R102,B003,08:15" >> "$DATA_DIR/$FILE_TIMETABLE"
echo "R103,B004,09:00" >> "$DATA_DIR/$FILE_TIMETABLE"
echo "R101,B005,09:15" >> "$DATA_DIR/$FILE_TIMETABLE"

# 3. Generate Live Feed
# Function to safely add/subtract minutes using 'date'
get_arrival_time() {
    base_time=$1
    # Random delay between -2 (early) and +30 (late)
    delay=$(( (RANDOM % 33) - 2 ))
    
    # Use 'date' to handle the time math (e.g. 09:00 - 2 mins = 08:58)
    date -d "$base_time today + $delay minutes" +%H:%M
}

cat <<JSON > "$DATA_DIR/$FILE_LIVE_RAW"
[
  {"bus_id": "B001", "actual_arrival": "$(get_arrival_time 08:00)"},
  {"bus_id": "B002", "actual_arrival": "$(get_arrival_time 08:30)"},
  {"bus_id": "B003", "actual_arrival": "$(get_arrival_time 08:15)"},
  {"bus_id": "B004", "actual_arrival": "$(get_arrival_time 09:00)"},
  {"bus_id": "B005", "actual_arrival": "$(get_arrival_time 09:15)"}
]
JSON

echo "✅ Realistic data created."