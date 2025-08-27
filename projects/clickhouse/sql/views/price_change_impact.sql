-- Price change impact analysis
CREATE VIEW analytics_db.price_change_impact AS
SELECT 
    ph.product_id,
    ph.change_reason,
    COUNT(*) as price_changes,
    AVG(ph.old_price) as avg_old_price,
    AVG(ph.new_price) as avg_new_price,
    AVG(ph.new_price - ph.old_price) as avg_price_change,
    CASE 
        WHEN AVG(ph.old_price) > 0 THEN ((AVG(ph.new_price) - AVG(ph.old_price)) / AVG(ph.old_price)) * 100.0
        ELSE 0
    END as avg_price_change_percentage,
    MIN(ph.effective_date) as first_change_date,
    MAX(ph.effective_date) as last_change_date,
    COUNT(CASE WHEN ph.new_price > ph.old_price THEN 1 END) as price_increases,
    COUNT(CASE WHEN ph.new_price < ph.old_price THEN 1 END) as price_decreases
FROM product_db.price_history ph
GROUP BY ph.product_id, ph.change_reason
HAVING COUNT(*) >= 1
ORDER BY avg_price_change_percentage DESC;
