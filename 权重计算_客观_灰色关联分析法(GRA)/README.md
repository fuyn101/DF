# 灰色关联分析 (GRA) 权重计算工具

该文件夹包含使用 **灰色关联分析 (Grey Relational Analysis, GRA)** 方法来计算指标权重的 MATLAB 工具。

## 文件结构

- `GRA.m`: 核心函数文件，实现了灰色关联分析算法，用于计算指标权重。
- `DEMO.m`: 一个演示脚本，展示了如何使用 `GRA.m` 函数。
- `visualize_gra_weights.m`: 一个辅助函数，用于将计算出的权重进行可视化展示。

## `GRA.m` 函数详解

该函数通过灰色关联度来评估各个指标的重要性，并据此分配权重。

### 语法

```matlab
[weights, gamma] = GRA(data, indicator_types, ro)
```

### 输入参数

- `data` (m x n 矩阵): 原始数据，其中 `m` 是样本数量，`n` 是指标数量。
- `indicator_types` (1 x n 向量): 定义每个指标的类型。
  - `1`: 正向指标 (效益型)，数值越大越好。
  - `-1`: 负向指标 (成本型)，数值越小越好。
- `ro` (可选, 标量): 分辨系数，用于调整关联系数。默认值为 `0.5`。

### 输出参数

- `weights` (1 x n 向量): 计算得出的各指标的权重。
- `gamma` (1 x n 向量): 各指标的灰色关联度。

## `visualize_gra_weights.m` 函数详解

该函数用于生成权重的条形图，方便结果的可视化分析。

### 语法

```matlab
visualize_gra_weights(weights)
```

### 输入参数

- `weights` (1 x n 向量): 需要可视化的权重向量。

## 如何使用

1.  **准备数据**: 准备一个 `m x n` 的数据矩阵。
2.  **定义指标类型**: 创建一个向量来指明每个指标是正向还是负向。
3.  **运行演示脚本**: 打开并运行 `DEMO.m`。该脚本会加载示例数据，调用 `GRA.m` 函数计算权重，并在命令行中显示结果，最后调用 `visualize_gra_weights.m` 生成权重图。

### `DEMO.m` 示例代码

```matlab
% --- 1. 准备数据 ---
data = [ ... ]; % 你的数据矩阵

% --- 2. 定义指标类型 ---
indicator_types = [1, 1, -1, 1, 1]; % 示例：第3个是负向指标

% --- 3. 调用函数计算权重 ---
[weights, gamma] = GRA(data, indicator_types);

% --- 4. 显示结果 ---
disp('各指标的权重:');
disp(weights);

% --- 5. 结果可视化 ---
visualize_gra_weights(weights);
```

该工具包提供了一个完整、独立的解决方案，用于通过灰色关联分析法进行客观赋权。
