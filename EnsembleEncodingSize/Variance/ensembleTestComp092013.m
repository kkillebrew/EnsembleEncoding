
% Rawdata 1 = filter value
% Rawdata 2 = iteration value
% Rawdata 3 = stair start value
% Rawdata 4 = variance value
% Rawdata 5 = random filter order value


% rect(3) columns(x) and rect(4) rows(y)
clear;

datafile=input('Enter Subject Code:','s');
datafile_full=sprintf('%s_full',datafile);

load('Preallocate');
ListenChar(2);

% Sets the inputs to come in from the other computer
% [nums, names] = GetKeyboardIndices;
% dev_ID=nums(2);

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

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

[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

noise=Screen('MakeTexture',w,noiseMatrix);

HideCursor;
[keyIsDown, secs, keycode] = KbCheck;

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

while 1
    if keyIsDown
        break
    end
    [keyIsDown, secs, keycode] = KbCheck;
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
    rawdata(n,5)=nFilterOrder;   % 1 means filter order second 2 means it comes first
    
    if nFilterOrder==1
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        WaitSecs(.5);
        for i=1:trialsDotAmount(n)
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopClear(n,i), trialsYTopClear(n,i), trialsXBotClear(n,i), trialsYBotClear(n,i)],(5));
        end
        Screen('Flip',w);
        WaitSecs(.5);
        
        Screen('Flip',w);
        WaitSecs(.5);
        
        for i=1:trialsDotAmount(n)
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(n,i,varVal), trialsYTopNoise(n,i,varVal), trialsXBotNoise(n,i,varVal), trialsYBotNoise(n,i,varVal)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
        Screen('Flip',w);
        WaitSecs(.5);
    else
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        WaitSecs(.5);
        
        for i=1:trialsDotAmount(n)
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(n,i,varVal), trialsYTopNoise(n,i,varVal), trialsXBotNoise(n,i,varVal), trialsYBotNoise(n,i,varVal)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
        Screen('Flip',w);
        WaitSecs(.5);
        
        Screen('Flip',w);
        WaitSecs(.5);
        
        for i=1:trialsDotAmount(n)
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopClear(n,i), trialsYTopClear(n,i), trialsXBotClear(n,i), trialsYBotClear(n,i)],(5));
        end
        Screen('Flip',w);
        WaitSecs(.5);
    end
    
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
    
    while 1
        [keyIsDown, secs, keycode] = KbCheck;
        if rawdata(n,5)==1;   % reference (clear) came first
            if keycode(buttonA)
                rawdata(n,6)=1;   % Test more variable
                break
            end
            if keycode(buttonK)
                rawdata(n,6)=2;   % Reference more variable
                break
            end
        else    % test (filter) came first
            if keycode(buttonA)
                rawdata(n,6)=2;   % Ref more variable
                break
            end
            if keycode(buttonK)
                rawdata(n,6)=1;   % Test more variable
                break
            end
        end
    end
    

    % test=1 ref=2
    if rawdata(n,6)==1    % choose that test was more variable
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
    
    
    Screen('Flip',w);
    [keyIsDown, secs, keycode] = KbCheck;
end

ListenChar(0);
Screen('Close',w);
ShowCursor;

save(datafile,'rawdata','reversalList');
save(datafile_full);

