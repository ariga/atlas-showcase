-- create enum type "maintenance_type"
CREATE TYPE "manufacturing"."maintenance_type" AS ENUM ('preventive', 'corrective', 'predictive', 'emergency', 'calibration', 'inspection');
