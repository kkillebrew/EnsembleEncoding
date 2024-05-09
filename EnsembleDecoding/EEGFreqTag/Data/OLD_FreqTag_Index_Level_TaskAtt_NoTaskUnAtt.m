% Script for creating index values from the OB frequency tags -
% 032219

clear all;
close all;

plotData = 1;
fakeData = 0;

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Ori','Size'};
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

%% Create index values collapsing across both att hemifeild and task type
for n=1:length(subjList)
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
%     for n=1:length(subjList)
        for i=1:4
            for j=1:size(deltaArray{i},1)
                segByLevelIndexGroupDeltaHolder(:,:,1,:,:,:,j) = segByLevelIndex(:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelIndex(:,:,deltaArray{i}(j,1),:,:,:);
                
                segByLevelFreqTagsTaskAttGroupDeltaHolder(:,:,:,1,:,:,:,j) = segByLevelFreqTagsTaskAtt(:,:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsTaskAtt(:,:,:,deltaArray{i}(j,1),:,:,:);
                
                segByLevelFreqTagsNoTaskUnAttGroupDeltaHolder(:,:,:,1,:,:,:,j) = segByLevelFreqTagsNoTaskUnAtt(:,:,:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsNoTaskUnAtt(:,:,:,deltaArray{i}(j,1),:,:,:);
            end
            
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
    save('segByLevelTask_Att_NoTask_UnAtt_Index','segByLevelFreqTagsTaskAttGroup','segByLevelFreqTagsNoTaskUnAttGroup','segByLevelIndexGroup')
    cd ../../
    
end