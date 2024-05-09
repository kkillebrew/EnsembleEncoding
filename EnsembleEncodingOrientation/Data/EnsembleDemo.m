close all;
clear all;

load('PreallocateSize');
load('PreallocateNoise');
load('PreallocateOrientation');
load('PreallocateOrientationStim');
ListenChar(2);
HideCursor;

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

rect=[0 100 1024 868];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

KbName('UnifyKeyNames');

buttonUp = KbName('UpArrow');
buttonDown = KbName('DownArrow');
buttonLeft = KbName('LeftArrow');
buttonRight = KbName('RightArrow');
buttonEscape = KbName('Escape');
buttonOne = KbName('1!');
buttonTwo = KbName('2@');
buttonThree = KbName('3#');
buttonFour = KbName('4$');
buttonR = KbName('R');
buttonT = KbName('T');
buttonLArrow = KbName(',<');
buttonRArrow = KbName('.>');
buttonColon = KbName(';:');
buttonL = KbName('L');
buttonQ = KbName('Q');
buttonE = KbName('E');

jitter=10;
radiusAnnulusBig=384;
radiusAnnulusSmall=200;
divisions=16;

radiusMax=(tand(wedgeSize)*radiusAnnulusBig)/(1+tand(wedgeSize));
radiusJitter=radiusMax-jitter;

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

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while ~keycod(escape)
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    % Up for size
    if keycode(buttonUp)
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
    end
    % Down for orientation
    if keycode(buttonDown)
        
    end
    
    
end




ShowCursor;
ListenChar(0);
Screen('CloseAll',w);












