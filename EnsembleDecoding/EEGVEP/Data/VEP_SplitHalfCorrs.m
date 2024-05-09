%% This script loads in the VEP data and divides it into categories. Divides the categories
% into two halves and performs coerrelations between/within groups over time. 

% close all; 
clear all;

cd ../../
ensDataStructBehav = ensLoadData('VEPBehav','All');
cd ./'EEG VEP'/Data/

subjList = ensDataStructBehav.subjid;

for n=1:length(subjList)
% for n=1

    %% Load in/Prep the data
    clearvars -except oriCorr sizeCorr subjList n oriCorrMat sizeCorrMat oriCorrDiff sizeCorrDiff interpOriSplitAve interpSizeSplitAve
    
    % Preallocate variables for speed
    interpOri = cell(1,5);
    interpSize = cell(1,5);
    interpOriMat = cell(1,5);
    interpSizeMat = cell(1,5);
    
    cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_30HzLP'))
    interp1 = load(sprintf('%s',subjList{n},'_Ens_VEP_Prep_1.mat'),'interp');
    interp2 = load(sprintf('%s',subjList{n},'_Ens_VEP_Prep_2.mat'),'interp');
    cd ../../
    
    interp1 = interp1.interp;
    interp2 = interp2.interp;
    
    % Manually combine the info files since ft_appenddata doesn't do this
    info_comb = cat(1,interp1.info,interp2.info);
    sampleinfo_comb = cat(1,interp1.sampleinfo,interp2.sampleinfo+interp1.sampleinfo(end,2)+10);
    
    % Combine the two runs into one file using ft_appenddata
    interp_comb = ft_appenddata([],interp1,interp2);
    interp_comb.info = info_comb;
    interp_comb.sampleinfo = sampleinfo_comb;
    
    % Seperate the conditions into their own arrays to split later
    for i=1:5   % For all conditions
        interpOri{i} = interp_comb.trial(interp_comb.trialinfo(:,2)==i);
        interpSize{i} = interp_comb.trial(interp_comb.trialinfo(:,3)==i);
    end
    
    % Turn into arrays that are easier to work with 
    for i=1:length(interpOri)
        for j=1:length(interpOri{i})
            interpOriMat{i}(j,:,:) = interpOri{i}{j}(:,:);
        end
    end
    for i=1:length(interpSize)
        for j=1:length(interpSize{i})
            interpSizeMat{i}(j,:,:) = interpSize{i}{j}(:,:);
        end
    end
    
    % Divide into halves randomly
    for i=1:5   % For all levels
        disp(i)
        
        % Ori
        clear split_data half_1_ori half_2_ori
        split_data = randperm(size(interpOriMat{i},1));
        half_1_ori = split_data(1:floor(length(split_data)/2));
        half_2_ori = split_data(floor(length(split_data)/2)+1:end);
        for k=1:size(half_1_ori,2)
            interpOriSplit{n,i,1}(k,:,:) = interpOriMat{i}(half_1_ori(k),:,:);
        end
        for k=1:size(half_2_ori,2)
            interpOriSplit{n,i,2}(k,:,:) = interpOriMat{i}(half_2_ori(k),:,:);
        end
        
        % Size
        clear split_data half_1_size half_2_size
        split_data = randperm(size(interpSizeMat{i},1));
        half_1_size = split_data(1:floor(length(split_data)/2));
        half_2_size = split_data(floor(length(split_data)/2)+1:end);
        
        for k=1:size(half_1_size,2)
            interpSizeSplit{n,i,1}(k,:,:) = interpSizeMat{i}(half_1_size(k),:,:);
        end
        for k=1:size(half_2_size,2)
            interpSizeSplit{n,i,2}(k,:,:) = interpSizeMat{i}(half_2_size(k),:,:);
        end
    end
    
    % Average trials in each half
    %%%%%%%%%%%% MAYBE AVERAGE AND BASELINE CORRECT HERE???? %%%%%%%%%%%%%
%     for i=1:size(interpOriSplit,2)
%        interpOriSplitAve(n,i,1,:,:) = squeeze(mean(interpOriSplit{n,i,1},1));   % Ori first half
%        interpOriSplitAve(n,i,2,:,:) = squeeze(mean(interpOriSplit{n,i,2},1));   % Ori second half
%        
%        interpSizeSplitAve(n,i,1,:,:) = squeeze(mean(interpSizeSplit{n,i,1},1));   % Ori first half
%        interpSizeSplitAve(n,i,2,:,:) = squeeze(mean(interpSizeSplit{n,i,2},1));   % Ori second half
%     end
    
    % Average and BLC using FT
    % Ori
    for i=1:size(interpOriSplit,2)
        clear holderInterp1 holderInterp2
        
        cfg.baseline = [-50 0];
        
        % Set up interp files for FT (Not sure if all of these are needed)
        for j=1:size(interpOriSplit{n,i,1},1)   
            holderInterp1.trial{j}(:,:) = interpOriSplit{n,i,1}(j,:,:);   % Trials
            holderInterp1.time{j} = 0:.001:.549;   % Time points
            holderInterp1.trialinfo(j) = i;   % Trial info
        end
        for j=1:size(interpOriSplit{n,i,2},1)
            holderInterp2.trial{j}(:,:) = interpOriSplit{n,i,2}(j,:,:);
            holderInterp2.time{j} = 0:.001:.549;
            holderInterp1.trialinfo(j) = i;
        end
        holderInterp1.label = interp_comb.label;   % Labels
        holderInterp2.label = interp_comb.label;
        holderInterp1.fsample = 1000;   % Num samples
        holderInterp1.fsample = 1000;
        
        interpOriSplitAveFT{i,1}.av = ft_timelockanalysis([],holderInterp1);
        interpOriSplitAveFT{i,2}.av = ft_timelockanalysis([],holderInterp2);
        
        [interpOriSplitAveFT{i,1}.av] = ft_timelockbaseline(cfg,interpOriSplitAveFT{i,1}.av);
        [interpOriSplitAveFT{i,2}.av] = ft_timelockbaseline(cfg,interpOriSplitAveFT{i,2}.av);
        
        % Save to a matrix
        interpOriSplitAve(n,i,1,:,:) = interpOriSplitAveFT{i,1}.av.avg;
        interpOriSplitAve(n,i,2,:,:) = interpOriSplitAveFT{i,2}.av.avg;
    end
    % Size
    for i=1:size(interpSizeSplit,2)
        clear holderInterp1 holderInterp2
        
        cfg.baseline = [-50 0];
        
        % Set up interp files for FT (Not sure if all of these are needed)
        for j=1:size(interpSizeSplit{n,i,1},1)   
            holderInterp1.trial{j}(:,:) = interpSizeSplit{n,i,1}(j,:,:);   % Trials
            holderInterp1.time{j} = 0:.001:.549;   % Time points
            holderInterp1.trialinfo(j) = i;   % Trial info
        end
        for j=1:size(interpSizeSplit{n,i,2},1)
            holderInterp2.trial{j}(:,:) = interpSizeSplit{n,i,2}(j,:,:);
            holderInterp2.time{j} = 0:.001:.549;
            holderInterp1.trialinfo(j) = i;
        end
        holderInterp1.label = interp_comb.label;   % Labels
        holderInterp2.label = interp_comb.label;
        holderInterp1.fsample = 1000;   % Num samples
        holderInterp1.fsample = 1000;
        
        interpSizeSplitAveFT{i,1}.av = ft_timelockanalysis([],holderInterp1);
        interpSizeSplitAveFT{i,2}.av = ft_timelockanalysis([],holderInterp2);
        
        [interpSizeSplitAveFT{i,1}.av] = ft_timelockbaseline(cfg,interpSizeSplitAveFT{i,1}.av);
        [interpSizeSplitAveFT{i,2}.av] = ft_timelockbaseline(cfg,interpSizeSplitAveFT{i,2}.av);
        
        % Save to a matrix
        interpSizeSplitAve(n,i,1,:,:) = interpSizeSplitAveFT{i,1}.av.avg;
        interpSizeSplitAve(n,i,2,:,:) = interpSizeSplitAveFT{i,2}.av.avg;
    end
    
    %% Plot the waveforms in each half
    subPlotOrder1 = 1:2:9;
    subPlotOrder2 = 2:2:10;
    % Orientation
    figure('Name',sprintf('%s%s',subjList{n},' Butterfly Plots Orientation'))
    for i=1:5   % For all levels
        subplot(5,2,subPlotOrder1(i))
        plot(squeeze(interpOriSplitAve(n,i,1,:,:))')
        title(sprintf('%s',subjList{n},' half 1'))
        
        subplot(5,2,subPlotOrder2(i))
        plot(squeeze(interpOriSplitAve(n,i,2,:,:))')
        title(sprintf('%s',subjList{n},' half 2'))
    end   
    
    % Size0
    figure('Name',sprintf('%s%s',subjList{n},' Butterfly Plots Size'))
    for i=1:5   % For all levels
        subplot(5,2,subPlotOrder1(i))
        plot(squeeze(interpSizeSplitAve(n,i,1,:,:))')
        title(sprintf('%s',subjList{n},' half 1'))
        
        subplot(5,2,subPlotOrder2(i))
        plot(squeeze(interpSizeSplitAve(n,i,2,:,:))')
        title(sprintf('%s',subjList{n},' half 2'))
    end
    
    %% Split half analysis
    % Correlate halves
    for i=1:size(interpOriSplit,2)   % Correlate each half of each condition with the other of each other condition
        for j=1:size(interpOriSplit,2)
            for k=1:size(interp_comb.trial{1},2)   % For each time point
                
                % Make a matrix with 2 columns to feed into the corr
                % Each column contains values from 1 timepoint for every
                % electrode from the two conditions being correlated. 
                holderMatOri(:,:) = squeeze([interpOriSplitAve(n,i,1,:,k), interpOriSplitAve(n,j,2,:,k)]);
                holderMatSize(:,:) = squeeze([interpSizeSplitAve(n,i,1,:,k), interpSizeSplitAve(n,j,2,:,k)]);
                
                % Do the correlation store for all comparisons
                oriCorr{n,i,j,k} = corrcoef(holderMatOri(1,:),holderMatOri(2,:));
                sizeCorr{n,i,j,k} = corrcoef(holderMatSize(1,:),holderMatSize(2,:));
                
                % Store single 'r' value in a matrix
                oriCorrMat(n,i,j,k) = oriCorr{n,i,j,k}(1,2);
                sizeCorrMat(n,i,j,k) = sizeCorr{n,i,j,k}(1,2);
                
            end
        end
    end
    
    % Take the difference between the within/between corr
    oriCorrDiff(n,1,:) = squeeze(oriCorrMat(n,1,1,:)) - squeeze(mean(squeeze([oriCorrMat(n,1,2,:),oriCorrMat(n,1,3,:),oriCorrMat(n,1,4,:),oriCorrMat(n,1,5,:)]),1))';
    oriCorrDiff(n,2,:) = squeeze(oriCorrMat(n,2,2,:)) - squeeze(mean(squeeze([oriCorrMat(n,2,1,:),oriCorrMat(n,2,3,:),oriCorrMat(n,2,4,:),oriCorrMat(n,2,5,:)]),1))';
    oriCorrDiff(n,3,:) = squeeze(oriCorrMat(n,3,3,:)) - squeeze(mean(squeeze([oriCorrMat(n,3,1,:),oriCorrMat(n,3,2,:),oriCorrMat(n,3,4,:),oriCorrMat(n,3,5,:)]),1))';
    oriCorrDiff(n,4,:) = squeeze(oriCorrMat(n,4,4,:)) - squeeze(mean(squeeze([oriCorrMat(n,4,1,:),oriCorrMat(n,4,2,:),oriCorrMat(n,4,3,:),oriCorrMat(n,4,5,:)]),1))';
    oriCorrDiff(n,5,:) = squeeze(oriCorrMat(n,5,5,:)) - squeeze(mean(squeeze([oriCorrMat(n,5,1,:),oriCorrMat(n,5,2,:),oriCorrMat(n,5,3,:),oriCorrMat(n,5,4,:)]),1))';

    sizeCorrDiff(n,1,:) = squeeze(sizeCorrMat(n,1,1,:)) - squeeze(mean(squeeze([sizeCorrMat(n,1,2,:),sizeCorrMat(n,1,3,:),sizeCorrMat(n,1,4,:),sizeCorrMat(n,1,5,:)]),1))';
    sizeCorrDiff(n,2,:) = squeeze(sizeCorrMat(n,2,2,:)) - squeeze(mean(squeeze([sizeCorrMat(n,2,1,:),sizeCorrMat(n,2,3,:),sizeCorrMat(n,2,4,:),sizeCorrMat(n,2,5,:)]),1))';
    sizeCorrDiff(n,3,:) = squeeze(sizeCorrMat(n,3,3,:)) - squeeze(mean(squeeze([sizeCorrMat(n,3,1,:),sizeCorrMat(n,3,2,:),sizeCorrMat(n,3,4,:),sizeCorrMat(n,3,5,:)]),1))';
    sizeCorrDiff(n,4,:) = squeeze(sizeCorrMat(n,4,4,:)) - squeeze(mean(squeeze([sizeCorrMat(n,4,1,:),sizeCorrMat(n,4,2,:),sizeCorrMat(n,4,3,:),sizeCorrMat(n,4,5,:)]),1))';
    sizeCorrDiff(n,5,:) = squeeze(sizeCorrMat(n,5,5,:)) - squeeze(mean(squeeze([sizeCorrMat(n,5,1,:),sizeCorrMat(n,5,2,:),sizeCorrMat(n,5,3,:),sizeCorrMat(n,5,4,:)]),1))';
    
%     for n=1:16
%         oriCorrDiff(n,1,:) = squeeze(oriCorrMat(n,1,1,:)) - squeeze(mean(squeeze([oriCorrMat(n,2,1,:),oriCorrMat(n,3,1,:),oriCorrMat(n,4,1,:),oriCorrMat(n,5,1,:)]),1))';
%         oriCorrDiff(n,2,:) = squeeze(oriCorrMat(n,2,2,:)) - squeeze(mean(squeeze([oriCorrMat(n,1,2,:),oriCorrMat(n,3,2,:),oriCorrMat(n,4,2,:),oriCorrMat(n,5,2,:)]),1))';
%         oriCorrDiff(n,3,:) = squeeze(oriCorrMat(n,3,3,:)) - squeeze(mean(squeeze([oriCorrMat(n,1,3,:),oriCorrMat(n,2,3,:),oriCorrMat(n,4,3,:),oriCorrMat(n,5,3,:)]),1))';
%         oriCorrDiff(n,4,:) = squeeze(oriCorrMat(n,4,4,:)) - squeeze(mean(squeeze([oriCorrMat(n,1,4,:),oriCorrMat(n,2,4,:),oriCorrMat(n,3,4,:),oriCorrMat(n,5,4,:)]),1))';
%         oriCorrDiff(n,5,:) = squeeze(oriCorrMat(n,5,5,:)) - squeeze(mean(squeeze([oriCorrMat(n,1,5,:),oriCorrMat(n,2,5,:),oriCorrMat(n,3,5,:),oriCorrMat(n,4,5,:)]),1))';
%         
%         sizeCorrDiff(n,1,:) = squeeze(sizeCorrMat(n,1,1,:)) - squeeze(mean(squeeze([sizeCorrMat(n,2,1,:),sizeCorrMat(n,3,1,:),sizeCorrMat(n,4,1,:),sizeCorrMat(n,5,1,:)]),1))';
%         sizeCorrDiff(n,2,:) = squeeze(sizeCorrMat(n,2,2,:)) - squeeze(mean(squeeze([sizeCorrMat(n,1,2,:),sizeCorrMat(n,3,2,:),sizeCorrMat(n,4,2,:),sizeCorrMat(n,5,2,:)]),1))';
%         sizeCorrDiff(n,3,:) = squeeze(sizeCorrMat(n,3,3,:)) - squeeze(mean(squeeze([sizeCorrMat(n,1,3,:),sizeCorrMat(n,2,3,:),sizeCorrMat(n,4,3,:),sizeCorrMat(n,5,3,:)]),1))';
%         sizeCorrDiff(n,4,:) = squeeze(sizeCorrMat(n,4,4,:)) - squeeze(mean(squeeze([sizeCorrMat(n,1,4,:),sizeCorrMat(n,2,4,:),sizeCorrMat(n,3,4,:),sizeCorrMat(n,5,4,:)]),1))';
%         sizeCorrDiff(n,5,:) = squeeze(sizeCorrMat(n,5,5,:)) - squeeze(mean(squeeze([sizeCorrMat(n,1,5,:),sizeCorrMat(n,2,5,:),sizeCorrMat(n,3,5,:),sizeCorrMat(n,4,5,:)]),1))';
%     end
    
    disp(n)
    
    %% Save
    %Create folder to store results for subject & naviagte into that folder
    %         resultsDir = sprintf('%s%s',subjList{n},'_results');
    resultsDir = 'Split_Half_Corrs';
    % check to see if this file exists
    cd(sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_30HzLP'))
    if exist(resultsDir,'file')
    else
        mkdir(resultsDir);
    end
    cd ./Split_Half_Corrs/
  
    % Save the preprocessing data for each participant in their respective
    % folders
    oriCorrMatPart = squeeze(oriCorrMat(n,:,:,:));
    sizeCorrMatPart = squeeze(sizeCorrMat(n,:,:,:));
    sizeCorrDiffPart = squeeze(sizeCorrDiff(n,:,:));
    oriCorrDiffPart = squeeze(oriCorrDiff(n,:,:));
    save(sprintf('%s%s',subjList{n},'_SplitHalf_2_30HzLP'),'oriCorrMatPart','sizeCorrMatPart','sizeCorrDiffPart','oriCorrDiffPart');
    
    % CD back to the data folder for next participant
    cd ../../../
end


%% Group analysis
% Average across participants
oriCorrAve = squeeze(mean(oriCorrMat,1));
sizeCorrAve = squeeze(mean(sizeCorrMat,1));

oriCorrDiffAve(:,:) = squeeze(mean(oriCorrDiff,1));
oriCorrDiffSTE(:,:) = squeeze(ste(oriCorrDiff,1));

sizeCorrDiffAve(:,:) = squeeze(mean(sizeCorrDiff,1));
sizeCorrDiffSTE(:,:) = squeeze(ste(sizeCorrDiff,1));

interpOriSplitPartAve = squeeze(mean(interpOriSplitAve,1));
interpSizeSplitPartAve = squeeze(mean(interpSizeSplitAve,1));

% Do the split half correlation of participant averaged data
% Correlate halves
% for i=1:size(interpOriSplitPartAve,1)   % Correlate each half of each condition with the other of each other condition
%     for j=1:size(interpOriSplitPartAve,1)
%         for k=1:size(interpOriSplitPartAve,4)   % For each time point
%             
%             % Make a matrix with 2 columns to feed into the corr
%             % Each column contains values from 1 timepoint for every
%             % electrode from the two conditions being correlated.
%             holderMatOri(:,:) = squeeze([interpOriSplitPartAve(i,1,:,k), interpOriSplitPartAve(j,2,:,k)]);
%             holderMatSize(:,:) = squeeze([interpSizeSplitPartAve(i,1,:,k), interpSizeSplitPartAve(j,2,:,k)]);
%             
%             % Do the correlation store for all comparisons
%             oriCorrPartAve{i,j,k} = corrcoef(holderMatOri(1,:),holderMatOri(2,:));
%             sizeCorrPartAve{i,j,k} = corrcoef(holderMatSize(1,:),holderMatSize(2,:));
%             
%             % Store single 'r' value in a matrix
%             oriCorrMatPartAve(i,j,k) = oriCorrPartAve{i,j,k}(1,2);
%             sizeCorrMatPartAve(i,j,k) = sizeCorrPartAve{i,j,k}(1,2);
%             
%         end
%     end
% end


%% Plot the data
%% Plot butterfly plots for size/ori
subPlotOrder1 = 1:2:9;
subPlotOrder2 = 2:2:10;
% Orientation
figure('Name','Average Butterfly Plots Orientation')
for i=1:5   % For all levels
    subplot(5,2,subPlotOrder1(i))
    plot(squeeze(interpOriSplitPartAve(i,1,:,:))')
    title(sprintf('%s%d%s','Ori Level: ', i, ' half 1'))
    
    subplot(5,2,subPlotOrder2(i))
    plot(squeeze(interpOriSplitPartAve(i,2,:,:))')
    title(sprintf('%s%d%s','Ori Level: ', i, ' half 2'))
end
% Size
figure('Name','Average Butterfly Plots Size')
for i=1:5   % For all levels
    subplot(5,2,subPlotOrder1(i))
    plot(squeeze(interpSizeSplitPartAve(i,1,:,:))')
    title(sprintf('%s%d%s','Size Level: ', i, ' half 1'))
    
    subplot(5,2,subPlotOrder2(i))
    plot(squeeze(interpSizeSplitPartAve(i,2,:,:))')
    title(sprintf('%s%d%s','Size Level: ', i, ' half 2'))
end

% % Plot heat maps over time on correlations done on averaged data
% % Orientation
% figure('Name','Orientation Correlations Over Time (Part Ave)')
% suptitle('Orientation Correlations Over Time (Part Ave)')
% for i=1:5
%     subplot(5,1,i)
%     imagesc(squeeze([oriCorrMatPartAve(i,1,:),oriCorrMatPartAve(i,2,:),oriCorrMatPartAve(i,3,:),oriCorrMatPartAve(i,4,:),oriCorrMatPartAve(i,5,:)]),[-1 1]);
%     hold on
%     title(sprintf('%s%d','Orientation Level: ',i))
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     colorbar
% end
% 
% % Size
% figure('Name','Size Correlations Over Time (Part Ave)')
% suptitle('Size Correlations Over Time (Part Ave)')
% for i=1:5
%     subplot(5,1,i)
%     imagesc(squeeze([sizeCorrMatPartAve(i,1,:),sizeCorrMatPartAve(i,2,:),sizeCorrMatPartAve(i,3,:),sizeCorrMatPartAve(i,4,:),sizeCorrMatPartAve(i,5,:)]),[-1 1]);
%     hold on
%     title(sprintf('%s%d','Size Level: ',i))
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     colorbar
% end

%% Plot heat maps over time
% Orientation 
figure('Name','Orientation Correlations Over Time')
suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    imagesc(squeeze([oriCorrAve(i,1,:),oriCorrAve(i,2,:),oriCorrAve(i,3,:),oriCorrAve(i,4,:),oriCorrAve(i,5,:)]),[-1 1]);
    hold on
    title(sprintf('%s%d','Orientation Level: ',i))
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
end

% Size
figure('Name','Size Correlations Over Time')
suptitle('Size Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    imagesc(squeeze([sizeCorrAve(i,1,:),sizeCorrAve(i,2,:),sizeCorrAve(i,3,:),sizeCorrAve(i,4,:),sizeCorrAve(i,5,:)]),[-1 1]);
    hold on
    title(sprintf('%s%d','Size Level: ',i))
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
end

%% Plot correlation matrices for time points every 50 ms for size and ori
timeSteps = 100:100:500;

% Ori
figure('Name','Select Orientation Correlation Matrices Over Time')
suptitle(sprintf('%s\n\n','Select Orientation Correlation Matrices Over Time'))
for i=1:length(timeSteps)
    subplot(1,length(timeSteps),i)
    imagesc(oriCorrAve(:,:,timeSteps(i)),[-1 1]);
    hold on
    title(sprintf('%s%d','Time Point: ',timeSteps(i)))
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar    
end

% Size
figure('Name','Select Size Correlation Matrices Over Time')
suptitle(sprintf('%s\n\n','Select Size Correlation Matrices Over Time'))
for i=1:length(timeSteps)
    subplot(1,length(timeSteps),i)
    imagesc(sizeCorrAve(:,:,timeSteps(i)),[-1 1]);
    hold on
    title(sprintf('%s%d','Time Point: ',timeSteps(i)))
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar    
end


%% Plot differences between between/within corrs
figure('Name','Difference Between Within/Between Correlations Over Time: Orientation')
for i=1:5
    subplot(5,1,i)
    shadedErrorBar([],squeeze(oriCorrDiffAve(i,:)),squeeze(oriCorrDiffSTE(i,:)));
    hold on
    ylim([-.4 .4]);
    yline(0,'k');   % Horizontal line at 0
    title(sprintf('%s%d','Orientation Level: ',i))
end

figure('Name','Difference Between Within/Between Correlations Over Time: Size')
for i=1:5
    subplot(5,1,i)
    shadedErrorBar([],squeeze(sizeCorrDiffAve(i,:)),squeeze(sizeCorrDiffSTE(i,:)));
    hold on
    ylim([-.4 .4]);
    yline(0,'k');   % Horizontal line at 0
    title(sprintf('%s%d','Size Level: ',i))
end


%% Save
%Create folder to store results for subject & naviagte into that folder
%         resultsDir = sprintf('%s%s',subjList{n},'_results');
resultsDir = 'Split_Half_Corrs';
% check to see if this file exists
cd('./Group_Results')
if exist(resultsDir,'file')
else
    mkdir(resultsDir);
end
cd(sprintf('%s','./',resultsDir))

% Save the preprocessing data for each participant in their respective
% folders
save('SplitHalf_2_30HzLP','sizeCorrDiffAve','sizeCorrDiffSTE','oriCorrDiffAve','oriCorrDiffSTE','oriCorrAve','oriCorrMat','sizeCorrAve','sizeCorrMat');

% CD back to the data folder for next participant
cd ../../












