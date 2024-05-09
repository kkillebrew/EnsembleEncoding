% rect(3) columns(x) and rect(4) rows(y)
clear;

datafile=input('Enter Subject Code:','s');
datafile_full=sprintf('%s_full',datafile);

load('PreallocateMean');
ListenChar(2);

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];
compareBuffer = 100;
totalTime=GetSecs;

eyetracking = 0;   % Set if using eye tracker

% break_trials = .25:.25:.75; % list of proportion of total trials at which to offer subject a self-timed break
break_trials = .1:.1:.9;    % list of proportion of total trials at which to offer subject a self-timed break

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

buttonA=KbName('A');
buttonK=KbName('K');

rawdata=[];

for i=1:nFilter
    for j=1:nIteration
        for k=1:nStart
            if k==2  %  Larger than the mean
                stepCount(i,j,k)=nCompareMean;     % Sets the value of stepCount to the greatest variability
                prevAns(i,j,k)=1;     % Was larger than the mean
            else     % Smaller than thed mean
                stepCount(i,j,k)=1;     % Sets the value of stepCount to the smallest variability
                prevAns(i,j,k)=2;     % Was smaller than the mean
            end
            placeList(i,j,k)=1;
        end
    end
end

variableList=repmat(fullyfact([nFilter nIteration nStart]),[nTrials,1]);        % repmap=repeat matrix; makes the large array to choose which variable to use per trial
trialOrder=randperm(numTrials);

[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
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
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('TextSize',w,24);
text='Press A for the first option or k for the second';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('Flip',w);

Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);

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
    
    meanValIdx=randi(meanNoiseCount);    % randomly chooses value to select which array of dots to choose from depending on mean size
    meanVal=meanNoise(meanValIdx);
    
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
    compareMeanIdx=stepCount(filterIdx,iterationIdx,startIdx);
    compareMeanVal=compareMeanList(compareMeanIdx);
    rawdata(n,4)=compareMeanVal;
    rawdata(n,5)=meanVal; % Chooses the actual mean
    
    Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
    Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
    Screen('Flip',w);
    WaitSecs(.5);
    
    startTime=GetSecs;
    z=0;
    while GetSecs-startTime<.5
        for i=1:trialsDotAmount(n)
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(n,i,meanValIdx), trialsYTopNoise(n,i,meanValIdx), trialsXBotNoise(n,i,meanValIdx), trialsYBotNoise(n,i,meanValIdx)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
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
    
    % Draw the comparison set
    for i=1:trialsDotAmount(n)
        Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopCompare(randi(300),i,meanValIdx,compareMeanIndex), trialsYTopNoise(randi(300),i,meanValIdx,compareMeanIndex), trialsXBotNoise(randi(300),i,meanValIdx,compareMeanIndex), trialsYBotNoise(randi(300),i,meanValIdx,compareMeanIndex)],(5));
    end
    
    Screen('TextSize',w,24);
    text='Which set of circles had the largest mean value?';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-350,textColor);
    Screen('TextSize',w,24);
    text='(A) for the first set (K) for the second set?';
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
    Screen('Flip',w);
    
    while 1
        % Records responses
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        if keycode(buttonA)
            rawdata(n,6)=1;    % smaller than the mean
            break
        end
        if keycode(buttonK)
            rawdata(n,6)=2;    % larger than the mean
            break
        end
    end
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    % smaller=1 larger=2
    if rawdata(n,6)==1    % compare was smaller than the mean
        if prevAns(filterIdx,iterationIdx,startIdx)==2   % States that on the last trial, the said the compare was larger
            reversalList(filterIdx,iterationIdx,startIdx,placeList(filterIdx,iterationIdx,startIdx))=1;
            placeList(filterIdx,iterationIdx,startIdx)=placeList(filterIdx,iterationIdx,startIdx)+1;
            rawdata(n,7)=1;
        else   % compare was larger
            rawdata(n,7)=0;
        end
        prevAns(filterIdx,iterationIdx,startIdx)=1;
        stepCount(filterIdx,iterationIdx,startIdx)=min(stepCount(filterIdx,iterationIdx,startIdx)+1,length(compareMeanList));
    else   %  said that the compare was larger
        if prevAns(filterIdx,iterationIdx,startIdx)==2   % States that on the last trial, the said that the compare was larger
            rawdata(n,7)=0;
        else   % the last value was smaller
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
        Screen('DrawText',w,text,x0-width/2,y0,textColor);
        text='Press any key when you are ready to continue.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0+50,textColor);
        Screen('Flip',w);
        disp(round(b*100));
        disp((GetSecs-totalTime)/60);
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        while 1
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            if Keycode(buttonA)
                break
            end
        end
    end
    
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
[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while 1
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    if keyIsDown
        break
    end
end

save(datafile,'rawdata','reversalList');
save(datafile_full);

disp((GetSecs-totalTime)/60);

ListenChar(0);
Screen('Close',w);
ShowCursor;




% Change the compare presentation to show a random set of dots from the set
% Change the response collection to account for the random display order
% Fix the exp so it is like the variance data collection method i.e. right
%   vs wrong instead of big vs small
% Graph the accuracytets

