# Student Performance Factors Analysis (SQL & Python) — ADY201m

> **Course:** Data Science with Python & SQL (`ADY201m`) — FPT University  
> **Repository:** `https://github.com/baole16/ADY201m`

---

## 1. Project Overview (Tổng quan dự án)

Dự án áp dụng **Quy trình Khoa học Dữ liệu 10 bước (10-Step Data Science Methodology)** kết hợp giữa **SQL (SQLite)** và **Python** để thu thập, làm sạch, khám phá dữ liệu (EDA), kiểm định giả thuyết thống kê (**ANOVA / T-test**) và xây dựng mô hình **Hồi quy tuyến tính (Linear Regression)** nhằm đánh giá các yếu tố ảnh hưởng đến kết quả thi cử (`Exam_Score`) của sinh viên.

### Objectives (Mục tiêu)
1. **Data Engineering & Cleaning (SQL + Python):** Chuẩn hóa cấu trúc bảng, tạo khóa chính `student_id`, xử lý giá trị khuyết thiếu và loại bỏ các điểm dị biệt sai miền giá trị (`Exam_Score > 100`).
2. **Exploratory Data Analysis (EDA):** Thống kê mô tả, phát hiện ngoại lai bằng phương pháp IQR và trực quan hóa 7 nhóm biểu đồ phân tích chuyên sâu.
3. **SQL Analytical Queries:** Sử dụng `CASE WHEN`, `CTE`, `GROUP BY`, `HAVING`, `JOIN` và `Window Functions` (`RANK() OVER`, `SUM() OVER`) để phân tầng sinh viên theo nhóm giờ học và tỷ lệ điểm danh.
4. **Statistical Testing & Modeling:** Kiểm định ý nghĩa thống kê bằng ANOVA / T-test và định lượng mức độ tác động của từng biến bằng mô hình Hồi quy tuyến tính.

---

## 2. Problem Statement (Đặt vấn đề)

Nhà trường và giảng viên cần xác định những yếu tố học tập, gia đình và môi trường học đường nào có mối liên hệ chặt chẽ nhất với kết quả thi (`Exam_Score`) của sinh viên, từ đó ưu tiên phân bổ nguồn lực hỗ trợ (cố vấn học tập, phụ đạo, học bổng, tài nguyên học liệu) đúng nhóm sinh viên có nguy cơ điểm thấp.

**Ba câu hỏi nghiên cứu trọng tâm:**
- **RQ1:** Các biến định lượng về nỗ lực cá nhân (`Hours_Studied`, `Attendance`, `Previous_Scores`, `Sleep_Hours`, `Tutoring_Sessions`) tương quan như thế nào với `Exam_Score`?
- **RQ2:** Sự khác biệt về hoàn cảnh gia đình và môi trường (`Access_to_Resources`, `Parental_Involvement`, `Parental_Education_Level`, `Family_Income`, `Teacher_Quality`, `Peer_Influence`) có ý nghĩa thống kê hay không?
- **RQ3:** Khi kết hợp nhiều yếu tố trong mô hình phân tích đa biến (SQL Multi-dimensional Grouping & Python Linear Regression), những yếu tố nào đóng vai trò quyết định nhất?

---

## 3. Dataset Description & Source (Mô tả tập dữ liệu)

- **Tên tập dữ liệu:** `StudentPerformanceFactors.csv`
- **Quy mô:** `6,607` bản ghi sinh viên × `16–20` thuộc tính (biến mục tiêu: `Exam_Score`, thang điểm `0–100`).
- **Phân loại biến chính:**
  - **Biến số (Numerical):** `Hours_Studied`, `Attendance`, `Previous_Scores`, `Sleep_Hours`, `Tutoring_Sessions`, `Physical_Activity`, `Exam_Score`.
  - **Biến phân loại (Categorical):** `Parental_Involvement`, `Access_to_Resources`, `Extracurricular_Activities`, `Motivation_Level`, `Internet_Access`, `Family_Income`, `Teacher_Quality`, `School_Type`, `Peer_Influence`, `Learning_Disabilities`, `Parental_Education_Level`, `Distance_from_Home`, `Gender`.
- **Tình trạng chất lượng dữ liệu & Xử lý làm sạch:**
  - Tạo khóa chính `student_id` (`1..6607`) từ `rowid`.
  - Không có bản ghi trùng lặp (`0 duplicates`).
  - Xử lý giá trị khuyết thiếu tại `Teacher_Quality` (`78` ô — `1.18%`), `Parental_Education_Level` (`90` ô — `1.36%`), `Distance_from_Home` (`67` ô — `1.01%`) bằng nhãn `'Unknown'` hoặc mode.
  - Chuẩn hóa miền giá trị: 1 bản ghi có `Exam_Score = 101` (`student_id = 1526`) vượt thang điểm 100 được chuyển thành `NULL` / loại trừ khi tính toán mô hình chuẩn.

---

## 4. Tools and Libraries Used (Công cụ & Thư viện)

| Nhóm công cụ | Chi tiết |
|---|---|
| **Ngôn ngữ & CSDL** | Python 3.12+, SQL (SQLite3) |
| **Thư viện Xử lý Dữ liệu** | `pandas`, `numpy`, `sqlite3` |
| **Thư viện Trực quan hóa** | `matplotlib`, `seaborn` |
| **Thư viện Thống kê & ML** | `scipy.stats` (ANOVA, T-test), `scikit-learn` (`LinearRegression`, `LabelEncoder`) |
| **Môi trường & Quản lý mã nguồn** | Jupyter Notebook (`.ipynb`), Git & GitHub Desktop |

---

## 5. Project Structure (Cấu trúc thư mục)

Toàn bộ thư mục bài nộp (`ass`) được tổ chức khoa học thành 5 phân khu chính kèm tài liệu bổ trợ:

```text
├── 1_Report/                                      # Báo cáo tổng kết dự án (Word)
│   ├── Report_VI.docx                             # Báo cáo chi tiết bản Tiếng Việt
│   └── Report_EN.docx                             # Báo cáo chi tiết bản Tiếng Anh
│
├── 2_Slide/                                       # Slide thuyết trình bảo vệ đồ án
│   ├── Slide_VI.pptx / Slide_VI.pdf               # Slide thuyết trình bản Tiếng Việt
│   └── Slide.pptx / Slide.pdf                     # Slide thuyết trình bản Tiếng Anh
│
├── 3_Dataset/                                     # Tập dữ liệu gốc và đã làm sạch
│   ├── StudentPerformanceFactors.csv              # Dữ liệu gốc (Raw dataset)
│   ├── student_performance_cleaned_sql.csv        # Dữ liệu sau khi làm sạch bằng SQL
│   └── StudentPerformance_Final.csv               # Dữ liệu hoàn chỉnh phục vụ phân tích
│
├── 4_Source Code/                                 # Mã nguồn SQL, Python Notebooks & Database
│   ├── PhanTich_10Buoc_SQL_Python.ipynb           # Notebook triển khai 10 bước Khoa học Dữ liệu (SQL + Python)
│   ├── StudentPerformanceAnalysis.ipynb           # Notebook EDA, Kiểm định thống kê & Hồi quy tuyến tính
│   ├── TruyVan_LamSach_PhanTich.sql               # Kịch bản 13 truy vấn làm sạch & phân tích SQL
│   ├── student_analysis.db                        # Cơ sở dữ liệu SQLite (raw_students, students_clean_sql)
│   ├── StudentPerformanceFactors.csv              # File dữ liệu kết nối trực tiếp với Notebook
│   ├── Source_Code.zip                            # Gói nén toàn bộ mã nguồn
│   └── Link Repo Github.docx                      # File đính kèm đường dẫn GitHub Repository
│
├── 5_Visualize/                                   # Hình ảnh trực quan hóa trích xuất từ phân tích
│   ├── Hình 1.jpg                                 # Phân phối điểm thi (Histogram & KDE)
│   ├── Hình 2.jpg                                 # Tương quan Giờ học & Điểm danh với Điểm thi
│   ├── Hình 3.jpg                                 # Ma trận tương quan (Correlation Heatmap)
│   ├── Hình 4.jpg                                 # Violin/Boxplot các biến phân loại trọng tâm
│   ├── Hình 5.jpg                                 # Phân tích theo Giới tính, Loại trường & Ngoại khóa
│   ├── Hình 6.jpg                                 # Phân phối điểm theo Nhóm giờ học & Chuyên cần (SQL)
│   └── Hình 7.jpg                                 # Ma trận tương tác & Hệ số Hồi quy tuyến tính (R² = 85.8%)
│
└── README.md                                      # Tài liệu hướng dẫn và mô tả dự án
```

---

## 6. Summary of Completed Work (Tóm tắt kết quả phân tích)

1. **Tương quan tuyến tính (Pearson $r$):**
   - **Tỷ lệ điểm danh (`Attendance`)** có tương quan thuận mạnh nhất với điểm thi ($r = +0.581$, tăng 10% chuyên cần giúp tăng trung bình ~1.98 điểm).
   - **Số giờ tự học (`Hours_Studied`)** đứng thứ hai ($r = +0.445$, tăng 10 giờ học/tuần giúp tăng ~2.90 điểm).
   - **Điểm số trước đó (`Previous_Scores`)** có tương quan thuận mức độ vừa ($r = +0.175$).
2. **Phân nhóm bằng SQL (`CASE WHEN` & `Window Functions`):**
   - Nhóm học **> 30 giờ/tuần** đạt trung bình **71.01 điểm** (+3.78 điểm so với mức chung 67.23), trong khi nhóm học **≤ 10 giờ/tuần** chỉ đạt **63.97 điểm** (-3.26 điểm).
   - Nhóm điểm danh **90–100%** ($n = 1,745$ bản ghi hợp lệ) đạt trung bình **70.12 điểm**, cao hơn **+5.91 điểm** so với nhóm điểm danh **< 70%** (64.21 điểm).
3. **Kiểm định giả thuyết & Mô hình Hồi quy (ANOVA, T-test & Linear Regression):**
   - Các yếu tố `Access_to_Resources` ($F = 98.00, p < 0.001$), `Parental_Involvement` ($F = 84.49, p < 0.001$), `Parental_Education_Level` ($F = 36.43, p < 0.001$), `Peer_Influence` ($F = 34.05, p < 0.001$), `Family_Income` ($F = 29.79, p < 0.001$) đều có ảnh hưởng có ý nghĩa thống kê rất cao.
   - Ngược lại, `Gender` và `School_Type` không tạo ra sự khác biệt có ý nghĩa thống kê ($p > 0.05$).
   - Mô hình **Hồi quy tuyến tính** đơn giản với 5 biến chính sau khi lọc outliers IQR `[59, 75]` đạt độ chính xác **$R^2 = 85.8\%$**.

---

## 7. Team Collaboration & Responsibilities (Phân công nhiệm vụ nhóm)

| Thành viên / Vai trò | Nhiệm vụ chính (Responsibilities) | Hạng mục đóng góp (Deliverables) |
|---|---|---|
| **Trưởng nhóm & Data Engineer (`baole16`)** | Thiết kế CSDL SQLite, xây dựng pipeline làm sạch dữ liệu SQL & Python, quản lý GitHub Repository | `3_Dataset/`, `4_Source Code/TruyVan_LamSach_PhanTich.sql`, `student_analysis.db`, `README.md` |
| **Data Analyst (EDA & Visualization)** | Thống kê mô tả, kiểm tra IQR Outliers, xây dựng 7 biểu đồ trực quan hóa dữ liệu | `4_Source Code/StudentPerformanceAnalysis.ipynb`, `5_Visualize/Hình 1..7.jpg` |
| **Statistical & ML Modeler** | Triển khai quy trình 10 bước Khoa học Dữ liệu, kiểm định ANOVA/T-test và mô hình Hồi quy tuyến tính | `4_Source Code/PhanTich_10Buoc_SQL_Python.ipynb`, `4_Source Code/chay_sql.py` |
| **Documentation & Presentation** | Biên soạn báo cáo song ngữ Việt - Anh và thiết kế Slide thuyết trình | `1_Report/Report_VI.docx`, `1_Report/Report_EN.docx`, `2_Slide/Slide_VI.pptx`, `2_Slide/Slide.pptx` |
