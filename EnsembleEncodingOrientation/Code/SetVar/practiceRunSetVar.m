close all;
clear all;

load('PreallocateNoise');
load('PreallocateOrientationSetVar');
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

rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 1,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

jitter = 10;
elongateRadius = 10;

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(2);
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

% Initial instructions
Screen('TextSize',w,20);
text='This is a practice run and will explain what the stimuli will look like and how you should respond.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
Screen('TextSize',w,20);
text='Press any key to continue.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Cue screen
Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
Screen('TextSize',w,24);
text='Variance/Mean Trial';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
Screen('TextSize',w,24);
text='This screen will appear before each trial instructing you what type of trial it will be.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
Screen('TextSize',w,24);
text='The color of the outline indicates trial type (red=mean green=variance)';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('TextSize',w,24);
text='The text also indicates what trial type it will be ("Variance/Mean Trial")';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
Screen('TextSize',w,20);
text='Press any key to continue.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Initial instructions
Screen('TextSize',w,20);
text='You will then be presented with two consecutive screens, each containing a group of oriented bars.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
Screen('TextSize',w,20);
text='Your task is to judge which set is either oriented more clockwise (towards the right) or more variable.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-250,textColor);
Screen('TextSize',w,20);
text='Keep in mind that some sets will be embedded in white noise and may be difficult to see.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
Screen('TextSize',w,20);
text='Do your best to respond based soley off the overall orientation regardless of noise.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('TextSize',w,20);
text='Press any key to continue.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Start of the show trial with response instructions
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

% Cue screen
Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
Screen('TextSize',w,24);
text='Variance Trial';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Fixation period
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
WaitSecs(.5);

n=1;
alphaVal = 0;
varStairIdx = 11;
varValIdx = 1;
% Presentation of noisy stimulus
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
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Breif fixation period
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
WaitSecs(.5);

% Presentation of cmopare
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
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Now a mean example
Screen('FrameRect',w,[256 0 0],[0 0 1024 768],5);
Screen('TextSize',w,24);
text='Mean Trial';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% .5s fixation
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
WaitSecs(.5);

meanValIdx = 3;
meanStairIdx = 11;
% Presentation of compare
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
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Fixation period
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
WaitSecs(.5);

% Presentation of test stim
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
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Fixation period
Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

% Start of the show trial with response instructions
Screen('TextSize',w,20);
text='You can now run through some practice trials';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
Screen('TextSize',w,20);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

expOrder = [1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 2 2 2 2 2];
varStairIdx = [11 1 10 2 9 3 9 3 9 3 11 1 10 2 9 3 9 3 9 3];
meanStairIdx = [11 1 10 2 9 3 9 3 9 3 11 1 10 2 9 3 9 3 9 3];
for n=1:20
    alphaIdx = randi(2);
    if alphaIdx ==1
        alhpaVal = 0;
    else
        alphaVal = .7;
    end
    if expOrder(n) == 1             % For variance experiments the ref is noisy (aka staircase or set that is changing)
        %% Variance Experiment sets variables for variance
        varValIdx=randi(nVarianceOrient);
        varVal=varianceOrientationList(varValIdx);
        
        nFilterOrder=randi(2);    % For 1 draw clear first 2 draw filter first
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
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVarianceStair(n,i+.5,varValIdx,varStairIdx(n)));
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
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVarianceStair(n,i+.5,varValIdx,varStairIdx(n)));
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
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMeanStair(n,i+.5,meanValIdx,meanStairIdx(n)));
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
                        Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMeanStair(n,i+.5,meanValIdx,meanStairIdx(n)));
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
    KbWait(dev_ID);
    KbReleaseWait(dev_ID);
end

Screen('CloseAll');

ListenChar(0);
ShowCursor;











