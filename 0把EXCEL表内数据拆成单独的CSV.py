import pandas as pd
import os
import random


def excel_to_csv(excel_file_path):
    """
    Reads an Excel file and saves each sheet as a separate CSV file.

    Args:
        excel_file_path (str): The path to the input Excel file.
    """
    try:
        # Load the Excel file
        xls = pd.ExcelFile(excel_file_path)
    except FileNotFoundError:
        print(f"错误：文件未找到 '{excel_file_path}'")
        return
    except Exception as e:
        print(f"读取Excel文件时发生错误: {e}")
        return

    # Get the directory of the Excel file to save CSVs in the same location
    output_dir = os.path.dirname(excel_file_path)
    if not output_dir:
        output_dir = "."

    # Get the base name of the excel file
    base_name = os.path.splitext(os.path.basename(excel_file_path))[0]

    # Iterate through each sheet in the Excel file
    for sheet_name in xls.sheet_names:
        try:
            # Read the sheet into a DataFrame
            df = pd.read_excel(xls, sheet_name=sheet_name)

            # Create a valid filename for the CSV
            random_suffix = random.randint(1000, 9999)
            csv_file_name = f"{base_name}_{sheet_name}_{random_suffix}.csv"
            csv_file_path = os.path.join(output_dir, csv_file_name)

            # Save the DataFrame to a CSV file, using UTF-8 encoding to prevent garbled text
            df.to_csv(csv_file_path, index=False, encoding="utf-8-sig")
            print(f"成功将工作表 '{sheet_name}' 保存为 '{csv_file_path}'")
        except Exception as e:
            print(f"处理工作表 '{sheet_name}' 时发生错误: {e}")


if __name__ == "__main__":
    # You can change the file name to your specific Excel file.
    # The script will look for this file in the same directory where the script is run.
    excel_file = r"新的断层数据/梁北断层新.xlsx"
    print(f"正在处理Excel文件: {excel_file}")
    excel_to_csv(excel_file)
