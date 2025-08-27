-- Return analysis view
CREATE VIEW analytics_db.return_analysis AS
SELECT 
    r.return_reason,
    r.return_status,
    COUNT(*) as total_returns,
    SUM(r.return_quantity) as total_quantity_returned,
    SUM(r.refund_amount) as total_refund_amount,
    AVG(r.refund_amount) as avg_refund_amount,
    COUNT(CASE WHEN r.return_status = 'processed' THEN 1 END) as processed_returns,
    COUNT(CASE WHEN r.return_status = 'rejected' THEN 1 END) as rejected_returns,
    CASE 
        WHEN COUNT(*) > 0 THEN (COUNT(CASE WHEN r.return_status = 'processed' THEN 1 END) * 100.0) / COUNT(*)
        ELSE 0
    END as processing_rate,
    AVG(CASE 
        WHEN r.processed_date IS NOT NULL THEN dateDiff('day', r.return_date, r.processed_date)
        ELSE NULL
    END) as avg_processing_days
FROM order_db.returns r
GROUP BY r.return_reason, r.return_status
ORDER BY total_returns DESC;
