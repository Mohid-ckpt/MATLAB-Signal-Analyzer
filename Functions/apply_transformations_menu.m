% --- Function: apply_transformations_menu.m ---
function apply_transformations_menu()
    global current_signal signal_fs signal_name;
    global complex_fft_data time_domain_fs_for_fft;

    while true
        disp(sprintf('\n--- Apply Transformations ---'));

        % Define state flags based on global variables
        % A signal is time-domain active if current_signal exists AND
        % (EITHER complex_fft_data is empty OR time_domain_fs_for_fft is specifically NaN,
        % indicating FFT result is not the primary focus or not present)
        is_time_domain_active = ~isempty(current_signal) && ...
                                (isempty(complex_fft_data) || (isscalar(time_domain_fs_for_fft) && isnan(time_domain_fs_for_fft)));

        % FFT data is active if complex_fft_data exists AND time_domain_fs_for_fft is a valid number (not NaN)
        is_fft_domain_active = ~isempty(complex_fft_data) && ...
                               (isscalar(time_domain_fs_for_fft) && ~isnan(time_domain_fs_for_fft));


        if is_time_domain_active
            disp(sprintf('Operating on Time-Domain Signal: %s (Fs: %.2f Hz)', signal_name, signal_fs));
        elseif is_fft_domain_active
            disp(sprintf('Operating on Complex FFT Data of: %s (Original Fs: %.2f Hz)', signal_name, time_domain_fs_for_fft));
            disp('Note: Most transformations below apply to time-domain signals.');
        else
            disp('No active signal or FFT data to transform. Load/generate a signal first.');
            % Option: could return here or break loop if you want to force user back
            % break; 
        end
        disp('-----------------------------');
        disp('1. Normalize Signal (Time-Domain)');
        disp('2. Resample Signal (Time-Domain)');
        disp('3. Differentiate Signal (Time-Domain)');
        disp('4. Integrate Signal (Time-Domain)');
        disp('5. Compute Analytic Signal (Hilbert - Time-Domain)');
        disp('6. Apply Full FFT (Time-Domain -> Freq-Domain)');
        disp('7. Apply Inverse FFT (Freq-Domain -> Time-Domain)');
        disp('0. Back to Main Menu');
        disp('-----------------------------');

        transform_choice = input('Select transformation: ');
        if isnan(transform_choice)
            disp('Invalid input. Please enter a number.');
            continue;
        end

        % --- CORRECTED PRE-CHECKS USING THE FLAGS ---
        needs_time_domain = ismember(transform_choice, [1, 2, 3, 4, 5, 6]);
        needs_fft_domain = ismember(transform_choice, [7]);

        if needs_time_domain && ~is_time_domain_active
            disp('Error: This transformation requires an active time-domain signal.');
            if is_fft_domain_active
                disp('Suggestion: Use option 7 (Inverse FFT) first to convert FFT data back to time-domain.');
            else
                disp('Suggestion: Load or generate a signal from the main menu.');
            end
            continue; 
        end

        if needs_fft_domain && ~is_fft_domain_active
            disp('Error: This transformation requires complex FFT data.');
            if is_time_domain_active
                disp('Suggestion: Use option 6 (Apply Full FFT) on the current time-domain signal first.');
            else
                disp('Suggestion: Load/generate a signal and then apply FFT from the main menu.');
            end
            continue;
        end
        
        % Additional check for operations that specifically need current_signal to be non-empty
        % (This is a bit redundant if is_time_domain_active is true, but acts as a safeguard)
        if needs_time_domain && isempty(current_signal)
            disp('Error: Time-domain signal data (`current_signal`) is unexpectedly empty.');
            disp('Please load or generate a signal.');
            continue;
        end


        switch transform_choice
            case 1
                normalize_signal_cli();
            case 2
                resample_signal_cli();
            case 3
                differentiate_signal_cli();
            case 4
                integrate_signal_cli();
            case 5
                analytic_signal_cli();
            case 6
                apply_fft_cli();
            case 7
                apply_ifft_cli();
            case 0
                disp('Returning to main menu.');
                break;
            otherwise
                disp('Invalid transformation choice.');
        end
    end
end

% --- Transformation Functions ---

function normalize_signal_cli()
    global current_signal signal_fs signal_name; % signal_fs needed for plotting

    disp('--- Normalize Signal ---');
    disp('1. Min-Max to [0, 1]');
    disp('2. Min-Max to [-1, 1]');
    disp('3. Z-score (Standardize)');
    norm_choice = input('Select normalization type: ');

    if isempty(current_signal) % Should be caught by pre-check, but good to have
        disp('No signal to normalize.'); return;
    end

    original_min = min(current_signal);
    original_max = max(current_signal);
    original_mean = mean(current_signal);
    original_std = std(current_signal);
    prev_name = signal_name; % Store previous name part

    switch norm_choice
        case 1
            if (original_max - original_min) < eps % Handle constant signal using a small tolerance
                current_signal = zeros(size(current_signal));
                disp('Signal is constant or near-constant. Normalized to 0.');
            else
                current_signal = (current_signal - original_min) / (original_max - original_min);
                disp('Signal normalized to [0, 1].');
            end
            signal_name = [prev_name '_norm01'];
        case 2
            if (original_max - original_min) < eps
                 current_signal = zeros(size(current_signal));
                 disp('Signal is constant or near-constant. Normalized to 0.');
            else
                current_signal = 2 * ((current_signal - original_min) / (original_max - original_min)) - 1;
                disp('Signal normalized to [-1, 1].');
            end
            signal_name = [prev_name '_normN1P1'];
        case 3
            if original_std < eps
                current_signal = zeros(size(current_signal));
                disp('Signal has zero or near-zero standard deviation. Normalized to 0.');
            else
                current_signal = (current_signal - original_mean) / original_std;
                disp('Signal Z-score normalized (target mean~0, target std~1).');
            end
            signal_name = [prev_name '_zscore'];
        otherwise
            disp('Invalid choice. Normalization cancelled.');
            return;
    end

    disp(sprintf('New signal range: [%.4f, %.4f]', min(current_signal), max(current_signal)));
    disp(sprintf('New mean: %.4f, New std: %.4f', mean(current_signal), std(current_signal)));
    prompt_plot_transformed_signal('Normalized Signal');
end

function resample_signal_cli()
    global current_signal signal_fs signal_name;

    disp('--- Resample Signal ---');
    current_fs = signal_fs;
    target_fs = input(sprintf('Current Fs is %.2f Hz. Enter target Fs: ', current_fs));

    if isempty(target_fs) || ~isnumeric(target_fs) || target_fs <= 0
        disp('Invalid target Fs. Resampling cancelled.');
        return;
    end

    if target_fs == current_fs
        disp('Target Fs is same as current Fs. No resampling needed.');
        return;
    end

    % resample uses a rational factor P/Q. Find P and Q.
    [P, Q] = rat(target_fs / current_fs);
    disp(sprintf('Resampling from %.2f Hz to %.2f Hz (P=%d, Q=%d)', current_fs, target_fs, P, Q));

    try
        current_signal = resample(current_signal, P, Q);
        signal_fs = target_fs; % Update global Fs
        signal_name = [signal_name '_resamp' num2str(round(target_fs)) 'Hz'];
        disp('Signal resampled successfully.');
        disp(sprintf('New signal length: %d, New Fs: %.2f Hz', length(current_signal), signal_fs));
        prompt_plot_transformed_signal('Resampled Signal');
    catch ME
        disp(['Error during resampling: ' ME.message]);
    end
end

function differentiate_signal_cli()
    global current_signal signal_fs signal_name;

    disp('--- Differentiate Signal (Approximate First Derivative) ---');
    if length(current_signal) < 2
        disp('Signal too short to differentiate.');
        return;
    end

    % Simple finite difference: diff(y) / diff(t). Here diff(t) = 1/Fs
    current_signal = diff(current_signal) * signal_fs; % Scaled by Fs to approximate dy/dt
    % The time vector is now shorter by 1. For plotting, we can either
    % adjust the time vector or pad the signal. Let's pad for simplicity.
    current_signal = [current_signal(1); current_signal]; % Pad at the beginning (or end)
    % Alternatively, adjust time vector in plotting function if it's aware of this.

    signal_name = [signal_name '_diff'];
    disp('Signal differentiated. Length may have changed or padded.');
    prompt_plot_transformed_signal('Differentiated Signal');
end

function integrate_signal_cli()
    global current_signal signal_fs signal_name;

    disp('--- Integrate Signal (Cumulative Sum Approximation) ---');
    % Approximate integral using cumulative sum, scaled by dt (1/Fs)
    current_signal = cumsum(current_signal) / signal_fs;
    signal_name = [signal_name '_integ'];
    disp('Signal integrated.');
    prompt_plot_transformed_signal('Integrated Signal');
end

function analytic_signal_cli()
    global current_signal signal_fs signal_name;

    disp('--- Compute Analytic Signal (via Hilbert Transform) ---');
    analytic_sig = hilbert(current_signal);

    disp('Analytic signal computed (complex).');
    disp('What do you want to do with it?');
    disp('1. Show Envelope (Magnitude)');
    disp('2. Show Instantaneous Phase (Unwrapped)');
    disp('3. Show Instantaneous Frequency (Approximate)');
    disp('4. Overwrite current signal with Envelope (Real)');
    disp('5. Cancel');
    choice = input('Choose action: ');

    switch choice
        case 1
            env_sig = abs(analytic_sig);
            figure; t_vec = (0:length(env_sig)-1)'/signal_fs;
            plot(t_vec, current_signal, 'b-', t_vec, env_sig, 'r--', 'LineWidth',1.5);
            legend('Original Signal', 'Envelope'); title(['Envelope of ' strrep(signal_name, '_', ' ')]);
            xlabel('Time (s)'); ylabel('Amplitude'); grid on; axis tight;
            disp('Plotting envelope.');
        case 2
            inst_phase = unwrap(angle(analytic_sig));
            figure; t_vec = (0:length(inst_phase)-1)'/signal_fs;
            plot(t_vec, inst_phase);
            title(['Instantaneous Phase of ' strrep(signal_name, '_', ' ')]);
            xlabel('Time (s)'); ylabel('Phase (radians)'); grid on; axis tight;
            disp('Plotting instantaneous phase.');
        case 3
            % Approximate instantaneous frequency
            inst_phase = unwrap(angle(analytic_sig));
            inst_freq = diff(inst_phase) * signal_fs / (2*pi);
            % Pad to match original length for plotting ease
            inst_freq = [inst_freq(1); inst_freq];
            figure; t_vec = (0:length(inst_freq)-1)'/signal_fs;
            plot(t_vec, inst_freq);
            title(['Approx. Instantaneous Frequency of ' strrep(signal_name, '_', ' ')]);
            xlabel('Time (s)'); ylabel('Frequency (Hz)'); grid on; axis tight;
            disp('Plotting instantaneous frequency.');
        case 4
            current_signal = abs(analytic_sig);
            signal_name = [signal_name '_envelope'];
            disp('Current signal replaced with its envelope.');
            prompt_plot_transformed_signal('Signal Envelope');
        case 5
            disp('Analytic signal computation cancelled.');
        otherwise
            disp('Invalid choice.');
    end
end

function apply_fft_cli()
    global current_signal signal_fs signal_name;
    global complex_fft_data time_domain_fs_for_fft;

    disp('--- Apply Full FFT ---');
    complex_fft_data = fft(current_signal);
    time_domain_fs_for_fft = signal_fs; % Store the Fs of the original time-domain signal

    % Clear current_signal and signal_fs to indicate we are now in freq domain primarily
    % current_signal = []; % This makes other time-domain operations fail cleanly
    % signal_fs = NaN;     % This is one way to manage state.
                         % Or, keep current_signal as is, and rely on time_domain_fs_for_fft
                         % to know that complex_fft_data is active. Let's try the latter.

    signal_name_orig = signal_name; % Keep original name for IFFT reference
    % signal_name = [signal_name_orig '_FFT']; % Don't change signal_name for now, it refers to original

    N_fft = length(complex_fft_data);
    f_vec = time_domain_fs_for_fft * (0:(N_fft/2))/N_fft; % Freq vector for single-sided plot

    disp(sprintf('FFT computed for "%s". Result stored internally.', signal_name_orig));
    disp('You can now use "Apply Inverse FFT" or plot parts of it.');

    plot_choice = input('Plot magnitude and phase of FFT? (y/n) [y]: ', 's');
    if isempty(plot_choice) || lower(plot_choice) == 'y'
        P2 = abs(complex_fft_data / N_fft);
        P1 = P2(1:N_fft/2+1);
        P1(2:end-1) = 2*P1(2:end-1);

        Ang_fft = angle(complex_fft_data); % Phase
        Ang_fft_single = Ang_fft(1:N_fft/2+1);

        figure;
        subplot(2,1,1);
        plot(f_vec, P1);
        title(['Magnitude Spectrum of ' strrep(signal_name_orig, '_', ' ')]);
        xlabel('Frequency (Hz)'); ylabel('|Y(f)|'); grid on; axis tight;
        subplot(2,1,2);
        plot(f_vec, rad2deg(unwrap(Ang_fft_single))); % Unwrap and convert to degrees
        title(['Phase Spectrum of ' strrep(signal_name_orig, '_', ' ')]);
        xlabel('Frequency (Hz)'); ylabel('Phase (degrees)'); grid on; axis tight;
    end
end

function apply_ifft_cli()
    global current_signal signal_fs signal_name;
    global complex_fft_data time_domain_fs_for_fft;

    disp('--- Apply Inverse FFT ---');
    % 'symmetric' flag assumes FFT was of a real signal, ensures IFFT result is real
    reconstructed_signal = ifft(complex_fft_data, 'symmetric');

    current_signal = reconstructed_signal;
    signal_fs = time_domain_fs_for_fft; % Restore original Fs

    disp(sprintf('IFFT applied. Signal "%s" reconstructed in time domain.', signal_name));
    disp(sprintf('Fs restored to: %.2f Hz', signal_fs));

    % Clear the FFT specific data as we are back in time domain
    complex_fft_data = [];
    time_domain_fs_for_fft = NaN;

    prompt_plot_transformed_signal('IFFT Reconstructed Signal');
end

% --- Utility function for plotting transformed signal ---
function prompt_plot_transformed_signal(transform_type_name)
    global current_signal signal_fs signal_name;
    plot_choice = input(sprintf('Plot %s? (y/n) [y]: ', lower(transform_type_name)), 's');
    if isempty(plot_choice) || lower(plot_choice) == 'y'
        if ~isempty(current_signal) && ~isnan(signal_fs)
            figure;
            t_vec = (0:length(current_signal)-1)' / signal_fs;
            plot(t_vec, current_signal);
            title([transform_type_name ': ' strrep(signal_name, '_', ' ')]);
            xlabel('Time (s)'); ylabel('Amplitude');
            grid on; axis tight;
            disp(['Plotting ' lower(transform_type_name) '...']);
        elseif ~isempty(current_signal) && isnan(signal_fs) % Fs might be lost or irrelevant for some ops
             figure;
            plot(current_signal);
            title([transform_type_name ': ' strrep(signal_name, '_', ' ') ' (Fs unknown/not applicable)']);
            xlabel('Sample Number'); ylabel('Amplitude');
            grid on; axis tight;
            disp(['Plotting ' lower(transform_type_name) '... (Fs not used for x-axis)']);
        else
            disp('Cannot plot: Signal data or Fs missing.');
        end
    end
end