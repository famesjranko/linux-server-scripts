<div align="center">

# Linux Server Scripts

Personal recovery kits, monitoring scripts, and maintenance helpers for Linux servers, pfSense, Docker hosts, Raspberry Pi devices, and one ThinkPad.

[![Shell](https://img.shields.io/badge/Shell-bash-4EAA25?logo=gnubash&logoColor=white)](#scripts)
[![Docker](https://img.shields.io/badge/Docker-helpers-2496ED?logo=docker&logoColor=white)](#docker)
[![pfSense](https://img.shields.io/badge/pfSense-monitoring-212121)](#pfsense)
[![Debian](https://img.shields.io/badge/Debian-tested-A81D33?logo=debian&logoColor=white)](#system-logging)

</div>

---

This repo is a toolbox, not a single application. Most scripts were written for
specific machines and have hard-coded paths, service names, hostnames, or device
IDs. Read the top of a script and adjust those values before running it on a new
system.

> [!IMPORTANT]
> Several scripts stop Docker containers, restart services, edit `/etc`, copy
> certificates, or write to system log/database paths. Review before running with
> `sudo`.

---

## Quick Index

| Area | Path | Purpose |
|:-----|:-----|:--------|
| Backups | [`backup.sh`](backup.sh) | Simple rsync backup for the old `hp-prodesk` layout. |
| Backups | [`backup-full.sh`](backup-full.sh) | Interactive full-system rsync backup with package list and Docker stop/start. |
| Docker | [`docker/scripts/`](docker/scripts/) | Container restart/update helpers, Deluge extraction, Jellyfin fail2ban log sync. |
| Docker | [`container-update-script.sh`](container-update-script.sh) | Older menu-driven Docker container updater. |
| Network | [`hosts-online.sh`](hosts-online.sh) | LAN host discovery with known/unknown host reporting. |
| Network | [`net-test_readable.sh`](net-test_readable.sh) | Human-readable speedtest log entry writer. |
| Network | [`avg_speeds.sh`](avg_speeds.sh) | Average/high/low stats for speedtest logs. |
| Monitoring | [`stats.sh`](stats.sh) | Interactive status menu for fail2ban, systemd services, and nginx status. |
| System logging | [`sys_logs/`](sys_logs/) | Boot, network, and temperature logging with SQLite helpers. |
| pfSense | [`pfsense/`](pfsense/) | WAN and `dpinger` monitoring scripts for pfSense. |
| RabbitMQ | [`rabbitmq/cert-copy.sh`](rabbitmq/cert-copy.sh) | Copy renewed Let's Encrypt certs into RabbitMQ and restart the service. |
| Raspberry Pi | [`internet-state-rgb/`](internet-state-rgb/) | WS281x RGB internet-status indicator with installer and systemd unit. |
| ThinkPad | [`p14s-nvidia-rtd3/`](p14s-nvidia-rtd3/) | NVIDIA T500 RTD3 power-management recovery kit. |
| Fail2Ban | [`fail2ban_upstream_proxy_chain_setup_guide.md`](fail2ban_upstream_proxy_chain_setup_guide.md) | Guide for pushing fail2ban bans to an upstream proxy via iptables. |

---

## Scripts

### Backups

| File | Notes |
|:-----|:------|
| [`backup.sh`](backup.sh) | Stops Docker, writes a package list, rsyncs `/` to `/mnt/backup_usb/prodesk/`, then restarts stopped containers. |
| [`backup-full.sh`](backup-full.sh) | More interactive full-system backup flow with mount checks, package list, exclusions, and prompts. |

Both backup scripts are machine-specific. Check `/mnt/backup_usb`, excluded
paths, Docker assumptions, and usernames before use.

### Docker

| File | Notes |
|:-----|:------|
| [`docker/scripts/docker-restart.sh`](docker/scripts/docker-restart.sh) | Restarts only the containers that were running when the script started. |
| [`docker/scripts/docker-update.sh`](docker/scripts/docker-update.sh) | Large menu-driven Docker CLI updater for media/server containers. |
| [`docker/scripts/deluge_extraction_script.sh`](docker/scripts/deluge_extraction_script.sh) | Deluge Execute-plugin script for extracting `.zip` and `.rar` downloads. |
| [`docker/scripts/fail2ban_jellyfin_logs_test.sh`](docker/scripts/fail2ban_jellyfin_logs_test.sh) | Compares fail2ban Jellyfin watched logs with current Jellyfin logs and reloads if needed. |
| [`container-update-script.sh`](container-update-script.sh) | Older top-level Docker update menu for selected media containers. |

### Network

| File | Notes |
|:-----|:------|
| [`hosts-online.sh`](hosts-online.sh) | Scans configured CIDR ranges with `nmap` and labels discovered hosts as allowed or unknown. |
| [`net-test_readable.sh`](net-test_readable.sh) | Runs `speedtest` and prints date, latency, download, upload, and packet loss. |
| [`avg_speeds.sh`](avg_speeds.sh) | Reads speedtest logs and prints highest, lowest, and average download/upload/latency. |

### System Logging

| File | Notes |
|:-----|:------|
| [`sys_logs/boot_report.sh`](sys_logs/boot_report.sh) | Prints a boot timestamp for logging. |
| [`sys_logs/net_report.sh`](sys_logs/net_report.sh) | Runs `speedtest --csv` and stores results in `/home/sys_logs/logs/system.db`. |
| [`sys_logs/temp_report.sh`](sys_logs/temp_report.sh) | Logs local weather, CPU temp, and NVIDIA GPU temp to SQLite. |
| [`sys_logs/network_stat.sh`](sys_logs/network_stat.sh) | Summarizes logged network speed data, optionally by date range. |
| [`sys_logs/log_rotate.sh`](sys_logs/log_rotate.sh) | Rotates large log files under `logs/net`, `logs/temp`, and `logs/boot`. |
| [`temp2graph.sh`](temp2graph.sh) | Converts `temp.log` into `temp_graph.log` for spreadsheet graphing. |

### pfSense

| File | Notes |
|:-----|:------|
| [`pfsense/network-monitor.sh`](pfsense/network-monitor.sh) | Checks whether a configured WAN interface has an IP and reports down/restored state. |
| [`pfsense/dpinger-monitor.sh`](pfsense/dpinger-monitor.sh) | Checks pfSense `dpinger` and attempts restart if it is down. |

### Recovery Kits

| Path | Notes |
|:-----|:------|
| [`internet-state-rgb/`](internet-state-rgb/) | Raspberry Pi WS281x internet status light. Includes installer, systemd unit, monitor script, and README. |
| [`p14s-nvidia-rtd3/`](p14s-nvidia-rtd3/) | ThinkPad P14s NVIDIA T500 runtime power-management setup. Includes scripts and verification guide. |

### Other

| File | Notes |
|:-----|:------|
| [`rabbitmq/cert-copy.sh`](rabbitmq/cert-copy.sh) | Copies updated certbot certificates to RabbitMQ cert paths and restarts RabbitMQ. |
| [`fail2ban_upstream_proxy_chain_setup_guide.md`](fail2ban_upstream_proxy_chain_setup_guide.md) | Notes for fail2ban upstream proxy-chain setup. |
| [`batch/`](batch/) | Empty Windows batch placeholders. |

---

## Common Dependencies

Not every script needs every tool, but the repo expects a mix of:

```text
bash, rsync, docker, nmap, speedtest, sqlite3, curl, lm-sensors, nvidia-smi,
fail2ban-client, systemctl, pfSsh.php, certbot/Let's Encrypt paths
```

Install only what the script you are running needs.

## Usage Pattern

```bash
chmod +x script.sh
./script.sh
```

For system scripts:

```bash
sudo ./script.sh
```

Read hard-coded variables first. The important ones are usually near the top of
each file.
