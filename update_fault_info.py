import pandas as pd


def fill_missing_perimeter():
    """
    Fills the missing 'C' values in '断层信息.csv' with the '周长'
    from '断层统计数据_面积周长.csv'.
    """
    info_file = "断层信息.csv"
    stats_file = "断层统计数据_面积周长.csv"

    try:
        # Load the file to be updated, handling whitespace in column names and data
        info_df = pd.read_csv(info_file, skipinitialspace=True)
        info_df.columns = info_df.columns.str.strip()

        # Load the data source file
        stats_df = pd.read_csv(stats_file, skipinitialspace=True)
        stats_df["断层名称"] = stats_df["断层名称"].str.strip()

        # Create a dictionary mapping fault names to perimeters
        # The fault name in stats_df is '断层名称' and perimeter is '周长'
        perimeter_map = stats_df.set_index("断层名称")["周长"].to_dict()

        # The fault name in info_df is 'N'
        # We check for NaN because empty cells are often read as NaN by pandas
        # We use .loc for safer assignment
        for index, row in info_df.iterrows():
            if pd.isna(row["C"]):
                fault_name = row["N"].strip()
                if fault_name in perimeter_map:
                    # Update the 'C' value with the corresponding perimeter
                    info_df.loc[index, "C"] = perimeter_map[fault_name]

        # Save the updated dataframe back to the original file, preserving encoding
        info_df.to_csv(info_file, index=False, encoding="utf-8-sig")

        print(f"File '{info_file}' has been updated successfully.")

    except FileNotFoundError as e:
        print(
            f"Error: {e}. Make sure both '{info_file}' and '{stats_file}' are present."
        )
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    fill_missing_perimeter()
