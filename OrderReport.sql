WITH payment_details AS (
    SELECT 
        order_id,
        COUNT(*) AS payment_attempts,
        COUNT(CASE WHEN payment_status = 'completed' THEN 1 END) AS successful_payments,
        COUNT(CASE WHEN payment_status = 'failed' THEN 1 END) AS failed_payments,
        SUM(CASE WHEN payment_status = 'completed' THEN payment_amount ELSE 0 END) AS total_paid,
        MAX(CASE WHEN payment_status = 'completed' THEN payment_date END) AS last_successful_payment,
        STRING_AGG(DISTINCT payment_method, ', ') AS payment_methods_used
    FROM 
        payments
    GROUP BY 
        order_id
)
SELECT 
    co.order_id,
    co.customer_id,
    co.order_date,
    co.order_amount,
    co.order_status,
    pd.payment_attempts,
    pd.successful_payments,
    pd.failed_payments,
    pd.total_paid,
    CASE
        WHEN co.order_amount = pd.total_paid THEN 'Fully Paid'
        WHEN pd.total_paid > 0 AND pd.total_paid < co.order_amount THEN 'Partially Paid'
        ELSE 'Not Paid'
    END AS payment_completion_status,
    pd.last_successful_payment,
    pd.payment_methods_used,
    ROUND((co.order_amount - pd.total_paid), 2) AS remaining_balance,
    DATE_PART('day', CURRENT_DATE - co.order_date) AS days_since_order
FROM 
    customer_orders co
LEFT JOIN 
    payment_details pd ON co.order_id = pd.order_id
ORDER BY 
    co.order_date DESC;
