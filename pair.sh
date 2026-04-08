#!/bin/bash
devicename="HHKB"

echo "Finding BT device *$devicename* ..."

# Scan for 10 seconds using bluetoothctl (replaces deprecated hcitool scan)
sudo bluetoothctl --timeout 10 scan on > /dev/null 2>&1

found=$(sudo bluetoothctl devices | grep "$devicename")
if [ $? -eq 0 ]; then
    mac=$(echo "$found" | awk '{print $2}')
    echo "Found: $mac"
    {
        sleep 1                  # Wait for bluetoothctl DBus agent to initialize
        echo "agent NoInputNoOutput"
        echo "default-agent"
        echo "pair $mac"
        sleep 8                  # Wait for pairing to complete before connecting
        echo "trust $mac"
        echo "connect $mac"
        sleep 5                  # Wait for connection to establish
    } | sudo bluetoothctl
else
    echo "not found"
fi
