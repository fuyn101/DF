# CRITIC 权重法分析

该目录包含使用 CRITIC (Criteria Importance Through Intercriteria Correlation) 方法进行多准则决策分析 (MCDA) 的 Matlab 函数。CRITIC 方法是一种客观赋权法，它通过评估每个准则的对比强度（变异性）和与其他准则的冲突性来确定其权重。

## 文件列表

- `CRITIC_standard.m`: 标准 CRITIC 方法的函数实现。
- `CRITIC_improved_Liruyu.m`: 一种改良的 CRITIC 方法的函数实现，主要区别在于冲突性的计算方式。

---

## `CRITIC_standard.m` 使用说明

该函数实现了标准的 CRITIC 权重计算方法。

### 功能与算法

1.  **数据标准化**: 采用离差标准化（Min-Max Normalization）方法对原始数据进行处理，并支持正向（效益型）和负向（成本型）指标。
2.  **对比强度 (Variability)**: 通过计算每个指标标准化后的**标准差**来衡量其对比强度。标准差越大，说明指标内部的取值差异越大，信息量越丰富。
3.  **冲突性 (Conflict)**: 通过计算指标间的**相关系数**来量化冲突性。冲突性定义为 `sum(1 - r)`，其中 `r` 是相关系数矩阵。一个指标与其他指标的相关性越低，冲突性就越小，其权重相应会更高。
4.  **信息承载量 (Information Content)**: 信息量 `C` 由对比强度和冲突性相乘得到 (`C = variability * conflict`)。
5.  **权重与得分计算**: 将信息量归一化得到最终的客观权重，并基于权重计算每个样本的综合得分。

### 如何使用

`CRITIC_standard` 是一个函数，需要从其他脚本或 Matlab 命令行中调用。

**函数定义:**
```matlab
function [weights, scores, normalized_data] = CRITIC_standard(data, indicator_types)
```

**输入参数:**
- `data`: `m x n` 的原始数据矩阵（m个样本, n个指标）。
- `indicator_types`: `1 x n` 的行向量，定义指标类型。`1` 代表正向指标，`-1` 代表负向指标。

**输出参数:**
- `weights`: `1 x n` 的权重向量。
- `scores`: `m x 1` 的各样本综合得分。
- `normalized_data`: 标准化后的数据矩阵。

**使用示例:**
```matlab
% 假设有 5 个样本和 4 个指标
data = rand(5, 4) * 100;
% 假设第1, 2, 4个是正向指标，第3个是负向指标
indicator_types = [1, 1, -1, 1];

% 调用函数
[w, s] = CRITIC_standard(data, indicator_types);

% 显示结果
disp('标准CRITIC计算出的权重为:');
disp(w);
disp('各样本的得分为:');
disp(s);
```

---

## `CRITIC_improved_Liruyu.m` 使用说明

该函数实现了一种改良的 CRITIC 方法，其主要创新在于对“冲突性”指标的计算方式进行了优化。

### 功能与算法

该函数在数据标准化、对比强度计算等方面与标准 CRITIC 方法保持一致，核心区别在于**冲突性**的计算。

1.  **数据标准化**: 与标准方法相同。
2.  **对比强度 (Variability)**: 与标准方法相同，使用标准差衡量。
3.  **冲突性 (Conflict) - 改良方法**: 标准方法使用 `sum(1 - r)` 计算冲突性，而该改良方法使用 **`1 - average r`** 来衡量。它首先计算每个指标与其他所有指标的**平均相关系数**，然后用1减去该平均值。这种方法可以更平滑地反映指标的独立性，避免个别极端的低相关性值对结果产生过大影响。
4.  **信息承载量与权重计算**: 后续步骤与标准方法相同。

### 如何使用

`CRITIC_improved` 同样是一个函数，调用方式与标准方法完全相同。

**函数定义:**
```matlab
function [weights, scores, normalized_data] = CRITIC_improved(data, indicator_types)
```

**使用示例:**
```matlab
% 假设有 5 个样本和 4 个指标
data = rand(5, 4) * 100;
% 假设第1, 2, 4个是正向指标，第3个是负向指标
indicator_types = [1, 1, -1, 1];

% 调用函数
[w, s] = CRITIC_improved_Liruyu(data, indicator_types); % 注意文件名

% 显示结果
disp('改良CRITIC计算出的权重为:');
disp(w);
disp('各样本的得分为:');
disp(s);
```

## 依赖

-   Matlab
