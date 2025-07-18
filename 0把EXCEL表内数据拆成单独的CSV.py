import pandas as pd
import os
import random


def excel_to_csv(excel_file_path, output_dir):
    """
    读取Excel文件，并将每个工作表另存为单独的CSV文件。

    参数:
        excel_file_path (str): 输入的Excel文件路径。
        output_dir (str): 保存输出CSV文件的目录。
    """
    try:
        # 加载Excel文件
        xls = pd.ExcelFile(excel_file_path)
    except FileNotFoundError:
        print(f"错误：文件未找到 '{excel_file_path}'")
        return
    except Exception as e:
        print(f"读取Excel文件时发生错误: {e}")
        return

    # 如果输出目录不存在，则创建它
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 获取Excel文件的基本名称
    base_name = os.path.splitext(os.path.basename(excel_file_path))[0]

    # 遍历Excel文件中的每个工作表
    for sheet_name in xls.sheet_names:
        try:
            # 将工作表读入DataFrame
            df = pd.read_excel(xls, sheet_name=sheet_name)

            # 为CSV创建一个有效的文件名
            random_suffix = random.randint(1000, 9999)
            csv_file_name = f"{base_name}_{sheet_name}_{random_suffix}.csv"
            csv_file_path = os.path.join(output_dir, csv_file_name)

            # 使用UTF-8编码将DataFrame保存为CSV文件，以防止乱码
            df.to_csv(csv_file_path, index=False, encoding="utf-8-sig")
            print(f"成功将工作表 '{sheet_name}' 保存为 '{csv_file_path}'")
        except Exception as e:
            print(f"处理工作表 '{sheet_name}' 时发生错误: {e}")


if __name__ == "__main__":
    # 您可以将文件名更改为您的特定Excel文件。
    # 该脚本将在运行脚本的同一目录中查找此文件。
    excel_file = r"源数据/平禹一矿断层新.xlsx"
    output_directory = "提取"
    print(f"正在处理Excel文件: {excel_file}")
    excel_to_csv(excel_file, output_directory)
