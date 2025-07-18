import os
import re
import csv


def parse_fault_filenames(directory_path, output_csv_path):
    """
    Parses fault data filenames to extract details and saves them to a CSV file.

    Args:
        directory_path (str): The path to the directory containing the fault data files.
        output_csv_path (str): The path to save the output CSV file.
    """
    # Regex to extract fault name and its properties from the filename
    # It captures the fault name and the content within the parentheses
    pattern = re.compile(r"坐标统计_(.*?)\((.*?)\)")

    results = []

    # Check if the directory exists
    if not os.path.isdir(directory_path):
        print(f"Error: Directory not found at '{directory_path}'")
        return

    for filename in os.listdir(directory_path):
        if filename.endswith(".csv"):
            match = pattern.search(filename)
            if match:
                fault_name = match.group(1).strip()
                properties_str = match.group(2).strip(
                    ")）"
                )  # Remove trailing parentheses

                # Split properties by ' ' or '，'
                properties = re.split(r"[，\s]+", properties_str)

                strike = ""
                dip = ""
                throw = ""

                for prop in properties:
                    if "H=" in prop:
                        throw = prop.replace("H=", "").strip()
                    elif "∠" in prop:
                        dip = prop.replace("∠", "").strip()
                    elif (
                        "°" in prop
                        or "NE" in prop
                        or "NW" in prop
                        or "SE" in prop
                        or "SW" in prop
                    ):
                        strike = prop.strip()

                # A fallback for cases where properties are not clearly separated
                if not strike and not dip and not throw:
                    # Simple split might work for some cases
                    parts = properties_str.split(" ")
                    if len(parts) > 0:
                        strike = parts[0]
                    if len(parts) > 1:
                        dip = parts[1]
                    if len(parts) > 2:
                        throw = parts[2]

                results.append([filename, fault_name, strike, dip, throw])

    # Write the results to a CSV file
    try:
        with open(output_csv_path, "w", newline="", encoding="utf-8-sig") as csvfile:
            writer = csv.writer(csvfile)
            # Write header
            writer.writerow(["文件名", "断层名称", "走向", "倾角", "落差(H)"])
            # Write data
            writer.writerows(results)
        print(f"Successfully created CSV file at '{output_csv_path}'")
    except IOError as e:
        print(f"Error writing to CSV file: {e}")


if __name__ == "__main__":
    data_directory = "平禹断层数据"
    output_file = "fault_data_summary.csv"
    parse_fault_filenames(data_directory, output_file)
