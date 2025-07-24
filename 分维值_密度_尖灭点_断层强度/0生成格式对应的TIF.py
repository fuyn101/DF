import os
import glob
import pandas as pd
import numpy as np
import rasterio
from rasterio.transform import from_origin
from rasterio.features import rasterize
from shapely.geometry import Polygon, LineString


def get_line_intersection(p1, p2, p3, p4):
    """
    计算两条线（由四个点定义）的交点。
    线1由p1和p2定义，线2由p3和p4定义。
    如果线平行或共线，则返回None。
    """
    x1, y1 = p1
    x2, y2 = p2
    x3, y3 = p3
    x4, y4 = p4

    denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    if denominator == 0:
        return None  # 平行或共线

    # 计算交点
    t_num = (x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)
    t = t_num / denominator

    intersect_x = x1 + t * (x2 - x1)
    intersect_y = y1 + t * (y2 - y1)

    return (intersect_x, intersect_y)


def create_geotiff_from_fault_data(csv_dir, output_tiff, resolution=1.0, buffer=100):
    """
    从包含断层坐标的CSV文件中创建地理参考TIF图像。

    参数:
    - csv_dir (str): 包含CSV文件的目录路径。
    - output_tiff (str): 输出TIF文件的路径。
    - resolution (float): 图像分辨率（每个像素代表的地理单位，例如米）。
    - buffer (int): 在断层数据周围添加的缓冲区（地理单位）。
    """
    print(f"开始处理目录: {csv_dir}")
    csv_files = glob.glob(os.path.join(csv_dir, "*.csv"))

    if not csv_files:
        print("错误：在指定目录中未找到CSV文件。")
        return

    all_coords = []
    shapes = []

    # 1. 读取所有CSV文件并提取坐标
    for f in csv_files:
        try:
            df = pd.read_csv(f)
            if "X" in df.columns and "Y" in df.columns:
                coords = list(zip(df["X"], df["Y"]))
                if not coords:
                    continue
                all_coords.extend(coords)
                # 如果坐标点数大于等于3且首尾坐标相同，则视为闭合多边形
                if len(coords) >= 3 and coords[0] == coords[-1]:
                    shapes.append(Polygon(coords))
                # 否则，如果坐标点数大于等于2，则视为线段
                elif len(coords) >= 2:
                    shapes.append(LineString(coords))
        except Exception as e:
            print(f"读取或处理文件 {f} 时出错: {e}")
            continue

    if not all_coords:
        print("错误：所有CSV文件中都没有找到有效的坐标。")
        return

    # 2. 计算所有坐标的边界框
    min_x = min(c[0] for c in all_coords) - buffer
    max_x = max(c[0] for c in all_coords) + buffer
    min_y = min(c[1] for c in all_coords) - buffer
    max_y = max(c[1] for c in all_coords) + buffer

    # 3. 计算TIF图像的尺寸
    width = int((max_x - min_x) / resolution)
    height = int((max_y - min_y) / resolution)

    # 定义地理变换
    transform = from_origin(min_x, max_y, resolution, resolution)

    # 4. 定义GeoTIFF元数据
    profile = {
        "driver": "GTiff",
        "height": height,
        "width": width,
        "count": 3,  # For RGB
        "dtype": "uint8",
        "crs": None,  # 没有指定坐标参考系统
        "transform": transform,
        "nodata": None,  # RGB图像通常没有单个nodata值
    }

    # 5. 栅格化几何图形
    # 创建一个白色背景的RGB图像
    rgb_image = np.full((3, height, width), 255, dtype=np.uint8)

    # 定义断层颜色为红色
    fault_color_r, fault_color_g, fault_color_b = 255, 0, 0

    # 栅格化几何图形并填充颜色
    if shapes:
        # rasterize 会将值为1的区域标记为断层
        burned_mask = rasterize(
            shapes=shapes,
            out_shape=(height, width),
            transform=transform,
            fill=0,  # 背景值
            default_value=1,  # 断层值
            dtype="uint8",
        )

        # 使用掩码将红色应用到图像上
        rgb_image[0, burned_mask == 1] = fault_color_r
        rgb_image[1, burned_mask == 1] = fault_color_g
        rgb_image[2, burned_mask == 1] = fault_color_b

        print(f"成功栅格化 {len(shapes)} 个几何图形。")
    else:
        print("警告: 没有可栅格化的几何图形。")

    # 6. 保存为GeoTIFF
    try:
        with rasterio.open(output_tiff, "w", **profile) as dst:
            dst.write(rgb_image)
        print(f"\n成功创建GeoTIFF文件: {output_tiff}")
    except Exception as e:
        print(f"错误: 保存GeoTIFF文件时出错: {e}")


if __name__ == "__main__":
    CSV_DIRECTORY = "提取"
    OUTPUT_TIFF_FILE = "faults_georef.tif"
    create_geotiff_from_fault_data(CSV_DIRECTORY, OUTPUT_TIFF_FILE)
