# 📊 Oracle Dashboard 3333 Metrics Explanation

## 🎯 **Dashboard: Oracle Database Monitoring (Grafana.net ID: 3333)**

Dashboard này được thiết kế bởi cộng đồng Grafana và sử dụng các metrics chuẩn có sẵn từ Oracle Exporter.

---

## 📈 **Panel 1: OracleDB Status**
- **Metric**: `oracledb_up{instance="$host"}`
- **Ý nghĩa**: Trạng thái kết nối Oracle Database
- **Giá trị**: 0 (DOWN) hoặc 1 (UP)
- **Quan trọng**: ⭐⭐⭐⭐⭐ (Critical)
- **Alert threshold**: 0 (Database down)
- **Load test impact**: Luôn = 1 khi database hoạt động
- **Troubleshooting**: Nếu = 0, kiểm tra Oracle service và listener

---

## 📈 **Panel 2: Active Sessions**
- **Metric**: `sum(oracledb_sessions_value{status="ACTIVE"})`
- **Ý nghĩa**: Số lượng sessions đang hoạt động
- **Quan trọng**: ⭐⭐⭐⭐⭐ (Critical)
- **Alert threshold**: > 100 sessions (OracleHighSessionCount)
- **Load test impact**: Tăng đáng kể khi chạy load test
- **Troubleshooting**: Nếu cao liên tục, có thể có long-running queries

---

## 📈 **Panel 3: User Commits**
- **Metric**: `oracledb_activity_user_commits{instance="$host"}`
- **Ý nghĩa**: Số lượng user commits đã thực hiện
- **Quan trọng**: ⭐⭐⭐⭐ (High)
- **Alert threshold**: Không có threshold cố định
- **Load test impact**: Tăng 25%+ khi chạy load test
- **Troubleshooting**: Nếu thấp, có thể có transaction issues

---

## 📈 **Panel 4: Execute Count**
- **Metric**: `oracledb_activity_execute_count{instance="$host"}`
- **Ý nghĩa**: Tổng số lần thực hiện SQL statements
- **Quan trọng**: ⭐⭐⭐⭐⭐ (Critical)
- **Alert threshold**: Không có threshold cố định
- **Load test impact**: Tăng 33%+ khi chạy load test
- **Troubleshooting**: Nếu thấp, có thể có performance issues

---

## 📈 **Panel 5: Last Scrape Duration Seconds**
- **Metric**: `oracledb_exporter_last_scrape_duration_seconds{instance="$host"}`
- **Ý nghĩa**: Thời gian scrape metrics cuối cùng (giây)
- **Quan trọng**: ⭐⭐⭐ (Medium)
- **Alert threshold**: > 5 seconds
- **Load test impact**: Có thể tăng khi database load cao
- **Troubleshooting**: Nếu cao, có thể có performance issues với exporter

---

## 📈 **Panel 6: Total Scrapes**
- **Metric**: `oracledb_exporter_scrapes_total{instance="$host"}`
- **Ý nghĩa**: Tổng số lần scrape metrics
- **Quan trọng**: ⭐⭐⭐ (Medium)
- **Alert threshold**: Không có threshold cố định
- **Load test impact**: Tăng liên tục theo thời gian
- **Troubleshooting**: Nếu không tăng, exporter có thể bị lỗi

---

## 📈 **Panel 7: Wait Time Concurrency**
- **Metric**: `oracledb_wait_time_concurrency{instance="$host"}`
- **Ý nghĩa**: Thời gian chờ do concurrency issues (locks, latches)
- **Quan trọng**: ⭐⭐⭐⭐ (High)
- **Alert threshold**: > 100ms
- **Load test impact**: Tăng khi có nhiều concurrent transactions
- **Troubleshooting**: Nếu cao, có thể có lock contention

---

## 📈 **Panel 8: Wait Time Commit**
- **Metric**: `oracledb_wait_time_commit{instance="$host"}`
- **Ý nghĩa**: Thời gian chờ commit transactions
- **Quan trọng**: ⭐⭐⭐⭐ (High)
- **Alert threshold**: > 50ms
- **Load test impact**: Tăng khi có nhiều commits
- **Troubleshooting**: Nếu cao, có thể có I/O issues hoặc log buffer problems

---

## 📈 **Panel 9: Wait Time System I/O**
- **Metric**: `oracledb_wait_time_system_io{instance="$host"}`
- **Ý nghĩa**: Thời gian chờ system I/O operations
- **Quan trọng**: ⭐⭐⭐⭐ (High)
- **Alert threshold**: > 100ms
- **Load test impact**: Tăng khi có nhiều system I/O
- **Troubleshooting**: Nếu cao, có thể có disk I/O bottlenecks

---

## 📈 **Panel 10: Wait Time User I/O**
- **Metric**: `oracledb_wait_time_user_io{instance="$host"}`
- **Ý nghĩa**: Thời gian chờ user I/O operations (table scans, index reads)
- **Quan trọng**: ⭐⭐⭐⭐⭐ (Critical)
- **Alert threshold**: > 50ms
- **Load test impact**: Tăng đáng kể khi chạy load test
- **Troubleshooting**: Nếu cao, cần optimize queries hoặc tăng buffer cache

---

## 📈 **Panel 11: Wait Time Application**
- **Metric**: `oracledb_wait_time_application{instance="$host"}`
- **Ý nghĩa**: Thời gian chờ do application logic
- **Quan trọng**: ⭐⭐⭐ (Medium)
- **Alert threshold**: > 100ms
- **Load test impact**: Tăng khi có application locks
- **Troubleshooting**: Nếu cao, có thể có application-level issues

---

## 📈 **Panel 12: Wait Time Network**
- **Metric**: `oracledb_wait_time_network{instance="$host"}`
- **Ý nghĩa**: Thời gian chờ network operations
- **Quan trọng**: ⭐⭐⭐ (Medium)
- **Alert threshold**: > 50ms
- **Load test impact**: Tăng khi có nhiều network traffic
- **Troubleshooting**: Nếu cao, có thể có network issues

---

## 📈 **Panel 13: Table Locks**
- **Metric**: Không rõ metric cụ thể (cần kiểm tra)
- **Ý nghĩa**: Thông tin về table locks
- **Quan trọng**: ⭐⭐⭐ (Medium)
- **Alert threshold**: Tùy thuộc vào metric
- **Load test impact**: Có thể tăng khi có lock contention
- **Troubleshooting**: Nếu cao, có thể có deadlock issues

---

## 🎯 **Metrics Quan trọng nhất cho Load Testing**

### **Top 8 Metrics thay đổi rõ rệt nhất:**

1. **Execute Count** - Tăng 33%+ ⭐⭐⭐⭐⭐
2. **Active Sessions** - Tăng đáng kể ⭐⭐⭐⭐⭐
3. **Wait Time User I/O** - Tăng đáng kể ⭐⭐⭐⭐⭐
4. **User Commits** - Tăng 25%+ ⭐⭐⭐⭐
5. **Wait Time Concurrency** - Tăng khi có concurrent load ⭐⭐⭐⭐
6. **Wait Time Commit** - Tăng khi có nhiều commits ⭐⭐⭐⭐
7. **Wait Time System I/O** - Tăng khi có system I/O ⭐⭐⭐⭐
8. **Last Scrape Duration** - Tăng khi database load cao ⭐⭐⭐

### **Metrics ít thay đổi:**
- **OracleDB Status** - Luôn = 1 (UP)
- **Total Scrapes** - Tăng liên tục theo thời gian
- **Wait Time Network** - Ít thay đổi trừ khi có network issues
- **Wait Time Application** - Ít thay đổi trừ khi có app locks

---

## 🚨 **Alert Thresholds (Hiện tại trong hệ thống)**

| Metric | Threshold | Severity | Description |
|--------|-----------|----------|-------------|
| `up{job="oracle-db"}` | = 0 | Critical | Database down (OracleDatabaseDown) |
| `sum(oracledb_sessions_value{status="ACTIVE"})` | > 100 | Warning | Too many active sessions (OracleHighSessionCount) |
| `oracledb_process_count` | > 60 | Warning | Too many processes (OracleHighProcessCount) |
| `rate(oracledb_activity_execute_count[5m])` | > 10/sec | Warning | High query rate (OracleLoadTestExecuteRate) |
| `sum(oracledb_sessions_value{status="ACTIVE"})` | > 20 | Warning | Load test active sessions (OracleLoadTestActiveSessions) |
| `rate(process_cpu_seconds_total[5m]) * 100` | > 80 | Warning | High CPU usage (OracleHighCPUUsage) |

---

## 🔧 **Troubleshooting Guide**

### **Nếu OracleDB Status = DOWN:**
1. Kiểm tra Oracle service: `Get-Service "OracleOraDB19Home1TNSListener"`
2. Kiểm tra listener: `lsnrctl status`
3. Kiểm tra Oracle Exporter logs: `docker logs oracledb-exporter`

### **Nếu Active Sessions cao:**
1. Kiểm tra long-running queries: `SELECT * FROM v$session WHERE status='ACTIVE'`
2. Kiểm tra wait events: `SELECT * FROM v$session_wait`
3. Có thể cần kill sessions: `ALTER SYSTEM KILL SESSION 'sid,serial#'`

### **Nếu Wait Time User I/O cao:**
1. Kiểm tra slow queries: `SELECT * FROM v$sql WHERE elapsed_time > 1000000`
2. Kiểm tra buffer cache hit ratio: `SELECT * FROM v$buffer_pool_statistics`
3. Có thể cần tăng buffer cache size

### **Nếu Wait Time Concurrency cao:**
1. Kiểm tra locks: `SELECT * FROM v$lock`
2. Kiểm tra latches: `SELECT * FROM v$latch`
3. Có thể có deadlock issues

### **Nếu Last Scrape Duration cao:**
1. Kiểm tra Oracle Exporter performance
2. Kiểm tra database load
3. Có thể cần tăng scrape interval

---

## 📊 **Dashboard Features**

### **Real-time Monitoring:**
- **Refresh rate**: Tùy thuộc vào cấu hình
- **Time range**: Có thể điều chỉnh
- **Auto-refresh**: Có thể enable/disable

### **Color Coding:**
- **Green**: Normal/Healthy
- **Yellow**: Warning threshold
- **Red**: Critical threshold

### **Interactive Features:**
- **Zoom**: Click và drag để zoom vào time range
- **Legend**: Click để show/hide metrics
- **Tooltip**: Hover để xem giá trị chi tiết
- **Variable**: `$host` để chọn instance

---

## 🎯 **Kết luận**

Dashboard 3333 này rất chuẩn và sử dụng các metrics cơ bản có sẵn từ Oracle Exporter. Điều này giúp:

1. **Tập trung vào metrics quan trọng** - Wait events, sessions, activity
2. **Không phụ thuộc vào metrics phức tạp** - CPU/RAM metrics
3. **Dễ dàng identify** performance issues
4. **Optimize** cho load testing scenarios
5. **Community tested** - Được sử dụng rộng rãi

**Dashboard này là lựa chọn tốt nhất cho monitoring Oracle Database với metrics có sẵn!** 🚀✨

---

## 📚 **Tham khảo**

- **Grafana.net Dashboard**: [Oracle Database Monitoring (ID: 3333)](https://grafana.com/grafana/dashboards/3333)
- **Oracle Exporter**: [iamseth/oracledb_exporter](https://github.com/iamseth/oracledb_exporter)
- **Oracle Wait Events**: [Oracle Documentation - Wait Events](https://docs.oracle.com/en/database/oracle/oracle-database/19/refrn/wait-events.html)
