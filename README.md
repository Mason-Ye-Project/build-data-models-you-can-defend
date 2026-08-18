# Copperline Model Lab

This is the executable companion for *Build Data Models You Can Defend* by Mason Ye.

Book companion: https://github.com/Mason-Ye-Project/build-data-models-you-can-defend

The book's first-edition reference is release `v1.0.0`. Use that release when you want the exact fixtures, commands, and expected outputs printed in the book. The `main` branch may receive later corrections.

## Requirements

- CPython 3.12 or newer
- no cloud account, Docker daemon, database server, or API key

## Clean start

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -e '.[dev]'
python -m model_lab doctor
python -m model_lab reset
python -m model_lab build
python -m model_lab test
python -m model_lab report
python -m model_lab cloud-map
```

Generated state is written under `.work/` and may be deleted with `reset`.

The report and manifest label what was executed locally, what is sourced platform behavior, and what remains an illustrative cloud-transfer decision. The Redshift, BigQuery, Snowflake, Databricks, Fabric, and dbt material does not require cloud credentials.

All companies, people, equipment, transactions, identifiers, timestamps, and prices are synthetic teaching data.
