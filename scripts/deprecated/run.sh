#!/bin/bash

# 1. Setup Context
# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
source ../config/settings.cfg

echo "=========================================="
echo "🚍 Public Transport Tracker - Manual Run"
echo "=========================================="

# 2. Generate Data
echo "[1/3] Generating mock timetable and live feed..."
./mock_data.sh
if [ $? -eq 0 ]; then echo "   ✅ Data generated."; else echo "   ❌ Error generating data."; exit 1; fi

# 3. Process Data
echo "[2/3] Processing delay logic..."
./process_tracker.sh
if [ $? -eq 0 ]; then echo "   ✅ Data processed and logged."; else echo "   ❌ Error processing data."; exit 1; fi

# 4. Generate Report
echo "[3/3] Generating Daily Report (HTML + PDF)..."
./generate_report.sh
if [ $? -eq 0 ]; then 
    echo "   ✅ Report created successfully."
else 
    echo "   ❌ Error generating report."
    exit 1
fi

echo "=========================================="
echo "🚀 Pipeline Complete!"
echo "📄 PDF Report: $REPORT_DIR/report_$(date +%Y-%m-%d).pdf"
echo "=========================================="