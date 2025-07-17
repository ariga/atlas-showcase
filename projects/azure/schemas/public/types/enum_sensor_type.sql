-- create enum type "sensor_type"
CREATE TYPE "public"."sensor_type" AS ENUM ('temperature', 'humidity', 'pressure', 'motion', 'light', 'air_quality', 'water_level', 'power_consumption');
