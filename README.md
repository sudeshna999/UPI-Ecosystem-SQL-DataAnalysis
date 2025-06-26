#  UPI Ecosystem Data Analysis Project — MySQL + Excel

> **“Analyzing transaction patterns and banking performance in India’s UPI network using advanced SQL and Excel-based datasets.”**

---

##  Project Summary

This project explores the **Unified Payments Interface (UPI)** ecosystem using real-world data stored in Excel files. It leverages **MySQL** to analyze millions of transactions between UPI applications and banks (both remitters and beneficiaries), spanning from **2022 to 2024**.

The objective is to uncover high-level insights such as app dominance, banking inefficiencies, transaction mismatches, and monthly performance fluctuations — all backed by robust SQL logic.

---

##  Business Problem

Despite rapid adoption, the UPI ecosystem faces several challenges:

- High decline/reversal rates in some banks  
- Inconsistent performance across apps (B2B/B2C)  
- Data mismatches between remitter and beneficiary records  
- Missed opportunities due to lack of visibility into trends  

These issues impact **user experience**, **trust**, and **network performance**.

---

##  Objective

To identify inefficiencies and improvement opportunities in UPI transactions by:

- Pinpointing top-performing apps and banks  
- Monitoring monthly trends and anomalies  
- Detecting approval consistency or fluctuations  
- Identifying transaction volume mismatches  
- Creating reusable views and procedures for long-term monitoring  

---

##  Dataset Overview

| Table | Description |
|-------|-------------|
| `upi_apps` | Volume/value by application (B2B, B2C, total) |
| `remmiter_banks` | Bank-level approval %, decline %, reversal rates |
| `benefeciary_banks` | Deemed approvals, actual approvals, volume metrics |

- **Source**: Excel (Kaggle Dataset)
- **Period Covered**: 2022–2024  
- **Volume**: 300K+ records across 12+ months

---

##  Tech Stack

| Tool | Purpose |
|------|---------|
| **MySQL** | Data analysis, joins, window functions |
| **Advanced SQL** | CTEs, views, stored procedures |
| **Excel (CSV format)** | Data storage, import to MySQL |
| **Command Line** | For bulk data import via `LOAD DATA` |

---

##  Key Analyses

###  App-Level Insights
- Top 3 UPI apps by total customer transaction value  
- Month-over-month % change in volume  
- B2B vs B2C volume share per app  
- Apps with B2B dominance in more than 3 months  

###  Bank-Level Insights
- Banks with highest debit reversal success  
- Beneficiary banks with consistently high deemed approval %  
- Decline trends: BD% > 10% and TD% > 5%  
- Banks with approval mismatch as remitter vs beneficiary  
- Volume mismatch in sent vs received transactions  
- Banks with consistent high approval using 3-month moving avg  
- Top-N banks by volume and their first entry dates (procedure)

---

##  SQL Techniques Used

- `CTEs` (Common Table Expressions)  
- `LAG()` and `RANK()` (Window Functions)  
- `Views` for reusability and reporting  
- `Stored Procedure` for dynamic filtering (e.g., top N banks)  
- Date parsing and cleaning via `STR_TO_DATE()`

---

##  Project Structure

```plaintext
 Data Analysis.sql                 # SQL scripts for complete analysis
 UPI_Ecosystem_Documentation.pptx # Business findings and insights
 Excel Datasets (external)         # upi_apps.csv, remmiter_banks.csv, benefeciary_banks.csv
 README.md                         # Documentation overview
```
---

## Sample SQL Outputs
App dominance: PhonePe, GPay, Paytm — >85% of value

Top bank (B2C): Axis Bank

Stable approvals: Standard Chartered >95% for 3+ months

Volume mismatch: Found in multiple banks between sender/receiver

High-decline banks: Maharashtra Gramin Bank >10% BD%

---
## Sample Stored Procedure
```CALL get_topN_entry_by_volume_filtered(5);
```
Dynamically identifies when banks first entered Top N by volume

---

## Author
### — Sudeshna Dey
###  — Contact & Contributions

####  Email: sudeshnadey1000@gmail.com
####  LinkedIn: https://www.linkedin.com/in/sudeshna-dey-724a811a0/
 Have feedback or suggestions? I'm always open to improving and collaborating!
 
If you find this project helpful:
Give it a star
Thanks for visiting — and happy data analyzing!
