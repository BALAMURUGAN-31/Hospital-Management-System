# 🏥 Hospital Management System — SQL Project

A realistic, fully-relational **MySQL** database for a hospital, built to
practice and demonstrate SQL from basic to advanced level — schema design,
constraints, joins, subqueries, window functions, views, procedures, and
triggers, all backed by ~8,000 rows of internally-consistent sample data.

<p>
  <img alt="MySQL" src="https://img.shields.io/badge/database-MySQL-4479A1">
  <img alt="Tables" src="https://img.shields.io/badge/tables-10-blue">
  <img alt="Records" src="https://img.shields.io/badge/sample%20records-~8%2C000-green">
  <img alt="Status" src="https://img.shields.io/badge/status-learning%20project-yellow">
</p>

## ✨ What's Inside

- **10 normalized tables** — departments, rooms, doctors, staff, patients, appointments, medical records, prescriptions, admissions, billing
- **Realistic constraints** — PK/FK relationships, `CHECK` constraints, `CASCADE`/`RESTRICT` delete rules, `UNIQUE` 1-to-1 links
- **~8,000 rows** of FK-consistent generated data (billing amounts, stay durations, etc. are computed, not random)
- **2 views, 1 stored procedure, 1 trigger, 4 indexes** — ICU patient view, revenue summary, patient history lookup, auto-billing on discharge
- **3 dashboard-style reports** — monthly revenue, top doctors by revenue, average stay duration by room type
- **45 practice questions** (Basic → Advanced) with a full solved answer key

## 🗂️ Repository Structure

```
├── sql/
│   ├── hospital_schema.sql       # DDL — creates DB + all 10 tables
│   ├── hospital_data.sql         # DML — ~8,000 rows of sample data
│   ├── advanced_features.sql     # Views, procedure, trigger, indexes
│   ├── reports.sql               # 3 dashboard report queries
│   └── answer_key.sql            # Solutions to all 45 practice questions
├── docs/
│   ├── HOSPITAL_MANAGEMENT_SYSTEM.md   # Full project write-up (ER diagram, schema, reports)
│   └── practice_questions.md           # 45 SQL practice questions
└── README.md                     # You are here
```

## 🚀 Quick Start

```bash
mysql -u root -p < sql/hospital_schema.sql
mysql -u root -p < sql/hospital_data.sql
mysql -u root -p < sql/advanced_features.sql
mysql -u root -p < sql/reports.sql
```

## 📊 Sample Result

Top 5 doctors by revenue generated (from `reports.sql`):

| doctor_name | dept_name | total_revenue | total_appointments |
|---|---|---|---|
| Hardik Kar | ENT | 33,600 | 38 |
| Jeevika Bail | Neurology | 32,700 | 40 |
| Theodore Sundaram | Neurology | 28,700 | 32 |

## 📖 Full Documentation

For the complete write-up — ER diagram, table-by-table schema summary,
constraint reasoning, all 3 reports with full output, and the 45 practice
questions with solutions — see:

**➡️ [docs/HOSPITAL_MANAGEMENT_SYSTEM.md](docs/HOSPITAL_MANAGEMENT_SYSTEM.md)**

## 🛠️ Built With

MySQL 8.0+ (uses `CHECK` constraints and window functions, both 8.0.16+/8.0+ features)

## 📌 Notes

This is a learning project built while studying SQL — schema design choices
(e.g. `RESTRICT` vs `CASCADE`, `ENUM` vs lookup tables) are deliberately
documented in the full write-up as talking points, not just implemented
silently.
