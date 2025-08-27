-- Product review analytics
CREATE VIEW analytics_db.product_review_summary AS
SELECT 
    pr.product_id,
    COUNT(*) as total_reviews,
    AVG(pr.rating) as average_rating,
    COUNT(CASE WHEN pr.rating = 5 THEN 1 END) as five_star_reviews,
    COUNT(CASE WHEN pr.rating = 1 THEN 1 END) as one_star_reviews,
    COUNT(CASE WHEN pr.is_verified_purchase = 1 THEN 1 END) as verified_reviews,
    SUM(pr.helpful_votes) as total_helpful_votes,
    SUM(pr.total_votes) as total_votes,
    CASE 
        WHEN SUM(pr.total_votes) > 0 THEN (SUM(pr.helpful_votes) * 100.0) / SUM(pr.total_votes)
        ELSE 0
    END as helpfulness_percentage,
    MIN(pr.review_date) as first_review_date,
    MAX(pr.review_date) as latest_review_date
FROM product_db.product_reviews pr
WHERE pr.status = 'approved'
GROUP BY pr.product_id
HAVING COUNT(*) >= 1
ORDER BY average_rating DESC, total_reviews DESC;
