clear
close all;
con_num=2;

% file_list={'S1_Mean_Pilot','S2_Mean_Pilot','S3_Mean_Pilot'};
% file_list={'S1_MeanHF_Pilot'};
% file_list={'S1_MeanHF3_Pilot','S2_MeanHF3_Pilot'};
% file_list={'BKN_Block2','S1_Block2','S2_Block2','S3_Block2','S4_Block2','S5_Block2','S6_Block2'};
% file_list={'BKN_Block2','S1_Block2','S2_Block2','S3_Block2','S5_Block2','S6_Block2','S7_Block2','S8_Block2','S9_Block'};
file_list={'BKN_Block2'};

% filterList=[0 .3 .5 .7];
% filterList=[0 .7 .8 .9];
% filterList=[0 .7 .8 1.0];
% filterList=[0 .8 .9 1];
filterList=[0 .8];

compareMeanList=[.75 .8 .85 .9 .95 1 1.05 1.1 1.15 1.2 1.25];
final_list=zeros(con_num,11,length(file_list));
xaxis=compareMeanList;
xx_axis=-1.2:.001:100;
xLabels={'0%','80%'};
mycolor=[.7 .7 .7; .3 .3 .3];
lineColor{1}=[.7 .7 .7];
lineColor{2}=[.3 .3 .3];


for a=1:length(file_list)
    
    load(file_list{a});
    
    
    % converting the raw data values to index values for filter and compare
    
    for i=1:length(rawdata)
        for j=11:-1:1
            if rawdata(i,9)==2
                if rawdata(i,4)==compareMeanList(j)
                    rawdata(i,4)=j;
                end
            end
        end
        
    end
    
    
    % Convert Filter list
    for i=1:length(rawdata)
        for j=1:con_num
            if rawdata(i,9)==2
                if rawdata(i,1)==filterList(j)
                    rawdata(i,1)=j;
                end
            end
        end
    end
    
    % presList tells how many of each trial there were smaller list tells
    % how many times they responded larger
    pres_list=zeros(con_num,length(compareMeanList));
    smaller_list=zeros(con_num,length(compareMeanList));
    
    
    for i=1:length(rawdata)
        for j=1:length(compareMeanList)
            if rawdata(i,9)==2
                if rawdata(i,4)==j
                    
                    pres_list(rawdata(i,1),j)=pres_list(rawdata(i,1),j)+1;
                    
                    if rawdata(i,7)==2
                        smaller_list(rawdata(i,1),j)=smaller_list(rawdata(i,1),j)+1;
                    end
                    
                end
            end
        end
    end
    
    % gives a precentage of larger responses per amount of trials at a
    % particular condition
    final_list(:,:,a)=smaller_list./pres_list;
    
    figure
    for j=1:con_num
        %       datafit(:,:,j) = [final_list(j,:,a)',ones(11,1)];
        datafit(:,:,j) = [smaller_list(j,:)',pres_list(j,:)'];
        b(a,:,j) = glmfit(xaxis',datafit(:,:,j),'binomial','logit');
        PSE(a,j) = -b(a,1,j)/b(a,2,j);
        fitdata(j,:,a) = 100* exp(b(a,1,j)+b(a,2,j)*xx_axis')./(1+exp(b(a,1,j)+b(a,2,j)*xx_axis'));
        plot(xaxis,100*final_list(j,:,a)','Color',lineColor{j},'LineWidth',2);
        hold on
        plot(xx_axis,fitdata(j,:,a),'Color',lineColor{j});
        plot(xaxis,50*ones(length(xaxis),1),'r--','LineWidth',2);
        set(gca,'ylim',[0,100]);
        set(gca,'xlim',[.75,1.25]);
        xlabel('Mean (°)')
        ylabel('PSE')
        str = {'',sprintf('%s%d','Data for Subject ',a),''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
    end
    
    figure
    for j = 1:con_num
        bar_h=bar(j,PSE(a,j));
        % Sets the color of the bars to the colors in the colormap
        % specified by mycolor array
        barChild=get(bar_h,'Children');
        set(barChild,'CData',PSE(a,j));
        colormap(mycolor);
        hold on;
        plot(1:con_num,1*ones(con_num,1),'r--','LineWidth',2);
        set(gca,'ylim',[0,2]);
        xlabel('Filter Level (%)')
        ylabel('Mean (°)')
        set(gca, 'XTickLabel',xLabels, 'XTick',1:numel(xLabels))
        % Sets the title as subject a's data
        str = {'',sprintf('%s%d','Data for Subject ',a),''}; % cell-array method
        title(str,'FontSize',15,'FontWeight','bold')
        
    end
    
end


mean_PSE = mean(PSE);
stderr_PSE = std(PSE)/sqrt(length(file_list)-1);
mean_fit =mean(fitdata,3);
mean_results = mean(final_list,3);
figure
for j = 1:con_num
    plot(xaxis,100*mean_results(j,:)','Color',lineColor{j},'LineWidth',2);
    hold on
    plot(xx_axis,mean_fit(j,:),'Color',lineColor{j});
    plot(xaxis,50*ones(length(xaxis),1),'r--','LineWidth',2);
    set(gca,'ylim',[0,100]);
    set(gca,'xlim',[.75,1.25]);
    xlabel('Mean (°)')
    ylabel('PSE')
    str = {'','Mean Data',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    
    % Displays the n value in the top right of the plot
    text(1.2,90,sprintf('%s%d','N = ',length(file_list)));
end
figure
for j = 1:con_num
    bar_h=bar(j,mean_PSE(j));
    % Sets the color of the bars to the colors in the colormap
    % specified by mycolor array
    barChild=get(bar_h,'Children');
    set(barChild,'CData',mean_PSE(j));
    colormap(mycolor);
    hold on;
    errorbar(j,mean_PSE(j),stderr_PSE(j),'k.');
    plot(1:con_num,1*ones(con_num,1),'r--','LineWidth',2);
    set(gca,'ylim',[0,2]);
    xlabel('Filter Level (%)')
    ylabel('Mean (°)')
    set(gca, 'XTickLabel',xLabels, 'XTick',1:numel(xLabels))
    str = {'','Mean Data',''}; % cell-array method
    title(str,'FontSize',15,'FontWeight','bold')
    
    % Displays the n value in the top right of the plot
    text(1.9,1.9,sprintf('%s%d','N = ',length(file_list)));
end

save('PSE_vals','mean_PSE','stderr_PSE','mean_fit','mean_results');





