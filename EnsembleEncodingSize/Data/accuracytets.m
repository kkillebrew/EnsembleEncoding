
clear all
close all

datafile='WeberAndAccuracy';

compareMeanList=[.5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5];
xaxis=compareMeanList;
xx_axis=-1.2:.001:100;    % Sampling rate
color = {'g','m','r','b','c'};

weber={'filename' 'filter' 'PSE' '75%' 'weber' '25%' 'weber' 'mean weber'};
weber_average=[];

for w=5:5
    if w==1
        con_num=4;
        file_list={'S1_Mean_Pilot','S2_Mean_Pilot','S3_Mean_Pilot'};
        means_list=[2.3 2.4 2.5 2.6 2.7];
        filter_list=[0 .3 .5 .7];
    end
    if w==2
        con_num=4;
        file_list={'S1_MeanHF_Pilot','S1_MeanHF_Pilot'};
        means_list=[2.3 2.4 2.5 2.6 2.7];
        filter_list=[0 .7 .8 .9];
    end
    if w==3
        con_num=4;
        file_list={'S1_MeanHF2_Pilot','S2_MeanHF2_Pilot','Cody_MeanHF2_Pilot','Jason_MeanHF2_Pilot'};
        means_list=[2.0 2.3 2.6 2.9 3.2];
        filter_list=[0 .7 .8 1];
    end
    if w==4
        con_num=4;
        file_list={'S1_MeanHF3_Pilot','S2_MeanHF3_Pilot'};
        means_list=[2.0 2.3 2.6 2.9 3.2];
        filter_list=[0 .8 .9 1];
    end
    if w==5
        con_num=6;
         file_list={'S1_MeanAnnulus_Pilot','S2_MeanAnnulus_Pilot','S3_MeanAnnulus_Pilot','S4_MeanAnnulus_Pilot','S5_MeanAnnulus_Pilot','S6_MeanAnnulus_Pilot'};
        % 'S1_MeanAnnulus_Pilot','S2_MeanAnnulus_Pilot','S3_MeanAnnulus_Pilot',
%                 file_list={'S4_MeanAnnulus_Pilot','S4_MeanAnnulus_Pilot'};

        means_list=[0.8 0.95 1.1 1.25 1.4];
        filter_list=[0 .2 .4 .6 .8 1];
    end
    
    final_list=zeros(con_num,11,length(file_list));
    holderWeber=[];
    holderActaul=[];
    holderPSE=[];
    holderMeans=[];
    
    for a=1:length(file_list)
        load(file_list{a});
        
        
        for i=1:length(rawdata)
            for j=1:11
                if rawdata(i,4)==compareMeanList(j)
                    rawdata(i,4)=j;
                end
            end
        end
        
        if w>=3 && w~=5
            % Convert for Filter RawData only for filter list values of 1
            for i=1:length(rawdata)
                if rawdata(i,1)==filter_list(4)
                    rawdata(i,1)=4;
                end
            end
            for i=1:length(rawdata)
                for j=1:3
                    if rawdata(i,1)==filter_list(j)
                        rawdata(i,1)=j;
                    end
                end
            end
        end
        
        if w==5
            % Convert for Filter RawData only for filter list values of 1
            for i=1:length(rawdata)
                if rawdata(i,1)==filter_list(6)
                    rawdata(i,1)=6;
                end
            end
            for i=1:length(rawdata)
                for j=1:5
                    if rawdata(i,1)==filter_list(j)
                        rawdata(i,1)=j;
                    end
                end
            end
        end
        
        if w<3
            % Convert for Filter Data
            for i=1:length(rawdata)
                for j=1:4
                    if rawdata(i,1)==filter_list(j)
                        rawdata(i,1)=j;
                    end
                end
                
            end
        end
        
        pres_list=zeros(con_num,11);
        smaller_list=zeros(con_num,11);
        
        
        for i=1:length(rawdata)
            for j=1:11
                if rawdata(i,4)==j
                    
                    pres_list(rawdata(i,1),j)=pres_list(rawdata(i,1),j)+1;
                    
                    if rawdata(i,6)==2
                        smaller_list(rawdata(i,1),j)=smaller_list(rawdata(i,1),j)+1;
                    end
                    
                end
            end
        end
        
        %         final_list(:,:,a)=smaller_list./pres_list;
        
      
        for j=1:con_num
            %             datafit(:,:,j) = [final_list(j,:,a)',ones(11,1)];
            datafit(:,:,j) = [smaller_list(j,:)',pres_list(j,:)'];       % Accounting for number of values at for each condition
            b(a,:,j) = glmfit(xaxis',datafit(:,:,j),'binomial','logit');
            PSE(a,j) = -b(a,1,j)/b(a,2,j);
            fitdata(j,:,a) = 100* exp(b(a,1,j)+b(a,2,j)*xx_axis')./(1+exp(b(a,1,j)+b(a,2,j)*xx_axis'));
        end
        
        %         for i=1:length(rawdata)
        %             for j=1:length(compareMeanList)
        %                 if rawdata(i,4)==j
        %                     rawdata(i,4)=compareMeanList(j);
        %                     break
        %                 end
        %             end
        %         end
        
        mean_PSE = mean(PSE);
        stderr_PSE = std(PSE)/sqrt(length(file_list)-1);
        mean_fit =mean(fitdata,3);
        mean_results = mean(final_list,3);
        
        
        total_count_means=zeros(1,length(means_list));
        right_count_means=zeros(1,length(means_list));
        total_count_filter=zeros(1,length(filter_list));
        right_count_filter_PSE=zeros(1,length(filter_list));
        right_count_filter_actual=zeros(1,length(filter_list));
        for i=1:length(rawdata)
            if rawdata(i,4)~=1
                for j=1:length(means_list)
                    if rawdata(i,5)==means_list(j)
                        total_count_means(j)=total_count_means(j)+1;
                        if rawdata(i,4)>1
                            if rawdata(i,6)==2
                                right_count_means(j)=right_count_means(j)+1;
                            end
                        else
                            if rawdata(i,6)==1
                                right_count_means(j)=right_count_means(j)+1;
                            end
                        end
                    end
                end
                
                % Accuracy around PSE
                for j=1:length(filter_list)
                    if rawdata(i,1)==j
                        total_count_filter(j)=total_count_filter(j)+1;
                        if rawdata(i,4)>PSE(j)
                            if rawdata(i,6)==2
                                right_count_filter_PSE(j)=right_count_filter_PSE(j)+1;
                            end
                        else
                            if rawdata(i,6)==1
                                right_count_filter_PSE(j)=right_count_filter_PSE(j)+1;
                            end
                        end
                    end
                end
                
                % Accuracy around actual mean
                for j=1:length(filter_list)
                    if rawdata(i,1)==j
                        if rawdata(i,4)>1
                            if rawdata(i,6)==2
                                right_count_filter_actual(j)=right_count_filter_actual(j)+1;
                            end
                        else
                            if rawdata(i,6)==1
                                right_count_filter_actual(j)=right_count_filter_actual(j)+1;
                            end
                        end
                    end
                end
                
            end
        end
        
        %     disp(right_count_means)
        %     disp(total_count_means)
        %     disp(right_count_means./total_count_means)
        right_count_means_percent=right_count_means./total_count_means;
        
        for i=1:length(means_list)
            holderMeans(a,i)=right_count_means_percent(i);
        end
        
        %     disp(right_count_filter)
        %     disp(total_count_filter)
        %     disp(right_count_filter./total_count_filter)
        right_count_filter_PSE_percent=right_count_filter_PSE./total_count_filter;
        
        for i=1:length(filter_list)
            holderPSE(a,i)=right_count_filter_PSE_percent(i);
        end
        
        right_count_filter_actual_percent=right_count_filter_actual./total_count_filter;
        
        for i=1:length(filter_list)
            holderActual(a,i)=right_count_filter_actual_percent(i);
        end
        
        final_list=[];
      
        
        for j=1:con_num
            topval=0;
            botval=0;
            z=1;
            y=1;
            for i=1:length(fitdata)
                if fitdata(j,i,a)>74.5 && fitdata(j,i,a)<75.5
                    topval(z)=i;
                    z=z+1;
                end
                if fitdata(j,i,a)>24.5 && fitdata(j,i,a)<25.5
                    botval(y)=i;
                    y=y+1;
                end
            end
            thetop=mean(topval);
            thebot=mean(botval);
            if round(thetop)~= 0
                final_list(1,j)=xx_axis(round(thetop));
            else
                final_list(1,j)=0;
            end
            if round(thebot)~= 0
                final_list(2,j)=xx_axis(round(thebot));
            else
                final_list(2,j)=0;
            end
        end
        
        for i=1:con_num
            weber{1+i,1}=file_list{a};
            weber{1+i,2}=filter_list(i);
            weber{1+i,3}=PSE(i);
            weber{1+i,4}=final_list(1,i);
            
            if final_list(1,i)==0
                weber{1+i,5}=0;
            else
                weber{1+i,5}=abs(100*((final_list(1,i)/PSE(i))-1));
            end
            
            weber{1+i,6}=final_list(2,i);
            
            if final_list(2,i)==0
                weber{1+i,7}=0;
            else
                weber{1+i,7}=abs(100*(1- (final_list(2,i)/PSE(i))));
            end
            
            if final_list(2,i)==0 || final_list(1,i)==0
                weber{1+i,8}=0;
            else
                weber{1+i,8}=(weber{1+i,7}+weber{1+i,5})/2;
            end
        end
        
        weber
        
        for p=1:length(filter_list)
            holderWeber(a,p)=weber{1+p,8}
        end
        
        
    end
    weber_average(w,:)=mean(holderWeber);
    stderr_weber_average(w,:) = std(weber_average)/sqrt(length(file_list)-1);
    right_count_filter_actual_average(w,:)=mean(holderActual);
    right_count_filter_PSE_average(w,:)=mean(holderPSE);
    right_count_means_average(w,:)=mean(holderMeans);
end

% % If only one subject use this
% disp(right_count_means_average);
% disp(right_count_filter_PSE_average);
% disp(right_count_filter_actual_average);
%
% figure
% bar(right_count_means_average);
% figure
% bar(right_count_filter_PSE_average);
% figure
% bar(right_count_filter_actual_average);


% If multiple subjects use this
% disp(mean(right_count_means_average));
% disp(mean(right_count_filter_PSE_average));
% disp(mean(right_count_filter_actual_average));
%
% figure
% bar(mean(right_count_means_average));
% figure
% bar(mean(right_count_filter_PSE_average));
% figure
% bar(mean(right_count_filter_actual_average));

% disp(weber_average);
% disp(mean(weber_average(:,:,w)));
disp(weber_average(5,:))
bar(weber_average(5,1:5));
hold on
errorbar(weber_average(5,1:5),stderr_weber_average(5,1:5),'k.');
hold off

save(datafile,'weber_average','right_count_means_average','right_count_filter_PSE_average','right_count_filter_actual_average')








