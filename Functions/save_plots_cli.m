% --- Function: save_plots_cli.m (or in the same file) ---
function save_plots_cli()
    fig_handles = findall(0, 'Type', 'figure'); % Get all open figure handles
    if isempty(fig_handles)
        disp('No plots are currently open to save.');
        return;
    end

    disp(['Found ' num2str(length(fig_handles)) ' open plot(s).']);
    save_dir = input('Enter directory to save plots (leave empty for current dir): ', 's');
    if isempty(save_dir)
        save_dir = pwd; % Current working directory
    elseif ~isfolder(save_dir)
        mkdir_choice = input(['Directory "' save_dir '" does not exist. Create it? (y/n): '], 's');
        if lower(mkdir_choice) == 'y'
            [status, msg] = mkdir(save_dir);
            if ~status
                disp(['Error creating directory: ' msg]);
                return;
            end
        else
            disp('Save cancelled.');
            return;
        end
    end

    for i = 1:length(fig_handles)
        fig = fig_handles(i);
        figure(fig); % Bring figure to front
        
        % Try to get a meaningful name from the title
        plot_title_obj = get(get(fig, 'CurrentAxes'), 'Title');
        if ~isempty(plot_title_obj) && isprop(plot_title_obj, 'String')
            plot_title = plot_title_obj.String;
            if iscell(plot_title) % Title can sometimes be a cell array
                plot_title = plot_title{1};
            end
            % Sanitize title for filename
            safe_filename = matlab.lang.makeValidName(plot_title);
            if isempty(safe_filename) || length(safe_filename) < 3 % if title is too short or invalid
                safe_filename = ['plot_' num2str(fig.Number)];
            end
        else
            safe_filename = ['plot_' num2str(fig.Number)];
        end
        
        default_filename = fullfile(save_dir, [safe_filename '.png']);
        
        save_filename = input(sprintf('Enter filename for plot %d (Figure %d: "%s") [default: %s]: ', ...
                                      i, fig.Number, safe_filename, default_filename), 's');
        if isempty(save_filename)
            save_filename = default_filename;
        else
            % Ensure it has an extension, default to .png
            [~,~,ext_chosen] = fileparts(save_filename);
            if isempty(ext_chosen)
                save_filename = [save_filename '.png'];
            end
            % If only filename is given, prepend save_dir
            if isempty(fileparts(save_filename))
                save_filename = fullfile(save_dir, save_filename);
            end
        end
        
        try
            saveas(fig, save_filename);
            disp(['Plot ' num2str(fig.Number) ' saved to "' save_filename '".']);
        catch ME
            disp(['Error saving plot ' num2str(fig.Number) ': ' ME.message]);
        end
    end
end