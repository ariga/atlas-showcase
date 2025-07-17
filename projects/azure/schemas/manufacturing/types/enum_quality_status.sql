-- create enum type "quality_status"
CREATE TYPE "manufacturing"."quality_status" AS ENUM ('pass', 'fail', 'rework', 'pending', 'quarantine', 'released');
