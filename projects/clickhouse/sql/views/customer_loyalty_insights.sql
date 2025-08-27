-- Customer loyalty insights
CREATE VIEW analytics_db.customer_loyalty_insights AS
SELECT 
    lp.customer_id,
    SUM(CASE WHEN lp.transaction_type = 'earned' THEN lp.points_earned ELSE 0 END) as total_points_earned,
    SUM(CASE WHEN lp.transaction_type = 'redeemed' THEN lp.points_redeemed ELSE 0 END) as total_points_redeemed,
    SUM(CASE WHEN lp.transaction_type = 'earned' THEN lp.points_earned ELSE 0 END) - 
    SUM(CASE WHEN lp.transaction_type = 'redeemed' THEN lp.points_redeemed ELSE 0 END) as current_point_balance,
    COUNT(DISTINCT CASE WHEN lp.transaction_type = 'earned' THEN lp.order_id END) as orders_with_points,
    COUNT(CASE WHEN lp.transaction_type = 'redeemed' THEN 1 END) as redemption_count,
    MIN(lp.created_at) as first_loyalty_activity,
    MAX(lp.created_at) as latest_loyalty_activity,
    CASE 
        WHEN SUM(CASE WHEN lp.transaction_type = 'earned' THEN lp.points_earned ELSE 0 END) > 0 
        THEN (SUM(CASE WHEN lp.transaction_type = 'redeemed' THEN lp.points_redeemed ELSE 0 END) * 100.0) / 
             SUM(CASE WHEN lp.transaction_type = 'earned' THEN lp.points_earned ELSE 0 END)
        ELSE 0
    END as redemption_rate_percentage
FROM customer_db.loyalty_points lp
GROUP BY lp.customer_id
HAVING total_points_earned > 0
ORDER BY current_point_balance DESC;
