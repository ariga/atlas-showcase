-- create enum type "report_type"
CREATE TYPE "public"."report_type" AS ENUM ('daily_standup', 'weekly_summary', 'sprint_review', 'milestone_report', 'executive_summary', 'risk_assessment', 'budget_report', 'team_performance', 'custom');
