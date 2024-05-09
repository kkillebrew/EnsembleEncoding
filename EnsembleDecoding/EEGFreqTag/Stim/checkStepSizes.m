datadirBehavioral = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/Behavioral/Data/';
% datadirBehavioral = '/Users/clab/Documents/CLAB/Kyle/Dissertation/Behavioral/Data/';

subjBehavioral = {'KK','MM','JB','TL','NH','TW','ZZ','CM','DP','ES','HA','VG','JV','MC','001','GF','OK','MH','BS','AH','KL','02','MG','06'};   % Subject ID list

expNameBehavioral = 'Ens_Behavioral';

standardSizes = [0 .1 .2 .3 .4];
standardOris = [0 10 20 30 40];

for i=1:length(subjBehavioral)
    
    subjid = subjBehavioral{i};
    stepList = load(sprintf('%s',datadirBehavioral,subjid,'_',expNameBehavioral,'_001'),'stepList');
    oriList(i,:) = double(stepList.stepList(1,[1 2 3 4 5]));
    sizeList(i,:) = double(stepList.stepList(2,[1 2 3 4 5]));
    sizeList(i,[2,3,4,5]) = sizeList(i,[2,3,4,5])-1;
    
end

for i=1:size(oriList,1)
    for j=1:size(oriList,2)
        if oriList(i,j) < standardOris(j)
            oriList2(i,j) = standardOris(j);
        else
            oriList2(i,j) = oriList(i,j);
        end
    end
    
    for j=1:size(sizeList,2)
        if sizeList(i,j) < standardSizes(j)
            sizeList2(i,j) = standardSizes(j);
        else
            sizeList2(i,j) = sizeList(i,j);
        end
    end
end





