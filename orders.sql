-- Monthly Order Status and Revenue Analysis
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    AVG(order_amount) AS average_order_value,
    COUNT(CASE WHEN order_status = 'pending' THEN 1 END) AS pending_orders,
    COUNT(CASE WHEN order_status = 'shipped' THEN 1 END) AS shipped_orders,
    COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) AS delivered_orders,
    ROUND(COUNT(CASE WHEN order_status = 'delivered' THEN 1 END)::NUMERIC / COUNT(order_id) * 100, 2) AS delivery_rate
FROM 
    customer_orders
GROUP BY 
    DATE_TRUNC('month', order_date)
ORDER BY 
    month;

-- Year-over-Year Growth Analysis
SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(order_id) AS total_orders,
    SUM(order_amount) AS total_revenue,
    LAG(SUM(order_amount), 12) OVER (PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY EXTRACT(YEAR FROM order_date)) AS prev_year_revenue,
    CASE 
        WHEN LAG(SUM(order_amount), 12) OVER (PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY EXTRACT(YEAR FROM order_date)) IS NOT NULL 
        THEN ROUND((SUM(order_amount) - LAG(SUM(order_amount), 12) OVER (PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY EXTRACT(YEAR FROM order_date))) / 
                LAG(SUM(order_amount), 12) OVER (PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY EXTRACT(YEAR FROM order_date)) * 100, 2)
        ELSE NULL
    END AS yoy_growth_pct
FROM 
    customer_orders
GROUP BY 
    EXTRACT(YEAR FROM order_date), 
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    year, month;
