# src/analysis/efficiency_calculator.py

import sqlite3
import pandas as pd

class EfficiencyCalculator:
    def __init__(self, db_path="data/db/local_tracking.db"):
        self.db_path = db_path

    def load_data(self):
        conn = sqlite3.connect(self.db_path)
        df = pd.read_sql_query("SELECT * FROM tracking", conn)
        conn.close()
        return df

    def calculate_efficiency(self):
        df = self.load_data()

        if df.empty:
            print("No hay datos en la base de datos.")
            return None

        # Agrupamos por cada persona y zona
        results = []

        grouped = df.groupby(['track_id', 'zone'])
        for (track_id, zone), group in grouped:
            total_frames = len(group)
            inside_frames = group['inside_zone'].sum()
            outside_frames = total_frames - inside_frames
            efficiency = (inside_frames / total_frames) * 100

            results.append({
                'track_id': track_id,
                'zone': zone,
                'total_frames': total_frames,
                'inside_frames': inside_frames,
                'outside_frames': outside_frames,
                'efficiency_%': round(efficiency, 2)
            })

        return pd.DataFrame(results)
