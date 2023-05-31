CREATE TABLE networks (
  id char(36) NOT NULL,
  PRIMARY KEY(id),
  created_at TIMESTAMP(0) NOT NULL,
  updated_at TIMESTAMP(0) NOT NULL
);

CREATE TABLE keto_uuid_mappings
(
    id                       UUID NOT NULL PRIMARY KEY,
    string_representation    TEXT NOT NULL CHECK (string_representation <> '')
);