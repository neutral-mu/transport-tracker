#!/bin/bash
# install_automation.sh
# Automates the crontab setup for the Public Transport Tracker

# 1. Get Absolute Paths
PROJECT_ROOT="$(pwd)"
PIPELINE_SCRIPT="$PROJECT_ROOT/scripts/run_pipeline.sh"
LOG_FILE="$PROJECT_ROOT/logs/cron_output.log"

echo "🔧 Installing Automation for Public Transport Tracker..."
echo "   Target Script: $PIPELINE_SCRIPT"

# 2. Validation
if [ ! -f "$PIPELINE_SCRIPT" ]; then
    echo "❌ Error: Could not find run_pipeline.sh at $PIPELINE_SCRIPT"
    echo "   Please run this installer from the project folder."
    exit 1
fi

# Make sure log dir exists
mkdir -p "$PROJECT_ROOT/logs"

# Make sure scripts are executable
chmod +x "$PROJECT_ROOT/scripts/"*.sh

# 3. Create Cron Job String
# Runs every 15 minutes
CRON_JOB="*/15 * * * * $PIPELINE_SCRIPT >> $LOG_FILE 2>&1"

# 4. Update Crontab safely
# We export the current crontab, remove any old lines for this project (to avoid duplicates),
# and add the new one.
(crontab -l 2>/dev/null | grep -v "run_pipeline.sh"; echo "$CRON_JOB") | crontab -

echo "=========================================="
echo "✅ Success! The tracker has been scheduled."
echo "   It will run every 15 minutes automatically."
echo "   Logs will be saved to: logs/cron_output.log"
echo "=========================================="
echo "To check the schedule, type: crontab -l"