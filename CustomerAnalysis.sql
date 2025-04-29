WITH customer_frequency AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count,
        SUM(order_amount) AS total_spent,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATE_PART('day', MAX(order_date) - MIN(order_date)) AS customer_lifetime_days
    FROM 
        customer_orders
    GROUP BY 
        customer_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Repeat (2-5)'
        WHEN order_count BETWEEN 6 AND 10 THEN 'Frequent (6-10)'
        ELSE 'Loyal (11+)'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    ROUND(AVG(customer_lifetime_days), 0) AS avg_customer_lifetime_days,
    ROUND(SUM(total_spent) / SUM(order_count), 2) AS avg_order_value
FROM 
    customer_frequency
GROUP BY 
    CASE 
        WHEN order_count = 1 THEN 'One-time'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Repeat (2-5)'
        WHEN order_count BETWEEN 6 AND 10 THEN 'Frequent (6-10)'
        ELSE 'Loyal (11+)'
    END
ORDER BY 
    customer_count DESC;

WITH customer_first_order AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM 
        customer_orders
    GROUP BY 
        customer_id
)
SELECT 
    DATE_TRUNC('month', co.order_date) AS month,
    COUNT(DISTINCT co.customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN co.order_date = cfo.first_order_date THEN co.customer_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN co.order_date > cfo.first_order_date THEN co.customer_id END) AS returning_customers,
    ROUND(COUNT(DISTINCT CASE WHEN co.order_date = cfo.first_order_date THEN co.customer_id END)::NUMERIC / 
          COUNT(DISTINCT co.customer_id) * 100, 2) AS new_customer_percentage
FROM 
    customer_orders co
JOIN 
    customer_first_order cfo ON co.customer_id = cfo.customer_id
GROUP BY 
    DATE_TRUNC('month', co.order_date)
ORDER BY 
    month;
