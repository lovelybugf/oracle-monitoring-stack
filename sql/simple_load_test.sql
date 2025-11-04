-- ========================================
-- SIMPLE LOAD TEST - CHẠY 1 CONNECTION
-- ========================================
-- Script đơn giản nhất để tạo load

SET SERVEROUTPUT ON;

DECLARE
    v_counter NUMBER := 0;
    v_max_iterations NUMBER := 1000;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('STARTING SIMPLE LOAD TEST');
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('User: ' || USER);
    DBMS_OUTPUT.PUT_LINE('Session ID: ' || SYS_CONTEXT('USERENV', 'SID'));
    DBMS_OUTPUT.PUT_LINE('Max iterations: ' || v_max_iterations);
    DBMS_OUTPUT.PUT_LINE('Start time: ' || v_start_time);
    DBMS_OUTPUT.PUT_LINE('=====================================');
    
    FOR i IN 1..v_max_iterations LOOP
        v_counter := v_counter + 1;
        
        -- 1. Simple COUNT queries
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.ACCOUNT;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.COURSE;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.TECHNOLOGY;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.TOPIC;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.TRACKS;
        
        -- 2. SELECT * queries
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.COURSE WHERE ROWNUM <= 5
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.TECHNOLOGY WHERE ROWNUM <= 5
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.TOPIC WHERE ROWNUM <= 5
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.TRACKS WHERE ROWNUM <= 5
        );
        
        -- 3. CROSS JOIN queries
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT a, SYSTEM.COURSE b WHERE ROWNUM <= 10
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.TECHNOLOGY a, SYSTEM.TOPIC b WHERE ROWNUM <= 10
        );
        
        -- 4. Subquery
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) WHERE ROWNUM <= 3;
        
        -- 5. EXISTS query
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) a WHERE EXISTS (
            SELECT 1 FROM SYSTEM.COURSE WHERE ROWNUM <= 3
        );
        
        -- 6. IN query
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) WHERE ROWNUM IN (1, 2, 3);
        
        -- 7. LIKE query
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) WHERE ROWNUM LIKE '%1%';
        
        -- 8. BETWEEN query
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) WHERE ROWNUM BETWEEN 1 AND 3;
        
        -- 9. ORDER BY query
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
            ORDER BY ROWNUM
        );
        
        -- 10. Complex WHERE clause
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) WHERE ROWNUM > 0 AND ROWNUM < 10;
        
        -- Commit mỗi 100 iterations
        IF MOD(i, 100) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Iteration ' || i || ' completed and committed');
        END IF;
        
    END LOOP;
    
    COMMIT;
    
    v_end_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('SIMPLE LOAD TEST COMPLETED!');
    DBMS_OUTPUT.PUT_LINE('Total iterations: ' || v_counter);
    DBMS_OUTPUT.PUT_LINE('User: ' || USER);
    DBMS_OUTPUT.PUT_LINE('Session ID: ' || SYS_CONTEXT('USERENV', 'SID'));
    DBMS_OUTPUT.PUT_LINE('Start time: ' || v_start_time);
    DBMS_OUTPUT.PUT_LINE('End time: ' || v_end_time);
    DBMS_OUTPUT.PUT_LINE('Duration: ' || (v_end_time - v_start_time));
    DBMS_OUTPUT.PUT_LINE('=====================================');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        ROLLBACK;
END;
/
