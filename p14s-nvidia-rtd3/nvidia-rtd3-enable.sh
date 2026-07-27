#!/usr/bin/env bash
# Force fine-grained RTD3 power management on the NVIDIA T500.
# Everything else is already in place; the driver just left power management at
# its "decide -> off" default (DynamicPowerManagement=3, shows "Disabled by
# default"). This pins it to 0x02 so the GPU suspends to D3cold when idle.
# Idempotent. Reboot required at the end.
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Elevating with sudo..."; exec sudo bash "$0" "$@"; fi

CONF=/etc/modprobe.d/nvidia-pm.conf
echo 'options nvidia NVreg_DynamicPowerManagement=0x02' > "$CONF"
echo "wrote $CONF"

echo "Rebuilding initramfs (may take a minute)..."
update-initramfs -u

echo
echo "Done. Reboot, then verify (no sudo needed):"
echo "  grep -i 'runtime d3' /proc/driver/nvidia/gpus/0000:01:00.0/power   # want: Enabled (fine-grained)"
echo "  cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status         # want: suspended"
echo
read -r -p "Reboot now? [y/N] " ans
case "${ans:-}" in
  [yY]*) echo "Rebooting..."; reboot ;;
  *)     echo "Skipped. Run 'sudo reboot' when ready." ;;
esac
