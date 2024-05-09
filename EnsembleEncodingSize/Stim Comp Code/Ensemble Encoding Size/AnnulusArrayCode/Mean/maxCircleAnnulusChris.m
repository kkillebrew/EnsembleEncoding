clear
ListenChar(2);
HideCursor;
[w,rect]=Screen('OpenWindow',0,[0 0 0],[0,0,1024,768]);
xc=rect(3)/2;
yc=rect(4)/2;

maxr=350;
minr=200;
jitter=10;


% circr=tand(11.25)*maxr;
circr2=(tand(11.25)*maxr)/(1+tand(11.25));
circr=circr2-jitter;

Screen('FrameOval',w,[255 255 255],[xc-maxr,yc-maxr,xc+maxr,yc+maxr]);
Screen('FrameOval',w,[255 255 255],[xc-minr,yc-minr,xc+minr,yc+minr]);
% for i=0:16
% Screen('DrawLine',w,[255 255 255],xc-maxr*cos((i*pi)/8),yc-maxr*sin((i*pi)/8),xc+minr*cos(((i+8)*pi)/8),yc+minr*sin(((i+8)*pi)/8));
% end

for i=.5:15.5
% Screen('DrawLine',w,[255 255 255],xc-maxr*cos((i*pi)/8),yc-maxr*sin((i*pi)/8),xc+minr*cos(((i+8)*pi)/8),yc+minr*sin(((i+8)*pi)/8));
% fromcenpos=randi(maxr-minr)+minr;
fromcenposx=maxr-circr2+(randi(jitter)*((-1)^(randi(2))));
fromcenposy=maxr-circr2+(randi(jitter)*((-1)^(randi(2))));
Screen('FrameOval',w,[255 255 255],[xc-(fromcenposx)*cos((i*pi)/8)-circr,yc-(fromcenposy)*sin((i*pi)/8)-circr,...
    xc-(fromcenposx)*cos((i*pi)/8)+circr,yc-(fromcenposy)*sin((i*pi)/8)+circr]);
end

Screen('Flip',w);

KbWait;

ShowCursor;
ListenChar(0);
Screen('CloseAll');