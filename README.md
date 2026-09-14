# 🏢 SQL Data Warehouse Project

> End-to-end data warehouse project built with Microsoft SQL Server, transforming raw CRM and ERP data into a clean, structured and analytics-ready data warehouse.

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

---

## 📌 Project Overview

This project demonstrates the design and implementation of an **end-to-end data warehouse using Microsoft SQL Server and T-SQL**.

The project takes raw data from multiple CRM and ERP source systems, loads it into a layered data warehouse, cleans and transforms the data, and finally creates a business-ready **Gold layer based on a Star Schema**.

The main objective was to practice real-world data engineering concepts such as:

- Data ingestion
- ETL processes
- Data cleansing
- Data transformation
- Data standardization
- Data quality validation
- Data modeling
- Star Schema design
- Fact and dimension tables
- Analytical data preparation

### 🔄 Overall Data Flow

```text
             ┌─────────────────────┐
             │     Source Data     │
             │                     │
             │   CRM       ERP     │
             │   CSV       CSV     │
             └──────────┬──────────┘
                        │
                        ▼
             ┌─────────────────────┐
             │    🥉 BRONZE        │
             │                     │
             │    Raw Data         │
             │  Data Ingestion     │
             └──────────┬──────────┘
                        │
                        ▼
             ┌─────────────────────┐
             │    🥈 SILVER        │
             │                     │
             │ Cleaning            │
             │ Transformation      │
             │ Standardization     │
             │ Data Quality        │
             └──────────┬──────────┘
                        │
                        ▼
             ┌─────────────────────┐
             │     🥇 GOLD         │
             │                     │
             │    Star Schema      │
             │                     │
             │ Dimensions + Fact   │
             └──────────┬──────────┘
                        │
                        ▼
             ┌─────────────────────┐
             │ Analytics & Reporting│
             └─────────────────────┘
```

---

# 🏗️ Data Warehouse Architecture

The warehouse follows a **three-layer architecture** based on the Medallion Architecture approach.

### 🥉 Bronze Layer

The Bronze layer contains raw data loaded directly from the source CSV files.

The data is preserved in its original form as much as possible, providing a raw foundation for further processing.

### 🥈 Silver Layer

The Silver layer contains cleaned, standardized and transformed data.

This layer prepares the raw data for analytical use by applying:

- Data cleansing
- Deduplication
- Standardization
- Data validation
- Business rules
- Date transformations
- Key transformations
- Handling of missing and invalid values

### 🥇 Gold Layer

The Gold layer contains business-ready views designed for analytics and reporting.

The final model follows a **Star Schema** consisting of:

- Customer dimension
- Product dimension
- Sales fact

---

# 📂 Source Data

The project uses two source systems: **CRM** and **ERP**.

## CRM

The CRM system contains:

```text
cust_info.csv
prd_info.csv
sales_details.csv
```

These datasets provide information about:

- Customers
- Products
- Sales transactions

## ERP

The ERP system contains:

```text
CUST_AZ12.csv
LOC_A101.csv
PX_CAT_G1V2.csv
```

These datasets provide additional information about:

- Customer birth dates and gender
- Customer locations
- Product categories and maintenance information

---

# 🥉 Bronze Layer

The Bronze layer is responsible for loading raw source data into SQL Server.

### Bronze Tables

```text
bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details

bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2
```

The Bronze layer uses SQL Server's `BULK INSERT` functionality to load CSV files.

The loading process is implemented in:

```text
scripts/bronze/proc_load_bronze.sql
```

The Bronze tables are created using:

```text
scripts/bronze/create_bronze_tables.sql
```

---

# 🥈 Silver Layer

The Silver layer is responsible for **data cleansing, transformation and standardization**.

The Silver layer contains cleaned versions of the CRM and ERP datasets.

### Silver Tables

```text
silver.crm_cust_info
silver.crm_prd_info
silver.crm_sales_details

silver.erp_cust_az12
silver.erp_loc_a101
silver.erp_px_cat_g1v2
```

---

## 👤 Customer Transformation

Customer data is cleaned and standardized before being loaded into the Silver layer.

The transformation process includes:

- Removing unnecessary spaces
- Filtering records with missing customer IDs
- Removing duplicate customer records
- Keeping the most recent customer record
- Standardizing marital status
- Standardizing gender values

For example:

```text
S → Single
M → Married
```

Gender values are standardized as:

```text
F → Female
M → Male
```

Unknown or unexpected values are converted to:

```text
Unknown
```

Duplicate customer records are handled using:

```sql
ROW_NUMBER() OVER (
    PARTITION BY cst_id
    ORDER BY cst_create_date DESC
)
```

This ensures that the most recent customer record is retained.

---

# 📦 Product Transformation

Product data is transformed before being loaded into the Silver layer.

The transformation includes:

- Extracting category IDs
- Separating product keys
- Handling missing product costs
- Standardizing product lines
- Converting dates
- Creating product end dates

Product line codes are transformed into readable values:

```text
M → Mountain
R → Road
S → Other Sales
T → Touring
```

Historical product records are tracked using:

```sql
LEAD(prd_start_dt)
OVER (
    PARTITION BY prd_key
    ORDER BY prd_start_dt
)
```

The product end date is calculated as one day before the next product version starts.

---

# 💰 Sales Transformation

Sales data is cleaned and validated before being loaded into the Silver layer.

The transformation process includes:

- Converting integer-based dates into SQL `DATE`
- Handling invalid dates
- Validating order, shipping and due dates
- Validating sales amounts
- Validating quantities
- Validating prices
- Recalculating incorrect sales values

The main business rule is:

```text
Sales Amount = Quantity × Price
```

Invalid values are corrected before the data reaches the Gold layer.

---

# 🌍 ERP Data Transformation

ERP datasets require additional cleaning before being integrated with CRM data.

## Customer ERP Data

The customer ERP dataset contains:

- Customer ID
- Birth date
- Gender

Customer identifiers are cleaned and standardized so that they can be joined with CRM customer data.

Birth dates are also validated.

## Location Data

Country information is cleaned and standardized.

Customer identifiers are transformed to match the CRM identifiers.

## Product Category Data

Product category information contains:

- Category
- Subcategory
- Maintenance

These values are cleaned and standardized before being integrated into the final product dimension.

---

# 🔄 Silver ETL Process

The Silver transformation process is implemented using a stored procedure:

```sql
EXEC silver.load_silver;
```

The process can be summarized as:

```text
Bronze Tables
      │
      ▼
Truncate Silver Tables
      │
      ▼
Clean & Transform Data
      │
      ▼
Apply Business Rules
      │
      ▼
Insert Into Silver
```

---

# 🥇 Gold Layer

The Gold layer provides the final business-ready data model.

The Gold layer uses a **Star Schema**.

```text
                     ┌─────────────────────┐
                     │    dim_customer     │
                     │─────────────────────│
                     │ Customer_Key        │
                     │ Customer_ID         │
                     │ Customer_Number     │
                     │ First_Name          │
                     │ Last_Name           │
                     │ Country             │
                     │ Marital_Status      │
                     │ Gender              │
                     │ Birth_Date          │
                     │ Create_Date         │
                     └──────────┬──────────┘
                                │
                                │
                                ▼
                     ┌─────────────────────┐
                     │     fact_sales      │
                     │─────────────────────│
                     │ Order_Number        │
                     │ Product_Key         │
                     │ Customer_Key        │
                     │ Order_Date          │
                     │ Shipping_Date       │
                     │ Due_Date            │
                     │ Sales_Amount        │
                     │ Sales_Quantity      │
                     │ Price               │
                     └──────────┬──────────┘
                                │
                                │
                                ▼
                     ┌─────────────────────┐
                     │    dim_product      │
                     │─────────────────────│
                     │ Product_Key         │
                     │ Product_ID          │
                     │ Product_Number      │
                     │ Product_Name        │
                     │ Category_ID         │
                     │ Category            │
                     │ Subcategory         │
                     │ Maintenance         │
                     │ Product_Cost        │
                     │ Product_Line        │
                     │ Start_Date          │
                     └─────────────────────┘
```

---

# 👤 Customer Dimension

The customer dimension combines CRM and ERP information into a single customer profile.

The Gold customer view contains:

- Customer ID
- Customer number
- First name
- Last name
- Country
- Marital status
- Gender
- Birth date
- Customer creation date

CRM is treated as the master source for gender information where available.

If CRM gender is unknown, ERP data is used as a fallback.

---

# 📦 Product Dimension

The product dimension combines CRM product information with ERP category data.

It contains:

- Product ID
- Product number
- Product name
- Category ID
- Category
- Subcategory
- Maintenance
- Product cost
- Product line
- Start date

Only the current version of each product is included in the Gold layer.

Historical product records are filtered using:

```sql
WHERE prd_end_dt IS NULL
```

---

# 💰 Sales Fact

The Sales Fact combines sales transactions with the Customer and Product dimensions.

It contains:

- Order number
- Product key
- Customer key
- Order date
- Shipping date
- Due date
- Sales amount
- Sales quantity
- Price

The fact table connects to the dimensions using surrogate keys.

This makes the final model suitable for analytical queries and reporting.

---

# 🧪 Data Quality

Data quality validation is an important part of this project.

Dedicated SQL scripts are included in the `tests/` directory.

```text
tests/
├── quality_checks_silver.sql
└── quality_checks_gold.sql
```

---

## Silver Quality Checks

The Silver layer tests include validation for:

### Customer Data

- NULL customer IDs
- Duplicate customer IDs
- Unwanted spaces
- Marital status standardization
- Gender standardization

### Product Data

- NULL product IDs
- Duplicate product IDs
- Unwanted spaces
- NULL product costs
- Negative product costs
- Product line standardization
- Invalid start/end dates

### Sales Data

- Invalid dates
- Incorrect date order
- Invalid sales amounts
- Invalid quantities
- Invalid prices
- Sales calculation consistency

The main sales validation rule is:

```text
Sales Amount = Quantity × Price
```

### ERP Data

Additional checks validate:

- Birth dates
- Gender values
- Country values
- Customer identifiers
- Product category values
- Unwanted spaces

---

# 🧪 Gold Quality Checks

The Gold layer contains tests for:

### Dimension Key Uniqueness

Customer and product surrogate keys are checked for duplicates.

### Referential Integrity

The Sales Fact is checked to ensure that every customer and product key can be matched with the corresponding dimension.

This ensures that the Star Schema relationships remain valid.

---

# 📁 Project Structure

```text
Data-Warehouse-Project/
│
├── 📂 datasets/
│   │
│   ├── 📂 source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   │
│   └── 📂 source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
│
├── 📂 docs/
│   └── Project documentation
│
├── 📂 scripts/
│   │
│   ├── init_database.sql
│   │
│   ├── 📂 bronze/
│   │   ├── create_bronze_tables.sql
│   │   └── proc_load_bronze.sql
│   │
│   ├── 📂 silver/
│   │   ├── ddl.silver.sql
│   │   └── proc_load_silver.sql
│   │
│   └── 📂 gold/
│       └── ddl.dot.sql
│
├── 📂 tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
│
├── 📄 LICENSE
└── 📄 README.md
```

---

# ⚙️ Setup & Execution

## 1. Clone the Repository

```bash
git clone https://github.com/filip-Nowak190/Data-Warehouse-Project.git
```

## 2. Open SQL Server Management Studio

Connect to your SQL Server instance.

## 3. Initialize the Database

Run:

```text
scripts/init_database.sql
```

This creates the following database structure:

```text
DataWarehouse
├── bronze
├── silver
└── gold
```

> ⚠️ **Warning:** The initialization script drops the existing `DataWarehouse` database before recreating it.

## 4. Create Bronze Tables

Run:

```text
scripts/bronze/create_bronze_tables.sql
```

## 5. Load the Bronze Layer

Run:

```text
scripts/bronze/proc_load_bronze.sql
```

Then execute the Bronze loading procedure.

## 6. Create Silver Tables

Run:

```text
scripts/silver/ddl.silver.sql
```

## 7. Create the Silver Loading Procedure

Run:

```text
scripts/silver/proc_load_silver.sql
```

Then execute:

```sql
EXEC silver.load_silver;
```

## 8. Create Gold Views

Run:

```text
scripts/gold/ddl.dot.sql
```

This creates the analytical Gold views.

## 9. Run Data Quality Checks

After loading the Silver layer:

```text
tests/quality_checks_silver.sql
```

After creating the Gold layer:

```text
tests/quality_checks_gold.sql
```

---

# 🛠️ Technologies

### Database

- Microsoft SQL Server

### Language

- T-SQL

### Data Processing

- ETL
- Data Cleaning
- Data Transformation
- Data Validation

### Data Modeling

- Star Schema
- Fact Tables
- Dimension Tables
- Surrogate Keys

### Tools

- SQL Server Management Studio
- Git
- GitHub

---

# 🎯 Key Skills Demonstrated

This project demonstrates practical experience with:

- SQL Server
- T-SQL
- ETL development
- Data ingestion
- Data cleansing
- Data transformation
- Data standardization
- Data validation
- Data quality testing
- Data modeling
- Star Schema
- Fact and Dimension tables
- Surrogate keys
- Stored Procedures
- SQL Views
- Window Functions
- CTEs
- Joins
- Aggregations
- Git & GitHub

---

# 🧠 What I Learned

Building this project helped me understand how raw operational data can be transformed into a structured analytical data warehouse.

The main concepts I practiced were:

### Data Engineering

- Designing a layered data warehouse
- Building an ETL pipeline
- Loading data from multiple source systems
- Transforming raw data using T-SQL

### Data Quality

- Detecting duplicates
- Handling missing values
- Validating dates
- Checking numerical consistency
- Standardizing categorical values
- Validating relationships between tables

### Data Modeling

- Designing dimensions
- Designing fact tables
- Creating surrogate keys
- Building a Star Schema
- Combining data from different source systems

### SQL

- Window functions
- `ROW_NUMBER()`
- `LEAD()`
- `CASE`
- `COALESCE`
- `ISNULL`
- `TRIM`
- `CAST`
- `CONVERT`
- CTEs
- Joins
- Stored Procedures
- Views

---

# 🚀 Future Improvements

Possible next steps for the project include:

- 📊 Building a Power BI dashboard
- 📈 Adding analytical SQL queries
- 🐍 Integrating Python into the ETL process
- ☁️ Migrating the warehouse to Azure
- ⚡ Improving ETL performance
- 🔄 Implementing incremental loading
- 🤖 Automating the ETL pipeline
- 🧪 Expanding automated data quality checks
- 📚 Adding additional documentation and data lineage

---

# 📌 Project Status

**Completed — with planned future improvements.**

The core data warehouse pipeline is implemented:

```text
CRM + ERP
    ↓
Bronze
    ↓
Silver
    ↓
Gold
    ↓
Star Schema
    ↓
Analytics
```

---

# 👨‍💻 About Me

I'm currently developing my skills in:

**Data Analytics & Data Engineering**

My main areas of focus are:

```text
SQL
Data Analysis
Data Warehousing
ETL
Data Modeling
Python
Power BI
Azure
```

I'm building practical projects to improve my technical skills and prepare for a career as a **Data Analyst / Data Engineer**.

---

# 📫 Contact

**Filip Nowak**

GitHub:  
https://github.com/filip-Nowak190

---

⭐ If you found this project useful or interesting, feel free to explore the repository.
