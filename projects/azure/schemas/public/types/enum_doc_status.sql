-- create enum type "doc_status"
CREATE TYPE "public"."doc_status" AS ENUM ('draft', 'review', 'approved', 'published', 'archived');
