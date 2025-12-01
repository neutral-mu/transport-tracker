#!/bin/bash
# scripts/1_ingest_data.sh

# 1. Load Config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

# 2. Fetch Data (Run the mock generator)
# This now creates "$DATA_DIR/$FILE_LIVE_RAW" and "$DATA_DIR/$FILE_TIMETABLE" directly
"$SCRIPTS_DIR/mock_data.sh"

# 3. Normalize: Convert JSON to CSV
# We take the raw JSON and convert it to the normalized CSV format
echo "bus_id,actual_time" > "$DATA_DIR/$FILE_LIVE_CSV"

if [ -f "$DATA_DIR/$FILE_LIVE_RAW" ]; then
    jq -r '.[] | "\(.bus_id),\(.actual_arrival)"' "$DATA_DIR/$FILE_LIVE_RAW" >> "$DATA_DIR/$FILE_LIVE_CSV"
    echo "✅ Ingestion Complete: Created $FILE_LIVE_CSV"
else
    echo "❌ Error: Raw data file ($FILE_LIVE_RAW) not found!"
    exit 1
fi