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

dataOut = '/Volumes/PromisePegasus/Kyle/Dissertation/EEG Freq Tag/Data/GroupResults/GroupResults_60HzLP/';

% If you are starting on new subjects, load in the group data files to
% append to them.
if newSubjs == 1
    load('./GroupResults/Group_results_60HzLP/segByLevelTaskIndex');
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
    
    segByLevelCounterOri = zeros(2,5,4);
    segByLevelCounterSize = zeros(2,5,4);
    
    % Segment trials based on lvl and attended hemifeild
    % So, for every trial you'll have 2 OB tags for both size and
    % orientation
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
        
        % For trial i, what task is being done and what 
        % What is the ori and size FTs when doing the ori task (regardless
        % of attended hemifeild)
        if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=10) || (interp.trialinfo(i,3)>=11 && interp.trialinfo(i,3)<=20)  % Ori task
            if interp.trialinfo(i,4) == 1   % 5Hz presented left
                % Left OB's
                if interp.trialinfo(i,5) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                    oriFreqOri(i,1) = 4;   % OB for ori on the left
                    sizeFreqOri(i,1) = 3;  % OB for size on the left
                elseif interp.trialinfo(i,5) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                    oriFreqOri(i,1) = 3;   % OB for ori on the left
                    sizeFreqOri(i,1) = 4;  % OB for size on the left
                end
                % Right OB's
                if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                    oriFreqOri(i,2) = 2;   % OB for ori on the right
                    sizeFreqOri(i,2) = 1;  % OB for size on the right
                elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                    oriFreqOri(i,2) = 1;   % OB for ori on the right
                    sizeFreqOri(i,2) = 2;  % OB for size on the right
                end
            elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
                % Left OB's
                if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                    oriFreqOri(i,1) = 2;   % OB for ori on the left
                    sizeFreqOri(i,1) = 1;  % OB for size on the left
                elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                    oriFreqOri(i,1) = 1;   % OB for ori on the left
                    sizeFreqOri(i,1) = 2;  % OB for size on the left
                end
                % Right OB's
                if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                    oriFreqOri(i,2) = 4;   % OB for ori on the right
                    sizeFreqOri(i,2) = 3;  % OB for size on the right
                elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                    oriFreqOri(i,2) = 3;   % OB for ori on the right
                    sizeFreqOri(i,2) = 4;  % OB for size on the right
                end
            end
            
            % Group the trial in the correct place
            % Ori task
            segByLevelCounterOri(1,oriLvl(i),oriFreqOri(i,1)) = segByLevelCounterOri(1,oriLvl(i),oriFreqOri(i,1))+1;   % Ori left tag while ori task
            segByLevelCounterOri(1,oriLvl(i),oriFreqOri(i,2)) = segByLevelCounterOri(1,oriLvl(i),oriFreqOri(i,2))+1;   % Ori right rag while ori task
            segByLevelCounterOri(2,oriLvl(i),sizeFreqOri(i,1)) = segByLevelCounterOri(2,oriLvl(i),sizeFreqOri(i,1))+1;   % Size left tag while ori task
            segByLevelCounterOri(2,oriLvl(i),sizeFreqOri(i,2)) = segByLevelCounterOri(2,oriLvl(i),sizeFreqOri(i,2))+1;   % Size right tag while ori task
            
            segByLevelOri{1,oriLvl(i),oriFreqOri(i,1)}(segByLevelCounterOri(1,oriLvl(i),oriFreqOri(i,1)),1:256,:) = interp.trial{i}(1:256,:);
            segByLevelOri{1,oriLvl(i),oriFreqOri(i,2)}(segByLevelCounterOri(1,oriLvl(i),oriFreqOri(i,2)),1:256,:) = interp.trial{i}(1:256,:);
            segByLevelOri{2,oriLvl(i),sizeFreqOri(i,1)}(segByLevelCounterOri(2,oriLvl(i),sizeFreqOri(i,1)),1:256,:) = interp.trial{i}(1:256,:);
            segByLevelOri{2,oriLvl(i),sizeFreqOri(i,2)}(segByLevelCounterOri(2,oriLvl(i),sizeFreqOri(i,2)),1:256,:) = interp.trial{i}(1:256,:);
            
        elseif (interp.trialinfo(i,3)>=1 && interp.trialinfo(i,3)<=10) || (interp.trialinfo(i,2)>=11 && interp.trialinfo(i,2)<=20)  % Size task
            if interp.trialinfo(i,4) == 1   % 5Hz presented left
                % Left OB's
                if interp.trialinfo(i,5) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                    oriFreqSize(i,1) = 4;   % OB for ori on the left
                    sizeFreqSize(i,1) = 3;  % OB for size on the left
                elseif interp.trialinfo(i,5) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                    oriFreqSize(i,1) = 3;   % OB for ori on the left
                    sizeFreqSize(i,1) = 4;  % OB for size on the left
                end
                % Right OB's
                if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                    oriFreqSize(i,2) = 2;   % OB for ori on the right
                    sizeFreqSize(i,2) = 1;  % OB for size on the right
                elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                    oriFreqSize(i,2) = 1;   % OB for ori on the right
                    sizeFreqSize(i,2) = 2;  % OB for size on the right
                end
            elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
                % Left OB's
                if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                    oriFreqSize(i,1) = 2;   % OB for ori on the left
                    sizeFreqSize(i,1) = 1;  % OB for size on the left
                elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                    oriFreqSize(i,1) = 1;   % OB for ori on the left
                    sizeFreqSize(i,1) = 2;  % OB for size on the left
                end
                % Right OB's
                if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                    oriFreqSize(i,2) = 4;   % OB for ori on the right
                    sizeFreqSize(i,2) = 3;  % OB for size on the right
                elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                    oriFreqSize(i,2) = 3;   % OB for ori on the right
                    sizeFreqSize(i,2) = 4;  % OB for size on the right
                end
            end

            % Group the trial in the correct place            
            % Size task
            segByLevelCounterSize(1,oriLvl(i),sizeFreqSize(i,1)) = segByLevelCounterSize(1,oriLvl(i),sizeFreqSize(i,1))+1;   % Size left tag while size task
            segByLevelCounterSize(1,oriLvl(i),sizeFreqSize(i,2)) = segByLevelCounterSize(1,oriLvl(i),sizeFreqSize(i,2))+1;   % Size right rag while size task
            segByLevelCounterSize(2,oriLvl(i),oriFreqSize(i,1)) = segByLevelCounterSize(2,oriLvl(i),oriFreqSize(i,1))+1;   % Ori left tag while size task
            segByLevelCounterSize(2,oriLvl(i),oriFreqSize(i,2)) = segByLevelCounterSize(2,oriLvl(i),oriFreqSize(i,2))+1;   % Ori right tag while size task
            
            segByLevelSize{1,oriLvl(i),sizeFreqSize(i,1)}(segByLevelCounterSize(1,oriLvl(i),sizeFreqSize(i,1)),1:256,:) = interp.trial{i}(1:256,:);
            segByLevelSize{1,oriLvl(i),sizeFreqSize(i,2)}(segByLevelCounterSize(1,oriLvl(i),sizeFreqSize(i,2)),1:256,:) = interp.trial{i}(1:256,:);
            segByLevelSize{2,oriLvl(i),oriFreqSize(i,1)}(segByLevelCounterSize(2,oriLvl(i),oriFreqSize(i,1)),1:256,:) = interp.trial{i}(1:256,:);
            segByLevelSize{2,oriLvl(i),oriFreqSize(i,2)}(segByLevelCounterSize(2,oriLvl(i),oriFreqSize(i,2)),1:256,:) = interp.trial{i}(1:256,:);
            
        end 
    end
    
    %% Average and FFT
    fprintf('%s\n','Average and FFT...')
    for i=1:size(segByLevelOri,1)
        for j=1:size(segByLevelOri,2)
            for k=1:size(segByLevelOri,3)
                
                % Average the trials together in each condition (feature, level, frequency)
                segByLevelAveOri(i,j,k,:,:) = squeeze(mean(segByLevelOri{i,j,k},1));
                segByLevelAveSize(i,j,k,:,:) = squeeze(mean(segByLevelSize{i,j,k},1));
                
                % Clear out the trials in segByLevel for faster running
                segByLevelOri{i,j,k} = [];
                segByLevelSize{i,j,k} = [];
                
                % Now take the FFT
                for l=1:size(segByLevelAveOri,4)   % Electrodes
                    segByLevelOriFFT(i,j,k,l,:,:) = abs(fft(segByLevelAveOri(i,j,k,l,:)));
                    segByLevelSizeFFT(i,j,k,l,:,:) = abs(fft(segByLevelAveSize(i,j,k,l,:)));
                end
                
            end
        end
    end

    clear segByLevelOri segByLevelSize segByLevelAveOri segByLevelAveSize segByLevelCounterOri segByLevelCounterSize oriFreqOri oriFreqSize sizeFreqOri sizeFreqSize
    
    % Only pick off the relevant frequencies so we don't have to store a
    % gigantic file
    for i=1:4
        segByLevelFreqTagsOri(:,:,i,:,:) =  segByLevelOriFFT(:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
        segByLevelFreqTagsSize(:,:,i,:,:) =  segByLevelSizeFFT(:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
    end
    
    
    
    %% Create the index
    for j=1:5   % Level
        for k=1:4   % Frequency
            for l=1:3   % Harmonic
                segByLevelIndex(1,j,k,:,l) = (segByLevelFreqTagsOri(1,j,k,:,l) - segByLevelFreqTagsSize(2,j,k,:,l)) ./...
                    (segByLevelFreqTagsOri(1,j,k,:,l) + segByLevelFreqTagsSize(2,j,k,:,l));
                
                segByLevelIndex(2,j,k,:,l) = (segByLevelFreqTagsSize(1,j,k,:,l) - segByLevelFreqTagsOri(2,j,k,:,l)) ./...
                    (segByLevelFreqTagsSize(1,j,k,:,l) + segByLevelFreqTagsOri(2,j,k,:,l));
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
                segByLevelIndexGroupDeltaHolder(:,1,:,:,:,j) = segByLevelIndex(:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelIndex(:,deltaArray{i}(j,1),:,:,:);
                
                % For task relevant freq tags
                segByLevelFreqTagsOriGroupDeltaHolder(:,1,:,:,:,j) = segByLevelFreqTagsOri(:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsOri(:,deltaArray{i}(j,1),:,:,:); 
                
                % For task irrelevant freq tags
                segByLevelFreqTagsSizeGroupDeltaHolder(:,1,:,:,:,j) = segByLevelFreqTagsSize(:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTagsSize(:,deltaArray{i}(j,1),:,:,:); 
            end
            
            segByLevelIndexGroupDelta(n,:,i,:,:,:,:) = squeeze(nanmean(segByLevelIndexGroupDeltaHolder,6));
            segByLevelFreqTagsOriGroupDelta(n,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsOriGroupDeltaHolder,6));
            segByLevelFreqTagsSizeGroupDelta(n,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsSizeGroupDeltaHolder,6));
             
            clear segByLevelFreqTagsOriGroupDeltaHolder segByLevelFreqTagsOriGroupDeltaHolder segByLevelFreqTagsSizeGroupDeltaHolder 
        end
%     end

    %% Sort and save
    % Store in participant array
    segByLevelFreqTagsOriGroup(n,:,:,:,:,:) = segByLevelFreqTagsOri;
    segByLevelFreqTagsSizeGroup(n,:,:,:,:,:) = segByLevelFreqTagsSize;
    segByLevelIndexGroup(n,:,:,:,:,:) = segByLevelIndex;
    
    clear segByLevelOriFFT segByLevelSizeFFT segByLevelFreqTagsOri segByLevelFreqTagsSize segByLevelIndex
    
    % Save segByLevelFreqTagsGroup after each subject
    cd(dataOut)
    save('segByLevelTaskIndex','segByLevelFreqTagsOriGroup','segByLevelFreqTagsSizeGroup','segByLevelIndexGroup',...
        'segByLevelFreqTagsOriGroupDelta','segByLevelFreqTagsSizeGroupDelta','segByLevelIndexGroupDelta')
    cd('../../../../../../../clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/')
    
end

%% Group analysis
% Average across frequencies
segByLevelIndexGroupFreqAve = squeeze(nanmean(segByLevelIndexGroup,4));
segByLevelIndexGroupDeltaFreqAve = squeeze(nanmean(segByLevelIndexGroupDelta,4));
segByLevelFreqTagsOriGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsOriGroup,4));
segByLevelFreqTagsSizeGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsSizeGroup,4));
segByLevelFreqTagsOriGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsOriGroupDelta,4));
segByLevelFreqTagsSizeGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsSizeGroupDelta,4));

% Average across participants
segByLevelIndexGroupFreqPartAve = squeeze(nanmean(segByLevelIndexGroupFreqAve,1));
segByLevelIndexGroupDeltaFreqPartAve = squeeze(nanmean(segByLevelIndexGroupDeltaFreqAve,1));
segByLevelFreqTagsOriGroupFreqPartAve = squeeze(nanmean(segByLevelFreqTagsOriGroupFreqAve,1));
segByLevelFreqTagsSizeGroupFreqPartAve = squeeze(nanmean(segByLevelFreqTagsSizeGroupFreqAve,1));
segByLevelFreqTagsOriGroupDeltaFreqPartAve = squeeze(nanmean(segByLevelFreqTagsOriGroupDeltaFreqAve,1));
segByLevelFreqTagsSizeGroupDeltaFreqPartAve = squeeze(nanmean(segByLevelFreqTagsSizeGroupDeltaFreqAve,1));





%% For the freq tags (pre-indexing)

%% Plot the topos for each level for att and unatt for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     titleArray = {'Ori While Ori' 'Ori While Size'; 'Size While Size' 'Size While Ori'};
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 2200 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Levels - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
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
%                             % Ori
%                             valsToPlot1 = squeeze(segByLevelFreqTagsOriGroupFreqPartAve(d,c,:,e)); % plot t-stat
%                             % Size
%                             valsToPlot2 = squeeze(segByLevelFreqTagsSizeGroupFreqPartAve(3-d,c,:,e)); % plot t-stat
%                         elseif d==2
%                             % Ori
%                             valsToPlot1 = squeeze(segByLevelFreqTagsSizeGroupFreqPartAve(d,c,:,e)); % plot t-stat
%                             % Size
%                             valsToPlot2 = squeeze(segByLevelFreqTagsOriGroupFreqPartAve(3-d,c,:,e)); % plot t-stat
%                         end
%                         cMapMax = 5000;   % ceil(cMapMaxHolder(5)); 
%                         cMapMin = 1000;   % floor(cMapMinHolder(5));
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
%         savefig(h,sprintf('%s%s%s','FreqTags_Task_Only_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','FreqTags_Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsOriGroupFreqAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            if i==1   % Ori while ori vs ori while size
                t1 = table(squeeze(segByLevelFreqTagsOriGroupFreqAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAve(:,1,4,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAve(:,1,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
                t2 = table(squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,2,4,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,2,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            elseif i==2   % Size while size vs size while ori
                t1 = table(squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,1,4,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupFreqAve(:,1,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
                t2 = table(squeeze(segByLevelFreqTagsOriGroupFreqAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsOriGroupFreqAve(:,2,4,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupFreqAve(:,2,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            end
            
            % Within subject labels
            within = table([1 2 3 4 5]');
            
            % Fit a repeated measures model
            rm1 = fitrm(t1,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            rm2 = fitrm(t2,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            
            % Perform the linear contrast
            lContrast1{i,j,k} = ranova(rm1,'WithinModel',[-2 -1 0 1 2]');
            lContrast2{i,j,k} = ranova(rm2,'WithinModel',[-2 -1 0 1 2]');
            
            % Grab the Fstat and pvalue
            lContrastF(1,i,j,k) = lContrast1{i,j,k}{1,4};
            lContrastP(1,i,j,k) = lContrast1{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(1,i,j,k) < .05
                sigElectrodes(1,i,k) = sigElectrodes(1,i,k)+1;
            end
            
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
for i=1:size(sigElectrodes,1)   % No task/task
    for j=1:size(sigElectrodes,2)   % Ori/Size
        for k=1:size(sigElectrodes,3)   % Harmonics
            qVals(i,j,k) = expectedFA/sigElectrodes(i,j,k);
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
    condLabel = {'Orientation Task' 'Orientation No Task'; 'Size Task' 'Size No Task'};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s\n',cats.task{d},' Freq Tag Linear Contrast FStat - Task Only'));
        for e = 1:3   % Harmonics
            for f=1:2   % ori task/size task
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
                        if d==1   % Ori
                            valsToPlot = squeeze(lContrastF(f,d,:,e)); % plot t-stat
                        elseif d==2   % Size
                            valsToPlot = squeeze(lContrastF(3-f,d,:,e)); % plot t-stat
                        end
                        cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                        cMapMin = 0;
                    case 'mean'
                        valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                        cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                        cMapMin = 0;
                end
                %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
                if d==1   % Ori
                    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(f,d,:,e))<.05),false,markerProps);
                elseif d==2   % Size
                   mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(3-f,d,:,e))<.05),false,markerProps); 
                end
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                title(sprintf('%s%s%d%s',condLabel{d,f},' - ',e,' Harmonic'));

                % Plot the stats
                text1 = sprintf('%s','o : significant electrodes at a threshold of');
                text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
                if d==1
                    text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(f,d,e));
                elseif d==2
                    text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(3-f,d,e));
                end
                text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
                
            end
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','FreqTags_Linear_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','FreqTags_Linear_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end








%% For the delta freq tags (pre-indexing)

%% Plot the topos for each level for att and unatt for size and orientation
% if plotData == 1
%     plotVal = 't';
%     individualColors = true;
%     titleArray = {'Ori While Ori' 'Ori While Size'; 'Size While Size' 'Size While Ori'};
%     markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
%     for d = 1:2   % Orientation/Size
%         counter = 0;
%         h = figure('Position',[10 10 2200 1100]);
%         hold on
%         suptitle(sprintf('%s%s%s%s%s\n',cats.task{d},' Levels - Freq Tags - ',titleArray{d,1},' vs. ',titleArray{d,2}));
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
%                             % Ori
%                             valsToPlot1 = squeeze(segByLevelFreqTagsOriGroupDeltaFreqPartAve(d,c,:,e)); % plot t-stat
%                             % Size
%                             valsToPlot2 = squeeze(segByLevelFreqTagsSizeGroupDeltaFreqPartAve(3-d,c,:,e)); % plot t-stat
%                         elseif d==2
%                             % Ori
%                             valsToPlot1 = squeeze(segByLevelFreqTagsSizeGroupDeltaFreqPartAve(d,c,:,e)); % plot t-stat
%                             % Size
%                             valsToPlot2 = squeeze(segByLevelFreqTagsOriGroupDeltaFreqPartAve(3-d,c,:,e)); % plot t-stat
%                         end
%                         cMapMax = 250;   % ceil(cMapMaxHolder(5)); 
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
%         savefig(h,sprintf('%s%s%s','FreqTags_Delta_Task_Only_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','FreqTags_Delta_Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsOriGroupFreqAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            if i==1   % Ori while ori vs ori while size
                t1 = table(squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,1,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
                t2 = table(squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,2,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
            elseif i==2   % Size while size vs size while ori
                t1 = table(squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,1,1,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,1,2,j,k)),...
                    squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,1,3,j,k)),squeeze(segByLevelFreqTagsSizeGroupDeltaFreqAve(:,1,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
                t2 = table(squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,2,1,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,2,2,j,k)),...
                    squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,2,3,j,k)),squeeze(segByLevelFreqTagsOriGroupDeltaFreqAve(:,2,4,j,k)),...
                    'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
            end
            
            % Within subject labels
            within = table([1 2 3 4]');
            
            % Fit a repeated measures model
            rm1 = fitrm(t1,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            rm2 = fitrm(t2,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
            
            % Perform the linear contrast
            lContrast1{i,j,k} = ranova(rm1,'WithinModel',[-1.5 -.5 .5 1.5]');
            lContrast2{i,j,k} = ranova(rm2,'WithinModel',[-1.5 -.5 .5 1.5]');
            
            % Grab the Fstat and pvalue
            lContrastF(1,i,j,k) = lContrast1{i,j,k}{1,4};
            lContrastP(1,i,j,k) = lContrast1{i,j,k}{1,5};
            
            % Count sig electrodes
            if lContrastP(1,i,j,k) < .05
                sigElectrodes(1,i,k) = sigElectrodes(1,i,k)+1;
            end
            
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
for i=1:size(sigElectrodes,1)   % No task/task
    for j=1:size(sigElectrodes,2)   % Ori/Size
        for k=1:size(sigElectrodes,3)   % Harmonics
            qVals(i,j,k) = expectedFA/sigElectrodes(i,j,k);
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
    condLabel = {'Orientation Task' 'Orientation No Task'; 'Size Task' 'Size No Task'};
    for d = 1:2   % Orientation/Size
        counter = 0;
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        h = figure('Units','inches','Position',fig_dims);
        hold on
%         suptitle(sprintf('%s%s\n',cats.task{d},' Freq Tag Delta Linear Contrast FStat - Task Only'));
        for e = 1:3   % Harmonics
            for f=1:2   % ori task/size task
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
                        if d==1   % Ori
                            valsToPlot = squeeze(lContrastF(f,d,:,e)); % plot t-stat
                        elseif d==2   % Size
                            valsToPlot = squeeze(lContrastF(3-f,d,:,e)); % plot t-stat
                        end
                        cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                        cMapMin = 0;
                    case 'mean'
                        valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                        cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                        cMapMin = 0;
                end
                %                 mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(i)),false,markerProps);
                if d==1   % If ori
                    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(f,d,:,e))<.05),false,markerProps);
                elseif d==2   % If size
                    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(squeeze(lContrastP(3-f,d,:,e))<.05),false,markerProps);
                end
                
                set(gcf,'ColorMap',cMap);
                set(gca, 'Clim',[cMapMin,cMapMax]);
                title(sprintf('%s%s%d%s',condLabel{d,f},' - ',e,' Harmonic'));

                % Plot the stats
                text1 = sprintf('%s','o : significant electrodes at a threshold of');
                text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
                if d==1
                    text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(f,d,e));
                elseif d==2
                    text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(3-f,d,e));
                end
                text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
            end
        end
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','FreqTags_Delta_Linear_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','FreqTags_Delta_Linear_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
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
%         suptitle(sprintf('%s%s\n',cats.task{d},' Levels - Task Only'));
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
%                         valsToPlot = squeeze(segByLevelIndexGroupFreqPartAve(d,c,:,e)); % plot t-stat
%                         cMapMax = .2; %ceil(max(max(valsToPlot(:,colorIdx))));
%                         cMapMin = -.2;
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
%         savefig(h,sprintf('%s%s%s','Levels_Task_Only_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','Levels_Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelIndexGroupFreqAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            t = table(squeeze(segByLevelIndexGroupFreqAve(:,i,1,j,k)),squeeze(segByLevelIndexGroupFreqAve(:,i,2,j,k)),...
                squeeze(segByLevelIndexGroupFreqAve(:,i,3,j,k)),squeeze(segByLevelIndexGroupFreqAve(:,i,4,j,k)),...
                squeeze(segByLevelIndexGroupFreqAve(:,i,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            
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
    for k=1:size(sigElectrodes,3)   % Harmonics
        qVals(i,k) = expectedFA/sigElectrodes(i,k);
        if qVals(i,k) == inf
            qVals(i,k) = NaN;
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
%         suptitle(sprintf('%s%s\n',cats.task{d},' Linear Contrast FStat - Task Only'));
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
        savefig(h,sprintf('%s%s%s','Linear_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','Linear_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
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
%         suptitle(sprintf('%s%s\n',cats.task{d},' Delta Levels - Task Only'));
%         for c = 1:4   % For each level
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
%                         valsToPlot = squeeze(segByLevelIndexGroupDeltaFreqPartAve(d,c,:,e)); % plot t-stat
%                         cMapMax = .2; %ceil(max(max(valsToPlot(:,colorIdx))));
%                         cMapMin = -.2;
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
%         savefig(h,sprintf('%s%s%s','Levels_Delta_Task_Only_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','Levels_Delta_Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelIndexGroupFreqAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            t = table(squeeze(segByLevelIndexGroupFreqAve(:,i,1,j,k)),squeeze(segByLevelIndexGroupFreqAve(:,i,2,j,k)),...
                squeeze(segByLevelIndexGroupFreqAve(:,i,3,j,k)),squeeze(segByLevelIndexGroupFreqAve(:,i,4,j,k)),...
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
    for k=1:size(sigElectrodes,3)   % Harmonics
        qVals(i,k) = expectedFA/sigElectrodes(i,k);
        if qVals(i,k) == inf
            qVals(i,k) = NaN;
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
%         suptitle(sprintf('%s%s\n',cats.task{d},' Delta Linear Contrast FStat - Task Only'));
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
        savefig(h,sprintf('%s%s%s','Linear_Delta_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','Linear_Delta_Contrast_FStat-Task_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end


