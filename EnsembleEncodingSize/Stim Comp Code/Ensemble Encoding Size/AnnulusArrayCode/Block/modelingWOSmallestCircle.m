clear all;
close all;

load('PreallocateBlock');

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

PPD = (1024/mon_width_deg);

dotAmount = 12;
backColor = 0;
dotColor = 128;

% Dot size variables
stdevMean=.2*PPD;
meanNoise=[0.8 0.9 1 1.1 1.2];
meanNoiseCount=length(meanNoise);
meanVar=1.1*PPD;
stdevClearVar=.2*PPD;

% Making the lists
experimentList=[1 2];   % Chooses mean or variance
nExperiment=length(experimentList);
filterList=[0 .8];    % How opaque the filter is
nFilter=length(filterList);
iterationList=[1 2]; % Which number staircase you are on
nIteration=length(iterationList);
startList=[1 2];
nStart=length(startList);
compareMeanList=[.75 .8 .85 .9 .95 1 1.05 1.1 1.15 1.2 1.25];
nCompareMean=length(compareMeanList);
varList=[.1 .12 .14 .16 .18 .2 .22 .24 .26 .28 .3];   % List of different variablities; chooses which set of dots to use
nVar=length(varList);
nTrials=25;    % Number of trials per staircase

actualAverageSizeArray = [];
averageSizeArray = [];
smallestSize = 0;

count = 10000;

for i=1:count
    
    dotSize = [];
    dotSizeNoise=[];
    dotSizeNoise=randn(1,12);
    dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
    dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
    dotSizeNoise=dotSizeNoise*stdevMean;
    dotSizeNoise=dotSizeNoise+(meanNoise(4)*PPD);
    dotSizeNoise=round(dotSizeNoise);
    smallestSize = dotSizeNoise(1);
    for j=1:trialsDotAmount(1)
        if dotSizeNoise(j)<smallestSize
            smallestSize = dotSizeNoise(j);
        end
    end
    % Check to make sure the smallest size is only represented once
    smallestCount = 0;
    for j=1:trialsDotAmount(1)
        if smallestSize == dotSizeNoise(j)
            smallestCount = smallestCount +1;
        end
    end
    counter = 1;
    for j=1:trialsDotAmount(1)
        if dotSizeNoise(j)~=smallestSize
            dotSize(counter) = dotSizeNoise(j);
            counter=counter+1;
        end
    end
    % If there are duplicates of the smallest size adds in an extra
    % smallest size for each duplicate
    if smallestCount ~= 1
        for l = 1:(smallestCount-1)
            counter = counter +1;
            dotSize(counter) = smallestSize;
        end
    end
    averageSizeArray(i) = mean(dotSize);
    actualAverageSizeArray(i) = mean(dotSizeNoise);
end

% for i=1:count
%     
%     dotSizeVar=[];
%     dotSizeClear=[];
%     dotSizeClear=randn(1,trialsDotAmount(1));
%     dotSizeClear=dotSizeClear-mean(dotSizeClear);
%     dotSizeClear=dotSizeClear/(std(dotSizeClear));
%     dotSizeClear=dotSizeClear*stdevClearVar;
%     dotSizeClear=dotSizeClear+meanVar;
%     dotSizeClear=round(dotSizeClear);
%     for j=1:trialsDotAmount(1)
%         trialsDotSizeClearVariance(i,j)=dotSizeClear(j);
%     end
% 
%     % Check to make sure the smallest size is only represented once
%     smallestCount = 0;
%     for j=1:trialsDotAmount(1)
%         if smallestSize == dotSizeNoise(j)
%             smallestCount = smallestCount +1;
%         end
%     end
%     counter = 1;
%     for j=1:trialsDotAmount(1)
%         if dotSizeNoise(j)~=smallestSize
%             dotSize(counter) = dotSizeNoise(j);
%             counter=counter+1;
%         end
%     end
%     % If there are duplicates of the smallest size adds in an extra
%     % smallest size for each duplicate
%     if smallestCount ~= 1
%         for l = 1:(smallestCount-1)
%             counter = counter +1;
%             dotSize(counter) = smallestSize;
%         end
%     end
%     averageSizeArray(i) = mean(dotSize);
%     actualAverageSizeArray(i) = mean(dotSizeNoise);
% end

averageSize = mean(averageSizeArray)/PPD;
actualAverageSize = mean(actualAverageSizeArray)/PPD;

disp(averageSize);
disp(actualAverageSize);

bar([averageSize, actualAverageSize]);






