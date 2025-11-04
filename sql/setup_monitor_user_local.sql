-- Script to create monitoring user for local Oracle Database
-- Run this as SYSTEM user in SQL*Plus or SQL Developer
-- Mục tiêu: monitor_user có thể thấy schema của SYSTEM

-- 1. Create monitoring user
CREATE USER monitor_user IDENTIFIED BY monitor_pass;

-- 2. Grant necessary privileges for monitoring
GRANT CONNECT TO monitor_user;
GRANT SELECT ANY DICTIONARY TO monitor_user;
GRANT CREATE TABLE TO monitor_user;
GRANT CREATE PROCEDURE TO monitor_user;
GRANT CREATE JOB TO monitor_user;
GRANT UNLIMITED TABLESPACE TO monitor_user;

-- System views for Oracle Exporter
GRANT SELECT ON v_$session TO monitor_user;
GRANT SELECT ON v_$process TO monitor_user;
GRANT SELECT ON v_$database TO monitor_user;
GRANT SELECT ON v_$instance TO monitor_user;
GRANT SELECT ON v_$tablespace TO monitor_user;
GRANT SELECT ON v_$datafile TO monitor_user;
GRANT SELECT ON v_$filestat TO monitor_user;
GRANT SELECT ON v_$log TO monitor_user;
GRANT SELECT ON v_$sys_time_model TO monitor_user;
GRANT SELECT ON v_$system_event TO monitor_user;
GRANT SELECT ON v_$buffer_pool TO monitor_user;
GRANT SELECT ON dba_data_files TO monitor_user;
GRANT SELECT ON dba_free_space TO monitor_user;

-- 3. Create test tables in MONITOR_USER schema
CONNECT monitor_user/monitor_pass;

CREATE TABLE ACCOUNT (
    ID NUMBER PRIMARY KEY,
    USERNAME VARCHAR2(50),
    PASSWORD VARCHAR2(50),
    EMAIL VARCHAR2(100),
    CREATED_DATE DATE DEFAULT SYSDATE
);

CREATE TABLE COURSE (
    ID NUMBER PRIMARY KEY,
    TITLE VARCHAR2(100),
    DESCRIPTION VARCHAR2(500),
    DURATION NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

CREATE TABLE TECHNOLOGY (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(50),
    VERSION VARCHAR2(20),
    CATEGORY VARCHAR2(50),
    CREATED_DATE DATE DEFAULT SYSDATE
);

CREATE TABLE TOPIC (
    ID NUMBER PRIMARY KEY,
    NAME VARCHAR2(100),
    DESCRIPTION VARCHAR2(500),
    DIFFICULTY VARCHAR2(20),
    CREATED_DATE DATE DEFAULT SYSDATE
);

CREATE TABLE TRACKS (
    ID NUMBER PRIMARY KEY,
    TITLE VARCHAR2(100),
    DESCRIPTION VARCHAR2(500),
    DURATION NUMBER,
    CREATED_DATE DATE DEFAULT SYSDATE
);

-- Insert sample data
INSERT INTO ACCOUNT VALUES (1, 'user_001', 'pass123', 'user1@example.com', SYSDATE);
INSERT INTO ACCOUNT VALUES (2, 'user_002', 'pass456', 'user2@example.com', SYSDATE);
INSERT INTO ACCOUNT VALUES (3, 'user_003', 'pass789', 'user3@example.com', SYSDATE);
INSERT INTO ACCOUNT VALUES (4, 'user_004', 'passabc', 'user4@example.com', SYSDATE);
INSERT INTO ACCOUNT VALUES (5, 'user_005', 'passdef', 'user5@example.com', SYSDATE);

INSERT INTO COURSE VALUES (1, 'Oracle Database Fundamentals', 'Learn Oracle basics', 40, SYSDATE);
INSERT INTO COURSE VALUES (2, 'SQL Programming', 'Advanced SQL techniques', 30, SYSDATE);
INSERT INTO COURSE VALUES (3, 'Database Administration', 'DBA essentials', 50, SYSDATE);
INSERT INTO COURSE VALUES (4, 'Performance Tuning', 'Optimize database performance', 35, SYSDATE);
INSERT INTO COURSE VALUES (5, 'Backup and Recovery', 'Data protection strategies', 25, SYSDATE);

INSERT INTO TECHNOLOGY VALUES (1, 'Oracle Database', '19c', 'Database', SYSDATE);
INSERT INTO TECHNOLOGY VALUES (2, 'SQL Developer', '21.4', 'Tool', SYSDATE);
INSERT INTO TECHNOLOGY VALUES (3, 'RMAN', '19c', 'Backup', SYSDATE);
INSERT INTO TECHNOLOGY VALUES (4, 'AWR', '19c', 'Performance', SYSDATE);
INSERT INTO TECHNOLOGY VALUES (5, 'Enterprise Manager', '13c', 'Management', SYSDATE);

INSERT INTO TOPIC VALUES (1, 'SQL Basics', 'Introduction to SQL', 'Beginner', SYSDATE);
INSERT INTO TOPIC VALUES (2, 'Joins and Subqueries', 'Advanced query techniques', 'Intermediate', SYSDATE);
INSERT INTO TOPIC VALUES (3, 'Indexes and Performance', 'Database optimization', 'Advanced', SYSDATE);
INSERT INTO TOPIC VALUES (4, 'Transactions and Locks', 'Concurrency control', 'Intermediate', SYSDATE);
INSERT INTO TOPIC VALUES (5, 'Stored Procedures', 'PL/SQL programming', 'Advanced', SYSDATE);

INSERT INTO TRACKS VALUES (1, 'Database Developer Track', 'Complete development path', 120, SYSDATE);
INSERT INTO TRACKS VALUES (2, 'DBA Track', 'Administration specialization', 150, SYSDATE);
INSERT INTO TRACKS VALUES (3, 'Performance Tuning Track', 'Optimization focus', 80, SYSDATE);
INSERT INTO TRACKS VALUES (4, 'Security Track', 'Database security', 60, SYSDATE);
INSERT INTO TRACKS VALUES (5, 'Cloud Track', 'Oracle Cloud services', 100, SYSDATE);

COMMIT;

-- 4. Connect back to SYSTEM to create synonyms
CONNECT SYSTEM/&system_password;

-- Create synonyms in SYSTEM schema for easy access
CREATE SYNONYM SYSTEM.ACCOUNT FOR monitor_user.ACCOUNT;
CREATE SYNONYM SYSTEM.COURSE FOR monitor_user.COURSE;
CREATE SYNONYM SYSTEM.TECHNOLOGY FOR monitor_user.TECHNOLOGY;
CREATE SYNONYM SYSTEM.TOPIC FOR monitor_user.TOPIC;
CREATE SYNONYM SYSTEM.TRACKS FOR monitor_user.TRACKS;

-- Grant additional permissions
GRANT SELECT ON monitor_user.ACCOUNT TO monitor_user;
GRANT SELECT ON monitor_user.COURSE TO monitor_user;
GRANT SELECT ON monitor_user.TECHNOLOGY TO monitor_user;
GRANT SELECT ON monitor_user.TOPIC TO monitor_user;
GRANT SELECT ON monitor_user.TRACKS TO monitor_user;

COMMIT;

-- Show success message
SELECT 'Oracle monitoring setup completed successfully!' as status FROM DUAL;
SELECT 'Tables created in MONITOR_USER schema:' as info FROM DUAL;
SELECT 'ACCOUNT, COURSE, TECHNOLOGY, TOPIC, TRACKS' as tables FROM DUAL;
SELECT 'Synonyms created in SYSTEM schema for easy access' as note FROM DUAL;
