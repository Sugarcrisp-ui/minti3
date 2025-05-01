#!/bin/bash
# setup-grok.sh
# Sets up Grok to run in a non-VPN namespace on Linux Mint with i3
# Location: /home/brett/minti3/scripts/setup-grok.sh

set -e

# Variables
USER="brett"
NAMESPACE="non_vpn"
VETH_HOST_IP="10.0.0.1"
VETH_NON_VPN_IP="10.0.0.2"
# Dynamically detect gateway and interface
GATEWAY_IP=$(ip route | grep default | awk '{print $3}')
PHYSICAL_IFACE=$(ip route | grep default | awk '{print $5}')
GROK_DESKTOP_FILE="/home/$USER/.local/share/applications/grok.desktop"
GROK_SCRIPT="/home/$USER/.bin-personal/grok-launch.sh"
SUDOERS_FILE="/etc/sudoers.d/grok-namespace"

# Validate detected values
if [ -z "$GATEWAY_IP" ] || [ -z "$PHYSICAL_IFACE" ]; then
    echo "Error: Could not detect gateway or interface. Ensure network is connected."
    exit 1
fi
echo "Detected GATEWAY_IP=$GATEWAY_IP, PHYSICAL_IFACE=$PHYSICAL_IFACE"

# Step 1: Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y brave-browser iproute2

# Step 2: Create non_vpn namespace
echo "Setting up $NAMESPACE namespace..."
sudo ip netns add $NAMESPACE || echo "Namespace $NAMESPACE already exists"

# Step 3: Configure virtual Ethernet pair
echo "Configuring virtual Ethernet pair..."
sudo ip link add veth-non-vpn type veth peer name veth-host
sudo ip link set veth-non-vpn netns $NAMESPACE
sudo ip addr add $VETH_HOST_IP/24 dev veth-host
sudo ip netns exec $NAMESPACE ip addr add $VETH_NON_VPN_IP/24 dev veth-non-vpn
sudo ip link set veth-host up
sudo ip netns exec $NAMESPACE ip link set veth-non-vpn up
sudo ip netns exec $NAMESPACE ip link set lo up

# Step 4: Configure routing
echo "Configuring routing..."
sudo ip route add 10.0.0.0/24 dev veth-host || echo "Route already exists"
sudo ip netns exec $NAMESPACE ip route add default via $VETH_HOST_IP dev veth-non-vpn
echo "200 non_vpn_table" | sudo tee -a /etc/iproute2/rt_tables
sudo ip route add default via $GATEWAY_IP dev $PHYSICAL_IFACE table non_vpn_table
sudo ip rule add from 10.0.0.0/24 lookup non_vpn_table

# Step 5: Set up iptables
echo "Setting up iptables..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -A FORWARD -i veth-host -o $PHYSICAL_IFACE -j ACCEPT
sudo iptables -
