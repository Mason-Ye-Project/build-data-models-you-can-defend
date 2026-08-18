from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[2]
SQL_ROOT = PROJECT_ROOT / "sql"
DATA_ROOT = PROJECT_ROOT / "data" / "raw"
CONTRACTS_ROOT = PROJECT_ROOT / "contracts"
REVIEW_ROOT = PROJECT_ROOT / "review"
WORK_ROOT = PROJECT_ROOT / ".work"
DATABASE_PATH = WORK_ROOT / "copperline.duckdb"
REPORT_PATH = WORK_ROOT / "model-report.html"
MANIFEST_PATH = WORK_ROOT / "model-manifest.json"
CLOUD_MAP_PATH = WORK_ROOT / "cloud-transfer-map.md"
