#!/bin/bash
devicename="HHKB"

echo "Finding BT device *$devicename* ..."

# Ensure Bluetooth is not soft-blocked
rfkill unblock bluetooth
sleep 1

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
    # Already paired — just reconnect (retry up to 5 times)
    echo "Already paired, connecting..."
    for i in 1 2 3 4 5; do
        sudo bluetoothctl connect "$mac" && break
        echo "Retrying in 5 seconds... ($i/5)"
        sleep 5
    done
else
    # First-time pairing: HHKB-Hybrid requires passkey entry.
    # A 6-digit passkey will be displayed below — type it on the HHKB within 30 seconds.
    echo "Pairing... Type the displayed passkey on the HHKB within 30 seconds."
    {
        sleep 1
        echo "agent DisplayOnly"
        echo "default-agent"
        echo "pair $mac"
        sleep 30
        echo "trust $mac"
        echo "quit"
    } | sudo bluetoothctl

    # Connect in a separate invocation to avoid InProgress conflict
    sleep 2
    sudo bluetoothctl connect "$mac"
fi
