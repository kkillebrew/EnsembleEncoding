% Analysis of behavioral data to find feature steps - 080918

clear all; close all;

% Load in participants data
cd ../../
ensDataStruct = ensLoadData('Behavioral','All');
cd ./Behavioral/Data/


%% Analysis - Step finder/PSE
% rawdata(1) = orientation
% rawdata(2) = size
% rawdata(3) = task
% rawdata(4) = density 1:test more, 2:ref more
% rawdata(5:6) = pres order 1:test, 2:ref
% rawdata(7) = response 1:first, 2:second
% rawdata(8) = chose test:1 ref:0

standardSize = 1;
standardOri = 270;

sizeList = [0 .1 .25 .5 1];
nSize = length(sizeList);
oriList = [0 10 25 45 90];
nOri = length(oriList);

% Calculate curve fit and PSE values
x_axis_ori = oriList;
xx_axis_ori = 0:.001:90;

x_axis_size = sizeList+standardSize;
xx_axis_size = 1:.001:2;

lineColor{1} = [1 0 0];
lineColor{2} = [0 0 1];
lineColor{3} = [0 1 0];
lineColor{4} = [1 0 1];

for i=1:length(oriList)
    oriTitle{i}  = num2str(oriList(i));
end
for i=1:length(sizeList)
    sizeTitle{i}  = num2str(sizeList(i)+standardSize);
end

%% Individual participant analysis

% for n=1
for n=1:length(ensDataStruct.subjid)
    % Separate the data based on task
    rawdata = ensDataStruct.rawdata{n}.rawdata;
    rawdataOri = rawdata(rawdata(:,3)==1,:);
    rawdataSize = rawdata(rawdata(:,3)==2,:);
    
    % Sum up number of times participant reported test as larger/more rightward
    % than reference
    for j=1:nOri
        numOri(n,j) = sum(rawdataOri(:,1)==j);
        numRight(n,j) = sum(rawdataOri(:,1)==j & rawdataOri(:,8)==1);
        percentRight(n,j) = numRight(n,j)/numOri(n,j);
        
        numSize(n,j) = sum(rawdataSize(:,2)==j);
        numLarge(n,j) = sum(rawdataSize(:,2)==j & rawdataSize(:,8)==1);
        percentLarge(n,j) = numLarge(n,j)/numSize(n,j);
    end
    
    % Calculate fits for ori and size seperately
    %     figure()
    %% Ori
    %     datafitTemp = [numRight(n,:); numOri(n,:)]';
    %     bTemp = glmfit(x_axis_ori',datafitTemp,'binomial','logit');
    %     cumulativeFit = @(p,x) p(3) + (1-p(3)-p(4)) .* 0.5 .* erf((x-p(1))/(p(2)*sqrt(2)));
    cumulativeFit = @(p,x) erf((x-p(1))/(p(2)*sqrt(2)));
    %     cumulativeFit = @(p,x)  p(3) + (1-p(3)-p(4)) .* exp(p(1) + p(2) * x) ./ (1 + exp(p(1) + p(2) * x));
    %     cumulativeFit = @(p,x)  exp(p(1) + p(2) * x) ./ (1 + exp(p(1) + p(2) * x));
    %     bTemp = nlinfit(x_axis_ori', percentRight(n,:)', cumulativeFit, [1 1 0.5 0]);
    %     bTemp = nlinfit(x_axis_ori', percentRight(n,:)', cumulativeFit, [3 5]);
    bTemp = nlinfit(x_axis_ori', [.5 percentRight(n,2:end)]', cumulativeFit, [3 5]);
    %     fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_ori') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_ori'));
    fitdata = cumulativeFit(bTemp,xx_axis_ori');
    
    %     figure()
    %     plot(x_axis_ori,100*percentRight(n,:)','Color',lineColor{1},'LineWidth',2);
    % %     plot(x_axis_ori,100*[.5 .75 1 1 .95]','Color',lineColor{1},'LineWidth',2);
    %     hold on
    %     plot(xx_axis_ori,100*fitdata,'b.');
    
    %     datafitTemp2 = [numRight(n,:); numOri(n,:)]';
    %     bTemp2 = glmfit(x_axis_ori',datafitTemp2,'binomial','logit');
    %     fitdata2 = 100 * exp(bTemp2(1) + bTemp2(2) * xx_axis_ori') ./ (1 + exp(bTemp2(1) + bTemp2(2) * xx_axis_ori'));
    %     PSETempOri2 = -bTemp2(1)/bTemp2(2);
    %
    % Determine what points you want to extract to use as step values in other experiments.
    % First determine the % at which their baseline falls (point at which they are comparing ref to ref)
    % Then find the points for baseline + 15,25,35%
    % Find the 50% point (PSE)
    %     syms xProp1
    %     eqn{1} = 100 * exp(bTemp(1) + bTemp(2) * xProp1') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp1')) == 50;
    %     sol(1) = vpa(solve(eqn{1},xProp1));
    %     % If the 50% point is < the reference values (size=1 DoVA; ori=0 degrees)
    %     % then find what the reference % is and count up 15, 25, and 35% from that.
    %     if sol(1) < oriList(1)
    %         propAtRef = 100 * exp(bTemp(1) + bTemp(2) * oriList(1)) ./ (1 + exp(bTemp(1) + bTemp(2) * oriList(1)));   % Find % at reference ori value of 0
    %         % If the reference proportion too large so that you can't add up to 35% to it (>65%), then make
    %         % the steps values evenly spaced between the reference proportion
    %         % and 95%
    %         if propAtRef > 60
    %             % Determine equally spaced steps between propAtRef and 95%
    %             properSteps = linspace(propAtRef,95,5);
    %             propStepList(1,1:4) = properSteps(1:4);
    %         else
    %             propStepList(1,1:4) = [propAtRef (propAtRef + [15 25 35])];
    %         end
    %     else
    %         propAtRef = 50;
    %         propStepList(1,1:4) = [propAtRef (propAtRef + [15 25 35])];
    %     end
    propStepList(1,1) = 65;
    propStepList(1,2) = 75;
    propStepList(1,3) = 85;
    propStepList(1,4) = 95;
    % Find the +15% point
    syms xProp1
    %     eqn{1} = 100 * exp(bTemp(1) + bTemp(2) * xProp1') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp1')) == propStepList(1,2);
    eqn{1} = 100 * erf((xProp1'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1,1);
    sol(1) = vpa(solve(eqn{1},xProp1));
    % Find the +25% point
    syms xProp2
    %     eqn{2} = 100 * exp(bTemp(1) + bTemp(2) * xProp3') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp3')) == propStepList(1,3);
    eqn{2} = 100 * erf((xProp2'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1,2);
    sol(2) = vpa(solve(eqn{2},xProp2));
    % Find the +35% point
    syms xProp3
    %     eqn{4} = 100 * exp(bTemp(1) + bTemp(2) * xProp4') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp4')) == propStepList(1,4);
    eqn{3} = 100 * erf((xProp3'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1,3);
    sol(3) = vpa(solve(eqn{3},xProp3));
    % Find the 99.9999% point
    syms xProp4
    %     eqn{5} = 100 * exp(bTemp(1) + bTemp(2) * xProp5') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp5')) == propStepList(1,5);
    eqn{4} = 100 * erf((xProp4'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1,4);
    sol(4) = vpa(solve(eqn{4},xProp4));
    %     if sol(5) > 90   % If for some reason this value exceeds 90 degrees just make it 90 degrees
    %         sol(5) = 90;
    %     end
    %     % Create the step list to be used in the imaging/recording experiments
    %     stepList(n,1,:) = double(real([oriList(1) sol(2) sol(3) sol(4) sol(5)]));
    
    % Plot participant data
    %     subplot(1,2,1)
    figure()
    h(n,i) = plot(x_axis_ori,100*percentRight(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
    hold on
    set(gca,'ylim',[0,100]);
    set(gca,'xtick',oriList,'xTickLabels',oriTitle);
    plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
    plot(xx_axis_ori,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
    plot(sol(2)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
    plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 75% point
    plot(sol(4)*ones(51,1),[0:50],'y--','LineWidth',2);    % Plot the 85% point
    %     plot(100*sol(5)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
    title('Orientation Task');
    xlabel('Orientation');
    ylabel('Proportaion Reported More Rightward');
    
    %     clear datafitTemp bTemp fitData xProp1 xProp2 xProp3 xProp4 xProp5 eqn sol propAtRef
    
    %     %% Size
    %     datafitTemp = [numLarge(n,:); numSize(n,:)]';
    %     bTemp = glmfit(x_axis_size',datafitTemp,'binomial','logit');
    %     fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_size') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_size'));
    %     PSETempSize = -bTemp(1)/bTemp(2);
    
    
    cumulativeFit = @(p,x) erf((x-p(1))/(p(2)*sqrt(2)));
    bTemp = nlinfit(x_axis_ori', [.5 percentLarge(n,2:end)]', cumulativeFit, [3 5]);
    fitdata = cumulativeFit(bTemp,xx_axis_ori');
    
    %     % Determine what points you want to extract to use as step values in other experiments.
    %     % First determine the % at which their baseline falls (point at which they are comparing ref to ref)
    %     % Then find the points for baseline + 15,25,35%
    %     % Find the 50% point (PSE)
    %     syms xProp1
    %     eqn{1} = 100 * exp(bTemp(1) + bTemp(2) * xProp1') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp1')) == 50;
    %     sol(1) = vpa(solve(eqn{1},xProp1));
    %     % If the 50% point is < the reference values (size=1 DoVA; ori=0 degrees)
    %     % then find what the reference % is and count up 15, 25, and 35% from that.
    %     if sol(1) < (sizeList(1)+standardSize)
    %         propAtRef = 100 * exp(bTemp(1) + bTemp(2) * (sizeList(1)+standardSize)) ./ (1 + exp(bTemp(1) + bTemp(2) * (sizeList(1)+standardSize)));   % Find % at reference size value of 1
    %         % If the reference proportion too large so that you can't add up to 35% to it (>65%), then make
    %         % the steps values evenly spaced between the reference proportion
    %         % and 95%
    %         if propAtRef > 60
    %             % Determine equally spaced steps between propAtRef and 95%
    %             properSteps = linspace(propAtRef,95,5);
    %             propStepList(2,1:4) = properSteps(1:4);
    %         else
    %             propStepList(2,1:4) = [propAtRef (propAtRef + [15 25 35])];
    %         end
    %     else
    %         propAtRef = 50;
    %         propStepList(2,1:4) = [propAtRef (propAtRef + [15 25 35])];
    %     end
    %     propStepList(2,5) = 95;
    %     % Find the +15% point
    %     syms xProp2
    %     eqn{2} = 100 * exp(bTemp(1) + bTemp(2) * xProp2') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp2')) == propStepList(2,2);
    %     sol(2) = vpa(solve(eqn{2},xProp2));
    %     % Find the +25% point
    %     syms xProp3
    %     eqn{3} = 100 * exp(bTemp(1) + bTemp(2) * xProp3') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp3')) == propStepList(2,3);
    %     sol(3) = vpa(solve(eqn{3},xProp3));
    %     % Find the +35% point
    %     syms xProp4
    %     eqn{4} = 100 * exp(bTemp(1) + bTemp(2) * xProp4') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp4')) == propStepList(2,4);
    %     sol(4) = vpa(solve(eqn{4},xProp4));
    %     % Find the 99.9999% point
    %     syms xProp5
    %     eqn{5} = 100 * exp(bTemp(1) + bTemp(2) * xProp5') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp5')) == propStepList(2,5);
    %     sol(5) = vpa(solve(eqn{5},xProp5));
    %     if sol(5) > 2   % If for some reason this value exceeds 90 degrees just make it 90 degrees
    %         sol(5) = 2;
    %     end
    %     % Create the step list to be used in the imaging/recording experiments
    %     stepList(n,2,:) = double(real([(sizeList(1)+standardSize) sol(2) sol(3) sol(4) sol(5)]));
    %
    %     subplot(1,2,2)
    %     h(n,i) = plot(x_axis_size,100*percentLarge(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
    %     hold on
    %     set(gca,'ylim',[0,100]);
    %     set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
    %     plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
    %     plot(xx_axis_size,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
    %     plot(sol(2)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +15% point
    %     plot(sol(3)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +25% point
    %     plot(sol(4)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +35% point
    %     plot(sol(5)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 99.9999% point
    %     title('Size Task');
    %     xlabel('Size (DoVA)');
    %     ylabel('Proportaion Reported Larger');
    %
    
    %     %% Look at the data for orientation while doing the size task and vice versa
    %     % Sum up number of times participant reported test as larger/more rightward
    %     % than reference when doing the opposite task
    %     for j=1:nOri
    %         % Looking at size accuracy while doing the orientation task
    %         numSizeWhileOri(j) = sum(rawdataOri(:,2)==j);
    %         numLargeWhileOri(j) = sum(rawdataOri(:,2)==j & rawdataOri(:,8)==1);
    %         percentLargeWhileOri(j) = numLargeWhileOri(j)/numSizeWhileOri(j);
    %
    %         % Looking at ori accuracy while doing the size task
    %         numOriWhileSize(j) = sum(rawdataSize(:,1)==j);
    %         numRightWhileSize(j) = sum(rawdataSize(:,1)==j & rawdataSize(:,8)==1);
    %         percentRightWhileSize(j) = numRightWhileSize(j)/numOriWhileSize(j);
    %     end
    %
    %     clear datafitTemp bTemp fitData xProp1 xProp2 xProp3 xProp4 xProp5 eqn sol propAtRef
    %
    %     % Calculate fits for ori and size seperately
    %     figure()
    %     % Sie while ori
    %     datafitTemp = [numLargeWhileOri; numSizeWhileOri]';
    %     bTemp = glmfit(x_axis_size',datafitTemp,'binomial','logit');
    %     fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_size') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_size'));
    %     PSETempSizeWhileOri = -bTemp(1)/bTemp(2);   % Looking at size accuracy while doing the orientation task
    %
    %     % Plot participant data
    %     subplot(1,2,1)
    %     h(n,i) = plot(x_axis_size,100*percentLargeWhileOri','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
    %     hold on
    %     set(gca,'ylim',[0,100]);
    %     set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
    %     plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
    %     plot(xx_axis_size,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
    %     title('Size While Doing Orientation');
    %     xlabel('Size (DoVA)');
    %     ylabel('Proportaion Reported Larger');
    %
    %     clear datafitTemp bTemp fitData x60 x70 x80 eqn60 eqn70 eqn80 sol60 sol70 sol80
    %
    %     % Orientation while size
    %     datafitTemp = [numRightWhileSize; numOriWhileSize]';
    %     bTemp = glmfit(x_axis_ori',datafitTemp,'binomial','logit');
    %     fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_ori') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_ori'));
    %     PSETempOriWhileSize = -bTemp(1)/bTemp(2);
    %
    %     subplot(1,2,2)
    %     h(n,i) = plot(x_axis_ori,100*percentRightWhileSize','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
    %     hold on
    %     set(gca,'ylim',[0,100]);
    %     set(gca,'xtick',oriList,'xTickLabels',oriTitle);
    %     plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
    %     plot(xx_axis_ori,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
    %     title('Orientation While Doing Size');
    %     xlabel('Orientation');
    %     ylabel('Proportaion Reported More Rightward');
    
end

%% Group analysis
%
% clear datafitTemp bTemp fitData xProp1 xProp2 xProp3 xProp4 xProp5 eqn sol propAtRef
%
% numOriGroup(:) = mean(numOri,1);
% numRightGroup(:) = mean(numRight,1);
% percentRightGroup = numRight./numOri;
% percentRightMean = mean(percentRightGroup,1);
% percentRightSTE = ste(percentRightGroup,1);
%
% numSizeGroup(:) = mean(numSize,1);
% numLargeGroup(:) = mean(numLarge,1);
% percentLargeGroup = numLarge./numSize;
% percentLargeMean = mean(percentLargeGroup,1);
% percentLargeSTE = ste(percentLargeGroup,1);
%
% % Calculate fits for ori and size seperately
% figure()
% %% Ori
% datafitTemp = [numRightGroup; numOriGroup]';
% bTemp = glmfit(x_axis_ori',datafitTemp,'binomial','logit');
% fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_ori') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_ori'));
% PSETempOri = -bTemp(1)/bTemp(2);
%
% % Determine what points you want to extract to use as step values in other experiments.
% % First determine the % at which their baseline falls (point at which they are comparing ref to ref)
% % Then find the points for baseline + 15,25,35%
% % Find the 50% point (PSE)
% syms xProp1
% eqn{1} = 100 * exp(bTemp(1) + bTemp(2) * xProp1') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp1')) == 50;
% sol(1) = vpa(solve(eqn{1},xProp1));
% % If the 50% point is < the reference values (size=1 DoVA; ori=0 degrees)
% % then find what the reference % is and count up 15, 25, and 35% from that.
% if sol(1) < oriList(1)
%     propAtRef = 100 * exp(bTemp(1) + bTemp(2) * oriList(1)) ./ (1 + exp(bTemp(1) + bTemp(2) * oriList(1)));   % Find % at reference ori value of 0
%     propStepListGroup(1,1:4) = [propAtRef (propAtRef + [15 25 35])];
% else
%     propAtRef = 50;
%     propStepListGroup(1,1:4) = [propAtRef (propAtRef + [15 25 35])];
% end
% propStepListGroup(1,5) = 95;
% % Find the +15% point
% syms xProp2
% eqn{2} = 100 * exp(bTemp(1) + bTemp(2) * xProp2') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp2')) == propStepListGroup(1,2);
% sol(2) = vpa(solve(eqn{2},xProp2));
% % Find the +25% point
% syms xProp3
% eqn{3} = 100 * exp(bTemp(1) + bTemp(2) * xProp3') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp3')) == propStepListGroup(1,3);
% sol(3) = vpa(solve(eqn{3},xProp3));
% % Find the +35% point
% syms xProp4
% eqn{4} = 100 * exp(bTemp(1) + bTemp(2) * xProp4') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp4')) == propStepListGroup(1,4);
% sol(4) = vpa(solve(eqn{4},xProp4));
% % Find the 99.9999% point
% syms xProp5
% eqn{5} = 100 * exp(bTemp(1) + bTemp(2) * xProp5') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp5')) == propStepListGroup(1,5);
% sol(5) = vpa(solve(eqn{5},xProp5));
% if sol(5) > 90   % If for some reason this value exceeds 90 degrees just make it 90 degrees
%     sol(5) = 90;
% end
% % Create the step list to be used in the imaging/recording experiments
% stepListGroup(1,:) = [oriList(1) sol(2) sol(3) sol(4) sol(5)];
%
% % Plot participant data
% subplot(1,2,1)
% h(n,i) = plot(x_axis_ori,100*percentRightMean(:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
% hold on
% errorbar(oriList,percentRightMean*100,percentRightSTE*100,'.k');
% set(gca,'ylim',[0,100]);
% set(gca,'xtick',oriList,'xTickLabels',oriTitle);
% plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
% plot(xx_axis_ori,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
% plot(sol(2)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +15% point
% plot(sol(3)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +25% point
% plot(sol(4)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +35% point
% plot(sol(5)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 99.9999% point
% xlim([oriList(1)-5 oriList(end)+5]);
% title('Orientation Task');
% xlabel('Orientation');
% ylabel('Proportaion Reported More Rightward');
%
%
% clear datafitTemp bTemp fitData xProp1 xProp2 xProp3 xProp4 xProp5 eqn sol propAtRef
%
% %% Size
% datafitTemp = [numLargeGroup; numSizeGroup]';
% bTemp = glmfit(x_axis_size',datafitTemp,'binomial','logit');
% fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_size') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_size'));
% PSETempSize = -bTemp(1)/bTemp(2);
%
% % Determine what points you want to extract to use as step values in other experiments.
% % First determine the % at which their baseline falls (point at which they are comparing ref to ref)
% % Then find the points for baseline + 15,25,35%
% % Find the 50% point (PSE)
% syms xProp1
% eqn{1} = 100 * exp(bTemp(1) + bTemp(2) * xProp1') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp1')) == 50;
% sol(1) = vpa(solve(eqn{1},xProp1));
% % If the 50% point is < the reference values (size=1 DoVA; ori=0 degrees)
% % then find what the reference % is and count up 15, 25, and 35% from that.
% if sol(1) < (sizeList(1)+standardSize)
%     propAtRef = 100 * exp(bTemp(1) + bTemp(2) * (sizeList(1)+standardSize)) ./ (1 + exp(bTemp(1) + bTemp(2) * (sizeList(1)+standardSize)));   % Find % at reference size value of 1
%     propStepList(2,1:4) = [propAtRef (propAtRef + [15 25 35])];
% else
%     propAtRef = 50;
%     propStepList(2,1:4) = [propAtRef (propAtRef + [15 25 35])];
% end
% propStepList(2,5) = 95;
% % Find the +15% point
% syms xProp2
% eqn{2} = 100 * exp(bTemp(1) + bTemp(2) * xProp2') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp2')) == propStepList(2,2);
% sol(2) = vpa(solve(eqn{2},xProp2));
% % Find the +25% point
% syms xProp3
% eqn{3} = 100 * exp(bTemp(1) + bTemp(2) * xProp3') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp3')) == propStepList(2,3);
% sol(3) = vpa(solve(eqn{3},xProp3));
% % Find the +35% point
% syms xProp4
% eqn{4} = 100 * exp(bTemp(1) + bTemp(2) * xProp4') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp4')) == propStepList(2,4);
% sol(4) = vpa(solve(eqn{4},xProp4));
% % Find the 99.9999% point
% syms xProp5
% eqn{5} = 100 * exp(bTemp(1) + bTemp(2) * xProp5') ./ (1 + exp(bTemp(1) + bTemp(2) * xProp5')) == propStepList(2,5);
% sol(5) = vpa(solve(eqn{5},xProp5));
% if sol(5) > 2   % If for some reason this value exceeds 90 degrees just make it 90 degrees
%     sol(5) = 2;
% end
% % Create the step list to be used in the imaging/recording experiments
% stepListGroup(2,:) = [(sizeList(1)+standardSize) sol(2) sol(3) sol(4) sol(5)];
%
% subplot(1,2,2)
% h(n,i) = plot(x_axis_size,100*percentLargeMean','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
% hold on
% errorbar(sizeList+standardSize,percentLargeMean*100,percentLargeSTE*100,'.k');
% set(gca,'ylim',[0,100]);
% set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
% plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
% plot(xx_axis_size,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
% plot(sol(2)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +15% point
% plot(sol(3)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +25% point
% plot(sol(4)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +35% point
% plot(sol(5)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 99.9999% point
% xlim([(standardSize+sizeList(1))-.1 (standardSize+sizeList(end))+.1]);
% title('Size Task');
% xlabel('Size (DoVA)');
% ylabel('Proportaion Reported Larger');









