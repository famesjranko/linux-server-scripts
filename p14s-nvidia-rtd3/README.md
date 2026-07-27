<div align="center">

# ThinkPad P14s NVIDIA T500 RTD3

Recovery scripts for keeping the NVIDIA T500 dGPU cool, quiet, and asleep when idle.

[![Laptop](https://img.shields.io/badge/ThinkPad-P14s-E00000?logo=lenovo&logoColor=white)](#thinkpad-p14s-nvidia-t500-rtd3)
[![GPU](https://img.shields.io/badge/NVIDIA-T500-76B900?logo=nvidia&logoColor=white)](#verify)
[![Debian](https://img.shields.io/badge/Debian-tested-A81D33?logo=debian&logoColor=white)](https://www.debian.org)
[![Shell](https://img.shields.io/badge/Shell-bash-4EAA25?logo=gnubash&logoColor=white)](#fresh-reinstall)

</div>

---

Tiny recovery kit for making the NVIDIA T500 runtime-suspend properly on this
ThinkPad P14s. When configured correctly, the dGPU drops into RTD3/D3cold while
idle and wakes automatically for PRIME, CUDA, or anything else that actually
needs it.

> [!NOTE]
> Use this after a fresh Linux reinstall or NVIDIA driver setup. If the current
> laptop already reports `Runtime D3 status: Enabled (fine-grained)`, there is
> nothing to fix.

---

## What This Does

| Script | Writes | Purpose |
|:-------|:-------|:--------|
| `nvidia-rtd3-setup.sh` | `/etc/modprobe.d/nvidia-modeset.conf` | Enables `nvidia-drm modeset=1`, required for RTD3. |
| `nvidia-rtd3-setup.sh` | `/etc/udev/rules.d/80-nvidia-pm.rules` | Sets NVIDIA PCI power control to `auto` when the driver binds. |
| `nvidia-rtd3-enable.sh` | `/etc/modprobe.d/nvidia-pm.conf` | Forces fine-grained RTD3 with `NVreg_DynamicPowerManagement=0x02`. |

Both scripts rebuild initramfs. Both are idempotent and safe to re-run.

---

## Fresh Reinstall

Install the NVIDIA driver first, then run the scripts in order:

```bash
./nvidia-rtd3-setup.sh
./nvidia-rtd3-enable.sh
```

Reboot when prompted, or manually:

```bash
sudo reboot
```

> [!IMPORTANT]
> Keep both scripts. `setup` handles the kernel/udev plumbing; `enable` handles
> the NVIDIA driver power-management mode.

---

## Verify

After reboot:

```bash
cat /sys/bus/pci/devices/0000:01:00.0/power/control
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
grep -i 'runtime d3' /proc/driver/nvidia/gpus/0000:01:00.0/power
```

Expected output:

```text
auto
suspended
Runtime D3 status: Enabled (fine-grained)
```

If `runtime_status` says `active`, close anything using the NVIDIA GPU and check
again after a few seconds.

---

## Files

| File | Use |
|:-----|:----|
| [`nvidia-rtd3-setup.sh`](nvidia-rtd3-setup.sh) | First-time RTD3 system setup. |
| [`nvidia-rtd3-enable.sh`](nvidia-rtd3-enable.sh) | NVIDIA fine-grained RTD3 driver option. |
| [`README.md`](README.md) | This recovery guide. |

## Recovery Checklist

1. Install Debian/Linux and the NVIDIA driver.
2. Clone or copy this folder onto the laptop.
3. Run `./nvidia-rtd3-setup.sh`.
4. Run `./nvidia-rtd3-enable.sh`.
5. Reboot.
6. Run the verification commands above.
