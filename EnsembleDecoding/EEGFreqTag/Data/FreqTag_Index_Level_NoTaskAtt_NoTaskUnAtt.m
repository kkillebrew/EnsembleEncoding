% Script for creating index values from the OB frequency tags -
% 032219

clear all;
close all;

plotData = 1;
fakeData = 0;
newSubjs = 1;

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Orientation','Size'};
cats.attend = {'Left','Right'};

% Load in behavioral subject data
cd ../../
ensDataStructBehav = ensLoadData('FreqTagBehav','All');
cd ./'EEG Freq Tag'/Data/

subjList = ensDataStructBehav.subjid;

% What stim rates should we pick off
% stim_rate_BL(1) = 3;
% stim_rate_BL(2) = 5;
% stim_rate_OB(1,1) = .6;
% stim_rate_OB(1,2) = .75;
% stim_rate_OB(2,1) = .8;
% stim_rate_OB(2,2) = 2;
stimRate(1,1) = 3;   % BL frequencies
stimRate(1,2) = 5;
stimRate(2,1) = .6;   % OB frequencies
stimRate(2,2) = .75;
stimRate(3,1) = .8;
stimRate(3,2) = 2;

stimRateConvert = round(stimRate/0.1);

stimRateOB = [.6 .75 .8 2];

% If you are starting on new subjects, load in the group data files to
% append to them.
if newSubjs == 1
    load('./GroupResults/Group_results_60HzLP/segByLevelNoTask_Att_UnAtt_Index');
end

%% Create index values collapsing across both att hemifeild and task type
for n=17:length(subjList)
% for n=1
    %% Load/prep the data
    fprintf('%s%d\n','Subj: ',n)
    fprintf('%s\n','Loading and preping...')
    
    % Data directory
    if fakeData==1
        dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP');
    elseif fakeData==0
        dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP');
    end
    
    % Load in both runs of preprocessed data
    cd(dataDir)   % CD into the participant results folder to grab the preproc data
    
    % Load in everything but the trials
    % Clear out interp files for next load
    clear interp
    load(sprintf('%s%s',subjList{n},'_Ens_FreqTag_Prep_1'),'interp')   % Load
    combInterp{1} = interp;
    
    % Clear out cfg and interp files for next load
    clear interp
    load(sprintf('%s%s',subjList{n},'_Ens_FreqTag_Prep_2'),'interp')   % Load
    combInterp{2} = interp;
    
    % Load in the trials
    for j=1:2   % For both runs
        
        cd(sprintf('%s%s%s%d','./',subjList{n},'_Ens_FreqTag_Prep_',j))
        fileList = dir('*.mat');   % How many trial files are in the folder
        for i=1:length(fileList)
            load(sprintf('%s%d%s%d','Run_',j,'_Trial_',i));
            combInterp{j}.trial{i} = eval(sprintf('%s%d%s%d','Run_',j,'_Trial_',i));
            clear holder
            clear(sprintf('%s%d%s%d','Run_',j,'_Trial_',i))
        end
        cd ../   % CD back into pariticipant folder
        
        clear interp fileList
    end
    
    % Now combine the subfeilds of the two files (don't need to combine
    % everything in interp.cfg)
    interp.trial = [combInterp{1}.trial combInterp{2}.trial];
    interp.time = [combInterp{1}.time combInterp{2}.time];
    interp.trialinfo = [combInterp{1}.trialinfo; combInterp{2}.trialinfo];
    interp.sampleinfo = [combInterp{1}.sampleinfo; combInterp{2}.sampleinfo];
    interp.info = [combInterp{1}.info; combInterp{2}.info];
    interp.fsample = combInterp{1}.fsample;
    interp.label = combInterp{1}.label;
    interp.hdr.nChans = combInterp{1}.hdr.nChans;
    interp.hdr.label = combInterp{1}.hdr.label;
    interp.hdr.Fs = combInterp{1}.hdr.Fs;
    interp.hdr.nSample = [combInterp{1}.hdr.nSamples combInterp{2}.hdr.nSamples];
    interp.hdr.nSamplePre = [combInterp{1}.hdr.nSamplesPre combInterp{2}.hdr.nSamplesPre];
    interp.hdr.nTrials = [combInterp{1}.hdr.nTrials combInterp{2}.hdr.nTrials];
    
    cd ../   % CD back into data folder
    
    % Clear out the loading variables
    clear combInterp
    
    
    %% Segment the attended trials
    fprintf('%s\n','Segmenting...')
    
    segByLevelCounterOri = zeros(2,2,5,4);
    segByLevelCounterSize = zeros(2,2,5,4);
    
    % Segment trials into groups based on task present att vs unatt
    for i=1:length(interp.trial)   % For every trial
        
        fprintf('%s%d\n','Trial: ',i)
        
        % For trial i, what is the lvl of ori and size
        if mod(interp.trialinfo(i,2),5) == 0
            oriLvl(i) = 5;
        else
            oriLvl(i) = mod(interp.trialinfo(i,2),5);
        end
        if mod(interp.trialinfo(i,3),5) == 0
            sizeLvl(i) = 5;
        else
            sizeLvl(i) = mod(interp.trialinfo(i,3),5);
        end
        
        % What are the ori and size FTs when doing the ori task 
        if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=10) || (interp.trialinfo(i,3)>=11 && interp.trialinfo(i,3)<=20)  % Ori task (grab size tags)
            %% Size (while ori)
            % Which side is attended
            if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=5) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=15)  % Left att
                if interp.trialinfo(i,4) == 1   % 5Hz presented left
                    % Left OB's (left attended OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .8 Hz; Ori presented at 2 Hz
                        sizeFreq(i,1) = 3;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at 2 Hz; Ori presented at .8 Hz
                        sizeFreq(i,1) = 4;   % OB for size on the left
                    end
                    % Right OB's (right unattended OB's; compare w/ right attended size OB's)
                    if interp.trialinfo(i,6) == 1   % Size presented at .6 Hz; Ori presented at .75 Hz
                        sizeFreq(i,2) = 1;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at .75 Hz; Ori presented at .6 Hz
                        sizeFreq(i,2) = 2;   % OB for size on the right
                    end
                elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
                    % Left OB's (attended OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .6 Hz; Ori presented at .75 Hz
                        sizeFreq(i,1) = 1;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at .75 Hz; Ori presented at .6 Hz
                        sizeFreq(i,1) = 2;   % OB for size on the left
                    end
                    % Right OB's (right unattended OB's; comnpare w/ right attended ori OB's)
                    if interp.trialinfo(i,6) == 1   % Size presented at .8 Hz; Ori presented at 2 Hz
                        sizeFreq(i,2) = 3;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at 2 Hz; Ori presented at .8 Hz
                        sizeFreq(i,2) = 4;   % OB for size on the right
                    end
                end
                
                % Group the trial in the correct place
                % Ori task
                segByLevelCounterSize(1,1,sizeLvl(i),sizeFreq(i,1)) = segByLevelCounterSize(1,1,sizeLvl(i),sizeFreq(i,1))+1;   % Size left attend tag while ori task
                segByLevelCounterSize(1,2,sizeLvl(i),sizeFreq(i,2)) = segByLevelCounterSize(1,2,sizeLvl(i),sizeFreq(i,2))+1;   % Size right unattend tag while ori task
                segByLevelSize{1,1,sizeLvl(i),sizeFreq(i,1)}(segByLevelCounterSize(1,1,sizeLvl(i),sizeFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelSize{1,2,sizeLvl(i),sizeFreq(i,2)}(segByLevelCounterSize(1,2,sizeLvl(i),sizeFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            elseif (interp.trialinfo(i,3)>=6 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,3)>=16 && interp.trialinfo(i,3)<=20)  % Right att
                if interp.trialinfo(i,4) == 1   % 3Hz presented right
                    % Right OB's (right attended OB's)
                    if interp.trialinfo(i,6) == 1   % Size presented at .6 Hz; Ori presented at .75 Hz
                        sizeFreq(i,1) = 1;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at .75 Hz; Ori presented at .6 Hz
                        sizeFreq(i,1) = 2;   % OB for size on the right
                    end
                    % Left OB's (left unattended OB's; comnpare w/ left attended size OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .8 Hz; Ori presented at 2 Hz
                        sizeFreq(i,2) = 3;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at 2 Hz; Ori presented at .8 Hz
                        sizeFreq(i,2) = 4;   % OB for size on the left
                    end
                elseif interp.trialinfo(i,4) == 2   % 5Hz presented right
                    % Right OB's
                    if interp.trialinfo(i,6) == 1   % Size presented at .8 Hz; Ori presented at 2 Hz
                        sizeFreq(i,1) = 3;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at 2 Hz; Ori presented at .8 Hz
                        sizeFreq(i,1) = 4;   % OB for size on the right
                    end
                    % Left OB's (left unattended OB's; comnpare w/ left attended size OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .6 Hz; Ori presented at .75 Hz
                        sizeFreq(i,2) = 1;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at .75 Hz; Ori presented at .6 Hz
                        sizeFreq(i,2) = 2;   % OB for size on the left
                    end
                end
                
                % Group the trial in the correct place
                % Size task
                segByLevelCounterSize(2,1,sizeLvl(i),sizeFreq(i,1)) = segByLevelCounterSize(2,1,sizeLvl(i),sizeFreq(i,1))+1;   % Size right attend tag while ori task
                segByLevelCounterSize(2,2,sizeLvl(i),sizeFreq(i,2)) = segByLevelCounterSize(2,2,sizeLvl(i),sizeFreq(i,2))+1;   % Size left unattend tag while ori task
                segByLevelSize{2,1,sizeLvl(i),sizeFreq(i,1)}(segByLevelCounterSize(2,1,sizeLvl(i),sizeFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelSize{2,2,sizeLvl(i),sizeFreq(i,2)}(segByLevelCounterSize(2,2,sizeLvl(i),sizeFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            end
            
        elseif (interp.trialinfo(i,3)>=1 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=20)  % Size task (grab ori tags)
            %% Ori (while size)
            % Which side is attended?
            if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=5) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=15)  % Left att
                if interp.trialinfo(i,4) == 1   % 5Hz presented left
                    % Left OB's (left attended OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,1) = 4;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,1) = 3;   % OB for ori on the left
                    end
                    % Right OB's (right unattended OB's; comnpare w/ right attended ori OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,2) = 2;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,2) = 1;   % OB for ori on the right
                    end
                elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
                    % Left OB's (attended OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,1) = 2;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,1) = 1;   % OB for ori on the left
                    end
                    % Right OB's (right unattended OB's; comnpare w/ right attended ori OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,2) = 4;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,2) = 3;   % OB for ori on the right
                    end
                end
                
                % Group the trial in the correct place
                % Ori task
                segByLevelCounterOri(1,1,oriLvl(i),oriFreq(i,1)) = segByLevelCounterOri(1,1,oriLvl(i),oriFreq(i,1))+1;   % Ori left attend tag while size task
                segByLevelCounterOri(1,2,oriLvl(i),oriFreq(i,2)) = segByLevelCounterOri(1,2,oriLvl(i),oriFreq(i,2))+1;   % Ori right unattend tag while size task
                segByLevelOri{1,1,oriLvl(i),oriFreq(i,1)}(segByLevelCounterOri(1,1,oriLvl(i),oriFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelOri{1,2,oriLvl(i),oriFreq(i,2)}(segByLevelCounterOri(1,2,oriLvl(i),oriFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            elseif (interp.trialinfo(i,3)>=6 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,3)>=16 && interp.trialinfo(i,3)<=20)   % Right att
                if interp.trialinfo(i,4) == 1   % 3Hz presented right
                    % Right OB's (right attended OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,1) = 2;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,1) = 1;   % OB for ori on the right
                    end
                    % Left OB's (left unattended OB's; comnpare w/ left attended ori OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,2) = 4;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,2) = 3;   % OB for ori on the left
                    end
                elseif interp.trialinfo(i,4) == 2   % 5Hz presented right
                    % Right OB's
                    if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,1) = 4;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,1) = 3;   % OB for ori on the right
                    end
                    % Left OB's (left unattended OB's; comnpare w/ left attended ori OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,2) = 2;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,2) = 1;   % OB for ori on the left
                    end
                end
                
                % Group the trial in the correct place
                % Ori task
                segByLevelCounterOri(2,1,oriLvl(i),oriFreq(i,1)) = segByLevelCounterOri(2,1,oriLvl(i),oriFreq(i,1))+1;   % Ori right attend tag while size task
                segByLevelCounterOri(2,2,oriLvl(i),oriFreq(i,2)) = segByLevelCounterOri(2,2,oriLvl(i),oriFreq(i,2))+1;   % Ori left unattend tag while size task
                segByLevelOri{2,1,oriLvl(i),oriFreq(i,1)}(segByLevelCounterOri(2,1,oriLvl(i),oriFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelOri{2,2,oriLvl(i),oriFreq(i,2)}(segByLevelCounterOri(2,2,oriLvl(i),oriFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            end
        end 
    end
    
    %% Average and FFT
    fprintf('%s\n','Average and FFT...')
    for i=1:size(segByLevelOri,1)
        for j=1:size(segByLevelOri,2)
            for k=1:size(segByLevelOri,3)
                for o=1:size(segByLevelOri,4)
                    
                    % Average the trials together in each condition (feature, level, frequency)
                    if isempty(segByLevelOri{i,j,k,o})
                        segByLevelAveOri(i,j,k,o,:,:) = nan(256,20000);
                    else
                        segByLevelAveOri(i,j,k,o,:,:) = squeeze(nanmean(segByLevelOri{i,j,k,o},1));
                    end
                    
                    if isempty(segByLevelSize{i,j,k,o})
                        segByLevelAveSize(i,j,k,o,:,:) = nan(256,20000);
                    else
                        segByLevelAveSize(i,j,k,o,:,:) = squeeze(nanmean(segByLevelSize{i,j,k,o},1));
                    end
                    
                    % Clear out the trials in segByLevel for faster running
                    segByLevelOri{i,j,k,o} = [];
                    segByLevelSize{i,j,k,o} = [];
                    
                    % Now take the FFT
                    for l=1:size(segByLevelAveOri,5)   % Electrodes
                        segByLevelOriFFT(i,j,k,o,l,:,:) = abs(fft(segByLevelAveOri(i,j,k,o,l,:)));
                        segByLevelSizeFFT(i,j,k,o,l,:,:) = abs(fft(segByLevelAveSize(i,j,k,o,l,:)));
                    end
                    
                end
            end
        end
    end

    clear segByLevelOri segByLevelSize segByLevelAveOri segByLevelAveSize segByLevelCounterOri segByLevelCounterSize oriFreqOri oriFreqSize sizeFreqOri sizeFreqSize
    
    % Only pick off the relevant frequencies so we don't have to store a
    % gigantic file
    for i=1:4
        segByLevelFreqTagsOri(:,:,:,i,:,:) =  segByLevelOriFFT(:,:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
        segByLevelFreqTagsSize(:,:,:,i,:,:) =  segByLevelSizeFFT(:,:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
    end
    
    
    %% Create the index (Task att - task unatt)
    for j=1:5   % Level
        for k=1:4   % Frequency
            for l=1:3   % Harmonic
                % Ori left
                if isnan(segByLevelFreqTagsOri(1,1,j,k,:,l)) | isnan(segByLevelFreqTagsOri(2,2,j,k,:,l))
                    segByLevelIndex(1,1,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(1,1,j,k,:,l) = (segByLevelFreqTagsOri(1,1,j,k,:,l) - segByLevelFreqTagsOri(2,2,j,k,:,l)) ./...
                        (segByLevelFreqTagsOri(1,1,j,k,:,l) + segByLevelFreqTagsOri(2,2,j,k,:,l));
                end
                % Ori right
                if isnan(segByLevelFreqTagsOri(2,1,j,k,:,l)) | isnan(segByLevelFreqTagsOri(1,2,j,k,:,l))
                    segByLevelIndex(1,2,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(1,2,j,k,:,l) = (segByLevelFreqTagsOri(2,1,j,k,:,l) - segByLevelFreqTagsOri(1,2,j,k,:,l)) ./...
                        (segByLevelFreqTagsOri(1,2,j,k,:,l) + segByLevelFreqTagsOri(2,1,j,k,:,l));
                end
                
                % Size left
                if isnan(segByLevelFreqTagsSize(1,1,j,k,:,l)) | isnan(segByLevelFreqTagsSize(2,2,j,k,:,l))
                    segByLevelIndex(2,1,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(2,1,j,k,:,l) = (segByLevelFreqTagsSize(1,1,j,k,:,l) - segByLevelFreqTagsSize(2,2,j,k,:,l)) ./...
                        (segByLevelFreqTagsSize(1,1,j,k,:,l) + segByLevelFreqTagsSize(2,2,j,k,:,l));
                end
                % Size right
                if isnan(segByLevelFreqTagsSize(2,1,j,k,:,l)) | isnan(segByLevelFreqTagsSize(1,2,j,k,:,l))
                    segByLevelIndex(2,2,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(2,2,j,k,:,l) = (segByLevelFreqTagsSize(2,1,j,k,:,l) - segByLevelFreqTagsSize(1,2,j,k,:,l)) ./...
                        (segByLevelFreqTagsSize(1,2,j,k,:,l) + segByLevelFreqTagsSize(2,1,j,k,:,l));
                end
            end
        end
    end
    
    %% Take the difference between the delta 1's (1-2,2-3,3-4,4-5), delta
    % 2's (1-3,2-4,3-5), delta 3's (1-4,2-5), and delta 4's (1-5)
    deltaArray{1} = [1 2;2 3;3 4;4 5];
    deltaArray{2} = [1 3;2 4;3 5];
    deltaArray{3} = [1 4;2 5];
    deltaArray{4} = [1 5];
%     for n=1:length(subjList)
        for i=1:4
            for j=1:size(deltaArray{i},1)
                segByLevelIndexGroupDeltaHolder(:,:,1,:,:,:,j) = segByLevelIndex(:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelIndex(:,:,deltaArray{i}(j,1),:,:,:);
                
                segByLevelFreqTagsOriGroupDeltaHolder(:,:,1,:,:,:,j) = segByLevelFreqTagsOri(:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsOri(:,:,deltaArray{i}(j,1),:,:,:);
                
                segByLevelFreqTagsSizeGroupDeltaHolder(:,:,1,:,:,:,j) = segByLevelFreqTagsSize(:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsSize(:,:,deltaArray{i}(j,1),:,:,:);
            end
            
            segByLevelIndexGroupDelta(n,:,:,i,:,:,:,:) = squeeze(nanmean(segByLevelIndexGroupDeltaHolder,7));
            segByLevelFreqTagsOriGroupDelta(n,:,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsOriGroupDeltaHolder,7));
            segByLevelFreqTagsSizeGroupDelta(n,:,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsSizeGroupDeltaHolder,7));
            
            clear segByLevelFreqTagsOriGroupDeltaHolder segByLevelFreqTagsOriGroupDeltaHolder segByLevelFreqTagsSizeGroupDeltaHolder
        end
%     end

    %% Sort and save
    % Store in participant array
    segByLevelFreqTagsOriGroup(n,:,:,:,:,:,:) = segByLevelFreqTagsOri;
    segByLevelFreqTagsSizeGroup(n,:,:,:,:,:,:) = segByLevelFreqTagsSize;
    segByLevelIndexGroup(n,:,:,:,:,:,:) = segByLevelIndex;
    
    clear segByLevelOriFFT segByLevelSizeFFT segByLevelFreqTagsOri segByLevelFreqTagsSize segByLevelIndex
    
    % Save segByLevelFreqTagsGroup after each subject
    cd ../GroupResults/Group_results_60HzLP/
    save('segByLevelNoTask_Att_UnAtt_Index','segByLevelFreqTagsOriGroup','segByLevelFreqTagsSizeGroup','segByLevelIndexGroup',...
        'segByLevelFreqTagsOriGroupDelta','segByLevelFreqTagsSizeGroupDelta','segByLevelIndexGroupDelta')
    cd ../../
    
end

%% Group analysis
% Average across frequencies
segByLevelIndexGroupFreqAve = squeeze(nanmean(segByLevelIndexGroup,5));
segByLevelIndexGroupDeltaFreqAve = squeeze(nanmean(segByLevelIndexGroupDelta,5));
segByLevelFreqTagsOriGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsOriGroup,5));
segByLevelFreqTagsSizeGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsSizeGroup,5));
segByLevelFreqTagsOriGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsOriGroupDelta,5));
segByLevelFreqTagsSizeGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsSizeGroupDelta,5));

% Average across left/right attended
segByLevelIndexGroupFreqAttAve = squeeze(nanmean(segByLevelIndexGroupFreqAve,3));
segByLevelIndexGroupDeltaFreqAttAve = squeeze(nanmean(segByLevelIndexGroupDeltaFreqAve,3));
segByLevelFreqTagsOriGroupFreqAttAve(:,1,:,:,:) = nanmean(segByLevelFreqTagsOriGroupFreqAve(:,:,1,:,:,:),2);   % Ori attended
segByLevelFreqTagsOriGroupFreqAttAve(:,2,:,:,:) = nanmean(segByLevelFreqTagsOriGroupFreqAve(:,:,2,:,:,:),2);   % Ori unattended
segByLevelFreqTagsSizeGroupFreqAttAve(:,1,:,:,:) = nanmean(segByLevelFreqTagsSizeGroupFreqAve(:,:,1,:,:,:),2);   % Size attended
segByLevelFreqTagsSizeGroupFreqAttAve(:,2,:,:,:) = nanmean(segByLevelFreqTagsSizeGroupFreqAve(:,:,2,:,:,:),2);   % Size unattended
segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,1,:,:,:) = nanmean(segByLevelFreqTagsOriGroupDeltaFreqAve(:,:,1,:,:,:),2);   % Ori attended delta
segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,2,:,:,:) = nanmean(segByLevelFreqTagsOriGroupDeltaFreqAve(:,:,2,:,:,:),2);   % Ori unattended delta
segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,1,:,:,:) = nanmean(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,:,1,:,:,:),2);   % Size attended delta
segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,2,:,:,:) = nanmean(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,:,2,:,:,:),2);   % Size unattended delta

% Average across participants
segByLevelIndexGroupFreqAttPartAve = squeeze(nanmean(segByLevelIndexGroupFreqAttAve,1));
segByLevelIndexGroupDeltaFreqAttPartAve = squeeze(nanmean(segByLevelIndexGroupDeltaFreqAttAve,1));
segByLevelFreqTagsOriGroupFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsOriGroupFreqAttAve,1));
segByLevelFreqTagsSizeGroupFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsSizeGroupFreqAttAve,1));
segByLevelFreqTagsOriGroupDeltaFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsOriGroupDeltaFreqAttAve,1));
segByLevelFreqTagsSizeGroupDeltaFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsSizeGroupDeltaFreqAttAve,1));



%% For the freq tags (pre-indexing)

%% Plot the topos for each level for att and unatt for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     titleArray = {'Ori Attended' 'Ori Unattended'; 'Size Attended' 'Size Unattended'};
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 2200 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Levels - No Task - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
%         for c = 1:5   % For each level
%             for e = 1:3   % Harmonics
%                 counter = counter+2;
%                 cMap = colormap(jmaColors('pval'));
%                 if ~individualColors
%                     colorIdx = 1:length(conditions);
%                 else
%                     colorIdx = c;
%                 end
%                 switch plotVal
%                     case {'p','pval','p-value'}
%                         cMapMin = 0;
%                         cMapMax = 1;
%                         valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
%                     case {'t','tval','t-value'}
%                         if d==1
%                             % Ori attended
%                             valsToPlot1 = squeeze(segByLevelFreqTagsOriGroupFreqAttPartAve(1,c,:,e)); % plot t-stat
%                             % Ori unattended
%                             valsToPlot2 = squeeze(segByLevelFreqTagsOriGroupFreqAttPartAve(2,c,:,e)); % plot t-stat
%                         elseif d==2
%                             % Size attended
%                             valsToPlot1 = squeeze(segByLevelFreqTagsSizeGroupFreqAttPartAve(1,c,:,e)); % plot t-stat
%                             % Size unattended
%                             valsToPlot2 = squeeze(segByLevelFreqTagsSizeGroupFreqAttPartAve(2,c,:,e)); % plot t-stat
%                         end
%                         cMapMax = 9000;   % ceil(cMapMaxHolder(5)); 
%                         cMapMin = 2000;   % floor(cMapMinHolder(5));
%                     case 'mean'
%                         valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
%                         cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
%                         cMapMin = 0;
%                 end
%                 % Plot attended
%                 thisPlot = subplot(5,6,counter-1);
%                 %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
%                 mrC.plotOnEgi(valsToPlot1(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',titleArray{d,1},' - Level ',c,' - ',e,' Harmonic'));
%                 
%                 % Plot unattended
%                 thisPlot = subplot(5,6,counter);
%                 %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
%                 mrC.plotOnEgi(valsToPlot2(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',titleArray{d,2},' - Level ',c,' - ',e,' Harmonic'));
%             end
%         end
%         
%         % Save the figure and then close it
%         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%         savefig(h,sprintf('%s%s%s','FreqTags_No_Task_Att_UnAtt_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','FreqTags_No_Task_Att_UnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsOriGroupFreqAttAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            if i==1   % Ori att vs ori unatt
                t1 = table(squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,1,4,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,1,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
                t2 = table(squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,2,4,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAttAve(:,2,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            elseif i==2   % Size while size vs size while ori
                t1 = table(squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,1,4,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,1,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
                t2 = table(squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,2,4,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAttAve(:,2,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            end
            
            % Within subject labels
            within = table([1 2 3 4 5]');
            
            % Fit a repeated measures model
            rm1 = fitrm(t1,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            rm2 = fitrm(t2,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            
            % Perform the linear contrast
            lContrast1{i,j,k} = ranova(rm1,'WithinModel',[-2 -1 0 1 2]');   % Attended
            lContrast2{i,j,k} = ranova(rm2,'WithinModel',[-2 -1 0 1 2]');   % Unattended
            
            % Grab the Fstat and pvalue
            % Attended
            lContrastF(1,i,j,k) = lContrast1{i,j,k}{1,4};
            lContrastP(1,i,j,k) = lContrast1{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(1,i,j,k) < .05
                sigElectrodes(1,i,k) = sigElectrodes(1,i,k)+1;
            end
            
            % Unattended
            lContrastF(2,i,j,k) = lContrast2{i,j,k}{1,4};
            lContrastP(2,i,j,k) = lContrast2{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(2,i,j,k) < .05
                sigElectrodes(2,i,k) = sigElectrodes(2,i,k)+1;
            end
            
        end
    end
end

% Number of expected electrodes at a p=0.05
expectedFA = ceil(0.05*256);
% Calculate the q val for each contrast
for i=1:size(sigElectrodes,1)   % Ori/Size
    for j=1:size(sigElectrodes,2)   % attend/unatt
        for k=1:size(sigElectrodes,3)   % Harmonics
            qVals(i,j,k) = expectedFA/sigElectrodes(j,i,k);
            if qVals(i,j,k) == inf
                qVals(i,j,k) = NaN;
            end
        end
    end
end

% Plot the significance value for the linear contrast for each electrode in a bar graph
if plotData == 1
    plotVal = 't';
    individualColors = true;
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    condLabel = {'Orientation No Task Attended' 'Orientation No Task Unattended'; 'Size No Task Attended' 'Size No Task Unattended'};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);

        hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Freq Tag Linear Contrast FStat - No Task - ',condLabel{d,1},' vs. ',condLabel{d,2}));
        for e = 1:3   % Harmonics
            for f=1:2   % att/unatt
                counter = counter+1;
                thisPlot(counter) = subplot(3,2,counter);
                cMap = colormap(jmaColors('pval'));
                if ~individualColors
                    colorIdx = 1:length(conditions);
                else
                    colorIdx = e;
                end
                switch plotVal
                    case {'p','pval','p-value'}
                        cMapMin = 0;
                        cMapMax = 1;
                        valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                    case {'t','tval','t-value'}
                        if f==1   % att
                            valsToPlot = squeeze(lContrastF(1,d,:,e)); % plot t-stat
                        elseif f==2   % unatt
                            valsToPlot = squeeze(lContrastF(2,d,:,e)); % plot t-stat
                        end
                        cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                        cMapMin = 0;
                    case 'mean'
                        valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                        cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                        cMapMin = 0;
                end
                %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
                if f==1   % att
                    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(1,d,:,e))<.05),false,markerProps);
                elseif f==2   % unatt
                   mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(2,d,:,e))<.05),false,markerProps); 
                end
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                if f==1
                    title(sprintf('%s%s%d%s',condLabel{d,1},' - ',e,' Harmonic'),'FontSize',12);
                elseif f==2
                    title(sprintf('%s%s%d%s',condLabel{d,2},' - ',e,' Harmonic'),'FontSize',12);
                end
                % Plot the stats
                text1 = sprintf('%s','o : significant electrodes at a threshold of');
                text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
                text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,f,e));
                text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
                
            end
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(sprintf('%s%s%s','FreqTags_Linear_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_Topo.fig'));
        print(sprintf('%s%s%s','FreqTags_Linear_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end





%% For the delta freq tags (pre-indexing)

%% Plot the topos for each level for att and unatt for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     titleArray = {'Ori Attended' 'Ori Unattended'; 'Size Attended' 'Size Unattended'};
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 2200 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Delta Levels - No Task - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
%         for c = 1:4   % For each level
%             for e = 1:3   % Harmonics
%                 counter = counter+2;
%                 cMap = colormap(jmaColors('pval'));
%                 if ~individualColors
%                     colorIdx = 1:length(conditions);
%                 else
%                     colorIdx = c;
%                 end
%                 switch plotVal
%                     case {'p','pval','p-value'}
%                         cMapMin = 0;
%                         cMapMax = 1;
%                         valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
%                     case {'t','tval','t-value'}
%                         if d==1
%                             % Ori attended
%                             valsToPlot1 = squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttPartAve(1,c,:,e)); % plot t-stat
%                             % Ori unattended
%                             valsToPlot2 = squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttPartAve(2,c,:,e)); % plot t-stat
%                         elseif d==2
%                             % Size attended
%                             valsToPlot1 = squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttPartAve(1,c,:,e)); % plot t-stat
%                             % Size unattended
%                             valsToPlot2 = squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttPartAve(2,c,:,e)); % plot t-stat
%                         end
%                         cMapMax = 500;   % ceil(cMapMaxHolder(5)); 
%                         cMapMin = 0;   % floor(cMapMinHolder(5));
%                     case 'mean'
%                         valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
%                         cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
%                         cMapMin = 0;
%                 end
%                 % Plot attended
%                 thisPlot = subplot(4,6,counter-1);
%                 %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
%                 mrC.plotOnEgi(valsToPlot1(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',titleArray{d,1},' - Level ',c,' - ',e,' Harmonic'));
%                 
%                 % Plot unattended
%                 thisPlot = subplot(4,6,counter);
%                 %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
%                 mrC.plotOnEgi(valsToPlot2(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',titleArray{d,2},' - Level ',c,' - ',e,' Harmonic'));
%             end
%         end
%         
%         % Save the figure and then close it
%         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%         savefig(h,sprintf('%s%s%s','FreqTags_Delta_No_Task_Att_UnAtt_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','FreqTags_Delta_No_Task_Att_UnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsOriGroupFreqAttAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            if i==1   % Ori att vs ori unatt
                t1 = table(squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,1,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
                t2 = table(squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAttAve(:,2,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
            elseif i==2   % Size while size vs size while ori
                t1 = table(squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,1,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
                t2 = table(squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAttAve(:,2,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
            end
            
            % Within subject labels
            within = table([1 2 3 4]');
            
            % Fit a repeated measures model
            rm1 = fitrm(t1,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            rm2 = fitrm(t2,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            
            % Perform the linear contrast
            lContrast1{i,j,k} = ranova(rm1,'WithinModel',[-1.5 -.5 .5 1.5]');   % Attended
            lContrast2{i,j,k} = ranova(rm2,'WithinModel',[-1.5 -.5 .5 1.5]');   % Unattended
            
            % Grab the Fstat and pvalue
            % Attended
            lContrastF(1,i,j,k) = lContrast1{i,j,k}{1,4};
            lContrastP(1,i,j,k) = lContrast1{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(1,i,j,k) < .05
                sigElectrodes(1,i,k) = sigElectrodes(1,i,k)+1;
            end
            
            % Unattended
            lContrastF(2,i,j,k) = lContrast2{i,j,k}{1,4};
            lContrastP(2,i,j,k) = lContrast2{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(2,i,j,k) < .05
                sigElectrodes(2,i,k) = sigElectrodes(2,i,k)+1;
            end
            
        end
    end
end

% Number of expected electrodes at a p=0.05
expectedFA = ceil(0.05*256);
% Calculate the q val for each contrast
for i=1:size(sigElectrodes,1)   % Ori/Size
    for j=1:size(sigElectrodes,2)   % attend/unatt
        for k=1:size(sigElectrodes,3)   % Harmonics
            qVals(i,j,k) = expectedFA/sigElectrodes(j,i,k);
            if qVals(i,j,k) == inf
                qVals(i,j,k) = NaN;
            end
        end
    end
end

% Plot the significance value for the linear contrast for each electrode in a bar graph
if plotData == 1
    plotVal = 't';
    individualColors = true;
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    condLabel = {'Orientation No Task Attended' 'Orientation No Task Unattended'; 'Size No Task Attended' 'Size No Task Unattended'};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Delta Freq Tag Linear Contrast FStat - No Task - ',condLabel{d,1},' vs. ',condLabel{d,2}));
        for e = 1:3   % Harmonics
            for f=1:2   % att/unatt
                counter = counter+1;
                thisPlot(counter) = subplot(3,2,counter);
                cMap = colormap(jmaColors('pval'));
                if ~individualColors
                    colorIdx = 1:length(conditions);
                else
                    colorIdx = e;
                end
                switch plotVal
                    case {'p','pval','p-value'}
                        cMapMin = 0;
                        cMapMax = 1;
                        valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                    case {'t','tval','t-value'}
                        if f==1   % att
                            valsToPlot = squeeze(lContrastF(1,d,:,e)); % plot t-stat
                        elseif f==2   % unatt
                            valsToPlot = squeeze(lContrastF(2,d,:,e)); % plot t-stat
                        end
                        cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                        cMapMin = 0;
                    case 'mean'
                        valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                        cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                        cMapMin = 0;
                end
                %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
                if f==1   % att
                    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(1,d,:,e))<.05),false,markerProps);
                elseif f==2   % unatt
                   mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(2,d,:,e))<.05),false,markerProps); 
                end
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                if f==1
                    title(sprintf('%s%s%d%s',condLabel{d,1},' - ',e,' Harmonic'));
                elseif f==2
                    title(sprintf('%s%s%d%s',condLabel{d,2},' - ',e,' Harmonic'));
                end
                
                % Plot the stats
                text1 = sprintf('%s','o : significant electrodes at a threshold of');
                text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
                text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,f,e));
                text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
            end
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','FreqTags_Delta_Linear_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','FreqTags_Delta_Linear_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end







%% For the normal indices

%% Plot the topos for each level for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 1100 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s\n',cats.task{d},' While ',cats.task{3-d},' - Levels - No Task - Attended/Unattended'));
%         for c = 1:5   % For each level
%             for e = 1:3   % Harmonics
%                 counter = counter+1;
%                 thisPlot(counter) = subplot(5,3,counter);
%                 cMap = colormap(jmaColors('pval'));
%                 if ~individualColors
%                     colorIdx = 1:length(conditions);
%                 else
%                     colorIdx = c;
%                 end
%                 switch plotVal
%                     case {'p','pval','p-value'}
%                         cMapMin = 0;
%                         cMapMax = 1;
%                         valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
%                     case {'t','tval','t-value'}
%                         valsToPlot = squeeze(segByLevelIndexGroupFreqAttPartAve(d,c,:,e)); % plot t-stat
%                         cMapMax = .15; %ceil(max(max(valsToPlot(:,colorIdx))));
%                         cMapMin = -.15;
%                     case 'mean'
%                         valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
%                         cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
%                         cMapMin = 0;
%                 end
%                 %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
%                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',cats.task{d},' Level ',c,' - ',e,' Harmonic'));
%             end
%         end
%         
%         % Save the figure and then close it
%         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%         savefig(h,sprintf('%s%s%s%s%s','Levels_No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s%s%s','Levels_No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelIndexGroupFreqAttAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            t = table(squeeze(segByLevelIndexGroupFreqAttAve(:,i,1,j,k)),squeeze(segByLevelIndexGroupFreqAttAve(:,i,2,j,k)),...
                squeeze(segByLevelIndexGroupFreqAttAve(:,i,3,j,k)),squeeze(segByLevelIndexGroupFreqAttAve(:,i,4,j,k)),...
                squeeze(segByLevelIndexGroupFreqAttAve(:,i,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            
            % Within subject labels
            within = table([1 2 3 4 5]');
            
            % Fit a repeated measures model
            rm = fitrm(t,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            
            % Perform the linear contrast
            lContrast{i,j,k} = ranova(rm,'WithinModel',[-2 -1 0 1 2]');
            
            % Grab the Fstat and pvalue
            lContrastF(i,j,k) = lContrast{i,j,k}{1,4};
            lContrastP(i,j,k) = lContrast{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(i,j,k) < .05
                sigElectrodes(i,k) = sigElectrodes(i,k)+1;
            end
            
        end
    end
end

% Number of expected electrodes at a p=0.05
expectedFA = ceil(0.05*256);
% Calculate the q val for each contrast
for i=1:size(sigElectrodes,1)   % Ori/size
    for j=1:size(sigElectrodes,2)   % harmonic
        qVals(i,j) = expectedFA/sigElectrodes(i,j);
        if qVals(i,j) == inf
            qVals(i,j) = NaN;
        end
    end
end

% Plot the significance value for the linear contrast for each electrode in a bar graph
if plotData == 1
    plotVal = 't';
    individualColors = true;
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s\n',cats.task{d},' While ',cats.task{3-d},' - Linear Contrast FStat - No Task - Attended/Unattended'));
        for e = 1:3   % Harmonics
            counter = counter+1;
            thisPlot(counter) = subplot(3,1,counter);
            cMap = colormap(jmaColors('pval'));
            if ~individualColors
                colorIdx = 1:length(conditions);
            else
                colorIdx = d;
            end
            switch plotVal
                case {'p','pval','p-value'}
                    cMapMin = 0;
                    cMapMax = 1;
                    valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                case {'t','tval','t-value'}
                    valsToPlot = squeeze(lContrastF(d,:,e))'; % plot t-stat
                    cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                    cMapMin = 0;
                case 'mean'
                    valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                    cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                    cMapMin = 0;
            end
            %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
            mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(d,:,e))<.05),false,markerProps);
            
            set(gcf,'ColorMap',cMap);
            set(gca, 'Clim',[cMapMin,cMapMax]);
            title(sprintf('%s%s%d%s',cats.task{d},' - ',e,' Harmonic'));
            
            % Plot the stats
            text1 = sprintf('%s','o : significant electrodes at a threshold of');
            text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
            text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,e));
            text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s%s%s','Linear_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.fig'));   % Save .fig
        print(h,sprintf('%s%s%s%s%s','Linear_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end





%% For the delta indices

%% Plot the topos for each level for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 1100 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s\n',cats.task{d},' While ',cats.task{3-d},' - Delta Levels - No Task - Attended/Unattended'));
%         for c = 1:4   % For each delta level
%             for e = 1:3   % Harmonics
%                 counter = counter+1;
%                 thisPlot(counter) = subplot(4,3,counter);
%                 cMap = colormap(jmaColors('pval'));
%                 if ~individualColors
%                     colorIdx = 1:length(conditions);
%                 else
%                     colorIdx = c;
%                 end
%                 switch plotVal
%                     case {'p','pval','p-value'}
%                         cMapMin = 0;
%                         cMapMax = 1;
%                         valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
%                     case {'t','tval','t-value'}
%                         valsToPlot = squeeze(segByLevelIndexGroupDeltaFreqAttPartAve(d,c,:,e)); % plot t-stat
%                         cMapMax = .15; %ceil(max(max(valsToPlot(:,colorIdx))));
%                         cMapMin = -.15;
%                     case 'mean'
%                         valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
%                         cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
%                         cMapMin = 0;
%                 end
%                 %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
%                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',cats.task{d},' Level ',c,' - ',e,' Harmonic'));
%             end
%         end
%         
%         % Save the figure and then close it
%         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%         savefig(h,sprintf('%s%s%s%s%s','Levels_Delta_No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s%s%s','Levels_Delta_No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelIndexGroupFreqAttAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            t = table(squeeze(segByLevelIndexGroupDeltaFreqAttAve(:,i,1,j,k)),squeeze(segByLevelIndexGroupDeltaFreqAttAve(:,i,2,j,k)),...
                squeeze(segByLevelIndexGroupDeltaFreqAttAve(:,i,3,j,k)),squeeze(segByLevelIndexGroupDeltaFreqAttAve(:,i,4,j,k)),...
                'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
            
            % Within subject labels
            within = table([1 2 3 4]');
            
            % Fit a repeated measures model
            rm = fitrm(t,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            
            % Perform the linear contrast
            lContrast{i,j,k} = ranova(rm,'WithinModel',[-1.5 -.5 .5 1.5]');
            
            % Grab the Fstat and pvalue
            lContrastF(i,j,k) = lContrast{i,j,k}{1,4};
            lContrastP(i,j,k) = lContrast{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(i,j,k) < .05
                sigElectrodes(i,k) = sigElectrodes(i,k)+1;
            end
            
        end
    end
end

% Number of expected electrodes at a p=0.05
expectedFA = ceil(0.05*256);
% Calculate the q val for each contrast
for i=1:size(sigElectrodes,1)   % Ori/size
    for j=1:size(sigElectrodes,2)   % harmonic
        qVals(i,j) = expectedFA/sigElectrodes(i,j);
        if qVals(i,j) == inf
            qVals(i,j) = NaN;
        end
    end
end

% Plot the significance value for the linear contrast for each electrode in a bar graph
if plotData == 1
    plotVal = 't';
    individualColors = true;
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s\n',cats.task{d},' While ',cats.task{3-d},' - Delta Linear Contrast FStat - No Task - Attended/Unattended'));
        for e = 1:3   % Harmonics
            counter = counter+1;
            thisPlot(counter) = subplot(3,1,counter);
            cMap = colormap(jmaColors('pval'));
            if ~individualColors
                colorIdx = 1:length(conditions);
            else
                colorIdx = d;
            end
            switch plotVal
                case {'p','pval','p-value'}
                    cMapMin = 0;
                    cMapMax = 1;
                    valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                case {'t','tval','t-value'}
                    valsToPlot = squeeze(lContrastF(d,:,e))'; % plot t-stat
                    cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                    cMapMin = 0;
                case 'mean'
                    valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                    cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                    cMapMin = 0;
            end
            %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
            mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(d,:,e))<.05),false,markerProps);
            
            set(gcf,'ColorMap',cMap);
            set(gca, 'Clim',[cMapMin,cMapMax]);
            title(sprintf('%s%s%d%s',cats.task{d},' - ',e,' Harmonic'));
            
            % Plot the stats
            text1 = sprintf('%s','o : significant electrodes at a threshold of');
            text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
            text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,e));
            text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s%s%s','Linear_Delta_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.fig'));   % Save .fig
        print(h,sprintf('%s%s%s%s%s','Linear_Delta_Contrast_FStat-No_Task_Att_UnAtt_',cats.task{d},'_While_',cats.task{3-d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end








