% --- Function: display_frequency_domain_cli.m (or in the same file) ---
function display_frequency_domain_cli()
    global current_signal signal_fs signal_name;

    global complex_fft_data;
    if ~isempty(complex_fft_data)
        disp('Current data is in frequency domain (FFT). This operation requires a time-domain signal.');
        disp('Suggestion: Apply Inverse FFT from the Transformations menu.');
        return;
    end
    
    N = length(current_signal);

    disp('--- Frequency-Domain Analysis ---');
    % Window selection
    disp('Select Window Function:');
    disp('1. Rectangular (None)');
    disp('2. Hann');
    disp('3. Hamming');
    disp('4. Blackman');
    win_choice = input('Enter window choice (default 2. Hann): ');
    if isempty(win_choice), win_choice = 2; end % Default to Hann

    win_len = N; % For basic FFT, use full signal length for window
    switch win_choice
        case 1
            window = rectwin(win_len);
            win_name = 'Rectangular';
        case 2
            window = hann(win_len);
            win_name = 'Hann';
        case 3
            window = hamming(win_len);
            win_name = 'Hamming';
        case 4
            window = blackman(win_len);
            win_name = 'Blackman';
        otherwise
            disp('Invalid window choice. Using Hann.');
            window = hann(win_len);
            win_name = 'Hann';
    end

    % Apply window
    windowed_signal = current_signal .* window;

    % FFT
    Y = fft(windowed_signal);
    P2 = abs(Y/N); % Two-sided spectrum
    P1 = P2(1:N/2+1); % Single-sided spectrum
    P1(2:end-1) = 2*P1(2:end-1); % Double everything except DC and Nyquist
    f_fft = signal_fs*(0:(N/2))/N; % Frequency vector for P1

    % Plot FFT Magnitude
    figure;
    subplot(2,1,1);
    plot(f_fft, P1);
    title(['Single-Sided Amplitude Spectrum of ' strrep(signal_name, '_', ' ') ' (Window: ' win_name ')']);
    xlabel('Frequency (Hz)');
    ylabel('|P1(f)|');
    grid on;
    axis tight;

    % Power Spectral Density (PSD) using Welch's method
    % You can prompt for segment length and overlap for Welch, or use defaults
    % For simplicity here, let's use default pwelch settings or some reasonable values.
    % segment_len = min(N, 256); % Example segment length for pwelch
    % overlap_percent = 50;
    % noverlap = floor(segment_len * overlap_percent / 100);
    % [pxx, f_psd] = pwelch(current_signal, window, noverlap, N, signal_fs);
    % Simpler for a start: use the same window as FFT for consistency, though pwelch often uses its own windowing internally or by segment.
    % For pwelch, the window argument is applied to each segment.
    % If you pass a window vector whose length is equal to the segment length (nfft),
    % pwelch uses that window. If you pass a scalar for window, pwelch uses a Hamming window of that length.
    % Here, we'll use the chosen window type with a default segment length if needed by pwelch.
    [pxx, f_psd] = pwelch(current_signal, [], [], [], signal_fs, 'psd'); % Let pwelch use defaults for window/overlap initially
                                                                         % Or be more specific:
    % nfft_welch = 2^nextpow2(N/8); % Example: 8 segments
    % window_welch = window_func(nfft_welch, win_name); % Helper to get chosen window of specific length
    % [pxx, f_psd] = pwelch(current_signal, window_welch, floor(nfft_welch/2), nfft_welch, signal_fs);

    subplot(2,1,2);
    plot(f_psd, 10*log10(pxx)); % Plot in dB
    title(['PSD using Welch''s Method (Window: ' win_name ' - applied per segment if not default)']);
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    grid on;
    axis tight;

    disp('Plotting FFT and PSD...');
end