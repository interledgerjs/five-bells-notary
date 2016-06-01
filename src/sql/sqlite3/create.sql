
CREATE TABLE IF NOT EXISTS N_CASES (
  CASE_ID                     INTEGER PRIMARY KEY AUTOINCREMENT,
  UUID                        CHAR(36) NOT NULL,
  STATUS_ID                   INTEGER NOT NULL,
  EXECUTION_CONDITION_TYPE    VARCHAR(20) NULL,
  EXECUTION_CONDITION_DIGEST  VARCHAR(4000) NOT NULL,
  EXEC_COND_FULFILLMENT       VARCHAR(4000) NULL,
  EXPIRES_DTTM                DATETIME NOT NULL,
  NOTARIES                    VARCHAR(4000) NOT NULL,
  NOTIFICATION_TARGETS        VARCHAR(4000) NOT NULL,
  DB_CREATED_DTTM             DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  DB_UPDATED_DTTM             DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  DB_UPDATED_USER             VARCHAR(40) NULL
);

CREATE INDEX N_XPK_CASES ON N_CASES
(CASE_ID DESC);

CREATE UNIQUE INDEX N_XAK_CASES_GUID ON N_CASES
(UUID ASC);

CREATE INDEX N_XIF_CASES ON N_CASES
(STATUS_ID ASC);

CREATE TABLE IF NOT EXISTS N_LU_CASE_STATUS
(
    CASE_STATUS_ID    INTEGER PRIMARY KEY AUTOINCREMENT,
    NAME              VARCHAR(20) UNIQUE NOT NULL ,
    DESCRIPTION       VARCHAR(255) NULL ,
    DB_CREATED_DTTM   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    DB_UPDATED_DTTM   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    DB_UPDATED_USER   VARCHAR(40) NULL
);

CREATE INDEX N_XPK_LU_CASE_STATUS ON N_LU_CASE_STATUS
(CASE_STATUS_ID ASC);

CREATE UNIQUE INDEX N_XAK_LU_CASE_STATE ON N_LU_CASE_STATUS
(NAME   ASC);

CREATE TABLE IF NOT EXISTS N_NOTIFICATIONS
(
  NOTIFICATION_ID   INTEGER PRIMARY KEY AUTOINCREMENT,
  CASE_ID           INTEGER NOT NULL,
  STATUS_ID         INTEGER NOT NULL ,
  TARGET            VARCHAR(4000) NULL,
  IS_ACTIVE         SMALLINT NULL,
  RETRY_COUNT       INTEGER NULL,
  NEXT_RETRY_DTTM   TIMESTAMP NULL,
  LAST_RETRY_DTTM   DATE NULL,
  DB_CREATED_DTTM   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  DB_UPDATED_DTTM   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  DB_UPDATED_USER   VARCHAR(40) NULL
);

CREATE INDEX N_XPK_NOTIFICATIONS ON N_NOTIFICATIONS
(NOTIFICATION_ID   DESC);

CREATE INDEX N_XIF_NOTIFICATIONS ON N_NOTIFICATIONS
(CASE_ID   ASC);

CREATE TABLE IF NOT EXISTS N_LU_NOTIFICATION_STATUS
(
  NOTIFICATION_STATUS_ID  INTEGER PRIMARY KEY AUTOINCREMENT,
  NAME                    VARCHAR(20) NOT NULL,
  DESCRIPTION             VARCHAR(255) NULL,
  DB_CREATED_DTTM         DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  DB_UPDATED_DTTM         DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  DB_UPDATED_USER         VARCHAR(40) NULL
);

CREATE UNIQUE INDEX N_XPK_LU_NOTIFICATION_STATUS ON N_LU_NOTIFICATION_STATUS
(NOTIFICATION_STATUS_ID   ASC);

CREATE UNIQUE INDEX N_XAK_LU_NOTIFICATION_STATUS ON N_LU_NOTIFICATION_STATUS
(NAME   ASC);

INSERT INTO N_LU_CASE_STATUS (NAME, DESCRIPTION) VALUES  ('proposed', 'This case is proposed');
INSERT INTO N_LU_CASE_STATUS (NAME, DESCRIPTION) VALUES  ('rejected', 'This case has been rejected because it is past expiry');
INSERT INTO N_LU_CASE_STATUS (NAME, DESCRIPTION) VALUES  ('executed', 'This case has been executed because it received the proper fulfillment');

INSERT INTO N_LU_NOTIFICATION_STATUS (NAME, DESCRIPTION) VALUES  ('pending', 'This notification is being delivered');
INSERT INTO N_LU_NOTIFICATION_STATUS (NAME, DESCRIPTION) VALUES  ('delivered', 'This notification has been delivered');
INSERT INTO N_LU_NOTIFICATION_STATUS (NAME, DESCRIPTION) VALUES  ('failed', 'Delivery failed permanently');
