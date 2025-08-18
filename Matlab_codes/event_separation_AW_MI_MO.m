folder_base = 'cleaned_dataset\';   % Replace with the actual path
folder_targ = 'data_task\';
tasks = {'Start_cue_Arm', 'Start_cue_Leg'};
skipSubjects = [];  % Subjects to skip

for sub_folder = 1:29
    if ismember(sub_folder, skipSubjects)
        fprintf('Skipping subject %d\n', sub_folder);
        continue;
    end

    files = dir(fullfile(folder_base, int2str(sub_folder), '*set*'));

    for file = 1:length(files)
        name = files(file).name;
        filename = split(name, '_');

        for task = 1:length(tasks)
            task_name = split(tasks{task}, '_');

            EEG = pop_loadset(fullfile(files(file).folder, name));
            eventsToRemove = ~ismember({EEG.event.type}, tasks);
            EEG.event(eventsToRemove) = [];
            EEG_epoched = pop_epoch(EEG, {tasks{task}}, [-1 3]);
            EEG_epoched = pop_rmbase(EEG_epoched, [-1000 0]);

            % Determine session type
            if strcmp(filename{3}, 'AW.set')
                target_path = fullfile(folder_targ, 'AW');
                save_name = strcat(filename{1}, '_AW_', task_name{3});
            elseif strcmp(filename{3}, 'MO.set')
                target_path = fullfile(folder_targ, 'MO');
                save_name = strcat(filename{1}, '_MO_', task_name{3});
            elseif strcmp(filename{3}, 'MI.set')
                target_path = fullfile(folder_targ, 'MI');
                save_name = strcat(filename{1}, '_MI_', task_name{3});
            else
                continue;
            end

            EEG_epoched = pop_saveset(EEG_epoched, 'filename', save_name, 'filepath', target_path);
        end
    end
end
