clear all;
close all;

load('PreallocateOrientation');
load('PreallocateOrientationStim');

ListenChar(2);

backColor = 128;
dotColor = 128;
textColor = [256, 256, 256];

rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (1024/mon_width_deg);

jitter=10;
% radiusJitter=radiusMax-jitter;
% alphaVal=0;
elongateRadius = 10;

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

for i=1:nCircles
    gabor(i) = Screen('MakeTexture',w,scaledtexture{i});
    shift(i) = randi(360);
end

n=1;
i=.5;
varValIdx = 6;
varStairIdx = 6;

[keyIsDown, secs, keycode] = KbCheck;
while ~keyIsDown
    
    [keyIsDown, secs, keycode] = KbCheck;
    for j=1:nCircles
        % Jitter for orientation location
        %     xJitter = (randi((jitter*2)+1)-jitter+1);
        %     yJitter = (randi((jitter*2)+1)-jitter+1);
        
        xJitter = 0;
        yJitter = 0;
        for i=.5:trialsDotAmount(n,j)-.5
            [keyIsDown, secs, keycode] = KbCheck;
            radius(j)=imSize(j)/2;
            destRect=[((x0-xCenter(j)*cos((i*pi)/(trialsDotAmount(n,j)/2)+shift(j)))-(radius(j))),...
                ((y0-yCenter(j)*sin((i*pi)/(trialsDotAmount(n,j)/2)+shift(j)))-(radius(j)+elongateRadius)),...
                ((x0-xCenter(j)*cos((i*pi)/(trialsDotAmount(n,j)/2)+shift(j))+(radius(j)))),...
                ((y0-yCenter(j)*sin((i*pi)/(trialsDotAmount(n,j)/2)+shift(j))+(radius(j)+elongateRadius)))];
            Screen('DrawTexture',w, gabor(j),[],destRect,trialsOrientationVarianceStair(n,i+.5,varValIdx,varStairIdx));
        end
    end
    Screen('Flip',w);
end

ListenChar(0);
Screen('CloseAll');








