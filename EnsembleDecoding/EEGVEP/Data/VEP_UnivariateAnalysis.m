% Does various univariate analysis on the final preprocessed/BLC/Averaged
% data.
% 1. Calculate difference waveforms between conditions.
% 2. Calculate the electrode x time heat maps of p-values.

% Load in the ERP_segOriAve (and size) for each participant. Make one
% larger array that is n (participants) x 2 (ori or size) x 10 (condition lvls collapsed across non relevant feature) x 257 x 550.

% Plot the participant averaged conditions against each other (start w/ just 1v5 and 1v3 for both size and orientation) for a
% few occ, par, and fron electrodes.

% Calculate a difference waveform for each participant and plot that as
% well.

% Perform a t-test between the difference wave and 0 for each time point.

%% Initialization stuff
clear all;
% close all;

pltIndividualWaves = 0;

% Load in behavioral subject data
cd ../../
ensDataStructBehav = ensLoadData('VEPBehav','All');
cd ./'EEG VEP'/Data/

subjList = ensDataStructBehav.subjid;

% Determine what comparisons we want to make
compArray = [1 5;1 4;1 3;1 2;1 1];

% Choice electrodes
elecList(1,:) = [86 98 153];   % Occipital
elecList(2,:) = [180 193 56];   % Parietal
elecList(3,:) = [3 222 40];   % Frontal

elecGroupList = {'Occipital','Parietal','Frontal'};

% Electrode groups
elecArray{1} = [102 91 256 251 247 243 246 250 255 82 92 103 93 73 254 249 245 242 241 244 248 252 253 67 61]; %25  cheek_left
elecArray{2} = [32 37 46 54 47 38 33 27 34 39 48 40 35 28 22 29 36 23]; %18   anterior_left
elecArray{3} = [ 68 55 62 69 74 83 94 84 75 70 63 56 49 57 64 71 76 77 72 65 58 50 41 30 42 51 59 66 78 89 79 60 52 43 24 16 17 44 ...
    53 80 45 9]; %42   center_left
elecArray{4} = [142 129 128 141 153 162 152 140 127 139 151 161 171 170 160 150 138 149 159 169 178 177 168 158 148 157 167 176 ...
    189 188 175 166 156 165 174 187 199]; %37   posterior_left
elecArray{5} = [31 26 21 15 8 257 81 90 101 119 126 137 147]; %13   midline
elecArray{6} = [208 216 229 233 237 240 236 232 228 217 209 200 201 218 227 231 235 239 238 234 230 226 225 219 220]; %25   cheek_right
elecArray{7} = [25 18 10 1 2 11 19 20 12 3 222 223 4 13 14 5 224 6]; %18   anterior_right
elecArray{8} = [210 221 211 202 192 191 190 179 180 193 203 212 213 204 194 181 172 163 173 182 195 205 214 215 206 196 183 164 ...
    154 130 143 155 184 197 207 7 195 185 144 131 132 186]; %42   center_right
elecArray{9} = [88 100 110 99 87 86 98 109 118 117 106 97 85 96 107 116 125 124 115 106 95 105 114 123 136 135 122 113 104 ...
    112 121 134 146 145 133 120 111]; %37   posterior_right

labels = {'cheek left','anterior left','center left', 'posterior left','midline','cheek right','anterior right','center right','posterior right'};

% Determine where to plot the x axis labels based on the size of each sub
% group.
runningSum(1) = 0;
for i=2:length(labels)+1
    runningSum(i) = runningSum(i-1)+length(elecArray{i-1});
    place2plot(i-1) = floor(runningSum(i) - ((runningSum(i) - runningSum(i-1))/2));   % Where along the x axis should the label be
end

alphaLvl = .01;

%% Load/Organize Data
for n=1:length(subjList)
    
    % Load in preprocessed data
    %     cd(sprintf('%s',subjList{n},'/',subjList{n},'_results'))
    %     load(sprintf('%s',subjList{n},'_segOriAve.mat'),'ERP_segOriAve');   % Load ori
    cd(sprintf('%s',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
    load(sprintf('%s',subjList{n},'_segOriAve_30HzLP.mat'),'ERP_segOriAve');   % Load ori
    segOri(n,:,:,:) = ERP_segOriAve;
    %     load(sprintf('%s',subjList{n},'_segSizeAve.mat'),'ERP_segSizeAve');   % Load size
    load(sprintf('%s',subjList{n},'_segSizeAve_30HzLP.mat'),'ERP_segSizeAve');   % Load size
    segSize(n,:,:,:) = ERP_segSizeAve;
    cd ../../
    
end

% Z-score the data
for i=1:size(segOri,1)   % Participant
    for j=1:size(segOri,2)   % Level
        for k=1:size(segOri,3)   % Electrode
        
            holderSegOriMean = squeeze(mean(segOri(i,j,k,:)));
            holderSegOriStd = squeeze(std(segOri(i,j,k,:)));
            
            holderSegSizeMean = squeeze(mean(segSize(i,j,k,:)));
            holderSegSizeStd = squeeze(std(segSize(i,j,k,:)));
            
            segOriZScore(i,j,k,:) = segOri(i,j,k,:) - holderSegOriMean;
            segOriZScore(i,j,k,:) = segOriZScore(i,j,k,:) ./ holderSegOriStd;
            
            segSizeZScore(i,j,k,:) = segSize(i,j,k,:) - holderSegSizeMean;
            segSizeZScore(i,j,k,:) = segSizeZScore(i,j,k,:) ./ holderSegSizeStd;
    
        end
    end
end

% Calculate a differnce wave
for i=1:size(compArray,1)
    segOriDiff(i,:,:,:) = squeeze(segOri(:,compArray(i,2),:,:) - segOri(:,compArray(i,1),:,:));
    segSizeDiff(i,:,:,:) = squeeze(segSize(:,compArray(i,2),:,:) - segSize(:,compArray(i,1),:,:));
end

for i=1:size(compArray,1)
    segOriDiffZScore(i,:,:,:) = squeeze(segOriZScore(:,compArray(i,2),:,:) - segOriZScore(:,compArray(i,1),:,:));
    segSizeDiffZScore(i,:,:,:) = squeeze(segSizeZScore(:,compArray(i,2),:,:) - segSizeZScore(:,compArray(i,1),:,:));
end

% Average across participants
segOriAve = squeeze(mean(segOri,1));
segSizeAve = squeeze(mean(segSize,1));

segOriDiffAve = squeeze(mean(segOriDiff,2));
segSizeDiffAve = squeeze(mean(segSizeDiff,2));

segOriAveZScore = squeeze(mean(segOriZScore,1));
segSizeAveZScore = squeeze(mean(segSizeZScore,1));

segOriDiffAveZScore = squeeze(mean(segOriDiffZScore,2));
segSizeDiffAveZScore = squeeze(mean(segSizeDiffZScore,2));

%% Stats
% Take t-tests along each timepoint for all electrodes of the difference wave compared to 0
for i=1:size(segOriDiff,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
    for j=1:size(segOriDiff,3)   % For every electrode
        for k=1:size(segOriDiff,4)   % For every timepoint
            
            [oriSig(i,j,k) oriP(i,j,k) oriCI{i,j,k} oriStats{i,j,k}] = ttest(segOriDiff(i,:,j,k));
            
        end
    end
end

for i=1:size(segSizeDiff,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
    for j=1:size(segSizeDiff,3)   % For every electrode
        for k=1:size(segSizeDiff,4)   % For every timepoint
            
            [sizeSig(i,j,k) sizeP(i,j,k) sizeCI{i,j,k} sizeStats{i,j,k}] = ttest(segSizeDiff(i,:,j,k));
            
        end
    end
end

% Convert the stats struct to an array
for i=1:size(sizeStats,1)
    for j=1:size(sizeStats,2)
        for k=1:size(sizeStats,3)
            oriT(i,j,k) = oriStats{i,j,k}.tstat;
            sizeT(i,j,k) = sizeStats{i,j,k}.tstat;
        end
    end
end

% Convert the p value to alpha (transparency) values based on significance
for i=1:size(oriP,1)
    for j=1:size(oriP,2)
        for k=1:size(oriP,3)
            if oriP(i,j,k) <= alphaLvl
                oriPTrans(i,j,k) = 1;
            else
                oriPTrans(i,j,k) = .25;
            end
        end
    end
end
for i=1:size(sizeP,1)
    for j=1:size(sizeP,2)
        for k=1:size(sizeP,3)
            if sizeP(i,j,k) <= alphaLvl
                sizePTrans(i,j,k) = 1;
            else
                sizePTrans(i,j,k) = .25;
            end
        end
    end
end


%% Stats for z-scored data
% Take t-tests along each timepoint for all electrodes of the difference wave compared to 0
for i=1:size(segOriDiffZScore,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
    for j=1:size(segOriDiffZScore,3)   % For every electrode
        for k=1:size(segOriDiffZScore,4)   % For every timepoint
            
            [oriSigZScore(i,j,k) oriPZScore(i,j,k) oriCIZScore{i,j,k} oriStatsZScore{i,j,k}] = ttest(segOriDiffZScore(i,:,j,k));
            
        end
    end
end

for i=1:size(segSizeDiffZScore,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
    for j=1:size(segSizeDiffZScore,3)   % For every electrode
        for k=1:size(segSizeDiffZScore,4)   % For every timepoint
            
            [sizeSigZScore(i,j,k) sizePZScore(i,j,k) sizeCIZScore{i,j,k} sizeStatsZScore{i,j,k}] = ttest(segSizeDiffZScore(i,:,j,k));
            
        end
    end
end

% Convert the stats struct to an array
for i=1:size(sizeStatsZScore,1)
    for j=1:size(sizeStatsZScore,2)
        for k=1:size(sizeStatsZScore,3)
            oriTZScore(i,j,k) = oriStatsZScore{i,j,k}.tstat;
            sizeTZScore(i,j,k) = sizeStatsZScore{i,j,k}.tstat;
        end
    end
end

% Convert the p value to alpha (transparency) values based on significance
for i=1:size(oriPZScore,1)
    for j=1:size(oriPZScore,2)
        for k=1:size(oriPZScore,3)
            if oriPZScore(i,j,k) <= alphaLvl
                oriPTransZScore(i,j,k) = 1;
            else
                oriPTransZScore(i,j,k) = .25;
            end
        end
    end
end
for i=1:size(sizePZScore,1)
    for j=1:size(sizePZScore,2)
        for k=1:size(sizePZScore,3)
            if sizePZScore(i,j,k) <= alphaLvl
                sizePTransZScore(i,j,k) = 1;
            else
                sizePTransZScore(i,j,k) = .25;
            end
        end
    end
end

%% Save the data 
cd(sprintf('%s',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
save(sprintf('%s',subjList{n},'_univariate_analysis_results_ori.mat'),'segOriDiff','oriPTrans','oriT','oriSig','oriP');
save(sprintf('%s',subjList{n},'_univariate_analysis_results_size.mat'),'segSizeDiff','sizePTrans','sizeT','sizeSig','sizeP');
save(sprintf('%s',subjList{n},'_univariate_analysis_results_ori_zscore.mat'),'segOriDiffZScore','oriPTransZScore','oriTZScore','oriSigZScore','oriPZScore');
save(sprintf('%s',subjList{n},'_univariate_analysis_results_size_zscore.mat'),'segSizeDiffZScore','sizePTransZScore','sizeTZScore','sizeSigZScore','sizePZScore');
cd ../../




%% Butterfly/Difference waveform plots
% Butterfly plot for each of the 5 conditions
% fig_box = 'off'; %Figure border on/off
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

lineWidth = 2;
fontSize = 12;

thisFig = figure('Name','Butterfly Plots','Units','inches','Position',fig_dims);
counter = 0;
for i=1:size(segOriAve,1)/2
    counter = counter + 2;
    
    % Orientation
    subplot(5,2,counter-1)
    plot(squeeze(segOriAve(i,:,:))')
    hold on 
    ylim([-7.5 7.5]);
    title(sprintf('%s%d%s%d','Orientation Level: ',i));
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    ylabel('Amplitude (?V)','FontSize',12);
    xlabel('Time (ms)','FontSize',12);
    xline(100,'-','LineWidth',2);   % Mark baseline
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])    
    
    % Size
    subplot(5,2,counter)
    plot(squeeze(segSizeAve(i,:,:))')
    hold on 
    ylim([-7.5 7.5]);
    title(sprintf('%s%d%s%d','Size Level: ',i));
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    ylabel('Amplitude (?V)','FontSize',12);
    xlabel('Time (ms)','FontSize',12);
    xline(100,'-','LineWidth',2);   % Mark baseline
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])    
end

% Save image
cd ./Figures/PrettyFigs/
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,'butterfly Plots.tif','-dtiffn')
cd ../../



% % Plot the butterflies for each participant
% for n=1:size(segOri,1)
%     figure('Name',sprintf('%s%s','Orientation Butterfly Plots ',subjList{n}))
%     counter = 0;
%     for i=1:size(segOri,2)/2
%         counter = counter+2;
%         
%         subplot(5,2,counter-1)
%         plot(squeeze(segOri(n,i,:,:))')
%         hold on
%         ylim([-5 5]);
%         title(sprintf('%s%s%d',subjList{j},' Orientation Level: ',i));
%         
%         subplot(5,2,counter)
%         plot(squeeze(segSize(n,i,:,:))')
%         hold on
%         ylim([-5 5]);
%         title(sprintf('%s%s%d',subjList{j},' Size Level: ',i));
%     end
% end




% Difference waves in heat maps/butterfly plots
% subPlotOrderButter = 1:2:9;
% subPlotOrderHeat = 2:2:10;
% figure('Name','Orientation Difference Waveform Data')
% for i=1:size(segOriDiff,1)-1
%     % Plot the butterfly plots
%     subplot(4,2,subPlotOrderButter(i))
%     plot(squeeze(segOriDiffAve(i,:,:))');    
%     hold on 
%     ylim([-1.5 1.5]);
%     title(sprintf('%s%d%s%d','Orientation Difference Waves: ',compArray(i,1),' vs ',compArray(i,2)));
%     
%     subplot(4,2,subPlotOrderHeat(i))
%     topoPlotOri = imagesc(squeeze(segOriDiffAve(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1.5 1.5]);
%     hold on
%     % Plot horizontal black lines to separate the electrode groups
%     runningSum = 0;
%     for j=1:length(elecArray)
%         runningSum = runningSum + length(elecArray{j});
%         yline(runningSum,'k','LineWidth',2);
%     end
%     set(topoPlotOri,'AlphaData',squeeze(oriPTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value
%     colorbar()
%     set(gca,'TickLength',[0 0])
%     yticks(place2plot);
%     yticklabels(labels);
%     title(sprintf('%s%d%s%d','Orientation Difference Waves: ',compArray(i,1),' vs ',compArray(i,2)));
% end
% figure('Name','Size Difference Waveform Data')
% for i=1:size(segOriDiff,1)-1
%     % Plot the butterfly plots
%     subplot(4,2,subPlotOrderButter(i))
%     plot(squeeze(segSizeDiffAve(i,:,:))');
%     hold on 
%     ylim([-1.5 1.5]);
%     title(sprintf('%s%d%s%d','Size Difference Waves: ',compArray(i,1),' vs ',compArray(i,2)));
%     
%     % Plot the heat maps
%     subplot(4,2,subPlotOrderHeat(i))
%     topoPlotSize = imagesc(squeeze(segSizeDiffAve(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1.5 1.5]);
%     hold on
%     % Plot horizontal black lines to separate the electrode groups
%     runningSum = 0;
%     for j=1:length(elecArray)
%         runningSum = runningSum + length(elecArray{j});
%         yline(runningSum,'k','LineWidth',2);
%     end
%     set(topoPlotSize,'AlphaData',squeeze(sizePTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value
%     colorbar()
%     set(gca,'TickLength',[0 0])
%     yticks(place2plot);
%     yticklabels(labels);
%     title(sprintf('%s%d%s%d','Size Difference Waves: ',compArray(i,1),' vs ',compArray(i,2)));
% end
% 
% %% Plot waveforms
% % Plot waveforms and difference waves
% if pltIndividualWaves == 1
%     for i=1:size(segOriDiff,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
%         figure('Name',sprintf('%s%d%s%d','Orientation Difference Waves: ',compArray(i,1),' vs ',compArray(i,2)))
%         counter = 0;
%         for j=1:size(elecList,1)
%             for k=1:size(elecList,2)
%                 
%                 counter = counter + 1;
%                 subplot(3,3,counter)
%                 yline(0,'k');   % Horizontal line at 0
%                 hold on
%                 plot(1:550,squeeze(segOriAve(compArray(i,1),elecList(j,k),:))','b');
%                 plot(1:550,squeeze(segOriAve(compArray(i,2),elecList(j,k),:))','r');
%                 plot(1:550,squeeze(segOriDiffAve(i,elecList(j,k),:))','g');
%                 title(sprintf('%s%s%d',elecGroupList{j},': Elec # ',elecList(j,k)));
%                 legend({sprintf('%s%d','Level: ',compArray(i,1)),sprintf('%s%d','Level: ',compArray(i,2)),'Difference'});
%                 ylabel('Amplitude (µV)');
%                 ylim([-4 4]);
%                 
%             end
%         end
%     end
%     
%     for i=1:size(segSizeDiff,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
%         figure('Name',sprintf('%s%d%s%d','Size Difference Waves: ',compArray(i,1),' vs ',compArray(i,2)))
%         counter = 0;
%         for j=1:size(elecList,1)
%             for k=1:size(elecList,2)
%                 
%                 counter = counter + 1;
%                 subplot(3,3,counter)
%                 yline(0,'k');   % Horizontal line at 0
%                 hold on
%                 plot(1:550,squeeze(segSizeAve(compArray(i,1),elecList(j,k),:))','b');
%                 plot(1:550,squeeze(segSizeAve(compArray(i,2),elecList(j,k),:))','r');
%                 plot(1:550,squeeze(segSizeDiffAve(i,elecList(j,k),:))','g');
%                 title(sprintf('%s%s%d',elecGroupList{j},': Elec # ',elecList(j,k)));
%                 legend({sprintf('%s%d','Level: ',compArray(i,1)),sprintf('%s%d','Level: ',compArray(i,2)),'Difference'});
%                 ylabel('Amplitude (µV)');
%                 ylim([-4 4]);
%                 
%             end
%         end
%     end
%     
%     % Plot p-vals with highlighted areas indicating significance
%     for i=1:size(segSizeDiff,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
%         figure('Name',sprintf('%s%d%s%d','Orientation Difference T-Vals: ',compArray(i,1),' vs ',compArray(i,2)))
%         counter = 0;
%         for j=1:size(elecList,1)
%             for k=1:size(elecList,2)
%                 
%                 counter = counter + 1;
%                 subplot(3,3,counter)
%                 yline(0,'k');   % Horizontal line at 0
%                 hold on
%                 plot(1:550,squeeze(oriT(i,elecList(j,k),:)),'b');
%                 plot(1:550,squeeze(segOriDiffAve(i,elecList(j,k),:))','g');
%                 % If p<.05 mark timepoint as significant
%                 for m=1:size(oriT,3)
%                     if oriP(i,j,m) <= .05
%                         plot(m,-3.3,'*r');
%                     end
%                 end
%                 
%                 title(sprintf('%s%s%d',elecGroupList{j},': Elec # ',elecList(j,k)));
%                 ylabel('Amplitude (µV)');
%                 ylim([-3.5 3]);
%                 
%             end
%         end
%     end
%     
%     for i=1:size(segSizeDiff,1)   % For each comparison (i.e. 1v5, 1v3, etc.)
%         figure('Name',sprintf('%s%d%s%d','Size Difference T-Vals: ',compArray(i,1),' vs ',compArray(i,2)))
%         counter = 0;
%         for j=1:size(elecList,1)
%             for k=1:size(elecList,2)
%                 
%                 counter = counter + 1;
%                 subplot(3,3,counter)
%                 yline(0,'k');   % Horizontal line at 0
%                 hold on
%                 plot(1:550,squeeze(sizeT(i,elecList(j,k),:)),'b');
%                 plot(1:550,squeeze(segSizeDiffAve(i,elecList(j,k),:))','g');
%                 % If p<.05 mark timepoint as significant
%                 for m=1:size(sizeT,3)
%                     if sizeP(i,j,m) <= .05
%                         plot(m,-3.3,'*r');
%                     end
%                 end
%                 
%                 title(sprintf('%s%s%d',elecGroupList{j},': Elec # ',elecList(j,k)));
%                 ylabel('Amplitude (µV)');
%                 ylim([-3.5 3]);
%                 
%             end
%         end
%     end
% end

%% Plot the heat maps for all electrodes
% Create an array to use with imagesc
% Orientation
figure('Name','Orientation Heat Maps')
for i=1:size(segOriDiff,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    subplot(4,1,i)
    topoPlotOri = imagesc(squeeze(oriT(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));
    hold on
    set(topoPlotOri,'AlphaData',squeeze(oriPTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',2);
    end
    title(sprintf('%s%d%s%d','Orientation Difference T-Vals All Electrodes: ',compArray(i,1),' vs ',compArray(i,2)));
    set(gca,'TickLength',[0 0])
    yticks(place2plot);
    yticklabels(labels);
    colorbar
end

% Size
figure('Name','Size Heat Maps')
for i=1:size(segSizeDiff,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    subplot(4,1,i)
    topoPlotSize = imagesc(squeeze(sizeT(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));
    hold on
    set(topoPlotSize,'AlphaData',squeeze(sizePTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',2);
    end
    title(sprintf('%s%d%s%d','Size Difference T-Vals All Electrodes: ',compArray(i,1),' vs ',compArray(i,2)));
    set(gca,'TickLength',[0 0])
    yticks(place2plot);
    yticklabels(labels);
    colorbar
end


%% Make and save pretty figs for all differences

% Change directory
cd ./Figures/PrettyFigs/

% fig_box = 'off'; %Figure border on/off
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

lineWidth = 2;
fontSize = 12;

thisFig = figure('Name','Average Orientation','Units','inches','Position',fig_dims);

% Plot the heat maps for all electrodes
% Orientation
for i=1:size(segOriDiff,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    %     close all

    subplot(4,1,i)
    topoPlotOri = imagesc(squeeze(oriT(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1 1]);
    hold on
    set(topoPlotOri,'AlphaData',squeeze(oriPTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value

    titleProp = title(sprintf('%s%d%s%d','Orientation Heat Maps ',compArray(i,2),' vs ',compArray(i,1)),'FontSize',12,'Units','pixels');
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    ylabel('Electrode Group','FontSize',12);
    xlabel('Time (ms)','FontSize',12);
    xline(100,'-','LineWidth',2);   % Mark baseline
    yticks(place2plot);
    yticklabels(labels);
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',2);
    end
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar

end

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
savefig(thisFig,'Univariate_TValHeatMaps_OriAllLvls_Topo.fig');
print(thisFig,'Univariate_TValHeatMaps_OriAllLvls.tif','-dtiffn');   % Save .tif





thisFig = figure('Name','Average Orientation','Units','inches','Position',fig_dims);

% Plot the heat maps for all electrodes
% Size
for i=1:size(segOriDiff,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    %     close all

    subplot(4,1,i)
    topoPlotOri = imagesc(squeeze(sizeT(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1 1]);
    hold on
    set(topoPlotOri,'AlphaData',squeeze(sizePTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value

    titleProp = title(sprintf('%s%d%s%d','Size Heat Maps ',compArray(i,2),' vs ',compArray(i,1)),'FontSize',12,'Units','pixels');
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    ylabel('Electrode Group','FontSize',12);
    xlabel('Time (ms)','FontSize',12);
    xline(100,'-','LineWidth',2);   % Mark baseline
    yticks(place2plot);
    yticklabels(labels);
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',2);
    end
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar

end

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
savefig(thisFig,'Univariate_TValHeatMaps_SizeAllLvls_Topo.fig');
print(thisFig,'Univariate_TValHeatMaps_SizeAllLvls.tif','-dtiffn');   % Save .tif

cd ../../



%% Make and save pretty figs for all differences (z-scored)

% Change directory
cd ./Figures/PrettyFigs/

% fig_box = 'off'; %Figure border on/off
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

lineWidth = 2;
fontSize = 12;

thisFig = figure('Name','Average Orientation','Units','inches','Position',fig_dims);

% Plot the heat maps for all electrodes
% Orientation
for i=1:size(segOriDiffZScore,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    %     close all

    subplot(4,1,i)
    topoPlotOri = imagesc(squeeze(oriTZScore(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1 1]);
    hold on
    set(topoPlotOri,'AlphaData',squeeze(oriPTransZScore(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value

    titleProp = title(sprintf('%s%d%s%d%s','Orientation Heat Maps ',compArray(i,2),' vs ',compArray(i,1),' - Z-Scored'),'FontSize',12,'Units','pixels');
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    ylabel('Electrode Group','FontSize',12);
    xlabel('Time (ms)','FontSize',12);
    xline(100,'-','LineWidth',2);   % Mark baseline
    yticks(place2plot);
    yticklabels(labels);
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',2);
    end
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar

end

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
savefig(thisFig,'Univariate_TValHeatMaps_OriAllLvls_ZScore_Topo.fig');
print(thisFig,'Univariate_TValHeatMaps_OriAllLvls_ZScore.tif','-dtiffn');   % Save .tif





thisFig = figure('Name','Average Orientation','Units','inches','Position',fig_dims);

% Plot the heat maps for all electrodes
% Size
for i=1:size(segSizeDiffZScore,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    %     close all

    subplot(4,1,i)
    topoPlotOri = imagesc(squeeze(sizeTZScore(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1 1]);
    hold on
    set(topoPlotOri,'AlphaData',squeeze(sizePTransZScore(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value

    titleProp = title(sprintf('%s%d%s%d','Size Heat Maps ',compArray(i,2),' vs ',compArray(i,1),' - Z-Scored'),'FontSize',12,'Units','pixels');
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    ylabel('Electrode Group','FontSize',12);
    xlabel('Time (ms)','FontSize',12);
    xline(100,'-','LineWidth',2);   % Mark baseline
    yticks(place2plot);
    yticklabels(labels);
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',2);
    end
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar

end

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
savefig(thisFig,'Univariate_TValHeatMaps_SizeAllLvls_ZScore_Topo.fig');
print(thisFig,'Univariate_TValHeatMaps_SizeAllLvls_ZScore.tif','-dtiffn');   % Save .tif

cd ../../


%% Make and save pretty figs for individual differences 
% fig_box = 'off'; %Figure border on/off
fig_dims = [500 500 2000 500];   % Size of figure
fig_size = 4;   % Thickness of borders
fig_box = 'on'; %Figure border on/off

% Change directory
cd ./Figures/PrettyFigs/

% Plot the heat maps for all electrodes
% Orientation
for i=1:size(segOriDiff,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    %     close all
    
    thisFig = figure('Name',sprintf('%s%d%s%d','Orientation Heat Maps ',compArray(i,2),' vs ',compArray(i,1)),'Units','pixels');
    topoPlotOri = imagesc(squeeze(oriT(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1 1]);
    hold on
    set(topoPlotOri,'AlphaData',squeeze(oriPTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value

    titleProp = title(sprintf('%s%d%s%d','Orientation Heat Maps ',compArray(i,2),' vs ',compArray(i,1)),'FontSize',30,'Units','pixels');
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',25);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',25);
    ylabel('Electrode Group','FontSize',30);
    xlabel('Time (ms)','FontSize',30);
    xline(50,'-','LineWidth',4);   % Mark baseline
    yticks(place2plot);
    yticklabels(labels);
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',4);
    end
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
    
    % Save image
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
    print(thisFig,sprintf('%s%d%s','Univariate_TValHeatMaps_OriLvl_',i,'_1_NoReref'),'-dpdf')
   
end

% Size
for i=1:size(segSizeDiff,1)-1   % For each comparison (i.e. 1v5, 1v3, etc.)
    %     close all
    
    thisFig = figure('Name',sprintf('%s%d%s%d','Size Heat Maps ',compArray(i,2),' vs ',compArray(i,1)),'Units','pixels');
    topoPlotSize = imagesc(squeeze(sizeT(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)),[-1 1]);
    hold on
    set(topoPlotSize,'AlphaData',squeeze(sizePTrans(i,[elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],:)));   % Changes the transparancy of various parts of the plot based on p-value

    titleProp = title(sprintf('%s%d%s%d','Size Heat Maps ',compArray(i,2),' vs ',compArray(i,1)),'FontSize',30,'Units','pixels');
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',25);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',25);
    ylabel('Electrode Group','FontSize',30);
    xlabel('Time (ms)','FontSize',30);
    xline(50,'-','LineWidth',4);   % Mark baseline
    yticks(place2plot);
    yticklabels(labels);
    % Plot horizontal black lines to separate the electrode groups
    runningSum = 0;
    for j=1:length(elecArray)
        runningSum = runningSum + length(elecArray{j});
        yline(runningSum,'k','LineWidth',4);
    end
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    hold on
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
    
    % Save image
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
    print(thisFig,sprintf('%s%d%s','Univariate_TValHeatMaps_SizeLvl_',i,'_1_NoReref'),'-dpdf')
    
end

% %% Plot individual waveforms to demonstrate the difference process
% % Orientation 1st elec lvl 1
% thisFig = figure('Name','Orientation Level 1');
% plot(squeeze(segOriAve(1,1,:))','LineWidth',3)
% hold on
% 
% titleProp = title('Orientation Level 1','FontSize',30,'Units','pixels');
% xAX = get(gca,'XAxis');   % Change font of x/y ticks
% set(xAX,'FontSize',25);
% yAX = get(gca,'YAxis');
% set(yAX,'FontSize',25);
% ylabel('Amplitude (?V)','FontSize',30);
% xlabel('Time (ms)','FontSize',30);
% xline(50,'-','LineWidth',4);   % Mark baseline
% ylim([-5 5]);
% 
% %Make background white
% set(gcf,'color','white')
% %Specify demensions of figure
% set(thisFig,'position',fig_dims)
% %Set figure thickness and border
% hold on
% set(gca,'linewidth',fig_size,'box',fig_box)
% 
% % y-axis are levels being correlated
% set(gca,'TickLength',[0 0])
% 
% % Save image
% thisFig.PaperPositionMode = 'auto';
% thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
% print(thisFig,'Univariate_IndivWaves_1_NoReref','-dpdf')
% 
% 
% % Orientation 1st elec lvl 2
% thisFig = figure('Name','Orientation Level 2');
% plot(squeeze(segOriAve(2,1,:))','LineWidth',3)
% hold on
% 
% titleProp = title('Orientation Level 2','FontSize',30,'Units','pixels');
% xAX = get(gca,'XAxis');   % Change font of x/y ticks
% set(xAX,'FontSize',25);
% yAX = get(gca,'YAxis');
% set(yAX,'FontSize',25);
% ylabel('Amplitude (?V)','FontSize',30);
% xlabel('Time (ms)','FontSize',30);
% xline(50,'-','LineWidth',4);   % Mark baseline
% ylim([-5 5]);
% 
% %Make background white
% set(gcf,'color','white')
% %Specify demensions of figure
% set(thisFig,'position',fig_dims)
% %Set figure thickness and border
% hold on
% set(gca,'linewidth',fig_size,'box',fig_box)
% 
% % y-axis are levels being correlated
% set(gca,'TickLength',[0 0])
% 
% % Save image
% thisFig.PaperPositionMode = 'auto';
% thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
% print(thisFig,'Univariate_IndivWaves_2_NoReref','-dpdf')
% 
% 
% % Orientation 1st elec 1 v 2 difference
% thisFig = figure('Name','Orientation Level 1 v 2 Difference');
% plot(squeeze(segOriDiffAve(1,1,:))','LineWidth',3)
% hold on
% 
% titleProp = title('Orientation Level 1 v 2 Difference','FontSize',30,'Units','pixels');
% xAX = get(gca,'XAxis');   % Change font of x/y ticks
% set(xAX,'FontSize',25);
% yAX = get(gca,'YAxis');
% set(yAX,'FontSize',25);
% ylabel('Amplitude (?V)','FontSize',30);
% xlabel('Time (ms)','FontSize',30);
% xline(50,'-','LineWidth',4);   % Mark baseline
% ylim([-5 5]);
% 
% %Make background white
% set(gcf,'color','white')
% %Specify demensions of figure
% set(thisFig,'position',fig_dims)
% %Set figure thickness and border
% hold on
% set(gca,'linewidth',fig_size,'box',fig_box)
% 
% % y-axis are levels being correlated
% set(gca,'TickLength',[0 0])
% 
% % Save image
% thisFig.PaperPositionMode = 'auto';
% thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
% print(thisFig,'Univariate_IndivWaves_Diff_NoReref','-dpdf')
% 
% 
% cd ../../















