clear all;
close all;
con_num=2;

inputFile = '/Users/C-Lab/Google Drive/Lab Projects/EnsembleEncodingSize/Code/Data/2 Annulus Data/Block/';

% file_list={'S1_Mean_Pilot','S2_Mean_Pilot','S3_Mean_Pilot'};
% file_list={'S1_MeanHF_Pilot'};
% file_list={'S1_MeanHF3_Pilot','S2_MeanHF3_Pilot'};
% file_list={'BKN_Block2','S1_Block2','S2_Block2','S3_Block2','S4_Block2','S5_Block2','S6_Block2'};
file_list={'BKN_Block2','S2_Block2','S3_Block2','S6_Block2','S7_Block2','S8_Block2'};
% file_list={'BKN_Block2','S2_Block2','S3_Block2','S6_Block2','S7_Block2','S8_Block2','S1_Block2','S5_Block2','S9_Block'};

% filterList=[0 .3 .5 .7];
% filterList=[0 .7 .8 .9];
% filterList=[0 .7 .8 1.0];
% filterList=[0 .8 .9 1];
filterList=[0 .8];
varList=[.1 .12 .14 .16 .18 .2 .22 .24 .26 .28 .3];   % List of different variablities; chooses which set of dots to use
compareMeanList=[.75 .8 .85 .9 .95 1 1.05 1.1 1.15 1.2 1.25];
weber_val_list_mean=zeros(con_num,11,length(file_list));
xaxis_mean=compareMeanList;
xaxis_var=varList;

% Sampling rate of the fitdata curvefrom starting to ending points & xaxis
% limits for graphs
xx_axis_mean=-1:.001:5;
xx_axis_var =-5:.001:20;


xLabels={'0%','80%'};
mycolor=[.7 .7 .7; .3 .3 .3];
lineColor{1}='r';
lineColor{2}='b';

% Used to hold the weber values
weber_val_list_mean=[];
weber_val_list_var=[];
% Arrays to hold the weber values
weber_val_mean=[];
weber_val_var=[];

for a=1:length(file_list)
    
    load(file_list{a});
    
    % parsing out the var and mean data from the rawdata list
    var_data  = rawdata(rawdata(:,9)==1,:);
    mean_data = rawdata(rawdata(:,9)==2,:);

    % Times the condition was presented
    pres_count_mean=zeros(con_num,length(compareMeanList));
    pres_count_var=zeros(con_num,length(varList));
    
    % Times the condition was seen as larger
    test_larger_count_mean=zeros(con_num,length(compareMeanList));
    test_larger_count_var=zeros(con_num,length(varList));
    
    for i = 1:length(compareMeanList)
        for j = 1:length(filterList)
            % Caluculating the sum
            pres_count_mean(j,i) = sum((mean_data(:,1)==filterList(j)) & (mean_data(:,4)==compareMeanList(i)));
            pres_count_var(j,i) = sum((var_data(:,1)==filterList(j)) & (var_data(:,4)==varList(i)));
            test_larger_count_mean(j,i) = sum((mean_data(:,1)==filterList(j)) & (mean_data(:,4)==compareMeanList(i))&(mean_data(:,7)==2));
            test_larger_count_var(j,i) = sum((var_data(:,1)==filterList(j)) & (var_data(:,4)==varList(i))&(var_data(:,7)==2));
        end
    end
    
    % Calculates the precentages of hits/times presented
    test_larger_percent_mean(:,:,a) =  test_larger_count_mean./pres_count_mean;
    test_larger_percent_var(:,:,a)  =  test_larger_count_var./pres_count_var;
    
    figure(a)
    for j=1:con_num
        % Array of data for fitdata
        datafit_mean(:,:,j) = [test_larger_count_mean(j,:)',pres_count_mean(j,:)'];
        datafit_var(:,:,j) = [test_larger_count_var(j,:)',pres_count_var(j,:)'];
        % Calculates the beta weights
        b_mean(:,j) = glmfit(xaxis_mean',datafit_mean(:,:,j),'binomial','logit');
        b_var(:,j) = glmfit(xaxis_var',datafit_var(:,:,j),'binomial','logit');
        % Fits the data to the sig curve
        fitdata_mean(j,:) = 100* exp(b_mean(1,j)+b_mean(2,j)*xx_axis_mean')./(1+exp(b_mean(1,j)+b_mean(2,j)*xx_axis_mean'));
        fitdata_var(j,:) = 100* exp(b_var(1,j)+b_var(2,j)*xx_axis_var')./(1+exp(b_var(1,j)+b_var(2,j)*xx_axis_var'));
        %Calculates the PSE values for mean and var using beta weight
        %values
        PSE_mean(j,a) = -b_mean(1,j)./b_mean(2,j);
        PSE_var(j,a) = -b_var(1,j)./b_var(2,j);
        
        % Calculate the 75 and 25 weber values for the fitdata
        topval_mean=0;
        botval_mean=0;
        topval_var=0;
        botval_var=0;
        count_top_mean=1;
        count_bot_mean=1;
        count_top_var=1;
        count_bot_var=1;
        % Find all the values in fitdata for the given ranges
        for i=1:length(fitdata_mean)
            if fitdata_mean(j,i)>74.5 && fitdata_mean(j,i)<75.5
                topval_mean(count_top_mean)=i;
                count_top_mean=count_top_mean+1;
            end
            if fitdata_mean(j,i)>24.5 && fitdata_mean(j,i)<25.5
                botval_mean(count_bot_mean)=i;
                count_bot_mean=count_bot_mean+1;
            end
        end
        for i=1:length(fitdata_var)
            if fitdata_var(j,i)>74.5 && fitdata_var(j,i)<75.5
                topval_var(count_top_var)=i;
                count_top_var=count_top_var+1;
            end
            if fitdata_var(j,i)>24.5 && fitdata_var(j,i)<25.5
                botval_var(count_bot_var)=i;
                count_bot_var=count_bot_var+1;
            end
        end
        % Calculate the mean weber values for 25 and 75 %
%         thetop_mean=mean(topval_mean);
%         thebot_mean=mean(botval_mean);
%         thetop_var=mean(topval_var);
%         thebot_var=mean(botval_var);
%         % Just in case you don't find a value (Make sure the xxaxis range
%         % is great enough and the sampling rate is small enough
%         if round(thetop_mean)~= 0
%             weber_val_list_mean(1,j,a)=xx_axis_mean(round(thetop_mean));
%         else
%             weber_val_list_mean(1,j,a)=0;
%         end
%         if round(thebot_mean)~= 0
%             weber_val_list_mean(2,j,a)=xx_axis_mean(round(thebot_mean));
%         else
%             weber_val_list_mean(2,j,a)=0;
%         end
%         if round(thetop_var)~= 0
%             weber_val_list_var(1,j,a)=xx_axis_var(round(thetop_var));
%         else
%             weber_val_list_var(1,j,a)=0;
%         end
%         if round(thebot_var)~= 0
%             weber_val_list_var(2,j,a)=xx_axis_var(round(thebot_var));
%         else
%             weber_val_list_var(2,j,a)=0;
%         end
%         
%         % Caluculating the weber between 75 and 50 points
%         if weber_val_list_mean(1,j,a)==0
%             weber_val_mean(1,j,a)=0;
%         else
%             weber_val_mean(1,j,a)=abs(100*((weber_val_list_mean(1,j,a)/PSE_mean(j,a))-1));
%         end
%         if weber_val_list_var(1,j,a)==0
%             weber_val_var(1,j,a)=0;
%         else
%             weber_val_var(1,j,a)=abs(100*((weber_val_list_var(1,j,a)/PSE_var(j,a))-1));
%         end
%         % Calculating the weber between 25 and 50 points
%         if weber_val_list_mean(2,j,a)==0
%             weber_val_mean(2,j,a)=0;
%         else
%             weber_val_mean(2,j,a)=abs(100*(1- (weber_val_list_mean(2,j,a)/PSE_mean(j,a))));
%         end
%         if weber_val_list_var(2,j,a)==0
%             weber_val_var(2,j,a)=0;
%         else
%             weber_val_var(2,j,a)=abs(100*(1- (weber_val_list_var(2,j,a)/PSE_var(j,a))));
%         end
%         % Calculating the mean weber value
%         if weber_val_list_mean(2,j,a)==0 || weber_val_list_mean(1,j,a)==0
%             weber_val_mean(3,j,a)=0;
%         else
%             weber_val_mean(3,j,a)=(weber_val_mean(1,j,a)+weber_val_mean(2,j,a))/2;
%         end
%         if weber_val_list_var(2,j,a)==0 || weber_val_list_var(1,j,a)==0
%             weber_val_var(3,j,a)=0;
%         else
%             weber_val_var(3,j,a)=(weber_val_var(1,j,a)+weber_val_var(2,j,a))/2;
%         end

        weber_val_mean(1,j,a)=xx_axis_mean(round(mean(topval_mean)));
        weber_val_mean(2,j,a)=xx_axis_mean(round(mean(botval_mean)));
        weber_val_var(1,j,a)=xx_axis_var(round(mean(topval_var)));
        weber_val_var(2,j,a)=xx_axis_var(round(mean(botval_var)));
        
        if weber_val_mean(1,j,a) == -25 && weber_val_mean(2,j,a) == -25
            weber_val_mean(1,j,a) = NaN;
            weber_val_mean(2,j,a) = NaN;
            sprintf('near chance performance on mean (both ends) CHECK! Subject: %d Cond: %d', a,j)
        elseif weber_val_mean(1,j,a) == -25 && weber_val_mean(2,j,a) ~= -25
            weber_val_mean(1,j,a) = -weber_val_mean(2,j,a);
            sprintf('near chance performance on mean (high end) CHECK! Subject: %d Cond: %d', a,j)
            
        elseif weber_val_mean(1,j,a) ~= -25 && weber_val_mean(2,j,a) == -25
            weber_val_mean(2,j,a) = -weber_val_mean(1,j,a);
            sprintf('near chance performance on mean (low end) CHECK! Subject: %d Cond: %d', a,j)
            
        end
        if weber_val_var(1,j,a) == 0 && weber_val_var(2,j,a) == 0
            weber_val_var(1,j,a) = NaN;
            weber_val_var(2,j,a) = NaN;
            sprintf('near chance performance on var (both ends) CHECK! Subject:%d Cond: %d', a,j)
        elseif weber_val_var(1,j,a) == 0 && weber_val_var(2,j,a) ~= 0
            weber_val_var(1,j,a) = -weber_val_var(2,j,a);
            sprintf('near chance performance on var (high end)CHECK! Subject: %d Cond: %d', a,j)
            
        elseif weber_val_var(1,j,a) ~= 0 && weber_val_var(2,j,a) == 0
            weber_val_var(2,j,a) = -weber_val_var(1,j,a);
            sprintf('near chance performance on var (low end)CHECK! Subject: %d Cond: %d', a,j)
            
        end
        
        % Calculating how good they are at the task (in arbitrary units)
        weber_val_mean(3,j,a)=abs((weber_val_mean(1,j,a)-weber_val_mean(2,j,a))/2);
        weber_val_var(3,j,a)=abs((weber_val_var(1,j,a)-weber_val_var(2,j,a))/2);
        
        % Plot the sig data and fitted curves on subplots
        % Bottom variance top mean
        subplot(2,3,1)
        plot(xaxis_mean,100*test_larger_percent_mean(j,:,a)',lineColor{j},'LineWidth',2);
        set(gca,'ylim',[0,100]);
        set(gca,'xlim',[.75,1.25]);
        hold on;
        plot(xaxis_mean,50*ones(length(xaxis_mean),1),'k--','LineWidth',2);
        plot(xx_axis_mean,fitdata_mean(j,:)',lineColor{j},'LineWidth',2);
        str = {'','Results for Mean',''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
        subplot(2,3,4)
        plot(xaxis_var,100*test_larger_percent_var(j,:,a)',lineColor{j},'LineWidth',2);
        set(gca,'ylim',[0,100]);
        set(gca,'xlim',[.1,.3]);
        hold on;
        plot(xaxis_var,50*ones(length(xaxis_var),1),'k--','LineWidth',2);
        plot(xx_axis_var,fitdata_var(j,:)',lineColor{j},'LineWidth',2);
        str = {'','Results for Variance',''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
        % Plots the PSE data on bar plots
        subplot(2,3,2)
        bar(j,PSE_mean(j,a),lineColor{j})
        hold on
        str = {'','PSE Values for Mean',''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
        subplot(2,3,5)
        bar(j,PSE_var(j,a),lineColor{j})
        hold on
        str = {'','PSE Values for Variance',''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
        % Plots the weber values
        subplot(2,3,3)
        bar(j,weber_val_mean(3,j,a),lineColor{j});
        hold on
        str = {'','Weber Values for Mean',''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
        subplot(2,3,6)
        bar(j,weber_val_var(3,j,a),lineColor{j});
        hold on
        str = {'','Weber Values for Variance',''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
    end
    
end


% Calculating the mean PSE values
mean_PSE_mean = mean(PSE_mean,2);
mean_PSE_var = mean(PSE_var,2);
stderr_PSE_mean = std(PSE_mean,0,2)/sqrt(length(file_list)-1);
stderr_PSE_var = std(PSE_var,0,2)/sqrt(length(file_list)-1);
figure(a+1)

% Calculating the mean data and fitdata
mean_fit_mean =mean(fitdata_mean,3);
mean_results_mean = mean(test_larger_percent_mean,3);
mean_fit_var =mean(fitdata_var,3);
mean_results_var = mean(test_larger_percent_var,3);

% Mean of weber values across subjects
mean_weber_val_mean(1)=nanmean(weber_val_mean(3,1,:));
mean_weber_val_mean(2)=nanmean(weber_val_mean(3,2,:));
mean_weber_val_var(1)=nanmean(weber_val_var(3,1,:));
mean_weber_val_var(2)=nanmean(weber_val_var(3,2,:));
stderr_weber_val_mean(1) = nanstd(weber_val_mean(3,1,:))/sqrt(length(file_list)-1);
stderr_weber_val_mean(2) = nanstd(weber_val_mean(3,2,:))/sqrt(length(file_list)-1);
stderr_weber_val_var(1) = nanstd(weber_val_var(3,1,:))/sqrt(length(file_list)-1);
stderr_weber_val_var(2) = nanstd(weber_val_var(3,2,:))/sqrt(length(file_list)-1);

% Calculating significance (ttest)
[mean_sig, mean_sig_value] = ttest(PSE_mean(1,:),PSE_mean(2,:));
[var_sig, var_sig_value] = ttest(PSE_var(1,:),PSE_var(2,:));
[weber_mean_sig, weber_mean_sig_value] = ttest(weber_val_mean(3,1,:),weber_val_mean(3,2,:));
[weber_var_sig, weber_var_sig_value] = ttest(weber_val_var(3,1,:),weber_val_var(3,2,:));

for j=1:con_num
    
    % Mean results for mean
    subplot(2,3,1)
    plot(xaxis_mean,100*mean_results_mean(j,:)','Color',lineColor{j},'LineWidth',2);
    hold on
    plot(xx_axis_mean,mean_fit_mean(j,:),'Color',lineColor{j},'LineWidth',2);
    plot(xaxis_mean,50*ones(length(xaxis_mean),1),'k--','LineWidth',2);
    set(gca,'ylim',[0,100]);
    set(gca,'xlim',[.75,1.25]);
    str = {'','Average Results for Mean',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    
    % Mean results for variance
    subplot(2,3,4)
    plot(xaxis_var,100*mean_results_var(j,:)','Color',lineColor{j},'LineWidth',2);
    hold on
    plot(xx_axis_var,mean_fit_var(j,:),'Color',lineColor{j},'LineWidth',2);
    plot(xaxis_var,50*ones(length(xaxis_var),1),'k--','LineWidth',2);
    set(gca,'ylim',[0,100]);
    set(gca,'xlim',[.1,.3]);
    str = {'','Average Results for Variance',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    
    % Mean PSE for mean
    subplot(2,3,2)
    bar(j,mean_PSE_mean(j),lineColor{j})
    hold on
    errorbar(j,mean_PSE_mean(j),stderr_PSE_mean(j),'k.','LineWidth',2)
    str = {'','Average PSE Values for Mean',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    % Put asterisks where appropriate
    if mean_PSE_mean(1) > mean_PSE_mean(2)
        if mean_sig ~= 0
            plot([1,2], [mean_PSE_mean(1)+stderr_PSE_mean(1)+.05, mean_PSE_mean(1)+stderr_PSE_mean(1)+.05],'k')
            plot(1.5,[mean_PSE_mean(1)+stderr_PSE_mean(1)+.1],'*-k')
        end
    elseif mean_PSE_mean(2) > mean_PSE_mean(1)
        if mean_sig ~= 0
            plot([1,2], [mean_PSE_mean(2)+stderr_PSE_mean(2)+.05, mean_PSE_mean(2)+stderr_PSE_mean(2)+.05],'k')
            plot(1.5,[mean_PSE_mean(2)+stderr_PSE_mean(2)+.1],'*-k')
        end
    end
    
    % Mean PSE for variance
    subplot(2,3,5)
    bar(j,mean_PSE_var(j),lineColor{j})
    hold on
    errorbar(j,mean_PSE_var(j),stderr_PSE_var(j),'k.','LineWidth',2)
    str = {'','Average PSE Values for Variance',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    % Put asterisks where appropriate
    if mean_PSE_var(1) > mean_PSE_var(2)
        if var_sig ~= 0
            plot([1,2], [mean_PSE_var(1)+stderr_PSE_var(1)+.01, mean_PSE_var(1)+stderr_PSE_var(1)+.01],'k')
            plot(1.5,[mean_PSE_var(1)+stderr_PSE_var(1)+.02],'*-k')
        end
    elseif mean_PSE_var(2) > mean_PSE_var(1)
        if var_sig ~= 0
            plot([1,2], [mean_PSE_var(2)+stderr_PSE_var(2)+.01, mean_PSE_var(2)+stderr_PSE_var(2)+.01],'k')
            plot(1.5,[mean_PSE_var(2)+stderr_PSE_var(2)+.02],'*-k')
        end
    end
    
    % Mean Weber for mean
    subplot(2,3,3)
    bar(j,mean_weber_val_mean(j),lineColor{j});
    hold on
    errorbar(j,mean_weber_val_mean(j),stderr_weber_val_mean(j),'k.','LineWidth',2);
    str = {'','Weber Values for Mean',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    
    % Mean Weber for variance
    subplot(2,3,6)
    bar(j,mean_weber_val_var(j),lineColor{j});
    hold on
    errorbar(j,mean_weber_val_var(j),stderr_weber_val_var(j),'k.','LineWidth',2);
    str = {'','Weber Values for Variance',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    
    
end










