close all;
clear all;
sca
%rng('shuffle')

curpath=pwd;
subjInti = input('Enter Subject Initial:','s');
subjid = input('Enter Subject Number:');
runid = input('Enter Run Number:');
experiment = 'F5O2Center_scanner';
datecode = datestr(now,'yyyymmddHHMM');
datafilename=sprintf('%s_%d_%s_%s_run%02d',subjInti, subjid,datecode,experiment,runid);
datafile=[curpath '/results/' datafilename '.mat'];
%cd Tools and Objects image files
imMorphDir = dir([curpath '/5F2O/*.jpg']);

% in one block
numTrials = 28;
numCond = 7;

array_log = cell(numTrials,15);
pressedKey = cell(numTrials,1);
RT = zeros(numTrials,1);
realTime = zeros(numTrials,1);
missRT = zeros(numTrials,1);

StimulusOnsetTime = [];

imDuration = 1;
fixDuration = 3;
blkDuration = 12;

while 1
    ITI = [repmat(0,1,14) repmat(2,1,8) repmat(4,1,4) repmat(6,1,2)]';
    curITI = Shuffle(ITI);
    if curITI(end) == 0
        break
    end
end

curTiming = [];
curTiming(1) = 0;

for i=2:numTrials
    curTiming(i,1) = curTiming(i-1,1) + imDuration + fixDuration + curITI(i-1) ;
end

curTiming = curTiming + blkDuration;
runEnd = curTiming(end) + imDuration + fixDuration + curITI(end) + blkDuration % 180 s

% tan(visual angle *pi/180)*50*1080/30
% tan(5*pi/180)*135*1920/70 in scanner
% atan(200/1920*70/135)*180/pi
% 1080/30 = 36 pix/cm
% 50 cm distance
xmove = 300;
tex = {};
xshift = [];

for i = 1:numCond
    imMorphName{i,1}=imread([curpath '/5F2O/' imMorphDir(i).name]);
end
imMorph = cell(numTrials,1);

% trial seq
trialseq = [];
trialseq = counter(7,28);
% for i = 1:numTrials/numCond
%    temseq = randperm(numCond);
%
%    while i > 1 && trialseq((i-1)*numCond) == temseq(1)
%        temseq = randperm(numCond)
%    end
%
%    trialseq = [trialseq temseq];
% end


%fix task trial 3 of 1
% fixtrial = [];
% for i = 1:numCond
%     temfix = [randperm(4) randperm(4)];
%     fixtrial = [fixtrial; temfix];
% end

if exist('runid')
else
    runid = 0;
end

% while 1
%     whichfix = counter(2,numCond);
%     if sum(whichfix) == 7 && mod(runid,2) == 0
%         break;
%     elseif sum(whichfix) == 8 && mod(runid,2) == 1
%         break;
%     end
% end

% condindx = zeros(numCond,1);
% for i = 1:numTrials
%     condindx(trialseq(i)) = condindx(trialseq(i)) + 1;
%
%     if fixtrial(trialseq(i),condindx(trialseq(i))) <= 2
%         FixCol(i) = 0; % Red
%         FixColStr{i} = 'Red';
%         FixColRGB{i} = [255 0 0];
%     else
%         FixCol(i) = 1; % Blue
%         FixColStr{i} = 'Blue';
%         FixColRGB{i} = [0 0 255];
%     end
%
%     if mod(fixtrial(trialseq(i),condindx(trialseq(i))),2) == 1 && FixCol(i) + 1 == whichfix(trialseq(i)) %% when fix and only 1 color
%         TrialTask(i) = 0; % Colr
%         TrialTaskStr{i} = 'Color';
%     else
%         TrialTask(i) = 1; % Face
%         TrialTaskStr{i} = 'Face';
%     end
%
%     temlvl = mod(trialseq(i),5);
%     switch temlvl
%         case 1
%             imMorph{i,1} = (imread([curpath '/Faces/' imMorphDir(1).name]));
%             imlvl(i) = 1;
%         case 2
%             imMorph{i,1} = (imread([curpath '/Faces/' imMorphDir(2).name]));
%             imlvl(i) = 2;
%         case 3
%             imMorph{i,1} = (imread([curpath '/Faces/' imMorphDir(3).name]));
%             imlvl(i) = 3;
%         case 4
%             imMorph{i,1} = (imread([curpath '/Faces/' imMorphDir(4).name]));
%             imlvl(i) = 4;
%         case 0
%             imMorph{i,1} = (imread([curpath '/Faces/' imMorphDir(5).name]));
%             imlvl(i) = 5;
%     end
%
%     if trialseq(i) <= 5
%         xshift(i) = xmove * 0;
%         Hemi(i) = 0; %LVF
%         HemiStr{i} = 'MID';
%     elseif trialseq(i) >= 11
%         xshift(i) = xmove * 1;
%         Hemi(i) = 2; %RVF
%         HemiStr{i} = 'RVF';
%     else
%         xshift(i) = xmove * 0;
%         Hemi(i) = 1; %CENTER
%         HemiStr{i} = 'MID';
%     end
% end


% PTB initiate
AssertOpenGL; %%%* check for PTB3
screens=Screen('Screens'); %%%* find display window
screenNum=max(screens); %%%*
Screen('Preference', 'SkipSyncTests', 1); %%% Ali's mirrored display only - allow presentation on mirrored displays for demo
Background = [255 255 255]; %%% BACKGROUND RGB COLOR
[window, rect] = Screen('OpenWindow',screenNum, Background);
[wScreen, hScreen] = RectSize(rect);
ifi = Screen('GetFlipInterval', window);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
hFixAdjust = 8;

LettSizeS = 50;
LettSize = 40;
FixSize = 10;
FixThick = 2;

for i = 1:numTrials
    
    tex{i,1} = imMorphName{trialseq(i),1};
    
    tex1(i) = Screen('MakeTexture',window,tex{i,1}); % target
    
end

HideCursor;
% set text format
Screen('TextSize',window,50);
%Screen('TextFont',window,'Helvetica');

black = BlackIndex(window);
white = WhiteIndex(window); % pixel value for white
gray = (2*white+white+black)/4;
blue = [0 0 255];
red = [255 0 0];
dotsSize = 10;
dotsColor = black;
dotsType = 1;

KbName('UnifyKeyNames');
[dev,name] = GetKeyboardIndices;
devid = dev(strcmp(name,'Lumina Keyboard')); %test program on Apple; formal scan on Lumia box %Lumina Keyboard Apple Internal Keyboard / Trackpad
%devid = dev(1); %needs to be changed

button1=KbName('3#');
button2=KbName('4$');
triggerKey = KbName('6^');


allowed_keys = zeros(1,256);
allowed_keys([button1 button2 triggerKey]) = 1;

KbQueueCreate(devid, allowed_keys);
KbQueueStart(devid);
KbQueueFlush(devid);
%KbQueueWait(devid);

%draw fixation
Screen('DrawDots', window, [wScreen/2 hScreen/2], dotsSize, dotsColor,[],dotsType);
Screen('Flip', window);
WaitSecs(.5);

%instruction
Screen('TextSize',window,LettSize);
text='Please wait for the experiment to start';
Swidth=RectWidth(Screen('TextBounds',window,text));
Screen('DrawText',window,text,wScreen/2-Swidth/2,hScreen/2,[0 0 0]);
Screen('Flip',window);

% wait for trigger
KbQueueFlush(devid);
[press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(devid);
while ~any(lastPress(triggerKey))
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(devid);
    StartTime = GetSecs;
end

tic

Screen('DrawDots', window, [wScreen/2 hScreen/2], dotsSize, dotsColor,[],dotsType);
Screen('Flip', window,StartTime-ifi/4);

allowed_keys = zeros(1,256);
allowed_keys([button1 button2]) = 1;

KbQueueCreate(devid, allowed_keys);
KbQueueStart(devid);
KbQueueFlush(devid);

%draw fixation
%[Fixwidth NNN]=RectWidth(Screen('TextBounds',window,'+'));
%Screen('DrawText',window,'+',wScreen/2 - Fixwidth/2,hScreen/2+hFixAdjust,[0 0 0]);

X1 = wScreen/2 - 120;
Y1 = hScreen/2 - 140;
X2 = wScreen/2 + 120;
Y2 = hScreen/2 + 140;

for i=1:numTrials
    %     Screen('Flip', window,StartTime+controlTiming(i,1)-ifi/2-0.7);
    %
    %     Screen('DrawLine', window, blue, wScreen/2-10, hScreen/2, wScreen/2+10, hScreen/2, 4);
    %     Screen('DrawLine', window, blue, wScreen/2, hScreen/2-10, wScreen/2, hScreen/2+10, 4);
    %     Screen('Flip', window,StartTime+controlTiming(i,1)-ifi/2-0.5);
    
    %draw fixation
    
    %     X1 = wScreen/2 - 120 + xshift(i);
    %     Y1 = hScreen/2 - 140;
    %     X2 = wScreen/2 + 120 + xshift(i);
    %     Y2 = hScreen/2 + 140;
    
    Screen('DrawTexture', window, tex1(i), [],[X1 Y1 X2 Y2]);
    %dotsColor = FixColRGB{i};
    Screen('DrawDots', window, [wScreen/2 hScreen/2], dotsSize, dotsColor,[],dotsType);
    
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
    [~, StimulusOnsetTime, ~, ~, ~] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
    realTime(i) = StimulusOnsetTime - StartTime;
    
    shown = 0;
    response = 0;
    startTime = GetSecs;
    KbQueueFlush(devid);
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(devid);
    while GetSecs - startTime < 3.5
        [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(devid);
        
        if press && response == 0
            RT(i) = GetSecs - startTime;
            response = 1;
            pressedKey{i} = KbName(firstPress);
        end
        
        if response == 1
            break;
        end
        
        if shown == 0 && GetSecs - startTime > 1
            Screen('DrawDots', window, [wScreen/2 hScreen/2], dotsSize, dotsColor,[],dotsType);
            [~, StimulusOnsetTime, ~, ~, ~] = Screen('Flip', window);
            shown = 1;
        end
        
        WaitSecs(0.005);
    end
    
    Screen('DrawDots', window, [wScreen/2 hScreen/2], dotsSize, dotsColor,[],dotsType);
    Screen('Flip', window);
    
    array_log{i,1} = subjid;
    array_log{i,2} = runid;
    array_log{i,3} = trialseq(i);
    array_log{i,4} = [];%HemiStr{i};
    array_log{i,5} = [];%imlvl(i);
    
    %     array_log{i,6} = TrialTask(i);
    %     array_log{i,7} = TrialTaskStr{i};
    %     array_log{i,8} = FixCol(i);
    %     array_log{i,9} = FixColStr{i};
    
    %     if TrialTask(i) == 1
    %         if strcmp(pressedKey{i},KbName(button1))
    %             array_log{i,10} = 1; % response
    %             array_log{i,11} = 'face1';
    %         else
    %             array_log{i,10} = 2;
    %             array_log{i,11} = 'face2';
    %         end
    %     else
    %         if FixCol(i) == 0 % red
    %             if strcmp(pressedKey{i},KbName(button1)) == 1
    %                 array_log{i,10} = 1;
    %                 array_log{i,11} = 'correct';
    %             else
    %                 array_log{i,10} = 0;
    %                 array_log{i,11} = 'incorrect';
    %             end
    %         else % blue
    %             if strcmp(pressedKey{i},KbName(button2)) == 1
    %                 array_log{i,10} = 1;
    %                 array_log{i,11} = 'correct';
    %             else
    %                 array_log{i,10} = 0;
    %                 array_log{i,11} = 'incorrect';
    %             end
    %         end
    %     end
    
    array_log{i,9} = trialseq(i);
    if response == 1
        if trialseq(i) <= 5
            if strcmp(pressedKey{i},KbName(button1))
                array_log{i,10} = 1; % response
                array_log{i,11} = 'F1';
            else
                array_log{i,10} = 2;
                array_log{i,11} = 'F2';
            end
        else
            array_log{i,10} = 0;
            array_log{i,11} = 'incorrected';
        end
    else
        if trialseq(i) <= 5
            array_log{i,10} = 0;
            array_log{i,11} = 'missed';
        elseif trialseq(i) == 6
            array_log{i,10} = 3;
            array_log{i,11} = 'P1';
        elseif trialseq(i) == 7
            array_log{i,10} = 3;
            array_log{i,11} = 'S1';
        end
    end
    
    array_log{i,12} =  RT(i);
    
    %     if Hemi(i) == 0
    %         temHemi = sprintf('LVF_MF%d', imlvl(i));
    %         temHemiTask = sprintf('%s_LVF_MF%d', TrialTaskStr{i},imlvl(i));
    %     elseif Hemi(i) == 1
    %         temHemi = sprintf('MID_MF%d', imlvl(i));
    %         temHemiTask = sprintf('%s_MID_MF%d', TrialTaskStr{i},imlvl(i));
    %     elseif Hemi(i) == 2
    %         temHemi = sprintf('RVF_MF%d', imlvl(i));
    %         temHemiTask = sprintf('%s_RVF_MF%d', TrialTaskStr{i},imlvl(i));
    %     end
    
    %     array_log{i,13} = temHemi;
    array_log{i,14} = curTiming(i);
    array_log{i,15} = realTime(i);
    %     array_log{i,16} = temHemiTask;
    
end

%draw fixation
Screen('DrawDots', window, [wScreen/2 hScreen/2], dotsSize, dotsColor,[],dotsType);

[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) + curITI(numTrials) + 4 + blkDuration - ifi/4);
%WaitSecs(curITI(numTrials));

toc
save(datafile);

Screen('CloseAll');
sca
