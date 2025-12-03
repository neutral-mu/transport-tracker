# Public Transport Delay Tracker

A robust, modular data pipeline built entirely in **Bash**. This system simulates real-time public transport data, calculates delays against a schedule, generates visual PDF reports with histograms, and automatically emails administrators if critical delays are detected.

## Project Structure

```text
public_transport_tracker/
├── setup_wizard.sh
├── install_automation.sh
├── scripts/
│   ├── mock_data.sh
│   ├── 1_ingest_data.sh
│   ├── 2_compute_delays.sh
│   ├── 3_generate_report.sh
│   ├── 4_send_alerts.sh
│   └── run_pipeline.sh
├── config/
│   ├── config.sh
│   └── secrets.sh
├── data/
├── logs/
└── output/reports/
```

## Logic & Command Breakdown

This section explains the specific shell commands used in each script and how they implement the project logic.

| File | Primary Logic / Responsibility | Key Commands & Usage |
| :--- | :--- | :--- |
| **setup\_wizard.sh** | **Configuration.** Interactively asks the user for Gmail credentials and saves them securely to a file. | **read**: Captures user input.<br>**cat**: Writes the configuration file using Here-Docs.<br>**chmod 600**: Secures the secrets file. |
| **mock\_data.sh** | **Data Generation.** Generates random arrival times. Handles time math. | **date -d**: Performs time arithmetic.<br>**$RANDOM**: Randomizes delay duration.<br>**cat \<\<EOF**: Generates raw JSON files dynamically. |
| **1\_ingest\_data.sh** | **Ingestion.** Calls the data generator and ensures raw files are present for processing. | **source**: Imports functions and variables.<br>**jq**: Parses raw JSON data into structured CSV format. |
| **2\_compute\_delays.sh** | **Computation.** The core engine. Reads CSVs, calculates time differences, and flags delays. | **awk**: Maps buses to schedules and uses conditional logic to assign status flags.<br>**date +%s**: Converts timestamps to Unix Epoch. |
| **3\_generate\_report.sh** | **Visualization.** Calculates statistics, draws charts, and builds the final document. | **gnuplot**: Generates PNG histograms directly from the CLI.<br>**wkhtmltopdf**: Converts HTML and images into a PDF.<br>**sed**: Converts CSV commas into HTML tags.<br>**awk**: Calculates summary statistics. |
| **4\_send\_alerts.sh** | **Notification.** Checks data for major delays and connects to SMTP servers. | **grep -c**: Counts occurrences of delays to determine if an alert is needed.<br>**s-nail / mailx**: Connects to SMTP server to send emails. |
| **install\_automation.sh** | **Scheduling.** Adds the pipeline to the system background scheduler. | **crontab**: Reads and writes to the system schedule daemon.<br>**grep -v**: Filters existing cron jobs to prevent duplicates. |

## Prerequisites & Installation

To run this project, you need specific Linux utilities installed.

### 1\. Arch Linux (Manjaro, EndeavourOS)

Note: Arch requires enabling the cron service manually.

```bash
sudo pacman -S s-nail gnuplot wkhtmltopdf jq cronie
sudo systemctl enable --now cronie
```

### 2\. Debian / Ubuntu / Linux Mint

```bash
sudo apt update
sudo apt install s-nail gnuplot wkhtmltopdf jq
```

### 3\. Fedora / RHEL / CentOS

```bash
sudo dnf install s-nail gnuplot wkhtmltopdf jq crontabs
sudo systemctl enable --now crond
```

### 4\. macOS (via Homebrew)

Note: macOS uses launchd instead of cron by default, but crontab is supported.

```bash
brew install gnuplot wkhtmltopdf jq
```

## Usage Guide

### Step 1: Configure Credentials

You need a **Gmail App Password** to send alerts. Run the wizard to set up your sender and recipient email.

```bash
./setup_wizard.sh
```

### Step 2: Manual Test Run

Run the full pipeline manually to generate data, create a report, and test the email connection.

```bash
./scripts/run_pipeline.sh
```

Check `output/reports/` for the PDF and your email inbox for the alert.

### Step 3: Enable Automation

Set the tracker to run automatically every 15 minutes in the background.

```bash
./install_automation.sh
```

## Configuration

You can tweak global settings in `config/config.sh`:

  * **DELAY\_THRESHOLD**: Minimum minutes late to trigger an alert (Default: 15).
  * **LIVE\_FEED\_URL**: URL if switching from mock data to a real API.

## Stopping the Automation

To stop the background scheduler:

```bash
crontab -r
```
