-- create enum type "constraint_type"
CREATE TYPE "public"."constraint_type" AS ENUM ('must_start_on', 'must_finish_on', 'start_no_earlier_than', 'start_no_later_than', 'finish_no_earlier_than', 'finish_no_later_than', 'as_soon_as_possible', 'as_late_as_possible');
