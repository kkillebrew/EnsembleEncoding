clear all
mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

ppd = (1024/mon_width_deg);

maxr=384;
minr=200;
jitter=10;
divisions=12;
guides=1;
linethickness=5;

wedgeang=360/(divisions*2);
circr2=(tand(wedgeang)*maxr)/(1+tand(wedgeang));

maxcircr=circr2-jitter;
mincircr=linethickness+1;

dotAmount = 12;

% Dot size variables
% With a mean of 1.1 the stdev needs to remain between .1 and .33
stdev=.1*ppd;
%with stdev of .2 min=.8     max=1.4;
meanNoise=1.1;
meanNoiseCount=length(meanNoise);

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeNoise = [];
largestMax = 0;
smallestMin = 10000;

numTrials=1000;

for i=1:numTrials
    dotSizeNoise=[];
    dotSizeNoise=randn(1,dotAmount);
    dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
    dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
    dotSizeNoise=dotSizeNoise*stdev;
    dotSizeNoise=dotSizeNoise+(meanNoise*ppd);
    dotSizeNoise=round(dotSizeNoise);
    for j=1:dotAmount
        trialsDotSizeNoise(i,j)=dotSizeNoise(j);
        
        if largestMax < trialsDotSizeNoise(i)
            largestMax = trialsDotSizeNoise(i);
        end
        
        if trialsDotSizeNoise(i) < smallestMin
            smallestMin = trialsDotSizeNoise(i);
        end
    end
end



maxviolations=sum(trialsDotSizeNoise(:)>maxcircr);
minviolations=sum(trialsDotSizeNoise(:)<mincircr);
disp(maxviolations);
disp(minviolations);
