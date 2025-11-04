# Oracle Database Monitoring System

Hệ thống monitoring Oracle Database hoàn chỉnh với Prometheus, Grafana, AlertManager và Discord notifications.

## 📁 Cấu trúc thư mục

```
oracle-monitoring/
├── config/                          # Configuration files
│   ├── prometheus-local.yml         # Prometheus configuration
│   ├── alertmanager.yml             # AlertManager configuration
│   ├── oracle_alerts.yml            # Alert rules
│   ├── loki-config.yml              # Loki configuration
│   ├── promtail-local.yml           # Promtail configuration
│   └── exporter-local.toml          # Oracle Exporter configuration
├── scripts/                         # Scripts and utilities
│   ├── Dockerfile.webhook           # Dockerfile for webhook converter
│   └── discord-webhook-converter.py # Discord webhook converter
├── sql/                            # SQL scripts
│   ├── setup_monitor_user_local.sql # Setup monitoring user
│   ├── quick_load_test.sql          # Quick load test script
│   └── simple_load_test.sql         # Simple load test script
├── dashboards/                     # Grafana dashboards
│   ├── 3333_rev1.json              # Main Oracle dashboard
│   ├── grafana-oracle-focused-dashboard.json
│   └── grafana-working-dashboard.json
├── docs/                           # Documentation
│   ├── README.md                   # This file
│   ├── LOAD_TEST_INSTRUCTIONS.md   # Load test instructions
│   ├── ORACLE_DASHBOARD_3333_METRICS_EXPLANATION.md
│   └── GRAFANA_DASHBOARD_METRICS_EXPLANATION.md
├── data_mau/                       # Sample data
│   ├── courses.csv
│   ├── danh_sach_tai_khoan.csv
│   ├── technology.csv
│   ├── topic.csv
│   └── tracks.csv
├── docker-compose-local-oracle.yml # Docker Compose configuration
├── monitoring_manager.bat          # Management script
└── README.md                       # This file
```

## 🚀 Quick Start

### 1. Khởi động hệ thống
```bash
# Chạy script quản lý
monitoring_manager.bat

# Hoặc chạy trực tiếp
docker-compose -f docker-compose-local-oracle.yml up -d
```

### 2. Truy cập các giao diện
- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093
- **Oracle Exporter**: http://localhost:9161/metrics
- **Loki**: http://localhost:3100
- **Webhook Converter**: http://localhost:5002/health

## 🔧 Cấu hình

### Alert Rules
Các alert rules được định nghĩa trong `config/oracle_alerts.yml`:
- `OracleDatabaseDown` - Critical (immediate notification)
- `OracleLoadTestActiveSessions` - Warning (dễ trigger)
- `OracleLoadTestExecuteRate` - Warning (dễ trigger)
- `OracleHighSessionCount` - Warning
- `OracleHighProcessCount` - Warning
- `OracleHighCPUUsage` - Warning

### Discord Notifications
- AlertManager gửi alerts đến webhook converter
- Webhook converter format và gửi đến Discord
- URL Discord webhook được cấu hình trong `scripts/discord-webhook-converter.py`

## 📊 Monitoring

### Metrics được thu thập
- Database sessions và processes
- CPU usage
- Memory usage
- Tablespace usage
- Wait events
- Query performance

### Dashboards
- **3333_rev1.json**: Dashboard chính với các metrics Oracle Database
- Các dashboard khác cho monitoring chi tiết

## 🧪 Load Testing

### Quick Load Test
```sql
-- Chạy trong SQL Developer
@sql/quick_load_test.sql
```

### Simple Load Test
```sql
-- Chạy trong SQL Developer
@sql/simple_load_test.sql
```

## 🛠️ Quản lý

### Sử dụng monitoring_manager.bat
1. **Start Monitoring Stack** - Khởi động tất cả services
2. **Stop Monitoring Stack** - Dừng tất cả services
3. **Restart Monitoring Stack** - Khởi động lại
4. **Test System Health** - Kiểm tra tình trạng hệ thống
5. **Setup Monitor User** - Tạo user monitoring
6. **Open Monitoring Interfaces** - Mở các giao diện
7. **View Logs** - Xem logs của containers
8. **Reload Prometheus Configuration** - Reload cấu hình
9. **Check Active Alerts** - Kiểm tra alerts đang active

### Reload Prometheus sau khi sửa config
```bash
# Sử dụng monitoring_manager.bat option 8
# Hoặc chạy trực tiếp
curl -X POST http://localhost:9090/-/reload
```

## 🔍 Troubleshooting

### Kiểm tra logs
```bash
# Xem logs của tất cả containers
docker-compose -f docker-compose-local-oracle.yml logs

# Xem logs của container cụ thể
docker logs prometheus
docker logs alertmanager
docker logs webhook-converter
```

### Kiểm tra alerts
```bash
# Kiểm tra alerts trong Prometheus
curl http://localhost:9090/api/v1/alerts

# Kiểm tra alerts trong AlertManager
curl http://localhost:9093/api/v1/alerts
```

### Kiểm tra webhook converter
```bash
# Health check
curl http://localhost:5002/health
```

## 📝 Notes

- Tất cả services chạy trong Docker network `monitoring`
- Webhook converter chạy trên port 5002 (mapped từ 5001 trong container)
- Discord webhook URL được cấu hình trong webhook converter
- Alert rules có thể được reload mà không cần restart Prometheus
- Load test scripts được thiết kế để chạy trong SQL Developer

## 🆘 Support

Nếu gặp vấn đề:
1. Kiểm tra logs của containers
2. Sử dụng monitoring_manager.bat để test system health
3. Kiểm tra cấu hình trong thư mục `config/`
4. Đảm bảo Oracle Database đang chạy và accessible
