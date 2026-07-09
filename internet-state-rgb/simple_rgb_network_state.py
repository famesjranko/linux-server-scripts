import time
import urllib.request
from rpi_ws281x import PixelStrip, Color

# LED configuration
LED_COUNT = 32          # Number of LEDs in matrix
LED_PIN = 18            # GPIO pin connected to the LEDs
LED_FREQ_HZ = 800000    # LED signal frequency in hertz
LED_DMA = 10            # DMA channel to use for generating signal
LED_BRIGHTNESS = 1      # LED brightness (0-255); kept very low on purpose, see README
LED_INVERT = False      # True to invert the signal
LED_CHANNEL = 0         # PWM channel used (0 or 1)

# Connectivity check config
INTERVAL_UP = 10        # Seconds between checks while online (poll lazily when healthy)
INTERVAL_DOWN = 2       # Seconds between checks while degraded/down (catch recovery fast)
PROBE_TIMEOUT = 1.5     # Per-URL timeout; two of these keeps the down-path under ~3s
FAILURES_BEFORE_RED = 2 # Consecutive failures before showing DOWN (red)
# Captive-portal check URLs: return an empty HTTP 204, tiny and fast. Try in order, first hit wins.
CHECK_URLS = [
    "http://clients3.google.com/generate_204",  # Google
    "http://cp.cloudflare.com/",                # Cloudflare
]

GREEN = Color(0, 255, 0)
YELLOW = Color(255, 255, 0)  # full channels so it survives low LED_BRIGHTNESS (sub-255 rounds to off)
RED = Color(255, 0, 0)
OFF = Color(0, 0, 0)

strip = PixelStrip(LED_COUNT, LED_PIN, LED_FREQ_HZ, LED_DMA, LED_INVERT, LED_BRIGHTNESS, LED_CHANNEL)
strip.begin()


def set_strip_color(color):
    for i in range(strip.numPixels()):
        strip.setPixelColor(i, color)
    strip.show()


def is_internet_up():
    for url in CHECK_URLS:
        try:
            with urllib.request.urlopen(url, timeout=PROBE_TIMEOUT) as r:
                if r.status in (200, 204):
                    return True
        except Exception:
            continue
    return False


def main():
    print("Starting internet monitoring and RGB control...")
    # SIGTERM (systemd stop) exits the process by default; ExecStop=clear_rgb.py clears the LEDs.
    # KeyboardInterrupt below handles manual Ctrl+C runs.
    failures = 0
    current = None
    try:
        while True:
            if is_internet_up():
                failures = 0
                color = GREEN
            else:
                failures += 1
                color = RED if failures >= FAILURES_BEFORE_RED else YELLOW
                print(f"{time.strftime('%Y-%m-%d %H:%M:%S')}: check failed ({failures})")

            if color != current:  # only repaint on state change
                set_strip_color(color)
                current = color
            time.sleep(INTERVAL_UP if color == GREEN else INTERVAL_DOWN)
    except KeyboardInterrupt:
        print("Exiting...")
        set_strip_color(OFF)


if __name__ == "__main__":
    main()
