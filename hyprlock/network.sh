#!/bin/bash

# Read the wifi-mode alias from hyprlock.conf
show_ssid=$(grep -oP '^\$wifi-mode\s*=\s*\K\S+' ~/.config/hypr/hyprlock.conf)


# Check if the Wi-Fi mode alias was successfully extracted
if [ -z "$show_ssid" ]; then
    echo "Wi-Fi mode not found in hyprlock.conf."
    exit 1
fi

# Get the Wi-Fi interface
wifi_interface=$(iw dev | awk '/Interface/ {print $2; exit}')

# Check if Wi-Fi interface exists
if [ -z "$wifi_interface" ]; then
    echo "󰤮  No Wi-Fi Interface"
    exit 0
fi

# Check if Wi-Fi is connected and get SSID
ssid=$(iwgetid -r)

# If not connected, show "No Wi-Fi"
if [ -z "$ssid" ]; then
    echo "󰤮  No Wi-Fi"
    exit 0
fi

# Get signal strength from /proc/net/wireless
signal_strength=$(awk -v iface="$wifi_interface" '$1 ~ iface ":" {print int($3 * 100 / 70)}' /proc/net/wireless)

# Define Wi-Fi icons based on signal strength
wifi_icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨") # From low to high signal

# Ensure signal_strength is within bounds (0 to 100)
signal_strength=$((signal_strength < 0 ? 0 : (signal_strength > 100 ? 100 : signal_strength)))

# Calculate the icon index based on signal strength (0–100 -> 0–4)
icon_index=$((signal_strength / 25))

# Get the corresponding icon
wifi_icon=${wifi_icons[$icon_index]}

# Output based on show_ssid variable
if [ "$show_ssid" = true ]; then
    # Show SSID
    echo "$wifi_icon $ssid"
else
    # Show "Connected"
    echo "$wifi_icon Connected"
fi
