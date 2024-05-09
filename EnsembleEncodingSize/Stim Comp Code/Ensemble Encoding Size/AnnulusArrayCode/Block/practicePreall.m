clear all;
close all;

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

PPD = (1024/mon_width_deg);

datafile='PracticePreallocateBlock';
datafile_full=sprintf('%s_full',datafile);

dotAmount = 12;
backColor = 0;
dotColor = 128;

% Dot size variables
stdevMean=.2*PPD;
meanNoiseTest=1*PPD;
meanNoise=[0.8 0.9 1 1.1 1.2];
meanNoiseCount=length(meanNoise);
meanVar=1.1*PPD;
stdevClearVar=.2*PPD;

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeNoiseMean = [];
trialsDotSizeClearMean = [];
trialsDotSizeClearVariance = [];
trialsDotSizeNoiseVariance = [];

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
nTrials=10;                             % Number of trials per staircase

numTrials=nFilter*nIteration*nStart*nTrials*nExperiment;

% rect=[0 0 2560 1440];     % screen dimension for lab comps
rect=[0 0 1024 768];     % test comps
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

% Preallocating the dot amount
for i=1:numTrials;
    trialsDotAmount(i)=dotAmount;
end

wedgeSize = 360/(dotAmount*2);

% Preallocating the mean conditions
for h=1:meanNoiseCount
    for i=1:numTrials
        dotSizeNoise=[];
        dotSizeNoise=randn(1,trialsDotAmount(i));
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*stdevMean;
        dotSizeNoise=dotSizeNoise+(meanNoiseTest);
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoiseMean(i,j,h)=dotSizeNoise(j);
        end
    end
end

for k=1:nCompareMean
    for h=1:meanNoiseCount
        for i=1:numTrials
            dotSizeNoise=[];
            dotSizeNoise=randn(1,trialsDotAmount(i));
            dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
            dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
            dotSizeNoise=dotSizeNoise*stdevMean;
            dotSizeNoise=dotSizeNoise+((meanNoise(h)*PPD)*compareMeanList(k));
            dotSizeNoise=round(dotSizeNoise);
            for j=1:trialsDotAmount(i)
                trialsDotSizeClearMean(i,j,h,k)=dotSizeNoise(j);
            end
        end
    end
end


% Preallocating the variance condition
for i=1:numTrials
    dotSizeClear=[];
    dotSizeClear=randn(1,trialsDotAmount(i));
    dotSizeClear=dotSizeClear-mean(dotSizeClear);
    dotSizeClear=dotSizeClear/(std(dotSizeClear));
    dotSizeClear=dotSizeClear*stdevClearVar;
    dotSizeClear=dotSizeClear+meanVar;
    dotSizeClear=round(dotSizeClear);
    for j=1:trialsDotAmount(i)
        trialsDotSizeClearVariance(i,j)=dotSizeClear(j);
    end
end

for h=1:nVar
    for i=1:numTrials
        dotSizeNoise=[];
        dotSizeNoise=randn(1,trialsDotAmount(i));
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*varList(h)*PPD;
        dotSizeNoise=dotSizeNoise+meanVar;
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoiseVariance(i,j,h)=dotSizeNoise(j);
        end
    end
end

% Preallocating the noise filter for each trial
noiseMatrix=[];
for i=1:1440
    for j=1:2560
        n=randi(2);
        if n==1
            noiseMatrix(i,j)=255;
        else
            noiseMatrix(i,j)=0;
        end
    end
end
destRect = [0,0,rect(3),rect(4)];


save(datafile,'rect', 'PPD', 'filterList', 'nFilter', 'startList', 'nStart', 'nTrials', 'iterationList', 'nIteration', ...
    'trialsDotAmount', 'trialsDotSizeNoiseMean', 'trialsDotSizeClearMean', 'trialsDotSizeClearVariance', 'trialsDotSizeNoiseVariance',...
    'experimentList', 'nExperiment', 'meanNoise', 'meanNoiseCount', 'nCompareMean', 'compareMeanList', 'varList',...
    'nVar', 'numTrials','wedgeSize','noiseMatrix','destRect');

save(datafile_full);








