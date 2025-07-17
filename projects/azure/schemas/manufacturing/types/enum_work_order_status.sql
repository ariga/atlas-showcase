-- create enum type "work_order_status"
CREATE TYPE "manufacturing"."work_order_status" AS ENUM ('planned', 'scheduled', 'in_progress', 'on_hold', 'completed', 'cancelled', 'requires_parts');
