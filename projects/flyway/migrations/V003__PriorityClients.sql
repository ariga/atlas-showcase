-- Generated script


-- deployment: Creating priorityclients...
CREATE TABLE priorityclients (
    FirstName varchar(24) NOT NULL,
    LastName varchar(45) NULL,
    ClientID int NULL
);
ALTER TABLE priorityclients ADD PRIMARY KEY (FirstName);

