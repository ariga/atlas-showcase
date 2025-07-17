-- atlas:import ../public.sql

-- create "calculate_working_days" function
CREATE FUNCTION "public"."calculate_working_days" ("start_date" date, "end_date" date, "working_days" integer[] DEFAULT '{1,2,3,4,5}', "holidays" date[] DEFAULT '{}') RETURNS integer LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    days_count integer := 0;
    current_day date;
BEGIN
    current_day := start_date;
    WHILE current_day <= end_date LOOP
        IF EXTRACT(dow FROM current_day)::integer = ANY(working_days) 
           AND current_day != ALL(holidays) THEN
            days_count := days_count + 1;
        END IF;
        current_day := current_day + 1;
    END LOOP;
    RETURN days_count;
END;
$$;
