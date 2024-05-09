% Behavioral analysis script for Freq Tagging experiment

clear all; close all;

% Load in data
cd ../../
ensDataStruct = ensLoadData('VEPBehav','All');
cd ./'EEG VEP'/Data/


for n = 1:length(ensDataStruct.subjid)
    
    % Load in rawdata
    rawdata = cell2mat(ensDataStruct.rawdata(n));
    
    %% Average Response
    % Calculate an average response for each condition
    % On average, how did the parcitipant respond to each trial
    for i=1:2   % Task
        for j=1:5   % Levels of offset
            aveResponseList(n,i,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8);   % Make a list of all values instead of taking the mean
            aveResponse(n,i,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8));   % Take an average of each participants responses for each condition
            aveResponseSTE(n,i,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8));   % Take the standard error
        end
    end
    
    % Calculate the average response to the unattended feature
    for i=1:2   % Task
        for j=1:5
            aveResponseListUnAtt(n,i,j,:) = rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,8);   % Make a list of all values instead of taking the mean
            aveResponseUnAtt(n,i,j) = mean(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,8));   % Take an average of each participants responses for each condition
            aveResponseUnAttSTE(n,i,j) = ste(rawdata(rawdata(:,3)==i & rawdata(:,3-i)==j,8));   % Take the standard error
        end
    end
    
    % Plot averages
    figure('Name',ensDataStruct.subjid{n})
    suptitle(sprintf('%s\n\n','VEP Behavioral Accuracy'));    % Orientation while attending orientation
    subplot(3,6,1:3)
    bar(squeeze(aveResponse(n,1,:)));
    hold on
    errorbar(squeeze(aveResponse(n,1,:)),squeeze(aveResponseSTE(n,1,:)),'k.');
    xticklabels({1,2,3,4,5});
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Orientation While Orientation');
    % Size while attending orientation
    subplot(3,6,4:6)
    bar(squeeze(aveResponseUnAtt(n,1,:)));
    hold on
    errorbar(squeeze(aveResponseUnAtt(n,1,:)),squeeze(aveResponseUnAttSTE(n,1,:)),'k.');
    xticklabels({1,2,3,4,5});
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Size While Orientation');
    
    % Size while attending size
    subplot(3,6,7:9)
    bar(squeeze(aveResponse(n,2,:)));
    hold on
    errorbar(squeeze(aveResponse(n,2,:)),squeeze(aveResponseSTE(n,2,:)),'k.');
    xticklabels({1,2,3,4,5});
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Size While Size');
    % Orientation while attending size
    subplot(3,6,10:12)
    bar(squeeze(aveResponseUnAtt(n,2,:)));
    hold on
    errorbar(squeeze(aveResponseUnAtt(n,2,:)),squeeze(aveResponseUnAttSTE(n,2,:)),'k.');
    xticklabels({1,2,3,4,5});
    ylabel('Average response');
    ylim([0 4]);
    title('Average Response: Orientation While Size');
    
    %% Soft accuracy
    % Calculate (soft) accuracy
    for i=1:length(rawdata)
        % Did they say there was a change when there actually was one?
        if rawdata(i,3) == 1  % Ori task
            if (rawdata(i,8) == 1) && (rawdata(i,1) == 1)   % No change and they said no change
                rawdata(i,9) = 1;
            elseif (rawdata(i,8) == 2 || rawdata(i,8) == 3 || rawdata(i,8) == 4) &&...
                    (rawdata(i,1) == 2 || rawdata(i,1) == 3 || rawdata(i,1) == 4 || rawdata(i,1) == 5) % Change and they said change
                rawdata(i,9) = 1;
            else
                rawdata(i,9) = 0;
            end
        elseif rawdata(i,3) == 2   % Size task
            if (rawdata(i,8) == 1) && (rawdata(i,2) == 1)   % No change and they said no change
                rawdata(i,9) = 1;
            elseif (rawdata(i,8) == 2 || rawdata(i,8) == 3 || rawdata(i,8) == 4) &&...
                    (rawdata(i,2) == 2 || rawdata(i,2) == 3 || rawdata(i,2) == 4 || rawdata(i,2) == 5) % Change and they said change
                rawdata(i,9) = 1;
            else
                rawdata(i,9) = 0;
            end
        end
    end
    
    % Calculate soft accuracy for both tasks
    % Orientation
    softAccuracy(n,1) = 100 * (sum(rawdata(rawdata(:,3)==1,9)==1)/length(rawdata(rawdata(:,3)==1,9)));
    
    % Size
    softAccuracy(n,2) = 100 * (sum(rawdata(rawdata(:,3)==2,9)==1)/length(rawdata(rawdata(:,3)==2,9)));
        
    subplot(3,6,13:14)
    bar([softAccuracy(n,1) softAccuracy(n,2)]);
    hold on
    xticklabels({'Orientation','Size'});
    ylim([0 100]);
    ylabel('Accuracy');
    title('Soft Accuracy by Task: Was there a change or not?');
    
    
    %% Hard accuracy
    semiHardRespList = {[1 2],[1 2 3],[2 3 4],[3 4],[3 4]};
    hardRespList = [1 2 3 4 4];
    for i=1:2   % Task
        for j=1:5   % Offset
            % Was a value of 1 and they said it was 1+/-1
            semiHardAccuracy(n,i,j) = 100*(sum(sum(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8)==semiHardRespList{j},2))/...
                length(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8)==semiHardRespList{j}));   % Was a value of 1 and they said it was 1+/-1
            
            hardAccuracy(n,i,j) = 100*(sum(sum(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8)==hardRespList(j),2))/...
                length(rawdata(rawdata(:,3)==i & rawdata(:,i)==j,8)==hardRespList(j)));   % Was a value of 1 and they said it was 1
        end
    end
    
    % Plot hard accuracy
    subplot(3,6,15:16)
    bar(squeeze([semiHardAccuracy(n,1,:);semiHardAccuracy(n,2,:)]));
    xticklabels({'Orientation','Size'});
    ylim([0 100]);
    ylabel('Accuracy');
    title('Semi Hard Accuracy by Task: +/-1 of the target value');
    
    subplot(3,6,17:18)
    bar(squeeze([hardAccuracy(n,1,:);hardAccuracy(n,2,:)]));
    xticklabels({'Orientation','Size'});
    ylim([0 100]);
    ylabel('Accuracy');
    title('Hard Accuracy by Task');
end

%% Average group data 
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

% Ori
% Create response array (measurements)
counter = 1;
for j=1:5
    for i=1:length(ensDataStruct.subjid)   % num subjects
        condMeasArrayOri(j,i) = aveResponse(i,1,j);
        condMeasArrayOriUnAtt(j,i) = aveResponseUnAtt(i,1,j);
        counter = counter+1;
    end
end

% Create table for use w/ fitrm function
oriTable = table(condNameArray',condMeasArrayOri(1,:)',condMeasArrayOri(2,:)',condMeasArrayOri(3,:)',condMeasArrayOri(4,:)',condMeasArrayOri(5,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
oriTableUnAtt = table(condNameArray',condMeasArrayOriUnAtt(1,:)',condMeasArrayOriUnAtt(2,:)',condMeasArrayOriUnAtt(3,:)',condMeasArrayOriUnAtt(4,:)',condMeasArrayOriUnAtt(5,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
% Define the conditions
oriMeas = [1 2 3 4 5]';
% Fit a repeated measures model
oriModel = fitrm(oriTable,'Offset1-Offset5~1');
oriModelUnAtt = fitrm(oriTableUnAtt,'Offset1-Offset5~1');
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
for j=1:5
    for i=1:length(ensDataStruct.subjid)   % num subjects
        condMeasArraySize(j,i) = aveResponse(i,2,j);
        condMeasArraySizeUnAtt(j,i) = aveResponseUnAtt(i,2,j);
        counter = counter+1;
    end
end

% Create table for use w/ fitrm function
sizeTable = table(condNameArray',condMeasArraySize(1,:)',condMeasArraySize(2,:)',condMeasArraySize(3,:)',condMeasArraySize(4,:)',condMeasArraySize(5,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
sizeTableUnAtt = table(condNameArray',condMeasArraySizeUnAtt(1,:)',condMeasArraySizeUnAtt(2,:)',condMeasArraySizeUnAtt(3,:)',condMeasArraySizeUnAtt(4,:)',condMeasArraySizeUnAtt(5,:)',...
    'VariableNames',{'Participants','Offset1', 'Offset2', 'Offset3', 'Offset4', 'Offset5'});
% Define the conditions
sizeMeas = [1 2 3 4 5]';
% Fit a repeated measures model
sizeModel = fitrm(sizeTable,'Offset1-Offset5~1');
sizeModelUnAtt = fitrm(sizeTableUnAtt,'Offset1-Offset5~1');
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
            aveRespNew(1,:,i,5)','VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
        tUnAtt = table(aveRespNew(2,:,i,1)',aveRespNew(2,:,i,2)',aveRespNew(1,:,i,3)',aveRespNew(2,:,i,4)',...
            aveRespNew(2,:,i,5)','VariableNames',{'Lvl1','Lvl2','Lvl3','Lvl4','Lvl5'});
        
        
        % Within subject labels
        within = table([1 2 3 4 5]');
        
        % Fit a repeated measures model
        rmAtt = fitrm(tAtt,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
        rmUnAtt = fitrm(tUnAtt,'Lvl1-Lvl5~1','WithinDesign',within,'WithinModel','orthogonalcontrasts');
        
        % Perform the linear contrast
        lContrast{1} = ranova(rmAtt,'WithinModel',[-2 -1 0 1 2]');
        lContrast{2} = ranova(rmUnAtt,'WithinModel',[-2 -1 0 1 2]');
        
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

% Change directory
cd ./Figures/PrettyFigs/

figure('Name','Average','Units','inches','Position',fig_dims)
% suptitle(sprintf('%s\n\n\n','VEP Behavioral Accuracy'));
% Orientation while attending orientation
subplot(2,6,1:3)
bar(aveResponseGroup(1,:));
hold on
errorbar(aveResponseGroup(1,:),aveResponseGroupSTE(1,:),'k.');
sigstar(oriSigVals{2,:},oriSigVals{1,:},0,lineWidth,fontSize);
xticklabels({1,2,3,4,5});
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
text(3,5.3,text1,'FontSize',12,'HorizontalAlignment','center');

% Size while attending orientation
subplot(2,6,4:6)
bar(aveResponseUnAttGroup(1,:));
hold on
errorbar(aveResponseUnAttGroup(1,:),aveResponseUnAttGroupSTE(1,:),'k.');
sigstar(oriSigValsUnAtt{2,:},oriSigValsUnAtt{1,:},0,lineWidth,fontSize);
xticklabels({1,2,3,4,5});
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
text(3,5.3,text1,'FontSize',12,'HorizontalAlignment','center');



% Size while attending size
subplot(2,6,7:9)
bar(aveResponseGroup(2,:));
hold on
errorbar(aveResponseGroup(2,:),aveResponseGroupSTE(2,:),'k.');
sigstar(sizeSigVals{2,:},sizeSigVals{1,:},0,lineWidth,fontSize);
xticklabels({1,2,3,4,5});
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
text(3,5.3,text1,'FontSize',12,'HorizontalAlignment','center');

% Orientation while attending size
subplot(2,6,10:12)
bar(aveResponseUnAttGroup(2,:));
sigstar(sizeSigValsUnAtt{2,:},sizeSigValsUnAtt{1,:},0,lineWidth,fontSize);
hold on
errorbar(aveResponseUnAttGroup(2,:),aveResponseUnAttGroupSTE(2,:),'k.');
xticklabels({1,2,3,4,5});
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
text2 = sprintf('%s%d%s%d%s%.3f%s%.3f','F(',linearContrast(1,2).DF1,',',linearContrast(1,2).DF2,') = ',linearContrast(1,2).FStat,', p = ',linearContrast(1,2).PVal);
text(3,5.3,text1,'FontSize',12,'HorizontalAlignment','center');

% Save image
print(sprintf('%s%d','VEP_Behavioral_Accuracy.tif'),'-dtiffn');

cd ../../

% %% Soft accuracy
% softAccuracyMean = mean(softAccuracy);
% softAccuracySTE = ste(softAccuracy);
% 
% subplot(3,6,13:14)
% bar(1:2,[softAccuracyMean(1) softAccuracyMean(2)]);
% hold on
% errorbar([softAccuracyMean(1) softAccuracyMean(2)],[softAccuracySTE(1) softAccuracySTE(1)],'.k');
% xticklabels({'Orientation','Size'});
% ylim([0 100]);
% ylabel('Accuracy');
% title('Soft Accuracy by Task: Was there a change or not?');
% 
% % Semi-hard accuracy
% semiHardAccuracyMean = squeeze(mean(semiHardAccuracy,1));
% semiHardAccuracySTE = squeeze(ste(semiHardAccuracy,1));
% 
% subplot(3,6,15:16)
% % For info on grouped errorbars: https://www.mathworks.com/matlabcentral/answers/319525-error-bars-on-grouped-bar-plot
% hBar = bar([semiHardAccuracyMean(1,:);semiHardAccuracyMean(2,:)]);
% for k1 = 1:5   % Number of bar groups
%     ctr(k1,:) = bsxfun(@plus, hBar(1).XData, [hBar(k1).XOffset]');
%     ydt(k1,:) = hBar(k1).YData;
% end
% hold on
% errorbar(ctr,ydt,semiHardAccuracySTE','.k');
% xticklabels({'Orientation','Size'});
% ylim([0 100]);
% ylabel('Accuracy');
% title('Semi Hard Accuracy by Task: +/-1 of the target value');
% 
% % Hard accuracy
% hardAccuracyMean = squeeze(mean(hardAccuracy,1));
% hardAccuracySTE = squeeze(ste(hardAccuracy,1));
% 
% subplot(3,6,17:18)
% gBar = bar(squeeze([hardAccuracy(n,1,:);hardAccuracy(n,2,:)]));
% for k1 = 1:5
%     ctr(k1,:) = bsxfun(@plus, gBar(1).XData, [gBar(k1).XOffset]');
%     ydt(k1,:) = gBar(k1).YData;
% end
% hold on
% errorbar(ctr,ydt,hardAccuracySTE','.k');
% xticklabels({'Orientation','Size'});
% ylim([0 100]);
% ylabel('Accuracy');
% title('Hard Accuracy by Task');







%% Make and save pretty figs for presentations
% fig_box = 'off'; %Figure border on/off
fig_dims = [500 500 2000 1000];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

% Change directory
cd ./Figures/PrettyFigs/

% Plot data for one individual to show their individual levels
%     close all

%% Ori while Ori
thisFig = figure('Name','Average Response Orientation While Orientation');
bar(aveResponseGroup(1,:));
hold on
errorbar(aveResponseGroup(1,:),aveResponseGroupSTE(1,:),'k.');
lineWidth = 3;
fontSize = 20;
sigstar(oriSigVals{2,:},oriSigVals{1,:},0,lineWidth,fontSize);

titleProp = title('Average Response: Orientation While Orientation','FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Average Response','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xticklabels({1,2,3,4,5});
yticks([1 2 3 4 5]);
ylim([0 5.5]);

% Plot the stats on the graph
text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStats{1,2},',',oriStats{2,2},') = ',oriStats{1,4},', p = ',oriStats{1,6});
text(.1,5.1,text1,'FontSize',25);
% Plot the Linear Contrast on the graph
% text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,1).DF1{1},',',linearContrast(1,1).DF2{1},') = ',linearContrast(1,1).FStat{1},', p = ',linearContrast(1,1).PVal{1});
% text(2.1,5.1,text2);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,sprintf('%s%d','Behave_OriWhileOri'),'-dpdf');


%% Size while ori
thisFig = figure('Name','Average Response Size While Orientation');
bar(aveResponseUnAttGroup(1,:));
hold on
errorbar(aveResponseUnAttGroup(1,:),aveResponseUnAttGroupSTE(1,:),'k.');
lineWidth = 3;
fontSize = 20;
sigstar(oriSigValsUnAtt{2,:},oriSigValsUnAtt{1,:},0,lineWidth,fontSize);

titleProp = title('Average Response: Size While Orientation','FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Average Response','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xticklabels({1,2,3,4,5});
yticks([1 2 3 4 5]);
ylim([0 5.5]);

% Plot the stats on the graph
text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStatsUnAtt{1,2},',',oriStatsUnAtt{2,2},') = ',oriStatsUnAtt{1,4},', p = ',oriStatsUnAtt{1,6});
text(.1,5.1,text1,'FontSize',25);
% Plot the Linear Contrast on the graph
% text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,1).DF1{1},',',linearContrast(1,1).DF2{1},') = ',linearContrast(1,1).FStat{1},', p = ',linearContrast(1,1).PVal{1});
% text(2.1,5.1,text2);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,sprintf('%s%d','Behave_SizeWhileOri'),'-dpdf');


%% Size while Size
thisFig = figure('Name','Average Response Size While Size');
bar(aveResponseGroup(2,:));
hold on
errorbar(aveResponseGroup(2,:),aveResponseGroupSTE(2,:),'k.');
lineWidth = 3;
fontSize = 20;
sigstar(sizeSigVals{2,:},sizeSigVals{1,:},0,lineWidth,fontSize);

titleProp = title('Average Response: Size While Size','FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Average Response','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xticklabels({1,2,3,4,5});
yticks([1 2 3 4 5]);
ylim([0 5.5]);

% Plot the stats on the graph
text1 = sprintf('%s%d%s%d%s%f%s%f','F(',sizeStats{1,2},',',sizeStats{2,2},') = ',sizeStats{1,4},', p = ',sizeStats{1,6});
text(.1,5.1,text1,'FontSize',25);
% Plot the Linear Contrast on the graph
% text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,1).DF1{1},',',linearContrast(1,1).DF2{1},') = ',linearContrast(1,1).FStat{1},', p = ',linearContrast(1,1).PVal{1});
% text(2.1,5.1,text2);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,sprintf('%s%d','Behave_SizeWhileSize'),'-dpdf');


%% Size while ori
thisFig = figure('Name','Average Response Size While Orientation');
bar(aveResponseUnAttGroup(2,:));
hold on
errorbar(aveResponseUnAttGroup(2,:),aveResponseUnAttGroupSTE(2,:),'k.');
lineWidth = 3;
fontSize = 20;
sigstar(sizeSigValsUnAtt{2,:},sizeSigValsUnAtt{1,:},0,lineWidth,fontSize);

titleProp = title('Average Response: Size While Orientation','FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Average Response','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xticklabels({1,2,3,4,5});
yticks([1 2 3 4 5]);
ylim([0 5.5]);

% Plot the stats on the graph
text1 = sprintf('%s%d%s%d%s%f%s%f','F(',oriStatsUnAtt{1,2},',',oriStatsUnAtt{2,2},') = ',oriStatsUnAtt{1,4},', p = ',oriStatsUnAtt{1,6});
text(.1,5.1,text1,'FontSize',20);
% Plot the Linear Contrast on the graph
% text2 = sprintf('%s%d%s%d%s%f%s%f','F(',linearContrast(1,1).DF1{1},',',linearContrast(1,1).DF2{1},') = ',linearContrast(1,1).FStat{1},', p = ',linearContrast(1,1).PVal{1});
% text(2.1,5.1,text2);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,sprintf('%s%d','Behave_OriWhileSize'),'-dpdf');

cd ../../







