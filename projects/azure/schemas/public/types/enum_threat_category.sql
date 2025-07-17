-- create enum type "threat_category"
CREATE TYPE "public"."threat_category" AS ENUM ('malware', 'phishing', 'ddos', 'data_theft', 'unauthorized_access', 'insider_threat');
