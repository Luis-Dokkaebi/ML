# src/storage/database_manager.py

import sqlite3
import os
from datetime import datetime

class DatabaseManager:
    def __init__(self, db_path="data/db/local_tracking.db"):
        self.db_path = db_path
        self._create_table()

    def _create_table(self):
        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS tracking (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        track_id INTEGER,
                        timestamp TEXT,
                        x REAL,
                        y REAL,
                        zone TEXT,
                        inside_zone INTEGER
                    )''')
        conn.commit()
        conn.close()

    def insert_record(self, track_id, x, y, zone, inside_zone):
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        timestamp = datetime.now().isoformat()
        c.execute("INSERT INTO tracking (track_id, timestamp, x, y, zone, inside_zone) VALUES (?, ?, ?, ?, ?, ?)",
                  (track_id, timestamp, x, y, zone, inside_zone))
        conn.commit()
        conn.close()

    def get_all_records(self):
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        c.execute("SELECT * FROM tracking")
        rows = c.fetchall()
        conn.close()
        return rows
