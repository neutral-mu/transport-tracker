set terminal pngcairo size 800,400
set output "/home/lol/Code/script/script_project/public_transport_tracker/output/reports/chart_2025-11-26.png"
set title "Bus Delays - 2025-11-26"
set style fill solid
set boxwidth 0.5
set grid y
set yrange [0:*]
set datafile separator whitespace

# Plot command details:
# using 0:2:xtic(1) -> Use Row Index for X, Col 2 for Y, Col 1 for Labels
# linecolor rgb variable -> Read the calculated color from the 4th column (the logic)
plot "/home/lol/Code/script/script_project/public_transport_tracker/data/graph_data.txt" using 0:2:xtic(1):( $2 > 15 ? 0xFF0000 : 0x00FF00 ) with boxes lc rgb variable notitle
