import os
import time
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed

import oracledb


def run_query(dsn: str, username: str, password: str, duration_sec: int, sql: str) -> None:
    connection = None
    try:
        # oracledb default Thin mode (no Oracle Client required)
        connection = oracledb.connect(user=username, password=password, dsn=dsn)
        with connection.cursor() as cursor:
            end_time = time.time() + duration_sec
            while time.time() < end_time:
                cursor.execute(sql)
                try:
                    _ = cursor.fetchone()
                except Exception:
                    pass
                # minimal work, avoid commit to keep it simple
    finally:
        try:
            if connection is not None:
                connection.close()
        except Exception:
            pass


def main():
    # Environment variables or defaults
    dsn = os.environ.get("ORACLE_DSN", "127.0.0.1:1521/orcl")
    username = os.environ.get("ORACLE_USER", "monitor_user")
    password = os.environ.get("ORACLE_PASS", "monitor_pass")
    num_sessions = int(os.environ.get("NUM_SESSIONS", "100"))
    duration_sec = int(os.environ.get("DURATION_SEC", "240"))
    sql = os.environ.get(
        "TEST_SQL",
        "SELECT COUNT(*) FROM dual CONNECT BY LEVEL <= 500000"
    )

    print(f"Starting {num_sessions} sessions for {duration_sec}s -> {dsn}")

    with ThreadPoolExecutor(max_workers=num_sessions) as executor:
        futures = [
            executor.submit(run_query, dsn, username, password, duration_sec, sql)
            for _ in range(num_sessions)
        ]
        for _ in as_completed(futures):
            pass

    print("Load test finished.")


if __name__ == "__main__":
    main()


