-- ============================================
-- Hospital Management System - Advanced Features
-- Views, Stored Procedures, Triggers, Analytics
-- ============================================

-- 1. VIEW: ICU Patients
CREATE VIEW icu_patients_view AS
SELECT p.patient_id,
       CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
       ad.admission_date,
       r.room_number,
       r.room_type,
       d.first_name AS doctor_first,
       d.last_name AS doctor_last,
       b.total_amount,
       b.payment_status
FROM admissions ad
JOIN patients p ON ad.patient_id = p.patient_id
JOIN rooms r ON ad.room_id = r.room_id
JOIN doctors d ON ad.doctor_id = d.doctor_id
LEFT JOIN billing b ON ad.admission_id = b.admission_id
WHERE r.room_type = 'ICU'
  AND ad.status = 'Admitted';

-- 2. STORED PROCEDURE: Patient History
DELIMITER $$
CREATE PROCEDURE get_patient_history(IN p_patient_id INT)
BEGIN
    -- Appointments
    SELECT a.appointment_id, a.appointment_date, a.status, a.fee,
           d.first_name AS doctor_first, d.last_name AS doctor_last
    FROM appointments a
    JOIN doctors d ON a.doctor_id = d.doctor_id
    WHERE a.patient_id = p_patient_id;

    -- Admissions
    SELECT ad.admission_id, ad.admission_date, ad.discharge_date, ad.status,
           r.room_number, r.room_type,
           doc.first_name AS doctor_first, doc.last_name AS doctor_last
    FROM admissions ad
    JOIN rooms r ON ad.room_id = r.room_id
    JOIN doctors doc ON ad.doctor_id = doc.doctor_id
    WHERE ad.patient_id = p_patient_id;

    -- Billing
    SELECT b.bill_id, b.total_amount, b.payment_status, b.payment_method, b.bill_date
    FROM billing b
    JOIN admissions ad ON b.admission_id = ad.admission_id
    WHERE ad.patient_id = p_patient_id;
END$$
DELIMITER ;

-- 3. TRIGGER: Auto-update Billing on Discharge
DELIMITER $$
CREATE TRIGGER update_billing_on_discharge
AFTER UPDATE ON admissions
FOR EACH ROW
BEGIN
    IF NEW.discharge_date IS NOT NULL AND OLD.discharge_date IS NULL THEN
        UPDATE billing b
        JOIN rooms r ON NEW.room_id = r.room_id
        SET b.total_amount = (
            DATEDIFF(NEW.discharge_date, NEW.admission_date) * r.charge_per_day
            + b.doctor_fee + b.other_charges
        )
        WHERE b.admission_id = NEW.admission_id;
    END IF;
END$$
DELIMITER ;

-- 4. ANALYTICS QUERY: Monthly Revenue Trend
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(b.bill_date, '%Y-%m') AS month,
           SUM(b.total_amount) AS revenue
    FROM billing b
    WHERE b.payment_status = 'Paid'
    GROUP BY DATE_FORMAT(b.bill_date, '%Y-%m')
)
SELECT month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(
         (revenue - LAG(revenue) OVER (ORDER BY month)) 
         / LAG(revenue) OVER (ORDER BY month) * 100, 2
       ) AS pct_change
FROM monthly_revenue
ORDER BY month;
