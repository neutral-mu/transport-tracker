#!/bin/bash
# Master Orchestrator

PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PIPELINE_DIR/../config/config.sh"

echo "🚀 Starting Public Transport Pipeline..."

echo "[1/4] Ingesting Data..."
"$SCRIPTS_DIR/1_ingest_data.sh"

echo "[2/4] Computing Delays..."
"$SCRIPTS_DIR/2_compute_delays.sh"

echo "[3/4] Generating Report..."
"$SCRIPTS_DIR/3_generate_report.sh"

echo "[4/4] Checking Alerts..."
"$SCRIPTS_DIR/4_send_alerts.sh"

echo "🏁 Pipeline Finished."