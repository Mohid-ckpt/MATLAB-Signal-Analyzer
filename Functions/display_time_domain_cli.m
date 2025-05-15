% --- Function: display_time_domain_cli.m (or in the same file) ---
function display_time_domain_cli()
    global current_signal signal_fs signal_name;

    N = length(current_signal);
    t = (0:N-1)' / signal_fs;

    global complex_fft_data;
    if ~isempty(complex_fft_data)
        disp('Current data is in frequency domain (FFT). This operation requires a time-domain signal.');
        disp('Suggestion: Apply Inverse FFT from the Transformations menu.');
        return;
    end

    disp('--- Time-Domain Analysis ---');
    disp(['Signal: ' signal_name]);
    disp(['Sampling Frequency (Fs): ' num2str(signal_fs) ' Hz']);
    disp(['Number of Samples: ' num2str(N)]);
    disp(['Duration: ' num2str(N/signal_fs) ' seconds']);

    % Calculate statistics
    sig_mean = mean(current_signal);
    sig_rms = rms(current_signal);
    sig_peak = max(abs(current_signal));
    sig_p2p = max(current_signal) - min(current_signal);
    sig_var = var(current_signal);
    sig_std = std(current_signal);

    disp('Statistics:');
    disp(['  Mean: ' num2str(sig_mean)]);
    disp(['  RMS: ' num2str(sig_rms)]);
    disp(['  Peak Absolute Value: ' num2str(sig_peak)]);
    disp(['  Peak-to-Peak: ' num2str(sig_p2p)]);
    disp(['  Variance: ' num2str(sig_var)]);
    disp(['  Standard Deviation: ' num2str(sig_std)]);

    % Plot waveform
    figure; % Create a new figure window
    plot(t, current_signal);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(['Time Domain: ' strrep(signal_name, '_', ' ')]); % Replace underscores for better title
    grid on;
    axis tight;
    disp('Plotting time-domain waveform...');
end