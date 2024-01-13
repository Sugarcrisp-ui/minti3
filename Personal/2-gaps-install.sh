# Install necessary packages
sudo apt-get update
sudo apt-get install -y \
    git \
    libxcb1 \
    libxcb-keysyms1 \
    libpango1.0-0 \
    libxcb-util0 \
    libxcb-icccm4 \
    libyajl2 \
    libstartup-notification0 \
    libxcb-randr0 \
    libev4 \
    libxcb-cursor0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libxkbcommon0 \
    libxcb-shape0

# Clone i3-gaps repository
git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps

# Build and install i3-gaps
mkdir -p build && cd build
meson ..
sudo ninja install

# Clone autotiling repository
cd ~
git clone https://github.com/nwg-piotr/autotiling.git
cd autotiling

# Install autotiling
sudo python3 setup.py install

# Cleanup
cd ~
rm -rf i3-gaps autotiling

# Create a custom LightDM configuration for i3
sudo tee /etc/lightdm/lightdm.conf <<EOL
[SeatDefaults]
user-session=i3
EOL

# Create a custom Xsession file for i3
sudo tee /usr/share/xsessions/i3.desktop <<EOL
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=i3
TryExec=i3
Type=Application
X-LightDM-DesktopName=i3
EOL

# Add execution permissions to the script
chmod +x i3-gaps-install.sh
