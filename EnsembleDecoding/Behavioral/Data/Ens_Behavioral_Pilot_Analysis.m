% Analysis of behavioral data to find feature steps - 080918

clear all; close all;

% Load in participants data
cd ../../
ensDataStruct = ensLoadData('Behavioral','All');
cd ./Behavioral/Data/

prettyFigs = 1;

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

propStepList(1) = 65;
propStepList(2) = 75;
propStepList(3) = 85;
propStepList(4) = 95;

%% Individual participant analysis

for n=21
    % for n=1:length(ensDataStruct.subjid)
    % for n=find(strcmp(ensDataStruct.subjid,'VG')==1)
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
    %% Ori
    cumulativeFit = @(p,x) erf((x-p(1))/(p(2)*sqrt(2)));
    bTemp = nlinfit(x_axis_ori', [.5 percentRight(n,2:end)]', cumulativeFit, [3 5]);
    fitdata = cumulativeFit(bTemp,xx_axis_ori');
    
    % Find the 65% point
    syms xProp1
    eqn{1} = 100 * erf((xProp1'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1);
    sol(1) = vpa(solve(eqn{1},xProp1));
    
    % Find the 75% point
    syms xProp2
    eqn{2} = 100 * erf((xProp2'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(2);
    sol(2) = vpa(solve(eqn{2},xProp2));
    
    % Find the 85% point
    syms xProp3
    eqn{3} = 100 * erf((xProp3'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(3);
    sol(3) = vpa(solve(eqn{3},xProp3));
    
    % Find the 95% point
    syms xProp4
    eqn{4} = 100 * erf((xProp4'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(4);
    sol(4) = vpa(solve(eqn{4},xProp4));
    
    % Create the step list to be used in the imaging/recording experiments
    stepListAll(n,1,:) = double([oriList(1) sol(1) sol(2) sol(3) sol(4)]);
    
    % Plot participant data
    if prettyFigs == 0
        thatFig = figure('Name',ensDataStruct.subjid{n});
        subplot(1,2,1)
        plot(x_axis_ori,100*percentRight(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
        hold on
        set(gca,'ylim',[0,110]);
        set(gca,'xtick',oriList,'xTickLabels',oriTitle);
        plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
        plot(xx_axis_ori,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
        plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
        plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
        plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
        plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
        title('Orientation Task');
        xlabel('Orientation');
        ylabel('Proportaion Reported More Rightward');
    end
    
    % Calculate each individual accuracy
    for i=1:5   % Orientation
        for j=1:5   % Size
            oriAccBySize(n,i,j) = 100.*(sum(rawdataOri(rawdataOri(:,1)==i & rawdataOri(:,2)==j,8)==1)./4);
        end
    end
    
    %     for i=1:5
    %
    %         % Plot rawdata
    %         subplot(2,6,i+1)
    %         plot(oriAccBySize(n,:,i));
    %         hold on
    %         set(gca,'ylim',[0,110]);
    %         set(gca,'xtick',oriList,'xTickLabels',oriTitle);
    %         title('Orientation Task');
    %         xlabel('Orientation');
    %         ylabel('Proportaion Reported More Rightward');
    %
    %     end
    
    
    %% Make and save pretty figs for presentations
    if prettyFigs == 1
        if n==21
            cd ./Figures/PrettyFigs/
            % fig_box = 'off'; %Figure border on/off
            fig_dims = [500 500 1000 1000];   % Size of figure
            fig_size = 4; %Thickness of borders
            fig_box = 'on'; %Figure border on/off
            
            % Change directory
            
            % Plot data for one individual to show their individual levels
            %     close all
            
            % Plot participant data
            thisFig = figure('Name','KL Individual Behavioral Data Orientation','Units','pixels');
            plot(x_axis_ori,100*percentRight(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
            hold on
            set(gca,'ylim',[0,110]);
            set(gca,'xtick',oriList,'xTickLabels',oriTitle);
            plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
            plot(xx_axis_ori,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
            plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
            plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
            plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
            plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
            title('Orientation Task','FontSize',30,'Units','pixels');
            xAX = get(gca,'XAxis');   % Change font of x/y ticks
            set(xAX,'FontSize',25);
            yAX = get(gca,'YAxis');
            set(yAX,'FontSize',25);
            xlabel('Orientation Level (°)','FontSize',30);
            ylabel('Proportaion Reported More Rightward','FontSize',30);
            
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
            print(thisFig,sprintf('%s%d','Ens_Behav_ExampParticipant_Ori'),'-dpdf');
            cd ../../
        end
    end   
    
    %% Make and save pretty figs for presentations using both ori and size
    if prettyFigs == 1
        if n==21
            % fig_box = 'off'; %Figure border on/off
            fig_dims = [1 1 6 3];   % Size of figure
            fig_size = 2; %Thickness of borders
            fig_box = 'on'; %Figure border on/off
            
            % Change directory
            
            % Plot data for one individual to show their individual levels
            %     close all
            
            % Plot participant data
            thisFigComb = figure('Name','KL Individual Behavioral Data Orientation','Units','inches');
            subplot(1,2,1)
            plot(x_axis_ori,100*percentRight(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
            hold on
            set(gca,'ylim',[0,110]);
            set(gca,'xtick',oriList,'xTickLabels',oriTitle);
            plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
            plot(xx_axis_ori,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
            plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
            plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
            plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
            plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
            title('Orientation Task','FontSize',15,'Units','pixels');
            xAX = get(gca,'XAxis');   % Change font of x/y ticks
            set(xAX,'FontSize',10);
            yAX = get(gca,'YAxis');
            set(yAX,'FontSize',10);
            xlabel('Orientation Level (°)','FontSize',12);
            ylabel('Proportaion Reported More Rightward','FontSize',12);
            
            %Make background white
            set(gcf,'color','white')
            %Specify demensions of figure
            set(thisFigComb,'position',fig_dims)
            %Set figure thickness and border
            hold on
            set(gca,'linewidth',fig_size,'box',fig_box)
            
            % y-axis are levels being correlated
            set(gca,'TickLength',[0 0])
            
%             % Save image
%             thisFigComb.PaperPositionMode = 'auto';
%             thisFigComb.PaperSize = [thisFigComb.PaperPosition(3) thisFigComb.PaperPosition(4)];
%             print(thisFigComb,sprintf('%s%d','Ens_Behav_ExampParticipant_Size'),'-dpdf');
%             cd ../../
        end
    end
    
    %% Size  
    clear bTemp fitData xProp1 xProp2 xProp3 xProp4 eqn sol
    
    cumulativeFit = @(p,x) erf((x-p(1))/(p(2)*sqrt(2)));
    bTemp = nlinfit(x_axis_size', [.5 percentLarge(n,2:end)]', cumulativeFit, [3 2]);
    fitdata = cumulativeFit(bTemp,xx_axis_size');

    % Find the 65% point
    syms xProp1
    eqn{1} = 100 * erf((xProp1'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1);
    sol(1) = vpa(solve(eqn{1},xProp1));
    
    % Find the 75% point
    syms xProp2
    eqn{2} = 100 * erf((xProp2'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(2);
    sol(2) = vpa(solve(eqn{2},xProp2));
    
    % Find the 85% point
    syms xProp3
    eqn{3} = 100 * erf((xProp3'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(3);
    sol(3) = vpa(solve(eqn{3},xProp3));
    
    % Find the 95% point
    syms xProp4
    eqn{4} = 100 * erf((xProp4'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(4);
    sol(4) = vpa(solve(eqn{4},xProp4));
    
    % Create the step list to be used in the imaging/recording experiments
    stepListAll(n,2,:) = double([oriList(1) sol(1) sol(2) sol(3) sol(4)]);
    
    if prettyFigs == 0
        subplot(1,2,2)
        h(n,i) = plot(x_axis_size,100*percentLarge(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
        hold on
        set(gca,'ylim',[0,110]);
        set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
        plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
        plot(xx_axis_size,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
        plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
        plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
        plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
        plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
        title('Size Task');
        xlabel('Size (DoVA)');
        ylabel('Proportaion Reported Larger');
    end
    
    % Calculate each individual accuracy
    for j=1:5   % Orientation
        for i=1:5   % Size
            sizeAccByOri(n,j,i) = 100.*(sum(rawdataSize(rawdataSize(:,1)==i & rawdataSize(:,2)==j,8)==1)./4);
        end
    end
        
%     for i=1:5
%         
%         % Plot rawdata
%         subplot(2,6,i+7)
%         plot(x_axis_size,sizeAccByOri(n,:,i));
%         hold on
%         set(gca,'ylim',[0,110]);
%         set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
%         title('Size Task');
%         xlabel('Size');
%         ylabel('Proportaion Reported Larger');
%         
%     end
    
    %% Make and save pretty figs for presentations
    if prettyFigs == 1
        if n==21
            cd ./Figures/PrettyFigs/
            % fig_box = 'off'; %Figure border on/off
            fig_dims = [500 500 1000 1000];   % Size of figure
            fig_size = 4; %Thickness of borders
            fig_box = 'on'; %Figure border on/off
            
            % Change directory
            
            % Plot data for one individual to show their individual levels
            %     close all
            
            % Plot participant data
            thisFig = figure('Name','KL Individual Behavioral Data Size','Units','pixels');
            plot(x_axis_size,100*percentLarge(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
            hold on
            set(gca,'ylim',[0,110]);
            set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
            plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
            plot(xx_axis_size,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
            plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
            plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
            plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
            plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
            xAX = get(gca,'XAxis');   % Change font of x/y ticks
            title('Size Task','FontSize',30,'Units','pixels');
            set(xAX,'FontSize',25);
            yAX = get(gca,'YAxis');
            set(yAX,'FontSize',25);
            xlabel('Size Level (DoVA)','FontSize',30);
            ylabel('Proportaion Reported Large','FontSize',30);
            
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
            print(thisFig,sprintf('%s%d','Ens_Behav_ExampParticipant_Size'),'-dpdf');
            cd ../../
        end
    end
    
    %% Make and save pretty figs for presentations using both ori and size
    if prettyFigs == 1
        if n==21
            cd ./Figures/PrettyFigs/
            
            fig_dims = [1 1 6 3];   % Size of figure
            fig_size = 2; %Thickness of borders
            fig_box = 'on'; %Figure border on/off
            
            % Plot participant data
%             figure(thisFigComb,'Name','KL Individual Behavioral Data Size','Units','pixels');
            figure(thisFigComb);
            subplot(1,2,2)
            plot(x_axis_size,100*percentLarge(n,:)','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
            hold on
            set(gca,'ylim',[0,110]);
            set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
            plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
            plot(xx_axis_size,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
            plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
            plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
            plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
            plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
            title('Size Task','FontSize',15,'Units','pixels');
            xAX = get(gca,'XAxis');   % Change font of x/y ticks
            set(xAX,'FontSize',10);
            yAX = get(gca,'YAxis');
            set(yAX,'FontSize',10);
            xlabel('Size Level (DoVA)','FontSize',12);
            ylabel('Proportaion Reported Large','FontSize',12);
            
            %Make background white
            set(gcf,'color','white')
            %Specify demensions of figure
            set(thisFigComb,'position',fig_dims)
            %Set figure thickness and border
            hold on
            set(gca,'linewidth',fig_size,'box',fig_box)
            
            % y-axis are levels being correlated
            set(gca,'TickLength',[0 0])
            
            % Save image
%             thisFigComb.PaperPositionMode = 'auto';
%             thisFigComb.PaperSize = [thisFigComb.PaperPosition(3) thisFigComb.PaperPosition(4)];
            print(thisFigComb,sprintf('%s%d','Ens_Behav_ExampParticipant_Combined.tif'),'-dtiffn');
            cd ../../
        end
    end

    %% Save the stepList values to participants behavioral data file
%     stepList(:,:) = stepListAll(n,:,:);
%     save(sprintf('%s',ensDataStruct.subjid{n},'_Ens_Behavioral_001'),'stepList','-append');

end
% 
% %% Ori
% clear datafitTemp bTemp fitData xProp1 xProp2 xProp3 xProp4 xProp5 eqn sol propAtRef
% 
% numOriGroup(:) = mean(numOri,1);
% numRightGroup(:) = mean(numRight,1);
% percentRightGroup = numRight./numOri;
% percentRightMean = mean(percentRightGroup,1);
% percentRightSTE = ste(percentRightGroup,1);
% 
% cumulativeFit = @(p,x) erf((x-p(1))/(p(2)*sqrt(2)));
% bTemp = nlinfit(x_axis_ori', [.5 percentRightMean(1,2:end)]', cumulativeFit, [3 5]);
% fitdata = cumulativeFit(bTemp,xx_axis_ori');
% 
% % Find the 65% point
% syms xProp1
% eqn{1} = 100 * erf((xProp1'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1);
% sol(1) = vpa(solve(eqn{1},xProp1));
% 
% % Find the 75% point
% syms xProp2
% eqn{2} = 100 * erf((xProp2'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(2);
% sol(2) = vpa(solve(eqn{2},xProp2));
% 
% % Find the 85% point
% syms xProp3
% eqn{3} = 100 * erf((xProp3'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(3);
% sol(3) = vpa(solve(eqn{3},xProp3));
% 
% % Find the 95% point
% syms xProp4
% eqn{4} = 100 * erf((xProp4'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(4);
% sol(4) = vpa(solve(eqn{4},xProp4));
% 
% %     % Create the step list to be used in the imaging/recording experiments
% %     stepListAll(n,1,:) = double([oriList(1) sol(1) sol(2) sol(3) sol(4)]);
% %     % Create the step list to be used in the imaging/recording experiments
% %     stepListGroup(1,:) = [oriList(1) sol(2) sol(3) sol(4) sol(5)];
% 
% % Plot participant data
% figure('Name','Average')
% subplot(2,6,1)
% h(n,i) = plot(x_axis_ori,100*percentRightMean','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
% hold on
% errorbar(x_axis_ori,100*percentRightMean',100*percentRightSTE','.k');
% set(gca,'ylim',[0,110]);
% set(gca,'xtick',oriList,'xTickLabels',oriTitle);
% plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
% plot(xx_axis_ori,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
% plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the 65% point
% plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the 75% point
% plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the 85% point
% plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 95% point
% title('Orientation Task');
% xlabel('Orientation');
% ylabel('Proportaion Reported More Rightward');
% 
% meanOriAccBySize = squeeze(mean(oriAccBySize,1))';
% steOriAccBySize = squeeze(ste(oriAccBySize,1))';
% 
% for i=1:5
%     subplot(2,6,i+1)
%     plot(x_axis_ori,meanOriAccBySize(i,:));
%     hold on
%     errorbar(x_axis_ori,meanOriAccBySize(i,:),steOriAccBySize(i,:),'.k');
%     set(gca,'ylim',[0,110]);
%     set(gca,'xtick',oriList,'xTickLabels',oriTitle);
%     title('Orientation Task');
%     xlabel('Orientation');
%     ylabel('Proportaion Reported More Rightward');
% end
% 
% clear datafitTemp bTemp fitData xProp1 xProp2 xProp3 xProp4 xProp5 eqn sol propAtRef
% 
% 
% %% Size
% numSizeGroup(:) = mean(numSize,1);
% numLargeGroup(:) = mean(numLarge,1);
% percentLargeGroup = numLarge./numSize;
% percentLargeMean = mean(percentLargeGroup,1);
% percentLargeSTE = ste(percentLargeGroup,1);
% 
% cumulativeFit = @(p,x) erf((x-p(1))/(p(2)*sqrt(2)));
% bTemp = nlinfit(x_axis_size', [.5 percentLargeMean(1,2:end)]', cumulativeFit, [3 2]);
% fitdata = cumulativeFit(bTemp,xx_axis_size');
% 
% % Find the 65% point
% syms xProp1
% eqn{1} = 100 * erf((xProp1'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(1);
% sol(1) = vpa(solve(eqn{1},xProp1));
% 
% % Find the 75% point
% syms xProp2
% eqn{2} = 100 * erf((xProp2'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(2);
% sol(2) = vpa(solve(eqn{2},xProp2));
% 
% % Find the 85% point
% syms xProp3
% eqn{3} = 100 * erf((xProp3'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(3);
% sol(3) = vpa(solve(eqn{3},xProp3));
% 
% % Find the 95% point
% syms xProp4
% eqn{4} = 100 * erf((xProp4'-bTemp(1))/(bTemp(2)*sqrt(2))) == propStepList(4);
% sol(4) = vpa(solve(eqn{4},xProp4));
% 
% subplot(2,6,7)
% h(n,i) = plot(x_axis_size,100*percentLargeMean','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
% hold on
% errorbar(sizeList+standardSize,percentLargeMean'*100,percentLargeSTE'*100,'.k');
% set(gca,'ylim',[0,110]);
% set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
% plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
% plot(xx_axis_size,100*fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
% plot(sol(1)*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the +15% point
% plot(sol(2)*ones(51,1),[0:50],'r--','LineWidth',2);    % Plot the +25% point
% plot(sol(3)*ones(51,1),[0:50],'b--','LineWidth',2);    % Plot the +35% point
% plot(sol(4)*ones(51,1),[0:50],'g--','LineWidth',2);    % Plot the 99.9999% point
% xlim([(standardSize+sizeList(1))-.1 (standardSize+sizeList(end))+.1]);
% title('Size Task');
% xlabel('Size (DoVA)');
% ylabel('Proportaion Reported Larger');
% 
% meanSizeAccByOri = squeeze(mean(sizeAccByOri,1))';
% steSizeAccByOri = squeeze(ste(sizeAccByOri,1))';
% 
% for i=1:5
%     subplot(2,6,i+7)
%     plot(x_axis_size,meanSizeAccByOri(i,:));
%     hold on
%     errorbar(sizeList+standardSize,meanSizeAccByOri(i,:),steSizeAccByOri(i,:),'.k');
%     set(gca,'ylim',[0,110]);
%     set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
%     xlim([(standardSize+sizeList(1))-.1 (standardSize+sizeList(end))+.1]);
%     title('Size Task');
%     xlabel('Size');
%     ylabel('Proportaion Reported Larger');
% end






