"""Chạy TruyVan_LamSach_PhanTich.sql bằng Python (không cần cài đặt sqlite3 rời).

Cách dùng:
  - Nhấp đúp trực tiếp vào file `chay_sql.py` hoặc `CHAY_SQL.bat`
  - Hoặc chạy trong Terminal / VS Code từ bất kỳ thư mục nào:
        python chay_sql.py

Script sẽ:
  1. Tự động tìm file `StudentPerformanceFactors.csv` và `TruyVan_LamSach_PhanTich.sql`
     (kể cả khi chạy từ thư mục khác hoặc mở trực tiếp từ file nén Source_Code.zip)
  2. Tạo database `sql_rieng.db`, nhập dữ liệu vào bảng `raw_students`
  3. Chạy lần lượt 14 câu lệnh trong `TruyVan_LamSach_PhanTich.sql`
  4. In kết quả của từng câu SELECT ra màn hình và lưu vào `ket_qua_chay_sql.txt`
"""
import csv
import io
import os
import sqlite3
import sys
import zipfile
from pathlib import Path

# Đảm bảo hiển thị tiếng Việt UTF-8 trên Windows console
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

SCRIPT_DIR = Path(__file__).resolve().parent


def find_project_file(filename: str) -> Path | None:
    """Tìm file trong thư mục chứa script, thư mục hiện tại, hoặc các thư mục con của dự án."""
    candidates = [
        SCRIPT_DIR / filename,
        SCRIPT_DIR / "data_csv" / filename,
        SCRIPT_DIR / "4_Source Code" / filename,
        SCRIPT_DIR / "3_Dataset" / filename,
        SCRIPT_DIR / "other" / filename,
        SCRIPT_DIR.parent / filename,
        SCRIPT_DIR.parent / "4_Source Code" / filename,
        SCRIPT_DIR.parent / "3_Dataset" / filename,
        SCRIPT_DIR.parent / "other" / filename,
        Path.cwd() / filename,
        Path.cwd() / "4_Source Code" / filename,
        Path.cwd() / "3_Dataset" / filename,
        Path.cwd() / "other" / filename,
        Path.home() / "OneDrive" / "Desktop" / "ass" / "4_Source Code" / filename,
        Path.home() / "OneDrive" / "Desktop" / "ass" / "3_Dataset" / filename,
        Path.home() / "OneDrive" / "Desktop" / "ass" / "other" / filename,
        Path.home() / "Desktop" / "ass" / "4_Source Code" / filename,
        Path.home() / "Desktop" / "ass" / "3_Dataset" / filename,
    ]
    for p in candidates:
        try:
            if p.is_file():
                return p.resolve()
        except Exception:
            continue

    # Nếu người dùng mở trực tiếp chay_sql.py bên trong Source_Code.zip mà chưa giải nén,
    # tự động tìm Source_Code.zip và giải nén tạm thời vào SCRIPT_DIR
    zip_candidates = [
        SCRIPT_DIR / "Source_Code.zip",
        SCRIPT_DIR.parent / "Source_Code.zip",
        Path.cwd() / "Source_Code.zip",
        Path.cwd() / "4_Source Code" / "Source_Code.zip",
        Path.home() / "OneDrive" / "Desktop" / "ass" / "4_Source Code" / "Source_Code.zip",
        Path.home() / "Desktop" / "ass" / "4_Source Code" / "Source_Code.zip",
    ]
    for zp in zip_candidates:
        try:
            if zp.is_file():
                with zipfile.ZipFile(zp, "r") as zf:
                    for member in zf.namelist():
                        if member.endswith("/" + filename) or member == filename:
                            target = SCRIPT_DIR / filename
                            target.write_bytes(zf.read(member))
                            return target.resolve()
        except Exception:
            continue
    return None


def format_table(rows: list[tuple], cols: list[str]) -> str:
    """Định dạng bảng kết quả đẹp mắt (dùng pandas nếu có, hoặc tự căn lề chuẩn)."""
    try:
        import pandas as pd
        pd.set_option("display.width", 200)
        pd.set_option("display.max_columns", None)
        return pd.DataFrame(rows, columns=cols).to_string(index=False)
    except Exception:
        str_rows = [["" if v is None else str(v) for v in r] for r in rows]
        widths = [
            max([len(str(cols[i]))] + [len(r[i]) for r in str_rows])
            for i in range(len(cols))
        ]
        header = "  ".join(str(cols[i]).rjust(widths[i]) for i in range(len(cols)))
        lines = [header]
        for r in str_rows:
            lines.append("  ".join(r[i].rjust(widths[i]) for i in range(len(cols))))
        return "\n".join(lines)


def load_csv_to_sqlite(csv_path: Path, conn: sqlite3.Connection, table_name: str) -> int:
    """Nhập file CSV vào bảng SQLite (hỗ trợ cả khi có hoặc không có pandas)."""
    with csv_path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.reader(f)
        headers = next(reader)
        rows = [
            [None if val == "" else val for val in row]
            for row in reader
        ]
    conn.execute(f'DROP TABLE IF EXISTS "{table_name}"')
    col_defs = ", ".join(f'"{h}" TEXT' for h in headers)
    conn.execute(f'CREATE TABLE "{table_name}" ({col_defs})')
    placeholders = ", ".join("?" for _ in headers)
    conn.executemany(f'INSERT INTO "{table_name}" VALUES ({placeholders})', rows)
    conn.commit()
    return len(rows)


def main() -> int:
    csv_path = find_project_file("StudentPerformanceFactors.csv")
    sql_path = find_project_file("TruyVan_LamSach_PhanTich.sql")

    if not csv_path:
        print("❌ Lỗi: Không tìm thấy file 'StudentPerformanceFactors.csv'.")
        print("👉 Vui lòng giải nén toàn bộ file Source_Code.zip ra một thư mục trước khi chạy.")
        return 1
    if not sql_path:
        print("❌ Lỗi: Không tìm thấy file 'TruyVan_LamSach_PhanTich.sql'.")
        print("👉 Vui lòng giải nén toàn bộ file Source_Code.zip ra một thư mục trước khi chạy.")
        return 1

    # Lưu sql_rieng.db và ket_qua_chay_sql.txt cùng thư mục với file SQL (hoặc thư mục tạm nếu chỉ đọc)
    work_dir = sql_path.parent
    if not os.access(work_dir, os.W_OK):
        work_dir = SCRIPT_DIR
    db_path = work_dir / "sql_rieng.db"
    out_txt = work_dir / "ket_qua_chay_sql.txt"

    output_lines = []

    def log(msg: str = ""):
        print(msg)
        output_lines.append(msg)

    conn = sqlite3.connect(db_path)
    row_count = load_csv_to_sqlite(csv_path, conn, "raw_students")
    log(f"Đã nhập {csv_path.name} ({row_count} dòng) vào bảng raw_students ({db_path.name})\n")

    buf, comment, n = "", "", 0
    for line in sql_path.read_text(encoding="utf-8").splitlines():
        if line.strip().startswith("--"):
            text = line.strip().strip("- ")
            if text and not text.startswith(("=", "*")):
                comment = text
            continue
        buf += line + "\n"
        if sqlite3.complete_statement(buf):
            cur = conn.execute(buf)
            if cur.description:
                n += 1
                cols = [d[0] for d in cur.description]
                rows = cur.fetchall()
                log(f"===== Truy vấn {n}  {comment}")
                log(format_table(rows, cols) + " \n")
            buf = ""

    conn.commit()
    conn.close()
    log(f"Hoàn tất: {n} truy vấn. Bảng students_clean_sql đã được tạo trong {db_path.name}.")

    try:
        out_txt.write_text("\n".join(output_lines), encoding="utf-8")
        print(f"📄 Đã lưu toàn bộ kết quả vào: {out_txt}")
    except Exception:
        pass

    return 0


if __name__ == "__main__":
    exit_code = 0
    try:
        exit_code = main()
    except Exception as exc:
        import traceback
        traceback.print_exc()
        exit_code = 1

    # Giữ cửa sổ console mở nếu người dùng nhấp đúp chuột chạy trực tiếp trên Windows
    if os.name == "nt" and sys.stdin and sys.stdin.isatty() and "--no-pause" not in sys.argv:
        try:
            input("\nNhấn phím Enter để đóng cửa sổ...")
        except EOFError:
            pass
    sys.exit(exit_code)
