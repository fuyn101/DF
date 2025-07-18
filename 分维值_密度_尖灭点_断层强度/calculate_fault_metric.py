import pandas as pd
from shapely.geometry import Polygon
import os


def calculate_grid_metric_sum():
    """
    For each grid cell, calculates the sum of metrics from all intersecting faults.

    The metric for a single fault in a single grid cell is:
    (intersected area / fault's total area) * (fault's total perimeter / 2)
    """
    try:
        # --- Configuration ---
        fault_info_file = "fault_horizontal_displacement.csv"
        grid_file = "分维值结果_20250715_161502.csv"
        fault_data_dir = "平禹断层数据"
        output_file = "grid_cell_metric_sum.csv"
        # --- End Configuration ---

        # 1. Load all fault information into a list of objects for easy access
        fault_info_df = pd.read_csv(fault_info_file, encoding="utf-8-sig")
        grid_df = pd.read_csv(grid_file, encoding="utf-8-sig")

        faults_data = []
        for _, fault_row in fault_info_df.iterrows():
            fault_name = fault_row["断层名称"]
            total_area = fault_row["面积"]
            total_perimeter = fault_row["周长"]
            fault_coord_file = os.path.join(fault_data_dir, f"{fault_name}.csv")

            if not os.path.exists(fault_coord_file):
                print(f"Warning: Skipping fault '{fault_name}' (file not found).")
                continue
            if total_area == 0:
                print(f"Warning: Skipping fault '{fault_name}' (total area is zero).")
                continue

            fault_coords_df = pd.read_csv(fault_coord_file)
            fault_polygon = Polygon(zip(fault_coords_df["X"], fault_coords_df["Y"]))

            faults_data.append(
                {
                    "name": fault_name,
                    "total_area": total_area,
                    "total_perimeter": total_perimeter,
                    "polygon": fault_polygon,
                }
            )

        print(f"Loaded data for {len(faults_data)} faults.")

        # 2. Iterate through each grid cell to calculate the summed metric
        grid_results = []
        for _, grid_row in grid_df.iterrows():
            grid_index = grid_row["Grid Index"]
            grid_box = Polygon(
                [
                    (grid_row["Geo X Min (m)"], grid_row["Geo Y Min (m)"]),
                    (grid_row["Geo X Max (m)"], grid_row["Geo Y Min (m)"]),
                    (grid_row["Geo X Max (m)"], grid_row["Geo Y Max (m)"]),
                    (grid_row["Geo X Min (m)"], grid_row["Geo Y Max (m)"]),
                ]
            )

            total_metric_for_grid = 0
            # For each grid, iterate through all faults
            for fault in faults_data:
                if fault["polygon"].intersects(grid_box):
                    intersection = fault["polygon"].intersection(grid_box)
                    intersected_area = intersection.area

                    # Calculate the metric for this specific fault in this grid
                    metric = (intersected_area / fault["total_area"]) * (
                        fault["total_perimeter"] / 2
                    )
                    total_metric_for_grid += metric

            grid_results.append(
                {
                    "Grid Index": grid_index,
                    "Summed Metric": total_metric_for_grid / 40000,
                }
            )
            print(
                f"Processed Grid Index {grid_index}, Summed Metric: {total_metric_for_grid}"
            )

        # 3. Save the final results to a CSV file
        if grid_results:
            results_df = pd.DataFrame(grid_results)
            results_df.to_csv(output_file, index=False, encoding="utf-8-sig")
            print(f"\nCalculation complete. Results saved to '{output_file}'")
        else:
            print("\nNo results were generated.")

    except FileNotFoundError as e:
        print(f"Error: Input file not found - {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    calculate_grid_metric_sum()
