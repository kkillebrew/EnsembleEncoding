% Behavioral analysis script for Freq Tagging experiment

clear all; close all;

% Load in data
cd ../../
ensDataStruct = ensLoadData_LabComp2('FreqTagBehav','All');
cd ./'EEG Freq Tag'/Data/

groupAnalysis = 1;

for n = 1:length(ensDataStruct.subjid)
    
    clear rawdata
    
    % Load in rawdata
    rawdata = ensDataStruct.rawdata{n};
    
    %% Average Response
    % Calculate an average response for each condition
    % On average, how did the parcitipant respond to each trial
    for i=1:2   % Task
        for k=1:2   % Attended hemifeild
            for j=1:5   % Levels of offset
                aveResponseList(n,i,k,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,i)==j & rawdata(:,4)==k,6);   % Make a list of all values instead of taking the mean
                aveResponse(n,i,k,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,i)==j & rawdata(:,4)==k,6));   % Take an average of each participants responses for each condition
                aveResponseSTE(n,i,k,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,i)==j & rawdata(:,4)==k,6));   % Take the standard error
            end
        end
    end
    
    % Calculate the average response to the unattended feature
    for i=1:2   % Task
        for k=1:2   % Attended hemifeild
            for j=1:5   % Levels of offset
                aveResponseListUnAtt(n,i,k,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j & rawdata(:,4)==k,6);   % Make a list of all values instead of taking the mean
                aveResponseUnAtt(n,i,k,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j & rawdata(:,4)==k,6));   % Take an average of each participants responses for each condition
                aveResponseUnAttSTE(n,i,k,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j & rawdata(:,4)==k,6));   % Take the standard error
            end
        end
    end
%     
%     % Plot averages
%     figure('Name',ensDataStruct.subjid{n})
%     suptitle(sprintf('%s\n\n','Frequency Tagging Behavioral Accuracy')); 
%     % Orientation task
%     % Attend left 
%     % Orientation while attending orientation
%     subplot(7,6,13:15)
%     bar(squeeze(aveResponse(n,1,1,:)));
%     hold on
%     errorbar(squeeze(aveResponse(n,1,1,:)),squeeze(aveResponseSTE(n,1,1,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Orientation While Orientation Left Attend');
%     % Size while attending orientation
%     subplot(7,6,16:18)
%     bar(squeeze(aveResponseUnAtt(n,1,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAtt(n,1,1,:)),squeeze(aveResponseUnAttSTE(n,1,1,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Size While Orientation Left Attend');
%     
%     % Orientation task
%     % Attend right
%     % Orientation while attending orientation
%     subplot(7,6,19:21)
%     bar(squeeze(aveResponse(n,1,2,:)));
%     hold on
%     errorbar(squeeze(aveResponse(n,1,2,:)),squeeze(aveResponseSTE(n,1,2,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Orientation While Orientation Right Attend');
%     % Size while attending orientation
%     subplot(7,6,22:24)
%     bar(squeeze(aveResponseUnAtt(n,1,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAtt(n,1,2,:)),squeeze(aveResponseUnAttSTE(n,1,2,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Size While Orientation Right Attend');
%     
%     % Size task
%     % Attend left
%     % Size while attending size
%     subplot(7,6,25:27)
%     bar(squeeze(aveResponse(n,2,1,:)));
%     hold on
%     errorbar(squeeze(aveResponse(n,2,1,:)),squeeze(aveResponseSTE(n,2,1,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Size While Size Left Attend');
%     % Orientation while attending size
%     subplot(7,6,28:30)
%     bar(squeeze(aveResponseUnAtt(n,2,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAtt(n,2,1,:)),squeeze(aveResponseUnAttSTE(n,2,1,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     xlabel('Offset from standard');
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Orientation While Size Left Attend');
%     
%     % Size task
%     % Attend right
%     % Size while attending size
%     subplot(7,6,31:33)
%     bar(squeeze(aveResponse(n,2,2,:)));
%     hold on
%     errorbar(squeeze(aveResponse(n,2,2,:)),squeeze(aveResponseSTE(n,2,2,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Size While Size Right Attend');
%     % Orientation while attending size
%     subplot(7,6,34:36)
%     bar(squeeze(aveResponseUnAtt(n,2,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAtt(n,2,2,:)),squeeze(aveResponseUnAttSTE(n,2,2,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Orientation While Size Right Attend');
%     
    % Collapse across attended hemifeild
    for i=1:2   % Task
        for j=1:5   % Levels of offset
            aveResponseListComb(n,i,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,i)==j,6);   % Make a list of all values instead of taking the mean
            aveResponseComb(n,i,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,6));   % Take an average of each participants responses for each condition
            aveResponseSTEComb(n,i,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,6));   % Take the standard error
        end
    end
    
    % Calculate the average response to the unattended feature
    for i=1:2   % Task
        for j=1:5   % Levels of offset
            aveResponseListUnAttComb(n,i,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,6);   % Make a list of all values instead of taking the mean
            aveResponseUnAttComb(n,i,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,6));   % Take an average of each participants responses for each condition
            aveResponseUnAttSTEComb(n,i,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,6));   % Take the standard error
        end
    end
%     
%     % Plot averages
%     % Orientation task
%     % Orientation while attending orientation
%     subplot(7,6,1:3)
%     bar(squeeze(aveResponseComb(n,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseComb(n,1,:)),squeeze(aveResponseSTEComb(n,1,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Orientation While Orientation Collapesed');
%     % Size while attending orientation
%     subplot(7,6,4:6)
%     bar(squeeze(aveResponseUnAttComb(n,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttComb(n,1,:)),squeeze(aveResponseUnAttSTEComb(n,1,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     xlabel('Offset from standard');
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Size While Orientation Collapesed');
%     
%     % Size task
%     % Size while attending size
%     subplot(7,6,7:9)
%     bar(squeeze(aveResponseComb(n,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseComb(n,2,:)),squeeze(aveResponseSTEComb(n,2,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Size While Size Collapesed');
%     % Orientation while attending size
%     subplot(7,6,10:12)
%     bar(squeeze(aveResponseUnAttComb(n,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttComb(n,2,:)),squeeze(aveResponseUnAttSTEComb(n,2,:)),'k.');
%     xticklabels({1,2,3,4,5});
%     xlabel('Offset from standard');
%     ylabel('Average response');
%     ylim([0 4]);
%     title('Average Response: Orientation While Size Collapesed');
%     
%     
%     %% Calculate (soft) accuracy
%     for i=1:length(rawdata)
%         % Did they say there was a change when there actually was one?
%         if rawdata(i,3) == 1  % Ori task
%             if (rawdata(i,6) == 1) && (rawdata(i,1) == 1)   % No change and they said no change
%                 rawdata(i,7) = 1;
%             elseif (rawdata(i,6) == 2 || rawdata(i,6) == 3 || rawdata(i,6) == 4) &&...
%                     (rawdata(i,1) == 2 || rawdata(i,1) == 3 || rawdata(i,1) == 4 || rawdata(i,1) == 5) % Change and they said change
%                 rawdata(i,7) = 1;
%             else
%                 rawdata(i,7) = 0;
%             end
%         elseif rawdata(i,3) == 2   % Size task
%             if (rawdata(i,6) == 1) && (rawdata(i,2) == 1)   % No change and they said no change
%                 rawdata(i,7) = 1;
%             elseif (rawdata(i,6) == 2 || rawdata(i,6) == 3 || rawdata(i,6) == 4) &&...
%                     (rawdata(i,2) == 2 || rawdata(i,2) == 3 || rawdata(i,2) == 4 || rawdata(i,2) == 5) % Change and they said change
%                 rawdata(i,7) = 1;
%             else
%                 rawdata(i,7) = 0;
%             end
%         end
%     end
%     
%     % Calculate soft accuracy for both attended directions as a function of task
%     % Attend left - Orientation
%     softTaskAccuracy(n,1,1) = 100 * (sum(rawdata(rawdata(:,4)==1 & rawdata(:,3)==1,7)==1)/length(rawdata(rawdata(:,4)==1 & rawdata(:,3)==1,7)));
%     
%     % Attend left - Size 
%     softTaskAccuracy(n,1,2) = 100 * (sum(rawdata(rawdata(:,4)==1 & rawdata(:,3)==2,7)==1)/length(rawdata(rawdata(:,4)==1 & rawdata(:,3)==2,7)));
%     
%     % Attend right - Orientation
%     softTaskAccuracy(n,2,1) = 100 * (sum(rawdata(rawdata(:,4)==2 & rawdata(:,3)==1,7)==1)/length(rawdata(rawdata(:,4)==2 & rawdata(:,3)==1,7)));
%     
%     % Attend right - Size
%     softTaskAccuracy(n,2,2) = 100 * (sum(rawdata(rawdata(:,4)==2 & rawdata(:,3)==2,7)==1)/length(rawdata(rawdata(:,4)==2 & rawdata(:,3)==2,7)));
%     
%     subplot(7,6,37:38)
%     bar(squeeze([softTaskAccuracy(n,1,:); softTaskAccuracy(n,2,:)]));
%     hold on
%     xticklabels({'Left','Right'});
%     ylim([0 100]);
%     ylabel('Accuracy');
%     title('Soft Accuracy by Attended Direction and Task: Was there a change or not?');
%     legend({'Orientation','Size'});
%     
%     
%     %% Hard accuracy
%     semiHardRespList = {[1 2],[1 2 3],[2 3 4],[3 4],[3 4]};
%     hardRespList = [1 2 3 4 4];
%     
%     for i=1:2   % Task
%         for k=1:2   % Attended hemifeild
%             for j=1:5   % Levels of offset
%                 semiHardAccuracy(n,k,i,j) = 100*(sum(sum(rawdata(rawdata(:,4)==k & rawdata(:,3)==i & rawdata(:,i)==j,6)==semiHardRespList{j},2))/...
%                     length(rawdata(rawdata(:,4)==k & rawdata(:,3)==i & rawdata(:,i)==j,6)==semiHardRespList{j}));   % Was a value of 1 and they said it was 1+/-1
%                 hardAccuracy(n,k,i,j) = 100*(sum(sum(rawdata(rawdata(:,4)==k & rawdata(:,3)==i & rawdata(:,i)==j,6)==hardRespList(j),2))/...
%                     length(rawdata(rawdata(:,4)==k & rawdata(:,3)==i & rawdata(:,i)==j,6)==hardRespList(j)));   % Was a value of 1 and they said it was 1
%             end
%         end
%     end
%     
%     % Plot hard/semi hard accuracy
%     subplot(7,6,39:40)
%     bar(squeeze([semiHardAccuracy(n,1,1,:);semiHardAccuracy(n,1,2,:);semiHardAccuracy(n,2,1,:);semiHardAccuracy(n,2,2,:)]));
%     xticklabels({'Ori Left','Size Left','Ori Right','Size Right'});
%     ylim([0 100]);
%     ylabel('Accuracy');
%     title('Semi Hard Accuracy by Attended Direction and Task: +/-1 of the target value');
%     
%     subplot(7,6,41:42)
%     bar(squeeze([hardAccuracy(n,1,1,:);hardAccuracy(n,1,2,:);hardAccuracy(n,2,1,:);hardAccuracy(n,2,2,:)]));
%     xticklabels({'Ori Left','Size Left','Ori Right','Size Right'});
%     ylim([0 100]);
%     ylabel('Accuracy');
%     title('Hard Accuracy by Attended Direction and Task');
end

%% Average group data
if groupAnalysis == 1
    %% Average response
    % Calculate an average response for each condition
    % On average, how did the parcitipant respond to each trial
    aveResponseGroup = squeeze(mean(aveResponse,1));
    aveResponseGroupSTE = squeeze(ste(aveResponse,1));
    
    aveResponseUnAttGroup = squeeze(mean(aveResponseUnAtt,1));
    aveResponseUnAttGroupSTE = squeeze(ste(aveResponseUnAtt,1));
    
    % Do stats
    % RM ANOVA using the built in Matlab functions.
    % sofAccuracyList(participant #, task, condition, trial) (7,2,4,12)
    clear condNameArray condMeasArrayOri condMeasArrayOriUnAtt
    
    % Create predictor array (1D array that defines the condition) (subjects)
    condNameArray = 1:length(ensDataStruct.subjid);
    
    % Define the groups that are being compared for use w/ sigstar
    sigGroups = {[1,2],[1,3],[1,4],[1,5],[2,3],[2,4],[2,5],[3,4],[3,5],[4,5]};
    
    % Create response array (measurements)
    for k=1:2   % hemifeild
        for j=1:5
            for i=1:length(ensDataStruct.subjid)   % num subjects
                % Ori
                condMeasArrayOri(k,j,i) = aveResponse(i,1,k,j);
                condMeasArrayOriUnAtt(k,j,i) = aveResponseUnAtt(i,1,k,j);
                
                % Size
                condMeasArraySize(k,j,i) = aveResponse(i,2,k,j);
                condMeasArraySizeUnAtt(k,j,i) = aveResponseUnAtt(i,2,k,j);
            end
        end
    end
    
%     for k=1:2   % hemifeild
%         
%         % Ori
%         % Create table for use w/ fitrm function
%         oriTable{k} = table(condNameArray',squeeze(condMeasArrayOri(k,1,:)),squeeze(condMeasArrayOri(k,2,:)),squeeze(condMeasArrayOri(k,3,:)),squeeze(condMeasArrayOri(k,4,:)),squeeze(condMeasArrayOri(k,5,:)),...
%             'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
%         oriTableUnAtt{k} = table(condNameArray',squeeze(condMeasArrayOriUnAtt(k,1,:)),squeeze(condMeasArrayOriUnAtt(k,2,:)),squeeze(condMeasArrayOriUnAtt(k,3,:)),squeeze(condMeasArrayOriUnAtt(k,4,:)),squeeze(condMeasArrayOriUnAtt(k,5,:)),...
%             'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
%         % Define the conditions
%         oriMeas = [1 2 3 4 5]';
%         % Fit a repeated measures model
%         oriModel{k} = fitrm(oriTable{k},'Offset1-Offset5~1');
%         oriModelUnAtt{k} = fitrm(oriTableUnAtt{k},'Offset1-Offset5~1');
%         % Do the repeated measures anova
%         oriStats{k} = ranova(oriModel{k});
%         oriStatsUnAtt{k} = ranova(oriModelUnAtt{k});
%         % Look at pairwise comparissons
%         oriPairwise{k} = multcompare(oriModel{k},'Time','ComparisonType','bonferroni');
%         oriPairwiseUnAtt{k} = multcompare(oriModelUnAtt{k},'Time','ComparisonType','bonferroni');
%         % Pick off the significance values for each comparison (1-2,1-3,1-4,2-3,etc.)
%         for i=1:length(sigGroups)
%             oriSigValsHolder(k,i) = oriPairwise{k}{oriPairwise{k}{:,1}==sigGroups{i}(1,1) & oriPairwise{k}{:,2}==sigGroups{i}(1,2),5};
%             oriSigValsUnAttHolder(k,i) = oriPairwiseUnAtt{k}{oriPairwiseUnAtt{k}{:,1}==sigGroups{i}(1,1) & oriPairwiseUnAtt{k}{:,2}==sigGroups{i}(1,2),5};
%         end
%         % Make a list of significant values to plot using sigstar
%         oriSigVals{k,1,:} = oriSigValsHolder(k,oriSigValsHolder(k,:) < 0.05);
%         oriSigVals{k,2,:} = sigGroups(oriSigValsHolder(k,:) < 0.05);
%         oriSigValsUnAtt{k,1,:} = oriSigValsUnAttHolder(k,oriSigValsUnAttHolder(k,:) < 0.05);
%         oriSigValsUnAtt{k,2,:} = sigGroups(oriSigValsUnAttHolder(k,:) < 0.05);
%         
%         
%         % Size
%         % Create table for use w/ fitrm function
%         sizeTable{k} = table(condNameArray',squeeze(condMeasArraySize(k,1,:)),squeeze(condMeasArraySize(k,2,:)),squeeze(condMeasArraySize(k,3,:)),squeeze(condMeasArraySize(k,4,:)),squeeze(condMeasArraySize(k,5,:)),...
%             'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
%         sizeTableUnAtt{k} = table(condNameArray',squeeze(condMeasArraySizeUnAtt(k,1,:)),squeeze(condMeasArraySizeUnAtt(k,2,:)),squeeze(condMeasArraySizeUnAtt(k,3,:)),squeeze(condMeasArraySizeUnAtt(k,4,:)),squeeze(condMeasArraySizeUnAtt(k,5,:)),...
%             'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
%         % Define the conditions
%         sizeMeas = [1 2 3 4 5]';
%         % Fit a repeated measures model
%         sizeModel{k} = fitrm(sizeTable{k},'Offset1-Offset5~1');
%         sizeModelUnAtt{k} = fitrm(sizeTableUnAtt{k},'Offset1-Offset5~1');
%         % Do the repeated measures anova
%         sizeStats{k} = ranova(sizeModel{k});
%         sizeStatsUnAtt{k} = ranova(sizeModelUnAtt{k});
%         % Look at pairwise comparissons
%         sizePairwise{k} = multcompare(sizeModel{k},'Time','ComparisonType','bonferroni');
%         sizePairwiseUnAtt{k} = multcompare(sizeModelUnAtt{k},'Time','ComparisonType','bonferroni');
%         % Pick off the significance values for each comparison (1-2,1-3,1-4,2-3,etc.)
%         for i=1:length(sigGroups)
%             sizeSigValsHolder(k,i) = sizePairwise{k}{sizePairwise{k}{:,1}==sigGroups{i}(1,1) & sizePairwise{k}{:,2}==sigGroups{i}(1,2),5};
%             sizeSigValsUnAttHolder(k,i) = sizePairwiseUnAtt{k}{sizePairwiseUnAtt{k}{:,1}==sigGroups{i}(1,1) & sizePairwiseUnAtt{k}{:,2}==sigGroups{i}(1,2),5};
%         end
%         % Make a list of significant values to plot using sigstar
%         sizeSigVals{k,1,:} = sizeSigValsHolder(k,sizeSigValsHolder(k,:) < 0.05);
%         sizeSigVals{k,2,:} = sigGroups(sizeSigValsHolder(k,:) < 0.05);
%         sizeSigValsUnAtt{k,1,:} = sizeSigValsUnAttHolder(k,sizeSigValsUnAttHolder(k,:) < 0.05);
%         sizeSigValsUnAtt{k,2,:} = sigGroups(sizeSigValsUnAttHolder(k,:) < 0.05);
%         
%     end
    
%     %% Linear contrasts
%     % Combine average response arrays
%     aveRespNew(1,:,:,:,:) = aveResponse;
%     aveRespNew(2,:,:,:,:) = aveResponseUnAtt;
%     for i=1:2   % Feature
%         for k=1:2   % Hemifeild
%             
%             % First make a table for 
%             tAtt = table(aveRespNew(1,:,i,k,1)',aveRespNew(1,:,i,k,2)',aveRespNew(1,:,i,k,3)',aveRespNew(1,:,i,k,4)',...
%                 aveRespNew(1,:,i,k,5)','VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
%             tUnAtt = table(aveRespNew(2,:,i,k,1)',aveRespNew(2,:,i,k,2)',aveRespNew(1,:,i,k,3)',aveRespNew(2,:,i,k,4)',...
%                 aveRespNew(2,:,i,k,5)','VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
% 
%             
%             % Within subject labels
%             within = table([1 2 3 4 5]');
%             
%             % Fit a repeated measures model
%             rmAtt = fitrm(tAtt,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
%             rmUnAtt = fitrm(tUnAtt,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
%             
%             % Perform the linear contrast
%             lContrast{1} = ranova(rmAtt,'WithinModel',[-2 -1 0 1 2]');
%             lContrast{2} = ranova(rmUnAtt,'WithinModel',[-2 -1 0 1 2]');
%             
%             % Grab the Fstat and pvalue
%             linearContrast(i,1,k).FStat = lContrast{1}{1,4};
%             linearContrast(i,2,k).FStat = lContrast{2}{1,4};
%             linearContrast(i,1,k).PVal = lContrast{1}{1,6};
%             linearContrast(i,2,k).PVal = lContrast{2}{1,6};
%             linearContrast(i,1,k).DF1 = lContrast{1}{1,2};
%             linearContrast(i,2,k).DF1 = lContrast{2}{1,2};
%             linearContrast(i,1,k).DF2 = lContrast{1}{2,2};
%             linearContrast(i,2,k).DF2 = lContrast{2}{2,2};
%             
%             clear lContrast
%             
%         end
%     end
%    
%     
%     %% Plot averages
%     h = figure('Name','Average','Position',[10 10 1300 1500]);
%     suptitle(sprintf('%s\n\n','Frequency Tag Behavioral Accuracy'));
%     % Orientation task
%     % Attend left
%     % Orientation while attending orientation
%     subplot(6,6,13:15)
%     bar(squeeze(aveResponseGroup(1,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseGroup(1,1,:)),squeeze(aveResponseGroupSTE(1,1,:)),'k.');
%     sigstar(oriSigVals{1,2,:},oriSigVals{1,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Orientation While Orientation Left Attend');
%     % Plot the ANOVA on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStats{1}{1,2},',',oriStats{1}{2,2},') = ',oriStats{1}{1,4},', p = ',oriStats{1}{1,6});
%     text(.1,5.4,text1);
%     % Plot the Linear Contrast on the graph
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,1,1).DF1,',',linearContrast(1,1,1).DF2,') = ',linearContrast(1,1,1).FStat,', p = ',linearContrast(1,1,1).PVal);
%     text(3.1,5.4,text2);
%     % Orientation task
%     % Attend left
%     % Size while attending orientation
%     subplot(6,6,16:18)
%     bar(squeeze(aveResponseUnAttGroup(1,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttGroup(1,1,:)),squeeze(aveResponseUnAttGroupSTE(1,1,:)),'k.');
%     sigstar(oriSigValsUnAtt{1,2,:},oriSigValsUnAtt{1,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Size While Orientation Left Attend');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStatsUnAtt{1}{1,2},',',oriStatsUnAtt{1}{2,2},') = ',oriStatsUnAtt{1}{1,4},', p = ',oriStatsUnAtt{1}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(2,2,1).DF1,',',linearContrast(2,2,1).DF2,') = ',linearContrast(2,2,1).FStat,', p = ',linearContrast(2,2,1).PVal);
%     text(3.1,5.4,text2);
%     
%     % Orientation task
%     % Attend right
%     % Orientation while attending orientation
%     subplot(6,6,19:21)
%     bar(squeeze(aveResponseGroup(1,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseGroup(1,2,:)),squeeze(aveResponseGroupSTE(1,2,:)),'k.');
%     sigstar(oriSigVals{2,2,:},oriSigVals{2,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Orientation While Orientation Right Attend');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStats{2}{1,2},',',oriStats{2}{2,2},') = ',oriStats{2}{1,4},', p = ',oriStats{2}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,1,2).DF1,',',linearContrast(1,1,2).DF2,') = ',linearContrast(1,1,2).FStat,', p = ',linearContrast(1,1,2).PVal);
%     text(3.1,5.4,text2);
%     % Orientation task
%     % Attend right
%     % Size while attending orientation
%     subplot(6,6,22:24)
%     bar(squeeze(aveResponseUnAttGroup(1,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttGroup(1,2,:)),squeeze(aveResponseUnAttGroupSTE(1,2,:)),'k.');
%     sigstar(oriSigValsUnAtt{2,2,:},oriSigValsUnAtt{2,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Size While Orientation Right Attend');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStatsUnAtt{2}{1,2},',',oriStatsUnAtt{2}{2,2},') = ',oriStatsUnAtt{2}{1,4},', p = ',oriStatsUnAtt{2}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(2,2,2).DF1,',',linearContrast(2,2,2).DF2,') = ',linearContrast(2,2,2).FStat,', p = ',linearContrast(2,2,2).PVal);
%     text(3.1,5.4,text2);
%     
%     % Size task
%     % Attend left
%     % Size while attending size
%     subplot(6,6,25:27)
%     bar(squeeze(aveResponseGroup(2,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseGroup(2,1,:)),squeeze(aveResponseGroupSTE(2,1,:)),'k.');
%     sigstar(sizeSigVals{1,2,:},sizeSigVals{1,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Size While Size Attend Left');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStats{1}{1,2},',',sizeStats{1}{2,2},') = ',sizeStats{1}{1,4},', p = ',sizeStats{1}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(2,1,1).DF1,',',linearContrast(2,1,1).DF2,') = ',linearContrast(2,1,1).FStat,', p = ',linearContrast(2,1,1).PVal);
%     text(3.1,5.4,text2);
%     % Size task
%     % Attend left
%     % Orientation while attending size
%     subplot(6,6,28:30)
%     bar(squeeze(aveResponseUnAttGroup(2,1,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttGroup(2,1,:)),squeeze(aveResponseUnAttGroupSTE(2,1,:)),'k.');
%     sigstar(sizeSigValsUnAtt{1,2,:},sizeSigValsUnAtt{1,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Orientation While Size Attend Left');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStatsUnAtt{1}{1,2},',',sizeStatsUnAtt{1}{2,2},') = ',sizeStatsUnAtt{1}{1,4},', p = ',sizeStatsUnAtt{1}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,2,1).DF1,',',linearContrast(1,2,1).DF2,') = ',linearContrast(1,2,1).FStat,', p = ',linearContrast(1,2,1).PVal);
%     text(3.1,5.4,text2);
%     
%     % Size task
%     % Attend right
%     % Size while attending size
%     subplot(6,6,31:33)
%     bar(squeeze(aveResponseGroup(2,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseGroup(2,2,:)),squeeze(aveResponseGroupSTE(2,2,:)),'k.');
%     sigstar(sizeSigVals{2,2,:},sizeSigVals{2,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Size While Size Attend Right');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStats{2}{1,2},',',sizeStats{2}{2,2},') = ',sizeStats{2}{1,4},', p = ',sizeStats{2}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(2,2,2).DF1,',',linearContrast(2,2,2).DF2,') = ',linearContrast(2,2,2).FStat,', p = ',linearContrast(2,2,2).PVal);
%     text(3.1,5.4,text2);
%     % Size task
%     % Attend right
%     % Orientation while attending size
%     subplot(6,6,34:36)
%     bar(squeeze(aveResponseUnAttGroup(2,2,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttGroup(2,2,:)),squeeze(aveResponseUnAttGroupSTE(2,2,:)),'k.');
%     sigstar(sizeSigValsUnAtt{2,2,:},sizeSigValsUnAtt{2,1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Orientation While Size Attend Right');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStatsUnAtt{2}{1,2},',',sizeStatsUnAtt{2}{2,2},') = ',sizeStatsUnAtt{2}{1,4},', p = ',sizeStatsUnAtt{2}{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,2,2).DF1,',',linearContrast(1,2,2).DF2,') = ',linearContrast(1,2,2).FStat,', p = ',linearContrast(1,2,2).PVal);
%     text(3.1,5.4,text2);
    
    %% Average collapsed across hemispheres
    % Calculate an average response for each condition
    % On average, how did the parcitipant respond to each trial
    aveResponseGroupComb = squeeze(mean(aveResponseComb,1));
    aveResponseGroupSTEComb = squeeze(ste(aveResponseComb,1));
    
    aveResponseUnAttGroupComb = squeeze(mean(aveResponseUnAttComb,1));
    aveResponseUnAttGroupSTEComb = squeeze(ste(aveResponseUnAttComb,1));
    
    % Do stats
    % RM ANOVA using the built in Matlab functions.
    % sofAccuracyList(participant #, task, condition, trial) (7,2,4,12)
    
    % Define the groups that are being compared for use w/ sigstar
    sigGroups = {[1,2],[1,3],[1,4],[1,5],[2,3],[2,4],[2,5],[3,4],[3,5],[4,5]};
    
    % Create response array (measurements)
    for j=1:5
        for i=1:length(ensDataStruct.subjid)   % num subjects
            % Ori
            condMeasArrayOriComb(j,i) = aveResponseComb(i,1,j);
            condMeasArrayOriUnAttComb(j,i) = aveResponseUnAttComb(i,1,j);
            
            % Size
            condMeasArraySizeComb(j,i) = aveResponseComb(i,2,j);
            condMeasArraySizeUnAttComb(j,i) = aveResponseUnAttComb(i,2,j);
        end
    end
    
    % Ori
    % Create table for use w/ fitrm function
    oriTableComb = table(condNameArray',condMeasArrayOriComb(1,:)',condMeasArrayOriComb(2,:)',condMeasArrayOriComb(3,:)',condMeasArrayOriComb(4,:)',condMeasArrayOriComb(5,:)',...
        'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
    oriTableUnAttComb = table(condNameArray',condMeasArrayOriUnAttComb(1,:)',condMeasArrayOriUnAttComb(2,:)',condMeasArrayOriUnAttComb(3,:)',condMeasArrayOriUnAttComb(4,:)',condMeasArrayOriUnAttComb(5,:)',...
        'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
    % Fit a repeated measures model
    oriModelComb = fitrm(oriTableComb,'Offset1-Offset5~1');
    oriModelUnAttComb = fitrm(oriTableUnAttComb,'Offset1-Offset5~1');
    % Do the repeated measures anova
    oriStatsComb = ranova(oriModelComb);
    oriStatsUnAttComb = ranova(oriModelUnAttComb);
    % Look at pairwise comparissons
    oriPairwiseComb = multcompare(oriModelComb,'Time','ComparisonType','bonferroni');
    oriPairwiseUnAttComb = multcompare(oriModelUnAttComb,'Time','ComparisonType','bonferroni');
    % Pick off the significance values for each comparison (1-2,1-3,1-4,2-3,etc.)
    for i=1:length(sigGroups)
        oriSigValsHolderComb(i) = oriPairwiseComb{oriPairwiseComb{:,1}==sigGroups{i}(1,1) & oriPairwiseComb{:,2}==sigGroups{i}(1,2),5};
        oriSigValsUnAttHolderComb(i) = oriPairwiseUnAttComb{oriPairwiseUnAttComb{:,1}==sigGroups{i}(1,1) & oriPairwiseUnAttComb{:,2}==sigGroups{i}(1,2),5};
    end
    % Make a list of significant values to plot using sigstar
    oriSigValsComb{1,:} = oriSigValsHolderComb(oriSigValsHolderComb(:) < 0.05);
    oriSigValsComb{2,:} = sigGroups(oriSigValsHolderComb(:) < 0.05);
    oriSigValsUnAttComb{1,:} = oriSigValsUnAttHolderComb(oriSigValsUnAttHolderComb(:) < 0.05);
    oriSigValsUnAttComb{2,:} = sigGroups(oriSigValsUnAttHolderComb(:) < 0.05);
    
    % Size
    % Create table for use w/ fitrm function
    sizeTableComb = table(condNameArray',condMeasArraySizeComb(1,:)',condMeasArraySizeComb(2,:)',condMeasArraySizeComb(3,:)',condMeasArraySizeComb(4,:)',condMeasArraySizeComb(5,:)',...
        'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
    sizeTableUnAttComb = table(condNameArray',condMeasArraySizeUnAttComb(1,:)',condMeasArraySizeUnAttComb(2,:)',condMeasArraySizeUnAttComb(3,:)',condMeasArraySizeUnAttComb(4,:)',condMeasArraySizeUnAttComb(5,:)',...
        'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
    % Fit a repeated measures model
    sizeModelComb = fitrm(sizeTableComb,'Offset1-Offset5~1');
    sizeModelUnAttComb = fitrm(sizeTableUnAttComb,'Offset1-Offset5~1');
    % Do the repeated measures anova
    sizeStatsComb = ranova(sizeModelComb);
    sizeStatsUnAttComb = ranova(sizeModelUnAttComb);
    % Look at pairwise comparissons
    sizePairwiseComb = multcompare(sizeModelComb,'Time','ComparisonType','bonferroni');
    sizePairwiseUnAttComb = multcompare(sizeModelUnAttComb,'Time','ComparisonType','bonferroni');
    % Pick off the significance values for each comparison (1-2,1-3,1-4,2-3,etc.)
    for i=1:length(sigGroups)
        sizeSigValsHolderComb(i) = sizePairwiseComb{sizePairwiseComb{:,1}==sigGroups{i}(1,1) & sizePairwiseComb{:,2}==sigGroups{i}(1,2),5};
        sizeSigValsUnAttHolderComb(i) = sizePairwiseUnAttComb{sizePairwiseUnAttComb{:,1}==sigGroups{i}(1,1) & sizePairwiseUnAttComb{:,2}==sigGroups{i}(1,2),5};
    end
    % Make a list of significant values to plot using sigstar
    sizeSigValsComb{1,:} = sizeSigValsHolderComb(sizeSigValsHolderComb(:) < 0.05);
    sizeSigValsComb{2,:} = sigGroups(sizeSigValsHolderComb(:) < 0.05);
    sizeSigValsUnAttComb{1,:} = sizeSigValsUnAttHolderComb(sizeSigValsUnAttHolderComb(:) < 0.05);
    sizeSigValsUnAttComb{2,:} = sigGroups(sizeSigValsUnAttHolderComb(:) < 0.05);
    
    %% Linear contrasts combined
    % Combine average response arrays
    aveRespNewComb(1,:,:,:) = aveResponseComb;
    aveRespNewComb(2,:,:,:) = aveResponseUnAttComb;
    for i=1:2   % Feature
        
        % First make a table for
        tAtt = table(aveRespNewComb(1,:,i,1)',aveRespNewComb(1,:,i,2)',aveRespNewComb(1,:,i,3)',aveRespNewComb(1,:,i,4)',...
            aveRespNewComb(1,:,i,5)','VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
        tUnAtt = table(aveRespNewComb(2,:,i,1)',aveRespNewComb(2,:,i,2)',aveRespNewComb(1,:,i,3)',aveRespNewComb(2,:,i,4)',...
            aveRespNewComb(2,:,i,5)','VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
        
        % Within subject labels
        within = table([1 2 3 4 5]');
        
        % Fit a repeated measures model
        rmAtt = fitrm(tAtt,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
        rmUnAtt = fitrm(tUnAtt,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
        
        % Perform the linear contrast
        lContrast{1} = ranova(rmAtt,'WithinModel',[-2 -1 0 1 2]');
        lContrast{2} = ranova(rmUnAtt,'WithinModel',[-2 -1 0 1 2]');
        
        % Grab the Fstat and pvalue
        linearContrastComb(i,1).FStat = lContrast{1}{1,4};
        linearContrastComb(i,2).FStat = lContrast{2}{1,4};
        linearContrastComb(i,1).PVal = lContrast{1}{1,6};
        linearContrastComb(i,2).PVal = lContrast{2}{1,6};
        linearContrastComb(i,1).DF1 = lContrast{1}{1,2};
        linearContrastComb(i,2).DF1 = lContrast{2}{1,2};
        linearContrastComb(i,1).DF2 = lContrast{1}{2,2};
        linearContrastComb(i,2).DF2 = lContrast{2}{2,2};
        
        clear lContrast
        
    end
    
    
    
     
    
    
    
    
    %% Plot pretty collapsed figure for the paper
    fig_dims = [1 1 10.5 9];   % Size of figure
    fig_size = 4; %Thickness of borders
    fig_box = 'on'; %Figure border on/off
    
    lineWidth = 2;
    fontSize = 12;
    
    figure('Name','Average','Units','inches','Position',fig_dims);
    
    % Orientation task
    % Orientation while attending orientation
    subplot(2,6,1:3)
    bar(squeeze(aveResponseGroupComb(1,:)));
    hold on
    errorbar(squeeze(aveResponseGroupComb(1,:)),squeeze(aveResponseGroupSTEComb(1,:)),'k.');
    sigstar(oriSigValsComb{2,:},oriSigValsComb{1,:},0,lineWidth,fontSize);
%     xticklabels({1,2,3,4,5});
    set(gca, 'XTickLabel', {1,2,3,4,5});
    ylabel('Average response','FontSize',12);
    ylim([0 6]);
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    title(sprintf('%s\n%s','Average Response:','Orientation While Orientation Collapesed'),'FontSize',12);
    % Plot the stats on the graph
    text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrastComb(1,1).DF1,',',linearContrastComb(1,1).DF2,') = ',linearContrastComb(1,1).FStat,', p = ',linearContrastComb(1,1).PVal);
    text(3,5.4,text1,'FontSize',12,'HorizontalAlignment','center');
    
    % Orientation task
    % Size while attending orientation
    subplot(2,6,4:6)
    bar(squeeze(aveResponseUnAttGroupComb(1,:)));
    hold on
    errorbar(squeeze(aveResponseUnAttGroupComb(1,:)),squeeze(aveResponseUnAttGroupSTEComb(1,:)),'k.');
    sigstar(oriSigValsUnAttComb{2,:},oriSigValsUnAttComb{1,:},0,lineWidth,fontSize);
%     xticklabels({1,2,3,4,5});
    set(gca, 'XTickLabel', {1,2,3,4,5});    ylabel('Average response','FontSize',12);
    ylim([0 6]);
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    title(sprintf('%s\n%s','Average Response:','Size While Orientation Collapesed'),'FontSize',12);
    % Plot the stats on the graph
    text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrastComb(2,2).DF1,',',linearContrastComb(2,2).DF2,') = ',linearContrastComb(2,2).FStat,', p = ',linearContrastComb(2,2).PVal);
    text(3,5.4,text1,'FontSize',12,'HorizontalAlignment','center');
    
    % Size task
    % Size while attending size
    subplot(2,6,7:9)
    bar(squeeze(aveResponseGroupComb(2,:)));
    hold on
    errorbar(squeeze(aveResponseGroupComb(2,:)),squeeze(aveResponseGroupSTEComb(2,:)),'k.');
    sigstar(sizeSigValsComb{2,:},sizeSigValsComb{1,:},0,lineWidth,fontSize);
%     xticklabels({1,2,3,4,5});
    set(gca, 'XTickLabel', {1,2,3,4,5});    ylabel('Average response');
    ylim([0 6]);
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    title(sprintf('%s\n%s','Average Response:','Size While Size Collapesed'),'FontSize',12);
    % Plot the stats on the graph
    text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrastComb(2,1).DF1,',',linearContrastComb(2,1).DF2,') = ',linearContrastComb(2,1).FStat,', p = ',linearContrastComb(2,1).PVal);
    text(3,5.4,text1,'FontSize',12,'HorizontalAlignment','center');
    
    % Size task
    % Orientation while attending size
    subplot(2,6,10:12)
    bar(squeeze(aveResponseUnAttGroupComb(2,:)));
    hold on
    errorbar(squeeze(aveResponseUnAttGroupComb(2,:)),squeeze(aveResponseUnAttGroupSTEComb(2,:)),'k.');
    sigstar(sizeSigValsUnAttComb{2,:},sizeSigValsUnAttComb{1,:},0,lineWidth,fontSize);
%     xticklabels({1,2,3,4,5});
    set(gca, 'XTickLabel', {1,2,3,4,5});    ylabel('Average response');
    ylim([0 6]);
    xAX = get(gca,'XAxis');   % Change font of x/y ticks
    set(xAX,'FontSize',10);
    yAX = get(gca,'YAxis');
    set(yAX,'FontSize',10);
    title(sprintf('%s\n%s','Average Response:','Orientation While Size Collapesed'),'FontSize',12);
    % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',sizeStatsUnAttComb{1,2},',',sizeStatsUnAttComb{2,2},') = ',sizeStatsUnAttComb{1,4},', p = ',sizeStatsUnAttComb{1,6});
%     text(.1,5.4,text1);
    text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrastComb(1,2).DF1,',',linearContrastComb(1,2).DF2,') = ',linearContrastComb(1,2).FStat,', p = ',linearContrastComb(1,2).PVal);
    text(3,5.4,text1,'FontSize',12,'HorizontalAlignment','center');
    
    % Save the plot in /GroupResults/
    cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
    savefig('Behavioral_Results_FreqTag_Collapsed.fig');
    print('Behavioral_Results_FreqTag_Collapsed.tif','-dtiffn');   % Save .tif
    %         close(h)
    cd ../../
    
    
    
    
    
    
    
    
    
    
    
    
    %% Plot averages
%     % Orientation task
%     % Orientation while attending orientation
%     subplot(6,6,1:3)
%     bar(squeeze(aveResponseGroupComb(1,:)));
%     hold on
%     errorbar(squeeze(aveResponseGroupComb(1,:)),squeeze(aveResponseGroupSTEComb(1,:)),'k.');
%     sigstar(oriSigValsComb{2,:},oriSigValsComb{1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Orientation While Orientation Collapesed');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStatsComb{1,2},',',oriStatsComb{2,2},') = ',oriStatsComb{1,4},', p = ',oriStatsComb{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrastComb(1,1).DF1,',',linearContrastComb(1,1).DF2,') = ',linearContrastComb(1,1).FStat,', p = ',linearContrastComb(1,1).PVal);
%     text(3.1,5.4,text2);
%     % Orientation task
%     % Attend left
%     % Size while attending orientation
%     subplot(6,6,4:6)
%     bar(squeeze(aveResponseUnAttGroupComb(1,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttGroupComb(1,:)),squeeze(aveResponseUnAttGroupSTEComb(1,:)),'k.');
%     sigstar(oriSigValsUnAttComb{2,:},oriSigValsUnAttComb{1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Size While Orientation Collapesed');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStatsUnAttComb{1,2},',',oriStatsUnAttComb{2,2},') = ',oriStatsUnAttComb{1,4},', p = ',oriStatsUnAttComb{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrastComb(2,2).DF1,',',linearContrastComb(2,2).DF2,') = ',linearContrastComb(2,2).FStat,', p = ',linearContrastComb(2,2).PVal);
%     text(3.1,5.4,text2);
%     
%     % Size task
%     % Size while attending size
%     subplot(6,6,7:9)
%     bar(squeeze(aveResponseGroupComb(2,:)));
%     hold on
%     errorbar(squeeze(aveResponseGroupComb(2,:)),squeeze(aveResponseGroupSTEComb(2,:)),'k.');
%     sigstar(sizeSigValsComb{2,:},sizeSigValsComb{1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Size While Size Collapesed');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStatsComb{1,2},',',sizeStatsComb{2,2},') = ',sizeStatsComb{1,4},', p = ',sizeStatsComb{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrastComb(2,1).DF1,',',linearContrastComb(2,1).DF2,') = ',linearContrastComb(2,1).FStat,', p = ',linearContrastComb(2,1).PVal);
%     text(3.1,5.4,text2);
%     % Size task
%     % Attend right
%     % Orientation while attending size
%     subplot(6,6,10:12)
%     bar(squeeze(aveResponseUnAttGroupComb(2,:)));
%     hold on
%     errorbar(squeeze(aveResponseUnAttGroupComb(2,:)),squeeze(aveResponseUnAttGroupSTEComb(2,:)),'k.');
%     sigstar(sizeSigValsUnAttComb{2,:},sizeSigValsUnAttComb{1,:},0,1,15);
%     xticklabels({1,2,3,4,5});
%     ylabel('Average response');
%     ylim([0 6]);
%     title('Average Response: Orientation While Size Collapesed');
%     % Plot the stats on the graph
%     text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStatsUnAttComb{1,2},',',sizeStatsUnAttComb{2,2},') = ',sizeStatsUnAttComb{1,4},', p = ',sizeStatsUnAttComb{1,6});
%     text(.1,5.4,text1);
%     text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrastComb(1,2).DF1,',',linearContrastComb(1,2).DF2,') = ',linearContrastComb(1,2).FStat,', p = ',linearContrastComb(1,2).PVal);
%     text(3.1,5.4,text2);
%     
%     % Save the plot in /GroupResults/
%     cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%     savefig(h,'Behavioral_Results_FreqTag_Topo.fig');
%     print(h,'Behavioral_Results_FreqTag_Topo.tif','-dtiffn');   % Save .tif
%     %         close(h)
%     cd ../../
%     
%     %% Soft accuracy
%     softAccuracyMean = mean(softTaskAccuracy,1);
%     softAccuracySTE = ste(softTaskAccuracy,1);
%     
%     subplot(7,6,37:38)
%     fBar = bar(squeeze([softAccuracyMean(1,1,:); softAccuracyMean(1,2,:)]));
%     for k1 = 1:2
%         ctrF(k1,:) = bsxfun(@plus, fBar(1).XData, [fBar(k1).XOffset]');
%         ydtF(k1,:) = fBar(k1).YData;
%     end
%     hold on
%     errorbar(ctrF,ydtF,squeeze([softAccuracySTE(1,1,:); softAccuracySTE(1,2,:)]),'.k');
%     xticklabels({'Left','Right'});
%     ylim([0 110]);
%     ylabel('Accuracy');
%     title('Soft Accuracy by Attended Direction and Task: Was there a change or not?');
%     legend({'Orientation','Size'});
%     
%     % Semi-hard Accuracy
%     semiHardAccuracyMean = mean(semiHardAccuracy,1);
%     semiHardAccuracySTE = ste(semiHardAccuracy,1);
%     
%     subplot(7,6,39:40)
%     hBar = bar(squeeze([semiHardAccuracyMean(1,1,1,:);semiHardAccuracyMean(1,1,2,:);semiHardAccuracyMean(1,2,1,:);semiHardAccuracyMean(1,2,2,:)]));
%     for k1 = 1:5
%         ctrH(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
%         ydtH(k1,:) = hBar(k1).YData;
%     end
%     hold on
%     errorbar(ctrH,ydtH,squeeze([semiHardAccuracySTE(1,1,1,:);semiHardAcc