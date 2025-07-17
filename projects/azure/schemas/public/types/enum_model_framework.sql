-- create enum type "model_framework"
CREATE TYPE "public"."model_framework" AS ENUM ('tensorflow', 'pytorch', 'scikit_learn', 'xgboost', 'lightgbm', 'keras', 'onnx', 'custom');
