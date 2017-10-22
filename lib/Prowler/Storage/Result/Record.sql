BEGIN TRANSACTION;

CREATE TABLE record (
  id INTEGER PRIMARY KEY NOT NULL,
  datetime varchar(50) NOT NULL,
  checksum varchar(32) NOT NULL,
  output TEXT NOT NULL
);

COMMIT;