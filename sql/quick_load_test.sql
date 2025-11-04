-- ========================================
-- QUICK LOAD TEST - CHẠY NHANH TRONG SQL DEVELOPER
-- ========================================
-- Script đơn giản để tạo load nhanh và trigger alerts

SET SERVEROUTPUT ON;

DECLARE
    v_counter NUMBER := 0;
    v_max_iterations NUMBER := 50;  -- Giảm từ 1000 xuống 50
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    v_start_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('STARTING QUICK LOAD TEST');
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('User: ' || USER);
    DBMS_OUTPUT.PUT_LINE('Session ID: ' || SYS_CONTEXT('USERENV', 'SID'));
    DBMS_OUTPUT.PUT_LINE('Max iterations: ' || v_max_iterations);
    DBMS_OUTPUT.PUT_LINE('Start time: ' || v_start_time);
    DBMS_OUTPUT.PUT_LINE('=====================================');
    
    FOR i IN 1..v_max_iterations LOOP
        v_counter := v_counter + 1;
        
        -- 1. Simple COUNT queries (nhanh)
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.COURSE WHERE ROWNUM <= 5;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.TECHNOLOGY WHERE ROWNUM <= 5;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.TOPIC WHERE ROWNUM <= 5;
        SELECT COUNT(*) INTO v_counter FROM SYSTEM.TRACKS WHERE ROWNUM <= 5;
        
        -- 2. Simple SELECT queries (nhanh)
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 3
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.COURSE WHERE ROWNUM <= 3
        );
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.TECHNOLOGY WHERE ROWNUM <= 3
        );
        
        -- 3. Simple JOIN queries (nhanh)
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT a, SYSTEM.COURSE b WHERE ROWNUM <= 5
        );
        
        -- 4. Simple WHERE queries (nhanh)
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
        ) WHERE ROWNUM BETWEEN 1 AND 3;
        
        -- 5. Simple ORDER BY query (nhanh)
        SELECT COUNT(*) INTO v_counter FROM (
            SELECT * FROM SYSTEM.ACCOUNT WHERE ROWNUM <= 5
            ORDER BY ROWNUM
        );
        
        -- Commit mỗi 10 iterations (thay vì 100)
        IF MOD(i, 10) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Iteration ' || i || ' completed and committed');
        END IF;
        
    END LOOP;
    
    COMMIT;
    
    v_end_time := SYSTIMESTAMP;
    
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('QUICK LOAD TEST COMPLETED!');
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
