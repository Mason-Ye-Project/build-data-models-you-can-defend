from __future__ import annotations

import duckdb

from model_lab.build import build, reset, run_checks, write_cloud_map, write_report
from model_lab.paths import CLOUD_MAP_PATH, DATABASE_PATH, MANIFEST_PATH, REPORT_PATH


def test_vertical_slice_builds_and_reconciles() -> None:
    reset()
    counts = build()
    assert counts["fct_rental_line"] == 5
    assert counts["fct_equipment_daily_snapshot"] == 11
    assert counts["fct_rental_lifecycle"] == 5
    assert counts["mart_branch_daily"] == 3

    checks = run_checks()
    assert checks
    assert {item["status"] for item in checks} == {"pass"}

    with duckdb.connect(str(DATABASE_PATH), read_only=True) as connection:
        total = connection.execute("select sum(net_revenue) from fct_rental_line").fetchone()[0]
        unsafe = connection.execute(
            """
            select sum(f.net_revenue)
            from fct_rental_line f
            join analytics.bridge_equipment_capability b using (equipment_key)
            """
        ).fetchone()[0]
        unknown_key = connection.execute(
            "select customer_key from fct_rental_lifecycle where rental_id = 'R1005'"
        ).fetchone()[0]
    assert float(total) == 1175.00
    assert float(unsafe) == 2250.00
    assert unknown_key == 0

    manifest = write_report()
    assert manifest["metrics"]["net_revenue"]["value"] == 1175.00
    assert manifest["metrics"]["on_time_rentals"] == 2
    assert manifest["metrics"]["completed_rentals"] == 3
    assert len(manifest["metric_contracts"]) == 4
    assert len(manifest["cloud_transfer"]["platforms"]) == 6
    assert REPORT_PATH.exists()
    assert MANIFEST_PATH.exists()
    assert write_cloud_map() == CLOUD_MAP_PATH
    assert "Snowflake" in CLOUD_MAP_PATH.read_text(encoding="utf-8")
