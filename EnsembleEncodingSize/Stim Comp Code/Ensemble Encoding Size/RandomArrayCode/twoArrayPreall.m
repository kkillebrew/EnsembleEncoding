

% rect(3) columns(x) and rect(4) rows(y)

clear

PPD = 33;  % For Test comps
% PPD = 40;  % For lab comps

datafile='PreallocateMean';
datafile_full=sprintf('%s_full',datafile);

totalTime=GetSecs;

dotAmount = 16;
backColor = 0;
dotColor = 128;
edgeBuffer = 100;
dotBuffer = 5;
textColor = [256, 256, 256];

% Dot size variables
stdev=.5*PPD;
meanNoise=[2 2.2 2.4 2.6 2.8];
meanNoiseCount=length(meanNoise);

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeNoise = [];
trialsXTopNoise = [];
trialsYTopNoise = [];
trialsXBotNoise = [];
trialsYBotNoise = [];

filterList=[0 .7 .8 1];    % How opaque the filter is
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


% Preallocating the dotsize and correcting the mean and stddev for the
% randm for the clear condition
for h=1:meanNoiseCount
    for i=1:numTrials
        dotSizeNoise=[];
        dotSizeNoise=randn(1,trialsDotAmount(i));
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*stdev;
        dotSizeNoise=dotSizeNoise+(meanNoise(h)*PPD);
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoise(i,j,h)=dotSizeNoise(j);
        end
    end
end
disp('Done Mean Noise Preall');

% Preall for dot size for comparison trials
for h=1:meanNoiseCount
    for p=1:nCompareMean
        for i=1:numTrials
            dotSizeCompare=[];
            dotSizeCompare=randn(1,trialsDotAmount(i));
            dotSizeCompare=dotSizeCompare-mean(dotSizeCompare);
            dotSizeCompare=dotSizeCompare/(std(dotSizeCompare));
            dotSizeCompare=dotSizeCompare*stdev;
            dotSizeCompare=dotSizeCompare+(meanNoise(h)*compareMeanList(p)*PPD);
            dotSizeCompare=round(dotSizeCompare);
            for j=1:trialsDotAmount(i)
                trialsDotSizeCompare(i,j,h,p)=dotSizeCompare(j);
            end
        end
    end
end
disp('Done Control Mean Preal');

edgeBufferX=(rect(3)-((4*((round(meanNoise(meanNoiseCount)*PPD))+10)+dotBuffer)*2))/2;
edgeBufferY=(rect(4)-((4*((round(meanNoise(meanNoiseCount)*PPD))+10)+dotBuffer)*2))/2;

if edgeBufferX < 0
    edgeBufferX=1;
end
if edgeBufferY < 0
    edgeBufferY=1;
end

resetTime=20;     % Time before the program resets the circle values

disp('start Preall noise');
% Preallocating the dot locations for numtrials by dot amount for noisy
% trials for all stdev's
for h=1:meanNoiseCount
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
        
        trialsXTopNoise(i,1,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,1,h)-edgeBufferX)-edgeBufferX);
        trialsYTopNoise(i,1,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,1,h)-edgeBufferY)-edgeBufferY);
        trialsXBotNoise(i,1,h) = trialsXTopNoise(i,1,h) + trialsDotSizeNoise(i,1,h);
        trialsYBotNoise(i,1,h) = trialsYTopNoise(i,1,h) + trialsDotSizeNoise(i,1,h);
        
        resetCheck=0;
        for j=1:trialsDotAmount(i)
            while 1
                startTime=GetSecs;
                recheck=0;
                for k=trialsXTopNoise(i,j,h):trialsXBotNoise(i,j,h)+dotBuffer
                    for l=trialsYTopNoise(i,j,h):trialsYBotNoise(i,j,h)+dotBuffer
                        if screenArray(l,k)==1
                            trialsXTopNoise(i,j,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferX)-edgeBufferX);
                            trialsYTopNoise(i,j,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferY)-edgeBufferY);
                            trialsXBotNoise(i,j,h) = trialsXTopNoise(i,j,h) + trialsDotSizeNoise(i,j,h);
                            trialsYBotNoise(i,j,h) = trialsYTopNoise(i,j,h) + trialsDotSizeNoise(i,j,h);
                            recheck=1;
                        end
                    end
                end
                if recheck == 0
                    trialsXTopNoise(i,j+1,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferX)-edgeBufferX);
                    trialsYTopNoise(i,j+1,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferY)-edgeBufferY);
                    trialsXBotNoise(i,j+1,h) = trialsXTopNoise(i,j+1,h) + trialsDotSizeNoise(i,j,h);
                    trialsYBotNoise(i,j+1,h) = trialsYTopNoise(i,j+1,h) + trialsDotSizeNoise(i,j,h);
                    break
                end
                if GetSecs-startTime>resetTime
                    resetCheck=1;
                    break
                end
            end
            if resetCheck==0
                for k=trialsXTopNoise(i,j,h):trialsXBotNoise(i,j,h)+dotBuffer
                    for l=trialsYTopNoise(i,j,h):trialsYBotNoise(i,j,h)+dotBuffer
                        screenArray(l,k) = 1;
                    end
                end
            else
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
                
                j=1;
                trialsXTopNoise(i,j,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferX)-edgeBufferX);
                trialsYTopNoise(i,j,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferY)-edgeBufferY);
                trialsXBotNoise(i,j,h) = trialsXTopNoise(i,j,h) + trialsDotSizeNoise(i,j,h);
                trialsYBotNoise(i,j,h) = trialsYTopNoise(i,j,h) + trialsDotSizeNoise(i,j,h);
            end
        end
        resetCheck=0;
        if i==(round(numTrials*.25))
            disp('25%');
        elseif i==(round(numTrials*.5))
            disp('50%');
        elseif i==(round(numTrials*.75))
            disp('75%');
        end
        
    end
    disp(h);
    disp((GetSecs-totalTime)/60);
    
end

disp('start preall compare');
% Preallocating the dot locations for numtrials by dot amount for all
% compare conditions trials for all stdev's
for h=1:meanNoiseCount
    for p=1:nCompareMean
        for i=1:300
            
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
            
            trialsXTopCompare(i,1,h,p) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeCompare(i,1,h,p)-edgeBufferX)-edgeBufferX);
            trialsYTopCompare(i,1,h,p) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeCompare(i,1,h,p)-edgeBufferY)-edgeBufferY);
            trialsXBotCompare(i,1,h,p) = trialsXTopCompare(i,1,h,p) + trialsDotSizeCompare(i,1,h,p);
            trialsYBotCompare(i,1,h,p) = trialsYTopCompare(i,1,h,p) + trialsDotSizeCompare(i,1,h,p);
            
            resetCheck=0;
            for j=1:trialsDotAmount(i)
                while 1
                    startTime=GetSecs;
                    recheck=0;
                    for k=trialsXTopCompare(i,j,h,p):trialsXBotCompare(i,j,h,p)+dotBuffer
                        for l=trialsYTopCompare(i,j,h,p):trialsYBotCompare(i,j,h,p)+dotBuffer
                            if screenArray(l,k)==1
                                trialsXTopCompare(i,j,h,p) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeCompare(i,j,h,p)-edgeBufferX)-edgeBufferX);
                                trialsYTopCompare(i,j,h,p) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeCompare(i,j,h,p)-edgeBufferY)-edgeBufferY);
                                trialsXBotCompare(i,j,h,p) = trialsXTopCompare(i,j,h,p) + trialsDotSizeCompare(i,j,h,p);
                                trialsYBotCompare(i,j,h,p) = trialsYTopCompare(i,j,h,p) + trialsDotSizeCompare(i,j,h,p);
                                recheck=1;
                            end
                        end
                    end
                    if recheck == 0
                        trialsXTopCompare(i,j+1,h,p) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeCompare(i,j,h,p)-edgeBufferX)-edgeBufferX);
                        trialsYTopCompare(i,j+1,h,p) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeCompare(i,j,h,p)-edgeBufferY)-edgeBufferY);
                        trialsXBotCompare(i,j+1,h,p) = trialsXTopCompare(i,j+1,h,p) + trialsDotSizeCompare(i,j,h,p);
                        trialsYBotCompare(i,j+1,h,p) = trialsYTopCompare(i,j+1,h,p) + trialsDotSizeCompare(i,j,h,p);
                        break
                    end
                    if GetSecs-startTime>resetTime
                        resetCheck=1;
                        break
                    end
                end
                if resetCheck==0
                    for k=trialsXTopCompare(i,j,h,p):trialsXBotCompare(i,j,h,p)+dotBuffer
                        for l=trialsYTopCompare(i,j,h,p):trialsYBotCompare(i,j,h,p)+dotBuffer
                            screenArray(l,k) = 1;
                        end
                    end
                else
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
                    
                    j=1;
                    trialsXTopCompare(i,1,h,p) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeCompare(i,1,h,p)-edgeBufferX)-edgeBufferX);
                    trialsYTopCompare(i,1,h,p) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeCompare(i,1,h,p)-edgeBufferY)-edgeBufferY);
                    trialsXBotCompare(i,1,h,p) = trialsXTopCompare(i,1,h,p) + trialsDotSizeCompare(i,1,h,p);
                    trialsYBotCompare(i,1,h,p) = trialsYTopCompare(i,1,h,p) + trialsDotSizeCompare(i,1,h,p);
                end
            end
            resetCheck=0;
            if i==(round(300*.25))
                disp('25%');
            elseif i==(round(300*.5))
                disp('50%');
            elseif i==(round(300*.75))
                disp('75%');
            end
        end
        disp(p)
        disp((GetSecs-totalTime)/60);
    end
    disp(h);
    disp((GetSecs-totalTime)/60);
    
end

disp('start filter');
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

disp((GetSecs-totalTime)/60);

save(datafile,'filterList', 'rect', 'meanNoise', 'startList', 'nStart','meanNoiseCount', 'nCompareMean', 'compareMeanList','nTrials','PPD', 'nFilter', 'iterationList', 'nIteration', 'stdev','numTrials','trialsDotAmount','trialsDotSizeNoise','trialsDotSizeCompare','trialsXTopNoise','trialsYTopNoise','trialsXBotNoise','trialsYBotNoise','trialsXTopCompare','trialsYTopCompare','trialsXBotCompare','trialsYBotCompare');

save(datafile_full);





