-- create enum type "security_event_type"
CREATE TYPE "public"."security_event_type" AS ENUM ('login_attempt', 'access_denied', 'data_breach', 'malware_detected', 'policy_violation', 'system_anomaly');
