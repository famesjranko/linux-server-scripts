# Internet State RGB

Raspberry Pi with a WS281x RGB LED board (32 LEDs on GPIO18) that shows internet status as a colour:

| Colour | Meaning |
|--------|---------|
| Green  | Online |
| Yellow | Degraded: 1 failed check (transient blip) |
| Red    | Down: 2 or more consecutive failed checks |

It polls the captive-portal `generate_204` endpoints at Google and Cloudflare over plain
HTTP. Those responses are empty and tiny, and the first one that answers wins. It checks
every 10s while online and every 2s while degraded or down, so it reacts fast during an
outage without hammering the network when everything is fine.

## Install

```bash
sudo ./install.sh
# reboot if it reports that it changed dtparam=audio
```

That copies the two scripts to `/opt/internet-state-rgb`, installs the systemd unit,
turns off onboard audio (see the gotchas), and enables the service. To install somewhere
else, set the directory: `sudo INSTALL_DIR=/opt/irgb ./install.sh`.

## Files

- `simple_rgb_network_state.py`: the monitor loop (probe, debounce, LED colour)
- `clear_rgb.py`: blanks the LEDs, run by the service's `ExecStop`
- `internet-state-rgb.service`: systemd unit, runs as root with `Restart=always`

## Gotchas

Two things here are not obvious and both took a while to work out.

**`dtparam=audio=on` breaks the LEDs.** The Pi's onboard audio uses the same PWM0
peripheral as WS281x on GPIO18. It usually works from a clean boot, but if the process is
ever killed mid-write it wedges the DMA channel, and after that every LED write silently
does nothing: no error, no light. The fix is `dtparam=audio=off` in `config.txt` followed
by a reboot. The installer sets this for you.

**Very low brightness turns some colours off.** `LED_BRIGHTNESS` is set to `1` in
`simple_rgb_network_state.py`. The driver scales each channel by roughly brightness/255,
so any channel below 255 rounds down to zero. That is why `YELLOW` is `Color(255, 255, 0)`
rather than a real dim yellow: a yellow with sub-255 channels comes out as off at this
brightness. Raise `LED_BRIGHTNESS` and you can use whatever colours you want.

## Verify (fake WAN-down test)

Blackhole the two probe hosts in `/etc/hosts`. That drops "internet" for the monitor
without touching your real WAN or your SSH session. You should see green go to yellow, then
red, and back to green once you restore the file.

```bash
sudo cp /etc/hosts /etc/hosts.bak
printf '192.0.2.1 clients3.google.com\n192.0.2.1 cp.cloudflare.com\n' | sudo tee -a /etc/hosts
journalctl -u internet-state-rgb -f | grep "check failed"   # watch it fail, Ctrl-C when done
sudo cp /etc/hosts.bak /etc/hosts                            # restore, goes back to green
```

## Manage

```bash
systemctl status internet-state-rgb
sudo systemctl restart internet-state-rgb
journalctl -u internet-state-rgb -f
```
