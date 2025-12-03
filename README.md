# Transport Tracker

## A public transport timetable and delay tracker

#### Processes public transport timetable data along with real-time delay updates to generate puntuality reports and alerts

## Usage:
Create a file config/secrets.sh

Add this:
```bash
#!/bin/bash
export EMAIL_USER=""
export EMAIL_PASS=""
export SMTP_URL=""
export ALERT_RECIPIENT=""
```

To run, use
```bash
bash ./scripts/run_pipeline.sh
```

Reports are generated in output/reports

### Dependencies:
```
gnuplot
mailx
wkhtmltopdf-static
jq
cronie
```
