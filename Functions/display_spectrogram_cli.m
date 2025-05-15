% --- Function: display_spectrogram_cli.m (or in the same file) ---
function display_spectrogram_cli()
    global current_signal signal_fs signal_name;

    global complex_fft_data;
    if ~isempty(complex_fft_data)
        disp('Current data is in frequency domain (FFT). This operation requires a time-domain signal.');
        disp('Suggestion: Apply Inverse FFT from the Transformations menu.');
        return;
    end
    
    disp('--- Spectrogram Display ---');

    % Sensible defaults or prompt the user
    default_win_len_ms = 30; % ms
    default_overlap_percent = 50;

    win_len_samples = input(sprintf('Enter window length in samples (e.g., %.0f for %d ms, default): ', round(default_win_len_ms/1000*signal_fs), default_win_len_ms));
    if isempty(win_len_samples)
        win_len_samples = round(default_win_len_ms/1000*signal_fs);
    end

    overlap_percent = input(sprintf('Enter overlap percentage (e.g., %d, default): ', default_overlap_percent));
    if isempty(overlap_percent)
        overlap_percent = default_overlap_percent;
    end
    noverlap = floor(win_len_samples * overlap_percent / 100);

    % NFFT points for FFT calculation within each window segment
    nfft = max(256, 2^nextpow2(win_len_samples)); % Ensure nfft is at least 256 and a power of 2

    figure;
    spectrogram(current_signal, hann(win_len_samples), noverlap, nfft, signal_fs, 'yaxis');
    title(['Spectrogram of ' strrep(signal_name, '_', ' ')]);
    % colormap jet; % Optional: change colormap
    colorbar;
    disp('Plotting spectrogram...');
end