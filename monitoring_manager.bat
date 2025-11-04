@echo off
setlocal enabledelayedexpansion

:MAIN_MENU
cls
echo ========================================
echo   ORACLE MONITORING SYSTEM MANAGER
echo ========================================
echo.
echo Current Status:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr -E "(grafana|prometheus|loki|alertmanager|oracledb-exporter|promtail|webhook-converter)" 2>nul
if errorlevel 1 (
    echo No monitoring containers running
)
echo.
echo ========================================
echo   MONITORING MANAGEMENT OPTIONS
echo ========================================
echo.
echo 1. Start Monitoring Stack
echo 2. Stop Monitoring Stack
echo 3. Restart Monitoring Stack
echo 4. Test System Health
echo 5. Setup Monitor User
echo 6. Open Monitoring Interfaces
echo 7. View Logs
echo 8. Reload Prometheus Configuration
echo 9. Check Active Alerts
echo 0. Exit
echo.
set /p choice="Select option (0-9): "

if "%choice%"=="1" goto START_STACK
if "%choice%"=="2" goto STOP_STACK
if "%choice%"=="3" goto RESTART_STACK
if "%choice%"=="4" goto TEST_SYSTEM
if "%choice%"=="5" goto SETUP_MONITOR_USER
if "%choice%"=="6" goto OPEN_INTERFACES
if "%choice%"=="7" goto VIEW_LOGS
if "%choice%"=="8" goto RELOAD_PROMETHEUS
if "%choice%"=="9" goto CHECK_ALERTS
if "%choice%"=="0" goto EXIT
goto MAIN_MENU

:START_STACK
echo.
echo Starting monitoring stack...
docker-compose -f docker-compose-local-oracle.yml up -d
echo.
echo Waiting for services to start...
timeout /t 15 /nobreak >nul
echo.
echo Services started! Checking status...
docker-compose -f docker-compose-local-oracle.yml ps
echo.
pause
goto MAIN_MENU

:STOP_STACK
echo.
echo Stopping monitoring stack...
docker-compose -f docker-compose-local-oracle.yml down
echo.
echo Monitoring stack stopped!
pause
goto MAIN_MENU

:RESTART_STACK
echo.
echo Restarting monitoring stack...
docker-compose -f docker-compose-local-oracle.yml down
timeout /t 5 /nobreak >nul
docker-compose -f docker-compose-local-oracle.yml up -d
echo.
echo Waiting for services to restart...
timeout /t 15 /nobreak >nul
echo.
echo Services restarted! Checking status...
docker-compose -f docker-compose-local-oracle.yml ps
echo.
pause
goto MAIN_MENU

:TEST_SYSTEM
echo.
echo ========================================
echo   ORACLE MONITORING SYSTEM TEST
echo ========================================

echo.
echo 1. Checking Docker containers status...
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo.
echo 2. Testing Prometheus connectivity...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9090/api/v1/query?query=up' -UseBasicParsing; if ($response.Content -match 'success') { Write-Host '✓ Prometheus is responding' } else { Write-Host '✗ Prometheus is not responding' } } catch { Write-Host '✗ Prometheus is not responding' }"

echo.
echo 3. Testing Oracle Exporter...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9161/metrics' -UseBasicParsing; if ($response.Content -match 'oracledb_up') { Write-Host '✓ Oracle Exporter is responding' } else { Write-Host '✗ Oracle Exporter is not responding' } } catch { Write-Host '✗ Oracle Exporter is not responding' }"

echo.
echo 4. Testing Grafana...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3000/api/health' -UseBasicParsing; if ($response.Content -match 'ok') { Write-Host '✓ Grafana is responding' } else { Write-Host '✗ Grafana is not responding' } } catch { Write-Host '✗ Grafana is not responding' }"

echo.
echo 5. Testing Loki...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3100/ready' -UseBasicParsing; if ($response.Content -match 'ready') { Write-Host '✓ Loki is responding' } else { Write-Host '✗ Loki is not responding' } } catch { Write-Host '✗ Loki is not responding' }"

echo.
echo 6. Testing AlertManager...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9093/-/healthy' -UseBasicParsing; if ($response.Content -match 'OK') { Write-Host '✓ AlertManager is responding' } else { Write-Host '✗ AlertManager is not responding' } } catch { Write-Host '✗ AlertManager is not responding' }"

echo.
echo 7. Testing Webhook Converter...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5002/health' -UseBasicParsing; if ($response.Content -match 'healthy') { Write-Host '✓ Webhook Converter is responding' } else { Write-Host '✗ Webhook Converter is not responding' } } catch { Write-Host '✗ Webhook Converter is not responding' }"

echo.
echo 8. Checking Oracle metrics...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9161/metrics' -UseBasicParsing; if ($response.Content -match 'oracledb_sessions') { Write-Host '✓ Oracle metrics are being collected' } else { Write-Host '✗ Oracle metrics are not being collected' } } catch { Write-Host '✗ Oracle metrics are not being collected' }"

echo.
echo ========================================
echo   MONITORING INTERFACES
echo ========================================
echo.
echo Access URLs:
echo   - Grafana Dashboard: http://localhost:3000 (admin/admin)
echo   - Prometheus: http://localhost:9090
echo   - AlertManager: http://localhost:9093
echo   - Oracle Exporter: http://localhost:9161/metrics
echo   - Loki: http://localhost:3100
echo   - Webhook Converter: http://localhost:5002/health
echo.
echo ========================================
echo   TEST COMPLETED!
echo ========================================
echo.
pause
goto MAIN_MENU

:SETUP_MONITOR_USER
echo.
echo ========================================
echo   SETUP MONITOR USER
echo ========================================
echo.
echo This will create monitor_user with necessary permissions
echo and create test tables with sample data for load testing
echo.
set /p oracle_password="Enter Oracle SYSTEM password: "
echo.
echo Creating monitor_user, test tables, and granting permissions...
echo Using connection: system/****@//localhost:1521/ORCL
echo.
sqlplus system/%oracle_password%@//localhost:1521/ORCL @sql/setup_monitor_user_local.sql
echo.
echo Setup completed!
echo.
echo Created:
echo - monitor_user/monitor_pass (with own schema)
echo - 5 test tables with sample data
echo - Synonyms in SYSTEM schema for easy access
echo.
echo Granted permissions:
echo - SELECT ANY DICTIONARY
echo - SELECT on V$ views
echo - SELECT on DBA_ views
echo - SELECT on test tables
echo.
pause
goto MAIN_MENU

:OPEN_INTERFACES
echo.
echo ========================================
echo   OPEN MONITORING INTERFACES
echo ========================================
echo.
echo 1. Grafana Dashboard (http://localhost:3000)
echo 2. Prometheus (http://localhost:9090)
echo 3. AlertManager (http://localhost:9093)
echo 4. Oracle Exporter Metrics (http://localhost:9161/metrics)
echo 5. Loki (http://localhost:3100)
echo 6. Webhook Converter Health (http://localhost:5002/health)
echo 7. Open All Interfaces
echo 0. Back to Main Menu
echo.
set /p interface_choice="Select interface (0-7): "

if "%interface_choice%"=="1" goto OPEN_GRAFANA
if "%interface_choice%"=="2" goto OPEN_PROMETHEUS
if "%interface_choice%"=="3" goto OPEN_ALERTMANAGER
if "%interface_choice%"=="4" goto OPEN_ORACLE_EXPORTER
if "%interface_choice%"=="5" goto OPEN_LOKI
if "%interface_choice%"=="6" goto OPEN_WEBHOOK_CONVERTER
if "%interface_choice%"=="7" goto OPEN_ALL_INTERFACES
if "%interface_choice%"=="0" goto MAIN_MENU
goto OPEN_INTERFACES

:OPEN_GRAFANA
echo.
echo Opening Grafana Dashboard...
start http://localhost:3000
echo.
echo Grafana Dashboard opened!
echo - URL: http://localhost:3000
echo - Username: admin
echo - Password: admin
echo.
pause
goto OPEN_INTERFACES

:OPEN_PROMETHEUS
echo.
echo Opening Prometheus...
start http://localhost:9090
echo.
echo Prometheus opened!
echo - URL: http://localhost:9090
echo - Query interface for metrics
echo.
pause
goto OPEN_INTERFACES

:OPEN_ALERTMANAGER
echo.
echo Opening AlertManager...
start http://localhost:9093
echo.
echo AlertManager opened!
echo - URL: http://localhost:9093
echo - Alert management interface
echo.
pause
goto OPEN_INTERFACES

:OPEN_ORACLE_EXPORTER
echo.
echo Opening Oracle Exporter Metrics...
start http://localhost:9161/metrics
echo.
echo Oracle Exporter Metrics opened!
echo - URL: http://localhost:9161/metrics
echo - Raw metrics from Oracle Database
echo.
pause
goto OPEN_INTERFACES

:OPEN_LOKI
echo.
echo Opening Loki...
start http://localhost:3100
echo.
echo Loki opened!
echo - URL: http://localhost:3100
echo - Log aggregation interface
echo.
pause
goto OPEN_INTERFACES

:OPEN_WEBHOOK_CONVERTER
echo.
echo Opening Webhook Converter Health Check...
start http://localhost:5002/health
echo.
echo Webhook Converter Health Check opened!
echo - URL: http://localhost:5002/health
echo - Health status of Discord webhook converter
echo.
pause
goto OPEN_INTERFACES

:OPEN_ALL_INTERFACES
echo.
echo Opening all monitoring interfaces...
echo.
start http://localhost:3000
start http://localhost:9090
start http://localhost:9093
start http://localhost:9161/metrics
start http://localhost:3100
start http://localhost:5002/health
echo.
echo All monitoring interfaces opened!
echo.
echo Quick Access URLs:
echo - Grafana Dashboard: http://localhost:3000 (admin/admin)
echo - Prometheus: http://localhost:9090
echo - AlertManager: http://localhost:9093
echo - Oracle Exporter: http://localhost:9161/metrics
echo - Loki: http://localhost:3100
echo - Webhook Converter: http://localhost:5002/health
echo.
pause
goto OPEN_INTERFACES

:VIEW_LOGS
echo.
echo ========================================
echo   VIEW CONTAINER LOGS
echo ========================================
echo.
echo 1. Prometheus Logs
echo 2. Grafana Logs
echo 3. Loki Logs
echo 4. AlertManager Logs
echo 5. Oracle Exporter Logs
echo 6. Promtail Logs
echo 7. Webhook Converter Logs
echo 8. All Logs
echo 9. Back to Main Menu
echo.
set /p log_choice="Select logs to view (1-9): "

if "%log_choice%"=="1" docker logs prometheus --tail 50
if "%log_choice%"=="2" docker logs grafana --tail 50
if "%log_choice%"=="3" docker logs loki --tail 50
if "%log_choice%"=="4" docker logs alertmanager --tail 50
if "%log_choice%"=="5" docker logs oracledb-exporter --tail 50
if "%log_choice%"=="6" docker logs promtail --tail 50
if "%log_choice%"=="7" docker logs webhook-converter --tail 50
if "%log_choice%"=="8" docker-compose -f docker-compose-local-oracle.yml logs --tail 50
if "%log_choice%"=="9" goto MAIN_MENU

echo.
pause
goto VIEW_LOGS

:RELOAD_PROMETHEUS
echo.
echo ========================================
echo   RELOAD PROMETHEUS CONFIGURATION
echo ========================================
echo.
echo This will reload Prometheus configuration and alert rules
echo without restarting the container.
echo.
set /p confirm="Do you want to reload Prometheus config? (y/N): "
if /i not "%confirm%"=="y" (
    echo Prometheus config reload cancelled.
    pause
    goto MAIN_MENU
)

echo.
echo Reloading Prometheus configuration...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9090/-/reload' -Method POST -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host '✓ Prometheus configuration reloaded successfully' } else { Write-Host '✗ Failed to reload Prometheus configuration' } } catch { Write-Host '✗ Failed to reload Prometheus configuration' }"

echo.
echo Checking if alert rules are loaded...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9090/api/v1/rules' -UseBasicParsing; if ($response.Content -match 'OracleDatabaseDown') { Write-Host '✓ Alert rules are loaded' } else { Write-Host '✗ Alert rules not found' } } catch { Write-Host '✗ Could not check alert rules' }"

echo.
pause
goto MAIN_MENU

:CHECK_ALERTS
echo.
echo ========================================
echo   CHECK ACTIVE ALERTS
echo ========================================
echo.
echo Checking for active alerts in Prometheus...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9090/api/v1/alerts' -UseBasicParsing; $data = $response.Content | ConvertFrom-Json; if ($data.data.alerts.Count -gt 0) { Write-Host 'Active alerts found:'; $data.data.alerts | ForEach-Object { Write-Host '- ' $_.labels.alertname ':' $_.annotations.summary } } else { Write-Host 'No active alerts found' } } catch { Write-Host 'Could not check alerts' }"

echo.
echo Checking for firing alerts in AlertManager...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:9093/api/v1/alerts' -UseBasicParsing; $data = $response.Content | ConvertFrom-Json; if ($data.data.Count -gt 0) { Write-Host 'Firing alerts in AlertManager:'; $data.data | ForEach-Object { Write-Host '- ' $_.labels.alertname ':' $_.annotations.summary } } else { Write-Host 'No firing alerts in AlertManager' } } catch { Write-Host 'Could not check AlertManager alerts' }"

echo.
echo Checking webhook converter health...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:5002/health' -UseBasicParsing; if ($response.Content -match 'healthy') { Write-Host '✓ Webhook converter is healthy' } else { Write-Host '✗ Webhook converter is not healthy' } } catch { Write-Host '✗ Webhook converter is not responding' }"

echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo Thank you for using Oracle Monitoring System Manager!
echo.
exit /b 0