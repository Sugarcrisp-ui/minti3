#!/bin/bash
# The set command is used to determine action if an error
# is encountered.  (-e) will stop and exit (+e) will
# continue with the script.
set -e

###############################################################################
#
#   DECLARATION OF FUNCTIONS
#
###############################################################################

func_install() {
    if dpkg -l | grep -q $1; then
        tput setaf 2
        echo "###############################################################################"
        echo "################## The package "$1" is already installed"
        echo "###############################################################################"
        echo
        tput sgr0
    else
        tput setaf 3
        echo "###############################################################################"
        echo "##################  Installing package "  $1
        echo "###############################################################################"
        echo
        tput sgr0
        sudo apt install -y $1
    fi
}

###############################################################################
echo "Installing display manager"
###############################################################################

list=(
    sddm
    # lightdm
)

count=0

for name in "${list[@]}" ; do
    count=$((count+1))
    tput setaf 3;echo "Installing package nr.  "$count " " $name;tput sgr0;
    func_install $name
done

###############################################################################

tput setaf 6;echo "################################################################"
echo "Make a backup of the .config"
echo "################################################################"
echo;tput sgr0

cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H.%M.%S)

tput setaf 5;echo "################################################################"
echo "Enabling the display manager"
echo "################################################################"
echo;tput sgr0

# Modify the display manager service name for Debian-based systems
sudo systemctl enable sddm.service -f
# Uncomment the following line if using lightdm
# sudo systemctl enable lightdm.service -f

tput setaf 11;
echo "################################################################"
echo "Reboot your system"
echo "################################################################"
echo;tput sgr0
