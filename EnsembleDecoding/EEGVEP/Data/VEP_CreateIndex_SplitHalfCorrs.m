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
close all;

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
    
    clear oriCorrMatPart sizeCorrMatPart
    
    % Load in preprocessed data
    %     cd(sprintf('%s',subjList{n},'/',subjList{n},'_results'))
    %     load(sprintf('%s',subjList{n},'_segOriAve.mat'),'ERP_segOriAve');   % Load ori
    cd(sprintf('%s',subjList{n},'/',subjList{n},'_results_30HzLP/Split_Half_Corrs/'))
    load(sprintf('%s',subjList{n},'_SplitHalf_2_30HzLP.mat'),'oriCorrMatPart');   % Load ori
    SHOri(n,:,:,:) = oriCorrMatPart;
    %     load(sprintf('%s',subjList{n},'_segSizeAve.mat'),'ERP_segSizeAve');   % Load size
    load(sprintf('%s',subjList{n},'_SplitHalf_2_30HzLP.mat'),'sizeCorrMatPart');   % Load size
    SHSize(n,:,:,:) = sizeCorrMatPart;
    cd ../../../
    
end

%% Create an index

% Determine what combinations are needed for each step size
indCombos{1} = [1 1; 2 2 ; 3 3; 4 4; 5 5];
indCombos{2} = [1 2; 2 3; 3 4; 4 5];
indCombos{3} = [1 3; 2 4; 3 5];
indCombos{4} = [1 4;2 5];
indCombos{5} = [1 5];

% First take an average of all combinations in each step size for each time point
for i=1:size(SHOri,1)   % Participant
    for j=1:size(indCombos,2)   
        for l=1:size(SHOri,4)   % Time points
            clear oriStepAvesHolder sizeStepAvesHolder
            for k=1:size(indCombos{j},1)   % Combination of conditions for this step size 
                
                oriStepAvesHolder(k) = SHOri(i,indCombos{j}(k,1),indCombos{j}(k,2),l);
                sizeStepAvesHolder(k) = SHSize(i,indCombos{j}(k,1),indCombos{j}(k,2),l);
            
            end
            
            % Average together each r value
            oriStepAves(i,j,l) = mean(oriStepAvesHolder);
            sizeStepAves(i,j,l) = mean(sizeStepAvesHolder);
            
        end
    end
end

% Create index from the split half correlation data using formula:
% (Step1)-(Step2) / (Step1+Step2)
% for each timepoint for each comparison.
% Do this in terms of step size (0: 1v1,2v2,3v3,etc; 1: 1v2,2v3,etc)
% Data format: subj x lvl x lvl x time point
for i=1:size(SHOri,1)   % Participant
    counter = 1;
    for j=2:size(indCombos,2)   % Step size (start at 2)
        for l=1:size(SHOri,4)   % Time point
            
            % Frist just look at the differences
            oriDiff(i,counter,l) = oriStepAves(i,1,l) - oriStepAves(i,j,l);
            sizeDiff(i,counter,l) = sizeStepAves(i,1,l) - sizeStepAves(i,j,l);
            
            % Create index
            oriIndex(i,counter,l) = (abs(oriStepAves(i,1,l)) - abs(oriStepAves(i,j,l))) / abs((oriStepAves(i,1,l)) + abs(oriStepAves(i,j,l)));
            sizeIndex(i,counter,l) = (abs(sizeStepAves(i,1,l)) - abs(sizeStepAves(i,j,l))) / abs((sizeStepAves(i,1,l)) + abs(sizeStepAves(i,j,l)));
            
        end
        counter = counter+1;
    end
end

% Average across participants
oriIndexPartAve = squeeze(mean(oriIndex,1));
oriIndexPartSTE = squeeze(ste(oriIndex,1));
sizeIndexPartAve = squeeze(mean(sizeIndex,1));
sizeIndexPartSTE = squeeze(ste(sizeIndex,1));

% % Average together relevant time points from 200-450ms
% oriIndexTimeAve = mean(oriIndexPartAve(:,200:450),2);
% oriIndexTimeSTE = mean(oriIndexPartSTE(:,200:450),2);
% sizeIndexTimeAve = mean(sizeIndexPartAve(:,200:450),2);
% sizeIndexTimeSTE = mean(sizeIndexPartSTE(:,200:450),2);
% % Plot averages over time w/ error
% % Ori
% figure()
% bar(oriIndexTimeAve);
% hold on
% errorbar(oriIndexTimeAve,oriIndexTimeSTE,'.k');
% % Size
% figure()
% bar(sizeIndexTimeAve);
% hold on
% errorbar(sizeIndexTimeAve,sizeIndexTimeSTE,'.k');
% 
% % Plot a bar graph of the index values over time for each step size
% % Ori
% figure()
% for i=1:size(oriIndexPartAve,1)
%     subplot(1,4,i)
%     bar(oriIndexPartAve(i,:));
%     errorbar(oriIndexPartAve(i,:),oriIndexPartSTE(i,:),'.k');
% end
% % Size
% figure()
% for i=1:size(sizeIndexPartAve,1)
%     subplot(1,4,i)
%     bar(sizeIndexPartAve(i,:))
%     errorbar(sizeIndexPartAve(i,:),sizeIndexPartSTE(i,:),'.k');
% end
% 
% % Heat maps
% figure()
% imagesc([oriIndexPartAve(1,:);oriIndexPartAve(2,:);oriIndexPartAve(3,:);oriIndexPartAve(4,:)],[-.5 .5])
% yticklabels({'Step 1','Step 2','Step 3','Step 4'});
% yticks([1:4]);
% set(gca,'TickLength',[0 0]);
% colorbar('Ticks',[-.5 .5]);

% Line graphs w/ error bars
% Orientation 
figure()
for i=1:4
    subplot(4,1,i)
    plot(1:size(oriIndexPartAve,2),oriIndexPartAve(i,:))
    hold on
    errorbar(1:size(oriIndexPartAve,2),oriIndexPartAve(i,:),oriIndexPartSTE(i,:),'.k')
    plot(1:550,zeros([1,550]),'k')   % Horizontal line at 0
    yticks([-.5:.1:.5])
    ylim([-.5 .5])
end
% Size
figure()
for i=1:4
    subplot(4,1,i)
    plot(1:size(sizeIndexPartAve,2),sizeIndexPartAve(i,:))
    hold on
    errorbar(1:size(sizeIndexPartAve,2),sizeIndexPartAve(i,:),sizeIndexPartSTE(i,:),'.k')
    plot(1:550,zeros([1,550]),'k')   % Horizontal line at 0
    yticks([-.5:.1:.5])
    ylim([-.5 .5])
end

% Plot individual time point
timePoints2Plot{1} = [190 195 200 205 210];
timePoints2Plot{2} = [290 295 300 305 310];
timePoints2Plot{3} = [340 345 350 355 360];
timePoints2Plot{4} = [390 395 400 405 410];
timePoints2Plot{5} = [440 445 450 455 460];
timePoints2Plot{6} = [490 495 500 505 510];
for j=1:length(timePoints2Plot)
    figure()
    counter = 1;
    for i=1:2:length(timePoints2Plot{j})*2
        
        % Ori
        subplot(5,2,i)
        bar(oriIndexPartAve(:,timePoints2Plot{j}(counter)));
        hold on
        errorbar(oriIndexPartAve(:,timePoints2Plot{j}(counter)),oriIndexPartSTE(:,timePoints2Plot{j}(counter)),'.k');
        
        % Size
        subplot(5,2,i+1)
        bar(sizeIndexPartAve(:,timePoints2Plot{j}(counter)));
        hold on
        errorbar(sizeIndexPartAve(:,timePoints2Plot{j}(counter)),sizeIndexPartSTE(:,timePoints2Plot{j}(counter)),'.k');
        
        counter=counter+1;
        
    end
end

%% Difference waves
% Calculate a differnce wave
% for i=1:size(compArray,1)
%     segOriDiff(i,:,:,:) = squeeze(SHOri(:,compArray(i,2),:,:) - SHOri(:,compArray(i,1),:,:));
%     segSizeDiff(i,:,:,:) = squeeze(SHsegSize(:,compArray(i,2),:,:) - SHsegSize(:,compArray(i,1),:,:));
% end











