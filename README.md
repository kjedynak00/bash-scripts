# 🚀 Bash Scripts Collection
Production-ready Bash scripts for sysadmin, home lab, and DevOps automation

![GitHub stars](https://img.shields.io/github/stars/kjedynak00/bash-scripts?style=social)
![Last commit](https://img.shields.io/github/last-commit/kjedynak00/bash-scripts)
![Repo size](https://img.shields.io/github/repo-size/kjedynak00/bash-scripts)
![Top language](https://img.shields.io/github/languages/top/kjedynak00/bash-scripts)
![Bash Scripts](https://img.shields.io/badge/Bash-Scripts-green)
![Linux Compatible](https://img.shields.io/badge/Linux-Compatible-blue)
![Automation](https://img.shields.io/badge/Automation-Ready-success)
![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)

---

# 🖥️ System Monitoring & Alerts
* `ping-logger` - 🌐 Smart Internet watchdog: pings 8.8.8.8, logs DOWN/UP transitions to USB drive
* `random-number-generator` - 🎲 Generates cryptographically secure random numbers to file (dev/random wrapper)
* `server-monitoring` - 🖥️ Production-grade monitoring: Disk/CPU/RAM/Load/Network
* `homelab-daily-report` - 📊 Daily Kubernetes homelab report with node status, pod health, PVC overview, restart counts and recent cluster events

---

# 📊 Quick Stats
Category | Script Name | Description | Status |
| :--- | :--- | :--- | :--- |
| **Monitoring** | server-monitoring | Disk/CPU/RAM/Load/Network + Discord alerts | 🟢 Production |
| **Monitoring** | ping-logger | Internet watchdog (8.8.8.8) + USB logging	 | 🟢 Production |
| **Utilities** | random-number-generator | Secure random numbers generator	 | 🟢 Production |
| **Automation** | auto-update | Auto apt updates + webhook notifications (dry-run check)	 | 🟢 Production |
| **Monitoring** | homelab-daily-report | Daily Kubernetes homelab report with node status, pod health, PVC overview, restart counts and recent cluster events	 | 🟡 IN PROGRESS |

---

# ⚙️ Requirements
- Linux system
- Bash (>= 4.x recommended)
- Optional:
  - `kubectl` (for Kubernetes scripts)
  - Internet access (for monitoring scripts)
  - Webhook endpoint (for alerts)

---

## ▶️ Usage
```bash
chmod +x script.sh
./script.sh
```
