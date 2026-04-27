Customer Churn Analysis
Tools: SQL Server · Power BI · Excel
Domain: Telecom / Subscription Business
Records Analyzed: 100,000+ customer records

Project Overview
This project analyzes customer churn behavior across a telecom dataset of 100,000+ records. Using SQL Server for data extraction and transformation, I identified key churn drivers across customer tenure, usage frequency, and billing history. The findings were visualized in a Power BI dashboard to help the retention team target high-risk customer segments.

Business Problem
A telecom company was experiencing high customer churn with no clear visibility into who was leaving or why. The goal was to:

Identify patterns in churned vs. retained customers
Segment customers by churn risk level (High / Mid / Low)
Provide actionable insights to the retention team


Dataset Description
File: customer_churn_dataset.csv
Rows: 100,000 customer records
Source: Simulated telecom dataset
ColumnDescriptioncustomer_idUnique customer identifiertenure_monthsNumber of months the customer has been activecontract_typeMonth-to-Month / One Year / Two Yearmonthly_chargesMonthly bill amount (₹)total_chargesTotal amount billed to date (₹)payment_methodAuto Pay / Manual / Bank Transfer / Credit Cardusage_frequencyNumber of service interactions per monthsupport_ticketsNumber of support tickets raised in last 6 monthsinternet_serviceDSL / Fiber Optic / Nochurn1 = Churned, 0 = Retained

SQL Analysis
File: churn_analysis_queries.sql
Queries Covered:

Overall churn rate
Churn by contract type
Churn by tenure band (using CTEs)
High-risk customer identification (using Window Functions)
Average charges — churned vs retained
Churn by payment method
Top churned segments by usage frequency
Rolling churn trend by month


Key Findings
InsightFindingOverall Churn Rate~26.5%Highest churn groupMonth-to-Month contract customersLowest churn groupTwo-year contract customers (< 5%)Tenure risk zoneCustomers with tenure < 12 months churn 3x moreBilling triggerCustomers with monthly charges > ₹70 churn 40% moreSupport ticketsCustomers with 3+ tickets have 58% churn rate

Power BI Dashboard
The dashboard includes:

Churn Rate KPI Card — overall and by segment
Churn by Contract Type — bar chart
Churn by Tenure Band — histogram
High-Risk Customer Table — filterable by region/contract
Monthly Charges vs Churn — scatter plot
Retention Opportunity Map — heat map by risk tier


Project Structure
customer-churn-analysis/
│
├── README.md                        ← You are here
├── customer_churn_dataset.csv       ← Dataset (100K records)
├── churn_analysis_queries.sql       ← All SQL queries with results
└── churn_analysis_excel.xlsx        ← Excel analysis + pivot tables

How to Run
SQL:

Import customer_churn_dataset.csv into SQL Server as customer_churn
Open churn_analysis_queries.sql in SQL Server Management Studio (SSMS)
Run queries section by section

Excel:

Open churn_analysis_excel.xlsx
Each sheet contains a separate analysis with pivot tables and charts


Skills Demonstrated

Advanced SQL: CTEs, Window Functions (ROW_NUMBER, NTILE, LAG), CASE statements
Data Cleaning: NULL handling, type casting, deduplication
Segmentation: RFM-style churn risk scoring
Power BI: DAX measures, KPI cards, drill-through filters
Excel: Pivot Tables, COUNTIFS, AVERAGEIFS, conditional formatting


Connect
LinkedIn: linkedin.com/in/praveen-kumar-58055231b
GitHub: github.com/praveenkumar-analyst
