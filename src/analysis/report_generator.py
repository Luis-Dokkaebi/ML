# src/analysis/report_generator.py

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

class ReportGenerator:
    def __init__(self, results_df):
        self.df = results_df

    def generate_table(self):
        print("\n===== TABLA DE EFICIENCIA =====\n")
        print(self.df)

    def generate_bar_plot(self, save_path=None):
        plt.figure(figsize=(10, 6))
        sns.barplot(data=self.df, x="track_id", y="efficiency_%", hue="zone", palette="viridis")
        plt.title("Porcentaje de eficiencia por persona")
        plt.xlabel("ID de Persona")
        plt.ylabel("Eficiencia (%)")
        plt.ylim(0, 100)
        plt.legend(title="Zona", bbox_to_anchor=(1.05, 1), loc='upper left')
        plt.tight_layout()
        if save_path:
            plt.savefig(save_path)
        plt.show()

    def export_to_excel(self, file_path="data/reporting/eficiencia.xlsx"):
        self.df.to_excel(file_path, index=False)
        print(f"Reporte exportado a: {file_path}")
