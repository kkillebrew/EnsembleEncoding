% Behavioral analysis script for fMRI experiment

clear all; close all;

% Load in data
cd ../../
ensDataStruct = ensLoadData('fMRI','All');
cd ./'MRI Adaptation'/Data/


for n = 1:length(ensDataStruct.subjid)
    % Load in the data
    rawdata = ensDataStruct.rawdata{n}.rawdata;
    
    %% Average Response
    % Calculate an average response for each condition
    % On average, how did the parcitipant respond to each trial
    for i=1:2   % Task
        for j=1:4   % Levels of offset
            aveResponseList(n,i,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8);   % Make a list of all values instead of taking the mean
            aveResponse(n,i,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8));   % Take an average of each participants responses for each condition
            aveResponseSTE(n,i,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8));   % Take the standard error
        end
    end
    
    % Calculate the average response to the unattended feature
    for i=1:2   % Task
        for j=1:4
            aveResponseListUnAtt(n,i,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,8);   % Make a list of all values instead of taking the mean
            aveResponseUnAtt(n,i,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,8));   % Take an average of each participants responses for each condition
            aveResponseUnAttSTE(n,i,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,8));   % Take the standard error
        end
    end
    
    % Plot averages
    figure('Name',ensDataStruct.subjid{n})
    suptitle(sprintf('%s\n\n','fMRI Behavioral Accuracy'));
    % Orientation while attending orientation
    subplot(4,2,1)
    bar(squeeze(aveResponse(n,1,:)));
    hold on
    errorbar(squeeze(aveResponse(n,1,:)),squeeze(aveResponseSTE(n,1,:)),'k.');
    xticklabels({1,2,3,4});
    xlabel('Offset from standard');
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Orientation While Orientation');
    % Size while attending orientation
    subplot(4,2,2)
    bar(squeeze(aveResponseUnAtt(n,1,:)));
    hold on
    errorbar(squeeze(aveResponseUnAtt(n,1,:)),squeeze(aveResponseUnAttSTE(n,1,:)),'k.');
    xticklabels({1,2,3,4});
    xlabel('Offset from standard');
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Size While Orientation');
    
    % Size while attending size
    subplot(4,2,3)
    bar(squeeze(aveResponse(n,2,:)));
    hold on
    errorbar(squeeze(aveResponse(n,2,:)),squeeze(aveResponseSTE(n,2,:)),'k.');
    xticklabels({1,2,3,4});
    xlabel('Offset from standard');
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Size While Size');
    % Orientation while attending size
    subplot(4,2,4)
    bar(squeeze(aveResponseUnAtt(n,2,:)));
    hold on
    errorbar(squeeze(aveResponseUnAtt(n,2,:)),squeeze(aveResponseUnAttSTE(n,2,:)),'k.');
    xticklabels({1,2,3,4});
    xlabel('Offset from standard');
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Orientation While Size');
    
    %% Soft Accuracy
    % Calculate (soft) accuracy
    for i=1:length(rawdata)
        % Did they say there was a change when there actually was one?
        if rawdata(i,3) == 1  % Ori task
            if ((rawdata(i,8) == 1) || (rawdata(i,8) == 2)) && (rawdata(i,1) == 1 || rawdata(i,1) == 2)   % No change and they said no change
                rawdata(i,9) = 1;
            elseif (rawdata(i,8) == 3 || rawdata(i,8) == 4) && (rawdata(i,1) == 3 || rawdata(i,1) == 4) % Change and they said change
                rawdata(i,9) = 1;
            else
                rawdata(i,9) = 0;
            end
        elseif rawdata(i,3) == 2   % Size task
            if (rawdata(i,8) == 1 || rawdata(i,8) == 2) && (rawdata(i,2) == 1 || rawdata(i,2) == 2)   % No change and they said no change
                rawdata(i,9) = 1;
            elseif (rawdata(i,8) == 3 || rawdata(i,8) == 4) && (rawdata(i,2) == 3 || rawdata(i,2) == 4) % Change and they said change
                rawdata(i,9) = 1;
            else
                rawdata(i,9) = 0;
            end
        end
    end
    
    
    % Plot accuracy as a function of run number
    for i=1:12
        blockCorrectSoft(i) = sum(rawdata(rawdata(:,4)==i,9));
        blockTotalSofter(i) = sum(rawdata(:,4)==i);
        softerAccuracyBlock(n,i) = 100*(blockCorrectSoft(i)/blockTotalSofter(i));
    end
    
    subplot(4,2,5)
    bar([softerAccuracyBlock(n,:),mean(softerAccuracyBlock(n,:))]);
    hold on
    errorbar(13,mean(softerAccuracyBlock(n,:)),ste(softerAccuracyBlock(n,:)),'k.');
    xticklabels({1,2,3,4,5,6,7,8,9,10,11,12,'Average'});
    xlabel('Run Number');
    ylabel('Accuracy');
    ylim([0 100]);
    title('Softer Accuracy: Was there a change or not?');
    
    % Calculate accuracy as a function of task
    % Orientation
    softTaskAccuracy(n,1,1) = 100*(sum(sum(rawdata(rawdata(:,3)==1 & (rawdata(:,1)==1 | rawdata(:,1)==2),8)==[1 2],2))/24);
    softTaskAccuracy(n,1,2) = 100*(sum(sum(rawdata(rawdata(:,3)==1 & (rawdata(:,1)==3 | rawdata(:,1)==4),8)==[3 4],2))/24);
    
    % Size 
    softTaskAccuracy(n,2,1) = 100*(sum(sum(rawdata(rawdata(:,3)==2 & (rawdata(:,2)==1 | rawdata(:,2)==2),8)==[1 2],2))/24);
    softTaskAccuracy(n,2,2) = 100*(sum(sum(rawdata(rawdata(:,3)==2 & (rawdata(:,2)==3 | rawdata(:,2)==4),8)==[3 4],2))/24);
    
    subplot(4,2,6)
    bar(squeeze([softTaskAccuracy(n,1,:);softTaskAccuracy(n,2,:)]));
    hold on
    xticklabels({'Orientation','Size'});
    ylim([0 100]);
    ylabel('Accuracy');
    title('Softer Accuracy by Task');
    legend({'No Change','Change'});
    
    
    %% Hard accuracy
    semiHardRespList = {[1 2],[1 2 3],[2 3 4],[3 4]};
    
    for i=1:2   % Task
        for j=1:4   % Offset
            % Was a value of 1 and they said it was 1+/-1
            semiHardAccuracy(n,i,j) = 100*(sum(sum(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8)==semiHardRespList{j},2))/12);
            % Was a value of 1 and they said it was 1
            hardAccuracy(n,i,j) = 100*(sum(sum(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8)==j,2))/12);
        end
    end

    % Plot accuracy
    subplot(4,2,7)
    bar(squeeze([semiHardAccuracy(n,1,:);semiHardAccuracy(n,2,:)]));
    xticklabels({'Orientation','Size'});
    ylabel('Accuracy');
    ylim([0 100]);
    title('Semi Hard Accuracy by Task: +/-1 of the target value');
    
    subplot(4,2,8)
    bar(squeeze([hardAccuracy(n,1,:);hardAccuracy(n,2,:)]));
    xticklabels({'Orientation','Size'});
    ylabel('Accuracy');
    ylim([0 100]);
    title('Hard Accuracy by Task');
end

%% Group averages and stats

%% Average response
% Calculate an average response for each condition
% On average, how did the parcitipant respond to each trial
aveResponseGroup = squeeze(mean(aveResponse,1));
aveResponseGroupSTE = squeeze(ste(aveResponse,1));

aveResponseUnAttGroup = squeeze(mean(aveResponseUnAtt,1));
aveResponseUnAttGroupSTE = squeeze(ste(aveResponseUnAtt,1));

% Do stats
% RM ANOVA using the built in Matlab functions. Will use the older anova_rm
% function as Matlab does some cooky calculations w/ degrees of freedom. 
% sofAccuracyList(participant #, task, condition, trial) (7,2,4,12)
clear condNameArray condMeasArrayOri condMeasArrayOriUnAtt

% Create predictor array (1D array that defines the condition) (subjects)
condNameArray = 1:length(ensDataStruct.subjid);

% Define the groups that are being compared for use w/ sigstar
sigGroups = {[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]};

% Ori
% Create response array (measurements)
counter = 1;
for j=1:4
    for i=1:length(ensDataStruct.subjid)   % num subjects
        condMeasArrayOri(j,i) = aveResponse(i,1,j);
        condMeasArrayOriUnAtt(j,i) = aveResponseUnAtt(i,1,j);
        counter = counter+1;
    end
end
clear oriTable oriMeas oriModel oriStats
% Create table for use w/ fitrm function
oriTable = table(condNameArray',condMeasArrayOri(1,:)',condMeasArrayOri(2,:)',condMeasArrayOri(3,:)',condMeasArrayOri(4,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4'});
oriTableUnAtt = table(condNameArray',condMeasArrayOriUnAtt(1,:)',condMeasArrayOriUnAtt(2,:)',condMeasArrayOriUnAtt(3,:)',condMeasArrayOriUnAtt(4,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4'});
% Define the conditions
oriMeas = [1 2 3 4]';
% Fit a repeated measures model
oriModel = fitrm(oriTable,'Offset1-Offset4~1');
oriModelUnAtt = fitrm(oriTableUnAtt,'Offset1-Offset4~1');
% Do the repeated measures anova
oriStats = ranova(oriModel);
oriStatsUnAtt = ranova(oriModelUnAtt);
% Look at pairwise comparissons 
oriPairwise = multcompare(oriModel,'Time','ComparisonType','bonferroni');
oriPairwiseUnAtt = multcompare(oriModelUnAtt,'Time','ComparisonType','bonferroni');
% Pick off the significance values for each comparison (1-2,1-3,1-4,2-3,etc.)
for i=1:length(sigGroups)
    oriSigValsHolder(i) = oriPairwise{oriPairwise{:,1}==sigGroups{i}(1,1) & oriPairwise{:,2}==sigGroups{i}(1,2),5};
    oriSigValsUnAttHolder(i) = oriPairwiseUnAtt{oriPairwiseUnAtt{:,1}==sigGroups{i}(1,1) & oriPairwiseUnAtt{:,2}==sigGroups{i}(1,2),5};
end
% Make a list of significant values to plot using sigstar
oriSigVals{1,:} = oriSigValsHolder(oriSigValsHolder < 0.05);
oriSigVals{2,:} = sigGroups(oriSigValsHolder < 0.05);
oriSigValsUnAtt{1,:} = oriSigValsUnAttHolder(oriSigValsUnAttHolder < 0.05);
oriSigValsUnAtt{2,:} = sigGroups(oriSigValsUnAttHolder < 0.05);

% Size
% Create response array (measurements)
counter = 1;
for j=1:4
    for i=1:length(ensDataStruct.subjid)   % num subjects
        condMeasArraySize(j,i) = aveResponse(i,2,j);
        condMeasArraySizeUnAtt(j,i) = aveResponseUnAtt(i,2,j);
        counter = counter+1;
    end
end
clear sizeTable sizeMeas sizeModel sizeStats
% Create table for use w/ fitrm function
sizeTable = table(condNameArray',condMeasArraySize(1,:)',condMeasArraySize(2,:)',condMeasArraySize(3,:)',condMeasArraySize(4,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4'});
sizeTableUnAtt = table(condNameArray',condMeasArraySizeUnAtt(1,:)',condMeasArraySizeUnAtt(2,:)',condMeasArraySizeUnAtt(3,:)',condMeasArraySizeUnAtt(4,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4'});
% Define the conditions
sizeMeas = [1 2 3 4]';
% Fit a repeated measures model
sizeModel = fitrm(sizeTable,'Offset1-Offset4~1');
sizeModelUnAtt = fitrm(sizeTableUnAtt,'Offset1-Offset4~1');
% Do the repeated measures anova
sizeStats = ranova(sizeModel);
sizeStatsUnAtt = ranova(sizeModelUnAtt);
% Look at pairwise comparissons 
sizePairwise = multcompare(sizeModel,'Time','ComparisonType','bonferroni');
sizePairwiseUnAtt = multcompare(sizeModelUnAtt,'Time','ComparisonType','bonferroni');
% Pick off the significance values for each comparison (1-2,1-3,1-4,2-3,etc.)
for i=1:length(sigGroups)
    sizeSigValsHolder(i) = sizePairwise{sizePairwise{:,1}==sigGroups{i}(1,1) & sizePairwise{:,2}==sigGroups{i}(1,2),5};
    sizeSigValsUnAttHolder(i) = sizePairwiseUnAtt{sizePairwiseUnAtt{:,1}==sigGroups{i}(1,1) & sizePairwiseUnAtt{:,2}==sigGroups{i}(1,2),5};
end
% Make a list of significant values to plot using sigstar
sizeSigVals{1,:} = sizeSigValsHolder(sizeSigValsHolder < 0.05);
sizeSigVals{2,:} = sigGroups(sizeSigValsHolder < 0.05);
sizeSigValsUnAtt{1,:} = sizeSigValsUnAttHolder(sizeSigValsUnAttHolder < 0.05);
sizeSigValsUnAtt{2,:} = sigGroups(sizeSigValsUnAttHolder < 0.05);

%% Linear contrasts
aveRespNew(1,:,:,:) = aveResponse;
aveRespNew(2,:,:,:) = aveResponseUnAtt;
for i=1:2   % Feature
        
        % First make a table for
        tAtt = table(aveRespNew(1,:,i,1)',aveRespNew(1,:,i,2)',aveRespNew(1,:,i,3)',aveRespNew(1,:,i,4)',...
            'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
        tUnAtt = table(aveRespNew(2,:,i,1)',aveRespNew(2,:,i,2)',aveRespNew(1,:,i,3)',aveRespNew(2,:,i,4)',...
            'VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4'});
        
        
        % Within subject labels
        within = table([1 2 3 4]');
        
        % Fit a repeated measures model
        rmAtt = fitrm(tAtt,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
        rmUnAtt = fitrm(tUnAtt,'Lvl1-Lvl4~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
        
        % Perform the linear contrast
        lContrast{1} = ranova(rmAtt,'WithinModel',[-1.5 -.5 .5 1.5]');
        lContrast{2} = ranova(rmUnAtt,'WithinModel',[-1.5 -.5 .5 1.5]');
        
        % Grab the Fstat and pvalue
        linearContrast(i,1).FStat = lContrast{1}{1,4};
        linearContrast(i,2).FStat = lContrast{2}{1,4};
        linearContrast(i,1).PVal = lContrast{1}{1,6};
        linearContrast(i,2).PVal = lContrast{2}{1,6};
        linearContrast(i,1).DF1 = lContrast{1}{1,2};
        linearContrast(i,2).DF1 = lContrast{2}{1,2};
        linearContrast(i,1).DF2 = lContrast{1}{2,2};
        linearContrast(i,2).DF2 = lContrast{2}{2,2};
        
        clear lContrast
        
end






%% Make and save pretty figs for presentations combined into one fig
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

lineWidth = 2;
fontSize = 12;

figure('Name','Average','Units','inches','Position',fig_dims)
% Orientation while attending orientation
subplot(2,2,1)
bar(aveResponseGroup(1,:));
hold on
errorbar(aveResponseGroup(1,:),aveResponseGroupSTE(1,:),'k.');
sigstar(oriSigVals{2,:},oriSigVals{1,:},0,lineWidth,fontSize);
xticklabels({1,2,3,4});
ylabel('Average response','FontSize',12);
ylim([0 5.5]);
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',10);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',10);
title(sprintf('%s\n%s','Average Response:','Orientation While Orientation'),'FontSize',12);
% Plot the stats on the graph
% text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',oriStats{1,2},',',oriStats{2,2},') = ',oriStats{1,4},', p = ',oriStats{1,6});
% text(.1,5.3,text1,'FontSize',9);
% Plot the Linear Contrast on the graph
text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrast(1,1).DF1,',',linearContrast(1,1).DF2,') = ',linearContrast(1,1).FStat,', p = ',linearContrast(1,1).PVal);
text(2.5,5.3,text1,'FontSize',12,'HorizontalAlignment','center');

% Size while attending orientation
subplot(2,2,2)
bar(aveResponseUnAttGroup(1,:));
hold on
errorbar(aveResponseUnAttGroup(1,:),aveResponseUnAttGroupSTE(1,:),'k.');
sigstar(oriSigValsUnAtt{2,:},oriSigValsUnAtt{1,:},0,lineWidth,fontSize);
xticklabels({1,2,3,4});
ylabel('Average response','FontSize',12);
ylim([0 5.5]);
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',10);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',10);
title(sprintf('%s\n%s','Average Response:','Size While Orientation'),'FontSize',12);
% Plot the stats on the graph
% text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',oriStatsUnAtt{1,2},',',oriStatsUnAtt{2,2},') = ',oriStatsUnAtt{1,4},', p = ',oriStatsUnAtt{1,6});
% text(.1,5.3,text1,'FontSize',9);
% Plot the Linear Contrast on the graph
text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrast(2,2).DF1,',',linearContrast(2,2).DF2,') = ',linearContrast(2,2).FStat,', p = ',linearContrast(2,2).PVal);
text(2.5,5.3,text1,'FontSize',12,'HorizontalAlignment','center');



% Size while attending size
subplot(2,2,3)
bar(aveResponseGroup(2,:));
hold on
errorbar(aveResponseGroup(2,:),aveResponseGroupSTE(2,:),'k.');
sigstar(sizeSigVals{2,:},sizeSigVals{1,:},0,lineWidth,fontSize);
xticklabels({1,2,3,4});
ylabel('Average response','FontSize',12);
ylim([0 5.5]);
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',10);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',10);
title(sprintf('%s\n%s','Average Response:','Size While Size'),'FontSize',12);
% Plot the stats
% text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',sizeStats{1,2},',',sizeStats{2,2},') = ',sizeStats{1,4},', p = ',sizeStats{1,6});
% text(.1,5.3,text1,'FontSize',9);
% Plot the Linear Contrast on the graph
text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrast(2,1).DF1,',',linearContrast(2,1).DF2,') = ',linearContrast(2,1).FStat,', p = ',linearContrast(2,1).PVal);
text(2.5,5.3,text1,'FontSize',12,'HorizontalAlignment','center');

% Orientation while attending size
subplot(2,2,4)
bar(aveResponseUnAttGroup(2,:));
sigstar(sizeSigValsUnAtt{2,:},sizeSigValsUnAtt{1,:},0,lineWidth,fontSize);
hold on
errorbar(aveResponseUnAttGroup(2,:),aveResponseUnAttGroupSTE(2,:),'k.');
xticklabels({1,2,3,4});
ylabel('Average response','FontSize',12);
ylim([0 5.5]);
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',10);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',10);
title(sprintf('%s\n%s','Average Response:','Orientation While Size'),'FontSize',12);
% Plot the stats
% text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',sizeStatsUnAtt{1,2},',',sizeStatsUnAtt{2,2},') = ',sizeStatsUnAtt{1,4},', p = ',sizeStatsUnAtt{1,6});
% text(.1,5.3,text1,'FontSize',9);
% Plot the Linear Contrast on the graph
text1 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrast(1,2).DF1,',',linearContrast(1,2).DF2,') = ',linearContrast(1,2).FStat,', p = ',linearContrast(1,2).PVal);
text(2.5,5.3,text1,'FontSize',12,'HorizontalAlignment','center');

% Save the plot in /GroupResults/
cd ./GroupResults/   % From the data folder CD into group results
savefig('Behavioral_Results_FreqTag_Collapsed.fig');
print('Behavioral_Results_FreqTag_Collapsed.tif','-dtiffn');   % Save .tif
%         close(h)
cd ../

% %% Soft Accuracy 
% softerAccuracyBlockAve = mean(softerAccuracyBlock,1);
% softerAccuracyBlockSTE = ste(softerAccuracyBlock,1);
% 
% % Plot
% subplot(4,2,5)
% bar([softerAccuracyBlockAve(:)',mean(softerAccuracyBlockAve)]);
% hold on
% errorbar(1:12,softerAccuracyBlockAve,softerAccuracyBlockSTE,'k.');
% errorbar(13,mean(softerAccuracyBlockAve),ste(softerAccuracyBlockAve),'k.');
% xticklabels({1,2,3,4,5,6,7,8,9,10,11,12,'Average'});
% xlabel('Run Number');
% ylabel('Accuracy');
% ylim([0 100]);
% title('Softer Accuracy: Was there a change or not?');
% 
% % Calculate accuracy as a function of task
% % Average across participants
% softTaskAccuracyAve = squeeze(mean(softTaskAccuracy,1));
% softTaskAccuracySTE = squeeze(ste(softTaskAccuracy,1));
% 
% subplot(4,2,6)
% hBar = bar([softTaskAccuracyAve(1,:);softTaskAccuracyAve(2,:)]);
% for k1 = 1:2   % Number of bar groups
%     ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
%     ydt(k1,:) = hBar(k1).YData;
% end
% hold on
% errorbar(ctr,ydt,[softTaskAccuracySTE(1,:);softTaskAccuracySTE(2,:)]','.k');
% xticklabels({'Orientation','Size'});
% ylim([0 100]);
% ylabel('Accuracy');
% title('Softer Accuracy by Task');
% legend({'No Change','Change'});
% 
% 
% %% Hard Accuracy
% hardAccuracyAve = squeeze(mean(hardAccuracy,1));
% hardAccuracySTE = squeeze(ste(hardAccuracy,1));
% 
% semiHardAccuracyAve = squeeze(mean(semiHardAccuracy,1));
% semiHardAccuracySTE = squeeze(ste(semiHardAccuracy,1));
% 
% % Plot accuracy
% subplot(4,2,7)
% fBar = bar([semiHardAccuracyAve(1,:);semiHardAccuracyAve(2,:)]);
% clear ctr ydt
% for k1 = 1:4   % Number of bar groups
%     ctr(k1,:) = bsxfun(@plus, fBar(1).XData, [fBar(k1).XOffset]');
%     ydt(k1,:) = fBar(k1).YData;
% end
% hold on
% errorbar(ctr,ydt,[semiHardAccuracySTE(1,:);semiHardAccuracySTE(2,:)]','.k');
% xticklabels({'Orientation','Size'});
% ylabel('Accuracy');
% ylim([0 100]);
% title('Semi Hard Accuracy by Task: +/-1 of the target value');
% 
% subplot(4,2,8)
% gBar = bar([hardAccuracyAve(1,:);hardAccuracyAve(2,:)]);
% clear ctr ydt
% for k1 = 1:4   % Number of bar groups
%     ctr(k1,:) = bsxfun(@plus, gBar(1).XData, [gBar(k1).XOffset]');
%     ydt(k1,:) = gBar(k1).YData;
% end
% hold on
% errorbar(ctr,ydt,[hardAccuracySTE(1,:);hardAccuracySTE(2,:)]','.k');
% xticklabels({'Orientation','Size'});
% ylabel('Accuracy');
% ylim([0 100]);
% title('Hard Accuracy by Task');











