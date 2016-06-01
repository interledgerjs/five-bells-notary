CREATE SEQUENCE N_SEQ_CASES_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;
/

CREATE SEQUENCE N_SEQ_NOTIFICATIONS_PK
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER
/

CREATE TABLE N_CASES
(
  CASE_ID                     INTEGER  NOT NULL ,
  UUID                        VARCHAR2(64) NOT NULL ,
  STATUS_ID                   INTEGER NOT NULL ,
  EXECUTION_CONDITION_TYPE    VARCHAR2(20) NULL ,
  EXECUTION_CONDITION_DIGEST  VARCHAR2(4000) NULL ,
  EXEC_COND_FULFILLMENT       VARCHAR2(4000) NULL ,
  EXPIRES_DTTM                TIMESTAMP WITH TIME ZONE NULL ,
  NOTARIES                    VARCHAR2(4000) NULL ,
  NOTIFICATION_TARGETS        VARCHAR2(4000) NULL ,
  DB_CREATED_DTTM             TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_DTTM             TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_USER             VARCHAR2(40) DEFAULT  USER  NOT NULL 
);
/

CREATE INDEX N_XPK_CASES ON N_CASES
(CASE_ID   DESC);
/

ALTER TABLE N_CASES
  ADD CONSTRAINT  N_PK_CASES PRIMARY KEY (CASE_ID);
/

CREATE UNIQUE INDEX N_XAK_CASES_GUID ON N_CASES
(UUID   ASC);
/

ALTER TABLE N_CASES
ADD CONSTRAINT  N_XAK_CASES_GUID UNIQUE (UUID);
/

CREATE INDEX N_XIF_CASES ON N_CASES
(STATUS_ID   ASC);
/

CREATE TABLE N_LU_CASE_STATUS
(
  CASE_STATUS_ID       INTEGER NOT NULL ,
  NAME                 VARCHAR2(20) NOT NULL ,
  DESCRIPTION          VARCHAR2(255) NULL ,
  DB_CREATED_DTTM      TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_DTTM      TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_USER      VARCHAR2(40) DEFAULT  USER  NOT NULL 
);
/

CREATE INDEX N_XPK_LU_CASE_STATUS ON N_LU_CASE_STATUS
(CASE_STATUS_ID   ASC);
/

ALTER TABLE N_LU_CASE_STATUS
  ADD CONSTRAINT  N_PK_LU_CASE_STATE PRIMARY KEY (CASE_STATUS_ID);
/

CREATE UNIQUE INDEX N_XAK_LU_CASE_STATE ON N_LU_CASE_STATUS
(NAME   ASC);
/

ALTER TABLE N_LU_CASE_STATUS
ADD CONSTRAINT  N_XAK_LU_CASE_STATE UNIQUE (NAME);
/

CREATE TABLE N_LU_NOTIFICATION_STATUS
(
  NOTIFICATION_STATUS_ID INTEGER NOT NULL ,
  NAME                   VARCHAR2(20) NOT NULL ,
  DESCRIPTION            VARCHAR2(255) NULL ,
  DB_CREATED_DTTM        TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_DTTM        TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_USER        VARCHAR2(40) DEFAULT  USER  NOT NULL 
);
/

CREATE UNIQUE INDEX N_XPK_LU_NOTIFICATION_STATUS ON N_LU_NOTIFICATION_STATUS
(NOTIFICATION_STATUS_ID   ASC);
/

ALTER TABLE N_LU_NOTIFICATION_STATUS
  ADD CONSTRAINT  N_PK_LU_NOTIFICATION_STATE PRIMARY KEY (NOTIFICATION_STATUS_ID);
/

CREATE UNIQUE INDEX N_XAK_LU_NOTIFICATION_STATUS ON N_LU_NOTIFICATION_STATUS
(NAME   ASC);
/

ALTER TABLE N_LU_NOTIFICATION_STATUS
ADD CONSTRAINT  N_XAK_LU_NOTIFICATION_STATUS UNIQUE (NAME);
/

CREATE TABLE N_NOTIFICATIONS
(
  NOTIFICATION_ID      INTEGER  NOT NULL ,
  STATUS_ID            INTEGER NOT NULL ,
  CASE_ID              INTEGER NOT NULL ,
  TARGET               VARCHAR2(4000) NULL ,
  RETRY_COUNT          INTEGER NULL ,
  NEXT_RETRY_DTTM      TIMESTAMP WITH TIME ZONE NULL ,
  IS_ACTIVE            SMALLINT NULL ,
  LAST_RETRY_DTTM      TIMESTAMP WITH TIME ZONE NULL ,
  DB_CREATED_DTTM      TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_DTTM      TIMESTAMP WITH TIME ZONE DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_USER      VARCHAR2(40) DEFAULT  USER  NOT NULL 
);
/

CREATE INDEX N_XPK_NOTIFICATIONS ON N_NOTIFICATIONS
(NOTIFICATIONS_ID   DESC);
/

ALTER TABLE N_NOTIFICATIONS
  ADD CONSTRAINT  N_XPK_NOTIFICATIONS PRIMARY KEY (NOTIFICATIONS_ID);
/

CREATE INDEX N_XIF_NOTIFICATIONS_CASES ON N_NOTIFICATIONS
(CASE_ID   ASC);
/

CREATE INDEX N_XIF_NOTIFICATIONS_STATUS ON N_NOTIFICATIONS
(STATUS_ID   ASC);
/

CREATE OR REPLACE TRIGGER N_TRG_NOTIFICATIONS_SEQ
  BEFORE INSERT 
  ON N_NOTIFICATIONS
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new.NOTIFICATION_ID is null)
DECLARE
  v_id N_NOTIFICATIONS.NOTIFICATION_ID%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new.N_NOTIFICATIONS
  SELECT N_SEQ_NOTIFICATIONS_PK.nextval INTO v_id FROM DUAL;

  :new.NOTIFICATION_ID := v_id;
END N_TRG_NOTIFICATIONS_SEQ;
/

CREATE OR REPLACE TRIGGER N_TRG_CASES_SEQ
  BEFORE INSERT 
  ON N_CASES
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new.CASE_ID is null)
DECLARE
  v_id N_CASES.CASE_ID%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new.CASE_ID
  SELECT N_SEQ_CASES_PK.nextval INTO v_id FROM DUAL;

  :new.CASE_ID := v_id;
END N_TRG_CASES_SEQ;
/

CREATE OR REPLACE TRIGGER N_TRG_NOTIFICATIONS_UPDATE
BEFORE UPDATE
   ON  N_NOTIFICATIONS
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new.DB_UPDATED_DTTM := SYSDATE;
   :new.DB_UPDATED_USER := USER;
END;
/

CREATE OR REPLACE TRIGGER N_TRG_NOTIFICATIONS_INSERT
BEFORE INSERT
   ON  N_NOTIFICATIONS
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new.DB_CREATED_DTTM := SYSDATE;
END;
/


CREATE OR REPLACE TRIGGER N_TRG_CASES_UPDATE
BEFORE UPDATE
   ON  N_CASES
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new.DB_UPDATED_DTTM := SYSDATE;
   :new.DB_UPDATED_USER := USER;
END;
/

CREATE OR REPLACE TRIGGER N_TRG_CASES_INSERT
BEFORE INSERT
   ON  N_CASES
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new.DB_CREATED_DTTM := SYSDATE;
END;
/

CREATE PUBLIC SYNONYM N_LU_NOTIFICATION_STATUS
   FOR N_LU_NOTIFICATION_STATUS;
/

CREATE PUBLIC SYNONYM N_LU_CASE_STATUS
   FOR N_LU_CASE_STATUS;
/

CREATE PUBLIC SYNONYM N_NOTIFICATIONS
   FOR N_NOTIFICATIONS;
/

CREATE PUBLIC SYNONYM N_CASES
   FOR N_CASES;
/

INSERT INTO N_LU_CASE_STATUS (CASE_STATUS_ID, NAME, DESCRIPTION) VALUES (1, 'proposed', 'This case is proposed');
/
INSERT INTO N_LU_CASE_STATUS (CASE_STATUS_ID, NAME, DESCRIPTION) VALUES (2, 'rejected', 'This case has been rejected because it is past expiry');
/
INSERT INTO N_LU_CASE_STATUS (CASE_STATUS_ID, NAME, DESCRIPTION) VALUES (3, 'executed', 'This case has been executed because it received the proper fulfillment');
/

INSERT INTO N_LU_NOTIFICATION_STATUS (NOTIFICATION_STATUS_ID, NAME, DESCRIPTION) VALUES  (1, 'pending', 'This notification is being delivered');
/
INSERT INTO N_LU_NOTIFICATION_STATUS (NOTIFICATION_STATUS_ID, NAME, DESCRIPTION) VALUES  (2, 'delivered', 'This notification has been delivered');
/
INSERT INTO N_LU_NOTIFICATION_STATUS (NOTIFICATION_STATUS_ID, NAME, DESCRIPTION) VALUES  (3, 'failed', 'Delivery failed permanently');
/

exit
