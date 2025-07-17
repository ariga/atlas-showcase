-- create enum type "device_status"
CREATE TYPE "public"."device_status" AS ENUM ('active', 'inactive', 'maintenance', 'offline', 'error');
