# sql-Data-Warehouse-Project
Building a modern data warehouse with SQL Server, including ETL processes, data modeling, and analytics.
Work in progress 
# 🏢 SQL Data Warehouse Project

> An end-to-end data warehouse project built with Microsoft SQL Server, focusing on ETL, data transformation, data modeling and analytics.

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

---

## 📌 Project Overview

This project demonstrates the design and implementation of a modern SQL Server data warehouse.

The main goal is to transform raw data into a structured and reliable data model that can be used for analytical queries and reporting.

The project covers the complete data workflow:

**Raw Data → ETL → Data Transformation → Data Warehouse → Analytics**

---

## 🏗️ Data Architecture

The warehouse is organized into three main layers:

| Layer | Description |
|---|---|
| 🥉 **Bronze** | Raw data loaded from source files |
| 🥈 **Silver** | Cleaned, transformed and standardized data |
| 🥇 **Gold** | Business-ready data prepared for analytics |

```text
                 ┌─────────────────┐
                 │   Source Data   │
                 │      CSV        │
                 └────────┬────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │  🥉 Bronze      │
                 │   Raw Data      │
                 └────────┬────────┘
                          │
                       ETL / SQL
                          │
                          ▼
                 ┌─────────────────┐
                 │  🥈 Silver      │
                 │ Cleaned Data    │
                 └────────┬────────┘
                          │
                    Transformation
                          │
                          ▼
                 ┌─────────────────┐
                 │   🥇 Gold       │
                 │ Analytics Layer │
                 └─────────────────┘
