% This script will perform ttests for each electrode in the sequential and
% simulutaneous conditions and order them based on significance (pval).

clear all
close all

inputFile = '/Users/C-Lab/Google Drive/Lab Projects/Marians Stuff/R15 Full Report/Data/';
load(sprintf('%s',inputFile,'/freqIndex_corrIncorr_10000it_trashcan'));

condNames = {'Sequential','Simultaneous'};

% Average across frequencies
freqAveIndex = squeeze(mean(aveIndex,3));

% Calculate the tstat that corresp with pval of .05
alphaTStat = abs(tinv(.05/2,size(freqAveIndex,1)-1));

% Calculate the threshold that corresp with an FDR of .1
% Initially set the actual difference value to be high
differenceActual([1 2]) = 100;

% Create a range of threshold values
threshold = .001:.001:.1;
numSig = zeros(size(freqAveIndex,2),length(threshold));

% Loop through a range of threshold values to find the one that is
% closest to an FDR of .1 (threshold at which the ratio of expected FA's
% to number of significant electrodes is .1)
for i=1:size(freqAveIndex,2)
    for j=1:length(threshold)
        
        % loop through for all the electrodes
        for z=1:size(freqAveIndex,3)
            % Calculate the tval that corresponds to the threshold that is set
            [S, P(i,j,z), CI, T{i,j,z}] = ttest(freqAveIndex(:,i,z),0,threshold(j));
            
            % How many electrodes are sig at each threshold
            % If the the pval is less than the threshold count up
            if P(i,j,z) < threshold(j)
                numSig(i,j) = numSig(i,j) + 1;
            end
        end
        
        % Calculate the expected number of false positives due to chance at the
        % threshold given
        expectedFA(i,j) = threshold(j)*size(freqAveIndex,3);
        
        % Calculate the FDR for the threshold chosen
        FDR(i,j) = expectedFA(i,j)/numSig(i,j);
        
        % Is the FDR for this threshold the closest to .1?
        differenceHolder = abs(FDR(i,j) - .1);
        if differenceHolder < differenceActual(i)
            differenceActual(i) = differenceHolder;
            closestThresh(i) = FDR(i,j);
            closestThreshP(i) = threshold(j);
            thresholdIdx(i) = j;
        end
    end
end

clear S P CI T

% Calculate the tstat that corresponds with the pval
for i=1:length(closestThreshP)
    thresholdTStat(i) = abs(tinv((closestThreshP(i)/2),size(freqAveIndex,3)-1));
end


% Perform the ttest using participant data for each electrode.
for i=1:size(freqAveIndex,2)   % seq vs sim
    
    for j=1:size(freqAveIndex,3)   % num of electrodes
        [S, P(i,j), CI, T{i,j}] = ttest(freqAveIndex(:,i,j),0,.05);
    end
    
    % Make an array of tvalues from the struct
    for j=1:size(T,2)
        tArray(i,j) = T{i,j}.tstat;
    end
    
    % Sort the tvals based on significance
    [pSorted(i,:), pIndex(i,:)] = sort(P(i,:),2,'ascend');
    tSorted(i,:) = tArray(i,pIndex(i,:));
    
    figure()
    bar(tSorted(i,:))
    line([1,257],[alphaTStat,alphaTStat],'Color',[1 0 0])
%     line([1,257],[thresholdTStat(i),thresholdTStat(i)],'Color',[0 1 0])
    title(condNames{i});
    set(gca,'ylim',[-2,5.5])
    ylabel('Test Statistic')
    
end

% Create arrays to use in brainstorm
index = squeeze(mean(freqAveIndex,1));
index = repmat(index,2,1);

% Make a list of the elec numbers for sig electrodes only
sigElecCounter1 = 0;
sigElecCounter2 = 0;
for i=1:size(tArray,2)
    if tArray(1,i) >= alphaTStat
       sigElecCounter1 = sigElecCounter1 + 1;
       sigElecNum{1}(sigElecCounter1,1) = i; 
    end
    if tArray(2,i) >= alphaTStat
       sigElecCounter2 = sigElecCounter2 + 1;
       sigElecNum{2}(sigElecCounter2,1) = i; 
    end   
end

% save(sprintf('%s',inputFile,'/freqIndex_corrIncorr_10000it_BS'),'index');







