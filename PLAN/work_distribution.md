# Public Transport Delay Tracker



## Person A — **Configuration, Utilities & Data Contracts**
### **Role:** Foundation / Shared Infrastructure  
### **Responsibilities**
- Define project structure, shared config, helper utilities.
- Define all CSV schemas and prepare sample data.
- Enable all other team members to work concurrently.

### **Tasks**
- Create directory skeleton (`data/`, `scripts/`, `output/`, `tests/`, etc.)
- Write `config.sh` (paths, API URL, thresholds)
- Write `lib.sh` (logging, timestamp functions, locking helper)
- Define canonical CSV schemas:
  - `live.csv`
  - `timetable_normalized.csv`
  - `matched.csv`
  - `delays.csv`
- Create sample CSV/JSON files in `tests/`
- Document data contracts in `docs/data_contract.md`

### **Deliverables**
- `config.sh`, `lib.sh`
- Standardized CSV schemas
- `tests/` sample inputs
- Base project structure

---



## Person B — **Live Data Ingestion (API Fetch + JSON → CSV)**
### **Role:** External Data Intake  
### **Responsibilities**
- Fetch live API data, validate, normalize, convert to canonical CSV.

### **Tasks**
- Write `fetch_live_data.sh` (curl, retries, logging)
- Write `json_to_csv.sh` (parse with `jq`, convert to ISO + epoch)
- Write `validate_live_data.sh`   
- Produce:
  - `data/live_raw.json`
  - `data/live.csv`

### **Deliverables**
- Functional ingestion pipeline
- Validated & normalized `live.csv`
- Fetch & parsing logs

---



## Person C — **Timetable Normalization**
### **Role:** Static Data Processing  
### **Responsibilities**
- Normalize timetable CSV into canonical structure.

### **Tasks**
- Write `normalize_timetable.sh`
- Convert times → ISO + epoch
- Trim/clean data fields
- Validate duplicates & missing fields
- Log warnings

### **Deliverables**
- `data/timetable_normalized.csv`
- `logs/timetable_warnings.log`

---



## Person D — **Matching Engine & Delay Computation**
### **Role:** Core Processing Logic  
### **Responsibilities**
- Match live data to timetable.
- Compute delays, thresholds, flags.

### **Tasks**
- Write `match_live_to_schedule.sh`  
  - trip_id first  
  - fallback: route_id + stop_id + time window  
  - log unmatched + ambiguous cases
- Write `compute_delays.sh`
  - delay calculation in minutes
  - add `alert_flag`
- Output:
  - `data/matched.csv`
  - `data/delays.csv`

### **Deliverables**
- Complete matching engine
- Delay calculator
- `matched.csv`, `delays.csv`, `unmatched.log`

---



## Person E — **Reporting, Alerts & Automation**
### **Role:** Output, Presentation, Ops**  
### **Responsibilities**
- Summary reports, charts, alerts, cron automation, health checks.

### **Tasks**
- Write `generate_summary.sh`  
  - Daily summary CSV  
  - Optional HTML report template  
- Optional: create charts via `gnuplot`
- Write `send_alerts.sh`  
  - dedup alerts via `alerts_sent.csv`
- Write automation scripts:
  - `run_all.sh`
  - `rotate_logs.sh`
  - cron job definitions
- Write:
  - `tests/run_tests.sh`
  - `healthcheck.sh`

### **Deliverables**
- Summary CSV & HTML reports
- Alert system + email integration
- Cron automation
- Test suite & health checks

---




## Summary Overview (Table)

| Person | Role | Primary Outputs |
|--------|------|----------------|
| **A** | Config & Data Contracts | config.sh, lib.sh, schemas, test samples |
| **B** | Live Data Ingestion | live_raw.json, live.csv |
| **C** | Timetable Normalization | timetable_normalized.csv |
| **D** | Matching & Delay Logic | matched.csv, delays.csv |
| **E** | Reporting & Automation | summary, alerts, cron, health checks |

---
