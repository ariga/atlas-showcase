-- create enum type "order_status"
CREATE TYPE "manufacturing"."order_status" AS ENUM ('draft', 'pending_approval', 'approved', 'sent', 'acknowledged', 'in_transit', 'delivered', 'completed', 'cancelled');
