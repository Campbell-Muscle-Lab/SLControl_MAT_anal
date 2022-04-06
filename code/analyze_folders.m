function analyze_folders(params)
% Function analyzes SLControl files arranged in a nested structure
% Default is to store summary data in Excel and working images in
% output_top_dir

arguments
    params.data_top_dir = [];
    params.output_top_dir = [];
    params.no_of_nested_levels = 2;
end

% Code

% Find the folders within the data_dir that contain SLControl files
slc_folders = folders_within_containing(params.data_top_dir, 'slc')';

% Loop through the slc folders
for folder_counter = 1 : numel(slc_folders)
    
    % Find the slc files in the folder
    slc_file_strings = findfiles('slc', slc_folders{folder_counter}, 0);
    
    % Create an output directory structure that is nested_levels deep
    dir_path = fileparts(GetFullPath(slc_file_strings{1}));
    folders = strsplit(dir_path, filesep);
    output_dir = params.output_top_dir;
    title_folder = '';
    for i = 1 : (params.no_of_nested_levels+1)
        output_dir = fullfile(output_dir, ...
            folders{end-1-params.no_of_nested_levels+i});
        title_folder = fullfile(title_folder, ...
            folders{end-1-params.no_of_nested_levels+i});
    end
    % Make sure the directory exists
    mkdir(output_dir);

    % Now create an output file for the superposed records
    fig_superposed_file_string = fullfile(output_dir, 'superposed');
    
    % Plot the records as a summary figure
    plot_superposed_records( ...
        'slc_file_strings', slc_file_strings, ...
        'output_file_string', fig_superposed_file_string, ...
        'title', title_folder);
    
    % pCa analysis - calculates 4 parameter fit for force-pCa data
    
    % Cycle through the files, pulling off force and pCa
    pd = [];
    for file_counter = 1 : numel(slc_file_strings)
        td = transform_slcontrol_record(load_slcontrol_file( ...
                slc_file_strings{file_counter}));
        pd.pCa(file_counter) = td.pCa;
        pd.y(file_counter) = td.force(end);
        pd.y_error(file_counter) = 0;
    end
    
    % Fit the force-pCa data
    [fd.pCa_50(folder_counter), fd.n_H(folder_counter), ...
        fd.f_min(folder_counter), fd.f_amp(folder_counter), ...
        fd.pCa_r_sq(folder_counter), ...
        pd.x_fit, pd.y_fit] = ...
            fit_Hill_curve(pd.pCa, pd.y);
    % Calculate the f_max
    fd.f_max(folder_counter) = fd.f_min(folder_counter) + ...
        fd.f_amp(folder_counter);
 
    % Now plot the pCa data and save to an appropriate place
    sp = initialise_publication_quality_figure( ...
            'no_of_panels_wide', 1, ...
            'no_of_panels_high', 1, ...
            'axes_padding_left', 1, ...
            'axes_padding_right', 0.5, ...
            'top_margin', 0.5, ...
            'bottom_margin', 0, ...
            'panel_label_font_size', 0);

    fig_pCa_file_string = fullfile(output_dir, 'pCa');
    
    title_string = sprintf('%s\npCa_{50}: %.2f  n_H: %.2f\nr^2: %.2f', ...
                        title_folder, ...
                        fd.pCa_50(folder_counter), ...
                        fd.n_H(folder_counter), ...
                        fd.pCa_r_sq(folder_counter));
        
    plot_pCa_data_with_y_errors( ...
        pd, ...
        'y_label_offset', -0.3, ...
        'title', title_string, ...
        'title_text_interpreter', 'none', ...
        'title_y_offset', 1.1, ...
        'title_font_size', 10, ...
        'output_file_string', fig_pCa_file_string);

    % Trace analysis - this stores force and k_tr values for
    % each record

    % Cycle through the files
    for file_counter = 1 : numel(slc_file_strings)
        td = transform_slcontrol_record(load_slcontrol_file( ...
                slc_file_strings{file_counter}));
            
        % Set output file name
        [dir_path,file_name] = fileparts(slc_file_strings{file_counter});
        fig_ktr_file_string = fullfile(output_dir, ...
            sprintf('%s_%s', 'k_tr', file_name));
            
        k_tr_out = calculate_k_tr('slc_record', td, ...
                        'title_string', ...
                            fullfile(title_folder, file_name), ...
                        'output_file_string', fig_ktr_file_string);
        
        % Add to trace_data structure, initialising if required
        if (~exist('trace_data'))
            trace_counter = 1;
        end
        trace_data.data_folder{trace_counter} = dir_path;
        for i = 1: params.no_of_nested_levels
            field_name = sprintf('factor_%i');
            trace_data.(field_name){trace_counter} = ...
                folders{end-params.no_of_nested_levels-1+i};
        end
        trace_data.prep{trace_counter} = folders{end};
        trace_data.file_name{trace_counter} = file_name;
        trace_data.pCa(trace_counter) = k_tr_out.pCa;
        trace_data.force(trace_counter) = k_tr_out.force;
        trace_data.k_tr(trace_counter) = k_tr_out.k_tr;
        trace_data.k_tr_r_sq(trace_counter) = k_tr_out.k_tr_r_sq;
        
        trace_counter = trace_counter + 1;
    end
    
    % Add in additional fields for the folder data
    fd.folder{folder_counter} = dir_path;
    for i = 1 : params.no_of_nested_levels
        field_name = sprintf('factor_%i',i);
        fd.(field_name){folder_counter} = ...
            folders{end-params.no_of_nested_levels-1+i};
    end
    fd.prep{folder_counter} = folders{end};
    % Need to open up a file to get dimensions
    d = load_slcontrol_file(slc_file_strings{1});
    fd.muscle_length(folder_counter) = d.muscle_length;
    fd.sarcomere_length(folder_counter) = d.sarcomere_length;
    fd.area(folder_counter) = d.area;
end

% Columnize and output
fd = columnize_structure(fd);
fd = struct2table(fd);

% Create the file name
output_file_string = fullfile(params.output_top_dir, 'analysis.xlsx');
try
    delete(output_file_string);
end
writetable(fd, output_file_string, 'Sheet', 'prep_data');

% Add in the trace data
trace_data = columnize_structure(trace_data);
trace_data = struct2table(trace_data);
writetable(trace_data, output_file_string, 'Sheet', 'trace_data');