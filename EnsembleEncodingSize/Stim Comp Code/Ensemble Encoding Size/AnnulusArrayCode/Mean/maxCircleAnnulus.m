
% Max Circle Radius = 62.3 pix or 1.89 degrees
% Max Circle Diameter = 124.7766 pix or 3.78 degrees

% std of .2 and min of .8 with max of 1.4

clear;

ListenChar(2);

jitter=20;

escape=KbName('escape');
dotColor=255;
backColor=0;
guide=0;

radiusAnnulusBig=384;
radiusAnnulusSmall=200;
divisions=11;

wedgeSize = 360/(divisions*2);
radiusMax=(tand(wedgeSize)*radiusAnnulusBig)/(1+tand(wedgeSize));
radiusJitter=radiusMax-jitter;

if radiusAnnulusBig-radiusAnnulusSmall<radiusJitter
    radiusJitter=radiusAnnulusBig-radiusAnnulusSmall;
end


% rect=[0 0 2560 1440];     % screen dimension for lab comps
rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

HideCursor;
[keyIsDown, secs, keycode] = KbCheck;
if guide==1
    Screen('FrameOval',w,[dotColor dotColor dotColor],[x0-radiusAnnulusBig, y0-radiusAnnulusBig, x0+radiusAnnulusBig, y0+radiusAnnulusBig],2);
    Screen('FrameOval',w,[dotColor dotColor dotColor],[x0-radiusAnnulusSmall, y0-radiusAnnulusSmall, x0+radiusAnnulusSmall, y0+radiusAnnulusSmall],2);
    for i=0:divisions
        Screen('DrawLine',w,[dotColor dotColor dotColor], x0-radiusAnnulusBig*cos((i*pi)/(divisions/2)),y0-radiusAnnulusBig*sin((i*pi)/(divisions/2)),...
            x0+radiusAnnulusSmall*cos(((i+(divisions/2))*pi)/(divisions/2)),y0+radiusAnnulusSmall*sin(((i+(divisions/2))*pi)/(divisions/2)),2);
    end
end

for i=.5:divisions-.5
    xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
    yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
    Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(divisions/2)))-(radiusJitter)),((y0-yCircleCenter*sin((i*pi)/(divisions/2)))-(radiusJitter)),...
        ((x0+xCircleCenter*cos(((i+(divisions/2))*pi)/(divisions/2)))+(radiusJitter)),((y0+yCircleCenter*sin(((i+(divisions/2))*pi)/(divisions/2)))+(radiusJitter))],2);
end

Screen('Flip',w);

KbWait;

ShowCursor;
ListenChar(0);
Screen('CloseAll');


