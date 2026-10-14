Phân Tích Dữ Liệu Các Yếu Tố Ảnh Hưởng Đến Kết Quả Học Tập Của Sinh Viên (Student Performance Factors)
Tổng Quan Dự Án & Vấn Đề Nghiên Cứu
Dự án thực hiện phân tích khám phá (EDA) để xác định mối quan hệ giữa các yếu tố thói quen sinh hoạt, môi trường giáo dục và điểm thi của sinh viên. Mục tiêu là nhận diện các yếu tố trọng yếu ảnh hưởng đến kết quả học tập, từ đó xây dựng nền tảng để đưa ra các đề xuất cải thiện thành tích học tập một cách hiệu quả.
Mô Tả Tập Dữ Liệu
●	Nguồn gốc: Tập dữ liệu StudentPerformanceFactors.csv.
●	Kích thước: 6607 dòng và 20 cột (bao gồm 7 biến số và 13 biến phân loại).
●	Biến mục tiêu: Exam_Score (Điểm thi).
●	Các biến số đặc trưng: Hours_Studied, Attendance, Sleep_Hours, Previous_Scores, Tutoring_Sessions, Physical_Activity.
Công Cụ & Thư Viện Sử Dụng
●	Ngôn ngữ: Python.
●	Thư viện: Pandas, NumPy (Xử lý dữ liệu), Matplotlib, Seaborn (Trực quan hóa).
Tổng Hợp Công Việc Đã Hoàn Thành
●	Kiểm tra chất lượng dữ liệu: Phát hiện 3 cột chứa giá trị thiếu bao gồm Parental_Education_Level (90 dòng), Teacher_Quality (78 dòng), và Distance_from_Home (67 dòng). Không phát hiện dữ liệu trùng lặp trong tập dữ liệu.
●	Phân tích giá trị bất thường (Outliers): Sử dụng phương pháp IQR kết hợp biểu đồ Boxplot, phát hiện các ngoại lệ tại các biến Hours_Studied (43 outliers), Tutoring_Sessions (430 outliers) và Exam_Score (104 outliers).
●	Thống kê mô tả: Các biến Tutoring_Sessions và Exam_Score có phân phối lệch phải (right-skewed), trong khi các biến số còn lại có phân phối gần đối xứng. Đã xác định giá trị phổ biến nhất (Mode) cho 13 biến phân loại trong tập dữ liệu.
Cấu Trúc Thư Mục
●	/Data: Lưu trữ tập dữ liệu StudentPerformanceFactors.csv.
●	/Python_notebooks: Chứa tệp mã nguồn Jupyter Notebook thực hiện phân tích EDA dữ liệu kết quả học tập.
●	/SQL_scripts: Chứa các tệp mã truy vấn dữ liệu (nếu sử dụng SQL để trích xuất hoặc gom nhóm dữ liệu trong các bước tiếp theo).
●	/Figures_and_visualizations: Lưu các hình ảnh biểu đồ được tạo ra, chẳng hạn như biểu đồ Boxplot phát hiện giá trị bất thường (Outliers).
●	/Reports_and_documentation: Chứa các tệp báo cáo tổng kết tiến độ phân tích, slide trình bày và các tài liệu liên quan khác.
Phân Công Trách Nhiệm Nhóm
Thành Viên	Vai Trò	Trách Nhiệm Cụ Thể (Giai đoạn EDA)
Thành viên 1	Data Engineer	Khởi tạo Repository, tải tập dữ liệu, cấu hình các thư viện cơ bản và viết mã kiểm tra giá trị thiếu/trùng lặp.
Thành viên 2	Data Analyst	Thực hiện tính toán thống kê mô tả, áp dụng phương pháp IQR để xử lý outlier và vẽ biểu đồ Boxplot.
Thành viên 3	Git Manager & Documentation	Cập nhật tệp README.md, review các Pull Request của nhóm và hợp nhất mã nguồn vào nhánh main.

