-- create enum type "schedule_type"
CREATE TYPE "public"."schedule_type" AS ENUM ('project_master', 'sprint_schedule', 'resource_plan', 'milestone_track', 'baseline', 'what_if_scenario');
