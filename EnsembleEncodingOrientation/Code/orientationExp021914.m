 % rawdata(n,1) = filter
% rawdata(n,2) = iteration
% rawdata(n,3) = start
% rawdata(n,4) = step value
% rawdata(n,5) = filter order 
% rawdata(n,6) = random mean value
% rawdata(n,7) = which was more variable/rightward
% rawdata(n,8) = reversal
% rawdata(n,9) = experiment number

clear all;
close all;

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'orientation';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
% datadir = '/Users/C-Lab/Google Drive/Lab Projects/EnsembleEncodingOrientation/Data/';
datadir = '/Volumes/C-Lab/Google Drive/Lab Projects/Data/';

datafile=sprintf('%s_%s_%s_%03d',subjid,experiment,datecode,runid);
datafile_full=sprintf('%s_full',datafile);

% check to see if this file exists
if exist(fullfile(datadir,[datafile '.mat']),'file')
    tmpfile = input('File exists.  Overwrite? y/n:','s');
    while ~ismember(tmpfile,{'n' 'y'})
        tmpfile = input('Invalid choice. File exists.  Overwrite? y/n:','s');
    end
    if strcmp(tmpfile,'n')
        display('Bye-bye...');
        return; % will need to start over for new input
    end
end

load('PreallocateNoise');
load('PreallocateOrientation');
load('PreallocateOrientationStim');

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (1024/mon_width_deg);

ListenChar(2);
HideCursor;

backColor = 128;
dotColor = 128;
textColor = [256, 256, 256];

dotSize = 100;
freq = 2;

totalTime=GetSecs;

rawdata=[];

count = 1;
countV = 1;
countM = 1;
block = 10;

for h=1:nExperiment
    for i=1:nFilter
        for j=1:nIteration
            for k=1:nStart
                if k==2   % The second choice was more variable
                    stepCount(h,i,j,k)=nMeanStair;     % Sets the value of stepCount at the greatest var until they choose another val
                    prevAns(h,i,j,k)=1;     % States that the test was more variable
                else
                    stepCount(h,i,j,k)=1;
                    prevAns(h,i,j,k)=2;      % Ref was more variable
                end
                placeList(h,i,j,k)=1;             % If you had a reversal add one to place list
            end
        end
    end
end

variableListVariance = repmat(fullyfact([nFilter nIteration nStart]),[nTrials,1]);
trialOrderVariance=randperm(length(variableListVariance));
variableListMean = repmat(fullyfact([nFilter nIteration nStart]),[nTrials,1]);
trialOrderMean=randperm(length(variableListMean));

x=1;
% Randomly assigns the blocks while ensuring same number of each block
for t=1:numTrials/(nExperiment*block)
    choice = randi(2);
    if choice==1
        blockOrder(x)=1;
        x=x+1;
        blockOrder(x)=2;
    else
        blockOrder(x)=2;
        x=x+1;
        blockOrder(x)=1;
    end
    x=x+1;
end

% Specifies the total trialOrder made from the individual trial order lists
trialOrder = [];
for z=1:length(blockOrder)
    if blockOrder(z)==1
        for i=1:block
            trialOrder(count,1)=trialOrderVariance(countV);
            trialOrder(count,2)=1;
            count=count+1;
            countV=countV+1;
        end
    else
        for i=1:block
            trialOrder(count,1)=trialOrderMean(countM);
            trialOrder(count,2)=2;
            count=count+1;
            countM=countM+1;
        end
    end
end

rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 1,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

jitter = 10;
elongateRadius = 10;

% break_trials = .25:.25:.75; % list of proportion of total trials at which to offer subject a self-timed break
break_trials = .1:.1:.9;    % list of proportion of total trials at which to offer subject a self-timed break

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

buttonLeft=KbName('LeftShift');
buttonRight=KbName('RightShift');

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

% Making the textures for noise and stimulus
noise=Screen('MakeTexture',w,noiseMatrix);
for i=1:nCircles
    gabor(i) = Screen('MakeTexture',w,scaledtexture{i});
    shift(i) = randi(360);
end

Screen('TextSize',w,20);
text='Please choose the set of objects that is the most rightward/clockwise or is most variable.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
Screen('TextSize',w,20);
text='If the preceding screen has a red outline choose the set that is most clockwise.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('TextSize',w,20);
text='If the preceding screen has a green outline choose the set with the largest difference in orientation.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
Screen('TextSize',w,20);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

%% Starting Experiment
for n=1:numTrials
    if trialOrder(n,2) == 1             % For variance experiments the ref is noisy (aka staircase or set that is changing)
        %% Variance Experiment sets variables for variance
        varValIdx=randi(nVarianceOrient);
        varVal=varianceOrientationList(varValIdx);
        
        nFilterOrder=randi(2);    % For 1 draw clear first 2 draw filter first
        
        % Choosing and storing values of the different variables into the
        % arrays
        filterIdx=variableListVariance(trialOrder(n,1),1);
        alphaVal=filterList(filterIdx);
        rawdata(n,1)=alphaVal;
        iterationIdx=variableListVariance(trialOrder(n,1),2);
        iterationVal=iterationList(iterationIdx);
        rawdata(n,2)=iterationVal;
        startIdx=variableListVariance(trialOrder(n,1),3);
        startVal=startList(startIdx);
        rawdata(n,3)=startVal;
        varStairIdx=stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx);    % stepCount list for variance
        varStairVal=varianceStaircaseList(varStairIdx);
        rawdata(n,4)=varStairVal;
        rawdata(n,5)=nFilterOrder;   % 1 means test fisrt
        rawdata(n,6)=varVal;    % Randomly chooses the mean value
        rawdata(n,9)=trialOrder(n,2);
        %% Variance filter comes first (or staircase)
        if nFilterOrder == 1    % Test first
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='Variance Trial';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(1);
            
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(.5);
            
            % HERE IS THE ANNULUS PART OF THE CODE
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVarianceStair(n,i+.5,varValIdx,varStairIdx));
                    end
                end
                Screen('DrawTexture',w,noise,[],destRectNoise,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
            end
            
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles

                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVariance(n,i+.5,varValIdx));
                    end
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
            end
        else                   % Ref first
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='Variance Trial';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(1);
            
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    % Jitter for orientation location
                    xJitter = (randi((jitter*2)+1)-jitter+1);
                    yJitter = (randi((jitter*2)+1)-jitter+1);
                    
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVariance(n,i+.5,varValIdx));
                    end
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
            end
            
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVarianceStair(n,i+.5,varValIdx,varStairIdx));
                    end
                end
                Screen('DrawTexture',w,noise,[],destRectNoise,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
            end
        end
        Screen('TextSize',w,24);
        text='Press Left Shift for the first option or Right Shift for the second';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
        Screen('TextSize',w,24);
        text='Which set of objects had the greatest variablity in orientation?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        
    else     % For mean experiments the test is noisy (aka the the set that doesnt change based on response)
        %%    Mean Experiment - Sets variables for the mean
        
        meanValIdx=randi(nMeanOrient);    % randomly chooses value to select which array to choose from depending on mean
        meanVal=meanOrientationList(meanValIdx);
        
        nFilterOrder=randi(2);    % For 1 ref first
        
        % Choosing and storing values of the different variables into the
        % arrays
        filterIdx=variableListMean(trialOrder(n,1),1);
        alphaVal=filterList(filterIdx);
        rawdata(n,1)=alphaVal;
        iterationIdx=variableListMean(trialOrder(n,1),2);
        iterationVal=iterationList(iterationIdx);
        rawdata(n,2)=iterationVal;
        startIdx=variableListMean(trialOrder(n,1),3);
        startVal=startList(startIdx);
        rawdata(n,3)=startVal;
        meanStairIdx=stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx);    % stepCount list for mean
        meanStairVal=meanStaircaseList(meanStairIdx);
        rawdata(n,4)=meanStairVal;
        rawdata(n,5)=nFilterOrder;   % 1 means test fisrt
        rawdata(n,6)=meanVal;
        rawdata(n,9)=trialOrder(n,2);
        
        %% Filter comes fist = 1 second = 2 on nFilterOrder (Always on non-changing set)
        
        if nFilterOrder==2                % ref comes first
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[256 0 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='Mean Trial';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(1);
            
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMean(n,i+.5,meanValIdx));
                    end
                end
                Screen('DrawTexture',w,noise,[],destRectNoise,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
            end
            
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMeanStair(n,i+.5,meanValIdx,meanStairIdx));
                    end
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
            end
        else                         % test first
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[256 0 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='Mean Trial';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(1);
            
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMeanStair(n,i+.5,meanValIdx,meanStairIdx));
                    end
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
            end
            
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for m=1:nCircles
                    
                    [keyIsDown, secs, keycode] = KbCheck;
                    for i=.5:trialsDotAmount(n,m)-.5
                        radius(m)=imSize(m)/2;
                        destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                            ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)))),...
                            ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmount(n,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMean(n,i+.5,meanValIdx));
                    end
                end
                Screen('DrawTexture',w,noise,[],destRectNoise,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
            end
        end
        Screen('TextSize',w,24);
        text='Press Left Shift for the first option or Right Shift for the second';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
        Screen('TextSize',w,24);
        text='Which set of objects was oreinted more clockwise (rightward)?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
    end
    %%  Storing data in arrays
    % If the test was more rightward/more variable rawdata(n,7) = 1
    % If the compare was more rightward/more variable rawdata(n,7) = 2
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if rawdata(n,5)==1;   % Test came first
            if keycode(buttonLeft)
                rawdata(n,7)=1;   % Test more variable/clockwise
                break
            end
            if keycode(buttonRight)
                rawdata(n,7)=2;   % compare more variable/clockwise
                break
            end
        else    % clear came first
            if keycode(buttonLeft)
                rawdata(n,7)=2;   % compare more variable/clockwise
                break
            end
            if keycode(buttonRight)
                rawdata(n,7)=1;   % test more variable/clockwise
                break
            end
        end
    end
    KbWait(dev_ID);
    KbReleaseWait(dev_ID);
    
    
    if rawdata(n,7)==1    % choose that test was more variable/clockwise
        if prevAns(trialOrder(n,2),filterIdx,iterationIdx,startIdx)==2   % States that on the last trial, compare had greater variablity
            reversalList(trialOrder(n,2),filterIdx,iterationIdx,startIdx,placeList(trialOrder(n,2),filterIdx,iterationIdx,startIdx))=1;
            placeList(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=placeList(trialOrder(n,2),filterIdx,iterationIdx,startIdx)+1;
            rawdata(n,8)=1;
        else   % the last value reft was more variable
            rawdata(n,8)=0;
        end
        prevAns(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=1;
        % decreases step count (unless it becomes greater than sets to
        % varList/comparemeanlist max)
        stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=max(stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx)-1,1);
    else   %  choose that compare was more variable
        if prevAns(trialOrder(n,2),filterIdx,iterationIdx,startIdx)==2   % States that on the last trial, compare had greater variablity
            rawdata(n,8)=0;
        else   % the last value test was more variable
            reversalList(trialOrder(n,2),filterIdx,iterationIdx,startIdx,placeList(trialOrder(n,2),filterIdx,iterationIdx,startIdx))=1;
            placeList(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=placeList(trialOrder(n,2),filterIdx,iterationIdx,startIdx)+1;
            rawdata(n,8)=1;
        end
        prevAns(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=2;
        % increases step count (unless it becomes greater than sets to
        % varList/comparemeanlist max)
        stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=min(stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx)+1,length(meanStaircaseList));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % give subject break at certain trials...
    this_b = 0;
    for b = break_trials
        if n==round(b*length(trialOrder))
            this_b = b;
            break
        end
    end
    
    if this_b
        % display break message
        text=sprintf('You have completed %d%% of the trials.',round(b*100));
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0,textColor);
        text='Press any key when you are ready to continue.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0+50,textColor);
        Screen('Flip',w);
        disp(this_b);
        disp((GetSecs-totalTime)/60);
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        KbReleaseWait(dev_ID);
        while 1
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            if keyIsDown
                break
            end
        end
    end
end

save(datafile,'rawdata','reversalList');
save(datafile_full);

ListenChar(0);
Screen('CloseAll');
ShowCursor;





