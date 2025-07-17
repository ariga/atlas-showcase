-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/suppliers.sql
-- atlas:import ../types/enum_supplier_status.sql
-- atlas:import ../../public/tables/users.sql

-- create "supplier_performance_scorecard" view
CREATE VIEW "manufacturing"."supplier_performance_scorecard" (
  "supplier_id",
  "supplier_name",
  "supplier_code",
  "status",
  "quality_rating",
  "delivery_rating",
  "cost_rating",
  "risk_score",
  "procurement_manager",
  "supplier_tier",
  "overall_score"
) AS SELECT s.id AS supplier_id,
    s.name AS supplier_name,
    s.code AS supplier_code,
    s.status,
    s.quality_rating,
    s.delivery_rating,
    s.cost_rating,
    s.risk_score,
    (u.first_name::text || ' '::text) || u.last_name::text AS procurement_manager,
        CASE
            WHEN s.quality_rating >= 4.5 AND s.delivery_rating >= 4.5 THEN 'preferred'::text
            WHEN s.quality_rating >= 3.5 AND s.delivery_rating >= 3.5 THEN 'approved'::text
            WHEN s.quality_rating >= 2.5 OR s.delivery_rating >= 2.5 THEN 'conditional'::text
            ELSE 'review_required'::text
        END AS supplier_tier,
    (s.quality_rating + s.delivery_rating + s.cost_rating) / 3::numeric AS overall_score
   FROM manufacturing.suppliers s
     LEFT JOIN public.users u ON s.procurement_manager_id = u.id
  WHERE s.status <> 'terminated'::manufacturing.supplier_status;
