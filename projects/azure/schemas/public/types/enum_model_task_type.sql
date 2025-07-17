-- create enum type "model_task_type"
CREATE TYPE "public"."model_task_type" AS ENUM ('classification', 'regression', 'clustering', 'recommendation', 'nlp', 'computer_vision', 'time_series', 'reinforcement_learning', 'generative');
