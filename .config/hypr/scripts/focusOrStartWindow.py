import sys
import os
import json
import subprocess

try:
    exec_command, class_name = sys.argv[1:]
except:
    print("Please enter 2 command line arguments")
    os._exit(1)

output = json.loads(
            subprocess.run(
            ["hyprctl", "-j", "clients"],
            capture_output = True,
            text = True
            ).stdout
        )

workspace = None

for window in output:
    if window["class"] == class_name:
        workspace = window["workspace"]["id"]

if workspace is None:
    subprocess.run(["hyprctl", "dispatch", "exec", exec_command])
else:
    subprocess.run(["hyprctl", "dispatch", "focuswindow", f"class:{class_name}"])
