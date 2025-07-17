-- create enum type "production_line_status"
CREATE TYPE "manufacturing"."production_line_status" AS ENUM ('planning', 'setup', 'running', 'maintenance', 'breakdown', 'changeover', 'shutdown');
