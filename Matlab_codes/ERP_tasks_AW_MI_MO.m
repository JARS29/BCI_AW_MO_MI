%%-- ERP Channel x Conditions  ---------
% clear
% clc
% 
% folder_data = 'data_task\';
% 
% chan = {'Fz', 'C3','Cz', 'C4', 'Pz', 'Oz'};
% conditions = {'AW', 'MO', 'MI'};
% tasks = {'*_Arm*', '*_Leg*'};
% %channels = [2, 3, 4];
% channels = [1, 2, 3, 4, 5, 7];
% 
% baseline_window = [-500 0];
% smooth_window = 10;  % samples for moving average
% 
% colors = lines(3);  % Distinct colors for the 3 conditions
% 
% for task = 1:length(tasks)
%     for j = 1:length(channels)
%         figure;
%         hold on;
% 
%         for condition = 1:length(conditions)
%             folderPath = fullfile(folder_data, conditions{condition});
%             filePattern = strcat(tasks{task}, '.set');
%             fileList = dir(fullfile(folderPath, filePattern));
% 
%             ERP_all_subjects = [];
% 
%             for i = 1:length(fileList)
%                 EEG = pop_loadset('filename', fileList(i).name, 'filepath', folderPath);
%                 EEG = pop_rmbase(EEG, baseline_window);
%                 ERP = mean(EEG.data, 3);  % Channels x Time
%                 ERP_all_subjects = cat(3, ERP_all_subjects, ERP);
%             end
% 
%             if ~isempty(ERP_all_subjects)
%                 grand_avg = mean(ERP_all_subjects, 3);
%                 erp_wave = grand_avg(channels(j), :);
% 
%                 % Smooth ERP using moving average
%                 erp_smooth = smoothdata(erp_wave, 'movmean', smooth_window);
% 
%                 % Plot
%                 plot(EEG.times, erp_smooth, 'LineWidth', 2, 'Color', colors(condition, :));
%             end
%         end
% 
%         hold off;
%         legend(conditions, 'Location', 'best');
%         title([chan{j} ' - ' tasks{task}(2:5) ' (Grand Average ERP)']);
%         xlabel('Time (ms)');
%         ylabel('Amplitude (µV)');
%         xlim([-500 1000]);
%         grid on;
%     end
% end

%%--- ERP Condition x Channel x Task ---%%

% clear;
% clc;
% 
% folder_data = 'data_task\';
% chan = {'Fz', 'Cz', 'Pz', 'Oz'};
% conditions = {'AW', 'MO', 'MI'};
% task_labels = {'Arm', 'Leg'};
% tasks = {'*_Arm*', '*_Leg*'};
% channels = [1, 3, 5, 7];  % indices for channels Fz, Cz, Pz, Oz
% 
% baseline_window = [-500 0];
% smooth_window = 10;  % in samples
% 
% task_colors = lines(2);  % one color per task (Arm, Leg)
% 
% for condition = 1:length(conditions)
%     cond_name = conditions{condition};
%     folderPath = fullfile(folder_data, cond_name);
% 
%     for ch = 1:length(channels)
%         figure('Name', [cond_name ' - ' chan{ch}], 'Color', 'w');
%         hold on;
% 
%         for task = 1:length(tasks)
%             filePattern = strcat(tasks{task}, '.set');
%             fileList = dir(fullfile(folderPath, filePattern));
% 
%             ERP_all_subjects = [];
% 
%             for i = 1:length(fileList)
%                 EEG = pop_loadset('filename', fileList(i).name, 'filepath', folderPath);
%                 EEG = pop_rmbase(EEG, baseline_window);
% 
%                 ERP = mean(EEG.data, 3);  % Channels x Time
%                 ERP_all_subjects = cat(3, ERP_all_subjects, ERP);
%             end
% 
%             if ~isempty(ERP_all_subjects)
%                 grand_avg = mean(ERP_all_subjects, 3);  % Channels x Time
%                 erp_wave = grand_avg(channels(ch), :);
%                 erp_smooth = smoothdata(erp_wave, 'movmean', smooth_window);
% 
%                 plot(EEG.times, erp_smooth, 'LineWidth', 2, 'Color', task_colors(task, :));
%             end
%         end
% 
%         % Final touches per plot
%         title([cond_name ' - ' chan{ch}]);
%         xlabel('Time (ms)');
%         ylabel('Amplitude (µV)');
%         legend(task_labels, 'Location', 'best');
%         xlim([-500 1000]);
%         yline(0, '--k');
%         xline(0, '--k');
%         grid on;
%     end
% end
%%----



% 

%%----- Output files ----- %% 

% folder_data = 'data_task\';
% output_folder = 'ERP_exports\';  
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% 
% chan_labels = {'Fz', 'C3','Cz', 'C4', 'Pz', 'Oz'};
% conditions = {'AW', 'MO', 'MI'};
% tasks = {'Arm', 'Leg'};
% channels = [1, 2, 3, 4, 5, 7];  % Correspond to above labels
% 
% baseline_window = [-500 0];  % ms
% 
% for taskIdx = 1:length(tasks)
%     task = tasks{taskIdx};
%     for condIdx = 1:length(conditions)
%         condition = conditions{condIdx};
%         folderPath = fullfile(folder_data, condition);
%         fileList = dir(fullfile(folderPath, ['*_' task '.set']));
% 
%         for fileIdx = 1:length(fileList)
%             EEG = pop_loadset('filename', fileList(fileIdx).name, 'filepath', folderPath);
%             EEG = pop_rmbase(EEG, baseline_window);
%             ERP = mean(EEG.data, 3);  % channels x time
%             times = EEG.times;       % time vector (1 x time)
% 
%             % Extract subject ID from filename
%             [~, fname, ~] = fileparts(fileList(fileIdx).name);
%             subjectID = extractBefore(fname, '_');
% 
%             for chIdx = 1:length(channels)
%                 chNum = channels(chIdx);
%                 chName = chan_labels{chIdx};
%                 erp_wave = ERP(chNum, :)';  % column vector
% 
%                 T = table(times', erp_wave, 'VariableNames', {'Time', 'ERP'});
% 
%                 % Define filename: e.g. "sub01_Cz_AW_Arm.csv"
%                 output_name = sprintf('%s_%s_%s_%s.csv', subjectID, chName, condition, task);
%                 writetable(T, fullfile(output_folder, output_name));
%             end
%         end
%     end
% end
