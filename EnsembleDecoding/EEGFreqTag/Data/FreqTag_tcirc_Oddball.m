% Loads in the frequency tagging data and performs a t-circ analysis on 40
% conditions: 3Hz/5Hz, left/right attend, ori/size, 1/2/3/4/5 lvls.

clear all;
close all;

fakeData=0;
plotData=1;
alphaVal = .05;
newSubjs = 0;

codeFolder = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/';
addpath(genpath(sprintf('%s/git/mrC',codeFolder)));
addpath(genpath(sprintf('%s/T_Circ_Analysis',codeFolder)));

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Ori','Size'};
cats.attend = {'Left','Right'};

%% Load in behavioral subject data
if fakeData == 0
    cd ../../
    ensDataStructBehav = ensLoadData('FreqTagBehav','All');
    cd ./'EEG Freq Tag'/Data/
    
    subjList = ensDataStructBehav.subjid;
elseif fakeData == 1
    % Make subject list equal to FakeData
    cd ../../
    ensDataStructBehav = ensLoadData('FreqTagBehavFake');
    cd ./'EEG Freq Tag'/Data/
    
    subjList = ensDataStructBehav.subjid;
end

% What stim rates should we pick off
stimRate(1,1) = 3;   % BL frequencies
stimRate(1,2) = 5;
stimRate(2,1) = .6;   % OB frequencies
stimRate(2,2) = .75;
stimRate(3,1) = .8;
stimRate(3,2) = 2;

stimRateConvert = round(stimRate/0.05);

% If you are starting on new subjects, load in the group data files to
% append to them.
if newSubjs == 1
    load('./GroupResults/Group_results_60HzLP/numSigElecs');
end


%% Start t-circ analysis
% for n=17:length(subjList)
for n=1:length(subjList)
    
    %% Load in the freqeuncy tag data
    
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
    
    cd ../../   % CD back into data folder
    
    % Clear out the loading variables
    clear combInterp interptrial
    
    % Store the trials in a normal array
    for i=1:length(interp.trial)
       interptrial(i,:,:) = interp.trial{i};
       interp.trial{i} = [];
    end
    
    interp.Trial = [];
    
    %% Segment
    
    fprintf('%s\n','Segmenting...')
    
    % First re-organize the info array using 1-4
    OBholder = zeros(4,2,2,length(interp.trial));
    CRs = [1 2];   % 3/5 Hz
    OBs(1,:) = [.6 .75];   % .6/.75 Hz
    OBs(2,:) = [.8 2];   % .8/2 Hz
    attTaskChoose = [1 25; 26 50; 51 75; 76 100];
    for p=1:4   % ori left/ori right/size left/size right
        for i=1:2   % carrier
            for j=1:2   % oddball
                OBholder(p,i,j,:) = (interp.trialinfo(:,1) >= attTaskChoose(p,1)) & (interp.trialinfo(:,1) <= attTaskChoose(p,2)) &...   % task/att
                    (interp.trialinfo(:,4) == CRs(i)) &...   % Carrier freq
                    (interp.trialinfo(:,4+1+mod(p,2))==j);   % OB freq (depends on attended hemifield, which is determined by 4+1+mod(p,2), which is either 1/0)
            end
        end
    end
    
    
    
    %% Do the tcirc analysis for every condition, electrode, and participant
    
    fprintf('%s\n','Performing TCirc...')
    for i=1:size(OBholder,1)   % ori left/ori right/size left/size right
        for j=1:size(OBholder,2)   % carrier
            for k=1:size(OBholder,3)   % oddball
                
                clear trialArrayHolder trialArrayHolderFFT
                
                % Store the trials in a new array
                clear holderIdx
                holderIdx = squeeze(OBholder(i,j,k,:));
                trialArrayHolder = interptrial(find(holderIdx),1:256,:);
                
                % Take the fft of each trial (w/ abs valuing)
                for p=1:size(trialArrayHolder,1)   % Trial
                    for m=1:size(trialArrayHolder,2)   % Electrode
                        trialArrayHolderFFT(p,m,:) = fft(trialArrayHolder(p,m,:));
                    end
                end
                
                % Grab the freqs you want to send to the tcirc
                tCircFreqArray = trialArrayHolderFFT(:,:,stimRateConvert(k+1,j)+1);
                
                % Outputs:
                % Z_est- Mean fourier
                % confidence_radii- N-length array of real numbers representing the 2D confidence circle radius  for each frequency
                % p- M-length array of significance values for each frequency
                % t2circ- M-length array of t2circ for each frequency
                for m=1:size(tCircFreqArray,2)  
                    [tCirc_Z_est(i,j,k,m) tCirc_confidence_radii(i,j,k,m) tCirc_p(i,j,k,m) tCirc_t2circ(i,j,k,m)] =...
                        t2circ_1tag(tCircFreqArray(:,m),alphaVal);
                end
            end
        end
    end
    
    
    
    
    
    %% Plot
    if plotData
        
        %         % If you're loading in data instead of running full script comment
        %         subjList = {'KK','ZZ','TL','TW','KE','CS','HA','TS','RM','DH','RR','KL'};
        %         alphaVal = .01;
        %
        %         for n=1:length(subjList)-1
        %
        %             % cd into participant data folder
        %             cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_60HzLP/'))
        %             load('tCirc_results');
        %             cd ../
        %
        
        % cd to figure directory to save the figs
        cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_60HzLP'))
        
        figDir = './tCirc_Figs/';
        if exist(figDir,'file')
        else
            mkdir(figDir);
        end
        cd(sprintf('%s','./',figDir))
        
        % Plot the t-circs
        close all;
        plotVal = 't';
        individualColors = true;
        condChoose = [1 1;1 2;2 1;2 2];
        featureAttChoose = [1 2;3 4];
        graphTitle{1,:,:} = {'0.6 Hz Left','0.6 Hz right';'0.75 Hz Left','0.75 Hz Right'};
        graphTitle{2,:,:} = {'0.8 Hz Left','0.8 Hz right';'2 Hz Left','2 Hz Right'};
        taskTitle = {'Orientation' 'Size'};
        
        markerProps = {'facecolor','none','edgecolor','none','markersize',5,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
        
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        for z=1:2   % Ori/size
            h = figure('Units','inches','Position',fig_dims);
            cMap = colormap(jmaColors('pval'));
            counter = 0;
            for c = 1:2   % For the carrier
                for d = 1:2   % For the OBs
                    for y=1:2   % For left/right
                        counter = counter+1;
                        subplot(4,2,counter)
                        hold on
                        if ~individualColors
                            colorIdx = 1:length(conditions);
                        else
                            colorIdx = 1;
                        end
                        switch plotVal
                            case {'p','pval','p-value'}
                                cMapMin = 0;
                                cMapMax = 1;
                                valsToPlot = squeeze(oriTCirc_p(condChoose(c,1),condChoose(c,2),:));
                            case {'t','tval','t-value'}
                                valsToPlot = squeeze(tCirc_t2circ(featureAttChoose(z,y),c,d,:)); % plot t-stat
                                cMapMax = 2; %ceil(max(max(valsToPlot(:,colorIdx))));
                                cMapMin = 0;
                            case 'mean'
                                valsToPlot = abs(oriTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                                cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                                cMapMin = 0;
                        end
                        
                        mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tCirc_p(featureAttChoose(z,y),c,d,:)<alphaVal),false,markerProps);
                        
                        % Count the number of significant electrodes for ori
                        sigElecCount(n,z,counter) = length(find(tCirc_p(featureAttChoose(z,y),c,d,:)<alphaVal));
                        
                        set(gcf,'ColorMap',cMap);
                        set(gca, 'Clim',[cMapMin,cMapMax]);
                        title(sprintf('%s%s%s',taskTitle{z},' ',graphTitle{c}{d,y}));
                        
                        % Plot the stats
                        text1 = sprintf('%s','o : significant electrodes at a threshold of p=0.05');
                        text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
                        
                        
                    end
                end
            end
            
            % Save the figure
            savefig(h,sprintf('%s%s%s%s',subjList{n},'_',taskTitle{z},'_OB_allPlots.fig'));
            print(h,sprintf('%s%s%s%s',subjList{n},'_',taskTitle{z},'_OB_allPlots.tif'),'-dtiffn');   % Save .tif
            close(h)
            
        end
    end
        
        
    
    %% Save data to participant folder
    fprintf('%s\n','Saving...')
    % cd back into the participants results folder
    cd ../
    
    save('tCirc_OB_results','tCirc_Z_est','tCirc_confidence_radii','tCirc_p','tCirc_t2circ','tCircFreqArray','tCircFreqArray')
    
    cd ../../   % cd back to data directory
    
    % Save the number of significant electrodes per condition per subject
    save('./GroupResults/Group_results_60HzLP/numSigElecs','sigElecCount');
    
    clear tCirc_results tCirc_Z_est oriTCirc_confidence_radii tCirc_p tCirc_t2circ...
        interp  tCircFreqArray OBholder
end





















