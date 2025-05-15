function load_signal_cli()
    global current_signal signal_fs signal_name;

    disp('--- Load Signal ---');
    disp('Supported formats: .mat, .csv, .txt (single column), .wav');
    filepath = input('Enter full path to signal file: ', 's');

    if isempty(filepath)
        disp('Load cancelled.');
        return;
    end

    if ~isfile(filepath) % older MATLAB versions might use exist(filepath, 'file')
        disp('Error: File not found.');
        return;
    end

    [~, name, ext] = fileparts(filepath);
    signal_name = name; % Store the base name

    try
        switch lower(ext)
            case '.mat'
                data = load(filepath);
                fields = fieldnames(data);
                if numel(fields) == 1
                    loaded_var = data.(fields{1});
                else
                    disp('Multiple variables found in .mat file:');
                    for i = 1:numel(fields)
                        disp([num2str(i) '. ' fields{i}]);
                    end
                    var_choice = input('Select variable to load: ');
                    if var_choice > 0 && var_choice <= numel(fields)
                        loaded_var = data.(fields{var_choice});
                    else
                        disp('Invalid selection.'); return;
                    end
                end

                % Attempt to find sampling frequency if stored
                if isstruct(loaded_var) && isfield(loaded_var, 'data') && isfield(loaded_var, 'fs')
                    current_signal = loaded_var.data;
                    signal_fs = loaded_var.fs;
                     disp('Loaded signal and Fs from structure in .mat file.');
                elseif isnumeric(loaded_var)
                     current_signal = loaded_var;
                     prompt_fs = input(sprintf('Enter sampling frequency (Fs) for "%s" (Hz): ', signal_name));
                     if isnumeric(prompt_fs) && prompt_fs > 0
                         signal_fs = prompt_fs;
                     else
                         disp('Invalid Fs. Load failed.'); current_signal = []; return;
                     end
                else
                    disp('Unsupported .mat file structure.'); return;
                end

            case '.csv'
                current_signal = readmatrix(filepath);
                prompt_fs = input(sprintf('Enter sampling frequency (Fs) for "%s" (Hz): ', signal_name));
                if isnumeric(prompt_fs) && prompt_fs > 0
                    signal_fs = prompt_fs;
                else
                    disp('Invalid Fs. Load failed.'); current_signal = []; return;
                end
            case '.txt' % Assuming single column numeric data
                current_signal = dlmread(filepath); % or readmatrix for newer MATLAB
                 prompt_fs = input(sprintf('Enter sampling frequency (Fs) for "%s" (Hz): ', signal_name));
                if isnumeric(prompt_fs) && prompt_fs > 0
                    signal_fs = prompt_fs;
                else
                    disp('Invalid Fs. Load failed.'); current_signal = []; return;
                end
            case '.wav'
                [current_signal, signal_fs] = audioread(filepath);
                disp(['Loaded audio file. Detected Fs = ' num2str(signal_fs) ' Hz.']);
            otherwise
                disp(['Error: Unsupported file extension "' ext '".']);
                return;
        end

        % Handle multi-channel signals (take first channel by default for simplicity in CLI)
        if size(current_signal, 2) > 1
            disp(['Signal has ' num2str(size(current_signal, 2)) ' channels. Using first channel.']);
            current_signal = current_signal(:, 1);
        end
        current_signal = current_signal(:); % Ensure it's a column vector

        disp(['Signal "' signal_name ext '" loaded successfully. Samples: ' num2str(length(current_signal))]);

    catch ME
        disp(['Error loading file: ' ME.message]);
        current_signal = [];
        signal_fs = NaN;
        signal_name = 'Untitled';
    end
end