# minti3: Linux Mint i3 Setup Automation

## Overview
Modular scripts for installing/configuring i3 on Linux Mint, including apps, themes, and backups.

## Recent Changes (Oct 2025)
- Portability: Dynamic `$USER_HOME` paths, remove hardcodes (e.g., "brett", hostnames).
- Lean installs: `--no-install-recommends` in apt.
- Automation: Integrate `automount-external-luks.sh` (no-reboot mode).
- Removals: Arch refs, grok-split-tunnel (ProtonVPN native).
- Fixes: Network IPv6 dynamic iface detection.
- Backup handling: Auto-select most recent /media/$USER/backup/daily/daily.X/backup.latest.

## Prereqs
- Fresh Linux Mint install.
- Run `sudo automount-external-luks.sh` (mounts /media/$USER/backup).
- GitHub repos accessible.

## Usage
1. Clone: `git clone https://github.com/Sugarcrisp-ui/minti3.git ~/github-repos/minti3`
2. Run: `cd ~/github-repos/minti3 && ./install.sh [/media/custom/backup/backup.latest]`
3. Reboot.

## Scripts
- install.sh: Orchestrates all.
- See /scripts for details.

## Notes
- Logs: ~/log-files/*
- Test on VM first.
