-- Support ticket analytics
CREATE VIEW analytics_db.support_ticket_metrics AS
SELECT 
    st.assigned_agent,
    st.category,
    st.priority,
    COUNT(*) as total_tickets,
    COUNT(CASE WHEN st.status = 'resolved' THEN 1 END) as resolved_tickets,
    COUNT(CASE WHEN st.status = 'closed' THEN 1 END) as closed_tickets,
    COUNT(CASE WHEN st.status IN ('open', 'in_progress') THEN 1 END) as active_tickets,
    CASE 
        WHEN COUNT(*) > 0 THEN (COUNT(CASE WHEN st.status IN ('resolved', 'closed') THEN 1 END) * 100.0) / COUNT(*)
        ELSE 0
    END as resolution_rate,
    AVG(CASE 
        WHEN st.resolved_at IS NOT NULL THEN dateDiff('hour', st.created_at, st.resolved_at)
        ELSE NULL
    END) as avg_resolution_time_hours,
    MIN(st.created_at) as earliest_ticket,
    MAX(st.created_at) as latest_ticket
FROM customer_db.support_tickets st
GROUP BY st.assigned_agent, st.category, st.priority
ORDER BY resolution_rate DESC, avg_resolution_time_hours ASC;
