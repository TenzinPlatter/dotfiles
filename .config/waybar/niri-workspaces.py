#!/usr/bin/env python3
import subprocess
import json
import sys
import os


def get_workspaces():
    output = subprocess.check_output(["niri", "msg", "-j", "workspaces"])
    return json.loads(output.decode("utf-8"))


def format_workspaces():
    workspaces = get_workspaces()

    # Sort by output and idx
    workspaces = sorted(workspaces, key=lambda w: (w["output"], w["idx"]))

    # Build the output
    text_parts = []
    tooltip_parts = []
    active_found = False

    current_output = None
    for wsp in workspaces:
        # Add output separator
        if current_output != wsp["output"]:
            if current_output is not None:
                text_parts.append("|")
            current_output = wsp["output"]

        name = wsp["name"] if wsp["name"] else str(wsp["idx"])

        if wsp["is_focused"]:
            # Focused workspace - highlighted
            text_parts.append(f"● {name}")
            active_found = True
        elif wsp["is_active"]:
            # Active but not focused (visible on another monitor)
            text_parts.append(f"○ {name}")
        else:
            # Inactive
            text_parts.append(f"· {name}")

        # Tooltip info
        status = "focused" if wsp["is_focused"] else ("active" if wsp["is_active"] else "inactive")
        tooltip_parts.append(f"{wsp['output']}: {name} ({status})")

    result = {
        "text": " ".join(text_parts) if text_parts else "No workspaces",
        "tooltip": "\n".join(tooltip_parts) if tooltip_parts else f"Monitor: {current_output}",
        "class": "active" if active_found else "inactive"
    }

    return json.dumps(result)


if __name__ == "__main__":
    # For initial output
    print(format_workspaces(), flush=True)

    # Subscribe to events
    process = subprocess.Popen(
        ["niri", "msg", "-j", "event-stream"],
        stdout=subprocess.PIPE,
    )

    if process.stdout is None:
        sys.exit(1)

    while True:
        line = process.stdout.readline().decode("utf-8")
        if line == "":
            break

        try:
            event = json.loads(line)
            # Update on workspace events
            if any(key in event for key in ["WorkspaceActivated", "WorkspacesChanged", "WorkspaceAdded", "WorkspaceRemoved"]):
                print(format_workspaces(), flush=True)
        except:
            pass
