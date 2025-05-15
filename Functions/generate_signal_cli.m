% --- Function: generate_signal_cli.m (or in the same file) ---
function generate_signal_cli()
    global current_signal signal_fs signal_name;

    disp('--- Generate Signal ---');
    disp('1. Sine Wave');
    disp('2. Square Wave');
    disp('3. Sawtooth Wave');
    disp('4. Gaussian Noise');
    type_choice = input('Select signal type: ');

    if isempty(type_choice) || ~ismember(type_choice, 1:4)
        disp('Invalid type. Generation cancelled.');
        return;
    end

    fs_in = input('Enter sampling frequency (Fs) in Hz (e.g., 1000): ');
    duration_in = input('Enter duration in seconds (e.g., 1): ');
    amp_in = input('Enter amplitude (e.g., 1): ');

    if any(isempty([fs_in, duration_in, amp_in])) || any(~isnumeric([fs_in, duration_in, amp_in])) || fs_in <= 0 || duration_in <= 0
        disp('Invalid parameters. Generation cancelled.');
        return;
    end

    signal_fs = fs_in;
    N = round(signal_fs * duration_in);
    t = (0:N-1)' / signal_fs; % Time vector

    switch type_choice
        case 1 % Sine
            freq_in = input('Enter frequency of sine wave in Hz (e.g., 50): ');
            phase_in_deg = input('Enter phase in degrees (e.g., 0): ');
             if isempty(freq_in) || ~isnumeric(freq_in) || freq_in <=0
                disp('Invalid frequency.'); return;
            end
            current_signal = amp_in * sin(2 * pi * freq_in * t + deg2rad(phase_in_deg));
            signal_name = sprintf('Sine_%.1fHz_%.1famp', freq_in, amp_in);
        case 2 % Square
            freq_in = input('Enter frequency of square wave in Hz (e.g., 50): ');
             if isempty(freq_in) || ~isnumeric(freq_in) || freq_in <=0
                disp('Invalid frequency.'); return;
            end
            current_signal = amp_in * square(2 * pi * freq_in * t);
            signal_name = sprintf('Square_%.1fHz_%.1famp', freq_in, amp_in);
        case 3 % Sawtooth
            freq_in = input('Enter frequency of sawtooth wave in Hz (e.g., 50): ');
             if isempty(freq_in) || ~isnumeric(freq_in) || freq_in <=0
                disp('Invalid frequency.'); return;
            end
            current_signal = amp_in * sawtooth(2 * pi * freq_in * t);
            signal_name = sprintf('Sawtooth_%.1fHz_%.1famp', freq_in, amp_in);
        case 4 % Gaussian Noise
            current_signal = amp_in * randn(N, 1); % Amplitude here acts as standard deviation scaling
            signal_name = sprintf('GaussianNoise_%.1famp', amp_in);
    end
    disp(['Signal "' signal_name '" generated successfully. Samples: ' num2str(length(current_signal))]);
end