

% rect(3) columns(x) and rect(4) rows(y)

clear

PPD = 33;  % For Test comps
% PPD = 40;  % For lab comps

datafile='PreallocateMean';
datafile_full=sprintf('%s_full',datafile);

dotAmount = 16;
backColor = 0;
dotColor = 128;
edgeBuffer = 100;
dotBuffer = 5;
textColor = [256, 256, 256];

% Dot size variables
stdev=.2*PPD;
meanNoise=[0.8 0.95 1.1 1.25 1.4];
meanNoiseCount=length(meanNoise);

% Preallocation variables/arrays
trialsDotAmount = [];
trialsDotSizeNoise = [];
trialsXTopNoise = [];
trialsYTopNoise = [];
trialsXBotNoise = [];
trialsYBotNoise = [];

filterList=[0 .2 .4 .6 .8 1];    % How opaque the filter is
nFilter=length(filterList);
iterationList=[1 2 3]; % Which number staircase you are on
startList=[1 2];
nStart=length(startList);
nIteration=length(iterationList);
compareMeanList=[.5 .6 .7 .8 .9 1 1.1 1.2 1.3 1.4 1.5];
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
        dotSizeNoise=dotSizeNoise+(meanNoise(h)*PPD);
        dotSizeNoise=round(dotSizeNoise);
        for j=1:trialsDotAmount(i)
            trialsDotSizeNoise(i,j,h)=dotSizeNoise(j);
        end
    end
end

% edgeBufferX=(rect(3)-((4*((round(meanNoise(meanNoiseCount)*PPD))+10)+dotBuffer)*2))/2;
% edgeBufferY=(rect(4)-((4*((round(meanNoise(meanNoiseCount)*PPD))+10)+dotBuffer)*2))/2;
% 
% if edgeBufferX < 0
%     edgeBufferX=1;
% end
% if edgeBufferY < 0
%     edgeBufferY=1;
% end

% Preallocating the dot locations for numtrials by dot amount for noisy
% trials for all stdev's
% for h=1:meanNoiseCount
%     for i=1:numTrials
%         
%         screenArray = zeros(rect(4),rect(3));    % creates an array of zeroes that represents the pixels on the screen
%         
%         % sets the edge values in the screenArray to 1
%         for k=1:rect(4)
%             for l=1:edgeBufferX
%                 screenArray(k,l) = 1;
%             end
%         end
%         
%         for k=1:rect(4)
%             for l=(rect(3)-edgeBufferX):rect(3)
%                 screenArray(k,l) = 1;
%             end
%         end
%         
%         for k=1:edgeBufferY
%             for l=1:rect(3)
%                 screenArray(k,l) = 1;
%             end
%         end
%         
%         for k=rect(4)-edgeBufferY:rect(4)
%             for l=1:rect(3)
%                 screenArray(k,l) = 1;
%             end
%         end
%         
%         for k=(x0-20):(x0+20)
%             for l=(y0-20):(y0+20)
%                 screenArray(l,k) = 1;
%             end
%         end
%         
%         trialsXTopNoise(i,1,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,1,h)-edgeBufferX)-edgeBufferX);
%         trialsYTopNoise(i,1,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,1,h)-edgeBufferY)-edgeBufferY);
%         trialsXBotNoise(i,1,h) = trialsXTopNoise(i,1,h) + trialsDotSizeNoise(i,1,h);
%         trialsYBotNoise(i,1,h) = trialsYTopNoise(i,1,h) + trialsDotSizeNoise(i,1,h);
%         
%         for j=1:trialsDotAmount(i)
%             while 1
%                 recheck=0;
%                 for k=trialsXTopNoise(i,j,h):trialsXBotNoise(i,j,h)+dotBuffer
%                     for l=trialsYTopNoise(i,j,h):trialsYBotNoise(i,j,h)+dotBuffer
%                         if screenArray(l,k)==1
%                             trialsXTopNoise(i,j,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferX)-edgeBufferX);
%                             trialsYTopNoise(i,j,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferY)-edgeBufferY);
%                             trialsXBotNoise(i,j,h) = trialsXTopNoise(i,j,h) + trialsDotSizeNoise(i,j,h);
%                             trialsYBotNoise(i,j,h) = trialsYTopNoise(i,j,h) + trialsDotSizeNoise(i,j,h);
%                             recheck=1;
%                         end
%                     end
%                 end
%                 if recheck == 0
%                     trialsXTopNoise(i,j+1,h) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferX)-edgeBufferX);
%                     trialsYTopNoise(i,j+1,h) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-trialsDotSizeNoise(i,j,h)-edgeBufferY)-edgeBufferY);
%                     trialsXBotNoise(i,j+1,h) = trialsXTopNoise(i,j+1,h) + trialsDotSizeNoise(i,j,h);
%                     trialsYBotNoise(i,j+1,h) = trialsYTopNoise(i,j+1,h) + trialsDotSizeNoise(i,j,h);
%                     break
%                 end
%             end
%             for k=trialsXTopNoise(i,j,h):trialsXBotNoise(i,j,h)+dotBuffer
%                 for l=trialsYTopNoise(i,j,h):trialsYBotNoise(i,j,h)+dotBuffer
%                     screenArray(l,k) = 1;
%                 end
%             end
%         end
%     end
% end

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


save(datafile,'filterList', 'rect', 'meanNoise', 'startList', 'nStart','meanNoiseCount', 'nCompareMean', 'compareMeanList','nTrials','PPD', 'nFilter', 'iterationList', 'nIteration', 'stdev','numTrials','trialsDotAmount','trialsDotSizeNoise','noiseMatrix','destRect','wedgeSize','dotAmount');

save(datafile_full);





