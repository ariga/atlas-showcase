-- create enum type "alert_status"
CREATE TYPE "public"."alert_status" AS ENUM ('open', 'acknowledged', 'resolved', 'escalated');
