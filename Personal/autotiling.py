#!/usr/bin/env python3

import argparse
import sys
import signal
from functools import partial
from i3ipc import Connection, Event

def switch_splitting(conn, e, last_window_id, debug=False):
    """Adjust the tiling layout of the focused window based on the golden ratio.

    Args:
        conn: i3ipc Connection object.
        e: Event object (unused but required by the handler).
        last_window_id: Mutable list holding the ID of the last focused window.
        debug: Boolean to enable debug output.
    """
    con = conn.get_tree().find_focused()
    if not con or not con.parent or not hasattr(con, 'rect') or con.type != 'con':
        if debug:
            print("Focused container is not a valid window, skipping", file=sys.stderr)
        return

    if con.id == last_window_id[0]:
        return

    if debug:
        print(f"Window changed: {con.id}, Dimensions: {con.rect.width}x{con.rect.height}", file=sys.stderr)

    new_layout = "splitv" if con.rect.height > con.rect.width / 1.618 else "splith"
    if new_layout != con.parent.layout:
        if debug:
            print(f"Switching to {new_layout}", file=sys.stderr)
        result = conn.command(new_layout)
        if not result[0].success:
            print(f"Error: Switch to {new_layout} failed", file=sys.stderr)

    last_window_id[0] = con.id

def main():
    parser = argparse.ArgumentParser(description="Custom autotiling script for i3 or sway")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debug messages")
    parser.add_argument("-v", "--version", action="version", version="1.0", help="Show version")
    args = parser.parse_args()

    i3 = Connection()
    last_window_id = [None]  # Use a list to allow mutable state

    # Create a partial function with fixed arguments
    handler = partial(switch_splitting, last_window_id=last_window_id, debug=args.debug)

    # Set up the event handler to pass both conn and e
    i3.on(Event.WINDOW, lambda conn, e: handler(conn, e))

    # Handle shutdown signals
    def shutdown(signal, frame):
        i3.main_quit()
    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)

    i3.main()

if __name__ == "__main__":
    main()
