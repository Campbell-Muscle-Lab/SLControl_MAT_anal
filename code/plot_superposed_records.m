function plot_superposed_records(params)
% Function plots superposed records

arguments
    params.slc_file_strings = [];
    params.force_subplot = [];
    params.fl_subplot = [];
    params.force_scaling_factor = 0.001;
    params.force_label = {'Stress','(kN m^{-2})'};
    params.fl_scaling_factor = 1e6;
    params.fl_label = {'Muscle','length','(µm)'};
    params.title = [];
    params.title_y_offset = 1.15;
    params.output_file_string = [];
    params.output_file_types = {'png'};
end

% Code

if (isempty(params.slc_file_strings))
    disp('plot_superposed_records - no slc files');
    return
end

% If no subplots are specified, make a default figure
if (isempty(params.force_subplot) & isempty(params.fl_subplot))
    sp = initialise_publication_quality_figure( ...
            'no_of_panels_wide', 1, ...
            'no_of_panels_high', 2, ...
            'axes_padding_left', 1.5, ...
            'axes_padding_right', 1.5, ...
            'axes_padding_top', 0.2, ...
            'axes_padding_bottom', 0.2, ...
            'x_to_y_axes_ratio', 2, ...
            'right_margin', 1, ...
            'top_margin', 0.5, ...
            'bottom_margin', 0.3, ...
            'relative_row_heights', [1 0.5], ...
            'panel_label_font_size', 0);
    params.force_subplot = sp(1);
    params.fl_subplot = sp(2);
end

% Make figure
fig_out = display_slcontrol_records( ...
            'record_file_strings', params.slc_file_strings, ...
            'force_subplot', params.force_subplot, ...
            'fl_subplot', params.fl_subplot, ...
            'force_scale_factor', params.force_scaling_factor, ...
            'normalize_fl', 0, ...
            'fl_scale_factor', params.fl_scaling_factor);
        
% Tidy axes
if (~isempty(params.force_subplot));
    improve_axes( ...
        'axis_handle', params.force_subplot, ...
        'y_ticks', [0 fig_out.max_force], ...
        'y_tick_decimal_places', 0, ...
        'y_axis_label', params.force_label, ...
        'x_ticks', [fig_out.min_time_s fig_out.max_time_s], ...
        'x_axis_off', 1, ...
        'title', params.title, ...
        'title_y_offset', params.title_y_offset, ...
        'title_text_interpreter', 'none');
end

if (~isempty(params.fl_subplot))
    improve_axes( ...
        'axis_handle', params.fl_subplot, ...
        'y_ticks', [fig_out.min_fl fig_out.max_fl], ...
        'y_tick_decimal_places', 0, ...
        'y_axis_label', params.fl_label, ...
        'x_ticks', [fig_out.min_time_s fig_out.max_time_s], ...
        'x_axis_label', 'Time (s)');
end

% Save figure
if (~isempty(params.output_file_string))
    for i = 1 : numel(params.output_file_types)
        figure_export('output_file_string', params.output_file_string, ...
            'output_type', params.output_file_types{i});
    end
end


