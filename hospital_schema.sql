create database sector1;
use sector1
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    floor_number INT NOT NULL,
    contact_number VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type ENUM('General', 'Semi-Private', 'Private', 'ICU', 'Operation Theatre') NOT NULL,
    floor_number INT NOT NULL,
    charge_per_day DECIMAL(10,2) NOT NULL CHECK (charge_per_day > 0),
    status ENUM('Available', 'Occupied', 'Maintenance') NOT NULL DEFAULT 'Available');

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_id INT NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(60) UNIQUE,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    years_experience INT DEFAULT 0 CHECK (years_experience >= 0),
    hire_date DATE NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_id INT NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    role ENUM('Nurse', 'Receptionist', 'Lab Technician', 'Pharmacist', 'Admin') NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    hire_date DATE NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    blood_group ENUM('A+','A-','B+','B-','O+','O-','AB+','AB-') ,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(60) UNIQUE,
    address VARCHAR(150),
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE));

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    reason VARCHAR(200),
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') NOT NULL DEFAULT 'Scheduled',
    fee DECIMAL(8,2) NOT NULL CHECK (fee >= 0),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT);

CREATE TABLE medical_records (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    appointment_id INT NOT NULL UNIQUE,
    diagnosis VARCHAR(200) NOT NULL,
    treatment_notes VARCHAR(300),
    record_date DATE NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
        ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    record_id INT NOT NULL,
    medicine_name VARCHAR(60) NOT NULL,
    dosage VARCHAR(30) NOT NULL,
    duration_days INT NOT NULL CHECK (duration_days > 0),
    FOREIGN KEY (record_id) REFERENCES medical_records(record_id)
        ON UPDATE CASCADE ON DELETE CASCADE);

CREATE TABLE admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    doctor_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    status ENUM('Admitted', 'Discharged') NOT NULL DEFAULT 'Admitted',
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CHECK (discharge_date IS NULL OR discharge_date >= admission_date));

CREATE TABLE billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    admission_id INT NOT NULL UNIQUE,
    room_charges DECIMAL(10,2) NOT NULL DEFAULT 0,
    doctor_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
    other_charges DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    payment_status ENUM('Paid', 'Pending', 'Partial') NOT NULL DEFAULT 'Pending',
    payment_method ENUM('Cash', 'Card', 'Insurance', 'UPI'),
    bill_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    FOREIGN KEY (admission_id) REFERENCES admissions(admission_id)
        ON UPDATE CASCADE ON DELETE CASCADE)