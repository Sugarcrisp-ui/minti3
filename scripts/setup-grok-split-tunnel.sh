#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
NAMESPACE="non_vpn"
VETH_HOST_IP="10.0.0.1"
VETH_NON_VPN_IP="10.0.0.2"
GATEWAY_IP=$(ip route | grep default | awk '{print $3}')
PHYSICAL_IFACE=$(ip route | grep default | awk '{print $5}')
GROK_DESKTOP_FILE="$HOME/.local/share/applications/grok.desktop"
GROK_SCRIPT="$HOME/.bin-personal/grok-launch.sh"
SUDOERS_FILE="/etc/sudoers.d/grok-namespace"
OUTPUT_FILE="$USER_HOME/log-files/setup-grok-split-tunnel/setup-grok-split-tunnel-output.txt"

# Redirect output to file
mkdir -p ~/log-files/setup-grok-split-tunnel
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Validate detected values
if [ -z "$GATEWAY_IP" ] || [ -z "$PHYSICAL_IFACE" ]; then
    echo "Warning: Could not detect gateway or interface. Network setup may fail."
else
    echo "Detected GATEWAY_IP=$GATEWAY_IP, PHYSICAL_IFACE=$PHYSICAL_IFACE"
fi

# Install dependencies
echo "Installing dependencies..."
sudo apt update
packages=(brave-browser iproute2)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Create non_vpn namespace
echo "Setting up $NAMESPACE namespace..."
sudo ip netns add $NAMESPACE 2>/dev/null || echo "Namespace $NAMESPACE already exists"

# Configure virtual Ethernet pair
echo "Configuring virtual Ethernet pair..."
sudo ip link add veth-non-vpn type veth peer name veth-host 2>/dev/null || echo "Virtual Ethernet pair already exists"
sudo ip link set veth-non-vpn netns $NAMESPACE 2>/dev/null || echo "veth-non-vpn already in namespace"
sudo ip addr add $VETH_HOST_IP/24 dev veth-host 2>/dev/null || echo "veth-host IP already set"
sudo ip netns exec $NAMESPACE ip addr add $VETH_NON_VPN_IP/24 dev veth-non-vpn 2>/dev/null || echo "veth-non-vpn IP already set"
sudo ip link set veth-host up 2>/dev/null || echo "veth-host already up"
sudo ip netns exec $NAMESPACE ip link set veth-non-vpn up 2>/dev/null || echo "veth-non-vpn already up"
sudo ip netns exec $NAMESPACE ip link set lo up 2>/dev/null || echo "Loopback already up"

# Configure routing
echo "Configuring routing..."
sudo ip route add 10.0.0.0/24 dev veth-host 2>/dev/null || echo "Route already exists"
sudo ip netns exec $NAMESPACE ip route add default via $VETH_HOST_IP dev veth-non-vpn 2>/dev/null || echo "Default route already set"
echo "200 non_vpn_table" | sudo tee -a /etc/iproute2/rt_tables >/dev/null 2>&1 || echo "Routing table already defined"
sudo ip route add default via $GATEWAY_IP dev $PHYSICAL_IFACE table non_vpn_table 2>/dev/null || echo "Table route already set"
sudo ip rule add from 10.0.0.0/24 lookup non_vpn_table 2>/dev/null || echo "Routing rule already set"

# Set up iptables
echo "Setting up iptables..."
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1 || echo "Warning: Failed to enable IP forwarding"
sudo iptables -A FORWARD -i veth-host -o $PHYSICAL_IFACE -j ACCEPT 2>/dev/null || echo "Forward rule already set"
sudo iptables -A FORWARD -i $PHYSICAL_IFACE -o veth-host -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || echo "Return rule already set"
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o $PHYSICAL_IFACE -j MASQUERADE 2>/dev/null || echo "NAT rule already set"

# Create grok-launch.sh
echo "Creating $GROK_SCRIPT..."
mkdir -p "$HOME/.bin-personal"
cat << EOF | tee "$GROK_SCRIPT"
#!/bin/bash
ip netns exec $NAMESPACE brave --app=https://grok.x.ai
EOF
chmod +x "$GROK_SCRIPT"

# Create grok.desktop
echo "Creating $GROK_DESKTOP_FILE..."
mkdir -p "$(dirname "$GROK_DESKTOP_FILE")"
cat << EOF | tee "$GROK_DESKTOP_FILE"
[Desktop Entry]
Name=Grok
Exec=$GROK_SCRIPT
Type=Application
Terminal=false
Icon=brave-browser
Categories=Network;WebBrowser;
EOF

# Configure sudoers for namespace execution
echo "Configuring sudoers..."
echo "$USER ALL=(root) NOPASSWD: /sbin/ip netns exec $NAMESPACE *" | sudo tee "$SUDOERS_FILE" >/dev/null
sudo chmod 440 "$SUDOERS_FILE"

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Network namespace functionality may be restricted."
fi

echo "Grok split tunnel setup complete."
