# 📊 Grafana Dashboard Metrics Explanation

## 🎯 Tổng quan Dashboard

Dashboard `grafana-working-dashboard.json` hiện có **17 panels** theo dõi các metrics quan trọng của Oracle Database và Oracle Exporter.

---

## 📈 **PANEL 1: Database Status**
- **Metric**: `up{job="oracledb-exporter"}`
- **Tên gọi**: Database Connection Status
- **Ý nghĩa**: Trạng thái kết nối giữa Oracle Exporter và Oracle Database
- **Độ quan trọng**: ⭐⭐⭐⭐⭐ (CRITICAL)
- **Giá trị**: 
  - `1` = Database UP (kết nối thành công)
  - `0` = Database DOWN (kết nối thất bại)
- **Alert**: Khi = 0 (Database không thể kết nối)

---

## 👥 **PANEL 2: Active Sessions**
- **Metric**: `sum(oracledb_sessions_value{status="ACTIVE"})`
- **Tên gọi**: Active Database Sessions
- **Ý nghĩa**: Số lượng sessions đang hoạt động trong Oracle Database
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Giá trị**: Số nguyên (0-∞)
- **Alert**: Khi > 15 sessions (High Session Count)
- **Giải thích**: Sessions cao có thể gây quá tải database

---

## ⚙️ **PANEL 3: Process Count**
- **Metric**: `oracledb_process_count`
- **Tên gọi**: Database Process Count
- **Ý nghĩa**: Tổng số processes đang chạy trong Oracle Database
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Giá trị**: Số nguyên (0-∞)
- **Alert**: Khi > 30 processes (High Process Count)
- **Giải thích**: Process count cao cho thấy database đang xử lý nhiều tác vụ

---

## 🚀 **PANEL 4: Query Execution Rate**
- **Metric**: `rate(oracledb_activity_execute_count[5m])`
- **Tên gọi**: SQL Query Execution Rate
- **Ý nghĩa**: Tốc độ thực thi SQL queries (queries/second)
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Giá trị**: Số thập phân (0-∞)
- **Alert**: Khi > 50 queries/sec (High Query Rate)
- **Giải thích**: Query rate cao cho thấy database đang xử lý nhiều requests

---

## 📊 **PANEL 5: SQL Execution Rate Over Time**
- **Metric**: `rate(oracledb_activity_execute_count[5m])`
- **Tên gọi**: SQL Execution Rate Trend
- **Ý nghĩa**: Biểu đồ xu hướng tốc độ thực thi SQL theo thời gian
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Unit**: queries/second
- **Giải thích**: Giúp theo dõi patterns và spikes trong database activity

---

## 👥 **PANEL 6: Sessions Over Time**
- **Metric**: `sum(oracledb_sessions_value)`
- **Tên gọi**: Total Sessions Trend
- **Ý nghĩa**: Biểu đồ xu hướng tổng số sessions theo thời gian
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Unit**: sessions
- **Giải thích**: Theo dõi session usage patterns và capacity planning

---

## 🔍 **PANEL 7: SQL Parse Rate Over Time**
- **Metric**: `rate(oracledb_activity_parse_count[5m])`
- **Tên gọi**: SQL Parse Rate Trend
- **Ý nghĩa**: Tốc độ parse SQL statements theo thời gian
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Unit**: parses/second
- **Giải thích**: Parse rate cao có thể cho thấy nhiều unique queries

---

## 💰 **PANEL 8: Transaction Activity Over Time**
- **Metric**: `rate(oracledb_activity_user_commits[5m])`
- **Tên gọi**: Transaction Commit Rate
- **Ý nghĩa**: Tốc độ commit transactions theo thời gian
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Unit**: commits/second
- **Giải thích**: Transaction activity cho thấy database workload

---

## 💾 **PANEL 9: Tablespace Usage Over Time**
- **Metric**: `oracledb_tablespace_bytes{type="USED"}`
- **Tên gọi**: Tablespace Usage Trend
- **Ý nghĩa**: Dung lượng tablespace đã sử dụng theo thời gian
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Unit**: bytes
- **Giải thích**: Theo dõi storage usage và capacity planning

---

## 🚨 **PANEL 10: Active Alerts**
- **Metric**: `ALERTS{alertstate="firing"}`
- **Tên gọi**: Firing Alerts Count
- **Ý nghĩa**: Số lượng alerts đang firing
- **Độ quan trọng**: ⭐⭐⭐⭐⭐ (CRITICAL)
- **Giá trị**: Số nguyên (0-∞)
- **Alert**: Khi > 0 (Có alerts đang firing)
- **Giải thích**: Cần xử lý ngay khi có alerts

---

## ❌ **PANEL 11: Failed Transactions Over Time**
- **Metric**: `rate(oracledb_activity_user_rollbacks[5m])`
- **Tên gọi**: Transaction Rollback Rate
- **Ý nghĩa**: Tốc độ rollback transactions (failed transactions)
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Unit**: rollbacks/second
- **Alert**: Khi > 0.01 rollbacks/sec (High Failed Transactions)
- **Giải thích**: Rollback rate cao cho thấy có lỗi trong transactions

---

## ⚠️ **PANEL 12: Oracle Exporter Errors**
- **Metric**: `oracledb_exporter_last_scrape_error`
- **Tên gọi**: Exporter Scrape Errors
- **Ý nghĩa**: Số lỗi khi Oracle Exporter scrape metrics
- **Độ quan trọng**: ⭐⭐⭐⭐⭐ (CRITICAL)
- **Giá trị**: 
  - `0` = No errors
  - `>0` = Has errors
- **Alert**: Khi > 0 (Exporter Errors)
- **Giải thích**: Exporter errors có thể làm mất metrics

---

## 😴 **PANEL 13: Inactive Sessions Count**
- **Metric**: `sum(oracledb_sessions_value{status="INACTIVE"})`
- **Tên gọi**: Inactive Sessions
- **Ý nghĩa**: Số lượng sessions không hoạt động
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Giá trị**: Số nguyên (0-∞)
- **Alert**: Khi > 20 sessions (High Inactive Sessions)
- **Giải thích**: Inactive sessions cao có thể cho thấy connection issues

---

## ⏱️ **PANEL 14: Oracle Exporter Performance**
- **Metric**: `oracledb_exporter_last_scrape_duration_seconds * 1000`
- **Tên gọi**: Exporter Scrape Duration
- **Ý nghĩa**: Thời gian scrape metrics (milliseconds)
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Unit**: milliseconds
- **Alert**: Khi > 5000ms (Slow Scrape)
- **Giải thích**: Scrape duration cao cho thấy exporter chậm

---

## 🖥️ **PANEL 15: Oracle Exporter CPU Usage**
- **Metric**: `rate(process_cpu_seconds_total[5m]) * 100`
- **Tên gọi**: Exporter CPU Usage
- **Ý nghĩa**: Phần trăm CPU usage của Oracle Exporter process
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Unit**: percent (0-100%)
- **Thresholds**:
  - Green: 0-50%
  - Yellow: 50-80%
  - Red: >80%
- **Alert**: Khi > 70% (High CPU Usage)
- **Giải thích**: CPU cao có thể làm chậm metrics collection

---

## 💾 **PANEL 16: Oracle Exporter Memory Usage**
- **Metric**: `process_resident_memory_bytes`
- **Tên gọi**: Exporter Memory Usage
- **Ý nghĩa**: Dung lượng RAM sử dụng bởi Oracle Exporter
- **Độ quan trọng**: ⭐⭐⭐⭐ (HIGH)
- **Unit**: bytes
- **Thresholds**:
  - Green: 0-200MB
  - Yellow: 200-300MB
  - Red: >300MB
- **Alert**: Khi > 300MB (High Memory Usage)
- **Giải thích**: Memory cao có thể gây memory leaks

---

## 📊 **PANEL 17: Oracle Exporter CPU & Memory Over Time**
- **Metrics**: 
  - `rate(process_cpu_seconds_total[5m]) * 100`
  - `process_resident_memory_bytes / 1024 / 1024`
- **Tên gọi**: Exporter Resource Usage Trend
- **Ý nghĩa**: Biểu đồ xu hướng CPU và Memory usage theo thời gian
- **Độ quan trọng**: ⭐⭐⭐ (MEDIUM)
- **Units**: 
  - CPU: percent
  - Memory: MB
- **Giải thích**: Theo dõi resource usage patterns và performance trends

---

## 🎯 **Tóm tắt Độ quan trọng:**

### 🔴 **CRITICAL (⭐⭐⭐⭐⭐):**
- Database Status
- Oracle Exporter Status
- Active Alerts
- Oracle Exporter Errors

### 🟡 **HIGH (⭐⭐⭐⭐):**
- Active Sessions
- Process Count
- Query Execution Rate
- Tablespace Usage
- Failed Transactions
- CPU Usage
- Memory Usage

### 🟢 **MEDIUM (⭐⭐⭐):**
- SQL Execution Rate Over Time
- Sessions Over Time
- SQL Parse Rate Over Time
- Transaction Activity Over Time
- Inactive Sessions Count
- Exporter Performance
- CPU & Memory Over Time

---

## 🚨 **Alert Rules Summary (Hiện tại trong hệ thống):**

1. **OracleDatabaseDown**: Database down (immediate notification)
2. **OracleHighSessionCount**: > 100 sessions
3. **OracleHighProcessCount**: > 60 processes
4. **OracleLoadTestActiveSessions**: > 20 sessions (dễ trigger)
5. **OracleLoadTestExecuteRate**: > 10 queries/sec (dễ trigger)
6. **OracleHighCPUUsage**: > 80% CPU (Oracle Exporter)
7. **OracleTablespaceSpaceLow**: Tablespace < 10% free
8. **OracleArchiveLogError**: Archive log errors

---

## 📝 **Ghi chú sử dụng:**

- **Refresh Rate**: 5 seconds
- **Time Range**: Last 1 hour (default)
- **Data Source**: Prometheus
- **Alert Manager**: Integrated với Prometheus alerts
- **Load Test**: Sử dụng `sql/quick_load_test.sql` hoặc `sql/simple_load_test.sql`
- **Discord Notifications**: Alerts được gửi tự động đến Discord
- **Webhook Converter**: Chuyển đổi format từ AlertManager sang Discord

---

## 🔧 **Troubleshooting:**

### Nếu Database Status = 0:
- Kiểm tra Oracle Database service
- Kiểm tra network connectivity
- Kiểm tra Oracle Exporter configuration

### Nếu High CPU/Memory:
- Kiểm tra load test đang chạy
- Restart Oracle Exporter nếu cần
- Monitor system resources

### Nếu Alerts firing:
- Xem chi tiết trong AlertManager: http://localhost:9093
- Kiểm tra Discord channel để nhận thông báo
- Sử dụng `monitoring_manager.bat` option 9 để check active alerts
- Xem logs để debug issues
