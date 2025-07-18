import os
import pandas as pd
from shapely.geometry import Polygon


def calculate_fault_properties():
    """
    Calculates the area and perimeter for each fault from CSV files
    and saves the results to a new CSV file.
    """
    data_dir = "平禹断层数据"
    output_file = "fault_area_perimeter.csv"
    results = []

    if not os.path.exists(data_dir):
        print(f"Error: Directory '{data_dir}' not found.")
        return

    for filename in os.listdir(data_dir):
        if filename.endswith(".csv"):
            fault_name = os.path.splitext(filename)[0]
            file_path = os.path.join(data_dir, filename)

            try:
                # Assuming the CSV has 'X' and 'Y' columns for coordinates
                df = pd.read_csv(file_path)

                # Check for required columns
                if "X" not in df.columns or "Y" not in df.columns:
                    print(
                        f"Warning: Skipping {filename}. It does not contain 'X' and 'Y' columns."
                    )
                    continue

                # Create a polygon from the coordinates
                coords = list(zip(df["X"], df["Y"]))

                if len(coords) < 3:
                    print(
                        f"Warning: Skipping {filename}. It has fewer than 3 coordinate pairs."
                    )
                    continue

                polygon = Polygon(coords)

                # Calculate area and perimeter (length)
                area = polygon.area
                perimeter = polygon.length

                results.append(
                    {"断层名称": fault_name, "面积": area, "周长": perimeter}
                )
                print(f"Processed {filename}: Area={area}, Perimeter={perimeter}")

            except Exception as e:
                print(f"Error processing {filename}: {e}")

    if results:
        # Create a DataFrame and save to CSV
        results_df = pd.DataFrame(results)
        results_df.to_csv(output_file, index=False, encoding="utf-8-sig")
        print(f"\nResults saved to {output_file}")
    else:
        print("No data was processed.")


if __name__ == "__main__":
    calculate_fault_properties()
