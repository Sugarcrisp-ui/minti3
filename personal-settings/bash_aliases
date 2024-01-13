# PATH setting
export PATH="$PATH:/opt/someApp/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/.bin-personal"

# Default editor
export EDITOR='micro'
export VISUAL='micro'

# System update
alias update='sudo apt update && sudo apt upgrade && flatpak update'

# ExpressVPN
alias es='expressvpn status'
alias dis='expressvpn disconnect'

function evpn() {
    expressvpn disconnect
    expressvpn connect $1
}

alias vn='evpn vn' # Vietnam
alias gu='evpn gu' # Guam
alias to='evpn cato' # Toronto
alias hk1='evpn hk1' # Hong Kong 1
alias sg='evpn sgju' # Singapore - Jurong
alias jp='evpn jpto' # Japan - Tokyo
alias lon='evpn uklo' # London
alias la='evpn usla1' # Los Angeles 1
alias sf='evpn ussf' # San Fransisco
alias ko='evpn kr2' # South Korea 2
alias ny='evpn usny' # New York 
alias xv='evpn xv' # Pick for Me
# Add other ExpressVPN aliases here

# Micro editor
alias mbp='micro ~/.bashrc-personal'

# Bash
alias bashup='source ~/.bashrc'

# Python
alias transfer='python /home/brett/.bin-personal/transfer.py'
alias backup='python ~/.bin-personal/file-backup-with-time.py'

# Configuration backup
alias topersonal='sudo /home/brett/.bin-personal/config-backup-to-personal.sh'
alias togithub='config-backup-github.sh'
alias toexternal='config-backup-to-external.sh'

# System information
alias sysinfo='inxi -Fxxxrz'

# Bluetooth
alias blue='bluetoothctl'
