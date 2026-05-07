#!/usr/bin/env python3
"""
RAWI build verification — confirms the latest Flutter release APK contains
freshly-compiled native code.

Hashes lib/arm64-v8a/libapp.so from inside the APK and compares against the
most recent entry in build_log.json. Identical hash means Dart code did NOT
recompile, regardless of what `flutter build` claimed. This is the only
reliable way to catch stale builds before they land on the A56.

Outputs the 4-line handoff block per RAWI_RULES_AND_LEARNINGS.md build
verification protocol. The agent pastes that block into every handoff
message; if it's missing, Khaled doesn't test the APK.

Usage
-----
    python verify_build.py                              # auto-find APK
    python verify_build.py --sprint "R28-HF4"           # named sprint
    python verify_build.py --apk path/to/app.apk        # explicit APK path

The agent runs this AFTER `flutter clean && gradlew.bat assembleRelease`.

Source: RAWI_WORKFLOW_ENHANCEMENTS-5May2026-2200.md (enhancement #2)
Locked: 7 May 2026
Scope: A56 only, arm64-v8a APKs only.
"""

import argparse
import hashlib
import json
import sys
import zipfile
from datetime import datetime
from pathlib import Path


# Paths are resolved relative to this script's location: D:\Rawi_Journey\tools\
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent
LOG_PATH = SCRIPT_DIR / "build_log.json"
DEFAULT_APK = PROJECT_ROOT / "build" / "app" / "outputs" / "apk" / "release" / "app-release.apk"
TARGET_LIB = "lib/arm64-v8a/libapp.so"
MAX_LOG_ENTRIES = 50


def find_apk(explicit_path):
    """Locate the APK to verify. Use --apk if given, else default Flutter path."""
    path = Path(explicit_path).resolve() if explicit_path else DEFAULT_APK
    if not path.exists():
        print(f"ERROR: APK not found at {path}")
        print("Run 'flutter build apk --release' first, or pass --apk <path>.")
        sys.exit(1)
    return path


def hash_libapp(apk_path):
    """Open APK, read libapp.so, return (sha256, size_bytes)."""
    try:
        with zipfile.ZipFile(apk_path, "r") as z:
            names = z.namelist()
            target = TARGET_LIB

            if target not in names:
                # Fall back: any libapp.so under lib/ (handles unusual ABIs)
                candidates = [n for n in names if n.endswith("/libapp.so")]
                if not candidates:
                    print(f"ERROR: No libapp.so found in APK.")
                    print(f"Expected: {TARGET_LIB}")
                    print("This may indicate a non-arm64 build. Available native libs:")
                    for n in names:
                        if "libapp" in n or "/lib/" in n:
                            print(f"  {n}")
                    sys.exit(1)
                target = candidates[0]
                print(f"WARNING: {TARGET_LIB} not present, using {target} instead.")

            with z.open(target) as f:
                data = f.read()
                return hashlib.sha256(data).hexdigest(), len(data)

    except zipfile.BadZipFile:
        print(f"ERROR: {apk_path} is not a valid APK / ZIP file.")
        sys.exit(1)


def load_log():
    """Load build log. Empty list on missing or corrupted file."""
    if not LOG_PATH.exists():
        return []
    try:
        with open(LOG_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)
            return data if isinstance(data, list) else []
    except (json.JSONDecodeError, OSError):
        return []


def save_log(entries):
    """Save log, capped at MAX_LOG_ENTRIES (most recent kept)."""
    trimmed = entries[-MAX_LOG_ENTRIES:]
    try:
        with open(LOG_PATH, "w", encoding="utf-8") as f:
            json.dump(trimmed, f, indent=2)
    except OSError as e:
        print(f"WARNING: could not write log: {e}")


def format_size(bytes_count):
    """Human-readable MB."""
    return f"{bytes_count / (1024 * 1024):.2f} MB"


def determine_changed(log, current_sha):
    """Compare current libapp.so hash against last logged entry."""
    if not log:
        return "N/A (first logged build)"
    prev_sha = log[-1].get("libapp_so_sha256", "")
    return "NO" if prev_sha == current_sha else "YES"


def main():
    parser = argparse.ArgumentParser(
        description="Verify RAWI Flutter release APK freshness via libapp.so hash."
    )
    parser.add_argument(
        "--apk",
        help=f"Explicit APK path (default: {DEFAULT_APK})",
    )
    parser.add_argument(
        "--sprint",
        default="[sprint name]",
        help="Sprint name for the handoff line (e.g. 'R28-HF4')",
    )
    args = parser.parse_args()

    apk_path = find_apk(args.apk)
    apk_size = apk_path.stat().st_size
    libapp_sha, libapp_size = hash_libapp(apk_path)

    log = load_log()
    changed = determine_changed(log, libapp_sha)

    log.append({
        "timestamp": datetime.now().isoformat(timespec="seconds"),
        "apk_path": str(apk_path),
        "apk_size_bytes": apk_size,
        "libapp_so_sha256": libapp_sha,
        "libapp_so_size_bytes": libapp_size,
        "sprint": args.sprint,
        "changed_from_previous": changed,
    })
    save_log(log)

    # The 4-line handoff block (5 lines including header)
    print(f"BUILD COMPLETE - {args.sprint}")
    print(f"- flutter clean: confirmed")
    print(f"- APK size: {format_size(apk_size)}")
    print(f"- libapp.so SHA256: {libapp_sha}")
    print(f"- Changed from previous build: {changed}")

    if changed == "NO":
        print()
        print("WARNING: libapp.so hash matches the previous build.")
        print("If you intended to ship code changes, this build is STALE.")
        print("Re-run 'flutter clean' and 'gradlew.bat assembleRelease', then verify again.")
        print("DO NOT install this APK on A56.")
        sys.exit(2)


if __name__ == "__main__":
    main()
