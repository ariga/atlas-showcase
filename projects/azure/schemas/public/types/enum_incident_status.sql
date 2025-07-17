-- create enum type "incident_status"
CREATE TYPE "public"."incident_status" AS ENUM ('detected', 'investigating', 'contained', 'resolved', 'post_mortem');
