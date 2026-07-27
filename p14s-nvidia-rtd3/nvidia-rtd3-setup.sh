#!/usr/bin/env bash
# Configure the NVIDIA T500 dGPU for RTD3 runtime power-off.
# Fixes the idle heat / loud fan: the GPU sleeps (D3cold, ~0 W) when nothing
# uses it, and wakes automatically on demand (prime-run, CUDA, etc.).
# Idempotent — safe to re-run. A reboot is required at the end.
set -euo pipefail

# Re-run under sudo if not already root.
if [ "$(id -u)" -ne 0 ]; then
  echo "Elevating with sudo..."
  exec sudo bash "$0" "$@"
fi

GPU=0000:01:00.0
MODESET=/etc/modprobe.d/nvidia-modeset.conf
UDEV=/etc/udev/rules.d/80-nvidia-pm.rules

echo "==> 1/3  Enabling nvidia-drm modeset (RTD3 prerequisite)"
echo 'options nvidia-drm modeset=1' > "$MODESET"
echo "         wrote $MODESET"

echo "==> 2/3  Installing runtime-PM udev rule"
cat > "$UDEV" <<'EOF'
# Let the NVIDIA dGPU runtime-suspend (RTD3/D3cold) when idle; wakes on demand.
ACTION=="bind",   SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="bind",   SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
ACTION=="unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", DRIVERS=="nvidia", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF
echo "         wrote $UDEV"

echo "==> 3/3  Rebuilding initramfs (bakes in the modeset option — may take a minute)"
update-initramfs -u
udevadm control --reload-rules || true

echo
echo "Done. Reboot, then verify with (no sudo needed):"
echo "  cat /sys/bus/pci/devices/$GPU/power/runtime_status       # want: suspended"
echo "  grep -i 'runtime d3' /proc/driver/nvidia/gpus/$GPU/power  # want: Enabled (fine-grained)"
echo
read -r -p "Reboot now? [y/N] " ans
case "${ans:-}" in
  [yY]*) echo "Rebooting..."; reboot ;;
  *)     echo "Skipped. Run 'sudo reboot' when you're ready." ;;
esac
