-- ================= LEVEL 1 — BASIC =================

-- Q1: List first name, last name, specialization of all doctors
SELECT first_name, last_name, specialization
FROM doctors;

-- Q2: Patients with blood group O+
SELECT * FROM patients
WHERE blood_group = 'O+';

-- Q3: Doctors in dept 1 with more than 10 years experience
SELECT doctor_id, first_name, last_name, dept_id, years_experience
FROM doctors
WHERE dept_id = 1
  AND years_experience > 10;

-- Q4: Rooms that are ICU or under Maintenance
SELECT * FROM rooms
WHERE room_type = 'ICU' OR status = 'Maintenance';

-- Q5: Appointments that are NOT cancelled
SELECT * FROM appointments
WHERE NOT status = 'Cancelled';

-- Q6: Doctors with specific specializations
SELECT * FROM doctors
WHERE specialization IN ('Surgeon', 'Consultant', 'Senior Consultant');

-- Q7: Patients born between 1990-01-01 and 2000-12-31
SELECT * FROM patients
WHERE dob BETWEEN '1990-01-01' AND '2000-12-31';

-- Q8: Patients whose email starts with 'a'
SELECT * FROM patients
WHERE email LIKE 'a%';

-- Q9: Patients with no email on file
SELECT * FROM patients
WHERE email IS NULL;

-- Q10: Doctors ordered by salary descending
SELECT * FROM doctors
ORDER BY salary DESC;

-- Q11: 5 most recently registered patients
SELECT * FROM patients
ORDER BY registration_date DESC
LIMIT 5;

-- Q12: Distinct room types
SELECT DISTINCT room_type FROM rooms;

-- Q13: Doctor full name as alias
SELECT CONCAT(first_name, ' ', last_name) AS doctor_name
FROM doctors;

-- Q14: Insert new department
INSERT INTO departments (dept_name, floor_number, contact_number)
VALUES ('Urology', 3, '9000000000');

-- Q15: Update room status
UPDATE rooms
SET status = 'Maintenance'
WHERE room_id = 1;

-- Q16: Delete old No-Show appointments
DELETE FROM appointments
WHERE status = 'No-Show'
  AND appointment_date < '2023-01-01';


-- ================= LEVEL 2 — INTERMEDIATE =================

-- Q17: Total patient count
SELECT COUNT(*) AS total_patients
FROM patients;

-- Q18: Average doctor salary per department
SELECT dept_id, AVG(salary) AS avg_salary
FROM doctors
GROUP BY dept_id;

-- Q19: Total amount collected where paid
SELECT SUM(total_amount) AS total_collected
FROM billing
WHERE payment_status = 'Paid';

-- Q20: Departments with more than 8 doctors
SELECT dept_id, COUNT(*) AS doctor_count
FROM doctors
GROUP BY dept_id
HAVING COUNT(*) > 8;

-- Q21: Doctors with department name (INNER JOIN)
SELECT d.doctor_id, d.first_name, d.last_name, dep.dept_name
FROM doctors d
INNER JOIN departments dep ON d.dept_id = dep.dept_id;

-- Q22: All doctors + admissions if any (LEFT JOIN)
SELECT d.doctor_id, d.first_name, d.last_name, a.admission_date
FROM doctors d
LEFT JOIN admissions a ON d.doctor_id = a.doctor_id;

-- Q23: Patient, doctor, diagnosis for completed records (multi-join)
SELECT p.first_name AS patient_first, p.last_name AS patient_last,
       doc.first_name AS doctor_first, doc.last_name AS doctor_last,
       mr.diagnosis
FROM medical_records mr
JOIN appointments ap ON mr.appointment_id = ap.appointment_id
JOIN patients p ON ap.patient_id = p.patient_id
JOIN doctors doc ON ap.doctor_id = doc.doctor_id;

-- Q24: Doctors earning above average salary (subquery)
SELECT * FROM doctors
WHERE salary > (SELECT AVG(salary) FROM doctors);

-- Q25: Patients who never booked an appointment
SELECT * FROM patients
WHERE patient_id NOT IN (SELECT DISTINCT patient_id FROM appointments);

-- Q26: Doctors above their department's average appointment count (correlated subquery)
SELECT d.doctor_id, d.first_name, d.last_name, d.dept_id,
       COUNT(a.appointment_id) AS appointment_count
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.dept_id
HAVING COUNT(a.appointment_id) > (
    SELECT AVG(dept_counts.dept_appt_count)
    FROM (
        SELECT doc.doctor_id, COUNT(ap.appointment_id) AS dept_appt_count
        FROM doctors doc
        JOIN appointments ap ON doc.doctor_id = ap.doctor_id
        WHERE doc.dept_id = d.dept_id
        GROUP BY doc.doctor_id
    ) AS dept_counts
);

-- Alternative to Q26 using window function (preview of Q38/39 concepts):
-- SELECT doctor_id, first_name, last_name, dept_id, appointment_count
-- FROM (
--     SELECT d.doctor_id, d.first_name, d.last_name, d.dept_id,
--            COUNT(a.appointment_id) AS appointment_count,
--            AVG(COUNT(a.appointment_id)) OVER (PARTITION BY d.dept_id) AS dept_avg
--     FROM doctors d
--     JOIN appointments a ON d.doctor_id = a.doctor_id
--     GROUP BY d.doctor_id, d.first_name, d.last_name, d.dept_id
-- ) t
-- WHERE appointment_count > dept_avg;

-- Q27: Categorize appointment fees (CASE)
SELECT appointment_id, fee,
    CASE
        WHEN fee >= 1000 THEN 'High Fee'
        WHEN fee >= 500 THEN 'Medium Fee'
        ELSE 'Low Fee'
    END AS fee_category
FROM appointments;

-- Q28: Appointments per month in 2025 (date functions)
SELECT MONTH(appointment_date) AS month_num, COUNT(*) AS appointment_count
FROM appointments
WHERE YEAR(appointment_date) = 2025
GROUP BY MONTH(appointment_date)
ORDER BY month_num;

-- Q29: Patients whose full name is longer than 20 characters (string functions)
SELECT patient_id, CONCAT(first_name, ' ', last_name) AS full_name
FROM patients
WHERE LENGTH(CONCAT(first_name, ' ', last_name)) > 20;

-- Q30: Stay duration per discharged admission (date arithmetic)
SELECT admission_id, patient_id,
       DATEDIFF(discharge_date, admission_date) AS stay_days
FROM admissions
WHERE discharge_date IS NOT NULL;

-- Q31: Duplicate phone numbers check (should return 0 rows)
SELECT phone, COUNT(*) AS occurrences
FROM patients
GROUP BY phone
HAVING COUNT(*) > 1;

-- Q32: Second-highest paid doctor
SELECT doctor_id, first_name, last_name, salary
FROM doctors
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

-- Q33: Departments with at least one doctor (EXISTS)
SELECT * FROM departments dep
WHERE EXISTS (
    SELECT 1 FROM doctors d WHERE d.dept_id = dep.dept_id
);


-- ================= LEVEL 3 — ADVANCED =================

-- Q34: Admitted patient + doctor + room type + bill (4-table join)
SELECT p.first_name, p.last_name,
       doc.first_name AS doctor_first, doc.last_name AS doctor_last,
       r.room_type, b.total_amount
FROM admissions ad
JOIN patients p ON ad.patient_id = p.patient_id
JOIN doctors doc ON ad.doctor_id = doc.doctor_id
JOIN rooms r ON ad.room_id = r.room_id
JOIN billing b ON ad.admission_id = b.admission_id;

-- Q35: Doctors prescribing more distinct medicines than average (nested subquery)
SELECT doc.doctor_id, COUNT(DISTINCT pr.medicine_name) AS distinct_meds
FROM doctors doc
JOIN appointments ap ON doc.doctor_id = ap.doctor_id
JOIN medical_records mr ON ap.appointment_id = mr.appointment_id
JOIN prescriptions pr ON mr.record_id = pr.record_id
GROUP BY doc.doctor_id
HAVING COUNT(DISTINCT pr.medicine_name) > (
    SELECT AVG(med_count) FROM (
        SELECT COUNT(DISTINCT pr2.medicine_name) AS med_count
        FROM doctors doc2
        JOIN appointments ap2 ON doc2.doctor_id = ap2.doctor_id
        JOIN medical_records mr2 ON ap2.appointment_id = mr2.appointment_id
        JOIN prescriptions pr2 ON mr2.record_id = pr2.record_id
        GROUP BY doc2.doctor_id
    ) AS per_doctor_counts
);

-- Q36: Each patient's most recent appointment (correlated subquery)
SELECT p.patient_id, p.first_name, p.last_name,
    (SELECT MAX(a2.appointment_date)
     FROM appointments a2
     WHERE a2.patient_id = p.patient_id) AS last_appointment
FROM patients p
WHERE EXISTS (SELECT 1 FROM appointments a3 WHERE a3.patient_id = p.patient_id);

-- Q37: Departments earning above-average revenue (CTE)
WITH dept_revenue AS (
    SELECT doc.dept_id, SUM(ap.fee) AS total_revenue
    FROM appointments ap
    JOIN doctors doc ON ap.doctor_id = doc.doctor_id
    GROUP BY doc.dept_id
)
SELECT dep.dept_name, dr.total_revenue
FROM dept_revenue dr
JOIN departments dep ON dr.dept_id = dep.dept_id
WHERE dr.total_revenue > (SELECT AVG(total_revenue) FROM dept_revenue);

-- Q38: Rank doctors by salary within department (DENSE_RANK)
SELECT doctor_id, first_name, last_name, dept_id, salary,
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_salary_rank
FROM doctors;

-- Q39: Visit sequence number per patient (ROW_NUMBER)
SELECT appointment_id, patient_id, appointment_date,
    ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY appointment_date) AS visit_number
FROM appointments;

-- Q40: Running total of billing revenue by date
SELECT bill_id, bill_date, total_amount,
    SUM(total_amount) OVER (ORDER BY bill_date) AS running_total
FROM billing
ORDER BY bill_date;

-- Q41: Monthly appointment count with % change from previous month (LAG)
WITH monthly AS (
    SELECT DATE_FORMAT(appointment_date, '%Y-%m') AS ym, COUNT(*) AS appt_count
    FROM appointments
    GROUP BY DATE_FORMAT(appointment_date, '%Y-%m')
)
SELECT ym, appt_count,
    LAG(appt_count) OVER (ORDER BY ym) AS prev_month_count,
    ROUND(
      (appt_count - LAG(appt_count) OVER (ORDER BY ym))
      / LAG(appt_count) OVER (ORDER BY ym) * 100, 2
    ) AS pct_change
FROM monthly
ORDER BY ym;

-- Q42: Status counts per department as columns (conditional aggregation)
SELECT doc.dept_id,
    SUM(CASE WHEN ap.status = 'Completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN ap.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN ap.status = 'No-Show' THEN 1 ELSE 0 END) AS noshow_count
FROM appointments ap
JOIN doctors doc ON ap.doctor_id = doc.doctor_id
GROUP BY doc.dept_id;

-- Q43: Top 3 doctors by completed appointments (Top-N)
SELECT doc.doctor_id, doc.first_name, doc.last_name, COUNT(*) AS completed_appointments
FROM appointments ap
JOIN doctors doc ON ap.doctor_id = doc.doctor_id
WHERE ap.status = 'Completed'
GROUP BY doc.doctor_id, doc.first_name, doc.last_name
ORDER BY completed_appointments DESC
LIMIT 3;

-- Q44: Prove no invalid discharge dates exist (CHECK constraint validation)
SELECT * FROM admissions
WHERE discharge_date < admission_date;
-- Expected: 0 rows.
-- If you manually tried: INSERT INTO admissions (patient_id, room_id, doctor_id, admission_date, discharge_date, status)
-- VALUES (1, 1, 1, '2026-01-10', '2026-01-05', 'Discharged');
-- MySQL 8.0.16+ would reject it with:
-- Error 3819 (HY000): Check constraint 'admissions_chk_1' is violated.

-- Q45: FK behavior demonstration (RESTRICT vs CASCADE)
-- Attempt 1: delete a department that still has doctors (should FAIL - RESTRICT)
-- DELETE FROM departments WHERE dept_id = 1;
-- Expected error: Cannot delete or update a parent row: a foreign key constraint fails
--   (`hospital_management`.`doctors`, CONSTRAINT ... FOREIGN KEY (`dept_id`) REFERENCES `departments`)

-- Attempt 2: delete a patient who has appointments (should SUCCEED - CASCADE)
-- DELETE FROM patients WHERE patient_id = 5;
-- Expected: succeeds, and all rows in appointments where patient_id = 5 are automatically deleted too.
-- Contrast: RESTRICT protects "structural" parent data (departments) from disappearing while
-- still referenced; CASCADE treats child data (appointments) as meaningless without its patient,
-- so it's cleaned up automatically.
