format long g;

dirName=pwd;
key=strcat(dirName,filesep,'*.csv');
files = dir(key);

record_path = strcat(dirName,filesep,'record.csv');
stim_path = strcat(dirName,filesep,'stim.csv');

% Reject last column
stim_to_import = importdata(stim_path);
stim = stim_to_import.data(:, 1:end-1);

% Reject last column
record_to_import = importdata(record_path);
record = record_to_import.data(:, 1:end-1);

% Create variables for channel names inside the workspace
record_to_import.colheaders(1) = [];
record_to_import.colheaders(end) = [];
channel_names = record_to_import.colheaders;
for r=1:size(record_to_import.colheaders, 2)
    eval(strcat(record_to_import.colheaders{r}, '=', int2str(r)));
end

% Normalizasyon
X = record(:, 2:end);

% Average channel of 14 channels
average_channel = mean(X, 2);
average_channel_matrix = repmat(average_channel, 1, length(channel_names));
record(:, 2:end) = X - average_channel_matrix;

% sampling period
Fs = 128;
Ts = 1 / Fs;
nb_bands = 5;

numberOfsongs = 10;
playing_time = 120;
playing_time_points = 120 * Fs;
pause_time = 10;

song_cats = {'happy', 'peaceful', 'romantic', 'sad', 'tension'};

% Get the list of played songs
songs = stim(1:2:end, 2)';

% Cut the song EEG's
next_song = 1;
for i=1:2:numberOfsongs*2
    song_number = stim(i, 2);
    song_idx = record(:, 1) >= stim(i, 1) & record(:, 1) <= stim(i + 1, 1);
    cat_idx = ceil(song_number / length(song_cats));
    data = record(song_idx, 2:end);
    fprintf('Cutting between %.2f and %.2f for song %d (%.2f seconds) \n', stim(i, 1), stim(i+1, 1), song_number, length(data(:, 1)) / Fs);
    cat_name = song_cats{cat_idx};
    Song_Structure(next_song).name = strcat(cat_name(1), int2str(song_number));
    Song_Structure(next_song).cat_label = cat_idx;
    Song_Structure(next_song).cat = cat_name;
    Song_Structure(next_song).eeg = data;
    Song_Structure(next_song).band_powers = [];
    next_song = next_song + 1;
end

% Sort the structures
Afields = fieldnames(Song_Structure);
Acell = struct2cell(Song_Structure);
sz = size(Acell);
Acell = reshape(Acell, sz(1), []);
Acell = Acell';
Acell = sortrows(Acell, 2);
Acell = reshape(Acell', sz);
AsortedStructOf_Songs = cell2struct(Acell, Afields, 1);

features = zeros(length(songs), (nb_bands * length(channel_names)) + 1);

% Iterate over channels
for j=1:length(channel_names)
    h = figure('visible', 'off');

    plot_id = 1;
    for id = [1:2:length(AsortedStructOf_Songs) 2:2:length(AsortedStructOf_Songs)]
        data = AsortedStructOf_Songs(id).eeg;
        % obtain size of data
        [N, nu] = size(data);
        % generates time vector
        t=(1:N) * Ts;
        
        [ps, freq] = pwelch(data(:, j), 512, 256, 512, Fs, 'psd');
        ps = 10*log10(ps);

        % Save the frequency information into the struct
        AsortedStructOf_Songs(id).ps = ps;
        AsortedStructOf_Songs(id).freq = freq;
        
        % delta: 0-4 (actually >0 and <= 4 as eeg contains very low freq
        % energy in somewhere between 0 and 2Hz)
        % theta: 4-8
        % alpha: 8-12
        % beta : 12-16
        % gamma: 16-20
        
        mean_power_0_4 = mean(ps(find(freq >= 1 & freq <= 4)));
        mean_power_4_8 = mean(ps(find(freq >= 4 & freq <= 8)));
        mean_power_8_12 = mean(ps(find(freq >= 8 & freq <= 12)));
        mean_power_12_16 = mean(ps(find(freq >= 12 & freq <= 16)));
        mean_power_16_20 = mean(ps(find(freq >= 16 & freq <= 20)));
        
        AsortedStructOf_Songs(id).band_powers = ...
            [AsortedStructOf_Songs(id).band_powers ...
                [mean_power_0_4 mean_power_4_8 mean_power_8_12 mean_power_12_16  mean_power_16_20]];

        subplot(2, 5, plot_id);
        plot_id = plot_id + 1;
        plot(freq, ps);
        title([AsortedStructOf_Songs(id).cat '(' AsortedStructOf_Songs(id).name ')']);
        
    end
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    over_title = ['Channel ', channel_names{j}];
    text(0.5, 1, over_title, 'HorizontalAlignment' ,'center','VerticalAlignment', 'top');
    set(h,'PaperOrientation','landscape');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 1 1]);
    %saveas(h, [channel_names{j} '.pdf'], 'pdf');
end

for i = 1:length(songs)
    features(i, 1:70) = AsortedStructOf_Songs(i).band_powers;
    features(i, end) = AsortedStructOf_Songs(i).cat_label;
end

filename='features.tab';
fileID = fopen(filename,'wb');


for i=1:length(channel_names)
    for j=1:nb_bands
        fprintf(fileID, '%s_%d\t', channel_names{i}, j);
    end
end
fprintf(fileID, 'cD#Class\n');
for i=1:length(channel_names)
    for j=1:nb_bands
        fprintf(fileID, 'c\t');
    end
end
fprintf(fileID, 'd\n');

for i=1:length(channel_names)
    for j=1:nb_bands
        fprintf(fileID, '\t');
    end
end
fprintf(fileID, 'class\n');
fclose(fileID);

dlmwrite(filename, features, 'delimiter', '\t', '-append');


