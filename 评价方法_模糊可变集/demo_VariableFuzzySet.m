% DEMO for VariableFuzzySet_func
% This script demonstrates how to use the VariableFuzzySet_func function
% for variable fuzzy set evaluation.

clear;
clc;
close all;

fprintf('--- Demo for Variable Fuzzy Set Evaluation ---\n\n');

% --- 1. Define Model Parameters ---
num_indicators = 4; % Number of evaluation indicators (e.g., 4)
num_samples = 10;   % Number of samples to be evaluated (e.g., 10)
num_grades = 5;     % Number of evaluation grades (e.g., 5, for I, II, III, IV, V)

fprintf('Model Parameters:\n');
fprintf('  Number of Indicators: %d\n', num_indicators);
fprintf('  Number of Samples: %d\n', num_samples);
fprintf('  Number of Grades: %d\n\n', num_grades);

% --- 2. Generate Sample Data (X) ---
% In a real application, this data would be your own.
% Here, we generate random data for demonstration purposes.
% X is a matrix of size [num_indicators x num_samples]
X = randi([1, 100], num_indicators, num_samples);
fprintf('Generated sample data matrix X (size %d x %d):\n', num_indicators, num_samples);
disp(X);

% --- 3. Define Indicator Weights (W) ---
% W is a matrix of size [num_samples x num_indicators]
% For simplicity, we assume equal weights for all indicators and samples.
% In a real scenario, you might use methods like AHP, EWM, etc., to determine weights.
W = repmat(1/num_indicators, num_samples, num_indicators);
fprintf('Indicator weight matrix W (size %d x %d):\n', num_samples, num_indicators);
disp(W);

% --- 4. Define Standard Grade Intervals (I) ---
% I is a 3D matrix of size [num_indicators x 5 x num_grades]
% The 5 columns represent the interval points [c, a, M, b, d] for each grade.
% M is the midpoint of the optimal range [a, b].
% [c, d] is the permissible range.
%
% For this demo, we define a simple, identical interval structure for all indicators.
% Grade I: [80, 90, 95, 100, 105]
% Grade II: [60, 70, 75, 80, 90]
% ... and so on.
I = zeros(num_indicators, 5, num_grades);

% Define grade intervals (example values)
grade_intervals = [
    90, 95, 100, 100, 100; % Grade V (Excellent)
    80, 85, 90, 90, 90;   % Grade IV (Good)
    70, 75, 80, 80, 80;   % Grade III (Medium)
    60, 65, 70, 70, 70;   % Grade II (Fair)
    0, 30, 60, 60, 60     % Grade I (Poor)
    ];

% For simplicity, let's assume these intervals are the same for all indicators.
% The structure is [c, a, M, b, d]
% Let's create a more standard structure
% Grade V (Excellent): [90, 90, 95, 100, 105]
% Grade IV (Good):     [80, 80, 85, 90, 95]
% Grade III (Medium):  [70, 70, 75, 80, 85]
% Grade II (Fair):     [60, 60, 65, 70, 75]
% Grade I (Poor):      [0, 0, 30, 60, 65]

% Let's define the intervals for each grade
I_grade_5 = [90, 90, 95, 100, 105]; % Excellent
I_grade_4 = [80, 80, 85, 90, 95];   % Good
I_grade_3 = [70, 70, 75, 80, 85];   % Medium
I_grade_2 = [60, 60, 65, 70, 75];   % Fair
I_grade_1 = [0,  0,  30, 60, 65];   % Poor

% Assign to the main interval matrix I
for i = 1:num_indicators
    I(i, :, 5) = I_grade_5;
    I(i, :, 4) = I_grade_4;
    I(i, :, 3) = I_grade_3;
    I(i, :, 2) = I_grade_2;
    I(i, :, 1) = I_grade_1;
end

fprintf('Standard grade interval matrix I has been constructed (size %d x 5 x %d).\n\n', num_indicators, num_grades);

% --- 5. Run the Variable Fuzzy Set Evaluation Function ---
fprintf('Calling VariableFuzzySet_func...\n\n');
try
    results = VariableFuzzySet_func(X, W, I);
    
    % --- 6. Display the Results ---
    fprintf('Evaluation Results (H0 values):\n');
    fprintf('------------------------------------------------------------------\n');
    fprintf('Sample | H0 (a=1, p=1) | H0 (a=2, p=1) | H0 (a=1, p=2) | H0 (a=2, p=2)\n');
    fprintf('------------------------------------------------------------------\n');
    
    result_table = [
        (1:num_samples)', ...
        results.H0_a1_p1, ...
        results.H0_a2_p1, ...
        results.H0_a1_p2, ...
        results.H0_a2_p2
        ];
    
    fprintf('%6d | %13.4f | %13.4f | %13.4f | %13.4f\n', result_table');
    fprintf('------------------------------------------------------------------\n\n');
    
    % You can also access individual results like this:
    % fprintf('H0 for Sample 1 (alpha=1, p=1): %.4f\n', results.H0_a1_p1(1));
    
catch ME
    fprintf('An error occurred during evaluation:\n');
    fprintf('%s\n', ME.message);
end
