% Plot the staircases for each trial

clear all
close all

nIteration = 2;
nStart = 2;
nFilter = 2;
% filterList=[0 .3 .5 .7];
% filterList=[0 .7 .8 .9];
% filterList=[0 .7 .8 1];
% filterList=[0 .8 .9 1];
filterList=[0 .8];

colorList={'b','r','g','y','m','c'};

% fileList={'S1_Mean_Pilot','S2_Mean_Pilot','S3_Mean_Pilot'};
% fileList={'S1_MeanHF_Pilot'};
% fileList={'S1_MeanHF2_Pilot', 'S2_MeanHF2_Pilot', 'Cody_MeanHF2_Pilot', 'Jason_MeanHF2_Pilot'};
% fileList={'S1_MeanHF3_Pilot','S2_MeanHF3_Pilot'};
fileList={'BKN_Block2','S1_Block2','S2_Block2','S3_Block2','S5_Block2','S6_Block2','S7_Block2','S8_Block2','S9_Block'};

aveList=[];


for a=1:length(fileList)
    load(fileList{a});
    allList = [];
    
    
    % Convert for Filter RawData only for filter list values of 1
    %     for i=1:length(rawdata)
    %         if rawdata(i,1)==filterList(length(filterList))
    %             rawdata(i,1)=length(filterList);
    %         end
    %     end
    for i=1:length(rawdata)
        for j=1:(length(filterList))
            if rawdata(i,9)==1
                if rawdata(i,1)==filterList(j)
                    rawdata(i,1)=j;
                end
            end
        end
    end
    
    %     for i=1:length(rawdata)
    %         for j=1:nFilter
    %             if rawdata(i,1)==filterList(j)
    %                 rawdata(i,1)=j;
    %             end
    %         end
    %     end
    
    % allList makes progressing lists of var vals for each condition
    for i=1:nFilter
        for j=1:nStart
            for k=1:nIteration
                p=1;
                for l=1:length(rawdata)
                    if rawdata(l,9)==1
                        if rawdata(l,1)==i && rawdata(l,3)==j && rawdata(l,2)==k
                            allList(i,j,k,p)=rawdata(l,4);
                            p=p+1;
                        end
                    end
                end
            end
        end
    end
    
    %     for i=1:nFilter
    %         for j=1:nStart
    %             for k=1:nIteration
    %                 p=1;
    %                 for l=1:length(rawdata)
    %                     if rawdata(l,1)==i && rawdata(l,3)==j && rawdata(l,2)==k
    %                         allList(i,j,k,p)=rawdata(l,4);
    %                         p=p+1;
    %                     end
    %                 end
    %             end
    %         end
    %     end
    
    figure
    for i=1:nFilter
        subplot(1,nFilter,i);
        color=0;
        for j=1:nStart
            for k=1:nIteration
                color=color+1;
                for z=1:length(allList(i,j,k,:))
                    bob(z)=allList(i,j,k,z);
                end
                
                plot(bob,colorList{color})
                hold on
                plot(0:length(bob),ones(length(bob)+1),'k')
                
                set(gca,'ylim',[.1,.3]);
                %                 set(gca,'xlim',[-.5,.5]);
            end
        end
    end
end














