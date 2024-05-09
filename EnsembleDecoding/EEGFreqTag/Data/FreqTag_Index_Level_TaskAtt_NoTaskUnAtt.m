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
    load('./GroupResults/Group_results_60HzLP/segByLevelTask_Att_NoTask_UnAtt_Index');
end

%% Create index values collapsing across both att hemifeild and task type
for n=16:length(subjList)
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
    
    segByLevelCounterTaskAtt = zeros(2,2,2,5,4);
    segByLevelCounterNoTaskUnAtt = zeros(2,2,2,5,4);
    
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
        if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=10) || (interp.trialinfo(i,3)>=11 && interp.trialinfo(i,3)<=20)  % Ori task
            %% Ori 
            % Which side is attended
            if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=5) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=15)  % Left att
                if interp.trialinfo(i,4) == 1   % 5Hz presented left
                    % Left OB's (left attended OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,1) = 4;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,1) = 3;   % OB for ori on the left
                    end
                    % Right OB's (right unattended OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        sizeFreq(i,2) = 1;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        sizeFreq(i,2) = 2;   % OB for size on the right
                    end
                elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
                    % Left OB's (attended OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,1) = 2;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,1) = 1;   % OB for ori on the left
                    end
                    % Right OB's (right unattended OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        sizeFreq(i,2) = 3;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        sizeFreq(i,2) = 4;   % OB for ori on the right
                    end
                end
                
                % Group the trial in the correct place
                % Ori task
                % segByLevel first ind = ori/size TAGS
                % segByLevel second ind = left/right hemifield
                % segByLevel third ind = ori/size task 
                segByLevelCounterTaskAtt(1,1,1,oriLvl(i),oriFreq(i,1)) = segByLevelCounterTaskAtt(1,1,1,oriLvl(i),oriFreq(i,1))+1;   % Ori left attend tag while ori task
                segByLevelCounterNoTaskUnAtt(2,2,1,sizeLvl(i),sizeFreq(i,2)) = segByLevelCounterNoTaskUnAtt(2,2,1,sizeLvl(i),sizeFreq(i,2))+1;   % Size right unattend tag while ori task
                segByLevelTaskAtt{1,1,1,oriLvl(i),oriFreq(i,1)}(segByLevelCounterTaskAtt(1,1,1,oriLvl(i),oriFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelNoTaskUnAtt{2,2,1,sizeLvl(i),sizeFreq(i,2)}(segByLevelCounterNoTaskUnAtt(2,2,1,sizeLvl(i),sizeFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);

            elseif (interp.trialinfo(i,3)>=6 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,3)>=16 && interp.trialinfo(i,3)<=20)  % Right att
                if interp.trialinfo(i,4) == 1   % 3Hz presented right
                    % Right OB's (right attended OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,1) = 2;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,1) = 1;   % OB for ori on the right
                    end
                    % Left OB's (left unattended OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        sizeFreq(i,2) = 4;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        sizeFreq(i,2) = 3;   % OB for ori on the left
                    end
                elseif interp.trialinfo(i,4) == 2   % 5Hz presented right
                    % Right OB's (right attended OB's)
                    if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,1) = 4;   % OB for ori on the right
                    elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,1) = 3;   % OB for ori on the right
                    end
                    % Left OB's (left unattended OB's)
                    if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                        sizeFreq(i,2) = 2;   % OB for ori on the left
                    elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                        sizeFreq(i,2) = 1;   % OB for ori on the left
                    end
                end
                
                % Group the trial in the correct place
                % Ori task
                % segByLevel first ind = ori/size TAGS
                % segByLevel second ind = left/right hemifield
                % segByLevel third ind = ori/size task 
                segByLevelCounterTaskAtt(1,2,1,oriLvl(i),oriFreq(i,1)) = segByLevelCounterTaskAtt(1,2,1,oriLvl(i),oriFreq(i,1))+1;   % Ori right attend tag while ori task
                segByLevelCounterNoTaskUnAtt(2,1,1,sizeLvl(i),sizeFreq(i,2)) = segByLevelCounterNoTaskUnAtt(2,1,1,sizeLvl(i),sizeFreq(i,2))+1;   % Size left unattend tag while ori task
                segByLevelTaskAtt{1,2,1,oriLvl(i),oriFreq(i,1)}(segByLevelCounterTaskAtt(1,2,1,oriLvl(i),oriFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelNoTaskUnAtt{2,1,1,sizeLvl(i),sizeFreq(i,2)}(segByLevelCounterNoTaskUnAtt(2,1,1,sizeLvl(i),sizeFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            end
            
        elseif (interp.trialinfo(i,3)>=1 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=20)  % Size task
            %% Size
            % Which side is attended?
            if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=5) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=15)  % Left att
                if interp.trialinfo(i,4) == 1   % 5Hz presented left
                    % Left OB's (left attended OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .8 Hz; Size presented at 2 Hz
                        sizeFreq(i,1) = 3;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at 2 Hz; Size presented at .8 Hz
                        sizeFreq(i,1) = 4;   % OB for size on the left
                    end
                    % Right OB's (right unattended OB's)
                    if interp.trialinfo(i,6) == 1   % Size presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,2) = 1;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,2) = 2;   % OB for size on the right
                    end
                elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
                    % Left OB's (attended OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .6 Hz; Size presented at .75 Hz
                        sizeFreq(i,1) = 1;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at .75 Hz; Size presented at .6 Hz
                        sizeFreq(i,1) = 2;   % OB for size on the left
                    end
                    % Right OB's (right unattended OB's)
                    if interp.trialinfo(i,6) == 1   % Size presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,2) = 3;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,2) = 4;   % OB for size on the right
                    end
                end
                
                % Group the trial in the correct place
                % Size task
                % segByLevel first ind = ori/size TAGS
                % segByLevel second ind = left/right hemifield
                % segByLevel third ind = ori/size task 
                segByLevelCounterTaskAtt(2,1,2,sizeLvl(i),sizeFreq(i,1)) = segByLevelCounterTaskAtt(2,1,2,sizeLvl(i),sizeFreq(i,1))+1;   % Size left attend tag while size task
                segByLevelCounterNoTaskUnAtt(1,2,2,oriLvl(i),oriFreq(i,2)) = segByLevelCounterNoTaskUnAtt(1,2,2,oriLvl(i),oriFreq(i,2))+1;   % Ori right unattend tag while size task
                segByLevelTaskAtt{2,1,2,sizeLvl(i),sizeFreq(i,1)}(segByLevelCounterTaskAtt(2,1,2,sizeLvl(i),sizeFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelNoTaskUnAtt{1,2,2,oriLvl(i),oriFreq(i,2)}(segByLevelCounterNoTaskUnAtt(1,2,2,oriLvl(i),oriFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            elseif (interp.trialinfo(i,3)>=6 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,3)>=16 && interp.trialinfo(i,3)<=20)   % Right att
                if interp.trialinfo(i,4) == 1   % 3Hz presented right
                    % Right OB's (right attended OB's)
                    if interp.trialinfo(i,6) == 1   % Size presented at .6 Hz; Size presented at .75 Hz
                        sizeFreq(i,1) = 1;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at .75 Hz; Size presented at .6 Hz
                        sizeFreq(i,1) = 2;   % OB for size on the right
                    end
                    % Left OB's (left unattended OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .8 Hz; Size presented at 2 Hz
                        oriFreq(i,2) = 3;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at 2 Hz; Size presented at .8 Hz
                        oriFreq(i,2) = 4;   % OB for size on the left
                    end
                elseif interp.trialinfo(i,4) == 2   % 5Hz presented right
                    % Right OB's
                    if interp.trialinfo(i,6) == 1   % Size presented at 2 Hz; Size presented at .8 Hz
                        sizeFreq(i,1) = 3;   % OB for size on the right
                    elseif interp.trialinfo(i,6) == 2   % Size presented at .8 Hz; Size presented at 2 Hz
                        sizeFreq(i,1) = 4;   % OB for size on the right
                    end
                    % Left OB's (left unattended OB's; comnpare w/ left attended size OB's)
                    if interp.trialinfo(i,5) == 1   % Size presented at .75 Hz; Size presented at .6 Hz
                        oriFreq(i,2) = 1;   % OB for size on the left
                    elseif interp.trialinfo(i,5) == 2   % Size presented at .6 Hz; Size presented at .75 Hz
                        oriFreq(i,2) = 2;   % OB for size on the left
                    end
                end
                
                % Group the trial in the correct place
                % Size task
                % segByLevel first ind = ori/size TAGS
                % segByLevel second ind = left/right hemifield
                % segByLevel third ind = ori/size task 
                segByLevelCounterTaskAtt(2,2,2,sizeLvl(i),sizeFreq(i,1)) = segByLevelCounterTaskAtt(2,2,2,sizeLvl(i),sizeFreq(i,1))+1;   % Size right attend tag while size task
                segByLevelCounterNoTaskUnAtt(1,1,2,oriLvl(i),oriFreq(i,2)) = segByLevelCounterNoTaskUnAtt(1,1,2,oriLvl(i),oriFreq(i,2))+1;   % Ori left unattend tag while size task
                segByLevelTaskAtt{2,2,2,sizeLvl(i),sizeFreq(i,1)}(segByLevelCounterTaskAtt(2,2,2,sizeLvl(i),sizeFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);
                segByLevelNoTaskUnAtt{1,1,2,oriLvl(i),oriFreq(i,2)}(segByLevelCounterNoTaskUnAtt(1,1,2,oriLvl(i),oriFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);
                
            end
        end 
    end
    
    %% Average and FFT
    fprintf('%s\n','Average and FFT...')
    for i=1:size(segByLevelTaskAtt,1)   % ori/size TAGS
        for j=1:size(segByLevelTaskAtt,2)   % left/right hemifield
            for k=1:size(segByLevelTaskAtt,3)   % ori/size task
                for o=1:size(segByLevelTaskAtt,4)   % feature level
                    for p=1:size(segByLevelTaskAtt,5)   % oddball frequency
                        
                        % Average the trials together in each condition
                        if isempty(segByLevelTaskAtt{i,j,k,o,p})
                            segByLevelAveTaskAtt(i,j,k,o,p,:,:) = nan(256,20000);
                        else
                            segByLevelAveTaskAtt(i,j,k,o,p,:,:) = squeeze(nanmean(segByLevelTaskAtt{i,j,k,o,p},1));
                        end
                        
                        if isempty(segByLevelNoTaskUnAtt{i,j,k,o,p})
                            segByLevelAveNoTaskUnAtt(i,j,k,o,p,:,:) = nan(256,20000);
                        else
                            segByLevelAveNoTaskUnAtt(i,j,k,o,p,:,:) = squeeze(nanmean(segByLevelNoTaskUnAtt{i,j,k,o,p},1));
                        end
                        
                        % Clear out the trials in segByLevel for faster running
                        segByLevelTaskAtt{i,j,k,o,p} = [];
                        segByLevelNoTaskUnAtt{i,j,k,o,p} = [];
                        
                        % Now take the FFT
                        for l=1:size(segByLevelAveTaskAtt,6)   % Electrodes
                            segByLevelTaskAttFFT(i,j,k,o,p,l,:,:) = abs(fft(segByLevelAveTaskAtt(i,j,k,o,p,l,:)));
                            segByLevelNoTaskUnAttFFT(i,j,k,o,p,l,:,:) = abs(fft(segByLevelAveNoTaskUnAtt(i,j,k,o,p,l,:)));
                        end
                        
                    end
                end
            end
        end
    end

    clear segByLevelTaskAtt segByLevelNoTaskUnAtt segByLevelAveTaskAtt segByLevelAveNoTaskUnAtt segByLevelCounterTaskAtt segByLevelCounterNoTaskUnAtt
    
    % Only pick off the relevant frequencies so we don't have to store a
    % gigantic file
    for i=1:4
        segByLevelFreqTagsTaskAtt(:,:,:,:,i,:,:) =  segByLevelTaskAttFFT(:,:,:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
        segByLevelFreqTagsNoTaskUnAtt(:,:,:,:,i,:,:) =  segByLevelNoTaskUnAttFFT(:,:,:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
    end
    
    
    %% Create the index (Task att - task unatt)
    for j=1:5   % Level
        for k=1:4   % Frequency
            for l=1:3   % Harmonic
                
                % segByLevel first ind = ori/size TAGS
                % segByLevel second ind = left/right hemifield
                % segByLevel third ind = ori/size task 
                
                % Ori left
                if isnan(segByLevelFreqTagsTaskAtt(1,1,1,j,k,:,l)) | isnan(segByLevelFreqTagsNoTaskUnAtt(1,1,2,j,k,:,l))
                    segByLevelIndex(1,1,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(1,1,j,k,:,l) = (segByLevelFreqTagsTaskAtt(1,1,1,j,k,:,l) - segByLevelFreqTagsNoTaskUnAtt(1,1,2,j,k,:,l)) ./...
                        (segByLevelFreqTagsTaskAtt(1,1,1,j,k,:,l) + segByLevelFreqTagsNoTaskUnAtt(1,1,2,j,k,:,l));
                end
                % Ori right
                if isnan(segByLevelFreqTagsTaskAtt(1,2,1,j,k,:,l)) | isnan(segByLevelFreqTagsNoTaskUnAtt(1,2,2,j,k,:,l))
                    segByLevelIndex(1,2,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(1,2,j,k,:,l) = (segByLevelFreqTagsTaskAtt(1,2,1,j,k,:,l) - segByLevelFreqTagsNoTaskUnAtt(1,2,2,j,k,:,l)) ./...
                        (segByLevelFreqTagsTaskAtt(1,2,1,j,k,:,l) + segByLevelFreqTagsNoTaskUnAtt(1,2,2,j,k,:,l));
                end
                
                % Size left
                if isnan(segByLevelFreqTagsTaskAtt(2,1,2,j,k,:,l)) | isnan(segByLevelFreqTagsNoTaskUnAtt(2,1,1,j,k,:,l))
                    segByLevelIndex(2,1,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(2,1,j,k,:,l) = (segByLevelFreqTagsTaskAtt(2,1,2,j,k,:,l) - segByLevelFreqTagsNoTaskUnAtt(2,1,1,j,k,:,l)) ./...
                        (segByLevelFreqTagsTaskAtt(2,1,2,j,k,:,l) + segByLevelFreqTagsNoTaskUnAtt(2,1,1,j,k,:,l));
                end
                % Size right
                if isnan(segByLevelFreqTagsTaskAtt(2,2,2,j,k,:,l)) | isnan(segByLevelFreqTagsNoTaskUnAtt(2,2,1,j,k,:,l))
                    segByLevelIndex(2,2,j,k,:,l) = nan(256,1);
                else
                    segByLevelIndex(2,2,j,k,:,l) = (segByLevelFreqTagsTaskAtt(2,2,2,j,k,:,l) - segByLevelFreqTagsNoTaskUnAtt(2,2,1,j,k,:,l)) ./...
                        (segByLevelFreqTagsTaskAtt(2,2,2,j,k,:,l) + segByLevelFreqTagsNoTaskUnAtt(2,2,1,j,k,:,l));
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
%     for n=1:15
        for i=1:4
            for j=1:size(deltaArray{i},1)
                segByLevelIndexGroupDeltaHolder(:,:,1,:,:,:,j) = segByLevelIndex(:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelIndex(:,:,deltaArray{i}(j,1),:,:,:);
                
                segByLevelFreqTagsTaskAttGroupDeltaHolder(:,:,:,1,:,:,:,j) = segByLevelFreqTagsTaskAtt(:,:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsTaskAtt(:,:,:,deltaArray{i}(j,1),:,:,:);
                
                segByLevelFreqTagsNoTaskUnAttGroupDeltaHolder(:,:,:,1,:,:,:,j) = segByLevelFreqTagsNoTaskUnAtt(:,:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsNoTaskUnAtt(:,:,:,deltaArray{i}(j,1),:,:,:);
            end
%             for j=1:size(deltaArray{i},1)
%                 segByLevelIndexGroupDeltaHolder(:,:,1,:,:,:,j) = segByLevelIndexGroup(n,:,:,deltaArray{i}(j,2),:,:,:) -...
%                     segByLevelIndexGroup(n,:,:,deltaArray{i}(j,1),:,:,:);
%                 
%                 segByLevelFreqTagsTaskAttGroupDeltaHolder(:,:,:,1,:,:,:,j) = segByLevelFreqTagsTaskAttGroup(n,:,:,:,deltaArray{i}(j,2),:,:,:) -...
%                     segByLevelFreqTagsTaskAttGroup(n,:,:,:,deltaArray{i}(j,1),:,:,:);
%                 
%                 segByLevelFreqTagsNoTaskUnAttGroupDeltaHolder(:,:,:,1,:,:,:,j) = segByLevelFreqTagsNoTaskUnAttGroup(n,:,:,:,deltaArray{i}(j,2),:,:,:) -...
%                     segByLevelFreqTagsNoTaskUnAttGroup(n,:,:,:,deltaArray{i}(j,1),:,:,:);
%             end
            
            segByLevelIndexGroupDelta(n,:,:,i,:,:,:,:) = squeeze(nanmean(segByLevelIndexGroupDeltaHolder,7));
            segByLevelFreqTagsTaskAttGroupDelta(n,:,:,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsTaskAttGroupDeltaHolder,7));
            segByLevelFreqTagsNoTaskUnAttGroupDelta(n,:,:,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroupDeltaHolder,7));
            
            clear segByLevelIndexGroupDeltaHolder segByLevelFreTagsTaskAttGroupDeltaHolder segByLevelFreTagsNoTaskUnAttGroupDeltaHolder
        end
%     end

    %% Sort and save
    % Store in participant array
    segByLevelFreqTagsTaskAttGroup(n,:,:,:,:,:,:,:) = segByLevelFreqTagsTaskAtt;
    segByLevelFreqTagsNoTaskUnAttGroup(n,:,:,:,:,:,:,:) = segByLevelFreqTagsNoTaskUnAtt;
    segByLevelIndexGroup(n,:,:,:,:,:,:,:) = segByLevelIndex;
    
    clear segByLevelTaskAttFFT segByLevelNoTaskUnAttFFT segByLevelFreqTagsTaskAtt segByLevelFreqTagsNoTaskUnAtt segByLevelIndex
    
    % Save segByLevelFreqTagsGroup after each subject
    cd ../GroupResults/Group_results_60HzLP/
    save('segByLevelTask_Att_NoTask_UnAtt_Index','segByLevelFreqTagsTaskAttGroup','segByLevelFreqTagsNoTaskUnAttGroup','segByLevelIndexGroup',...
        'segByLevelFreqTagsTaskAttGroupDelta','segByLevelFreqTagsNoTaskUnAttGroupDelta','segByLevelIndexGroupDelta')
    cd ../../
    
end



%% Group analysis
% Average across frequencies
segByLevelIndexGroupFreqAve = squeeze(nanmean(segByLevelIndexGroup,5));
segByLevelIndexGroupDeltaFreqAve = squeeze(nanmean(segByLevelIndexGroupDelta,5));
segByLevelFreqTagsTaskAttGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsTaskAttGroup,6));
segByLevelFreqTagsNoTaskUnAttGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroup,6));
segByLevelFreqTagsTaskAttGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsTaskAttGroupDelta,6));
segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroupDelta,6));

% Average across left/right attended
segByLevelIndexGroupFreqAttAve = squeeze(nanmean(segByLevelIndexGroupFreqAve,3));
segByLevelIndexGroupDeltaFreqAttAve = squeeze(nanmean(segByLevelIndexGroupDeltaFreqAve,3));
segByLevelFreqTagsTaskAttGroupFreqAttAve = squeeze(nanmean(segByLevelFreqTagsTaskAttGroupFreqAve,3));   % Task attended averaged across left/right
segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroupFreqAve,3));   % No task unattended averaged across left/right
segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve = squeeze(nanmean(segByLevelFreqTagsTaskAttGroupDeltaFreqAve,3));   % Task attended averaged across left/right delta
segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAve,3));   % No task unattended averaged across left/right delta

% Average across participants
segByLevelIndexGroupFreqAttPartAve = squeeze(nanmean(segByLevelIndexGroupFreqAttAve,1));
segByLevelIndexGroupDeltaFreqAttPartAve = squeeze(nanmean(segByLevelIndexGroupDeltaFreqAttAve,1));
segByLevelFreqTagsTaskAttGroupFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsTaskAttGroupFreqAttAve,1));
segByLevelFreqTagsNoTaskUnAttGroupFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve,1));
segByLevelFreqTagsTaskAttGroupDeltaFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve,1));
segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttPartAve = squeeze(nanmean(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve,1));







%% For the freq tags (pre-indexing)

%% Plot the topos for each level for task att and no task unatt for size and orientation
if plotData == 1
    plotVal = 't';
    individualColors = true;
    titleArray = {'Ori Task Attended' 'Ori No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for d = 1:2   % Orientation/Size
        counter = 0;
        h = figure('Position',[10 10 2200 1100]);
        hold on
        suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Levels - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
        for c = 1:5   % For each level
            for e = 1:3   % Harmonics
                counter = counter+2;
                cMap = colormap(jmaColors('pval'));
                if ~individualColors
                    colorIdx = 1:length(conditions);
                else
                    colorIdx = c;
                end
                switch plotVal
                    case {'p','pval','p-value'}
                        cMapMin = 0;
                        cMapMax = 1;
                        valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                    case {'t','tval','t-value'}
                        if d==1
                            % Ori attended
                            valsToPlot1 = squeeze(segByLevelFreqTagsTaskAttGroupFreqAttPartAve(1,1,c,:,e)); % ori attended ori task
                            % Ori unattended
                            valsToPlot2 = squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttPartAve(1,2,c,:,e)); % ori unattended size task
                        elseif d==2
                            % Size attended
                            valsToPlot1 = squeeze(segByLevelFreqTagsTaskAttGroupFreqAttPartAve(2,2,c,:,e)); % size attended size task
                            % Size unattended
                            valsToPlot2 = squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttPartAve(2,1,c,:,e)); % size unattended ori task
                        end
                        cMapMax = 9000;   % ceil(cMapMaxHolder(5)); 
                        cMapMin = 5000;   % floor(cMapMinHolder(5));
                    case 'mean'
                        valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                        cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                        cMapMin = 0;
                end
                % Plot attended
                thisPlot = subplot(5,6,counter-1);
                %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
                mrC.plotOnEgi(valsToPlot1(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                title(sprintf('%s%s%d%s%d%s',titleArray{d,1},' - Level ',c,' - ',e,' Harmonic'));
                
                % Plot unattended
                thisPlot = subplot(5,6,counter);
                %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
                mrC.plotOnEgi(valsToPlot2(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                title(sprintf('%s%s%d%s%d%s',titleArray{d,2},' - Level ',c,' - ',e,' Harmonic'));
            end
        end
        
        % Save the figure and then close it
%         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%         savefig(h,sprintf('%s%s%s','FreqTags_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','FreqTags_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
    end
end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsTaskAttGroupFreqAttAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            if i==1   % Ori attended while ori vs ori unattended while size 
                t1 = table(squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,1,1,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,1,3,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,1,4,j,k)),...
                    squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,1,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
                t2 = table(squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,2,1,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,2,3,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,2,4,j,k)),...
                    squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,2,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            elseif i==2   % Size while size vs size while ori
                t1 = table(squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,2,1,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,2,3,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,2,4,j,k)),...
                    squeeze(segByLevelFreqTagsTaskAttGroupFreqAttAve(:,i,2,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
                t2 = table(squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,1,1,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,1,3,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,1,4,j,k)),...
                    squeeze(segByLevelFreqTagsNoTaskUnAttGroupFreqAttAve(:,i,1,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
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
            % Task Attended
            lContrastF(1,i,j,k) = lContrast1{i,j,k}{1,4};
            lContrastP(1,i,j,k) = lContrast1{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(1,i,j,k) < .05
                sigElectrodes(1,i,k) = sigElectrodes(1,i,k)+1;
            end
            
            % No Task Unattended
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

% Plot the significance value for the linear contrast for each electrode in a topo
if plotData == 1
    plotVal = 't';
    individualColors = true;
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    condLabel = {'Orientation Task Attended' 'Orientation No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Freq Tag Linear Contrast FStat -',condLabel{d,1},' vs. ',condLabel{d,2}));
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
                        if f==1   % task att
                            valsToPlot = squeeze(lContrastF(1,d,:,e)); % plot t-stat
                        elseif f==2   % no task unatt
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
        savefig(h,sprintf('%s%s%s','FreqTags_Linear_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','FreqTags_Linear_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end










%% For the delta freq tags (pre-indexing)

% Plot the delta level values for no task unatt orientation only
if plotData == 1
    plotVal = 't';
    individualColors = true;
    titleArray = {'Orientation No Task Unattended'};
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    counter = 0;
    fig_dims = [1 1 10.5 9];   % Size of figure
    fig_size = 4; %Thickness of borders
    fig_box = 'on'; %Figure border on/off
    
    h = figure('Units','inches','Position',fig_dims);
    hold on
%     suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Delta Levels - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
    for c = 1:4   % For each level
        for e = 1:3   % Harmonics
            counter = counter+1;
            cMap = colormap(jmaColors('pval'));
            if ~individualColors
                colorIdx = 1:length(conditions);
            else
                colorIdx = 1;
            end
            switch plotVal
                case {'p','pval','p-value'}
                    cMapMin = 0;
                    cMapMax = 1;
                    valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                case {'t','tval','t-value'}
                    % Ori unattended
                    valsToPlot2 = squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttPartAve(1,2,c,:,e)); % ori unattended size task
                    cMapMax = 400;   % ceil(cMapMaxHolder(5));
                    cMapMin = 0;   % floor(cMapMinHolder(5));
                case 'mean'
                    valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                    cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                    cMapMin = 0;
            end            
            % Plot unattended
            thisPlot = subplot(4,3,counter);
            %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
            mrC.plotOnEgi(valsToPlot2(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
            
            set(gcf,'ColorMap',cMap);
            set(gca, 'Clim',[cMapMin,cMapMax]);
            title(sprintf('%s\n%s%d%s%d%s',titleArray{1},'Level ',c,' - ',e,' Harmonic'));
        end
    end
    
            % Save the figure and then close it
            cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
            savefig(h,sprintf('%s%s%s','FreqTags_Delta_NoTaskUnAtt_Ori',cats.task{d},'_Topo.fig'));
            print(h,sprintf('%s%s%s','FreqTags_Delta_NoTaskUnAtt_Ori',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
    %         close(h)
            cd ../../../
end


% % Plot the topos for each level for task att and no task unatt for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     titleArray = {'Ori Task Attended' 'Ori No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 2200 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Delta Levels - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
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
%                             valsToPlot1 = squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttPartAve(1,1,c,:,e)); % ori attended ori task
%                             % Ori unattended
%                             valsToPlot2 = squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttPartAve(1,2,c,:,e)); % ori unattended size task
%                         elseif d==2
%                             % Size attended
%                             valsToPlot1 = squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttPartAve(2,2,c,:,e)); % size attended size task
%                             % Size unattended
%                             valsToPlot2 = squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttPartAve(2,1,c,:,e)); % size unattended ori task
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
% %         % Save the figure and then close it
% %         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
% %         savefig(h,sprintf('%s%s%s','FreqTags_Delta_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
% %         print(h,sprintf('%s%s%s','FreqTags_Delta_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% % %         close(h)
% %         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            if i==1   % Ori attended while ori vs ori unattended while size 
                t1 = table(squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,1,1,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,1,3,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,1,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
                t2 = table(squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,2,1,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,2,3,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,2,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
            elseif i==2   % Size while size vs size while ori
                t1 = table(squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,2,1,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,2,3,j,k)),squeeze(segByLevelFreqTagsTaskAttGroupDeltaFreqAttAve(:,i,2,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
                t2 = table(squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,1,1,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,1,3,j,k)),squeeze(segByLevelFreqTagsNoTaskUnAttGroupDeltaFreqAttAve(:,i,1,4,j,k)),...
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
            % Task Attended
            lContrastF(1,i,j,k) = lContrast1{i,j,k}{1,4};
            lContrastP(1,i,j,k) = lContrast1{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(1,i,j,k) < .05
                sigElectrodes(1,i,k) = sigElectrodes(1,i,k)+1;
            end
            
            % No Task Unattended
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

% Plot the significance value for the linear contrast for each electrode in a topo
if plotData == 1
    plotVal = 't';
    individualColors = true;
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    condLabel = {'Orientation Task Attended' 'Orientation No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Freq Tag Linear Contrast FStat -',condLabel{d,1},' vs. ',condLabel{d,2}));
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
                        if f==1   % task att
                            valsToPlot = squeeze(lContrastF(1,d,:,e)); % plot t-stat
                        elseif f==2   % no task unatt
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
        cd ./GroupResults/Group_results_60HzLP/FinalFigures  % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','FreqTags_Delta_Linear_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','FreqTags_Delta_Linear_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end











%% For the normal indices

%% Plot the topos for each level for task att and no task unatt for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     titleArray = {'Ori Task Attended' 'Ori No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 2200 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Levels - Index - ',titleArray{d,1},' vs. ',titleArray{d,2}));
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
%                 
%                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
%                 
%                 set(gcf,'ColorMap',cMap);
%                 set(gca, 'Clim',[cMapMin,cMapMax]);
%                 title(sprintf('%s%s%d%s%d%s',cats.task{d},' Level ',c,' - ',e,' Harmonic'));
%                 
%             end
%         end
%         
%         % Save the figure and then close it
%         cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%         savefig(h,sprintf('%s%s%s','Levels_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','Levels_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
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
    condLabel = {'Ori Task Attended' 'Ori No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' - Linear Contrast FStat - ',condLabel{d,1},' vs. ',condLabel{d,2}));
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
        savefig(h,sprintf('%s%s%s%s%s','Linear_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s%s%s','Linear_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end










%% For the delta indices

% Plot the topos for each level for task att and no task unatt for size and orientation
if plotData == 1
    plotVal = 't';
    individualColors = true;
    titleArray = {'Ori Task Attended' 'Ori No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for d = 1:2   % Orientation/Size
        counter = 0;
        h = figure('Position',[10 10 2200 1100]);
        hold on
        suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Levels - Index - ',titleArray{d,1},' vs. ',titleArray{d,2}));
        for c = 1:4   % For each level
            for e = 1:3   % Harmonics
                counter = counter+1;
                thisPlot(counter) = subplot(4,3,counter);
                cMap = colormap(jmaColors('pval'));
                if ~individualColors
                    colorIdx = 1:length(conditions);
                else
                    colorIdx = c;
                end
                switch plotVal
                    case {'p','pval','p-value'}
                        cMapMin = 0;
                        cMapMax = 1;
                        valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
                    case {'t','tval','t-value'}
                        valsToPlot = squeeze(segByLevelIndexGroupDeltaFreqAttPartAve(d,c,:,e)); % plot t-stat
                        cMapMax = .15; %ceil(max(max(valsToPlot(:,colorIdx))));
                        cMapMin = -.15;
                    case 'mean'
                        valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                        cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                        cMapMin = 0;
                end
                
                mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,0,false,markerProps);
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                title(sprintf('%s%s%d%s%d%s',cats.task{d},' Level ',c,' - ',e,' Harmonic'));
                
            end
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','Levels_Delta_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','Levels_Delta_TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../
    end
end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelIndexGroupDeltaFreqAttAve,1)-1));
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
    condLabel = {'Ori Task Attended' 'Ori No Task Unattended'; 'Size Task Attended' 'Size No Task Unattended'};
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' - Linear Delta Contrast FStat - ',condLabel{d,1},' vs. ',condLabel{d,2}));
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
            text2 = sprintf('%s%.3f%s%.3f','F=(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,e));
            text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s%s%s','Linear_Delta_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s%s%s','Linear_Delta_Contrast_FStat-TaskAtt_NoTaskUnAtt_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end




