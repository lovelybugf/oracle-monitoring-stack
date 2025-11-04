# Oracle Dashboard (Redesigned) - Giải thích các thông số

Tài liệu này mô tả các panel/metric trong `oracle_dashboard_redesigned.json` và cách diễn giải nhanh.

## 1) Database Status
- Metric: `max(up{job="oracle-db"})`
- Hiển thị: UP/DOWN theo mapping giá trị 1/0 (màu xanh/đỏ).

## 2) Active Sessions (tức thời)
- Metric: `sum(oracledb_sessions_value{status="ACTIVE"})`
- Ý nghĩa: Tổng session ACTIVE tại thời điểm.

## 3) Process Count
- Metric: `oracledb_process_count`
- Ý nghĩa: Số process Oracle đang chạy.

## 4) Query Rate
- Metric: `rate(oracledb_activity_execute_count[5m])`
- Ý nghĩa: Tốc độ thực thi SQL (queries/second).

## 5) SQL Activity Over Time
- Metric: `rate(oracledb_activity_execute_count[5m])`
- Ý nghĩa: Xu hướng hoạt động SQL theo thời gian.

## 6) Sessions by Status (ACTIVE trên INACTIVE)
- Metrics:
  - `sum(oracledb_sessions_value{status="ACTIVE"})`
  - `sum(oracledb_sessions_value{status="INACTIVE"})`
- Hiển thị: Ưu tiên đường ACTIVE (z-index cao hơn) để nhìn rõ so sánh.

## 7) Transaction Activity
- Metrics:
  - `rate(oracledb_activity_user_commits[5m])`
  - `rate(oracledb_activity_user_rollbacks[5m])`
- Ý nghĩa: Nhịp commit/rollback của người dùng.

## 8) Tablespace Usage
- Metric: `oracledb_tablespace_bytes{type="PERMANENT"}` (hoặc nhãn tương ứng)
- Ý nghĩa: Dung lượng theo từng tablespace (bytes).

## 9) Inactive Sessions (tức thời)
- Metric: `sum(oracledb_sessions_value{status="INACTIVE"})`
- Ý nghĩa: Tổng session INACTIVE, hỗ trợ phát hiện kết nối treo.

## 10) Active Alerts (tổng số)
- Metric: `count(ALERTS{alertstate="firing"})`
- Ý nghĩa: Số lượng cảnh báo đang firing trong Prometheus.

## 11) Oracle Exporter CPU Usage
- Metric: `rate(process_cpu_seconds_total[5m]) * 100`
- Ý nghĩa: % CPU ước tính của exporter container.

---

## Thuật ngữ chính (giải thích kỹ)

- **Session (phiên kết nối)**: Kết nối logic giữa client và Oracle Database. Mỗi session tương ứng một người dùng/ứng dụng đang kết nối.
  - Trạng thái phổ biến:
    - **ACTIVE**: Session đang thực thi câu lệnh (đang tiêu thụ tài nguyên).
    - **INACTIVE**: Session rảnh/đang chờ (không chạy câu lệnh tại thời điểm đo).
  - Liên quan metric:
    - `oracledb_sessions_value{status="ACTIVE"|"INACTIVE"}`: Đếm số session theo trạng thái.
    - Số ACTIVE cao phản ánh tải thực tế; INACTIVE cao có thể do connection giữ lâu/không giải phóng.

- **Process (tiến trình Oracle)**: Tiến trình hệ điều hành mà Oracle dùng để xử lý yêu cầu.
  - Phân loại chính:
    - **Server process**: Phục vụ các session (xử lý SQL, trả kết quả).
    - **Background processes**: Quản trị nội bộ như `PMON`, `SMON`, `DBWn`, `LGWR`, `CKPT`, `ARCn`...
  - Liên quan metric:
    - `oracledb_process_count` hoặc metric tương đương: Số lượng process hiện có.
    - Process tăng theo tải; cần theo dõi ngưỡng cấu hình tối đa để tránh cạn kiệt tài nguyên.

- **Transaction (giao dịch)**: Nhóm thao tác SQL đảm bảo tính nguyên tử (ACID). Kết thúc bằng `COMMIT` hoặc `ROLLBACK`.
  - **COMMIT**: Xác nhận thay đổi; dữ liệu được ghi bền vững, phát sinh redo.
  - **ROLLBACK**: Huỷ bỏ thay đổi trong giao dịch; sử dụng undo để khôi phục.
  - Liên quan metric:
    - `rate(oracledb_activity_user_commits[5m])`: Tốc độ commit/giây.
    - `rate(oracledb_activity_user_rollbacks[5m])`: Tốc độ rollback/giây.
    - Rollback tăng có thể chỉ ra lỗi ứng dụng, deadlock, hoặc kiểm soát giao dịch chưa tốt.

---

Ghi chú:
- Datasource: `${PROMETHEUS}` để linh hoạt môi trường.
- Thời gian mặc định: 1h, refresh 30s.
- Muốn có metric mới: cập nhật exporter (TOML + `--custom.metrics`) và đảm bảo Prometheus scrape.
- Tần suất thu thập: chỉnh `scrape_interval` của job `oracle-db` trong `prometheus-local.yml`.
- Cảnh báo: định nghĩa trong `oracle_alerts.yml`; panel Active Alerts phản ánh tổng đang firing.