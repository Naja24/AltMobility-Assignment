SELECT 
    payment_method,
    COUNT(*) AS total_attempts,
    COUNT(CASE WHEN payment_status = 'completed' THEN 1 END) AS successful_payments,
    COUNT(CASE WHEN payment_status = 'failed' THEN 1 END) AS failed_payments,
    COUNT(CASE WHEN payment_status = 'pending' THEN 1 END) AS pending_payments,
    ROUND(COUNT(CASE WHEN payment_status = 'completed' THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS success_rate,
    ROUND(COUNT(CASE WHEN payment_status = 'failed' THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS failure_rate,
    ROUND(AVG(payment_amount), 2) AS avg_payment_amount
FROM 
    payments
GROUP BY 
    payment_method
ORDER BY 
    total_attempts DESC;


SELECT 
    DATE_TRUNC('month', payment_date) AS month,
    COUNT(*) AS total_attempts,
    COUNT(CASE WHEN payment_status = 'completed' THEN 1 END) AS successful_payments,
    COUNT(CASE WHEN payment_status = 'failed' THEN 1 END) AS failed_payments,
    ROUND(COUNT(CASE WHEN payment_status = 'completed' THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS success_rate,
    SUM(CASE WHEN payment_status = 'completed' THEN payment_amount ELSE 0 END) AS successful_revenue,
    SUM(CASE WHEN payment_status = 'failed' THEN payment_amount ELSE 0 END) AS failed_revenue
FROM 
    payments
GROUP BY 
    DATE_TRUNC('month', payment_date)
ORDER BY 
    month;
