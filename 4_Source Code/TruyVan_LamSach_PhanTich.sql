-- =====================================================================
-- TruyVan_LamSach_PhanTich.sql
-- Truy van - Lam sach - Phan tich du lieu StudentPerformanceFactors.csv (SQLite)
-- Dieu kien: da nhap CSV vao bang raw_students (giu nguyen ten cot goc), vi du:
--   sqlite3 student_analysis.db
--   .mode csv
--   .import StudentPerformanceFactors.csv raw_students
--   .read TruyVan_LamSach_PhanTich.sql
-- Luu y: neu import bang .import, o trong cua CSV la chuoi rong '' (khong phai NULL);
--        cac cau lenh duoi day xu ly ca hai truong hop.
-- =====================================================================

-- ---------------------------------------------------------------------
-- BUOC 4 - DATA COLLECTION: truy xuat du lieu
-- ---------------------------------------------------------------------
-- 4.1 Top 10 sinh vien diem cao nhat trong nhom chuyen can >= 90%
SELECT rowid AS student_id, Gender, Hours_Studied, Attendance,
       Motivation_Level, Parental_Education_Level, Exam_Score
FROM raw_students
WHERE CAST(Attendance AS REAL) >= 90
ORDER BY CAST(Exam_Score AS REAL) DESC, student_id
LIMIT 10;

-- 4.2 So sinh vien va diem TB theo loai truong & gioi tinh
SELECT School_Type, Gender, COUNT(*) AS students,
       ROUND(AVG(CAST(Exam_Score AS REAL)), 2) AS avg_exam_score
FROM raw_students
GROUP BY School_Type, Gender
ORDER BY School_Type, Gender;

-- ---------------------------------------------------------------------
-- BUOC 5 - DATA UNDERSTANDING: kiem tra chat luong du lieu
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM raw_students;

-- Ban ghi trung toan bo
SELECT COUNT(*) AS duplicate_groups FROM (
  SELECT COUNT(*) AS c FROM raw_students
  GROUP BY Hours_Studied, Attendance, Parental_Involvement, Access_to_Resources,
           Extracurricular_Activities, Sleep_Hours, Previous_Scores, Motivation_Level,
           Family_Income, Teacher_Quality, School_Type, Peer_Influence,
           Physical_Activity, Parental_Education_Level, Gender, Exam_Score
  HAVING COUNT(*) > 1);

-- Gia tri thieu (NULL hoac rong)
SELECT SUM(Teacher_Quality IS NULL OR TRIM(Teacher_Quality) = '')                   AS null_teacher_quality,
       SUM(Parental_Education_Level IS NULL OR TRIM(Parental_Education_Level) = '') AS null_parent_edu
FROM raw_students;

-- Gia tri ngoai pham vi hop ly
SELECT SUM(CAST(Exam_Score AS REAL)      NOT BETWEEN 0 AND 100) AS exam_out_0_100,
       SUM(CAST(Previous_Scores AS REAL) NOT BETWEEN 0 AND 100) AS prev_out_0_100,
       SUM(CAST(Attendance AS REAL)      NOT BETWEEN 0 AND 100) AS attendance_out_0_100,
       SUM(CAST(Sleep_Hours AS REAL)     NOT BETWEEN 0 AND 24)  AS sleep_out_0_24,
       SUM(CAST(Hours_Studied AS REAL)   NOT BETWEEN 0 AND 168) AS hours_out_0_168
FROM raw_students;

SELECT rowid AS student_id, Hours_Studied, Attendance, Previous_Scores, Exam_Score
FROM raw_students WHERE CAST(Exam_Score AS REAL) > 100;

-- ---------------------------------------------------------------------
-- BUOC 6 - DATA PREPARATION: lam sach tren BANG MOI (khong sua du lieu goc)
--  * student_id = rowid; ten cot chu thuong; TRIM van ban
--  * Diem/so lieu ngoai pham vi -> NULL (khong tu y sua diem)
--  * Teacher_Quality, Parental_Education_Level thieu -> 'Unknown'
--  * Loai ban ghi trung toan bo (giu ban ghi dau tien)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS students_clean_sql;
CREATE TABLE students_clean_sql AS
WITH standardized AS (
 SELECT rowid AS student_id,
        TRIM(Gender) AS gender,
        CASE WHEN CAST(Hours_Studied AS REAL) BETWEEN 0 AND 168 THEN CAST(Hours_Studied AS INTEGER) END AS hours_studied,
        CASE WHEN CAST(Attendance AS REAL) BETWEEN 0 AND 100 THEN CAST(Attendance AS INTEGER) END AS attendance,
        CASE WHEN CAST(Sleep_Hours AS REAL) BETWEEN 0 AND 24 THEN CAST(Sleep_Hours AS INTEGER) END AS sleep_hours,
        CASE WHEN CAST(Previous_Scores AS REAL) BETWEEN 0 AND 100 THEN CAST(Previous_Scores AS INTEGER) END AS previous_scores,
        CAST(Physical_Activity AS INTEGER) AS physical_activity,
        TRIM(Parental_Involvement) AS parental_involvement,
        TRIM(Access_to_Resources) AS access_to_resources,
        TRIM(Extracurricular_Activities) AS extracurricular_activities,
        TRIM(Motivation_Level) AS motivation_level,
        TRIM(Family_Income) AS family_income,
        COALESCE(NULLIF(TRIM(Teacher_Quality), ''), 'Unknown') AS teacher_quality,
        TRIM(School_Type) AS school_type,
        TRIM(Peer_Influence) AS peer_influence,
        COALESCE(NULLIF(TRIM(Parental_Education_Level), ''), 'Unknown') AS parental_education_level,
        CASE WHEN CAST(Exam_Score AS REAL) BETWEEN 0 AND 100 THEN CAST(Exam_Score AS INTEGER) END AS exam_score,
        ROW_NUMBER() OVER (
            PARTITION BY Hours_Studied, Attendance, Parental_Involvement, Access_to_Resources,
                         Extracurricular_Activities, Sleep_Hours, Previous_Scores, Motivation_Level,
                         Family_Income, Teacher_Quality, School_Type, Peer_Influence,
                         Physical_Activity, Parental_Education_Level, Gender, Exam_Score
            ORDER BY rowid) AS rn
 FROM raw_students
)
SELECT student_id, gender, hours_studied, attendance, sleep_hours, previous_scores,
       physical_activity, parental_involvement, access_to_resources,
       extracurricular_activities, motivation_level, family_income, teacher_quality,
       school_type, peer_influence, parental_education_level, exam_score
FROM standardized WHERE rn = 1
ORDER BY student_id;

SELECT COUNT(*) AS clean_rows,
       SUM(teacher_quality = 'Unknown')          AS unknown_teacher_quality,
       SUM(parental_education_level = 'Unknown') AS unknown_parent_edu,
       SUM(exam_score IS NULL)                   AS exam_score_set_null
FROM students_clean_sql;

-- ---------------------------------------------------------------------
-- BUOC 7 - MODELING: phan nhom quy tac (CASE WHEN + CTE + window function)
-- ---------------------------------------------------------------------
WITH grouped AS (
 SELECT CASE WHEN hours_studied <= 10 THEN '1. <=10h'
             WHEN hours_studied <= 20 THEN '2. 11-20h'
             WHEN hours_studied <= 30 THEN '3. 21-30h'
             ELSE '4. >30h' END AS study_group,
        exam_score, attendance
 FROM students_clean_sql
 WHERE hours_studied IS NOT NULL AND exam_score IS NOT NULL
), summary AS (
 SELECT study_group, COUNT(*) AS student_count,
        ROUND(AVG(exam_score), 2) AS avg_exam_score,
        ROUND(AVG(attendance), 2) AS avg_attendance
 FROM grouped GROUP BY study_group
)
SELECT study_group, student_count, avg_exam_score, avg_attendance,
       ROUND(avg_exam_score - SUM(avg_exam_score * student_count) OVER () / SUM(student_count) OVER (), 2) AS diff_vs_overall,
       RANK() OVER (ORDER BY avg_exam_score DESC) AS score_rank
FROM summary
ORDER BY study_group;

-- Dong luc (dong) x Su tham gia cua phu huynh (cot)
SELECT motivation_level,
       ROUND(AVG(CASE WHEN parental_involvement = 'Low'    THEN exam_score END), 2) AS parent_low,
       ROUND(AVG(CASE WHEN parental_involvement = 'Medium' THEN exam_score END), 2) AS parent_medium,
       ROUND(AVG(CASE WHEN parental_involvement = 'High'   THEN exam_score END), 2) AS parent_high
FROM students_clean_sql
GROUP BY motivation_level
ORDER BY CASE motivation_level WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END;

-- ---------------------------------------------------------------------
-- BUOC 8 - EVALUATION: danh gia, so sanh nhom (CTE + JOIN)
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS total_students, ROUND(AVG(exam_score), 3) AS avg_score,
       SUM(CASE WHEN parental_education_level = 'Unknown' THEN 1 ELSE 0 END) AS unknown_parent_edu,
       SUM(CASE WHEN teacher_quality = 'Unknown' THEN 1 ELSE 0 END) AS unknown_teacher_quality,
       SUM(CASE WHEN exam_score IS NULL THEN 1 ELSE 0 END) AS missing_exam_score
FROM students_clean_sql;

SELECT CASE WHEN attendance < 70 THEN '1. Duoi 70%'
            WHEN attendance < 80 THEN '2. 70-<80%'
            WHEN attendance < 90 THEN '3. 80-<90%' ELSE '4. 90-100%' END AS attendance_group,
       COUNT(*) AS students, ROUND(AVG(exam_score), 2) AS avg_score
FROM students_clean_sql GROUP BY attendance_group ORDER BY attendance_group;

WITH grp AS (
  SELECT parental_education_level, extracurricular_activities,
         COUNT(*) AS students, AVG(exam_score) AS avg_score
  FROM students_clean_sql
  GROUP BY parental_education_level, extracurricular_activities
), overall AS (
  SELECT AVG(exam_score) AS overall_avg FROM students_clean_sql
)
SELECT g.parental_education_level, g.extracurricular_activities, g.students,
       ROUND(g.avg_score, 2) AS avg_score,
       ROUND(g.avg_score - o.overall_avg, 2) AS diff_vs_overall
FROM grp g CROSS JOIN overall o
ORDER BY avg_score DESC;

WITH motiv AS (
  SELECT motivation_level, AVG(exam_score) AS group_avg
  FROM students_clean_sql GROUP BY motivation_level
)
SELECT s.student_id, s.motivation_level, s.hours_studied, s.attendance, s.exam_score,
       ROUND(m.group_avg, 2) AS group_avg,
       ROUND(s.exam_score - m.group_avg, 2) AS above_group_avg
FROM students_clean_sql s
JOIN motiv m ON s.motivation_level = m.motivation_level
WHERE s.exam_score IS NOT NULL
ORDER BY above_group_avg DESC, s.student_id
LIMIT 5;
