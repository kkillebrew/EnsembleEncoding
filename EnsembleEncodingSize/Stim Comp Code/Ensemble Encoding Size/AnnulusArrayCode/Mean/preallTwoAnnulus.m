

% rect(3) columns(x) and rect(4) rows(y)
% Mean Preallocation

clear

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

PPD = (1024/mon_width_deg);

datafile='PreallocateMeanTwoAnnulus';
datafile_full=sprintf('%s_full',datafile);

dotAmount = 12;
backColor = 0;
dotColor = 128;

% Dot size variables
stdev=.2*PPD;
meanNoiseTest=1*PPD;
meanNoise=[0.8 0.9 1 1.1 1.2];
meanNoiseCount=length(meanNoise);

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeNoise = [];

filterList=[0 .2 .4 .6 .8];    % How opaque the filter is
nFilter=length(filterList);
iterationList=[1 2 3]; % Which number staircase you are on
startList=[1 2];
nStart=length(startList);
nIteration=length(iterationList);
compareMeanList=[.75 .8 .85 .9 .95 1 1.05 1.1 1.15 1.2 1.25];
nCompareMean=length(compareMeanList);
nTrials=30;                             % Number of trials per staircase

numTrials=nFilter*nIteration*nStart*nTrials;

% rect=[0 0 2560 1440];     % screen dimension for lab comps
rect=[0 0 1024 768];     % test comps
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

% Preallocating the dot amount
for i=1:numTrials;
    trialsDotAmount(i)=dotAmount;
end

wedgeSize = 360/(dotAmount*2);

% Preallocating the dotsize and correcting the mean and stddev for the
% randm for the clear condition
for h=1:meanNoiseCount
    for i=1:numTrials
        dotSizeNoise=[];
        dotSizeNoise=randn(1,trialsDotAmount(i));
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*stdev;
        dotSizeNoise=dotSizeNoise+(meanNoiseTest);
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoise(i,j,h)=dotSizeNoise(j);
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
            dotSizeNoise=dotSizeNoise*stdev;
            dotSizeNoise=dotSizeNoise+((meanNoise(h)*PPD)*compareMeanList(k));
            dotSizeNoise=round(dotSizeNoise);
            for j=1:trialsDotAmount(i)
                trialsDotSizeClear(i,j,h,k)=dotSizeNoise(j);
            end
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


save(datafile,'filterList', 'rect', 'meanNoise', 'startList', 'nStart','meanNoiseCount', 'nCompareMean', 'compareMeanList',...
    'nTrials','PPD', 'nFilter', 'iterationList', 'nIteration', 'stdev','numTrials','trialsDotAmount','trialsDotSizeNoise',...
    'noiseMatrix','destRect','wedgeSize','dotAmount','trialsDotSizeClear');

save(datafile_full);





