%%
% ------------------ Topo ERP grouped ------------------

% clear;
% clc;
% folder_data = 'data_task\';
% conditions = {'AW', 'MO', 'MI'};
% task_labels = {'Arm', 'Leg'};
% tasks = {'*_Arm*', '*_Leg*'};
% baseline_window = [-500 0];
% time_windows = [0 250; 250 500; 500 750; 750 1000];
% 
% for condition = 1:length(conditions)
%     cond_name = conditions{condition};
%     folderPath = fullfile(folder_data, cond_name);
% 
%     for task = 1:length(tasks)
%         filePattern = strcat(tasks{task}, '.set');
%         fileList = dir(fullfile(folderPath, filePattern));
% 
%         ERP_subjects = [];  % Subjects x Channels x TimeWindow
% 
%         for i = 1:length(fileList)
%             EEG = pop_loadset('filename', fileList(i).name, 'filepath', folderPath);
%             EEG = pop_rmbase(EEG, baseline_window);
% 
%             nChans = size(EEG.data, 1);
%             nWins = size(time_windows, 1);
%             erp_windows = zeros(nChans, nWins);
% 
%             for w = 1:nWins
%                 t1 = time_windows(w, 1);
%                 t2 = time_windows(w, 2);
%                 [~, idx1] = min(abs(EEG.times - t1));
%                 [~, idx2] = min(abs(EEG.times - t2));
%                 tmp = mean(EEG.data(:, idx1:idx2, :), 2);  % avg over time
%                 tmp = squeeze(mean(tmp, 3));  % avg over trials
%                 erp_windows(:, w) = tmp;
%             end
% 
%             ERP_subjects(:, :, end+1) = erp_windows;
%         end
% 
%         % Grand average over subjects
%         grand_avg = mean(ERP_subjects, 3);
% 
%         % Plot each time window topoplot
%         figure('Name', [cond_name ' - ' task_labels{task}], 'Color', 'w');
%         for w = 1:nWins
%             subplot(2, 2, w);
%             topoplot(grand_avg(:, w), EEG.chanlocs, 'maplimits', 'absmax', 'electrodes', 'on');
%             title([num2str(time_windows(w, 1)) '-' num2str(time_windows(w, 2)) ' ms']);
%         end
%         sgtitle([cond_name ' - ' task_labels{task} ' ERP Topography']);
%         colorbar;
%     end
% end


% ------------------ Topographical ERD/ERS grouped ------------------
% clear;
% clc;
% folder_data = 'data_task\';
% conditions = {'AW', 'MO', 'MI'};
% task_labels = {'Arm', 'Leg'};
% tasks = {'*_Arm*', '*_Leg*'};
% baseline_window = [-500 0];
% time_windows = 0:250:2000;  % 250 ms steps
% mu_band = [8 13];
% beta_band = [13 30];
% 
% for condition = 1:length(conditions)
%     cond_name = conditions{condition};
%     folderPath = fullfile(folder_data, cond_name);
% 
%     for task = 1:length(tasks)
%         filePattern = strcat(tasks{task}, '.set');
%         fileList = dir(fullfile(folderPath, filePattern));
% 
%         mu_topo = [];
%         beta_topo = [];
% 
%         for i = 1:length(fileList)
%             EEG = pop_loadset('filename', fileList(i).name, 'filepath', folderPath);
%             EEG = pop_rmbase(EEG, baseline_window);
% 
%             ersp_all_chans = [];
%             for ch = 1:EEG.nbchan
%                 [ersp, ~, ~, times, freqs] = newtimef(EEG.data(ch,:,:), EEG.pnts, ...
%                     [EEG.xmin*1000 EEG.xmax*1000], EEG.srate, 0, ...
%                     'baseline', baseline_window, 'plotersp', 'off', 'plotitc', 'off');
% 
%                 ersp_all_chans(ch,:,:) = ersp;  % freq x time
%             end
% 
%             % Compute average in mu and beta bands per 250 ms window
%             mu_map = zeros(EEG.nbchan, length(time_windows)-1);
%             beta_map = zeros(EEG.nbchan, length(time_windows)-1);
% 
%             for w = 1:(length(time_windows)-1)
%                 t1 = time_windows(w);
%                 t2 = time_windows(w+1);
%                 [~, tidx1] = min(abs(times - t1));
%                 [~, tidx2] = min(abs(times - t2));
% 
%                 [~, fmu1] = min(abs(freqs - mu_band(1)));
%                 [~, fmu2] = min(abs(freqs - mu_band(2)));
%                 [~, fbeta1] = min(abs(freqs - beta_band(1)));
%                 [~, fbeta2] = min(abs(freqs - beta_band(2)));
% 
%                 for ch = 1:EEG.nbchan
%                     mu_map(ch, w) = mean(mean(ersp_all_chans(ch, fmu1:fmu2, tidx1:tidx2), 3), 2);
%                     beta_map(ch, w) = mean(mean(ersp_all_chans(ch, fbeta1:fbeta2, tidx1:tidx2), 3), 2);
%                 end
%             end
% 
%             % Accumulate across subjects
%             mu_topo = cat(3, mu_topo, mu_map);
%             beta_topo = cat(3, beta_topo, beta_map);
%         end
% 
%         % Compute grand average across subjects
%         mu_grand = mean(mu_topo, 3);
%         beta_grand = mean(beta_topo, 3);
% 
%         % Plot topoplots
%         bands = {'Mu', 'Beta'};
%         for band = 1:2
%             figure('Name', [cond_name ' - ' task_labels{task} ' - ' bands{band}], 'Color', 'w');
%             data_to_plot = mu_grand;
%             if band == 2
%                 data_to_plot = beta_grand;
%             end
% 
%             for w = 1:size(data_to_plot, 2)
%                 subplot(2, 4, w);
%                 topoplot(data_to_plot(:, w), EEG.chanlocs, 'maplimits', 'absmax', 'electrodes', 'on');
%                 title([num2str(time_windows(w)) '-' num2str(time_windows(w+1)) ' ms']);
%             end
% 
%             sgtitle([cond_name ' - ' task_labels{task} ' ' bands{band} ' Band ERSP']);
%             colorbar;
%         end
%     end
% end
% 

%%
% ------------------ Individual Topographical ERD/ERS ------------------

clear
clc

% Folder and setup
folder_data = 'data_task\';
conditions = {'AW', 'MO', 'MI'};
tasks = {'*_Arm*', '*_Leg*'};
time_windows = {[500 1000], [1000 1500]};  % ms
bands = {[9 13], [14 28]};              % mu and beta
band_labels = {'mu', 'beta'};

% Load channel locations from one example EEG file
example_file = dir(fullfile(folder_data, conditions{1}, '*.set'));
EEG_tmp = pop_loadset('filename', example_file(1).name, 'filepath', fullfile(folder_data, conditions{1}));
chanlocs = EEG_tmp.chanlocs;

for cond = 1:length(conditions)
    for task = 1:length(tasks)
        % Load all files for condition and task
        folderPath = fullfile(folder_data, conditions{cond});
        fileList = dir(fullfile(folderPath, [tasks{task} '.set']));

        ersp_all_subjects = [];  % Subjects x channels x freqs x times

        for i = 1:length(fileList)
            EEG = pop_loadset('filename', fileList(i).name, 'filepath', folderPath);

            % Preallocate ERSP: channels x freqs x times
            num_chans = EEG.nbchan;
            num_freqs = 80;

            ersp_subj = zeros(num_chans, num_freqs, 200);  % Adjust '200' to match timesout if needed

            for ch = 1:num_chans
                [ersp, ~, ~, times, freqs] = newtimef(EEG.data(ch,:,:), EEG.pnts, ...
                    [EEG.xmin*1000 EEG.xmax*1000], EEG.srate, ...
                    'cycles', [3 0.5], 'nfreqs', num_freqs, ...
                    'freqs', [4 40], 'baseline', [-1000 0], ...
                    'plotersp', 'off', 'plotitc', 'off', 'plotphase', 'off');

                ersp_subj(ch,:,:) = ersp;  % Save for current subject
            end

            ersp_all_subjects(:,:,:,i) = ersp_subj;
        end

        % Average over subjects
        ersp_avg = mean(ersp_all_subjects, 4);  % mean across subjects

        % Now compute average power in bands and time windows
        for b = 1:length(bands)
            band = bands{b};
            [~, band_idx] = find(freqs >= band(1) & freqs <= band(2));
            band_label = band_labels{b};

            for w = 1:length(time_windows)
                time_window = time_windows{w};
                [~, time_idx] = find(times >= time_window(1) & times <= time_window(2));

                % Average over time and freq within selected window and band
                power_map = squeeze(mean(mean(ersp_avg(:, band_idx, time_idx), 2), 3));  % channels x 1

                figure;
                topoplot(power_map, chanlocs, ...
                    'maplimits', 'maxmin', ...
                    'electrodes', 'on');
                title(sprintf('%s-%s: %s band [%d–%d ms]', ...
                    conditions{cond}, tasks{task}(3:end), band_label, time_window(1), time_window(2)));
                colorbar;
            end
        end
    end
end


% ------------------ Topographical ERP ------------------
% 
% clear
% clc
% 
% folder_data = 'data_task\';
% 
% % Setup
% conditions = {'AW', 'MO', 'MI'};
% tasks = {'*_Arm*', '*_Leg*'};
% time_windows = {[0 500], [500 1000]};  % ms
% window_labels = {'0–500 ms', '500–1000 ms'};
% 
% % Load example file for channel locations
% example_file = dir(fullfile(folder_data, conditions{1}, '*.set'));
% EEG_tmp = pop_loadset('filename', example_file(1).name, 'filepath', fullfile(folder_data, conditions{1}));
% chanlocs = EEG_tmp.chanlocs;
% 
% for cond = 1:length(conditions)
%     for task = 1:length(tasks)
%         % Load all subject files for this condition/task
%         folderPath = fullfile(folder_data, conditions{cond});
%         fileList = dir(fullfile(folderPath, [tasks{task} '.set']));
%         ERP_all_subjects = [];
% 
%         for i = 1:length(fileList)
%             EEG = pop_loadset('filename', fileList(i).name, 'filepath', folderPath);
% 
%             % Mean across epochs (ERP)
%             ERP = mean(EEG.data, 3);  % channels x time
% 
%             ERP_all_subjects(:,:,i) = ERP;  % Store subject ERP
%         end
% 
%         % Average across subjects
%         ERP_grand_avg = mean(ERP_all_subjects, 3);  % channels x time
% 
%         % Loop over time windows
%         for w = 1:length(time_windows)
%             time_window = time_windows{w};
%             [~, idx_start] = min(abs(EEG.times - time_window(1)));
%             [~, idx_end]   = min(abs(EEG.times - time_window(2)));
% 
%             % Average ERP across time window
%             ERP_window_avg = mean(ERP_grand_avg(:, idx_start:idx_end), 2);  % channels x 1
% 
%             % Plot
%             figure;
%             topoplot(ERP_window_avg, chanlocs, 'maplimits', 'maxmin', 'electrodes', 'on');
%             title(sprintf('ERP Topo: %s-%s [%s]', ...
%                 conditions{cond}, tasks{task}(3:end), window_labels{w}));
%             colorbar;
%         end
%     end
% end


