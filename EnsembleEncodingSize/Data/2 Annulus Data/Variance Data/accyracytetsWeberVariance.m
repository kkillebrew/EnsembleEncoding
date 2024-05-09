close all
clear all

file_list={'S1_MeanHF_Pilot'};
con_num=4;
means_list=[2.0 2.3 2.6 2.9 3.2];
filter_list=[0 .7 .8 .9];
compareMeanList=[.5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5];
final_list=zeros(con_num,11,length(file_list));
xaxis=compareMeanList;
xx_axis=-1.2:.001:3;
color = {'g','m','r','b','c'};

weber={'filename' 'size' 'PSE' '75%' 'weber' '25%' 'weber' 'mean weber'};

load(file_list{:});

a=1;

for i=1:length(rawdata)
    for j=1:11
        if rawdata(i,4)==compareMeanList(j)
            rawdata(i,4)=j;
        end
    end
end


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

% % Convert for Filter Data
% for i=1:length(rawdata)
%     for j=1:4
%         if rawdata(i,1)==filter_list(j)
%             rawdata(i,1)=j;
%         end
%     end
%
% end

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

final_list(:,:,a)=smaller_list./pres_list;

for j=1:con_num
    %       datafit(:,:,j) = [final_list(j,:,a)',ones(11,1)];
    datafit(:,:,j) = [smaller_list(j,:)',pres_list(j,:)'];
    b(a,:,j) = glmfit(xaxis',datafit(:,:,j),'binomial','logit');
    PSE(a,j) = -b(a,1,j)/b(a,2,j);
    fitdata(j,:,a) = 100* exp(b(a,1,j)+b(a,2,j)*xx_axis')./(1+exp(b(a,1,j)+b(a,2,j)*xx_axis'));
end

for i=1:length(rawdata)
    for j=1:11
        if rawdata(i,4)==j
            rawdata(i,4)=compareMeanList(j);
        end
    end
end


mean_PSE = mean(PSE);
stderr_PSE = std(PSE)/sqrt(length(file_list)-1);
mean_fit =mean(fitdata,3);
mean_results = mean(final_list,3);

total_count_means=zeros(1,length(means_list));
right_count_means=zeros(1,length(means_list));
right_count_meanspse=zeros(1,length(means_list));
total_count_filter=zeros(1,length(filter_list));
right_count_filter=zeros(1,length(filter_list));
right_count_filterpse=zeros(1,length(filter_list));

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
                if rawdata(i,4)>PSE(j)
                    if rawdata(i,6)==2
                        right_count_meanspse(j)=right_count_meanspse(j)+1;
                    end
                else
                    if rawdata(i,6)==1
                        right_count_meanspse(j)=right_count_meanspse(j)+1;
                    end
                end
            end
        end
        
        for j=1:length(filter_list)
            if rawdata(i,1)==j
                total_count_filter(j)=total_count_filter(j)+1;
                if rawdata(i,4)>1
                    if rawdata(i,6)==2
                        right_count_filter(j)=right_count_filter(j)+1;
                    end
                else
                    if rawdata(i,6)==1
                        right_count_filter(j)=right_count_filter(j)+1;
                    end
                end
                if rawdata(i,4)>PSE(j)
                    if rawdata(i,6)==2
                        right_count_filterpse(j)=right_count_filterpse(j)+1;
                    end
                else
                    if rawdata(i,6)==1
                        right_count_filterpse(j)=right_count_filterpse(j)+1;
                    end
                end
            end
        end
    end
end

for j=1:con_num
    topval=0;
    botval=0;
    z=1;
    y=1;
    for i=1:length(fitdata)
        if fitdata(j,i)>74.5 && fitdata(j,i)<75.5
            topval(z)=i;
            z=z+1;
        end
        if fitdata(j,i)>24.5 && fitdata(j,i)<25.5
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

for i=1:4
    weber{1+i,1}=file_list{1};
    weber{1+i,2}=filter_list(i);
    weber{1+i,3}=PSE(i);
    weber{1+i,4}=final_list(1,i);
    
    if final_list(1,i)==0
        weber{1+i,5}=0;
    else
        weber{1+i,5}=100*((final_list(1,i)/PSE(i))-1);
    end
    
    weber{1+i,6}=final_list(2,i);
    
    if final_list(2,i)==0
        weber{1+i,7}=0;
    else
        weber{1+i,7}=100*(1- (final_list(2,i)/PSE(i)));
    end
    
    if final_list(2,i)==0 || final_list(1,i)==0
        weber{1+i,8}=0;
    else
        weber{1+i,8}=((100*(1- (final_list(2,i)/PSE(i))))+(100*((final_list(1,i)/PSE(i))-1)))/2;
    end
end

disp(right_count_means)
disp(total_count_means)
disp(right_count_means./total_count_means)

disp(right_count_meanspse)
disp(total_count_means)
disp(right_count_meanspse./total_count_means)

disp(right_count_filter)
disp(total_count_filter)
disp(right_count_filter./total_count_filter)

disp(right_count_filterpse)
disp(total_count_filter)
disp(right_count_filterpse./total_count_filter)

disp(weber);

