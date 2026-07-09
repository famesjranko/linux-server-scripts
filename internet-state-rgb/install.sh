#!/usr/bin/env bash
# Install the Internet State RGB monitor as a systemd service.
# Usage:  sudo ./install.sh            # installs to /opt/internet-state-rgb
#         sudo INSTALL_DIR=/opt/irgb ./install.sh   # custom location
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/internet-state-rgb}"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ $EUID -ne 0 ]]; then echo "run with sudo"; exit 1; fi

# 1. Dependency: rpi_ws281x (PEP668 systems need the override flag)
if ! python3 -c "import rpi_ws281x" 2>/dev/null; then
    command -v pip3 >/dev/null || apt-get install -y python3-pip
    pip3 install rpi_ws281x --break-system-packages
fi

# 2. Copy scripts
install -d "$INSTALL_DIR"
install -m755 "$SRC_DIR/simple_rgb_network_state.py" "$INSTALL_DIR/"
install -m755 "$SRC_DIR/clear_rgb.py"                "$INSTALL_DIR/"

# 3. Install the unit, rewriting paths if INSTALL_DIR was overridden
sed "s#/opt/internet-state-rgb#${INSTALL_DIR}#g" \
    "$SRC_DIR/internet-state-rgb.service" > /etc/systemd/system/internet-state-rgb.service

# 4. Free the PWM peripheral from onboard audio (GPIO18 conflict). Needs a reboot to apply.
CFG=/boot/firmware/config.txt; [[ -f $CFG ]] || CFG=/boot/config.txt
if grep -q '^dtparam=audio=on' "$CFG"; then
    sed -i 's/^dtparam=audio=on/dtparam=audio=off/' "$CFG"
    echo "!! set dtparam=audio=off in $CFG, REBOOT required for the LEDs to work reliably"
fi

# 5. Enable + start
systemctl daemon-reload
systemctl enable --now internet-state-rgb
echo "done: $(systemctl is-active internet-state-rgb). If audio was just disabled, reboot now."
