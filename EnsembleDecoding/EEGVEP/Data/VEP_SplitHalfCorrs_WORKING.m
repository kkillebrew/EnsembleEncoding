%% This script loads in the VEP data and divides it into categories. Divides the categories
% into two halves and performs coerrelations between/within groups over time.

% close all;
clear all;

cd ../../
ensDataStructBehav = ensLoadData('VEPBehav','All');
cd ./'EEG VEP'/Data/

subjList = ensDataStructBehav.subjid;

for n=1:length(subjList)
% for n=5
    
    %% Load in/Prep the data
    clearvars -except oriCorr sizeCorr subjList n oriCorrMat sizeCorrMat oriCorrDiff sizeCorrDiff interpOriSplitAve interpSizeSplitAve
    
    % Preallocate variables for speed
    interpOri = cell(1,5);
    interpSize = cell(1,5);
    interpOriMat = cell(1,5);
    interpSizeMat = cell(1,5);
    
    %     cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_30HzLP'))
    cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
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
            holderInterp1.time{j} = 0:.001:.699;   % Time points
            holderInterp1.trialinfo(j) = i;   % Trial info
        end
        for j=1:size(interpOriSplit{n,i,2},1)
            holderInterp2.trial{j}(:,:) = interpOriSplit{n,i,2}(j,:,:);
            holderInterp2.time{j} = 0:.001:.699;
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
            holderInterp1.time{j} = 0:.001:.699;   % Time points
            holderInterp1.trialinfo(j) = i;   % Trial info
        end
        for j=1:size(interpSizeSplit{n,i,2},1)
            holderInterp2.trial{j}(:,:) = interpSizeSplit{n,i,2}(j,:,:);
            holderInterp2.time{j} = 0:.001:.699;
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
    
%     %% Plot the waveforms in each half
%     subPlotOrder1 = 1:2:9;
%     subPlotOrder2 = 2:2:10;
%     % Orientation
%     figure('Name',sprintf('%s%s',subjList{n},' Butterfly Plots Orientation'))
%     for i=1:5   % For all levels
%         subplot(5,2,subPlotOrder1(i))
%         plot(squeeze(interpOriSplitAve(n,i,1,:,:))')
%         title(sprintf('%s',subjList{n},' half 1'))
%         
%         subplot(5,2,subPlotOrder2(i))
%         plot(squeeze(interpOriSplitAve(n,i,2,:,:))')
%         title(sprintf('%s',subjList{n},' half 2'))
%     end
%     
%     % Size0
%     figure('Name',sprintf('%s%s',subjList{n},' Butterfly Plots Size'))
%     for i=1:5   % For all levels
%         subplot(5,2,subPlotOrder1(i))
%         plot(squeeze(interpSizeSplitAve(n,i,1,:,:))')
%         title(sprintf('%s',subjList{n},' half 1'))
%         
%         subplot(5,2,subPlotOrder2(i))
%         plot(squeeze(interpSizeSplitAve(n,i,2,:,:))')
%         title(sprintf('%s',subjList{n},' half 2'))
%     end
%     
    
    %% Z-Score the data
    % Take the mean/std across time for each half
    for j=1:size(interpOriSplitAve,2)   % For each level
        for k=1:size(interpOriSplitAve,3)   % For both halves
            for i=1:size(interpOriSplitAve,4)-1   % For each electrode
                
                % Take mean/std
                holderMeanOri = mean(squeeze(interpOriSplitAve(n,j,k,i,:)));
                holderSTDOri = std(squeeze(interpOriSplitAve(n,j,k,i,:)));
                holderMeanSize = mean(squeeze(interpSizeSplitAve(n,j,k,i,:)));
                holderSTDSize = std(squeeze(interpSizeSplitAve(n,j,k,i,:)));
                
                % Subtract out mean/divide by STD for each electrode and
                % time point
                interpOriSplitAveZScore(n,j,k,i,:) = squeeze(interpOriSplitAve(n,j,k,i,:)) - holderMeanOri;
                interpOriSplitAveZScore(n,j,k,i,:) = squeeze(interpOriSplitAveZScore(n,j,k,i,:)) ./ holderSTDOri;
                
                interpSizeSplitAveZScore(n,j,k,i,:) = squeeze(interpSizeSplitAve(n,j,k,i,:)) - holderMeanSize;
                interpSizeSplitAveZScore(n,j,k,i,:) = squeeze(interpSizeSplitAveZScore(n,j,k,i,:)) ./ holderSTDSize;
                
                % Change NaNs to 0's
                for o=1:size(interpSizeSplitAveZScore,5)
                    if isnan(interpSizeSplitAveZScore(n,j,k,i,o))
                        interpSizeSplitAveZScore(n,j,k,i,o) = 0;
                        interpOriSplitAveZScore(n,j,k,i,o) = 0;
                    end
                end
                
            end
        end
    end
    
    
%     
%     %% Plot the waveforms in for the z-scored data for each half
%     subPlotOrder1 = 1:2:9;
%     subPlotOrder2 = 2:2:10;
%     % Orientation
%     figure('Name',sprintf('%s%s',subjList{n},' Butterfly Plots Z-Scored Orientation'))
%     for i=1:5   % For all levels
%         subplot(5,2,subPlotOrder1(i))
%         plot(squeeze(interpOriSplitAveZScore(n,i,1,:,:))')
%         title(sprintf('%s',subjList{n},' half 1'))
%         
%         subplot(5,2,subPlotOrder2(i))
%         plot(squeeze(interpOriSplitAveZScore(n,i,2,:,:))')
%         title(sprintf('%s',subjList{n},' half 2'))
%     end
%     
%     % Size0
%     figure('Name',sprintf('%s%s',subjList{n},' Butterfly Plots Z-Scored Size'))
%     for i=1:5   % For all levels
%         subplot(5,2,subPlotOrder1(i))
%         plot(squeeze(interpSizeSplitAveZScore(n,i,1,:,:))')
%         title(sprintf('%s',subjList{n},' half 1'))
%         
%         subplot(5,2,subPlotOrder2(i))
%         plot(squeeze(interpSizeSplitAveZScore(n,i,2,:,:))')
%         title(sprintf('%s',subjList{n},' half 2'))
%     end
    
    
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
    
    clear oriCorr sizeCorr holderMatOri holderMatSize
    
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
    
    
    
    %% Split half analysis on z-scored data
    % Correlate halves
    for i=1:size(interpOriSplit,2)   % Correlate each half of each condition with the other of each other condition
        for j=1:size(interpOriSplit,2)
            for k=1:size(interp_comb.trial{1},2)   % For each time point
                
                % Make a matrix with 2 columns to feed into the corr
                % Each column contains values from 1 timepoint for every
                % electrode from the two conditions being correlated.
                holderMatOri(:,:) = squeeze([interpOriSplitAveZScore(n,i,1,1:256,k), interpOriSplitAveZScore(n,j,2,1:256,k)]);
                holderMatSize(:,:) = squeeze([interpSizeSplitAveZScore(n,i,1,1:256,k), interpSizeSplitAveZScore(n,j,2,1:256,k)]);
                
                % Do the correlation store for all comparisons
                oriCorr{n,i,j,k} = corrcoef(holderMatOri(1,:),holderMatOri(2,:));
                sizeCorr{n,i,j,k} = corrcoef(holderMatSize(1,:),holderMatSize(2,:));
                
                % Store single 'r' value in a matrix
                oriCorrMatZScore(n,i,j,k) = oriCorr{n,i,j,k}(1,2);
                sizeCorrMatZScore(n,i,j,k) = sizeCorr{n,i,j,k}(1,2);
                
            end
        end
    end
    
    % Take the difference between the within/between corr
    oriCorrDiffZScore(n,1,:) = squeeze(oriCorrMatZScore(n,1,1,:)) - squeeze(mean(squeeze([oriCorrMatZScore(n,1,2,:),oriCorrMatZScore(n,1,3,:),oriCorrMatZScore(n,1,4,:),oriCorrMatZScore(n,1,5,:)]),1))';
    oriCorrDiffZScore(n,2,:) = squeeze(oriCorrMatZScore(n,2,2,:)) - squeeze(mean(squeeze([oriCorrMatZScore(n,2,1,:),oriCorrMatZScore(n,2,3,:),oriCorrMatZScore(n,2,4,:),oriCorrMatZScore(n,2,5,:)]),1))';
    oriCorrDiffZScore(n,3,:) = squeeze(oriCorrMatZScore(n,3,3,:)) - squeeze(mean(squeeze([oriCorrMatZScore(n,3,1,:),oriCorrMatZScore(n,3,2,:),oriCorrMatZScore(n,3,4,:),oriCorrMatZScore(n,3,5,:)]),1))';
    oriCorrDiffZScore(n,4,:) = squeeze(oriCorrMatZScore(n,4,4,:)) - squeeze(mean(squeeze([oriCorrMatZScore(n,4,1,:),oriCorrMatZScore(n,4,2,:),oriCorrMatZScore(n,4,3,:),oriCorrMatZScore(n,4,5,:)]),1))';
    oriCorrDiffZScore(n,5,:) = squeeze(oriCorrMatZScore(n,5,5,:)) - squeeze(mean(squeeze([oriCorrMatZScore(n,5,1,:),oriCorrMatZScore(n,5,2,:),oriCorrMatZScore(n,5,3,:),oriCorrMatZScore(n,5,4,:)]),1))';
    
    sizeCorrDiffZScore(n,1,:) = squeeze(sizeCorrMatZScore(n,1,1,:)) - squeeze(mean(squeeze([sizeCorrMatZScore(n,1,2,:),sizeCorrMatZScore(n,1,3,:),sizeCorrMatZScore(n,1,4,:),sizeCorrMatZScore(n,1,5,:)]),1))';
    sizeCorrDiffZScore(n,2,:) = squeeze(sizeCorrMatZScore(n,2,2,:)) - squeeze(mean(squeeze([sizeCorrMatZScore(n,2,1,:),sizeCorrMatZScore(n,2,3,:),sizeCorrMatZScore(n,2,4,:),sizeCorrMatZScore(n,2,5,:)]),1))';
    sizeCorrDiffZScore(n,3,:) = squeeze(sizeCorrMatZScore(n,3,3,:)) - squeeze(mean(squeeze([sizeCorrMatZScore(n,3,1,:),sizeCorrMatZScore(n,3,2,:),sizeCorrMatZScore(n,3,4,:),sizeCorrMatZScore(n,3,5,:)]),1))';
    sizeCorrDiffZScore(n,4,:) = squeeze(sizeCorrMatZScore(n,4,4,:)) - squeeze(mean(squeeze([sizeCorrMatZScore(n,4,1,:),sizeCorrMatZScore(n,4,2,:),sizeCorrMatZScore(n,4,3,:),sizeCorrMatZScore(n,4,5,:)]),1))';
    sizeCorrDiffZScore(n,5,:) = squeeze(sizeCorrMatZScore(n,5,5,:)) - squeeze(mean(squeeze([sizeCorrMatZScore(n,5,1,:),sizeCorrMatZScore(n,5,2,:),sizeCorrMatZScore(n,5,3,:),sizeCorrMatZScore(n,5,4,:)]),1))';
    
    
    
    %% Save
    disp(n)
    
    %Create folder to store results for subject & naviagte into that folder
    %         resultsDir = sprintf('%s%s',subjList{n},'_results');
    resultsDir = 'Split_Half_Corrs';
    % check to see if this file exists
    cd(sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
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
    
    oriCorrMatPartZScore = squeeze(oriCorrMatZScore(n,:,:,:));
    sizeCorrMatPartZScore = squeeze(sizeCorrMatZScore(n,:,:,:));
    sizeCorrDiffPartZScore = squeeze(sizeCorrDiffZScore(n,:,:));
    oriCorrDiffPartZScore = squeeze(oriCorrDiffZScore(n,:,:));
    
    save(sprintf('%s%s',subjList{n},'_SplitHalf_2_30HzLP_100msBL'),'oriCorrMatPart','sizeCorrMatPart','sizeCorrDiffPart','oriCorrDiffPart',...
        'oriCorrMatPartZScore','sizeCorrMatPartZScore','sizeCorrDiffPartZScore','oriCorrDiffPartZScore');
    
    % CD back to the data folder for next participant
    cd ../../../
end

% Load in each participant and store in group array (for running group
% analysis w/out re-running the script)
for i=1:length(subjList)
    
    % Load each particpant
    load(sprintf('%s%s%s%s%s%s%s','./',subjList{i},'/',subjList{i},'_results_100msBL_NoReref/Split_Half_Corrs/',subjList{i},'_SplitHalf_2_30HzLP_100msBL'));
    
    oriCorrMat(i,:,:,:) = oriCorrMatPart;
    sizeCorrMat(i,:,:,:) = sizeCorrMatPart;
    oriCorrDiff(i,:,:) = oriCorrDiffPart;
    sizeCorrDiff(i,:,:) = sizeCorrDiffPart;
    
    oriCorrMatZScore(i,:,:,:) = oriCorrMatPartZScore;
    sizeCorrMatZScore(i,:,:,:) = sizeCorrMatPartZScore;
    sizeCorrDiffZScore(i,:,:) = sizeCorrDiffPartZScore;
    oriCorrDiffZScore(i,:,:) = oriCorrDiffPartZScore;
    
end


%% Group analysis
% Average across participants
oriCorrAve = squeeze(mean(oriCorrMat,1));
sizeCorrAve = squeeze(mean(sizeCorrMat,1));

oriCorrDiffAve(:,:) = squeeze(mean(oriCorrDiff,1));
oriCorrDiffSTE(:,:) = squeeze(ste(oriCorrDiff,1));

sizeCorrDiffAve(:,:) = squeeze(mean(sizeCorrDiff,1));
sizeCorrDiffSTE(:,:) = squeeze(ste(sizeCorrDiff,1));

oriCorrAveZScore = squeeze(mean(oriCorrMatZScore,1));
sizeCorrAveZScore = squeeze(mean(sizeCorrMatZScore,1));

oriCorrDiffAveZScore(:,:) = squeeze(mean(oriCorrDiffZScore,1));
oriCorrDiffSTEZScore(:,:) = squeeze(ste(oriCorrDiffZScore,1));

sizeCorrDiffAveZScore(:,:) = squeeze(mean(sizeCorrDiffZScore,1));
sizeCorrDiffSTEZScore(:,:) = squeeze(ste(sizeCorrDiffZScore,1));

% interpOriSplitPartAve = squeeze(mean(interpOriSplitAve,1));
% interpSizeSplitPartAve = squeeze(mean(interpSizeSplitAve,1));

% Save
%Create folder to store results for subject & naviagte into that folder
%         resultsDir = sprintf('%s%s',subjList{n},'_results');
resultsDir = 'Split_Half_Corrs';
% check to see if this file exists
cd('./Group_Results_100msBL_NoReref')
if exist(resultsDir,'file')
else
    mkdir(resultsDir);
end
cd(sprintf('%s','./',resultsDir))
save('SplitHalf_2_30HzLP','sizeCorrDiffAve','sizeCorrDiffSTE','oriCorrDiffAve','oriCorrDiffSTE','oriCorrAve','oriCorrMat','sizeCorrAve','sizeCorrMat',...
    'oriCorrAveZScore','sizeCorrAveZScore','oriCorrDiffAveZScore','oriCorrDiffSTEZScore','sizeCorrDiffAveZScore','sizeCorrDiffSTEZScore');

% CD back to the data folder for next participant
cd ../../




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
% %% Plot butterfly plots for size/ori
% subPlotOrder1 = 1:2:9;
% subPlotOrder2 = 2:2:10;
% % Orientation
% figure('Name','Average Butterfly Plots Orientation')
% for i=1:5   % For all levels
%     subplot(5,2,subPlotOrder1(i))
%     plot(squeeze(interpOriSplitPartAve(i,1,:,:))')
%     title(sprintf('%s%d%s','Ori Level: ', i, ' half 1'))
%
%     subplot(5,2,subPlotOrder2(i))
%     plot(squeeze(interpOriSplitPartAve(i,2,:,:))')
%     title(sprintf('%s%d%s','Ori Level: ', i, ' half 2'))
% end
% % Size
% figure('Name','Average Butterfly Plots Size')
% for i=1:5   % For all levels
%     subplot(5,2,subPlotOrder1(i))
%     plot(squeeze(interpSizeSplitPartAve(i,1,:,:))')
%     title(sprintf('%s%d%s','Size Level: ', i, ' half 1'))
%
%     subplot(5,2,subPlotOrder2(i))
%     plot(squeeze(interpSizeSplitPartAve(i,2,:,:))')
%     title(sprintf('%s%d%s','Size Level: ', i, ' half 2'))
% end

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
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off
lineWidth = 2;
fontSize = 12;

% Orientation
thisFig = figure('Name','Orientation Correlations Over Time','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    imagesc(squeeze([oriCorrAve(i,1,:),oriCorrAve(i,2,:),oriCorrAve(i,3,:),oriCorrAve(i,4,:),oriCorrAve(i,5,:)]),[-1 1]);
    hold on
    title(sprintf('%s%d','Orientation Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    for j=1:5
        yline(j+.5);  % Seperate the correlations
    end
    xline(100,'-','LineWidth',4);   % Mark baseline
    %     ylabel(sprintf('%s\n%s','Feature','Level'),'FontSize',12);
    ylabel('Feature Level','FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Ori_30HzLP_AllComparisons.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Ori_30HzLP_AllComparisons.tif'),'-dtiffn');   % Save .tif


% Size
thisFig = figure('Name','Size Correlations Over Time','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    imagesc(squeeze([sizeCorrAve(i,1,:),sizeCorrAve(i,2,:),sizeCorrAve(i,3,:),sizeCorrAve(i,4,:),sizeCorrAve(i,5,:)]),[-1 1]);
    hold on
    title(sprintf('%s%d','Size Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    for j=1:5
        yline(j+.5);  % Seperate the correlations
    end
    xline(100,'-','LineWidth',4);   % Mark baseline
    ylabel('Feature Level','FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Size_30HzLP_AllComparisons.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Size_30HzLP_AllComparisons.tif'),'-dtiffn');   % Save .tif




%% Plot heat maps over time for z-scored data
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off
lineWidth = 2;
fontSize = 12;

% Orientation
thisFig = figure('Name','Orientation Correlations Over Time','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    imagesc(squeeze([oriCorrAveZScore(i,1,:),oriCorrAveZScore(i,2,:),oriCorrAveZScore(i,3,:),oriCorrAveZScore(i,4,:),oriCorrAveZScore(i,5,:)]),[-.5 .5]);
    hold on
    title(sprintf('%s%d','Orientation Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    for j=1:5
        yline(j+.5);  % Seperate the correlations
    end
    xline(100,'-','LineWidth',4);   % Mark baseline
    %     ylabel(sprintf('%s\n%s','Feature','Level'),'FontSize',12);
    ylabel('Feature Level','FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Ori_30HzLP_AllComparisons_ZScore.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Ori_30HzLP_AllComparisons_ZScore.tif'),'-dtiffn');   % Save .tif


% Size
thisFig = figure('Name','Size Correlations Over Time','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    imagesc(squeeze([sizeCorrAveZScore(i,1,:),sizeCorrAveZScore(i,2,:),sizeCorrAveZScore(i,3,:),sizeCorrAveZScore(i,4,:),sizeCorrAveZScore(i,5,:)]),[-.5 .5]);
    hold on
    title(sprintf('%s%d','Size Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    colorbar
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    for j=1:5
        yline(j+.5);  % Seperate the correlations
    end
    xline(100,'-','LineWidth',4);   % Mark baseline
    ylabel('Feature Level','FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Size_30HzLP_AllComparisons_ZScore.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Size_30HzLP_AllComparisons_ZScore.tif'),'-dtiffn');   % Save .tif






% %% Plot correlation matrices for time points every 50 ms for size and ori
% timeSteps = 100:100:500;
%
% % Ori
% figure('Name','Select Orientation Correlation Matrices Over Time')
% suptitle(sprintf('%s\n\n','Select Orientation Correlation Matrices Over Time'))
% for i=1:length(timeSteps)
%     subplot(1,length(timeSteps),i)
%     imagesc(oriCorrAve(:,:,timeSteps(i)),[-1 1]);
%     hold on
%     title(sprintf('%s%d','Time Point: ',timeSteps(i)))
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     colorbar
% end
%
% % Size
% figure('Name','Select Size Correlation Matrices Over Time')
% suptitle(sprintf('%s\n\n','Select Size Correlation Matrices Over Time'))
% for i=1:length(timeSteps)
%     subplot(1,length(timeSteps),i)
%     imagesc(sizeCorrAve(:,:,timeSteps(i)),[-1 1]);
%     hold on
%     title(sprintf('%s%d','Time Point: ',timeSteps(i)))
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     colorbar
% end


%% Plot differences between between/within corrs

fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off
lineWidth = 2;
fontSize = 12;

% Orientation
thisFig = figure('Name','Between - Within Correlation Differences - Orientation','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    shadedErrorBar([],squeeze(oriCorrDiffAve(i,:)),squeeze(oriCorrDiffSTE(i,:)));
    hold on
    title(sprintf('%s%d','Between - Within Correlation Differences - Orientation Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    yline(0,'k');   % Horizontal line at 0
    xline(100,'-','LineWidth',4);   % Mark baseline
    ylim([-.4 .4]);
    ylabel(sprintf('%s\n%s','Correlation', 'Statistic (r)'),'FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Ori_30HzLP_AllComparisons.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Ori_30HzLP_AllComparisons.tif'),'-dtiffn');   % Save .tif


% Size
thisFig = figure('Name','Between - Within Correlation Differences - Size','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    shadedErrorBar([],squeeze(sizeCorrDiffAve(i,:)),squeeze(sizeCorrDiffSTE(i,:)));
    hold on
    title(sprintf('%s%d','Between - Within Correlation Differences - Size Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    yline(0,'k');   % Horizontal line at 0
    xline(100,'-','LineWidth',4);   % Mark baseline
    ylim([-.4 .4]);
    ylabel(sprintf('%s\n%s','Correlation', 'Statistic (r)'),'FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Size_30HzLP_AllComparisons.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Size_30HzLP_AllComparisons.tif'),'-dtiffn');   % Save .tif



%% Plot differences between between/within corrs on z-scored data

fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off
lineWidth = 2;
fontSize = 12;

% Orientation
thisFig = figure('Name','Between - Within Correlation Differences - Orientation','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    shadedErrorBar([],squeeze(oriCorrDiffAveZScore(i,:)),squeeze(oriCorrDiffSTEZScore(i,:)));
    hold on
    title(sprintf('%s%d','Between - Within Correlation Differences - Z-Scored - Orientation Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    yline(0,'k');   % Horizontal line at 0
    xline(100,'-','LineWidth',4);   % Mark baseline
    ylim([-.4 .4]);
    ylabel(sprintf('%s\n%s','Correlation', 'Statistic (r)'),'FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Ori_30HzLP_AllComparisons_ZScore.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Ori_30HzLP_AllComparisons_ZScore.tif'),'-dtiffn');   % Save .tif


% Size
thisFig = figure('Name','Between - Within Correlation Differences - Size','Units','inches','Position',fig_dims);
% suptitle('Orientation Correlations Over Time')
for i=1:5
    subplot(5,1,i)
    shadedErrorBar([],squeeze(sizeCorrDiffAveZScore(i,:)),squeeze(sizeCorrDiffSTEZScore(i,:)));
    hold on
    title(sprintf('%s%d','Between - Within Correlation Differences - Z-Scored - Size Level: ',i),'FontSize',12)
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    yline(0,'k');   % Horizontal line at 0
    xline(100,'-','LineWidth',4);   % Mark baseline
    ylim([-.4 .4]);
    ylabel(sprintf('%s\n%s','Correlation', 'Statistic (r)'),'FontSize',12);
    
    %Make background white
    set(gcf,'color','white')
    %Specify demensions of figure
    set(thisFig,'position',fig_dims)
    %Set figure thickness and border
    set(gca,'linewidth',fig_size,'box',fig_box)
    
    % y-axis are levels being correlated
    set(gca,'TickLength',[0 0])
    
    thisFig.PaperPositionMode = 'auto';
    thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
end

% Save figures
savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Size_30HzLP_AllComparisons_ZScore.fig'));
print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/Split_Half_Corrs/SplitHalves_Differences_Size_30HzLP_AllComparisons_ZScore.tif'),'-dtiffn');   % Save .tif




% %% Make and save pretty figs for presentations
% % fig_box = 'off'; %Figure border on/off
% fig_dims = [500 500 1500 250];   % Size of figure
% fig_size = 4; %Thickness of borders
% fig_box = 'on'; %Figure border on/off
% 
% % Change directory
% cd ./Figures/PrettyFigs_100msBL/
% 
% % Heat maps
% % Orientation
% for i=1:5
%     %     close all
%     
%     thisFig = figure('Name',sprintf('%s%d','Orientation Correlations Over Time: ', i),'Units','pixels');
%     imagesc(squeeze([oriCorrAve(i,1,2:end),oriCorrAve(i,2,2:end),oriCorrAve(i,3,2:end),oriCorrAve(i,4,2:end),oriCorrAve(i,5,2:end)]),[-1 1]);
%     hold on
%     
%     titleProp = title(sprintf('%s%d','Orientation Correlations Over Time: Level ', i),'FontSize',30,'Units','pixels');
%     xAX = get(gca,'XAxis');   % Change font of x/y ticks
%     set(xAX,'FontSize',15);
%     yAX = get(gca,'YAxis');
%     set(yAX,'FontSize',15);
%     ylabel(sprintf('%s\n%s','Orientation','Level'),'FontSize',25);
%     xlabel('Time (ms)','FontSize',25);
%     xline(50,'-','LineWidth',3);   % Mark baseline
%     yticks([1 2 3 4 5]);
%     
%     %Make background white
%     set(gcf,'color','white')
%     %Specify demensions of figure
%     set(thisFig,'position',fig_dims)
%     %Set figure thickness and border
%     hold on
%     set(gca,'linewidth',fig_size,'box',fig_box)
%     
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     colorbar
%     
%     % Save image
%     thisFig.PaperPositionMode = 'auto';
%     thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
%     print(thisFig,sprintf('%s%d','SplitHalf_OriLvl_',i),'-dpdf')
%     
% end
% 
% % Size
% for i=1:5
%     %     close all
%     
%     thisFig = figure('Name',sprintf('%s%d','Size Correlations Over Time: ', i),'Units','pixels');
%     imagesc(squeeze([sizeCorrAve(i,1,2:end),sizeCorrAve(i,2,2:end),sizeCorrAve(i,3,2:end),sizeCorrAve(i,4,2:end),sizeCorrAve(i,5,2:end)]),[-1 1]);
%     hold on
%     
%     titleProp = title(sprintf('%s%d','Size Correlations Over Time: Level ', i),'FontSize',30,'Units','pixels');
%     xAX = get(gca,'XAxis');   % Change font of x/y ticks
%     set(xAX,'FontSize',15);
%     yAX = get(gca,'YAxis');
%     set(yAX,'FontSize',15);
%     ylabel(sprintf('%s\n%s','Size','Level'),'FontSize',25);
%     xlabel('Time (ms)','FontSize',25);
%     xline(50,'-','LineWidth',3);   % Mark baseline
%     yticks([1 2 3 4 5]);
%     
%     %Make background white
%     set(gcf,'color','white')
%     %Specify demensions of figure
%     set(thisFig,'position',fig_dims)
%     %Set figure thickness and border
%     hold on
%     set(gca,'linewidth',fig_size,'box',fig_box)
%     
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     colorbar
%     
%     % Save image
%     thisFig.PaperPositionMode = 'auto';
%     thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
%     print(thisFig,sprintf('%s%d','SplitHalf_SizeLvl_',i),'-dpdf')
% end
% 
% % Differences between within/between correlations
% for i=1:5
%     %     close all
%     
%     thisFig = figure('Name',sprintf('%s%d%s','Correlation Differences Orientation Level ', i,': Between - Within '),'Units','pixels');
%     shadedErrorBar([],squeeze(oriCorrDiffAve(i,:)),squeeze(oriCorrDiffSTE(i,:)));
%     hold on
%     
%     titleProp = title(sprintf('%s%d%s','Correlation Differences Orientation Level ', i,': Between - Within '),'FontSize',30,'Units','pixels');
%     xAX = get(gca,'XAxis');   % Change font of x/y ticks
%     set(xAX,'FontSize',15);
%     yAX = get(gca,'YAxis');
%     set(yAX,'FontSize',15);
%     ylabel(sprintf('%s\n%s','Correlation','Difference'),'FontSize',25);
%     xlabel('Time (ms)','FontSize',25);
%     xline(50,'-','LineWidth',4);   % Mark baseline
%     ylim([-.4 .4]);
%     yline(0,'k','LineWidth',4);   % Horizontal line at 0
%     
%     %Make background white
%     set(gcf,'color','white')
%     %Specify demensions of figure
%     set(thisFig,'position',fig_dims)
%     %Set figure thickness and border
%     hold on
%     set(gca,'linewidth',fig_size,'box',fig_box)
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     
%     % Save image
%     thisFig.PaperPositionMode = 'auto';
%     thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
%     print(thisFig,sprintf('%s%d%s','SplitHalf_Differnces_OriLvl_',i),'-dpdf')
% end
% 
% for i=1:5
%     %     close all
%     
%     thisFig = figure('Name',sprintf('%s%d%s','Correlation Differences Size Level ', i,': Between - Within '),'Units','pixels');
%     shadedErrorBar([],squeeze(sizeCorrDiffAve(i,:)),squeeze(sizeCorrDiffSTE(i,:)));
%     hold on
%     
%     titleProp = title(sprintf('%s%d%s','Correlation Differences Size Level ', i,': Between - Within '),'FontSize',30,'Units','pixels');
%     xAX = get(gca,'XAxis');   % Change font of x/y ticks
%     set(xAX,'FontSize',15);
%     yAX = get(gca,'YAxis');
%     set(yAX,'FontSize',15);
%     ylabel(sprintf('%s\n%s','Correlation','Difference'),'FontSize',25);
%     xlabel('Time (ms)','FontSize',25);
%     xline(50,'-','LineWidth',4);   % Mark baseline
%     ylim([-.4 .4]);
%     yline(0,'k','LineWidth',4);   % Horizontal line at 0
%     
%     %Make background white
%     set(gcf,'color','white')
%     %Specify demensions of figure
%     set(thisFig,'position',fig_dims)
%     %Set figure thickness and border
%     hold on
%     set(gca,'linewidth',fig_size,'box',fig_box)
%     % y-axis are levels being correlated
%     set(gca,'TickLength',[0 0])
%     
%     % Save image
%     thisFig.PaperPositionMode = 'auto';
%     thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
%     print(thisFig,sprintf('%s%d%s','SplitHalf_Differnces_SizeLvl_',i),'-dpdf')
% end
% 
% cd ../../








