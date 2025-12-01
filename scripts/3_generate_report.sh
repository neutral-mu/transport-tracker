#!/bin/bash
# scripts/3_generate_report.sh

# 1. Load Config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.sh"

TODAY=$(date +%Y-%m-%d)
INPUT_CSV="$DATA_DIR/$FILE_DELAYS"
REPORT_HTML="$REPORT_DIR/report_$TODAY.html"
REPORT_PDF="$REPORT_DIR/report_$TODAY.pdf"
CHART_IMG="$REPORT_DIR/chart_$TODAY.png"
THRESHOLD=${DELAY_THRESHOLD:-15}

# 2. Calculate Statistics
eval $(awk -F, 'NR>1 {
    total++;
    sum_delay += $5;
    if ($5 <= 0) on_time++;
} END {
    if (total > 0) {
        avg = sum_delay / total;
        pct = (on_time / total) * 100;
    } else {
        avg = 0; pct = 0;
    }
    printf "AVG_DELAY=%.2f\nON_TIME_PCT=%.2f\nTOTAL_BUSES=%d", avg, pct, total
}' "$INPUT_CSV")

# 3. Generate Chart (Direct CSV - Boxes Mode)
gnuplot <<-GNU
    set terminal pngcairo size 800,400 font "Arial,10"
    set output "$CHART_IMG"
    set title "Bus Delays - $TODAY"
    set boxwidth 0.5 absolute
    set style fill solid 1.0
    set grid y
    set yrange [0:*]
    set ylabel "Delay (Minutes)"
    set xlabel "Bus ID"
    
    set datafile separator ","
    
    # 0 = X Coordinate (Row Index)
    # 5 = Y Coordinate (Delay Value)
    # xtic(2) = X Axis Label (BusID from Col 2)
    # Color Logic: If Delay(Col 5) > Threshold ? Red(0xFF0000) : Green(0x00AA00)
    
    plot "$INPUT_CSV" every ::1 using 0:5:xtic(2):( \$5 > $THRESHOLD ? 0xFF0000 : 0x00AA00 ) with boxes lc rgb variable notitle
GNU

# 4. Generate HTML
cat <<HTML > "$REPORT_HTML"
<html>
<head>
    <style>
        body { font-family: sans-serif; padding: 20px; }
        .stats { display: flex; gap: 20px; }
        .card { border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .MAJOR_DELAY { background-color: #ffcccc; color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Public Transport Punctuality: $TODAY</h1>
    <div class="stats">
        <div class="card"><strong>On-Time Performance:</strong> ${ON_TIME_PCT}%</div>
        <div class="card"><strong>Avg Delay:</strong> ${AVG_DELAY} min</div>
        <div class="card"><strong>Total Tracked:</strong> ${TOTAL_BUSES}</div>
    </div>
    
    <h3>Delay Visualization</h3>
    <img src="$CHART_IMG" alt="Delay Chart" width="600">

    <h3>Detailed Log</h3>
    <table>
        <tr><th>Route</th><th>Bus</th><th>Scheduled</th><th>Actual</th><th>Delay (min)</th><th>Status</th></tr>
HTML

tail -n +2 "$INPUT_CSV" | sed 's/,/<\/td><td>/g' | sed 's/^/<tr><td>/' | sed 's/$/<\/td><\/tr>/' | \
while read row; do
    if echo "$row" | grep -q "MAJOR_DELAY"; then
        echo "${row/<tr>/<tr class='MAJOR_DELAY'>}" >> "$REPORT_HTML"
    else
        echo "$row" >> "$REPORT_HTML"
    fi
done

echo "    </table></body></html>" >> "$REPORT_HTML"

# 5. Convert to PDF
if command -v wkhtmltopdf &> /dev/null; then
    wkhtmltopdf --enable-local-file-access -q "$REPORT_HTML" "$REPORT_PDF"
    echo "PDF generated at $REPORT_PDF"
fi