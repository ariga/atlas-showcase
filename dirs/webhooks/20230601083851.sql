create table users
(
    id    int,
    email varchar(100),
    name  varchar(100),
    primary key (id),
    unique (email)
);