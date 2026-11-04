"""BizInsight AI: CSV -> temiz CSV + SQLite. Çalıştır: python etl.py"""
from pathlib import Path
import sqlite3
import pandas as pd

BASE = Path(__file__).resolve().parent
DATA = BASE / "data"
DATA.mkdir(parents=True, exist_ok=True)

INPUT = DATA / "sales_data.csv"
OUTPUT = DATA / "clean_sales_data.csv"
DB = DATA / "veripusula.db"

REQUIRED = ["order_id", "order_date", "product", "category", "region", "sales_channel", "quantity", "unit_price", "unit_cost", "discount_rate"]

def run():
    df = pd.read_csv(INPUT, encoding="utf-8-sig")
    missing = set(REQUIRED) - set(df.columns)
    if missing:
        raise ValueError(f"Eksik sütunlar: {sorted(missing)}")
    df = df[REQUIRED].copy()
    df["order_date"] = pd.to_datetime(df["order_date"], errors="coerce")
    for col in ("quantity", "unit_price", "unit_cost", "discount_rate"):
        df[col] = pd.to_numeric(df[col], errors="coerce")
    df = df.dropna(subset=REQUIRED).drop_duplicates(subset="order_id")
    df = df[(df.quantity > 0) & (df.unit_price >= 0) & (df.unit_cost >= 0) & df.discount_rate.between(0, 1)].copy()
    df["revenue"] = (df.quantity * df.unit_price * (1 - df.discount_rate)).round(2)
    df["total_cost"] = (df.quantity * df.unit_cost).round(2)
    df["profit"] = (df.revenue - df.total_cost).round(2)
    df["order_date"] = df.order_date.dt.strftime("%Y-%m-%d")
    df["year_month"] = df.order_date.str[:7]
    df.to_csv(OUTPUT, index=False, encoding="utf-8-sig")
    with sqlite3.connect(DB) as conn:
        df.to_sql("sales", conn, if_exists="replace", index=False)
        conn.execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_order_id ON sales(order_id)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(order_date)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_sales_category ON sales(category)")
        row = conn.execute("SELECT COUNT(*), ROUND(SUM(revenue),2), ROUND(SUM(profit),2) FROM sales").fetchone()
    print(f"ETL complete | Orders: {row[0]} | Total Revenue: {row[1]:,.2f} TRY | Total Profit: {row[2]:,.2f} TRY")

if __name__ == "__main__":
    run()
