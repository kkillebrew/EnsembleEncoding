
clear

% PPD = 33;  % For Test comps
PPD = 40;  % For lab comps

rect=[0 0 2560 1440];     % screen dimension for lab comps
% rect=[0 0 1024 768];     % test comps
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

dotAmount = 15;
backColor = 0;
dotColor = 128;
dotBuffer = 20;
textColor = [256, 256, 256];

% Dot size variables
ave=2.5*PPD;
stdevClear=.5*PPD;
stdevNoise=[.9 1];
stdevNoiseCount=length(stdevNoise);

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeClear = [];
trialsDotSizeNoise = [];
trialsXTopClear = [];
trialsYTopClear = [];
trialsXBotClear = [];
trialsYBotClear = [];
trialsXTopNoise = [];
trialsYTopNoise = [];
trialsXBotNoise = [];
trialsYBotNoise = [];

filterList=[.2 .4 .6 .8];    % How opaque the filter is
nFilter=length(filterList);
iterationList=[1 2];           % Which number staircase you are on
nIteration=length(iterationList);
startList=[1 2];               % Which starting postion staircase being used
nStart=length(startList);
varList=[1 2];   % List of different variablities; chooses which set of dots to use
nVar=length(varList);
nTrials=5;                             % Number of trials per staircase

numTrials=nFilter*nIteration*nStart*nTrials;


% Preallocating the dot amount
for i=1:numTrials;
    trialsDotAmount(i)=dotAmount;
end

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
% randm for the clear condition
for h=1:stdevNoiseCount
    for i=1:numTrials
        dotSizeNoise=[];
        dotSizeNoise=randn(1,trialsDotAmount(i));
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*stdevNoise(h)*PPD;
        dotSizeNoise=dotSizeNoise+ave;
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoise(i,j,h)=dotSizeNoise(j);
        end
    end
end

edgeBufferX=(rect(3)-((4*(max(dotSizeNoise))+dotBuffer)*2))/2;
edgeBufferY=(rect(4)-((4*(max(dotSizeNoise))+dotBuffer)*2))/2;

% Preallocating the dot locations for numtrials by dot amount for clear
% trials
for i=1:numTrials
    
    screenArray = zeros(rect(4),rect(3));    % creates an array of zeroes that represents the pixels on the screen
    
    % sets the edge values in the screenArray to 1
    for k=1:rect(4)
        for l=1:edgeBufferX
            screenArray(k,l) = 1;
        end
    end
    
    for k=1:rect(4)
        for l=(rect(3)-edgeBufferX):rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=1:edgeBufferY
        for l=1:rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=rect(4)-edgeBufferY:rect(4)
        for l=1:rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=(x0-20):(x0+20)
        for l=(y0-20):(y0+20)
            screenArray(l,k) = 1;
        end
    end
    
    trialsXTopClear(i,1) = edgeBufferX+randi((rect(3)-dotBuffer-trialsDotSizeClear(i,1)-edgeBufferX)-edgeBufferX);
    trialsYTopClear(i,1) = edgeBufferY+randi((rect(4)-dotBuffer-trialsDotSizeClear(i,1)-edgeBufferY)-edgeBufferY);
    trialsXBotClear(i,1) = trialsXTopClear(i,1) + trialsDotSizeClear(i,1);
    trialsYBotClear(i,1) = trialsYTopClear(i,1) + trialsDotSizeClear(i,1);
    
    for j=1:trialsDotAmount(i)
        while 1
            recheck=0;
            for k=trialsXTopClear(i,j):trialsXBotClear(i,j)+dotBuffer
                for l=trialsYTopClear(i,j):trialsYBotClear(i,j)+dotBuffer
                    if screenArray(l,k)==1
                        trialsXTopClear(i,j) = edgeBufferX+randi((rect(3)-dotBuffer-trialsDotSizeClear(i,j)-edgeBufferX)-edgeBufferX);
                        trialsYTopClear(i,j) = edgeBufferY+randi((rect(4)-dotBuffer-trialsDotSizeClear(i,j)-edgeBufferY)-edgeBufferY);
                        trialsXBotClear(i,j) = trialsXTopClear(i,j) + trialsDotSizeClear(i,j);
                        trialsYBotClear(i,j) = trialsYTopClear(i,j) + trialsDotSizeClear(i,j);
                        recheck=1;
                    end
                end
            end
            if recheck == 0
                trialsXTopClear(i,j+1) = edgeBufferX+randi((rect(3)-dotBuffer-trialsDotSizeClear(i,j)-edgeBufferX)-edgeBufferX);
                trialsYTopClear(i,j+1) = edgeBufferY+randi((rect(4)-dotBuffer-trialsDotSizeClear(i,j)-edgeBufferY)-edgeBufferY);
                trialsXBotClear(i,j+1) = trialsXTopClear(i,j+1) + trialsDotSizeClear(i,j);
                trialsYBotClear(i,j+1) = trialsYTopClear(i,j+1) + trialsDotSizeClear(i,j);
                break
            end
        end
        for k=trialsXTopClear(i,j):trialsXBotClear(i,j)+dotBuffer
            for l=trialsYTopClear(i,j):trialsYBotClear(i,j)+dotBuffer
                screenArray(l,k) = 1;
            end
        end
    end
end