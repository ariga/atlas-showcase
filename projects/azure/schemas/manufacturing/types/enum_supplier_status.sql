-- create enum type "supplier_status"
CREATE TYPE "manufacturing"."supplier_status" AS ENUM ('active', 'pending_approval', 'suspended', 'terminated', 'under_review');
