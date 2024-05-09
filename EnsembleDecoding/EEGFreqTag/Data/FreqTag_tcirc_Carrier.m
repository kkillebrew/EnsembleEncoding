% Loads in the frequency tagging data and performs a t-circ analysis on 40
% conditions: 3Hz/5Hz, left/right attend, ori/size, 1/2/3/4/5 lvls.

clear all;
close all;

fakeData=0;
plotData=1;
alphaVal = .01;
newSubjs = 1;

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
% stim_rate_BL(1) = 3;
% stim_rate_BL(2) = 5;
% stim_rate_OB(1,1) = .6;
% stim_rate_OB(1,2) = .75;
% stim_rate_OB(2,1) = .8;
% stim_rate_OB(2,2) = 2;

% If you are starting on new subjects, load in the group data files to
% append to them.
if newSubjs == 1
    load('./GroupResults/Group_results_60HzLP/numSigElecs');
end


%% Start t-circ analysis
% for n=17:length(subjList)
for n=1
    
    %% Load in the freqeuncy tag data
    
    fprintf('%s%d\n','Subj: ',n)
    fprintf('%s\n','Loading and preping...')
    
    % Data directory
    if fakeData==1
        dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP');
    elseif fakeData==0
        dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP/tCircData/');
    end
    
    cd(dataDir)
    
    % Load data segmented by condtion
    for i=1:10   % For all conditions
        oriSegHolder = load(sprintf('%s%d','tcir_Seg_Data_',i),'oriSegTCirc');
        sizeSegHolder = load(sprintf('%s%d','tcir_Seg_Data_',i),'sizeSegTCirc');
        
        oriSeg{i} = oriSegHolder.oriSegTCirc;
        sizeSeg{i} = sizeSegHolder.sizeSegTCirc;
        
        clear oriSegTCircHolder sizeSegTCircHolder
    end
    
    % Load the conditions file
    cd ../   % cd back to participant results folder
    chosenFreqsOriHolder = load('FFT_Results','chosenFreqsOri');
    chosenFreqsSizeHolder = load('FFT_Results','chosenFreqsSize');
    
    chosenFreqsOri = chosenFreqsOriHolder.chosenFreqsOri;
    chosenFreqsSize = chosenFreqsSizeHolder.chosenFreqsSize;
    
    clear chosenFreqsOriHolder chosenFreqsSizeHolder
    
    cd ../../   % cd back to the data dir
    
    %% Segment
    
    fprintf('%s\n','Segmenting...')
    
    % Segment data into 3Hz att and 5Hz att
    % Ori
    carrierFreqs = [30 50];
    oriSegAtt = cell(2,2);
    for k=1:2   % 3/5 Hz
        for j=1:2   % Left/right att
            if j==1
                for i=1:5   % Levels
                    if isempty(oriSegAtt{k,j})
                        oriSegAtt{k,j} = oriSeg{i}(chosenFreqsOri{i}(:,1)==carrierFreqs(k),1:256,:);
                    else
                        oriSegAtt{k,j} = cat(1,oriSegAtt{k,j}(:,1:256,:), oriSeg{i}(chosenFreqsOri{i}(:,1)==carrierFreqs(k),1:256,:));
                    end
                end
            elseif j==2
                for i=6:10   % Levels
                    if isempty(oriSegAtt{k,j})
                        oriSegAtt{k,j} = oriSeg{i}(chosenFreqsOri{i}(:,2)==carrierFreqs(k),1:256,:);
                    else
                        oriSegAtt{k,j} = cat(1,oriSegAtt{k,j}(:,1:256,:), oriSeg{i}(chosenFreqsOri{i}(:,2)==carrierFreqs(k),1:256,:));
                    end
                end
            end
        end
    end
    
%     % Run to confirm number of trials per condition
%     counter = [0 0];
%     for j=1:2
%         if j==1
%             for i=1:5
%                 counter(j) = counter(j) + sum(chosenFreqsOri{i}(:,j)==50);
%             end
%         elseif j==2
%             for i=6:10
%                 counter(j) = counter(j) + sum(chosenFreqsOri{i}(:,j)==50);
%             end
%         end
%     end
        
    % Size
    sizeSegAtt = cell(2,2);
    for k=1:2   % 3/5 Hz
        for j=1:2   % Left/right att
            if j==1
                for i=1:5   % Levels
                    if isempty(sizeSegAtt{k,j})
                        sizeSegAtt{k,j} = sizeSeg{i}(chosenFreqsSize{i}(:,1)==carrierFreqs(k),1:256,:);
                    else
                        sizeSegAtt{k,j} = cat(1,sizeSegAtt{k,j}(:,1:256,:), sizeSeg{i}(chosenFreqsSize{i}(:,1)==carrierFreqs(k),1:256,:));
                    end
                end
            elseif j==2
                for i=6:10   % Levels
                    if isempty(sizeSegAtt{k,j})
                        sizeSegAtt{k,j} = sizeSeg{i}(chosenFreqsSize{i}(:,2)==carrierFreqs(k),1:256,:);
                    else
                        sizeSegAtt{k,j} = cat(1,sizeSegAtt{k,j}(:,1:256,:), sizeSeg{i}(chosenFreqsSize{i}(:,2)==carrierFreqs(k),1:256,:));
                    end
                end
            end
        end
    end

%     % Run to confirm number of trials per condition
%     counter = [0 0];
%     for j=1:2
%         if j==1
%             for i=1:5
%                 counter(j) = counter(j) + sum(chosenFreqsSize{i}(:,j)==50);
%             end
%         elseif j==2
%             for i=6:10
%                 counter(j) = counter(j) + sum(chosenFreqsSize{i}(:,j)==50);
%             end
%         end
%     end
    
    %% Do the tcirc analysis for every condition, electrode, and participant
    % ori, left/right att, 1-5 lvls, 3/5Hz
    
    fprintf('%s\n','Performing TCirc...')
    
%     cd ./T_Circ_Analysis/
    for i=1:2   % 3/5 Hz
        for j=1:2   % Left/right
            for k=1:256   % Electrode
                
                % First, take the fft for each trial in the condition
                for l=1:size(oriSegAtt{i,j},1)
                    oriSegAttFFT{i,j}(l,k,:) = fft(squeeze(oriSegAtt{i,j}(l,k,:)));
                end
                for l=1:size(sizeSegAtt{i,j},1)
                    sizeSegAttFFT{i,j}(l,k,:) = fft(squeeze(sizeSegAtt{i,j}(l,k,:)));
                end
                
                % Grab the freqs you want to send to the tcirc
                if i==1 && j==1   % 3Hz left att
                    oriTCircFreqArray{i,j}(:,k) = oriSegAttFFT{i,j}(:,k,61);
                    sizeTCircFreqArray{i,j}(:,k) = sizeSegAttFFT{i,j}(:,k,61);
                elseif i==1 && j==2   % 3Hz right att
                    oriTCircFreqArray{i,j}(:,k) = oriSegAttFFT{i,j}(:,k,61);
                    sizeTCircFreqArray{i,j}(:,k) = sizeSegAttFFT{i,j}(:,k,61);
                elseif i==2 && j==1   % 5Hz left att
                    oriTCircFreqArray{i,j}(:,k) = oriSegAttFFT{i,j}(:,k,101);
                    sizeTCircFreqArray{i,j}(:,k) = sizeSegAttFFT{i,j}(:,k,101);
                elseif i==2 && j==2   % 5Hz right att
                    oriTCircFreqArray{i,j}(:,k) = oriSegAttFFT{i,j}(:,k,101);
                    sizeTCircFreqArray{i,j}(:,k) = sizeSegAttFFT{i,j}(:,k,101);
                end
                    
                % Outputs:
                % Z_est- Mean fourier
                % confidence_radii- N-length array of real numbers representing the 2D confidence circle radius  for each frequency
                % p- M-length array of significance values for each frequency
                % t2circ- M-length array of t2circ for each frequency
                [oriTCirc_Z_est(i,j,k,:) oriTCirc_confidence_radii(i,j,k,:) oriTCirc_p(i,j,k,:) oriTCirc_t2circ(i,j,k,:)] =...
                    t2circ_1tag(squeeze(oriTCircFreqArray{i,j}(:,k)),alphaVal);
                
                [sizeTCirc_Z_est(i,j,k,:) sizeTCirc_confidence_radii(i,j,k,:) sizeTCirc_p(i,j,k,:) sizeTCirc_t2circ(i,j,k,:)] =...
                    t2circ_1tag(squeeze(sizeTCircFreqArray{i,j}(:,k)),alphaVal);
                
            end
            
            clear oriSegAttFFT sizeSegAttFFT
            
        end
    end
    
    
    clear oriSegAttFFT sizeSegAttFFT oriSegAtt sizeSegAtt
    
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
        graphTitle = {'3 Hz Left','3 Hz right','5 Hz Left','5 Hz Right'};
        
        markerProps = {'facecolor','none','edgecolor','none','markersize',5,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
        
        fig_dims = [1 1 10.5 9];   % Size of figure
        fig_size = 4; %Thickness of borders
        fig_box = 'on'; %Figure border on/off
        
        % Ori
        h = figure('Units','inches','Position',fig_dims);
        cMap = colormap(jmaColors('pval'));
        for c = 1:4   % For 3Hz/5Hz left/right
            subplot(2,2,c)
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
                    valsToPlot = squeeze(oriTCirc_t2circ(condChoose(c,1),condChoose(c,2),:)); % plot t-stat
                    cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                    cMapMin = 0;
                case 'mean'
                    valsToPlot = abs(oriTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                    cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                    cMapMin = 0;
            end
            mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(oriTCirc_p(condChoose(c,1),condChoose(c,2),:)<alphaVal),false,markerProps);
            
            % Count the number of significant electrodes for ori
            oriSigElecCount(n,c) = length(find(oriTCirc_p(condChoose(c,1),condChoose(c,2),:)<alphaVal));
            
            set(gcf,'ColorMap',cMap);
            set(gca, 'Clim',[cMapMin,cMapMax]);
            title(sprintf('%s%s',' Orientation ',graphTitle{c}));
            
            % Plot the stats
            text1 = sprintf('%s','o : significant electrodes at a threshold of p=0.01');
            text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');

        end
        
        % Save the figure
        savefig(h,sprintf('%s%s%s%s',subjList{n},' Ori ',graphTitle{c},'_allPlots.fig'));
        print(h,sprintf('%s%s%s%s',subjList{n},' Ori ',graphTitle{c},'_allPlots.tif'),'-dtiffn');   % Save .tif
        close(h)
        
        % Size
        h = figure('Units','inches','Position',fig_dims);
        for c = 1:4   % For 3Hz/5Hz left/right
            subplot(2,2,c)
            hold on
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
                    valsToPlot = squeeze(sizeTCirc_t2circ(condChoose(c,1),condChoose(c,2),:)); % plot t-stat
                    cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                    cMapMin = 0;
                case 'mean'
                    valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
                    cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                    cMapMin = 0;
            end
            mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:)<alphaVal),false,markerProps);
            
            % Count the number of significant electrodes for size
            sizeSigElecCount(n,c) = length(find(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:)<alphaVal));
            
            set(gcf,'ColorMap',cMap);
            set(gca, 'Clim',[cMapMin,cMapMax]);
            title(sprintf('%s%s',' Size ',graphTitle{c}));
            
            text1 = sprintf('%s','o : significant electrodes at a threshold of p=0.01');
            text(0,-15,text1,'FontSize',12,'HorizontalAlignment','center');
            
            hold off
        end
        
        % Save the figure
        savefig(h,sprintf('%s%s%s%s',subjList{n},' Size ',graphTitle{c},'_allPlots.fig'));
        print(h,sprintf('%s%s%s%s',subjList{n},' Size ',graphTitle{c},'_allPlots.tif'),'-dtiffn');   % Save .tif
        close(h)
        
    end
    
    %% Save data to participant folder
    fprintf('%s\n','Saving...')
    % cd back into the participants results folder
    cd ../
    
    save('tCirc_results','oriTCirc_Z_est','oriTCirc_confidence_radii','oriTCirc_p','oriTCirc_t2circ',...
        'sizeTCirc_Z_est','sizeTCirc_confidence_radii','sizeTCirc_p','sizeTCirc_t2circ','oriTCircFreqArray','sizeTCircFreqArray')
    
    cd ../../   % cd back to data directory
    
    % Save the number of significant electrodes per condition per subject
    save('./GroupResults/Group_results_60HzLP/numSigElecs','oriSigElecCount','sizeSigElecCount');
    
    clear tCirc_results oriTCirc_Z_est oriTCirc_confidence_radii oriTCirc_p oriTCirc_t2circ...
        sizeTCirc_Z_est sizeTCirc_confidence_radii sizeTCirc_p sizeTCirc_t2circ...
        chosenFreqsOri chosenFreqsSize oriSeg sizeSeg  oriTCircFreqArray sizeTCircFreqArray 
end





















