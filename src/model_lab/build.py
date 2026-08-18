from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import duckdb

from .paths import (
    CLOUD_MAP_PATH,
    CONTRACTS_ROOT,
    DATABASE_PATH,
    DATA_ROOT,
    MANIFEST_PATH,
    REPORT_PATH,
    SQL_ROOT,
    WORK_ROOT,
)


BUILD_ORDER = [
    "staging/01_sources.sql",
    "dimensions/01_dimensions.sql",
    "facts/01_rental_line_fact.sql",
    "facts/02_availability_snapshot.sql",
    "facts/03_rental_lifecycle.sql",
    "marts/01_branch_daily.sql",
    "marts/02_capability_revenue.sql",
    "marts/03_metric_summary.sql",
]


def _render_sql(path: Path) -> str:
    raw_dir = str(DATA_ROOT).replace("'", "''")
    return path.read_text(encoding="utf-8").replace("{{RAW_DIR}}", raw_dir)


def reset() -> None:
    if WORK_ROOT.exists():
        for child in sorted(WORK_ROOT.iterdir(), reverse=True):
            if child.is_file() or child.is_symlink():
                child.unlink()
            elif child.is_dir():
                for nested in sorted(child.rglob("*"), reverse=True):
                    if nested.is_file() or nested.is_symlink():
                        nested.unlink()
                    elif nested.is_dir():
                        nested.rmdir()
                child.rmdir()
    WORK_ROOT.mkdir(parents=True, exist_ok=True)


def build() -> dict[str, int]:
    WORK_ROOT.mkdir(parents=True, exist_ok=True)
    if DATABASE_PATH.exists():
        DATABASE_PATH.unlink()

    with duckdb.connect(str(DATABASE_PATH)) as connection:
        for relative_path in BUILD_ORDER:
            connection.execute(_render_sql(SQL_ROOT / relative_path))
        counts = {
            table: connection.execute(f"select count(*) from {table}").fetchone()[0]
            for table in [
                "stg_rentals",
                "stg_rental_lines",
                "dim_branch",
                "dim_customer",
                "dim_equipment",
                "fct_rental_line",
                "fct_equipment_daily_snapshot",
                "fct_rental_lifecycle",
                "mart_branch_daily",
                "mart_capability_revenue",
            ]
        }
    return counts


def run_checks() -> list[dict[str, object]]:
    if not DATABASE_PATH.exists():
        raise RuntimeError("Database not found. Run `python -m model_lab build` first.")

    checks: list[dict[str, object]] = []
    with duckdb.connect(str(DATABASE_PATH), read_only=True) as connection:
        for path in sorted((SQL_ROOT / "tests").glob("*.sql")):
            rows = connection.execute(path.read_text(encoding="utf-8")).fetchall()
            columns = [item[0] for item in connection.description]
            for row in rows:
                record = dict(zip(columns, row, strict=True))
                record["source_file"] = path.name
                checks.append(record)
    return checks


def load_contract(name: str) -> dict[str, object]:
    return json.loads((CONTRACTS_ROOT / name).read_text(encoding="utf-8"))


def write_cloud_map() -> Path:
    contract = load_contract("cloud_transfer_matrix.json")
    lines = [
        "# Copperline cloud transfer map",
        "",
        "This file maps a locally executed logical model to platform decisions. It is not deployment evidence.",
        "",
        "## Invariants",
        "",
    ]
    lines.extend(f"- {item}" for item in contract["invariants"])
    lines.extend(["", "## Platform decisions", ""])
    for platform in contract["platforms"]:
        lines.extend(
            [
                f"### {platform['name']}",
                "",
                f"- Revisit: {platform['revisit']}",
                f"- Integrity boundary: {platform['integrity_boundary']}",
                f"- Exercise: {platform['exercise']}",
                f"- Evidence: {platform['evidence_label']}",
                "",
            ]
        )
    CLOUD_MAP_PATH.write_text("\n".join(lines), encoding="utf-8")
    return CLOUD_MAP_PATH


def write_report() -> dict[str, object]:
    checks = run_checks()
    failures = [item for item in checks if item["status"] != "pass"]
    if failures:
        raise RuntimeError(f"Cannot publish report: {len(failures)} checks failed")

    with duckdb.connect(str(DATABASE_PATH), read_only=True) as connection:
        branch_rows = connection.execute(
            """
            select calendar_date, branch_name, rental_line_count, net_revenue
            from mart_branch_daily
            order by calendar_date, branch_name
            """
        ).fetchall()
        total = connection.execute(
            "select round(sum(net_revenue), 2) from fct_rental_line"
        ).fetchone()[0]
        summary = connection.execute(
            """
            select net_revenue, completed_rentals, on_time_rentals,
                   on_time_return_rate, utilization_rate
            from mart_metric_summary
            """
        ).fetchone()

    generated_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    grain_contracts = load_contract("grain_contracts.json")
    metric_contracts = load_contract("metric_contracts.json")
    cloud_transfer = load_contract("cloud_transfer_matrix.json")
    write_cloud_map()
    manifest = {
        "project": "Copperline Model Lab",
        "version": "0.1.0",
        "generated_at_utc": generated_at,
        "database": DATABASE_PATH.name,
        "models": grain_contracts["models"],
        "metric_contracts": metric_contracts["metrics"],
        "cloud_transfer": cloud_transfer,
        "metrics": {
            "net_revenue": {
                "value": float(total),
                "formula": "base_charge - discount_amount + fee_amount for billable rental lines",
            },
            "completed_rentals": int(summary[1]),
            "on_time_rentals": int(summary[2]),
            "on_time_return_rate": float(summary[3]),
            "utilization_rate": float(summary[4]),
        },
        "checks": checks,
    }
    MANIFEST_PATH.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    rows_html = "\n".join(
        f"<tr><td>{day}</td><td>{branch}</td><td>{count}</td><td>${amount:.2f}</td></tr>"
        for day, branch, count, amount in branch_rows
    )
    checks_html = "\n".join(
        f"<li><strong>{item['check_name']}</strong>: {item['status']} - {item['detail']}</li>"
        for item in checks
    )
    contract_html = "\n".join(
        f"<li><strong>{item['name']}</strong>: {item['grain']}</li>"
        for item in grain_contracts["models"]
    )
    cloud_html = "\n".join(
        f"<li><strong>{item['name']}</strong>: {item['integrity_boundary']} "
        f"<em>({item['evidence_label']})</em></li>"
        for item in cloud_transfer["platforms"]
    )
    REPORT_PATH.write_text(
        f"""<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Copperline model report</title>
<style>body{{font-family:system-ui;max-width:880px;margin:40px auto;line-height:1.5;color:#17202a}}table{{border-collapse:collapse;width:100%}}th,td{{border:1px solid #ccd1d1;padding:8px;text-align:left}}th{{background:#eef3f5}}code{{background:#f5f5f5;padding:2px 4px}}</style></head>
<body><h1>Copperline model report</h1>
<p>Generated {generated_at}. The transaction fact has the declared grain <code>one row per source rental line</code>.</p>
<h2>Branch daily output</h2><table><thead><tr><th>Date</th><th>Branch</th><th>Lines</th><th>Net revenue</th></tr></thead><tbody>{rows_html}</tbody></table>
<h2>Verified total</h2><p><strong>${total:.2f}</strong></p>
<h2>Grain contracts</h2><ul>{contract_html}</ul>
<h2>Checks</h2><ul>{checks_html}</ul>
<h2>Cloud transfer boundaries</h2><ul>{cloud_html}</ul>
<p>This report proves only the bounded properties stated by its checks. It is not evidence of production scale, source completeness, or universal business correctness.</p>
</body></html>""",
        encoding="utf-8",
    )
    return manifest
