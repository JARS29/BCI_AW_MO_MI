clear
clc
folder_data = 'data_task\';   % 
chan={'C3' 'Cz' 'C4'};
%chan={'C3-Cz' 'C4-Cz'};
%chan = {'PO7', 'Pz', 'PO8'};

conditions ={'AW', 'MO', 'MI'};%'MO', 'MI'
tasks ={'*_Arm*', '*_Leg*'};
channels =[2, 3, 4];
%channels = [6, 5, 8];
%C3_Diestro_imag_third_S_1
for condition=1:length(conditions)
    folderPath = fullfile(folder_data, conditions{condition});
    for task = 1:length(tasks)
        filePattern = strcat(tasks{task}, '.set');
        fileList = dir(fullfile(folderPath, filePattern));
        EEG_dataset = {};  % Initialize as cell array
        for i = 1:length(fileList)
             EEG = pop_loadset('filename', fileList(i).name);
             %EEG = pop_resample(EEG, 512);  % Uncomment if you need resampling
             EEG_dataset{i} = EEG;       % Append EEG dataset to the cell array
             for j=1:length(channels)
                 [ersp, itc, powbasea, times, freqs, erspboot, itcboot]=  newtimef(EEG.data(channels(j),:,:), EEG.pnts,  [-1.0 3.0]*1000, EEG.srate, [4 0.5], 'freqs', [4 40], ...
                 'baseline',[-1000 0], 'nfreqs', 80, 'alpha', .05, 'plotersp', 'off', 'plotitc','off', 'plotphase','off');
                  csvwrite(fullfile('CSV_ERSP_CH/',strcat(chan{j},'_', conditions{condition},tasks{task}(2:5), '_S_', int2str(i),'.csv')), ersp');
             end
        end
        EEG_dataset_struct = [EEG_dataset{:}]; % Convert cell array to struct array

        EEG_original = pop_mergeset(EEG_dataset_struct, 1:length(EEG_dataset));  % Merge all datasets

% %%
% 
for j=1:length(channels)
   figure;
   newtimef(EEG_original.data(channels(j),:,:), EEG_original.pnts,  [-1000 3000], EEG_original.srate, [4 0.5], 'freqs', [4 40], ...
    'baseline',[-1000 0], 'nfreqs', 80, 'alpha', .05, 'plotersp', 'on', 'plotitc','off', 'plotphase','off','caption',strcat(chan{j}, conditions{condition}, tasks{task}) );
     %Calculate grand average only if there are any valid subject averages
end
    end
end

%%

