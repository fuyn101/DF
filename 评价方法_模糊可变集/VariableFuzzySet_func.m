function results = VariableFuzzySet_func(X, W, I)
% VariableFuzzySet_func: A function for variable fuzzy set evaluation method.
%
% Syntax:
%   results = VariableFuzzySet_func(X, W, I)
%
% Input:
%   X - Sample data matrix. Each column is a sample, and each row is an indicator.
%       (size: a x b, where 'a' is the number of indicators, 'b' is the number of samples)
%   W - Weight matrix. Each row corresponds to the weights for a sample.
%       (size: b x a, where 'b' is the number of samples, 'a' is the number of indicators)
%   I - Standard interval matrix for evaluation grades.
%       (size: a x 5 x k, where 'a' is the number of indicators,
%        5 corresponds to [c, a, M, b, d] for each grade,
%        'k' is the number of grades, typically 5)
%
% Output:
%   results - A struct containing the evaluation level characteristic values (H0)
%             for different model parameters (alpha 'a' and p).
%             - results.H0_a1_p1: H0 for alpha=1, p=1
%             - results.H0_a1_p2: H0 for alpha=1, p=2
%             - results.H0_a2_p1: H0 for alpha=2, p=1
%             - results.H0_a2_p2: H0 for alpha=2, p=2
%
% Example:
%   % See demo_VariableFuzzySet.m for a detailed example.
%
% Author: Cline
% Date: 2025/07/19

% --- Input Validation ---
[a, b] = size(X); % a: number of indicators, b: number of samples
[wb, wa] = size(W);
[Ia, I5, Ik] = size(I); % Ik: number of grades

if b ~= wb
    error('The number of samples in X (columns) must match the number of samples in W (rows).');
end
if a ~= wa || a ~= Ia
    error('The number of indicators in X, W, and I must be consistent.');
end
if I5 ~= 5
    error('The second dimension of the interval matrix I must be 5.');
end

% --- Step 1: Calculate Relative Membership Degree ---
D = zeros(a, Ik, b);
for i = 1:b           % Iterate through samples
    for j = 1:a       % Iterate through indicators
        x = X(j, i);
        for k = 1:Ik  % Iterate through grades
            interval = I(j, :, k);
            c = interval(1);
            a_val = interval(2);
            M = interval(3);
            b_val = interval(4);
            d = interval(5);
            
            if x >= c && x < a_val
                D(j, k, i) = -((x - a_val) / (c - a_val));
            elseif x >= a_val && x < M
                D(j, k, i) = (x - a_val) / (M - a_val);
            elseif x >= M && x < b_val
                D(j, k, i) = (x - b_val) / (M - b_val);
            elseif x >= b_val && x <= d
                D(j, k, i) = -((x - b_val) / (d - b_val));
            else
                D(j, k, i) = -1;
            end
        end
    end
end
u = (1 + D) / 2; % Relative membership degree uA

% --- Step 2: Calculate Comprehensive Evaluation Level ---
H0 = zeros(b, 4);

% Case 1: alpha=1, p=1
for i = 1:b
    u_sample = squeeze(u(:, :, i));
    w_sample = W(i, :);
    numerator = w_sample * (1 - u_sample);
    denominator = w_sample * u_sample;
    % Avoid division by zero
    denominator(denominator == 0) = 1e-9;
    u1 = 1 ./ (1 + (numerator ./ denominator));
    h1 = sum(u1);
    H1 = (u1 .* (1:Ik)) / h1;
    H0(i, 1) = sum(H1);
end

% Case 2: alpha=2, p=1
for i = 1:b
    u_sample = squeeze(u(:, :, i));
    w_sample = W(i, :);
    numerator = w_sample * (1 - u_sample);
    denominator = w_sample * u_sample;
    denominator(denominator == 0) = 1e-9;
    u2 = 1 ./ (1 + (numerator ./ denominator).^2);
    h2 = sum(u2);
    H2 = (u2 .* (1:Ik)) / h2;
    H0(i, 2) = sum(H2);
end

% Case 3: alpha=1, p=2
for i = 1:b
    u_sample = squeeze(u(:, :, i));
    W0 = diag(W(i, :));
    u3_num = sum((W0 * (1 - u_sample)).^2);
    u3_den = sum((W0 * u_sample).^2);
    u3_den(u3_den == 0) = 1e-9;
    u3 = 1 ./ (1 + sqrt(u3_num ./ u3_den));
    h3 = sum(u3);
    H3 = (u3 .* (1:Ik)) / h3;
    H0(i, 3) = sum(H3);
end

% Case 4: alpha=2, p=2
for i = 1:b
    u_sample = squeeze(u(:, :, i));
    W0 = diag(W(i, :));
    u4_num = sum((W0 * (1 - u_sample)).^2);
    u4_den = sum((W0 * u_sample).^2);
    u4_den(u4_den == 0) = 1e-9;
    u4 = 1 ./ (1 + (u4_num ./ u4_den));
    h4 = sum(u4);
    H4 = (u4 .* (1:Ik)) / h4;
    H0(i, 4) = sum(H4);
end

% --- Step 3: Format Output ---
results.H0_a1_p1 = H0(:, 1);
results.H0_a2_p1 = H0(:, 2);
results.H0_a1_p2 = H0(:, 3);
results.H0_a2_p2 = H0(:, 4);

fprintf('Variable Fuzzy Set Evaluation Completed.\n');
disp('Results struct contains H0 values for different alpha and p parameters.');

end
