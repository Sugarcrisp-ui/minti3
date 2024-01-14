# Install necessary packages
sudo apt-get update
sudo apt-get install -y \
    git \
    libxcb1 \
    libxcb-keysyms1 \
    libpango1.0-0 \
    libxcb-util1 \
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
    libxcb-shape0 \
    meson \
    ninja-build \
    python3-setuptools \
    python3-pip

# Install autotiling dependencies
sudo apt-get install -y \
    libxcb-randr0-dev \
    libxcb-xinerama0-dev \
    libxcb-xtest0-dev \
    libxcb-shape0-dev

# Clone autotiling repository
cd ~
git clone https://github.com/nwg-piotr/autotiling.git
cd autotiling

# Install autotiling
sudo python3 setup.py install

# Cleanup
cd ~
sudo rm -rf i3-gaps autotiling

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

