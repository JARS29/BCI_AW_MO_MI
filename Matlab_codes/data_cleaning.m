clear
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
path=pwd;
folder_base = 'raw_data\';
folder_targ = 'cleaned_dataset\';

for sub_folder = 1:29
    files = dir(fullfile(folder_base, int2str(sub_folder), '*set*'));
    for file=1:length(files)
        disp(sub_folder)
        disp(files(file).name)
        filename = split(files(file).name, '_');
        target_path = fullfile(folder_targ, int2str(sub_folder));

        EEG = pop_loadset(fullfile(files(file).folder, files(file).name));
        EEG = cleaning(EEG, files(file).name);

        if length(filename)< 3
          EEG = pop_saveset( EEG, 'filename',strcat(filename{1}, '_cleaned_', filename{2}),'filepath',target_path);
        else
          EEG = pop_saveset( EEG, 'filename',strcat(filename{1}, '_cleaned_', filename{3}),'filepath',target_path);
        end
    end
end