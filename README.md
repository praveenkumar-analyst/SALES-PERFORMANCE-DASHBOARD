
# Sales Performance Dashboard

**Tools:** Power BI · SQL Server · DAX  
**Domain:** Retail / Sales Analytics  
**Records Analyzed:** 500,000+ sales transactions

---

## Project Overview

This project delivers an end-to-end interactive Sales Performance Dashboard built for management reporting. Using SQL Server for data extraction and transformation, and Power BI with advanced DAX measures, the dashboard provides real-time visibility into revenue trends, regional performance, product rankings, and time-based KPIs — enabling self-serve business reporting across the organization.

---

## Business Problem

The sales leadership team had no centralized view of performance across regions, categories, and time periods. Monthly reporting was done manually in Excel, causing delays and inconsistencies. The goal was to:

- Track Month-over-Month (MoM) and Year-to-Date (YTD) revenue automatically
- Identify top-performing and underperforming products by region
- Enable drill-down filtering without IT involvement
- Replace manual Excel reports with a self-serve dashboard

---

## Dataset Description

**File:** `sales_performance_dataset.csv`  
**Rows:** 500,000 sales transactions  
**Period:** Jan 2022 – Dec 2024 (3 years)

| Column | Description |
|--------|-------------|
| order_id | Unique transaction identifier |
| order_date | Date of the sale (YYYY-MM-DD) |
| region | North / South / East / West |
| state | State of the sale |
| category | Product category (Electronics, Clothing, Furniture, Food, Sports) |
| sub_category | Sub-category within the category |
| product_name | Name of the product sold |
| sales_rep | Name of the sales representative |
| quantity | Number of units sold |
| unit_price | Price per unit (₹) |
| discount | Discount applied (0.0 – 0.4) |
| revenue | Final revenue after discount (₹) |
| profit | Profit on the transaction (₹) |
| profit_margin | Profit as % of revenue |

---

## SQL Analysis

**File:** `sales_analysis_queries.sql`

### Queries Covered:
1. Total revenue, profit, and order count summary
2. Month-over-Month (MoM) revenue growth using LAG()
3. Year-to-Date (YTD) revenue using running totals
4. Top-N products by revenue (with DENSE_RANK)
5. Revenue by region and category
6. Sales rep performance ranking
7. Discount impact analysis
8. Quarterly revenue trend
9. Best and worst performing months

---

## Key Findings

| Insight | Finding |
|--------|---------|
| Total Revenue (3 Years) | ₹48.2 Crore |
| Best Performing Region | North (32% of total revenue) |
| Top Category | Electronics (38% of revenue) |
| Highest MoM Growth | Nov 2023 (+22% — festive season) |
| Avg Profit Margin | 18.4% |
| Top Sales Rep | Amit Sharma (₹4.2Cr in 3 years) |
| Discount Risk | Orders with >30% discount have negative profit margin |

---

## Power BI Dashboard — DAX Measures

### Key DAX Measures Used:

```dax
-- Total Revenue
Total Revenue = SUM(sales[revenue])

-- Month-over-Month Growth %
MoM Growth % =
VAR CurrentMonth = [Total Revenue]
VAR PrevMonth = CALCULATE([Total Revenue], DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PrevMonth, PrevMonth, 0)

-- Year-to-Date Revenue
YTD Revenue = TOTALYTD([Total Revenue], 'Date'[Date])

-- Top N Products (dynamic parameter)
Top N Revenue =
CALCULATE(
    [Total Revenue],
    TOPN([TopN Parameter], ALL(sales[product_name]), [Total Revenue])
)

-- Running Total Revenue
Running Total =
CALCULATE(
    [Total Revenue],
    FILTER(
        ALL('Date'[Date]),
        'Date'[Date] <= MAX('Date'[Date])
    )
)
```

---

## Dashboard Features

- **KPI Cards** — Total Revenue, Profit, Orders, Avg Order Value
- **MoM Revenue Trend** — Line chart with growth % annotations
- **YTD vs PYTD Comparison** — Bar chart by month
- **Top-N Products** — Dynamic ranking with slicer (Top 5 / 10 / 20)
- **Region Map** — Filled map with revenue heat
- **Category Drill-Down** — Category → Sub-category → Product
- **Sales Rep Leaderboard** — Table with conditional formatting
- **Discount vs Profit Scatter** — Correlation chart

---

## Project Structure

```
sales-performance-dashboard/
│
├── README.md                        ← You are here
├── sales_performance_dataset.csv    ← Dataset (500K transactions)
├── sales_analysis_queries.sql       ← All SQL queries with results
└── sales_analysis_excel.xlsx        ← Excel pivot analysis + charts
```

---

## How to Run

**SQL:**
1. Import `sales_performance_dataset.csv` into SQL Server as `sales_performance`
2. Open `sales_analysis_queries.sql` in SSMS
3. Run queries section by section

**Excel:**
1. Open `sales_analysis_excel.xlsx`
2. Each sheet has a separate pivot analysis and chart

**Power BI:**
1. Connect Power BI Desktop to your SQL Server table
2. Recreate DAX measures from the formulas above
3. Build visuals using the field list

---

## Skills Demonstrated

- Advanced SQL: Window Functions (LAG, DENSE_RANK, NTILE, SUM OVER), CTEs, CASE
- DAX: TOTALYTD, DATEADD, TOPN, DIVIDE, CALCULATE, Running Totals
- Power BI: Drill-through, dynamic Top-N slicers, filled maps, KPI cards
- Excel: Pivot Tables, SUMIFS, AVERAGEIFS, RANK, conditional formatting, charts

---

## Connect

**LinkedIn:** [linkedin.com/in/praveen-kumar-58055231b](https://linkedin.com/in/praveen-kumar-58055231b)  
**GitHub:** [github.com/praveenkumar-analyst](https://github.com/praveenkumar-analyst)

