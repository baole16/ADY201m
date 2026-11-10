"""Chạy TruyVan_LamSach_PhanTich.sql bằng Python (không cần cài sqlite3).

Cách dùng (mở terminal tại thư mục này):
    python chay_sql.py

Script sẽ:
  1. Tạo database sql_rieng.db, nhập StudentPerformanceFactors.csv vào bảng raw_students
  2. Chạy lần lượt từng câu lệnh trong TruyVan_LamSach_PhanTich.sql
  3. In kết quả của mỗi câu SELECT ra màn hình
"""
import sqlite3
import sys
from pathlib import Path

import pandas as pd

sys.stdout.reconfigure(encoding="utf-8")

CSV = Path("StudentPerformanceFactors.csv")
SQL = Path("TruyVan_LamSach_PhanTich.sql")
DB = Path("sql_rieng.db")

pd.set_option("display.width", 200)
pd.set_option("display.max_columns", None)

conn = sqlite3.connect(DB)
pd.read_csv(CSV).to_sql("raw_students", conn, if_exists="replace", index=False)
print(f"Đã nhập {CSV} vào bảng raw_students ({DB})\n")

buf, comment, n = "", "", 0
for line in SQL.read_text(encoding="utf-8").splitlines():
    if line.strip().startswith("--"):
        text = line.strip().strip("- ")
        if text and not text.startswith(("=", "*")):
            comment = text                # nhớ dòng chú thích gần nhất để làm tiêu đề
        continue
    buf += line + "\n"
    if sqlite3.complete_statement(buf):
        cur = conn.execute(buf)
        if cur.description:               # câu SELECT -> in kết quả
            n += 1
            cols = [d[0] for d in cur.description]
            print(f"===== Truy vấn {n}  {comment}")
            print(pd.DataFrame(cur.fetchall(), columns=cols).to_string(index=False), "\n")
        buf = ""

conn.commit()
conn.close()
print(f"Hoàn tất: {n} truy vấn. Bảng students_clean_sql đã được tạo trong {DB}.")
