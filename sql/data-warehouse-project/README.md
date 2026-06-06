# SQL Data Warehouse Project

This project builds a data warehouse using SQL Server. It takes raw sales data from two source systems : an ERP and a CRM : and processes it through a series of steps to produce clean, structured data ready for business reporting and analysis.


## What This Project Does

The project covers the full journey of data : from raw CSV files all the way to a reporting-ready database model. It handles data ingestion, cleaning, transformation, and modelling, and finishes with SQL-based analytics covering sales, customers, and products.

## Architecture

The project follows a three-layer approach called Medallion Architecture.

**Bronze layer** : raw data is loaded exactly as it comes from the source files. Nothing is changed or cleaned at this stage. It serves as a reliable record of the original data.

**Silver layer** : the raw data is cleaned and standardised here. This includes removing duplicates, handling missing values, fixing data types, and joining the ERP and CRM data together into one consistent dataset.

**Gold layer** : the cleaned data is modelled into a star schema, which is a structure designed for fast and easy querying. This is where all the reporting and analytics happen.

## Data Model

The Gold layer uses a star schema with one central fact table and supporting dimension tables.

- `fact_sales` : the main table containing sales transactions, with amounts, quantities, and dates
- `dim_customer` : customer details such as name, gender, country, and marital status
- `dim_product` : product information including category, subcategory, and cost
- `dim_date` : a date table with year, month, quarter, and week breakdowns

The dimension tables connect to `fact_sales` through foreign keys, making it straightforward to slice and analyse the data from any angle.

## ETL Pipeline

The data moves through three stages.

1. **Extract** : CSV files from the ERP and CRM are read and loaded into the Bronze layer using bulk insert. Basic validation like schema checks and row counts is done here.

2. **Transform** : the Bronze data is cleaned, standardised, and joined in the Silver layer. This step handles all the data quality issues before modelling begins.

3. **Load** : the Silver data is modelled into the star schema and published to the Gold layer, where it is tested for quality and made available for reporting.


## Analytics

Three areas of analysis are built on top of the Gold layer.

**Customer behaviour** : looks at how customers purchase, how often they buy, and their overall value to the business.

**Product performance** : identifies top-selling products, revenue by category, and margin trends.

**Sales trends** : tracks revenue over time, compares periods, and breaks down performance by region and order size.


## Repository Structure

```
sql-data-warehouse-project/
│
├── datasets/          Raw CSV files from ERP and CRM
├── docs/              Architecture diagrams and data catalog
├── scripts/
│   ├── bronze/        Scripts to load raw data
│   ├── silver/        Scripts to clean and transform data
│   └── gold/          Scripts to build the star schema
├── tests/             Data quality checks
├── README.md
└── LICENSE
```


## How to Run

1. Clone this repository
2. Install SQL Server Express and SSMS
3. Run the scripts in order : bronze first, then silver, then gold
4. Run the test scripts to verify data quality
5. Open the analytics scripts in SSMS to query the Gold layer


## Tools Used

- SQL Server Express : database engine
- SSMS : for writing and running SQL queries
- T-SQL : language used for all scripts
- Draw.io : for architecture and flow diagrams
- Git and GitHub : version control

## License

This project is licensed under the MIT License. You are free to use, modify, and share it with proper credit.

---

*This is a guided project completed as part of the DataWithBaraa SQL Data Warehouse course.*
