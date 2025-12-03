PROJECT OVERVIEW & COMMAND MAPPING

1. SETUP & AUTOMATION
---------------------
File: setup_wizard.sh
- Purpose: Asks user for Gmail credentials and saves them securely.
- Commands:
  * read  : Captures user input (email/password).
  * cat   : Writes the 'secrets.sh' configuration file.
  * chmod : Sets file permissions so only the owner can read the password.

File: install_automation.sh
- Purpose: Adds the project to the system scheduler.
- Commands:
  * crontab : Reads/Writes to the system schedule daemon.
  * grep    : checks if a job already exists to avoid duplicates.

2. DATA PIPELINE (scripts/ folder)
----------------------------------
File: mock_data.sh (called by 1_ingest_data.sh)
- Purpose: Generates random bus arrival times.
- Commands:
  * date  : Performs time math (e.g., "08:00 + 5 minutes").
  * cat   : "Here-Doc" usage to write raw JSON/CSV data to disk.

File: 2_compute_delays.sh
- Purpose: Calculates the difference between Scheduled and Actual times.
- Commands:
  * awk   : The logic engine. Reads CSV columns, calculates delay minutes, and assigns status flags (MAJOR_DELAY).

File: 3_generate_report.sh
- Purpose: Creates the PDF dashboard.
- Commands:
  * awk         : Calculates summary stats (Avg Delay, On-Time %).
  * gnuplot     : Draws the PNG Bar Chart histogram directly from the script.
  * sed         : text stream editor. Converts CSV commas into HTML <td> tags.
  * wkhtmltopdf : Converts the final HTML file + Images into a PDF.

File: 4_send_alerts.sh
- Purpose: Emails the admin if delays are found.
- Commands:
  * grep  : Counts occurrences of "MAJOR_DELAY" in the data.
  * mailx : Connects to Gmail SMTP to send the email with attachment.

File: run_pipeline.sh
- Purpose: Master orchestrator.
- Commands:
  * source : Imports variables from config.sh.
  * bash   : Executes the other scripts in order (1 -> 2 -> 3 -> 4).
