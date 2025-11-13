# **Public Transport Delay Tracker — Complete Project Phases**


## Gist:
  - First we get the data - timetable and live data

  - We compare the live data with the scheduled timetable to calculate the delays

  - If any delay crosses a certain threshold, we mark it down as critically late

  - We create a summary report of the various observations. Doing stuff like making charts or stuff. This part can be adjusted based on what kind of observations we can achieve.

  - We send alerts and notifications. Basically maintain a log and email data about critical delays to the concerned parties

  - We automate the process using cron. Since its public transport we run it every 15 minutes, to prevent stuff like rate limits while still keeping the data relevant
  
  - We add safety monitors like frequently running checks if data is updated or not, checking if cron is producing errors, api is respondong or not, etc

  - At last, we test and debug

---



## **Phase 0 — Project Setup & Foundations**
**Goal:** Establish project structure, configuration, utilities, and data standards.

### Tasks
- Create directory structure (`data/`, `scripts/`, `logs/`, `output/`, `tests/`, etc.)
- Write `config.sh` (paths, API URL, thresholds)
- Write `lib.sh` (logging, time conversion helpers, locking)
- Define canonical CSV schemas:
  - `live.csv`
  - `timetable_normalized.csv`
  - `matched.csv`
  - `delays.csv`
- Prepare sample CSV/JSON data for testing
- Produce documentation (`docs/data_contract.md`)

### Deliverables
- Project skeleton  
- Configuration + utilities  
- Standard data schemas  
- Sample test data  

---



## **Phase 1 — Live Data Ingestion & Normalization**
**Goal:** Fetch JSON from API, validate, convert to normalized CSV.

### Tasks
- Implement `fetch_live_data.sh`  
  - curl → `live_raw.json`  
  - retry logic  
  - logging  
- Implement `json_to_csv.sh`  
  - Parse JSON using `jq`  
  - Convert timestamps (ISO, epoch)  
  - Output `live.csv`  
- Implement `validate_live_data.sh`  
- Error handling + ingestion logs

### Deliverables
- `data/live_raw.json`  
- `data/live.csv`  
- Ingestion logs  

---



## **Phase 2 — Timetable Normalization**
**Goal:** Convert static timetable CSV into normalized canonical form.

### Tasks
- Implement `normalize_timetable.sh`
- Clean fields (trim whitespace, consistent formatting)
- Convert times to ISO + epoch
- Validate data (duplicate stops, missing fields)
- Log warnings & inconsistencies

### Deliverables
- `data/timetable_normalized.csv`  
- `logs/timetable_warnings.log`  

---



## **Phase 3 — Matching Engine**
**Goal:** Match live events to scheduled events.

### Tasks
- Implement `match_live_to_schedule.sh`  
  - trip_id exact match (primary)  
  - fallback match: route_id + stop_id + time window  
  - handle multiple matches  
  - log ambiguous or unmatched entries  
- Produce `matched.csv` with confidence flags

### Deliverables
- `data/matched.csv`  
- `logs/unmatched.log`  

---



## **Phase 4 — Delay Calculation & Threshold Flagging**
**Goal:** Compute delays and identify alert-worthy events.

### Tasks
- Implement `compute_delays.sh`
  - Calculate delay_minutes from epoch times
  - Determine `alert_flag` using threshold from `config.sh`
- Produce final delayed dataset (`delays.csv`)
- Prep for alerting system

### Deliverables
- `data/delays.csv`  

---



## **Phase 5 — Summary Generation & Reporting**
**Goal:** Summarize daily performance and optionally visualize.

### Tasks
- Implement `generate_summary.sh`
  - daily summary CSV  
  - key metrics (avg delay, on-time %, alerts count)  
- Build optional HTML report template
- Optionally generate charts using `gnuplot`  
  - avg delay per route  
  - delay distribution  

### Deliverables
- `output/reports/summary_YYYY-MM-DD.csv`  
- `output/reports/report_YYYY-MM-DD.html`  
- Optional chart PNGs  

---



## **Phase 6 — Alerts & Notifications**
**Goal:** Notify operators when severe delays occur.

### Tasks
- Implement `send_alerts.sh`
  - For delays ≥ threshold  
  - Deduplicate using `alerts_sent.csv`  
  - Send via `mailx`  
- Maintain alert logs & history

### Deliverables
- Alert email system  
- `alerts_sent.csv`  
- `alert_logs`  

---



## **Phase 7 — Automation (Cron + Pipeline Orchestration)**
**Goal:** Make the entire pipeline run automatically and reliably.

### Tasks
- Implement master orchestrator `run_all.sh`
  - fetch → normalize → match → delays → summary → alerts  
- Implement log rotation (`rotate_logs.sh`)
- Configure cron jobs:
  - Every X minutes: run_all  
  - Daily: summary reports  
- Ensure environment variables, absolute paths, and locking in place

### Deliverables
- `run_all.sh`  
- `rotate_logs.sh`  
- cron entries  

---



## **Phase 8 — Testing & Health Monitoring**
**Goal:** Ensure system correctness, detect failures.

### Tasks
- Implement `tests/run_tests.sh`
- Write simple diff-based assertions for:
  - JSON→CSV  
  - timetable normalization  
  - matching on sample data  
  - delay calculations  
- Implement `healthcheck.sh`
  - Detect stale runs / missing data  
  - Log anomalies  

### Deliverables
- Automated test suite  
- Health monitoring scripts  

---



## **Phase 9 — Final Integration & QA**
**Goal:** Combine all components into a stable pipeline.

### Tasks
- Run end-to-end test with real API + timetable
- Debug any mismatches in CSV formats
- Validate summary and alerts
- Final cleanup & documentation

### Deliverables
- Fully working system  
- Final README + usage docs  
- Operational checklist  

---
