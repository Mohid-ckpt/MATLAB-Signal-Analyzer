% --- Function: clear_all_figures_cli.m (or add to your main script) ---
function clear_all_figures_cli()
    fig_handles = findall(0, 'Type', 'figure'); % Get all open figure handles
    num_figs = length(fig_handles);

    if num_figs == 0
        disp('No figures are currently open to clear.');
    else
        confirm_clear = input(sprintf('Found %d open figure(s). Are you sure you want to close all of them? (y/n): ', num_figs), 's');
        if lower(confirm_clear) == 'y'
            close all; % MATLAB command to close all figure windows
            disp([num2str(num_figs) ' figure(s) closed.']);
        else
            disp('Clear figures cancelled.');
        end
    end
end