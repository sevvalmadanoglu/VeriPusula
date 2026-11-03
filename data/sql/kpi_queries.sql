-- VeriPusula | SQLite KPI Queries
-- Source: bizinsight.db / sales
-- Recreated for the supplied database; these queries do not modify data.
-- Monetary values: TRY. Profit margin: percent of net revenue.
-- Run with SQLite connected to bizinsight.db.

-- 1. Overall performance
SELECT
    COUNT(*) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue_try,
    ROUND(SUM(total_cost), 2) AS total_cost_try,
    ROUND(SUM(profit), 2) AS total_profit_try,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct,
    ROUND(SUM(revenue) / NULLIF(COUNT(*), 0), 2) AS average_order_value_try
FROM sales;

-- 2. Category performance, highest revenue first
SELECT
    category,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue), 2) AS revenue_try,
    ROUND(SUM(profit), 2) AS profit_try,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct
FROM sales
GROUP BY category
ORDER BY SUM(revenue) DESC, category;

-- 3. Monthly performance
SELECT
    year_month,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue), 2) AS revenue_try,
    ROUND(SUM(profit), 2) AS profit_try,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct
FROM sales
GROUP BY year_month
ORDER BY year_month;

-- 4. Region performance
SELECT
    region,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue), 2) AS revenue_try,
    ROUND(SUM(profit), 2) AS profit_try,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct
FROM sales
GROUP BY region
ORDER BY SUM(revenue) DESC, region;

-- 5. Sales channel performance
SELECT
    sales_channel,
    COUNT(*) AS total_orders,
    ROUND(SUM(revenue), 2) AS revenue_try,
    ROUND(SUM(profit), 2) AS profit_try,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(revenue), 0), 2) AS profit_margin_pct
FROM sales
GROUP BY sales_channel
ORDER BY SUM(revenue) DESC, sales_channel;

-- 6. Top 10 products by revenue
SELECT
    product,
    category,
    SUM(quantity) AS units_sold,
    ROUND(SUM(revenue), 2) AS revenue_try,
    ROUND(SUM(profit), 2) AS profit_try
FROM sales
GROUP BY product, category
ORDER BY SUM(revenue) DESC, product, category
LIMIT 10;

-- 7. Highest and lowest revenue months in 2025 (includes ties)
WITH monthly AS (
    SELECT year_month, SUM(revenue) AS revenue, SUM(profit) AS profit
    FROM sales
    WHERE order_date >= '2025-01-01' AND order_date < '2026-01-01'
    GROUP BY year_month
)
SELECT
    'highest' AS revenue_rank,
    year_month,
    ROUND(revenue, 2) AS revenue_try,
    ROUND(profit, 2) AS profit_try
FROM monthly
WHERE revenue = (SELECT MAX(revenue) FROM monthly)
UNION ALL
SELECT
    'lowest' AS revenue_rank,
    year_month,
    ROUND(revenue, 2) AS revenue_try,
    ROUND(profit, 2) AS profit_try
FROM monthly
WHERE revenue = (SELECT MIN(revenue) FROM monthly);

