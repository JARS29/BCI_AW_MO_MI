function [EEG] = cleaning(EEG , dataName)
EEG = pop_rmdat( EEG, {'Start_cue_Arm','Start_cue_Leg'},[-3 3] ,0);

EEG = pop_selectevent( EEG, 'type',{'Start_cue_Arm','Start_cue_Leg'},'deleteevents','on');

%EEG = pop_resample( EEG, 128);

EEG = pop_eegfiltnew(EEG, 1, [], 1650, 0, [], 0);

EEG = pop_cleanline(EEG, 'bandwidth', 2, 'chanlist', 1:EEG.nbchan, 'computepower', 1, 'linefreqs', 60, 'newversion', 1, 'normSpectrum', 0, 'p', 0.01, 'pad', 2, 'plotfigures', 0, 'scanforlines', 0, 'sigtype', 'Channels', 'taperbandwidth', 2, 'tau', 100, 'verb', 1, 'winsize', 4, 'winstep', 1);


originalEEG  = EEG;
originalData = EEG.data;

EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off', ...
    'LineNoiseCriterion','off','Highpass','off', ...
    'BurstCriterion', 25, 'WindowCriterion', 0.2, ...
    'BurstRejection','off','Distance','Euclidian', ...
    'BurstCriterionRefMaxBadChns', 0, ...
    'BurstCriterionRefTolerances', [-Inf 8], ...
    'WindowCriterionTolerances',[-Inf 8], 'MaxMem', 1024*24);


survivedDataIdx           = find(EEG.etc.clean_sample_mask);
correspondingOriginalData = originalData(:,survivedDataIdx);
asrPowerReductionDb       = 10*log10(var(EEG.data,0,2)./var(correspondingOriginalData,0,2));
EEG.etc.varianceReductionInDbByAsr = asrPowerReductionDb;


EEG.nbchan = EEG.nbchan+1;
EEG.data(end+1,:) = zeros(1, EEG.pnts);
EEG.chanlocs(1,EEG.nbchan).labels = 'initialReference';
EEG = pop_reref(EEG, []);
EEG = pop_select(EEG,'nochannel',{'initialReference'});


EEG = pop_eegfiltnew(EEG, 1, 40, 1650, 0, [], 0);


EEG = eeg_checkset(EEG);
%eeglab redraw
participantID = dataName;  

% Calculate % of data retained after ASR
if isfield(EEG.etc, 'clean_sample_mask')
    percentRetained = mean(EEG.etc.clean_sample_mask) * 100;
else
    percentRetained = NaN;
end

% Calculate variance reduction in dB from ASR
if isfield(EEG.etc, 'varianceReductionInDbByAsr')
    asrPowerReductionDb = EEG.etc.varianceReductionInDbByAsr;
    meanAsrDb = mean(asrPowerReductionDb);
else
    meanAsrDb = NaN;
end

% Count remaining events
eventTypes = {EEG.event.type};
numArmEvents = sum(strcmp(eventTypes, 'Start_cue_Arm'));
numLegEvents = sum(strcmp(eventTypes, 'Start_cue_Leg'));

resultsTable = table( ...
    string(participantID), ...
    percentRetained, ...
    meanAsrDb, ...
    numArmEvents, ...
    numLegEvents, ...
    'VariableNames', {'ParticipantID','PercentRetained','MeanASRPowerReductionDb','NumArmEvents','NumLegEvents'} ...
    );

% === Export to CSV ===
outFilename = fullfile('cleaning','EEG_cleaning_metrics.csv');

if isfile(outFilename)
    existingTable = readtable(outFilename);
    combinedTable = [existingTable; resultsTable];
    writetable(combinedTable, outFilename);
else
    writetable(resultsTable, outFilename);
end


end

