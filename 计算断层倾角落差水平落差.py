import pandas as pd
import numpy as np
import re


def parse_angle(angle_str):
    """
    Parses the angle string, which can be a single value or a range.
    For a range (e.g., '40°～62°'), it returns the average.
    For a single value (e.g., '70°'), it returns the value.
    """
    angle_str = str(angle_str).replace("°", "").strip()
    if "～" in angle_str:
        parts = angle_str.split("～")
        return (float(parts[0]) + float(parts[1])) / 2
    else:
        # Use regex to find the first valid number in the string
        match = re.search(r"(\d+\.?\d*)", angle_str)
        if match:
            return float(match.group(1))
        else:
            return np.nan


# Load the CSV file
try:
    df = pd.read_csv("fault_data_summary.csv", encoding="utf-8")
except UnicodeDecodeError:
    df = pd.read_csv("fault_data_summary.csv", encoding="gbk")


# Apply the parsing function to the '倾角' column
df["倾角_度"] = df["倾角"].apply(parse_angle)

# Convert degrees to radians for the tan function
df["倾角_弧度"] = np.radians(df["倾角_度"])

# Calculate the horizontal displacement (b)
# b = a / tan(angle)
df["水平落差(b)"] = df["落差C"] / np.tan(df["倾角_弧度"])

# Round the result to 2 decimal places
df["水平落差(b)"] = df["水平落差(b)"].round(2)

# Save the results to a new CSV file
output_filename = "fault_horizontal_displacement.csv"
df.to_csv(output_filename, index=False, encoding="utf-8-sig")

print(f"计算完成，结果已保存到 {output_filename}")
print("\n计算结果预览:")
print(df[["断层名称", "倾角", "落差C", "水平落差(b)"]].to_string())
