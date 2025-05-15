% --- Main Script: signal_analyzer_cli.m ---

% Global variables to store the current signal and its properties
global current_signal signal_fs signal_name;
current_signal = [];
signal_fs = NaN;
signal_name = 'Untitled';

% Main loop
while true
    disp(sprintf('\n--- Signal Analyzer CLI ---'));
    if ~isempty(current_signal)
        disp(sprintf('Current Signal: %s (Length: %d, Fs: %.2f Hz)', signal_name, length(current_signal), signal_fs));
    else
        disp('No signal loaded/generated yet.');
    end
    disp('---------------------------');
    disp('1. Load Signal from File');
    disp('2. Generate Signal');
    disp('3. Display Time-Domain Info & Plot');
    disp('4. Display Frequency-Domain Info & Plot (FFT & PSD)');
    disp('5. Display Spectrogram');
    disp('6. Save Current Plots (if any open)');
    disp('7. Clear All Open Figures');
    disp('8. Apply Transformations');
    disp('0. Exit');
    disp('---------------------------');

    choice = input('Enter your choice: ');

    switch choice
        case 1
            load_signal_cli();
        case 2
            generate_signal_cli();
        case 3
            if check_signal_loaded_time_domain()
                display_time_domain_cli();
            end
        case 4
            if check_signal_loaded_time_domain()
                display_frequency_domain_cli();
            end
        case 5
            if check_signal_loaded_time_domain()
                display_spectrogram_cli();
            end
        case 6
            save_plots_cli();
        case 7
            clear_all_figures_cli();
        case 8
            apply_transformations_menu();
        case 0
            disp('Exiting Signal Analyzer CLI.');
            break;
        otherwise
            disp('Invalid choice. Please try again.');
    end
end

% --- Helper Functions ---
function loaded = check_signal_loaded_time_domain() % Modified to check for time-domain signal
    global current_signal complex_fft_data;
    if isempty(current_signal) && isempty(complex_fft_data)
        disp('Error: No signal loaded or generated. Please use option 1 or 2 first.');
        loaded = false;
    elseif ~isempty(complex_fft_data) && isempty(current_signal)
        disp('Error: Current data is in Frequency Domain (FFT). Please apply IFFT or load/generate a new time-domain signal for this operation.');
        loaded = false;
    elseif isempty(current_signal) % Should not happen if logic is correct, but good check
        disp('Error: No time-domain signal available.');
        loaded = false;
    else
        loaded = true;
    end
end