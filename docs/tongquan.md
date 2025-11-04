# Oracle Database Monitoring System

Hệ thống monitoring Oracle Database hoàn chỉnh với Prometheus, Grafana, Loki và AlertManager.

## 🏗️ Kiến trúc và Logic Vận Hành

### 📊 **Sơ đồ kiến trúc:**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Oracle DB     │───▶ Oracle Exporter │───▶│   Prometheus    │
│                 │    │   (Port 9161)   │    │   (Port 9090)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Loki        │◀── │    Promtail     │    │ AlertManager    │
│  (Port 3100)    │    │   (Port 9080)   │    │  (Port 9093)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                               │
         ▼                                               ▼
┌─────────────────┐                     ┌──────────────────────────┐    ┌─────────────────┐
│    Grafana      │                     │  Webhook Converter       │─── │     Alerts      │
│  (Port 3000)    │                     │ (Port 5001, Host 5002)   │    │                 │
└─────────────────┘                     └──────────────────────────┘    └─────────────────┘
```

### 🔄 **Logic Vận Hành:**

#### **1. Thu thập Metrics (Data Collection)**
- **Oracle Exporter** kết nối trực tiếp với Oracle Database
- Thực hiện các SQL queries để lấy metrics từ system views
- Expose metrics qua HTTP endpoint `/metrics` theo format Prometheus
- **Prometheus** scrape metrics từ Oracle Exporter mỗi 30 giây

#### **2. Thu thập Logs (Log Collection)**
- **Promtail** đọc log files từ Oracle Database (`D:/oracle-base/diag/`)
- Parse và gửi logs đến **Loki** theo cấu hình chuyên nghiệp
- **Loki** lưu trữ và index logs với labels để query hiệu quả

#### **3. Lưu trữ và Xử lý (Storage & Processing)**
- **Prometheus** lưu trữ time-series metrics
- **Loki** lưu trữ structured logs
- Cả hai đều có khả năng query và aggregation

#### **4. Giám sát và Cảnh báo (Monitoring & Alerting)**
- **Prometheus** đánh giá alert rules mỗi 15 giây
- Khi điều kiện alert được thỏa mãn, gửi alert đến **AlertManager**
- **AlertManager** xử lý routing, grouping và gửi notifications

#### **5. Visualization (Trực quan hóa)**
- **Grafana** kết nối với Prometheus và Loki làm datasource
- Tạo dashboards để hiển thị metrics và logs
- Cung cấp real-time monitoring và historical analysis

## 🛠️ Vai trò của từng công cụ

### **Oracle Exporter**
- **Vai trò**: Thu thập metrics từ Oracle Database
- **Cách hoạt động**: 
  - Kết nối Oracle DB qua connection string
  - Thực hiện SQL queries từ `exporter-local.toml`
  - Convert kết quả thành Prometheus metrics format
  - Serve metrics qua HTTP endpoint

### **Prometheus**
- **Vai trò**: Time-series database và alerting engine
- **Cách hoạt động**:
  - Scrape metrics từ Oracle Exporter mỗi 30s
  - Lưu trữ time-series data
  - Đánh giá alert rules từ `oracle_alerts.yml`
  - Cung cấp query language (PromQL)

### **Loki**
- **Vai trò**: Log aggregation system
- **Cách hoạt động**:
  - Nhận logs từ Promtail
  - Index logs theo labels
  - Cung cấp query interface cho logs
  - Tích hợp với Grafana

### **Promtail**
- **Vai trò**: Log shipper
- **Cách hoạt động**:
  - Đọc log files từ filesystem
  - Parse logs theo regex patterns
  - Gửi logs đến Loki
  - Track file positions

### **AlertManager**
- **Vai trò**: Alert routing và notification
- **Cách hoạt động**:
  - Nhận alerts từ Prometheus
  - Group và route alerts
  - Gửi notifications (email, webhook, etc.)
  - Quản lý alert states

### **Grafana**
- **Vai trò**: Visualization và dashboard
- **Cách hoạt động**:
  - Kết nối Prometheus và Loki làm datasource
  - Tạo dashboards với panels
  - Real-time visualization
  - Alert visualization

## 📝 Chi tiết Logging và Labels

### 🏷️ **Cấu hình Labels trong Promtail**

Hệ thống sử dụng 5 job thu thập logs với labels chuyên nghiệp:

#### **1. Oracle Alert Logs**
```yaml
job_name: oracle-alert-logs
labels:
  service_name: oracle
  log_type: alert
  environment: production
  __path__: /var/log/oracle/**/alert/*.log
```
**Thu thập**: Alert logs từ Oracle database (startup/shutdown, errors, warnings)

#### **2. Oracle Trace Logs**
```yaml
job_name: oracle-trace-logs
labels:
  service_name: oracle
  log_type: trace
  environment: production
  __path__: /var/log/oracle/**/trace/*.trc
```
**Thu thập**: Trace files từ Oracle processes (SQL execution, performance traces)

#### **3. Oracle XML Logs**
```yaml
job_name: oracle-xml-logs
labels:
  service_name: oracle
  log_type: xml
  environment: production
  __path__: /var/log/oracle/**/alert/*.xml
```
**Thu thập**: XML format logs (structured log entries)

#### **4. Oracle Listener Logs**
```yaml
job_name: oracle-listener-logs
labels:
  service_name: oracle
  log_type: listener
  environment: production
  __path__: /var/log/oracle/**/listener/*.log
```
**Thu thập**: TNS Listener logs (connection attempts, listener status)

#### **5. Oracle Client Logs**
```yaml
job_name: oracle-client-logs
labels:
  service_name: oracle
  log_type: client
  environment: production
  __path__: /var/log/oracle/**/client/*.log
```
**Thu thập**: Client connection logs (SQL*Plus, application connections)

### 🔍 **Cách Lọc Logs trong Grafana**

#### **1. Lọc Theo Service**
```
{service_name="oracle"}
```
**Kết quả**: Tất cả logs từ Oracle service

#### **2. Lọc Theo Loại Log**
```
{service_name="oracle", log_type="alert"}
{service_name="oracle", log_type="trace"}
{service_name="oracle", log_type="xml"}
{service_name="oracle", log_type="listener"}
{service_name="oracle", log_type="client"}
```

#### **3. Lọc Theo Mức Độ**
```
{service_name="oracle", level="error"}
{service_name="oracle", level="warn"}
{service_name="oracle", level="info"}
```

#### **4. Lọc Kết Hợp**
```
{service_name="oracle", log_type="alert", level="error"}
{service_name="oracle", log_type="trace", environment="production"}
```

#### **5. Lọc Theo Job Cụ Thể**
```
{job="oracle-alert-logs"}
{job="oracle-trace-logs"}
{job="oracle-xml-logs"}
{job="oracle-listener-logs"}
{job="oracle-client-logs"}
```

### 📊 **Ví Dụ Thực Tế**

#### **Tìm Tất Cả Lỗi Oracle:**
```
{service_name="oracle", level="error"}
```

#### **Xem Alert Logs Gần Đây:**
```
{service_name="oracle", log_type="alert"} |= "ORA-"
```

#### **Xem Trace Logs Có Chứa "SELECT":**
```
{service_name="oracle", log_type="trace"} |= "SELECT"
```

#### **Xem Listener Connection Issues:**
```
{service_name="oracle", log_type="listener"} |= "TNS-"
```

### 🎯 **Cách Sử Dụng Trong Grafana**

#### **Bước 1: Vào Grafana Logs**
1. Mở Grafana: `http://localhost:3000`
2. Chọn **Explore** → **Logs**
3. Chọn data source: **loki**

#### **Bước 2: Sử Dụng Label Browser**
1. Click vào **"Labels"** dropdown
2. Chọn `service_name` → chọn `oracle`
3. Chọn `log_type` → chọn loại log muốn xem
4. Click **"Show logs"**

#### **Bước 3: Viết Query Thủ Công**
```
# Tất cả Oracle logs
{service_name="oracle"}

# Chỉ alert logs
{service_name="oracle", log_type="alert"}

# Logs có chứa từ khóa cụ thể
{service_name="oracle"} |= "ORA-00600"

# Logs trong 1 giờ qua
{service_name="oracle"} |= "error" [1h]
```

### 🎨 **Lợi Ích của Cấu Hình Labels**

1. **Phân loại rõ ràng**: Mỗi loại log có label riêng
2. **Filtering dễ dàng**: Có thể lọc theo nhiều tiêu chí
3. **Performance tốt**: Labels giúp Loki index nhanh hơn
4. **Monitoring chuyên nghiệp**: Dễ tạo alerts và dashboards
5. **Troubleshooting hiệu quả**: Tìm log nhanh chóng

## 📊 Chi tiết Metrics

### 🔍 **Oracle Database Metrics (Chính)**

#### **Session Metrics**
- **`oracledb_sessions_value`**
  - **Ý nghĩa**: Số lượng sessions theo trạng thái và loại
  - **Labels**: `status` (ACTIVE, INACTIVE), `type` (USER, BACKGROUND)
  - **Chỉ số**: Count (số lượng)
  - **Giải thích**: 
    - ACTIVE: Sessions đang hoạt động
    - INACTIVE: Sessions không hoạt động
    - USER: Sessions của user applications
    - BACKGROUND: Sessions của Oracle background processes

#### **Process Metrics**
- **`oracledb_process_count`**
  - **Ý nghĩa**: Tổng số processes trong Oracle instance
  - **Chỉ số**: Count (số lượng)
  - **Giải thích**: Mỗi session cần 1 process, cộng với background processes

#### **Tablespace Metrics**
- **`oracledb_tablespace_bytes`**
  - **Ý nghĩa**: Kích thước tablespace đã sử dụng
  - **Labels**: `tablespace` (SYSTEM, SYSAUX, USERS, etc.)
  - **Chỉ số**: Bytes
  - **Giải thích**: Dung lượng đã sử dụng của từng tablespace

- **`oracledb_tablespace_free`**
  - **Ý nghĩa**: Dung lượng trống trong tablespace
  - **Labels**: `tablespace`
  - **Chỉ số**: Bytes
  - **Giải thích**: Dung lượng còn trống để sử dụng

#### **Wait Events Metrics**
- **`oracledb_wait_time_*`**
  - **Ý nghĩa**: Thời gian chờ đợi theo từng loại
  - **Labels**: Wait class (USER_IO, SYSTEM_IO, CONCURRENCY, etc.)
  - **Chỉ số**: Time (microseconds)
  - **Giải thích**: 
    - USER_IO: Chờ đợi I/O từ user
    - SYSTEM_IO: Chờ đợi I/O từ system
    - CONCURRENCY: Chờ đợi do lock contention

#### **Resource Utilization**
- **`oracledb_resource_current_utilization`**
  - **Ý nghĩa**: Mức độ sử dụng các resources
  - **Labels**: `resource_name` (sessions, processes, enqueue_locks, etc.)
  - **Chỉ số**: Count
  - **Giải thích**: Số lượng resources đang được sử dụng

- **`oracledb_resource_limit_value`**
  - **Ý nghĩa**: Giới hạn tối đa của các resources
  - **Labels**: `resource_name`
  - **Chỉ số**: Count (-1 = UNLIMITED)
  - **Giải thích**: Giới hạn tối đa cho phép của từng resource

#### **Activity Metrics**
- **`oracledb_activity_execute_count`**
  - **Ý nghĩa**: Số lần thực hiện SQL statements
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần execute SQL từ khi khởi động database

- **`oracledb_activity_parse_count_total`**
  - **Ý nghĩa**: Số lần parse SQL statements
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần parse SQL (hard parse + soft parse)

- **`oracledb_activity_user_commits`**
  - **Ý nghĩa**: Số lần commit của user
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số transactions đã commit

- **`oracledb_activity_user_rollbacks`**
  - **Ý nghĩa**: Số lần rollback của user
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số transactions đã rollback

#### **Exporter Performance Metrics**
- **`oracledb_exporter_last_scrape_duration_seconds`**
  - **Ý nghĩa**: Thời gian scrape metrics lần cuối
  - **Chỉ số**: Seconds
  - **Giải thích**: Thời gian Oracle Exporter cần để lấy metrics

- **`oracledb_exporter_last_scrape_error`**
  - **Ý nghĩa**: Lỗi scrape lần cuối
  - **Chỉ số**: 0 (success) hoặc 1 (error)
  - **Giải thích**: Trạng thái lỗi của lần scrape cuối

- **`oracledb_exporter_scrapes_total`**
  - **Ý nghĩa**: Tổng số lần scrape
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần Oracle Exporter đã scrape metrics

- **`oracledb_up`**
  - **Ý nghĩa**: Trạng thái kết nối Oracle Database
  - **Chỉ số**: 0 (down) hoặc 1 (up)
  - **Giải thích**: Oracle Database có đang hoạt động không

### 🔧 **Go Runtime Metrics (Oracle Exporter)**

#### **Memory Metrics**
- **`go_memstats_alloc_bytes`**
  - **Ý nghĩa**: Bytes đã allocate và đang sử dụng
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory đang được sử dụng bởi Oracle Exporter

- **`go_memstats_heap_alloc_bytes`**
  - **Ý nghĩa**: Heap memory đã allocate
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory trên heap đang được sử dụng

- **`go_memstats_heap_objects`**
  - **Ý nghĩa**: Số lượng objects trên heap
  - **Chỉ số**: Count
  - **Giải thích**: Số objects đang được quản lý bởi Go runtime

#### **Garbage Collection Metrics**
- **`go_gc_scan_heap_bytes`**
  - **Ý nghĩa**: Bytes được scan bởi garbage collector
  - **Chỉ số**: Bytes
  - **Giải thích**: Dung lượng memory được GC scan

- **`go_memstats_gc_cpu_fraction`**
  - **Ý nghĩa**: Tỷ lệ CPU time dành cho garbage collection
  - **Chỉ số**: Fraction (0-1)
  - **Giải thích**: Phần trăm CPU time dành cho GC

#### **Goroutines Metrics**
- **`go_goroutines`**
  - **Ý nghĩa**: Số lượng goroutines đang chạy
  - **Chỉ số**: Count
  - **Giải thích**: Số concurrent threads trong Go application

#### **Additional Memory Metrics**
- **`go_memstats_alloc_bytes_total`**
  - **Ý nghĩa**: Tổng bytes đã allocate (kể cả đã free)
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng memory đã allocate từ khi khởi động

- **`go_memstats_frees_total`**
  - **Ý nghĩa**: Tổng số lần free memory
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần memory được giải phóng

- **`go_memstats_mallocs_total`**
  - **Ý nghĩa**: Tổng số lần allocate memory
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần memory được allocate

- **`go_memstats_heap_idle_bytes`**
  - **Ý nghĩa**: Heap memory đang idle
  - **Chỉ số**: Bytes
  - **Giải thích**: Heap memory đã allocate nhưng chưa sử dụng

- **`go_memstats_heap_inuse_bytes`**
  - **Ý nghĩa**: Heap memory đang sử dụng
  - **Chỉ số**: Bytes
  - **Giải thích**: Heap memory đang được sử dụng bởi application

- **`go_memstats_heap_released_bytes`**
  - **Ý nghĩa**: Heap memory đã trả về OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Heap memory đã được trả về cho operating system

- **`go_memstats_heap_sys_bytes`**
  - **Ý nghĩa**: Heap memory đã lấy từ OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Tổng heap memory đã lấy từ operating system

#### **System Memory Metrics**
- **`go_memstats_sys_bytes`**
  - **Ý nghĩa**: Tổng system memory đã lấy từ OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Tổng memory đã lấy từ OS (heap + stack + other)

- **`go_memstats_stack_inuse_bytes`**
  - **Ý nghĩa**: Stack memory đang sử dụng
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory đang sử dụng cho goroutine stacks

- **`go_memstats_stack_sys_bytes`**
  - **Ý nghĩa**: Stack memory đã lấy từ OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Tổng stack memory đã lấy từ OS

- **`go_memstats_mcache_inuse_bytes`**
  - **Ý nghĩa**: Memory cache đang sử dụng
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory đang sử dụng cho mcache structures

- **`go_memstats_mcache_sys_bytes`**
  - **Ý nghĩa**: Memory cache đã lấy từ OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Tổng mcache memory đã lấy từ OS

- **`go_memstats_mspan_inuse_bytes`**
  - **Ý nghĩa**: Memory span đang sử dụng
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory đang sử dụng cho mspan structures

- **`go_memstats_mspan_sys_bytes`**
  - **Ý nghĩa**: Memory span đã lấy từ OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Tổng mspan memory đã lấy từ OS

- **`go_memstats_buck_hash_sys_bytes`**
  - **Ý nghĩa**: Memory cho bucket hash table
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory sử dụng cho profiling bucket hash table

- **`go_memstats_other_sys_bytes`**
  - **Ý nghĩa**: Memory khác đã lấy từ OS
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory khác đã lấy từ OS (không thuộc heap, stack, mcache, mspan)

#### **Additional GC Metrics**
- **`go_gc_duration_seconds`**
  - **Ý nghĩa**: Thời gian thực hiện garbage collection
  - **Labels**: `quantile` (0, 0.25, 0.5, 0.75, 1)
  - **Chỉ số**: Seconds
  - **Giải thích**: Thời gian thực hiện GC theo percentiles

- **`go_gc_duration_seconds_sum`**
  - **Ý nghĩa**: Tổng thời gian GC
  - **Chỉ số**: Seconds
  - **Giải thích**: Tổng thời gian đã dành cho garbage collection

- **`go_gc_duration_seconds_count`**
  - **Ý nghĩa**: Số lần thực hiện GC
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần garbage collection đã thực hiện

- **`go_memstats_next_gc_bytes`**
  - **Ý nghĩa**: Ngưỡng bytes cho lần GC tiếp theo
  - **Chỉ số**: Bytes
  - **Giải thích**: Số bytes heap sẽ đạt được trước khi GC tiếp theo chạy

- **`go_memstats_last_gc_time_seconds`**
  - **Ý nghĩa**: Thời gian lần GC cuối cùng
  - **Chỉ số**: Unix timestamp
  - **Giải thích**: Thời điểm lần garbage collection cuối cùng

#### **Additional Runtime Metrics**
- **`go_info`**
  - **Ý nghĩa**: Thông tin Go version
  - **Labels**: `version`
  - **Chỉ số**: 1
  - **Giải thích**: Thông tin về version của Go runtime

- **`go_threads`**
  - **Ý nghĩa**: Số lượng OS threads
  - **Chỉ số**: Count
  - **Giải thích**: Số lượng operating system threads đã tạo

- **`go_memstats_lookups_total`**
  - **Ý nghĩa**: Tổng số pointer lookups
  - **Chỉ số**: Counter
  - **Giải thích**: Tổng số lần runtime đã thực hiện pointer lookups

### 📈 **Process Metrics (System)**
- **`process_cpu_seconds_total`**
  - **Ý nghĩa**: Tổng CPU time đã sử dụng
  - **Chỉ số**: Seconds
  - **Giải thích**: Tổng thời gian CPU mà process đã sử dụng

- **`process_resident_memory_bytes`**
  - **Ý nghĩa**: Resident memory size
  - **Chỉ số**: Bytes
  - **Giải thích**: Memory thực tế đang sử dụng trong RAM

- **`process_virtual_memory_bytes`**
  - **Ý nghĩa**: Virtual memory size
  - **Chỉ số**: Bytes
  - **Giải thích**: Tổng virtual memory mà process đã allocate

- **`process_virtual_memory_max_bytes`**
  - **Ý nghĩa**: Maximum virtual memory
  - **Chỉ số**: Bytes (-1 = unlimited)
  - **Giải thích**: Giới hạn tối đa virtual memory cho process

- **`process_start_time_seconds`**
  - **Ý nghĩa**: Thời gian khởi động process
  - **Chỉ số**: Unix timestamp
  - **Giải thích**: Thời điểm process được khởi động

- **`process_open_fds`**
  - **Ý nghĩa**: Số file descriptors đang mở
  - **Chỉ số**: Count
  - **Giải thích**: Số lượng files/sockets đang được process sử dụng

- **`process_max_fds`**
  - **Ý nghĩa**: Giới hạn tối đa file descriptors
  - **Chỉ số**: Count
  - **Giải thích**: Giới hạn tối đa số file descriptors process có thể mở

### 📊 **Tóm tắt Metrics theo Category**

#### **Oracle Database Metrics (8 categories)**
1. **Session Metrics**: `oracledb_sessions_value`
2. **Process Metrics**: `oracledb_process_count`
3. **Tablespace Metrics**: `oracledb_tablespace_bytes`, `oracledb_tablespace_free`
4. **Wait Events**: `oracledb_wait_time_*`
5. **Resource Utilization**: `oracledb_resource_current_utilization`, `oracledb_resource_limit_value`
6. **Activity Metrics**: `oracledb_activity_*`
7. **Exporter Performance**: `oracledb_exporter_*`
8. **Database Status**: `oracledb_up`

#### **Go Runtime Metrics (6 categories)**
1. **Memory Metrics**: `go_memstats_alloc_*`, `go_memstats_heap_*`
2. **Garbage Collection**: `go_gc_*`, `go_memstats_gc_*`
3. **Goroutines**: `go_goroutines`
4. **System Memory**: `go_memstats_sys_*`, `go_memstats_stack_*`
5. **Cache & Span**: `go_memstats_mcache_*`, `go_memstats_mspan_*`
6. **Runtime Info**: `go_info`, `go_threads`, `go_memstats_lookups_total`

#### **Process Metrics (7 metrics)**
1. **CPU**: `process_cpu_seconds_total`
2. **Memory**: `process_resident_memory_bytes`, `process_virtual_memory_*`
3. **Process Info**: `process_start_time_seconds`
4. **File Descriptors**: `process_open_fds`, `process_max_fds`

### 🎯 **Metrics Quan trọng nhất để Monitor**

#### **Database Health**
- `oracledb_up` - Database availability
- `oracledb_sessions_value` - Session count
- `oracledb_process_count` - Process count
- `oracledb_tablespace_free` - Free space

#### **Performance**
- `oracledb_activity_execute_count` - SQL execution rate
- `oracledb_wait_time_*` - Wait events
- `process_cpu_seconds_total` - CPU usage
- `process_resident_memory_bytes` - Memory usage

#### **Exporter Health**
- `oracledb_exporter_last_scrape_error` - Scrape errors
- `oracledb_exporter_last_scrape_duration_seconds` - Scrape time
- `go_goroutines` - Goroutine count
- `go_memstats_gc_cpu_fraction` - GC overhead

## 📝 Logging với Loki

### **Cấu hình Log Collection**
- **Promtail** đọc logs từ `/var/log/oracle/`
- **Log types được collect**:
  - Alert logs: `alert_*.log`
  - Trace logs: `trace_*.log`
  - Listener logs: `listener.log`

### **Log Parsing**
- **Alert logs**: Parse timestamp, level, message
- **Trace logs**: Parse timestamp, level, message
- **Labels**: `job`, `level`, `message`

### **Log Queries trong Grafana**
```logql
# Tất cả Oracle logs
{job=~"oracle-.*"}

# Chỉ alert logs
{job="oracle-alert-logs"}

# Logs có level ERROR
{job=~"oracle-.*"} |= "ERROR"

# Logs trong 1 giờ qua
{job=~"oracle-.*"} |= "ORA-" | __error__=""
```

## 🚀 Khởi động hệ thống

### 1. Chuẩn bị Oracle Database
```sql
-- Chạy script setup
sqlplus system/password@//localhost:1521/ORCL @sql/setup_monitor_user_local.sql
```

### 2. Khởi động monitoring stack
```bash
# Sử dụng monitoring manager (khuyến nghị)
monitoring_manager.bat

# Hoặc chạy thủ công
docker-compose -f docker-compose-local-oracle.yml up -d
```

### 3. Kiểm tra hệ thống
```bash
# Sử dụng monitoring manager
monitoring_manager.bat
# Chọn option 4: Test System Health
```

## 📊 Truy cập các giao diện

| Service | URL | Credentials | Mục đích |
|---------|-----|-------------|----------|
| **Grafana** | http://localhost:3000 | admin/admin | Dashboard chính |
| **Prometheus** | http://localhost:9090 | - | Query metrics |
| **AlertManager** | http://localhost:9093 | - | Quản lý alerts |
| **Oracle Exporter** | http://localhost:9161/metrics | - | Raw metrics |
| **Loki** | http://localhost:3100 | - | Query logs |

## 🧪 Load Testing

### **Simple Load Test (Khuyến nghị)**
```bash
# Sử dụng monitoring manager
monitoring_manager.bat
# Chọn option 5: Run Simple Load Test
```

**Tính năng Simple Load Test:**
- 1 session thay vì 5 sessions (dễ monitor)
- 500+ queries thay vì 37,500+ queries (load vừa phải)
- Thời gian chạy: 1-2 phút
- Phù hợp cho testing và demo

### **Alert Thresholds (Đã điều chỉnh cho demo)**
- **Session Count**: > 10 sessions (thay vì 100)
- **Process Count**: > 50 processes (thay vì 200)
- **Alert Duration**: 1 minute (thay vì 5 minutes)

## 🚨 Alerting Rules

| Alert | Threshold | Severity | Description |
|-------|-----------|----------|-------------|
| `OracleHighSessionCount` | > 10 sessions | Warning | Số session quá cao |
| `OracleHighProcessCount` | > 50 processes | Warning | Số process quá cao |
| `OracleTablespaceSpaceLow` | < 10% free | Critical | Tablespace sắp hết chỗ |
| `OracleDatabaseDown` | Exporter down | Critical | Database không phản hồi |

## 🎛️ Dashboard Management

### **Enhanced Dashboard**
- **File**: `grafana-enhanced-dashboard.json`
- **14 panels** với Oracle và Go metrics
- **Real-time monitoring** với refresh 30s
- **Mục đích**: Tổng quan về toàn bộ hệ thống

### **CPU Management Dashboard**
- **File**: `grafana-cpu-management-dashboard.json`
- **14 panels** chuyên biệt cho CPU management
- **Real-time monitoring** với refresh 10s
- **Mục đích**: Quản lý và tối ưu CPU performance

#### **CPU Dashboard Features:**
- **CPU Usage Overview**: Tổng quan CPU usage
- **Go GC CPU Fraction**: Garbage collection overhead
- **Active Goroutines**: Số lượng concurrent threads
- **Memory Allocation Rate**: Tốc độ allocate memory
- **CPU Usage Over Time**: Biểu đồ CPU theo thời gian
- **Memory Usage Over Time**: Biểu đồ memory theo thời gian
- **Garbage Collection Activity**: Hoạt động GC
- **Heap Objects and Memory**: Quản lý heap memory
- **Oracle Database CPU Metrics**: CPU metrics từ Oracle
- **System Resource Usage**: Sử dụng system resources
- **CPU Performance Alerts**: Cảnh báo CPU
- **Memory Pressure**: Áp lực memory
- **Process Efficiency**: Hiệu quả process
- **System Health Score**: Điểm số health tổng thể

### **Import Dashboards**
1. Truy cập Grafana: http://localhost:3000
2. Vào **Dashboards** → **Import**
3. Upload dashboard JSON files:
   - `grafana-enhanced-dashboard.json` (Tổng quan)
   - `grafana-cpu-management-dashboard.json` (CPU Management)
4. Chọn datasource Prometheus
5. Click **Import**

### **Dashboard Auto-loading**
Dashboards sẽ tự động được load khi khởi động Grafana container.

## 🔧 Cấu hình Files

### **Oracle Exporter**
- **File**: `exporter-local.toml`
- **Mô tả**: Cấu hình SQL queries để lấy metrics

### **Prometheus**
- **File**: `prometheus-local.yml`
- **Mô tả**: Cấu hình scraping targets và alert rules

### **Loki**
- **File**: `loki-config.yml`
- **Mô tả**: Cấu hình log storage và indexing

### **AlertManager**
- **File**: `alertmanager.yml`
- **Mô tả**: Cấu hình alert routing và notifications

## 🐛 Troubleshooting

### **Loki không khởi động**
```bash
# Kiểm tra logs
docker logs loki

# Lỗi thường gặp: Schema version không tương thích
# Giải pháp: Đã cập nhật schema v13 và tsdb index
```

### **Oracle Exporter không kết nối**
```bash
# Kiểm tra connection string
docker logs oracledb-exporter

# Kiểm tra Oracle listener
lsnrctl status

# Kiểm tra user permissions
sqlplus monitor_user/monitor_pass@//localhost:1521/ORCL
```

### **Prometheus không scrape metrics**
```bash
# Kiểm tra targets
curl http://localhost:9090/api/v1/targets

# Kiểm tra Oracle Exporter
curl http://localhost:9161/metrics
```

### **Logs không hiển thị trong Grafana**
```bash
# Kiểm tra Promtail logs
docker logs promtail

# Kiểm tra Loki connectivity
curl http://localhost:3100/ready

# Kiểm tra log files path
# Đảm bảo D:/oracle-base/diag/ có log files
ls -la D:/oracle-base/diag/rdbms/orcl/orcl/alert/
ls -la D:/oracle-base/diag/rdbms/orcl/orcl/trace/

# Kiểm tra Promtail targets
curl http://localhost:9080/targets
```

### **Lỗi YAML parsing trong Promtail**
```bash
# Kiểm tra cấu hình
docker exec promtail cat /etc/promtail/config.yml

# Restart Promtail
docker-compose -f docker-compose-local-oracle.yml restart promtail
```

## 📊 **Grafana Dashboards**

### **1. Oracle Enhanced Dashboard**
- **File**: `grafana-enhanced-dashboard.json`
- **URL**: http://localhost:3000
- **Login**: admin/admin
- **Features**: 14 panels covering all Oracle metrics

### **2. CPU Management Dashboard**
- **File**: `grafana-cpu-management-dashboard.json`
- **URL**: http://localhost:3000
- **Login**: admin/admin
- **Features**: 14 panels focused on CPU and resource management

### **3. Professional Oracle Dashboard** ⭐ **NEW**
- **File**: `grafana-professional-oracle-dashboard.json`
- **URL**: http://localhost:3000
- **Login**: admin/admin
- **Features**: 15 panels optimized for load testing monitoring
- **Focus**: Metrics that change most during `simple_user_worker` execution

#### **Professional Dashboard Highlights:**
- **Real-time Status Overview**: Database status, active sessions, process count, query rate
- **Load Test Impact Analysis**: Detailed explanation of which metrics change during load test
- **SQL Activity Monitoring**: Execute count, parse count, commits, rollbacks over time
- **Session & Process Tracking**: Active/inactive sessions, process count trends
- **Resource Utilization**: Tablespace usage, resource limits, exporter performance
- **Alert Status**: Current firing alerts with color-coded severity

#### **Key Metrics for Load Testing:**
1. **SQL Execution Count** - Increases 33%+ during load test
2. **SQL Parse Count** - Increases 18%+ during load test  
3. **User Commits** - Increases 25%+ during load test
4. **Active Sessions** - Increases 75%+ during load test
5. **Process Count** - Increases 19%+ during load test
6. **Tablespace Usage** - Minimal increase during load test

## ❓ FAQ

### **Q: Tại sao có nhiều metrics Go runtime?**
**A:** Oracle Exporter được viết bằng Go, nên tự động expose metrics về Go runtime (memory, GC, goroutines). Đây là behavior mặc định của Go applications.

### **Q: Metrics nào quan trọng nhất để monitor?**
**A:** 
- **Oracle metrics**: `oracledb_*` - Metrics thực sự của Oracle Database
- **Go metrics**: `go_*` - Metrics về performance của Oracle Exporter
- **Process metrics**: `process_*` - Metrics về system resources

### **Q: Dashboard nào tốt nhất cho load testing?**
**A:** **Professional Oracle Dashboard** - được thiết kế đặc biệt để theo dõi các metrics thay đổi rõ rệt nhất khi chạy `simple_user_worker`.

### **Q: Tại sao không thấy alerts khi chạy load test?**
**A:** Load test hiện tại chưa đủ mạnh để vượt ngưỡng cảnh báo. Có thể tăng cường load test hoặc điều chỉnh alert thresholds.

## 🤝 Hỗ trợ

Nếu gặp vấn đề, hãy:
1. Sử dụng monitoring manager: `monitoring_manager.bat`
2. Chọn option 4: Test System Health
3. Chọn option 8: View Logs để kiểm tra logs
4. Kiểm tra network connectivity
5. Xem lại cấu hình files

## 🔧 **Giải pháp Oracle Exporter Connection Issues**

### **Vấn đề thường gặp: `ORA-12541: TNS:no listener`**

#### **Nguyên nhân:**
- Oracle Listener không được cấu hình đúng để accept connections từ Docker containers
- Oracle Exporter container không thể kết nối đến Oracle Database trên host machine

#### **Giải pháp đã test thành công:**

##### **1. Cấu hình Oracle Listener**
```bash
# Mở Oracle Net Configuration Assistant
# Chọn "Listener Configuration" → "Select Protocols"
# Đảm bảo TCP được chọn trong "Selected Protocols"
# Trong màn hình tiếp theo, cấu hình:
# - Port: 1521
# - Host: 0.0.0.0 (thay vì localhost hoặc hostname)
```

##### **2. Cấu hình Docker Compose**
```yaml
# File: docker-compose-local-oracle.yml
oracledb-exporter:
  image: iamseth/oracledb_exporter:latest
  container_name: oracledb-exporter
  ports:
    - "9161:9161"
  environment:
    - DATA_SOURCE_NAME=monitor_user/monitor_pass@host.docker.internal:1521/orcl
  depends_on:
    - prometheus
  restart: unless-stopped
  networks:
    - monitoring
  extra_hosts:
    - "host.docker.internal:host-gateway"
```

##### **3. Cấu hình Networks**
```yaml
# Thêm vào cuối file docker-compose-local-oracle.yml
networks:
  monitoring:
    driver: bridge
```

##### **4. Cập nhật tất cả services để sử dụng network**
```yaml
# Thêm vào mỗi service:
networks:
  - monitoring
```

#### **Các cấu hình đã thử nhưng không thành công:**
- ❌ `network_mode: host` - Gây conflict với port mapping
- ❌ `DATA_SOURCE_NAME=//localhost:1521/orcl` - Container không thể resolve localhost
- ❌ `DATA_SOURCE_NAME=//192.168.1.5:1521/orcl` - IP không cố định
- ❌ `DATA_SOURCE_NAME=//Admin-PC:1521/orcl` - Hostname resolution issues

#### **Cấu hình cuối cùng hoạt động:**
- ✅ `host.docker.internal:host-gateway` - Docker's built-in host resolution
- ✅ `networks: monitoring` - Isolated network cho tất cả services
- ✅ `HOST = 0.0.0.0` trong listener.ora - Accept connections từ tất cả interfaces

#### **Verification Steps:**
```bash
# 1. Kiểm tra Oracle Listener
lsnrctl status

# 2. Test connection từ host
tnsping localhost:1521

# 3. Test connection với monitor_user
sqlplus monitor_user/monitor_pass@localhost:1521/orcl

# 4. Kiểm tra Oracle Exporter logs
docker logs oracledb-exporter --tail 10

# 5. Test metrics endpoint
curl http://localhost:9161/metrics
```

#### **Kết quả mong đợi:**
- ✅ Oracle Exporter logs: `"Listening on :9161"` (không có error)
- ✅ Metrics endpoint trả về Oracle metrics
- ✅ Grafana dashboard hiển thị data
- ✅ Prometheus targets status: UP

---
**Lưu ý**: Hệ thống này được thiết kế cho môi trường development/testing. Đối với production, cần cấu hình bảo mật và performance tuning phù hợp.