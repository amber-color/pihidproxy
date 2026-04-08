# pihidproxy
Bridge Bluetooth keyboard and mouse to USB (hid proxy)

![Imgur](https://i.imgur.com/cpGkjXw.png)

If you have a bluetooth keyboard, you can't access BIOS or OS without a BT stack.
This project acts as a bridge so the PC only sees a USB keyboard and so works without drivers.
It works by copying keypresses from the bluetooth keyboard to the piZero's USB.

Requirements:

Raspberry Pi Zero
Bluetooth keyboard

Initial setup:

**1. Enable USB OTG (dwc2)**

    # Raspberry Pi OS Bookworm:
    echo "dtoverlay=dwc2" | sudo tee -a /boot/firmware/config.txt
    # Older OS (Bullseye and earlier):
    # echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt

    echo "dwc2" | sudo tee -a /etc/modules
    echo "libcomposite" | sudo tee -a /etc/modules

**2. Install Python dependency**

    sudo apt install python3-evdev

**3. Pair the Bluetooth keyboard (one-time)**

    sudo bash pair.sh

A 6-digit passkey will be displayed — type it on the keyboard within 30 seconds.

**4. Install and enable the systemd service**

Run from the cloned repository directory:

    sed "s|REPODIR|$(pwd)|" pihidproxy.service | sudo tee /etc/systemd/system/pihidproxy.service
    sudo systemctl daemon-reload
    sudo systemctl enable pihidproxy.service

**5. Reboot**

    sudo reboot

After reboot, connecting the Pi's USB data port to a PC will start everything automatically.
The PC will see a USB keyboard, and keypresses from the Bluetooth keyboard will be forwarded.

---

pair.sh - pairs & connects the Bluetooth keyboard on boot.

setuphid.sh - sets up the USB HID gadget (keyboard + mouse).

keys.py - reads keyboard events and forwards them over USB HID.


