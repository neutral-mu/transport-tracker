#!/bin/bash
# bin/log_rotate.sh
cd "$(dirname "$0")"
source ../config/settings.cfg

# Compress logs older than 7 days
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

# Delete archives older than 30 days
find "$LOG_DIR" -name "*.gz" -mtime +30 -exec rm {} \;