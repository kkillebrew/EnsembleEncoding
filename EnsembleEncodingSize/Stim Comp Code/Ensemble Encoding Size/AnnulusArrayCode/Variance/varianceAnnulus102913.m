
% rect(3) columns(x) and rect(4) rows(y)
clear;

datafile=input('Enter Subject Code:','s');
datafile_full=sprintf('%s_full',datafile);

load('PreallocateVariance');
ListenChar(2);

% Sets the inputs to come in from the other computer
% [nums, names] = GetKeyboardIndices;
% dev_ID=nums(2);

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

totalTime=GetSecs;

jitter=10;
radiusAnnulusBig=384;
radiusAnnulusSmall=200;
divisions=12;

radiusMax=(tand(wedgeSize)*radiusAnnulusBig)/(1+tand(wedgeSize));
radiusJitter=radiusMax-jitter;

eyetracking = 0;   % Set if using eye tracker

% break_trials = .25:.25:.75; % list of proportion of total trials at which to offer subject a self-timed break
break_trials = .1:.1:.9;    % list of proportion of total trials at which to offer subject a self-timed break

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(2);
con_ID=nums(1);

buttonA=KbName('A');
buttonK=KbName('K');

rawdata=[];

for i=1:nFilter
    for j=1:nIteration
        for k=1:nStart
            if k==2   % The second choice was more variable
                stepCount(i,j,k)=nVar;     % Sets the value of stepCount at the greatest var until they choose another val
                prevAns(i,j,k)=1;     % States that the test was more variable
            else
                stepCount(i,j,k)=1;
                prevAns(i,j,k)=2;      % Ref was more variable
            end
            placeList(i,j,k)=1;             % If you had a reversal add one to place list
        end
    end
end

variableList=repmat(fullyfact([nFilter nIteration nStart]),[nTrials,1]);        % repmap=repeat matrix; makes the large array to choose which variable to use per trial
trialOrder=randperm(numTrials);

[w,rect]=Screen('OpenWindow', 1,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

noise=Screen('MakeTexture',w,noiseMatrix);

HideCursor;
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

Screen('TextSize',w,24);
text='Which set of circles had the greatest difference in size?';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('TextSize',w,24);
text='Press A for the first option or K for the second.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
text='Please focus on the central red and black dot.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-250,textColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);

while 1
    if keyIsDown
        break
    end
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
end

if eyetracking
    [result, ivx]=iCiewXComm('open',ivx);   % Open a connection with the eyetracker
end

for n=1:numTrials
    
    nFilterOrder=randi(2);    % For 1 draw clear first 2 draw filter first
    
    % Choosing and storing values of the different variables into the
    % arrays
    filterIdx=variableList(trialOrder(n),1);
    alphaVal=filterList(filterIdx);
    rawdata(n,1)=alphaVal;
    iterationIdx=variableList(trialOrder(n),2);
    iterationVal=iterationList(iterationIdx);
    rawdata(n,2)=iterationVal;
    startIdx=variableList(trialOrder(n),3);
    startVal=startList(startIdx);
    rawdata(n,3)=startVal;
    varIdx=stepCount(filterIdx,iterationIdx,startIdx);
    varVal=varList(varIdx);
    rawdata(n,4)=varVal;
    rawdata(n,5)=nFilterOrder;   % 1 means noisy fisrt 2 second
    
    if nFilterOrder==1
        
        % Draw noisy set to be on screen for .5 sec
        % As the set becomes more variable and more noisy participants
        % should report it as appearing less variable
        startTime=GetSecs;
        z=0;
        while GetSecs-startTime<.5
            for i=.5:trialsDotAmount(n)-.5
                xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                radiusCircle=trialsDotSizeNoise(n,i+.5,varIdx);
                Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                    ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
            end
            Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
            Screen('Flip',w);
            WaitSecs(.5);
            
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
                radiusCircle=trialsDotSizeClear(n,i+.5);
                Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                    ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
            end
            Screen('Flip',w);
            WaitSecs(.5);
            
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
        
    else

        % Draw comparison set to be on screen for .5 sec
        startTime=GetSecs;
        z=0;
        while GetSecs-startTime<.5
            for i=.5:trialsDotAmount(n)-.5
                xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
                radiusCircle=trialsDotSizeClear(n,i+.5);
                Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                    ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
            end
            Screen('Flip',w);
            WaitSecs(.5);
            
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
                radiusCircle=trialsDotSizeNoise(n,i+.5,varIdx);
                Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2)))-(radiusCircle)),...
                    ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmount(n)/2))+(radiusCircle)))],5);
            end
            Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
            Screen('Flip',w);
            WaitSecs(.5);
            
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
    
    Screen('TextSize',w,24);
    text='Which set of circles had the greatest difference in size?';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
    Screen('TextSize',w,24);
    text='Press A for the first option or K for the second';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
    Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
    Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
    Screen('Flip',w);
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if rawdata(n,5)==1;   % noisy came first
            if keycode(buttonA)
                rawdata(n,6)=1;   % noise more variable
                break
            end
            if keycode(buttonK)
                rawdata(n,6)=2;   % clear more variable
                break
            end
        else    % clear came first
            if keycode(buttonA)
                rawdata(n,6)=2;   % clear more variable
                break
            end
            if keycode(buttonK)
                rawdata(n,6)=1;   % noise more variable
                break
            end
        end
    end
    
    
    % test=1 ref=2
    if rawdata(n,6)==2    % choose that test was more variable
        if prevAns(filterIdx,iterationIdx,startIdx)==2   % States that on the last trial, ref had greater variablity
            reversalList(filterIdx,iterationIdx,startIdx,placeList(filterIdx,iterationIdx,startIdx))=1;
            placeList(filterIdx,iterationIdx,startIdx)=placeList(filterIdx,iterationIdx,startIdx)+1;
            rawdata(n,7)=1;
        else   % the last value reft was more variable
            rawdata(n,7)=0;
        end
        prevAns(filterIdx,iterationIdx,startIdx)=1;
        stepCount(filterIdx,iterationIdx,startIdx)=min(stepCount(filterIdx,iterationIdx,startIdx)+1,length(varList));
    else   %  choose that ref was more variable
        if prevAns(filterIdx,iterationIdx,startIdx)==2   % States that on the last trial, ref had greater variablity
            rawdata(n,7)=0;
        else   % the last value test was more variable
            reversalList(filterIdx,iterationIdx,startIdx,placeList(filterIdx,iterationIdx,startIdx))=1;
            placeList(filterIdx,iterationIdx,startIdx)=placeList(filterIdx,iterationIdx,startIdx)+1;
            rawdata(n,7)=1;
        end
        prevAns(filterIdx,iterationIdx,startIdx)=2;
        stepCount(filterIdx,iterationIdx,startIdx)=max(stepCount(filterIdx,iterationIdx,startIdx)-1,1);
    end
    
    % give subject break at certain trials...
    this_b = 0;
    for b = break_trials
        if n==round(b*length(variableList))
            this_b = b;
            break
        end
    end
    if this_b
        % display break message
        text=sprintf('You have completed %d%% of the trials.',round(b*100));
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
        text='Press any key when you are ready to continue.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
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
    
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
end

save(datafile,'rawdata','reversalList');
save(datafile_full);

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
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keyIsDown
        break
    end
end

ListenChar(0);
Screen('Close',w);
ShowCursor;



