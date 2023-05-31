ALTER TABLE template_version_parameters ADD COLUMN required boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN template_version_parameters.required IS 'Is parameter required?';
