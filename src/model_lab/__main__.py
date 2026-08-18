from __future__ import annotations

import argparse
import platform
import sys

import duckdb

from .build import build, reset, run_checks, write_cloud_map, write_report
from .paths import CLOUD_MAP_PATH, DATABASE_PATH, MANIFEST_PATH, REPORT_PATH


def main() -> int:
    parser = argparse.ArgumentParser(prog="python -m model_lab")
    parser.add_argument(
        "command", choices=["doctor", "reset", "build", "test", "report", "cloud-map"]
    )
    args = parser.parse_args()

    if args.command == "doctor":
        print(f"python={platform.python_version()}")
        print(f"duckdb={duckdb.__version__}")
        print("status=ready")
        return 0
    if args.command == "reset":
        reset()
        print("reset=complete")
        return 0
    if args.command == "build":
        counts = build()
        print(f"database={DATABASE_PATH}")
        for name, count in counts.items():
            print(f"{name}={count}")
        return 0
    if args.command == "test":
        failures = []
        for check in run_checks():
            print(f"{check['status']} {check['check_name']}: {check['detail']}")
            if check["status"] != "pass":
                failures.append(check)
        return 1 if failures else 0
    if args.command == "report":
        manifest = write_report()
        print(f"report={REPORT_PATH}")
        print(f"manifest={MANIFEST_PATH}")
        print(f"net_revenue={manifest['metrics']['net_revenue']['value']:.2f}")
        return 0
    if args.command == "cloud-map":
        write_cloud_map()
        print(f"cloud_map={CLOUD_MAP_PATH}")
        return 0
    return 2


if __name__ == "__main__":
    sys.exit(main())
