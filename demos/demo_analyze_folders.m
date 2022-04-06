function demo_analyze_folders
% Function analyzes test data

% Variables
data_top_dir = '../test_data';
output_top_dir = '../test_data/temp_output';
no_of_nested_levels = 1;

% Code

% Make sure the analysis code is on the path
addpath(genpath('../code'));

analyze_folders('data_top_dir', data_top_dir, ...
                'output_top_dir', output_top_dir, ...
                'no_of_nested_levels', no_of_nested_levels);
