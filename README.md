# 🚀 Bash Scripts Collection
Bash scripts for sysadmin, homelab and DevOps automation

![GitHub stars](https://img.shields.io/github/stars/kjedynak00/bash-scripts?style=social)
![Last commit](https://img.shields.io/github/last-commit/kjedynak00/bash-scripts)
![Repo size](https://img.shields.io/github/repo-size/kjedynak00/bash-scripts)
![Top language](https://img.shields.io/github/languages/top/kjedynak00/bash-scripts)
![Bash Scripts](https://img.shields.io/badge/Bash-Scripts-green)
![Linux Compatible](https://img.shields.io/badge/Linux-Compatible-blue)
![Automation](https://img.shields.io/badge/Automation-Ready-success)
![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)

---
## 📊 Quick Stats

Category | Script | Description | Status |
| :--- | :--- | :--- | :--- |
| **Monitoring** | [`server-monitoring.sh`](server-monitoring.sh) | 🖥️ Disk / CPU / RAM / load / network / pending updates + Discord alerts | 🟢 Production |
| **Monitoring** | [`ping-logger.sh`](ping-logger.sh) | 🌐 Internet watchdog (8.8.8.8) – logs only DOWN/UP transitions | 🟢 Production |
| **Monitoring** | [`homelab-daily-raport.sh`](homelab-daily-raport.sh) | 📊 Daily Kubernetes report: node disk & uptime, failing pods → Discord | 🟡 In progress |
| **Automation** | [`auto-update.sh`](auto-update.sh) | 🔄 apt updates with a pre-check, log file and Discord summary | 🟢 Production |
| **Utilities** | [`random-number-generator.sh`](random-number-generator.sh) | 🎲 Writes rows of random numbers from `/dev/urandom` to `file.txt` | 🟢 Production |

---
## 🧰 Scripts

### 🖥️ server-monitoring.sh
One-shot health check, meant to run from cron. Sends a Discord message when a threshold is exceeded:

Check | Alert when |
| :--- | :--- |
| Disk usage (`/`, `/boot`) | > 60% |
| CPU usage | > 70% |
| RAM usage | > 70% |
| Pending apt updates | at least one |

Also reports uptime, load average and RX/TX traffic of the active network interface.

**Configuration:** `WEBHOOK_URL`, monitored partitions in `PARTITION=(...)`, thresholds inside the script.

### 🌐 ping-logger.sh
Pings `8.8.8.8` in an endless loop and writes a line only when the connection goes down (🌐 INTERNET DOWN) or comes back (✅ INTERNET BACK UP). The last state is kept in a state file, so a restart does not log a false change.

**Configuration:** `LOGFILE`, `STATEFILE` (default: a USB drive under `/mnt/usb-drv/1tb/`).  
Run it in the background, e.g. as a systemd service or with `nohup ./ping-logger.sh &`.

### 📊 homelab-daily-raport.sh
Builds a daily report of the Kubernetes cluster and posts it to Discord:
- every node: disk size, free space (⚠️ below 20% free) and uptime – remote nodes are checked with a short-lived privileged `busybox` pod
- every pod that is not `Running` / `Completed`

**Configuration:** `WEBHOOK_URL`. Needs `kubectl` with access to the cluster.

### 🔄 auto-update.sh
Checks for available packages first and only then runs `apt-get` upgrades.
- logs every run with the hostname to `LOGFILE`
- sends a Discord summary with the list of updated packages
- reports whether a reboot is required (`/var/run/reboot-required`)
- stops with an error message when `apt` or `curl` fails

**Configuration:** `WEBHOOK_URL`, `LOGFILE` (default: `/mnt/NAS/home-lab/logs/updates.txt`). Run as root.

### 🎲 random-number-generator.sh
Appends 20 rows to `file.txt`, each with 1–7 random 32-bit numbers read from `/dev/urandom` (unlike Bash `$RANDOM`, suitable where unpredictability matters).

**Configuration:** `OUTFILE`, `ROWS`, `MAX_PER_ROW` at the top of the script.

---
## 🔧 Configuration
No real secrets are stored in this repository. Before running a script, replace the placeholders at the top of the file:
```bash
WEBHOOK_URL="EXAMPLE_WEBHOOK_URL"  # your Discord webhook URL
```
Keep webhook URLs out of Git – anyone with the URL can post to your channel.

---
## ⚙️ Requirements
- Linux (Debian / Ubuntu for `auto-update.sh` and the updates check)
- Bash 4+
- `curl` – Discord notifications
- `jq` – used by `auto-update.sh` (has a fallback without it)
- `bc` – CPU / RAM checks in `server-monitoring.sh`
- `kubectl` – `homelab-daily-raport.sh`

---
## ▶️ Usage
```bash
chmod +x script-name.sh
./script-name.sh
```
Example cron entries (`crontab -e`):
```bash
*/15 * * * * /path/to/server-monitoring.sh
0 8 * * *    /path/to/homelab-daily-raport.sh
0 4 * * 0    /path/to/auto-update.sh
```

---
## 👋 Contact
- Author: Kacper Jedynak
- Homelab: [kjedynak00/Home-lab](https://github.com/kjedynak00/Home-lab)
