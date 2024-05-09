
% rawdata(n,1) = filter
% rawdata(n,2) = iteration
% rawdata(n,3) = start
% rawdata(n,4) = step value
% rawdata(n,5) = filter order
% rawdata(n,6) = random mean value
% rawdata(n,7) = which was more variable/larger
% rawdata(n,8) = reversal
% rawdata(n,9) = experiment number

%Initially stepcount(which determines what staircase value to use
%across different conditions of noise, which staircase you are on, and
%which experiment you are on) is determined to be max or min value
%depending on start value (assuming two start locations there will be 2
%of every condition: noise, iteration, and experiment). Then the arrays
%are made determing all possible trials over noise and iteration and
%experiment for the two starting locations. These are randomly
%distributed using randperm and trialOrder is made. So far we have the
%stepCount and related arrays, variable list, and trialOrder. On the
%first iteration of the experiment depending on the trialOrder, the
%filter, iteration and experiment are randomly selected and the step
%value is choose depending on the values of filter, iteration, start
%and experiment. Then depending on the answer given the value of
%stepCount changes for that specific trial (determined by start,
%iteration, filter and experiment), either going up or down (usually
%during the first few steps of each trial it either goes down if max
%start position or up if min start position depending on if the start
%positions are different enought from PSE). So the value of the
%staircase can be determined by nTrials which will lead to a good PSE
%(usually around 25). So as the experiment progresses your step index
%value will go up or down independently for each trial condition
%(amount of individual trial conditions is determined by
%start*iteration*filter*experiment and length of the staircase plots is
%determined by nTrials) and you will have individuas staircases for
%each iteration, filter, start and experiment.

close all;
clear all;

datafile=input('Enter Subject Code:','s');
datafile_full=sprintf('%s_full',datafile);

load('PreallocateBlock');
ListenChar(2);
HideCursor;

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

totalTime=GetSecs;

jitter=10;
radiusAnnulusBig=384;
radiusAnnulusSmall=200;
divisions=16;

radiusMax=(tand(wedgeSize)*radiusAnnulusBig)/(1+tand(wedgeSize));
radiusJitter=radiusMax-jitter;

eyetracking = 0;   % Set if using eye tracker

% break_trials = .25:.25:.75; % list of proportion of total trials at which to offer subject a self-timed break
break_trials = .1:.1:.9;    % list of proportion of total trials at which to offer subject a self-timed break

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

buttonA=KbName('A');
buttonK=KbName('K');

numTrials = nFilter*nIteration*nStart*nExperiment*nTrials;
rawdata=[];

count = 1;
countV = 1;
countM = 1;
block = 50;

for h=1:nExperiment
    for i=1:nFilter
        for j=1:nIteration
            for k=1:nStart
                if k==2   % The second choice was more variable
                    stepCount(h,i,j,k)=nVar;     % Sets the value of stepCount at the greatest var until they choose another val
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
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

noise=Screen('MakeTexture',w,noiseMatrix);

[keyIsDown, secs, keycode] = KbCheck(dev_ID);

if eyetracking
    r1=3;
    r2=10;
    acceptableError=1.5*PPD;
    
    ivx=iViewXInitDefaults;    % Calls a list of variables the eyetracker needs
    Screen('FillRect',w,[0 0 128]);  % Sets the background of the screen to blue for calibration
    [results]=EyeTrackerCalibrate(ivx,acceptableError,dev_ID,con_ID,w);  % Calls and executest the calibration
    
    Screen('FillRect',w,[0 0 0],rect);
end

Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
WaitSecs(.5);
Screen('TextSize',w,20);
text='Please choose the set of circles that had the largest mean or variance depending on the instructions.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
Screen('TextSize',w,20);
text='If the preceding screen has a red outline choose the set with the largest mean size.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('TextSize',w,20);
text='If the preceding screen has a green outline choose the set with the largest difference in size.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
Screen('TextSize',w,20);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

if eyetracking
    [result, ivx]=iCiewXComm('open',ivx);   % Open a connection with the eyetracker
end

for n=1:numTrials
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if trialOrder(n,2)==1 % Variance Experiment
        
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
        varIdx=stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx);    % stepCount list for variance
        varVal=varList(varIdx);
        rawdata(n,4)=varVal;
        rawdata(n,5)=nFilterOrder;   % 1 means test fisrt
        rawdata(n,6)=0;    % Randomly chooses the mean value
        rawdata(n,9)=trialOrder(n,2);
        
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        WaitSecs(.5);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if nFilterOrder==1    % Test
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='This is a Variance Trial';
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
            
            % Draw noisy set to be on screen for .5 se	
            % As the set becomes more variable and more noisy participants
            % should report it as appearing less variable
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeNoiseVariance(n,i+.5,varIdx);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
            WaitSecs(.5);
            
            % Draw comparison
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeClearVariance(n,i+.5);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        else    % Compare first
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='This is a Variance Trial';
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
            
            % Draw comparison set to be on screen for .5 sec
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeClearVariance(n,i+.5);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
            WaitSecs(.5);
            
            % Draw noisy set to be on screen for .5 sec
            % As the set becomes more variable and more noisy participants
            % should report it as appearing less variable
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeNoiseVariance(n,i+.5,varIdx);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
        end
        
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        WaitSecs(.5);
        Screen('TextSize',w,24);
        text='Press A for the first option or K for the second';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
        Screen('TextSize',w,24);
        text='Which set of circles had the greatest difference in individual variabiltiy?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    else % Mean Experiment
        
        meanValIdx=randi(meanNoiseCount);    % randomly chooses value to select which array of dots to choose from depending on mean size
        meanVal=meanNoise(meanValIdx);
        
        nFilterOrder=randi(2);    % For 1 draw clear first 2 draw filter first
        
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
        compareMeanIdx=stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx);    % stepCount list for mean
        compareMeanVal=compareMeanList(compareMeanIdx);
        rawdata(n,4)=compareMeanVal;
        rawdata(n,5)=nFilterOrder;   % 1 means test fisrt 
        rawdata(n,6)=meanVal;
        rawdata(n,9)=trialOrder(n,2);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if nFilterOrder==2         % Compare comes first
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[256 0 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='This is a Mean Trial';
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
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeNoiseMean(n,i+.5,meanValIdx);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeClearMean(n,i+.5,meanValIdx,compareMeanIdx);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        else      % Test came first
            
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            
            Screen('FrameRect',w,[256 0 0],[0 0 1024 768],5);
            Screen('TextSize',w,24);
            text='This is a Mean Trial';
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
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeClearMean(n,i+.5,meanValIdx,compareMeanIdx);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
            WaitSecs(.5);
            
            startTime=GetSecs;
            z=0;
            while GetSecs-startTime<.5
                for i=.5:trialsDotAmount(n)-.5
                    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                    radiusCircle=trialsDotSizeNoiseMean(n,i+.5,meanValIdx);
                    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                        ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
                end
                Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                WaitSecs(.5);
                
                Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                Screen('Flip',w);
                
                if eyetracking
                    
                    z=z+1;
                    
                    xpoint=x0;
                    ypoint=y0;
                    
                    [xeye_new, yeye_new]=EyeTrackerGazeCheck(ivx,xeye_cur,yeye_cur,w);  % Track eye position; returns the actual eye position into xnew and ynew
                    xeye_cur = xeye_new;
                    yeye_cur = yeye_new;
                    xdiff = xpoint-xeye_new;
                    ydiff = ypoint-yeye_new;
                    delta=sqrt((xdiff^2)+(ydiff^2));
                    
                    Pos_v_Trace(n,1,z)=xpoint;          % Record screen center
                    Pos_v_Trace(n,2,z)=ypoint;
                    Pos_v_Trace(n,3,z)=xeye_new;        % Records the actual eye position
                    Pos_v_Trace(n,4,z)=yeye_new;
                    Pos_v_Trace(n,5,z)=xdiff;           % Difference between the actual x and screen center
                    Pos_v_Trace(n,6,z)=ydiff;           % Difference between the actual y and screen center
                    Pos_v_Trace(n,7,z)=delta;           % Total differnce between center screen and eye position
                else
                    Pos_v_Trace=0;
                end
            end
            
        end
        
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        WaitSecs(.5);
        Screen('TextSize',w,24);
        text='Press A for the first option or K for the second';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
        Screen('TextSize',w,24);
        text='Which set of circles had the greatest difference in mean size?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    

    % If the test was larger/more variable rawdata(n,7) = 1 
    % If the compare was larger/more variable rawdata(n,7) = 2
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if rawdata(n,5)==1;   % Test came first
            if keycode(buttonA)
                rawdata(n,7)=1;   % Test more variable/larger
                break
            end
            if keycode(buttonK)
                rawdata(n,7)=2;   % compare more variable/larger
                break
            end
        else    % clear came first
            if keycode(buttonA)
                rawdata(n,7)=2;   % compare more variable/larger
                break
            end
            if keycode(buttonK)
                rawdata(n,7)=1;   % test more variable/larger
                break
            end
        end
    end
    KbWait(dev_ID);
    KbReleaseWait(dev_ID);
    

    if rawdata(n,7)==1    % choose that test was more variable
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
        stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx)=min(stepCount(trialOrder(n,2),filterIdx,iterationIdx,startIdx)+1,length(varList));
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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

% Make sure to type into command window if line is not reached during
% experiment
if eyetracking
    [result, ivx] = iViewXComm('close',ivx);   % stops connection with eyetracker
end

% display Thank you message
text='You have completed the experiment.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0,textColor);
text='Please let the experimenter know you are done.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0+50,textColor);
Screen('Flip',w);
disp(this_b);
disp((GetSecs-totalTime)/60);
[keyIsDown, secs, keycode] = KbCheck(dev_ID);
KbReleaseWait(dev_ID);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

save(datafile,'rawdata','reversalList');
save(datafile_full);

ListenChar(0);
Screen('Close',w);
ShowCursor;

