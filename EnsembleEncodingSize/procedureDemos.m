
clear

load('noiseFilter');
ListenChar(2);
% PPD = 33;  % For Test comps
PPD = 40;  % For lab comps

dotAmount = 15;
backColor = 0;
dotColor = 128;
dotBuffer = 5;
textColor = [256, 256, 256];

% rect=[0 0 1024 768];     % test comps
rect=[0 0 2560 1440];
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

% Dot size variables
ave=3.5*PPD;
stdevClear=.5*PPD;
stdevNoise=.5*PPD;

% Preallocation variables/arrays
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

% Preallocating the dotsize and correcting the mean and stddev for the
% randm for the clear condition
dotSizeClear=[];
dotSizeClear=randn(1,16);
dotSizeClear=dotSizeClear-mean(dotSizeClear);
dotSizeClear=dotSizeClear/(std(dotSizeClear));
dotSizeClear=dotSizeClear*stdevClear;
dotSizeClear=dotSizeClear+ave;
dotSizeClear=round(dotSizeClear);

% Preallocating the dotsize and correcting the mean and stddev for the
% randm for the clear condition

dotSizeNoise=[];
dotSizeNoise=randn(1,16);
dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
dotSizeNoise=dotSizeNoise*stdevNoise;
dotSizeNoise=dotSizeNoise+ave;
dotSizeNoise=round(dotSizeNoise);

edgeBufferX=(rect(3)-((4*(4*PPD)+10)+dotBuffer)*2)/2;
edgeBufferY=(rect(4)-((4*(4*PPD)+10)+dotBuffer)*2)/2;

% Preallocating the dot locations for numtrials by dot amount for clear
% trials
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
trialsXTopClear(1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeClear(1)-edgeBufferX)-edgeBufferX);
trialsYTopClear(1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeClear(1)-edgeBufferY)-edgeBufferY);
trialsXBotClear(1) = trialsXTopClear(1) + dotSizeClear(1);
trialsYBotClear(1) = trialsYTopClear(1) + dotSizeClear(1);

for j=1:16
    while 1
        recheck=0;
        for k=trialsXTopClear(j):trialsXBotClear(j)+dotBuffer
            for l=trialsYTopClear(j):trialsYBotClear(j)+dotBuffer
                if screenArray(l,k)==1
                    trialsXTopClear(j) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeClear(j)-edgeBufferX)-edgeBufferX);
                    trialsYTopClear(j) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeClear(j)-edgeBufferY)-edgeBufferY);
                    trialsXBotClear(j) = trialsXTopClear(j) + dotSizeClear(j);
                    trialsYBotClear(j) = trialsYTopClear(j) + dotSizeClear(j);
                    recheck=1;
                end
            end
        end
        if recheck == 0
            trialsXTopClear(j+1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeClear(j)-edgeBufferX)-edgeBufferX);
            trialsYTopClear(j+1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeClear(j)-edgeBufferY)-edgeBufferY);
            trialsXBotClear(j+1) = trialsXTopClear(j+1) + dotSizeClear(j);
            trialsYBotClear(j+1) = trialsYTopClear(j+1) + dotSizeClear(j);
            break
        end
    end
    for k=trialsXTopClear(j):trialsXBotClear(j)+dotBuffer
        for l=trialsYTopClear(j):trialsYBotClear(j)+dotBuffer
            screenArray(l,k) = 1;
        end
    end
end

% Preallocating the dot locations for numtrials by dot amount for noisy
% trials for all stdev'

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

trialsXTopNoise(1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeNoise(1)-edgeBufferX)-edgeBufferX);
trialsYTopNoise(1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeNoise(1)-edgeBufferY)-edgeBufferY);
trialsXBotNoise(1) = trialsXTopNoise(1) + dotSizeNoise(1);
trialsYBotNoise(1) = trialsYTopNoise(1) + dotSizeNoise(1);

for j=1:16
    while 1
        recheck=0;
        for k=trialsXTopNoise(j):trialsXBotNoise(j)+dotBuffer
            for l=trialsYTopNoise(j):trialsYBotNoise(j)+dotBuffer
                if screenArray(l,k)==1
                    trialsXTopNoise(j) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeNoise(j)-edgeBufferX)-edgeBufferX);
                    trialsYTopNoise(j) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeNoise(j)-edgeBufferY)-edgeBufferY);
                    trialsXBotNoise(j) = trialsXTopNoise(j) + dotSizeNoise(j);
                    trialsYBotNoise(j) = trialsYTopNoise(j) + dotSizeNoise(j);
                    recheck=1;
                end
            end
        end
        if recheck == 0
            trialsXTopNoise(j+1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeNoise(j)-edgeBufferX)-edgeBufferX);
            trialsYTopNoise(j+1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeNoise(j)-edgeBufferY)-edgeBufferY);
            trialsXBotNoise(j+1) = trialsXTopNoise(j+1) + dotSizeNoise(j);
            trialsYBotNoise(j+1) = trialsYTopNoise(j+1) + dotSizeNoise(j);
            break
        end
    end
    for k=trialsXTopNoise(j):trialsXBotNoise(j)+dotBuffer
        for l=trialsYTopNoise(j):trialsYBotNoise(j)+dotBuffer
            screenArray(l,k) = 1;
        end
    end
end

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

noise=Screen('MakeTexture',w,noiseMatrix);

HideCursor;

demo=1;
delayTime=.5;
stimTime=.5;

dotStep=1.5*PPD;
imArrayCount=1;
imageArray=[];
alphaVal=.7;    % Sets the alpha value to be changed over each iteration
if demo==1
    for i=1:round(60*delayTime)
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    
    for l=1:round(60*stimTime)
        for i=1:16
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(i), trialsYTopNoise(i), trialsXBotNoise(i), trialsYBotNoise(i)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],(alphaVal));
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    
    for k=1:round(60*delayTime)
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);
        imArrayCount=imArrayCount+1;
    end
    
    for p=1:round(60*delayTime)
        Screen('FrameOval',w,[dotColor dotColor dotColor],[(x0-(ave/2)-200) (y0-(ave/2)) (x0+(mean(ave/2))-200) (y0+(ave/2))],(5));
        Screen('FrameOval',w,[dotColor dotColor dotColor],[(x0-((ave+dotStep)/2)+200) (y0-((ave+dotStep)/2)) (x0+((ave+dotStep)/2)+200) (y0+(ave+dotStep)/2)],(5));
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);
        imArrayCount=imArrayCount+1;
    end
else
    for i=1:round(60*delayTime)
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    
    for l=1:round(60*stimTime)
        for i=1:16
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(i), trialsYTopNoise(i), trialsXBotNoise(i), trialsYBotNoise(i)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],(alphaVal));
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    for i=1:round(60*delayTime)
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    for l=1:round(60*stimTime)
        for i=1:16
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopClear(i), trialsYTopClear(i), trialsXBotClear(i), trialsYBotClear(i)],(5));
        end
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    for p=1:round(60*delayTime)
        Screen('TextSize',w,24);
        text='Which set of circles had the greatest difference in size?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
        Screen('TextSize',w,24);
        text='Press A for the first option or k for the second';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
end

ListenChar(0);
Screen('Close',w);
ShowCursor;

vidObj = VideoWriter('meanLowF7'); %#ok .
vidObj.FrameRate = 60;

open(vidObj);

for i=1:length(imageArray)
    imshow(imageArray(i).image);
    axis off;
    currFrame = getframe;  % grabs current figure as a video frame
    writeVideo(vidObj,currFrame);  % writes the current frame to vidObj
end

close(vidObj);


