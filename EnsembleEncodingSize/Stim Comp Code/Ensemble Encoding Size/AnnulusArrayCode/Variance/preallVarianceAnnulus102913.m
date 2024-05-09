
% Variance Preallocation

clear all

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

PPD = (1024/mon_width_deg);

datafile='PreallocateVariance';
datafile_full=sprintf('%s_full',datafile);

% rect=[0 0 2560 1440];     % screen dimension for lab comps
rect=[0 0 1024 768];     % test comps
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

dotAmount = 12;
backColor = 0;
dotColor = 128;

% Dot size variables
ave=1.1*PPD;
stdevClear=.2*PPD;

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeClear = [];
trialsDotSizeNoise = [];

filterList=[0 .2 .4 .6 .8];    % How opaque the filter is
nFilter=length(filterList);
iterationList=[1 2 3];           % Which number staircase you are on
nIteration=length(iterationList);
startList=[1 2];               % Which starting postion staircase being used
nStart=length(startList);
varList=[.1 .12 .14 .16 .18 .2 .22 .24 .26 .28 .3];   % List of different variablities; chooses which set of dots to use
nVar=length(varList);
nTrials=30;                             % Number of trials per staircase

numTrials=nFilter*nIteration*nStart*nTrials;

% Preallocating the dot amount
for i=1:numTrials;
    trialsDotAmount(i)=dotAmount;
end

wedgeSize = 360/(dotAmount*2);

% Preallocating the dotsize and correcting the mean and stddev for the
% randm for the clear condition
for i=1:numTrials
    dotSizeClear=[];
    dotSizeClear=randn(1,trialsDotAmount(i));
    dotSizeClear=dotSizeClear-mean(dotSizeClear);
    dotSizeClear=dotSizeClear/(std(dotSizeClear));
    dotSizeClear=dotSizeClear*stdevClear;
    dotSizeClear=dotSizeClear+ave;
    dotSizeClear=round(dotSizeClear);
    for j=1:trialsDotAmount(i)
        trialsDotSizeClear(i,j)=dotSizeClear(j);
    end
end

% Preallocating the dotsize and correcting the mean and stddev for the
% randm for the noisy condition
for h=1:nVar
    for i=1:numTrials
        dotSizeNoise=[];
        dotSizeNoise=randn(1,trialsDotAmount(i));
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*varList(h)*PPD;
        dotSizeNoise=dotSizeNoise+ave;
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoise(i,j,h)=dotSizeNoise(j);
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


save(datafile,'wedgeSize','filterList', 'nTrials', 'rect', 'nFilter', 'iterationList', 'nIteration', 'startList', 'nStart', 'varList', 'nVar','ave','numTrials','trialsDotAmount','trialsDotSizeClear','trialsDotSizeNoise','trialsXTopClear','trialsYTopClear','trialsXBotClear','trialsYBotClear','trialsXTopNoise','trialsYTopNoise','trialsXBotNoise','trialsYBotNoise','noiseMatrix','destRect');

save('datafile_full');





