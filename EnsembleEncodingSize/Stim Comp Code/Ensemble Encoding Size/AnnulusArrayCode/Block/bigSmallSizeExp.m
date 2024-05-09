close all;
clear all;

ListenChar(2);
HideCursor;

% load('PreallocateNoise');

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

PPD = (1024/mon_width_deg);

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

dotSizeList = [.5 1 1.5];
nDotSize = length(dotSizeList);
filterList = [0 .8];
nFilter = length(filterList);
nTrials = 25;

numTrials = nFilter*nTrials*nDotSize;

variableList = repmat(fullyfact([nFilter nDotSize]),[nTrials,1]);
trialOrder = randperm(length(variableList));

totalTime=GetSecs;

% break_trials = .25:.25:.75; % list of proportion of total trials at which to offer subject a self-timed break
break_trials = .1:.1:.9;    % list of proportion of total trials at which to offer subject a self-timed break

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

buttonA=KbName('A');
buttonK=KbName('K');

rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

% noise=Screen('MakeTexture',w,noiseMatrix);

rawdata = [];

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
for n=1:numTrials
    filterIdx=variableList(trialOrder(n,1),1);
    alphaVal=filterList(filterIdx);
    rawdata(n,1)=alphaVal;
    dotSizeIdx=variableList(trialOrder(n,1),2);    % stepCount list for variance
    dotSizeVal=(dotSizeList(dotSizeIdx))*PPD;
    rawdata(n,4)=dotSizeVal;
    
    destRect = [x0-(dotSizeVal/2) y0-(dotSizeVal/2) x0+(dotSizeVal/2) y0+(dotSizeVal/2)];
    Screen('FrameOval',w,[dotColor dotColor dotColor], destRect);
end

ListenChar(0);
Screen('Close',w);
ShowCursor;