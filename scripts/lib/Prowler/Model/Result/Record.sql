BEGIN TRANSACTION;

DROP TABLE records;

CREATE TABLE content (
  id INTEGER PRIMARY KEY NOT NULL,
  datetime varchar(50) NOT NULL,
  record varchar(250),
);

COMMIT;