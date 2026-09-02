#!/usr/bin/env python3
"""Push the morning's firm list into Supabase.

Runs on Jason's Mac at the end of the daily pipeline. It replaces the FIRMS
table only — the desk's own work (assignments, statuses, follow-ups, history)
lives in `work` and `activity` and is never touched here.

A firm that drops out of tier 1 is left in place rather than deleted, because
deleting it would cascade away the call history attached to it. It simply
stops being refreshed; its `refreshed_at` goes stale and the board can hide it
later if that ever matters.

Credentials come from the environment, never from this file:

    export SUPABASE_URL="https://xxxx.supabase.co"
    export SUPABASE_SERVICE_KEY="eyJ..."      # service_role, NOT the anon key

The service key bypasses row-level security, which is exactly why it lives on
your Mac and never in the repo, never in the browser, never in a chat message.
"""
import csv
import json
import os
import sys
import urllib.error
import urllib.request

BATCH = 200


def main(path):
    url = os.environ.get("SUPABASE_URL", "").rstrip("/")
    key = os.environ.get("SUPABASE_SERVICE_KEY", "")
    if not url or not key:
        sys.exit("SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in the environment.")

    with open(path, newline="", encoding="utf-8") as fh:
        rows = list(csv.DictReader(fh))
    if not rows:
        sys.exit(f"{path} has no rows — refusing to push an empty list.")

    for r in rows:
        for k in ("score", "staff"):
            r[k] = int(r[k]) if str(r.get(k, "")).strip().isdigit() else None
        for k, v in list(r.items()):
            if v == "":
                r[k] = None

    endpoint = f"{url}/rest/v1/firms?on_conflict=firm_id"
    sent = 0
    for i in range(0, len(rows), BATCH):
        chunk = rows[i:i + BATCH]
        req = urllib.request.Request(
            endpoint, data=json.dumps(chunk).encode(), method="POST",
            headers={"apikey": key, "Authorization": f"Bearer {key}",
                     "Content-Type": "application/json",
                     "Prefer": "resolution=merge-duplicates,return=minimal"})
        try:
            with urllib.request.urlopen(req, timeout=90) as resp:
                resp.read()
        except urllib.error.HTTPError as e:
            sys.exit(f"Supabase rejected rows {i}-{i+len(chunk)}: "
                     f"{e.code} {e.read().decode()[:400]}")
        sent += len(chunk)
        print(f"  pushed {sent} of {len(rows)}")

    print(f"Deal Board updated: {sent} firms.")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "firms_seed.csv")
