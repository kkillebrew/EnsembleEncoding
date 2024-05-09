close all;
clear all;

load('PreallocateNoise');

ListenChar(2);
HideCursor;

backColor = 255;
dotColor = 128;
textColor = [256, 256, 256];

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

rect=[0, 100, 1024, 868];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

KbName('UnifyKeyNames');

buttonUp = KbName('UpArrow');
buttonDown = KbName('DownArrow');
buttonLeft = KbName('LeftArrow');
buttonRight = KbName('RightArrow');
buttonEscape = KbName('Escape');

% Make texture for noise filter
Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason
noise=Screen('MakeTexture',w,noiseMatrix);

alphaVal = 0;
numWidth = 20;
numHeight = 10;
squareLength = 40;
squareDistWidth = (rect(3)-(numWidth*squareLength))/(numWidth+1);
squareDistHeight = (rect(4)-(numHeight*squareLength))/(numHeight+1);
count = 1;

Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
Screen('TextSize',w,20);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);

    x1 = squareDistWidth;
    y1 = squareDistHeight;
    x2 = x1+squareLength;
    y2 = y1+squareLength;
    for i=1:numHeight
        [keyIsDown, secs, keycode] = KbCheck(dev_ID);
        for j=1:numWidth
            [keyIsDown, secs, keycode] = KbCheck(dev_ID);
            destRect(:,count) = [x1 y1 x2 y2];
            
            x1 = x2+squareDistWidth;
            x2 = x1+squareLength;
            count = count+1;
        end
        y1 = y2+squareDistHeight;
        y2 = y1+squareLength;
        
        x1 = squareDistWidth;
        x2 = x1+squareLength;
    end
    
    Screen('FillRect',w,[128 128 128],destRect);
    Screen('Flip',w);
end



