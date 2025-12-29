# Linux Mint i3 Installation Follow-up Notes

Here's a complete list of post-install issues encountered on Linux Mint i3, along with the exact fixes and terminal commands used to resolve them.

### 1. External Drive Auto-Mounting
**Issue**: External backup drives not auto-mounting on boot.  
**Fix**: Added fstab entries with proper UUIDs.  
**Commands**:
```bash
# Identify UUIDs
lsblk -o NAME,SIZE,FSTYPE,UUID,MOUNTPOINT

# Create mount points
sudo mkdir -p /media/brett/backup
sudo mkdir -p /media/brett/backup2

# Backup fstab
sudo cp /etc/fstab /etc/fstab.bak

# Add entries (update UUIDs as needed)
sudo bash -c 'cat >> /etc/fstab << EOF
# External backup drives
UUID=96a06646-562f-45f2-923b-c0ae48cabac4 /media/brett/backup ext4 defaults 0 2
UUID=7f948861-5f2c-4251-8647-cb870e41f471 /media/brett/backup2 ext4 defaults 0 2
EOF'

# Test and apply
sudo mount -a
sudo systemctl daemon-reload
```

### 2. Display Manager and Bluetooth Manager
**Issue**: SDDM not set as display manager; Blueman missing.  
**Fix**: Installed and configured SDDM + Blueman.  
**Commands**:
```bash
sudo apt install sddm blueman
sudo dpkg-reconfigure sddm  # Select SDDM
```

### 3. Timeshift Not Launching
**Issue**: Timeshift (and other apps) failed to launch due to missing polkit agent.  
**Fix**: Resolved by installing GNOME PolicyKit agent (see #7).

### 4. Audio System (Pipewire → PulseAudio)
**Issue**: Audio problems with Pipewire.  
**Fix**: Switched to PulseAudio.  
**Commands**:
```bash
sudo apt remove pipewire pipewire-bin pipewire-pulse
sudo apt install pulseaudio pulseaudio-utils
sudo apt autoremove
# Reboot required
```

### 5. Device Managers (Solaar, Tailscale, Syncthing)
**Issue**: Missing device/sync tools.  
**Fix**: Installed each with repositories where needed.  
**Commands**:
```bash
# Solaar
sudo apt install solaar

# Tailscale
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt update
sudo apt install tailscale
sudo tailscale up  # Authenticate

# Syncthing
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt update
sudo apt install syncthing
```

### 6. Terminal Editor (msedit → Fresh)
**Issue**: Preferred a better terminal-based editor.  
**Fix**: Installed Fresh editor.  
**Commands**:
```bash
DEB_URL=$(curl -s https://api.github.com/repos/sinelaw/fresh/releases/latest | grep "browser_download_url.*_$(dpkg --print-architecture)\.deb" | cut -d '"' -f 4)
curl -L -o fresh-editor.deb "$DEB_URL"
sudo dpkg -i fresh-editor.deb
sudo apt install -f
rm fresh-editor.deb
```

### 7. PolicyKit Authentication Agent
**Issue**: Privilege prompts (gufw, Timeshift, etc.) failed.  
**Fix**: Installed GNOME polkit agent and auto-started it.  
**Commands**:
```bash
sudo apt install policykit-1-gnome

# Add to ~/.config/i3/config
exec --no-startup-id /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
```
Reload i3: `Mod+Shift+R`

### 8. Tailscale Video Server Access
**Issue**: Needed secure remote access to video folder.  
**Fix**: Enabled Tailscale serve.  
**Commands**:
```bash
sudo tailscale serve --bg --https=443 /home/brett/Videos/youtube-videos

# Add to ~/.config/i3/config (auto-start on desktop)
exec --no-startup-id [ "$(hostname)" = "brett-MS-7D82" ] && sudo tailscale serve --bg --https=443 /home/brett/Videos/youtube-videos
```
Access URL: https://brett-ms-7d82.tail256c78.ts.net/

### 9. Calibre Web Content Server
**Issue**: No remote library access.  
**Fix**: Installed Calibre and started content server.  
**Commands**:
```bash
sudo apt install calibre
calibre-server /path/to/library  # Run manually or add to startup
```

### 10. i3-logout Script Not Working
**Issue**: Logout menu not functioning.  
**Fix**: Corrected path and permissions.  
**Commands**:
```bash
chmod +x ~/github-repos/i3-logout/i3-logout.py

# Add/correct in ~/.config/i3/config
bindsym $mod+Shift+e exec python3 ~/github-repos/i3-logout/i3-logout.py
```
Reload i3: `Mod+Shift+R`

### 11. Thunar Dark Theme
**Issue**: Thunar not following dark theme.  
**Fix**: Installed Dracula theme.  
**Commands**:
```bash
sudo apt install dracula-theme
# Select in Appearance settings if needed
```

### 12. Dotfiles Symlinks and Autotiling
**Issue**: Dotfiles not linked; autotiling not starting.  
**Fix**: Ran symlink script and added autotiling to config.  
**Commands**:
```bash
~/dotfiles/create-symlinks.sh  # Your symlink command

# Add to ~/.config/i3/config
exec --no-startup-id autotiling
```

### 13. ProtonVPN GUI and Tray Support
**Issue**: No GUI VPN with tray icon in i3.  
**Fix**: Installed official ProtonVPN GNOME app + tray support.  
**Commands**:
```bash
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
echo "0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180 protonvpn-stable-release_1.0.8_all.deb" | sha256sum --check -
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
sudo apt install proton-vpn-gnome-desktop
sudo apt install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator
```
Launch: `protonvpn`