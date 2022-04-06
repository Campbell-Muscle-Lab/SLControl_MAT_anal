function out = calculate_k_tr(params)
% Function calculates k_tr and returns trace properties

arguments
    params.slc_record = [];
    params.k_tr_restretch_delay_s = 0.01;
    params.k_tr_fit_s = 4;
    params.force_subplot = [];
    params.fl_subplot = [];
    params.fl_scaling_factor = 1e6;
    params.title_string = [];
    params.title_y_offset = 1.2;
    params.output_file_string = [];
    params.output_file_types = {'png'};
end

% Code
if (isempty(params.slc_record))
    disp('calculate_k_tr - no record');
    return
end

% Calculate k_tr restretch time
k_tr_restretch_s = params.slc_record.ktr_initiation_time + ...
                    params.slc_record.ktr_duration;
% If it's missing, look for max restretch speed                
if (~isfinite(k_tr_restretch_s))
    dfl = diff(params.slc_record.fl);
    [~, k_tr_restretch_ind] = max(dfl);
    k_tr_restretch_s = params.slc_record.time(k_tr_restretch_ind);
end

% Add on the padding for the transient
k_tr_start_s = k_tr_restretch_s + params.k_tr_restretch_delay_s;

% Duration to end of record
post_restretch_s = params.slc_record.time(end) - k_tr_start_s;

% Set fitting period
k_tr_end_s = k_tr_start_s + min([params.k_tr_fit_s post_restretch_s]);

% Deduce indices
fit_vi = find((params.slc_record.time >= k_tr_start_s) & ...
                (params.slc_record.time <= k_tr_end_s));

% Fit
[f_start, f_amp, k_tr, r_squared, f_fit] = fit_single_exponential( ...
    params.slc_record.time(fit_vi) - k_tr_start_s, ...
    params.slc_record.force(fit_vi));

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

display_vi = 1:numel(params.slc_record.time);

% Force plot
subplot(params.force_subplot);
hold on;
plot(params.slc_record.time(display_vi), ...
        params.slc_record.force(display_vi), 'b-');
plot(params.slc_record.time(fit_vi), f_fit, 'r-', 'LineWidth', 2);

% Update the title
title_string = sprintf('%s\npCa=%.2f k_tr = %.2f s^{-1}', ...
                params.title_string, ...
                params.slc_record.pCa, k_tr);

% Add length record
subplot(params.fl_subplot);
hold on;
plot(params.slc_record.time(display_vi), ...
        params.fl_scaling_factor * params.slc_record.fl(display_vi), 'b-');
            
% Tidy axes
if (~isempty(params.force_subplot));
    improve_axes( ...
        'axis_handle', params.force_subplot, ...
        'y_tick_decimal_places', 0, ...
        'y_axis_label', {'Force','(N m^{-2})'}, ...
        'x_axis_off', 1, ...
        'title', title_string, ...
        'title_y_offset', params.title_y_offset, ...
        'title_text_interpreter', 'none');
end

if (~isempty(params.fl_subplot))
    improve_axes( ...
        'axis_handle', params.fl_subplot, ...
        'y_tick_decimal_places', 0, ...
        'y_axis_label', {'Muscle','length','(sm)'}, ...
        'x_axis_label', 'Time (s)');
end

% Save figure
if (~isempty(params.output_file_string))
    for i = 1 : numel(params.output_file_types)
        figure_export('output_file_string', params.output_file_string, ...
            'output_type', params.output_file_types{i});
    end
end

% Save data for output
out.pCa = params.slc_record.pCa;
out.force = params.slc_record.force(1);
out.k_tr = k_tr;
out.k_tr_r_sq = r_squared;
