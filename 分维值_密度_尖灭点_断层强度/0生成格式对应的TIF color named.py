import os
import glob
import pandas as pd
import numpy as np
import rasterio
from rasterio.transform import from_origin
from rasterio.features import rasterize
from shapely.geometry import Polygon, LineString
from PIL import Image, ImageDraw, ImageFont


# 辅助函数，用于根据索引生成不同的颜色
def get_color_by_index(index):
    """
    根据索引生成一个独特的颜色。
    会从一个预定义的颜色列表中循环选择。
    """
    colors = [
        (255, 0, 0),  # 红
        (0, 255, 0),  # 绿
        (0, 0, 255),  # 蓝
        (255, 255, 0),  # 黄
        (0, 255, 255),  # 青
        (255, 0, 255),  # 洋红
        (128, 0, 0),  # 栗色
        (0, 128, 0),  # 深绿
        (0, 0, 128),  # 海军蓝
        (255, 165, 0),  # 橙色
        (128, 0, 128),  # 紫色
        (0, 128, 128),  # 蓝绿色
    ]
    return colors[index % len(colors)]


def create_geotiff_from_fault_data(csv_dir, output_tiff, resolution=1.0, buffer=100):
    """
    从包含断层坐标的CSV文件中创建地理参考TIF图像。
    不同的断层将以不同的颜色显示，并在其旁边显示名称。

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
    fault_geometries = []  # 存储每个断层的详细信息
    shapes_for_rasterize = []  # 专门用于栅格化的(geom, id)对
    fault_color_map = {}
    fault_id_counter = 1

    # 1. 读取所有CSV文件，为每个断层分配ID和颜色，并准备几何数据
    for i, f in enumerate(csv_files):
        fault_name = os.path.basename(f).replace(".csv", "")
        try:
            df = pd.read_csv(f)
            if "X" in df.columns and "Y" in df.columns:
                coords = list(zip(df["X"], df["Y"]))
                if not coords:
                    continue

                all_coords.extend(coords)

                if fault_name not in fault_color_map:
                    fault_color_map[fault_name] = {
                        "id": fault_id_counter,
                        "color": get_color_by_index(len(fault_color_map)),
                    }
                    fault_id_counter += 1

                fault_info = fault_color_map[fault_name]
                fault_id = fault_info["id"]
                fault_color = fault_info["color"]

                geom = None
                if len(coords) >= 3 and coords[0] == coords[-1]:
                    geom = Polygon(coords)
                elif len(coords) >= 2:
                    geom = LineString(coords)

                if geom:
                    fault_geometries.append(
                        {
                            "name": fault_name,
                            "geom": geom,
                            "id": fault_id,
                            "color": fault_color,
                        }
                    )
                    shapes_for_rasterize.append((geom, fault_id))

        except Exception as e:
            print(f"读取或处理文件 {f} 时出错: {e}")
            continue

    if not all_coords:
        print("错误：所有CSV文件中都没有找到有效的坐标。")
        return

    # 2. 计算边界框
    min_x = min(c[0] for c in all_coords) - buffer
    max_x = max(c[0] for c in all_coords) + buffer
    min_y = min(c[1] for c in all_coords) - buffer
    max_y = max(c[1] for c in all_coords) + buffer

    # 3. 计算图像尺寸
    width = int((max_x - min_x) / resolution)
    height = int((max_y - min_y) / resolution)
    transform = from_origin(min_x, max_y, resolution, resolution)

    # 4. 定义GeoTIFF元数据
    profile = {
        "driver": "GTiff",
        "height": height,
        "width": width,
        "count": 3,
        "dtype": "uint8",
        "crs": None,
        "transform": transform,
        "nodata": None,
    }

    # 5. 栅格化几何图形并着色
    if not shapes_for_rasterize:
        print("警告: 没有可栅格化的几何图形。")
        rgb_image = np.full((3, height, width), 255, dtype=np.uint8)
    else:
        burned_array = rasterize(
            shapes=shapes_for_rasterize,
            out_shape=(height, width),
            transform=transform,
            fill=0,
            dtype="uint16",
        )
        rgb_image = np.full((3, height, width), 255, dtype=np.uint8)
        for name, data in fault_color_map.items():
            fault_id = data["id"]
            color = data["color"]
            mask = burned_array == fault_id
            rgb_image[0, mask] = color[0]
            rgb_image[1, mask] = color[1]
            rgb_image[2, mask] = color[2]
        print(f"\n成功栅格化 {len(shapes_for_rasterize)} 个几何图形。")

    # 6. 使用Pillow添加断层名称
    # 将numpy数组 (C, H, W) 转换为Pillow图像 (H, W, C)
    rgb_image_pil = Image.fromarray(np.transpose(rgb_image, (1, 2, 0)), "RGB")
    draw = ImageDraw.Draw(rgb_image_pil)

    try:
        font = ImageFont.truetype("msyh.ttc", 15)  # 尝试使用微软雅黑字体
    except IOError:
        print("警告: 'msyh.ttc' (微软雅黑) 字体未找到。尝试 'simhei.ttf' (黑体)。")
        try:
            font = ImageFont.truetype("simhei.ttf", 15)
        except IOError:
            print("警告: 'simhei.ttf' (黑体) 也未找到。将使用默认字体。")
            font = ImageFont.load_default()

    for fault in fault_geometries:
        geom = fault["geom"]
        name = fault["name"]
        color = fault["color"]

        # 使用代表点确保标签在多边形内部，对线使用质心
        label_point = (
            geom.representative_point() if isinstance(geom, Polygon) else geom.centroid
        )

        # 将地理坐标转换为像素坐标
        px, py = ~transform * (label_point.x, label_point.y)

        # 在图像上绘制文本
        draw.text((px, py), name, fill=color, font=font)
        print(f"在像素坐标 ({int(px)}, {int(py)}) 处为断层 '{name}' 添加标签。")

    # 将Pillow图像转换回numpy数组 (C, H, W)
    final_rgb_image = np.transpose(np.array(rgb_image_pil), (2, 0, 1))

    # 7. 保存最终的GeoTIFF文件
    try:
        with rasterio.open(output_tiff, "w", **profile) as dst:
            dst.write(final_rgb_image)
        print(f"\n成功创建带标签的GeoTIFF文件: {output_tiff}")
    except Exception as e:
        print(f"错误: 保存GeoTIFF文件时出错: {e}")


if __name__ == "__main__":
    CSV_DIRECTORY = "提取"
    OUTPUT_TIFF_FILE = "faults_georef_colored.tif"
    create_geotiff_from_fault_data(CSV_DIRECTORY, OUTPUT_TIFF_FILE)
