import pandas as pd
import os

def line_intersects_grid(p1, p2, grid_x_min, grid_x_max, grid_y_min, grid_y_max):
    """
    判断线段 (p1, p2) 是否与网格相交 (Liang-Barsky 算法)
    """
    x1, y1 = p1
    x2, y2 = p2
    dx = x2 - x1
    dy = y2 - y1
    p = [-dx, dx, -dy, dy]
    q = [x1 - grid_x_min, grid_x_max - x1, y1 - grid_y_min, grid_y_max - y1]
    
    u1, u2 = 0, 1

    for i in range(4):
        if p[i] == 0:
            if q[i] < 0:
                return False
        else:
            t = q[i] / p[i]
            if p[i] < 0:
                u1 = max(u1, t)
            else:
                u2 = min(u2, t)
    
    return u1 <= u2

def main():
    grid_file = '分维值结果_20250714_174808.csv'
    fault_data_dir = '平禹断层数据'
    output_file = 'grid_polygon_intersection_counts.csv'

    # 1. 读取网格数据
    try:
        grid_df = pd.read_csv(grid_file)
    except FileNotFoundError:
        print(f"错误: 网格文件 '{grid_file}' 未找到。")
        return

    # 初始化多边形相交计数
    grid_df['polygon_intersection_count'] = 0
    fault_files = [f for f in os.listdir(fault_data_dir) if f.endswith('.csv')]

    # 2. 遍历每个网格单元
    for index, grid_row in grid_df.iterrows():
        grid_x_min = grid_row['地理X最小值(m)']
        grid_x_max = grid_row['地理X最大值(m)']
        grid_y_min = grid_row['地理Y最小值(m)']
        grid_y_max = grid_row['地理Y最大值(m)']
        
        polygons_counted = 0

        # 3. 遍历每个断层文件 (多边形)
        for fault_file in fault_files:
            fault_file_path = os.path.join(fault_data_dir, fault_file)
            try:
                fault_df = pd.read_csv(fault_file_path)
            except Exception as e:
                print(f"读取断层文件 '{fault_file}' 时出错: {e}")
                continue

            if 'X' not in fault_df.columns or 'Y' not in fault_df.columns:
                print(f"断层文件 '{fault_file}' 缺少 'X' 或 'Y' 列。")
                continue

            points = list(zip(fault_df['X'], fault_df['Y']))
            num_points = len(points)

            if num_points < 2:
                continue

            # 4. 检查当前多边形是否有任何边与网格相交
            fault_intersects = False
            for i in range(num_points):
                p1 = points[i]
                p2 = points[(i + 1) % num_points]  # 闭合曲线

                if line_intersects_grid(p1, p2, grid_x_min, grid_x_max, grid_y_min, grid_y_max):
                    fault_intersects = True
                    break  # 找到相交边，无需再检查此多边形的其他边
            
            if fault_intersects:
                polygons_counted += 1
        
        # 5. 更新当前网格的多边形相交计数
        grid_df.loc[index, 'polygon_intersection_count'] = polygons_counted

    # 6. 输出结果
    grid_df.to_csv(output_file, index=False, encoding='utf-8-sig')
    print(f"处理完成，结果已保存到 '{output_file}'。")

if __name__ == '__main__':
    main()
