-- create enum type "equipment_status"
CREATE TYPE "manufacturing"."equipment_status" AS ENUM ('available', 'running', 'idle', 'maintenance', 'breakdown', 'setup', 'offline');
