clear
% close all;
con_num=5;

% file_list={'S1_Mean_Pilot','S2_Mean_Pilot','S3_Mean_Pilot'};
% file_list={'S1_MeanHF_Pilot'};
% file_list={'S1_MeanHF3_Pilot','S2_MeanHF3_Pilot'};
file_list={'S1_MeanTwoAnnulus_Pilot'};
    
% filterList=[0 .3 .5 .7];
% filterList=[0 .7 .8 .9];
% filterList=[0 .7 .8 1.0];
% filterList=[0 .8 .9 1];
filterList=[0 .2 .4 .6 .8];


compareMeanList=[.5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5];
final_list=zeros(con_num,11,length(file_list));
xaxis=compareMeanList;
xx_axis=-1.2:.001:3;
color = {'g','m','r','b','c','y'};

for a=1:length(file_list)
    
    load(file_list{a});
    
    
    % converting the raw data values to index values for filter and compare
    for i=1:length(rawdata)
        for j=1:11
            if rawdata(i,4)==compareMeanList(j)
                rawdata(i,4)=j;
            end
        end
        
    end
    
    
    % Convert Filter list
    for i=1:length(rawdata)
        for j=1:con_num
            if rawdata(i,1)==filterList(j)
                rawdata(i,1)=j;
            end
        end
    end
    
    
    pres_list=zeros(con_num,length(compareMeanList));
    smaller_list=zeros(con_num,length(compareMeanList));
    
    
    for i=1:length(rawdata)
        for j=1:length(compareMeanList)
            if rawdata(i,4)==j
                
                pres_list(rawdata(i,1),j)=pres_list(rawdata(i,1),j)+1;
                
                if rawdata(i,6)==2
                    smaller_list(rawdata(i,1),j)=smaller_list(rawdata(i,1),j)+1;
                end
                
            end
        end
    end
    
    final_list(:,:,a)=smaller_list./pres_list;
    
    figure
    for j=1:con_num
        %       datafit(:,:,j) = [final_list(j,:,a)',ones(11,1)];
        datafit(:,:,j) = [smaller_list(j,:)',pres_list(j,:)'];
        b(a,:,j) = glmfit(xaxis',datafit(:,:,j),'binomial','logit');
        PSE(a,j) = -b(a,1,j)/b(a,2,j);
        fitdata(j,:,a) = 100* exp(b(a,1,j)+b(a,2,j)*xx_axis')./(1+exp(b(a,1,j)+b(a,2,j)*xx_axis'));
        plot(xaxis,100*final_list(j,:,a)',color{j},'LineWidth',2);
        hold on
        plot(xx_axis,fitdata(j,:,a),color{j});
        plot(xaxis,50*ones(length(xaxis),1),'r--','LineWidth',2);
        set(gca,'ylim',[0,100]);
        set(gca,'xlim',[.4,1.6]);
    end
    
    figure
    for j = 1:con_num
        bar(j,PSE(a,j),color{j});
        hold on;
        plot(1:con_num,120*ones(con_num,1),'r--','LineWidth',2);
        set(gca,'ylim',[0,2]);
    end
    
end


mean_PSE = mean(PSE);
stderr_PSE = std(PSE)/sqrt(length(file_list)-1);
mean_fit =mean(fitdata,3);
mean_results = mean(final_list,3);
figure
for j = 1:con_num
    plot(xaxis,100*mean_results(j,:)',color{j},'LineWidth',2);
    hold on
    plot(xx_axis,mean_fit(j,:),color{j});
    plot(xaxis,50*ones(length(xaxis),1),'r--','LineWidth',2);
    set(gca,'ylim',[0,100]);
    set(gca,'xlim',[.4,1.6]);
    
end
figure
for j = 1:con_num
    bar(j,mean_PSE(j),color{j});
    hold on;
    errorbar(j,mean_PSE(j),stderr_PSE(j),'k.');
    plot(1:con_num,120*ones(con_num,1),'r--','LineWidth',2);
    set(gca,'ylim',[0,2]);
end

save('PSE_vals','mean_PSE','stderr_PSE','mean_fit','mean_results');





