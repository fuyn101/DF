function len = line_intersects_grid(p1, p2, bbox)
%LINE_INTERSECTS_GRID 计算线段与矩形边界框的相交长度
%
%   len = LINE_INTERSECTS_GRID(p1, p2, bbox) 计算由点p1和p2定义的线段
%   与由bbox定义的矩形相交部分的长度。
%
%   输入:
%       p1   - 线段的起始点 [x1, y1]
%       p2   - 线段的结束点 [x2, y2]
%       bbox - 矩形边界框 [xmin, ymin, xmax, ymax]
%
%   输出:
%       len  - 线段在矩形内部的长度。如果没有交集，则为0。
%
%   算法:
%       使用Liang-Barsky线段裁剪算法。

x1 = p1(1); y1 = p1(2);
x2 = p2(1); y2 = p2(2);
xmin = bbox(1); ymin = bbox(2);
xmax = bbox(3); ymax = bbox(4);

dx = x2 - x1;
dy = y2 - y1;

p = [-dx, dx, -dy, dy];
q = [x1 - xmin, xmax - x1, y1 - ymin, ymax - y1];

t0 = 0.0;
t1 = 1.0;

for i = 1:4
    if p(i) == 0
        if q(i) < 0
            len = 0;
            return;
        end
    else
        r = q(i) / p(i);
        if p(i) < 0
            t0 = max(t0, r);
        else % p(i) > 0
            t1 = min(t1, r);
        end
    end
    
    if t0 > t1
        len = 0;
        return;
    end
end

% 如果有交集，计算交集线段的长度
clip_x1 = x1 + t0 * dx;
clip_y1 = y1 + t0 * dy;
clip_x2 = x1 + t1 * dx;
clip_y2 = y1 + t1 * dy;

len = sqrt((clip_x2 - clip_x1)^2 + (clip_y2 - clip_y1)^2);
end
