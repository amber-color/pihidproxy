#!/bin/bash
devicename="HHKB"

echo "Finding BT device *$devicename* ..."

# Scan for 10 seconds using bluetoothctl (replaces deprecated hcitool scan)
sudo bluetoothctl --timeout 10 scan on > /dev/null 2>&1

found=$(sudo bluetoothctl devices | grep "$devicename")
if [ $? -ne 0 ]; then
    echo "not found"
    exit 1
fi

mac=$(echo "$found" | awk '{print $2}')
echo "Found: $mac"

if sudo bluetoothctl info "$mac" | grep -q "Paired: yes"; then
    # Already paired — just trust and connect
    echo "Already paired, connecting..."
    sudo bluetoothctl trust "$mac"
    sudo bluetoothctl connect "$mac"
else
    # First time pairing
    echo "Pairing..."
    {
        sleep 1
        echo "agent NoInputNoOutput"
        echo "default-agent"
        echo "pair $mac"
        sleep 15
        echo "trust $mac"
        echo "connect $mac"
        sleep 5
    } | sudo bluetoothctl
fi
