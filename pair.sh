#!/bin/bash
devicename="NexDock"

echo "Finding BT device *$devicename* ..."

# Scan for 10 seconds using bluetoothctl (replaces deprecated hcitool scan)
sudo bluetoothctl --timeout 10 scan on > /dev/null 2>&1

found=$(sudo bluetoothctl devices | grep "$devicename")
if [ $? -eq 0 ]; then
    mac=$(echo "$found" | awk '{print $2}')
    echo "Found: $mac"
    printf "default-agent\nagent on\npair %s\ntrust %s\nconnect %s\n" \
        "$mac" "$mac" "$mac" | sudo bluetoothctl
else
    echo "not found"
fi
