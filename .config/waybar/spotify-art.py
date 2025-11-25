#!/usr/bin/env python3
import subprocess
import json
import os
import urllib.request
import hashlib
import time

CACHE_DIR = os.path.expanduser("~/.cache/waybar/albumart")
CSS_FILE = os.path.expanduser("~/.config/waybar/spotify-albumart.css")
STATE_FILE = os.path.expanduser("~/.cache/waybar/spotify-current.txt")
LOG_FILE = os.path.expanduser("~/.cache/waybar/spotify-art.log")
os.makedirs(CACHE_DIR, exist_ok=True)

def log(message):
    """Write log message to file"""
    import datetime
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, 'a') as f:
        f.write(f"[{timestamp}] {message}\n")

def get_album_art():
    try:
        art_url = subprocess.run(
            ["playerctl", "-p", "spotify", "metadata", "mpris:artUrl"],
            capture_output=True,
            text=True,
            timeout=2
        ).stdout.strip()

        if not art_url:
            return None

        url_hash = hashlib.md5(art_url.encode()).hexdigest()
        cache_file = os.path.join(CACHE_DIR, f"{url_hash}.jpg")

        if not os.path.exists(cache_file):
            log(f"Downloading: {art_url[:50]}...")
            if art_url.startswith("file://"):
                import shutil
                local_path = art_url.replace("file://", "")
                shutil.copy(local_path, cache_file)
            else:
                urllib.request.urlretrieve(art_url, cache_file)

        return cache_file
    except Exception as e:
        log(f"Error getting album art: {e}")
        return None

def write_css(art_path):
    """Write CSS file with album art - following GitHub discussion pattern"""
    ts = int(time.time())

    if art_path and os.path.exists(art_path):
        css_content = f"""#custom-spotify-art {{
  min-width: 32px;
  min-height: 32px;
  background-image: url("file://{art_path}?ts={ts}");
  background-repeat: no-repeat;
  background-size: contain;
  background-position: center;
}}
"""
    else:
        css_content = """#custom-spotify-art {
  min-width: 32px;
  min-height: 32px;
  background-image: none;
}
"""

    with open(CSS_FILE, 'w') as f:
        f.write(css_content)

    log(f"Updated CSS (ts={ts})")

def get_current_track():
    """Get current track ID"""
    try:
        track_id = subprocess.run(
            ["playerctl", "-p", "spotify", "metadata", "mpris:trackid"],
            capture_output=True,
            text=True,
            timeout=2
        ).stdout.strip()
        return track_id
    except:
        return None

def get_player_info():
    try:
        status = subprocess.run(
            ["playerctl", "-p", "spotify", "status"],
            capture_output=True,
            text=True,
            timeout=2
        )

        if status.returncode != 0:
            return None

        title = subprocess.run(
            ["playerctl", "-p", "spotify", "metadata", "title"],
            capture_output=True,
            text=True
        ).stdout.strip()

        artist = subprocess.run(
            ["playerctl", "-p", "spotify", "metadata", "artist"],
            capture_output=True,
            text=True
        ).stdout.strip()

        playing = status.stdout.strip().lower() == "playing"

        # Check if song changed
        current_track = get_current_track()
        try:
            with open(STATE_FILE, 'r') as f:
                last_track = f.read().strip()
        except:
            last_track = ""

        # Update CSS only if song changed
        if current_track != last_track:
            log(f"Track changed: {artist} - {title}")
            art_path = get_album_art()
            write_css(art_path)

            # Save current track
            with open(STATE_FILE, 'w') as f:
                f.write(current_track)

        return {
            "text": f"{title[:30]}",
            "tooltip": f"<b>{title}</b>\n{artist}",
            "class": "playing" if playing else "paused"
        }
    except Exception as e:
        log(f"Error: {e}")
        return None

if __name__ == "__main__":
    info = get_player_info()
    if info:
        print(json.dumps(info))
    else:
        print(json.dumps({"text": "", "tooltip": "No music playing", "class": "stopped"}))
