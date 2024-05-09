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
    load('./GroupResults/Group_results_60HzLP/segByLevelFreqTagsGroup');
end

%% Create index values collapsing across both att hemifeild and task type
% for n=1:length(subjList)
for n=16:length(subjList)
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
    
    
    %% Segment and take the FFT
    fprintf('%s\n','Segmenting...')
    
    segByLevelCounter = zeros(2,5,4);
    
    % Segment trials only based on level 
    % So, for every trial you'll have 2 OB tags for both size and
    % orientation
    for i=1:length(interp.trial)   % For every trial
        
        fprintf('%s%d\n','Trial: ',i);
        
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
        
        % For trial i, what OB freq is presented on the left/right for both
        % ori and size.
        if interp.trialinfo(i,4) == 1   % 5Hz presented left
            % Left OB's
            if interp.trialinfo(i,5) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                oriFreq(i,1) = 4;   % OB for ori on the left
                sizeFreq(i,1) = 3;  % OB for size on the left
            elseif interp.trialinfo(i,5) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                oriFreq(i,1) = 3;   % OB for ori on the left
                sizeFreq(i,1) = 4;  % OB for size on the left
            end
            % Right OB's
            if interp.trialinfo(i,6) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                oriFreq(i,2) = 2;   % OB for ori on the right
                sizeFreq(i,2) = 1;  % OB for size on the right
            elseif interp.trialinfo(i,6) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                oriFreq(i,2) = 1;   % OB for ori on the right
                sizeFreq(i,2) = 2;  % OB for size on the right
            end
        elseif interp.trialinfo(i,4) == 2   % 3Hz presented left
            % Left OB's
            if interp.trialinfo(i,5) == 1   % Ori presented at .75 Hz; Size presented at .6 Hz
                oriFreq(i,1) = 2;   % OB for ori on the left
                sizeFreq(i,1) = 1;  % OB for size on the left
            elseif interp.trialinfo(i,5) == 2   % Ori presented at .6 Hz; Size presented at .75 Hz
                oriFreq(i,1) = 1;   % OB for ori on the left
                sizeFreq(i,1) = 2;  % OB for size on the left
            end
            % Right OB's
            if interp.trialinfo(i,6) == 1   % Ori presented at 2 Hz; Size presented at .8 Hz
                oriFreq(i,2) = 4;   % OB for ori on the right
                sizeFreq(i,2) = 3;  % OB for size on the right
            elseif interp.trialinfo(i,6) == 2   % Ori presented at .8 Hz; Size presented at 2 Hz
                oriFreq(i,2) = 3;   % OB for ori on the right
                sizeFreq(i,2) = 4;  % OB for size on the right
            end
        end
        
        % Group the trial in the correct place
        segByLevelCounter(1,oriLvl(i),oriFreq(i,1)) = segByLevelCounter(1,oriLvl(i),oriFreq(i,1))+1;
        segByLevelCounter(1,oriLvl(i),oriFreq(i,2)) = segByLevelCounter(1,oriLvl(i),oriFreq(i,2))+1;
        segByLevel{1,oriLvl(i),oriFreq(i,1)}(segByLevelCounter(1,oriLvl(i),oriFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);   % Ori trials OB freq 1
        segByLevel{1,oriLvl(i),oriFreq(i,2)}(segByLevelCounter(1,oriLvl(i),oriFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);   % Ori trials OB freq 2
        
        segByLevelCounter(2,sizeLvl(i),sizeFreq(i,1)) = segByLevelCounter(2,sizeLvl(i),sizeFreq(i,1))+1;
        segByLevelCounter(2,sizeLvl(i),sizeFreq(i,2)) = segByLevelCounter(2,sizeLvl(i),sizeFreq(i,2))+1;
        segByLevel{2,sizeLvl(i),sizeFreq(i,1)}(segByLevelCounter(2,sizeLvl(i),sizeFreq(i,1)),1:256,:) = interp.trial{i}(1:256,:);   % Ori trials OB freq 1
        segByLevel{2,sizeLvl(i),sizeFreq(i,2)}(segByLevelCounter(2,sizeLvl(i),sizeFreq(i,2)),1:256,:) = interp.trial{i}(1:256,:);   % Ori trials OB freq 2
        
        % Clear out interp for faster run times
        interp.trial{i} = {};
        
    end
    
    %% Average and FFT
    fprintf('%s\n','Average and FFT...')
    for i=1:size(segByLevel,1)
        for j=1:size(segByLevel,2)
            for k=1:size(segByLevel,3)
                
                % Average the trials together in each condition (feature, level, frequency)
                segByLevelAve(i,j,k,:,:) = squeeze(mean(segByLevel{i,j,k},1));
                
                % Clear out the trials in segByLevel for faster running
                segByLevel{i,j,k} = [];
                
                % Now take the FFT
                for l=1:size(segByLevelAve,4)   % Electrodes
                    segByLevelFFT(i,j,k,l,:,:) = abs(fft(segByLevelAve(i,j,k,l,:)));
                end
                
            end
        end
    end

    clear segByLevel segByLevelAve segByLevelCounter oriFreq sizeFreq oriLvl sizeLvl
    
    % Only pick off the relevant frequencies so we don't have to store a
    % gigantic file
    for i=1:4
        segByLevelFreqTags(:,:,i,:,:) =  segByLevelFFT(:,:,i,:,20*stimRateOB(i)+1:20*stimRateOB(i):3*20*stimRateOB(i)+1);
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
                segByLevelFreqTagsGroupDeltaHolder(:,1,:,:,:,j) = segByLevelFreqTags(:,deltaArray{i}(j,2),:,:,:) -...
                    segByLevelFreqTags(:,deltaArray{i}(j,1),:,:,:);
            end
            
            segByLevelFreqTagsGroupDelta(n,:,i,:,:,:,:) = squeeze(nanmean(segByLevelFreqTagsGroupDeltaHolder,6));
             
            clear segByLevelFreqTagsOriGroupDeltaHolder
        end
%     end
    
    % Store in participant array
    segByLevelFreqTagsGroup(n,:,:,:,:,:) = segByLevelFreqTags;
    
    clear segByLevelFFT segByLevelFreqTags
    
    % Save segByLevelFreqTagsGroup after each subject
    cd ../GroupResults/Group_results_60HzLP
    save('segByLevelFreqTagsGroup','segByLevelFreqTagsGroup')
    cd ../../
    
end

%% Group analysis
% Average across frequencies
segByLevelFreqTagsGroupFreqAve = squeeze(nanmean(segByLevelFreqTagsGroup,4));
segByLevelFreqTagsGroupDeltaFreqAve = squeeze(nanmean(segByLevelFreqTagsGroup,4));

% Average across participants
segByLevelFreqTagsGroupFreqPartAve = squeeze(nanmean(segByLevelFreqTagsGroupFreqAve,1));
segByLevelFreqTagsGroupDeltaFreqPartAve = squeeze(nanmean(segByLevelFreqTagsGroupDeltaFreqAve,1));

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
%                         valsToPlot = squeeze(segByLevelFreqTagsGroupFreqPartAve(d,c,:,e)); % plot t-stat
%                         cMapMax = 2500; %ceil(max(max(valsToPlot(:,colorIdx))));
%                         cMapMin = 0;
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
%         savefig(h,sprintf('%s%s%s','Levels_Only_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','Levels_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsGroupFreqAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            t = table(squeeze(segByLevelFreqTagsGroupFreqAve(:,i,1,j,k)),squeeze(segByLevelFreqTagsGroupFreqAve(:,i,2,j,k)),...
                squeeze(segByLevelFreqTagsGroupFreqAve(:,i,3,j,k)),squeeze(segByLevelFreqTagsGroupFreqAve(:,i,4,j,k)),...
                squeeze(segByLevelFreqTagsGroupFreqAve(:,i,5,j,k)),'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
            
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
            title(sprintf('%s%s%d%s',cats.task{d},' Feature Levels - ',e,' Harmonic'));
            
            % Plot the stats
            text1 = sprintf('%s','o : significant electrodes at a threshold of');
            text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
            text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,e));
            text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
        end
        
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','Linear_Contrast_FStat-Levels_Only_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','Linear_Contrast_FStat-Levels_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
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
%         suptitle(sprintf('%s%s\n',cats.task{d},' - Delta Levels Only'));
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
%                         valsToPlot = squeeze(segByLevelFreqTagsGroupDeltaFreqPartAve(d,c,:,e)); % plot t-stat
%                         cMapMax = 3500; %ceil(max(max(valsToPlot(:,colorIdx))));
%                         cMapMin = 0;
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
%         savefig(h,sprintf('%s%s%s','Levels_Delta_Only_',cats.task{d},'_Topo.fig'));
%         print(h,sprintf('%s%s%s','Levels_Delta_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
% %         close(h)
%         cd ../../
%     end
% end

%% Take the linear contrast
% should be: segByLevelFreqTagsGroupFreqAve(11,2,5,256,3)
sigElectrodes = zeros(2,3);
% TStat for an alpha=0.05; w/ 20 subjects
alphaTStat = abs(finv(.95,1,size(segByLevelFreqTagsGroupFreqAve,1)-1));
for i=1:2   % For ori/size
    for j=1:256   % For all electrodes
        for k=1:3   % Harmonics
            
            % First make a table of each subjs freq tag for each level
            t = table(squeeze(segByLevelFreqTagsGroupDeltaFreqAve(:,i,1,j,k)),squeeze(segByLevelFreqTagsGroupDeltaFreqAve(:,i,2,j,k)),...
                squeeze(segByLevelFreqTagsGroupDeltaFreqAve(:,i,3,j,k)),squeeze(segByLevelFreqTagsGroupDeltaFreqAve(:,i,4,j,k)),...
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
%         suptitle(sprintf('%s%s%s%s\n',cats.task{d},' - Delta Linear Contrast FStat - Levels Only'));
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
            title(sprintf('%s%s%d%s',cats.task{d},' Delta Levels - ',e,' Harmonic'));
            
            % Plot the stats
            text1 = sprintf('%s','o : significant electrodes at a threshold of');
            text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
            text2 = sprintf('%s%.3f%s%.3f','F(1,19)=',alphaTStat,'; p=0.05; q=',qVals(d,e));
            text(0,-18,text2,'FontSize',12,'HorizontalAlignment','center');
        end
        
        
        % Save the figure and then close it
        cd ./GroupResults/Group_results_60HzLP/FinalFigures   % From the data folder CD into group results
        savefig(h,sprintf('%s%s%s','Linear_Delta_Contrast_FStat-Levels_Only_',cats.task{d},'_Topo.fig'));
        print(h,sprintf('%s%s%s','Linear_Delta_Contrast_FStat-Levels_Only_',cats.task{d},'_Topo.tif'),'-dtiffn');   % Save .tif
%         close(h)
        cd ../../../
    end
end






