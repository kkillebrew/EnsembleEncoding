clear
ListenChar(2);
HideCursor;
[w,rect]=Screen('OpenWindow',0,[0 0 0],[0 ,0,1024,768]);
xc=rect(3)/2;
yc=rect(4)/2;

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);

ppd = (1024/mon_width_deg);

maxr=384;
minr=200;
jitter=10;
dotAmount=16;
guides=0;
linethickness=5;
% Dot size variables
stdev=.2*ppd;
%with stdev of .2 min=.8     max=1.4;
meanNoise=[0.8 0.95 1.1 1.25 1.4];
meanNoiseCount=length(meanNoise);

wedgeang=360/(dotAmount*2);
circr2=(tand(wedgeang)*maxr)/(1+tand(wedgeang));
if maxr-minr<circr2
    circr2=maxr-minr;
end
maxcircr=circr2-jitter;
mincircr=linethickness+1;

wedgeang=360/(dotAmount*2);
circr2=(tand(wedgeang)*maxr)/(1+tand(wedgeang));
if maxr-minr<circr2
    circr2=maxr-minr;
end
maxcircr=circr2-jitter;
maxcircr=maxcircr/ppd;
mincircr=linethickness+1;
mincircr=mincircr/ppd;




% Preallocation variables/arrays
trialsdotAmount = [];
trialsDotSizeNoise = [];

numTrials=1000;

for h=1:length(meanNoise)
    for i=1:numTrials
        
        dotSizeNoise=[];
        dotSizeNoise=randn(1,dotAmount);
        dotSizeNoise=dotSizeNoise-mean(dotSizeNoise);
        dotSizeNoise=dotSizeNoise/(std(dotSizeNoise));
        dotSizeNoise=dotSizeNoise*stdev;
        dotSizeNoise=dotSizeNoise+(meanNoise(h)*ppd);
        dotSizeNoise=round(dotSizeNoise);
        for j=1:dotAmount
            trialsDotSizeNoise(i,h,j)=dotSizeNoise(j);
        end
    end
end



for z=1:numTrials
    if guides
        Screen('FrameOval',w,[255 255 255],[xc-maxr,yc-maxr,xc+maxr,yc+maxr]);
        Screen('FrameOval',w,[255 255 255],[xc-minr,yc-minr,xc+minr,yc+minr]);
        for i=0:dotAmount
            Screen('DrawLine',w,[255 255 255],xc-maxr*cos((i*pi)/(dotAmount/2)),yc-maxr*sin((i*pi)/(dotAmount/2)),...
                xc+minr*cos(((i+(dotAmount/2))*pi)/(dotAmount/2)),yc+minr*sin(((i+(dotAmount/2))*pi)/(dotAmount/2)));
        end
    end
    
    
    for i=.5:dotAmount-.5;
        
        if guides
            Screen('DrawLine',w,[255 255 255],xc-maxr*cos((i*pi)/(dotAmount/2)),yc-maxr*sin((i*pi)/(dotAmount/2)),...
                xc+minr*cos(((i+(dotAmount/2))*pi)/(dotAmount/2)),yc+minr*sin(((i+(dotAmount/2))*pi)/(dotAmount/2)));
        end
        
        fromcenposx=maxr-circr2+(randi((jitter*2)+1)-(jitter+1));
        fromcenposy=maxr-circr2+(randi((jitter*2)+1)-(jitter+1));
        circr=trialsDotSizeNoise(z,randi(length(meanNoise)),i+.5);
        
        Screen('FrameOval',w,[255 255 255],[xc-(fromcenposx)*cos((i*pi)/(dotAmount/2))-circr,yc-(fromcenposy)*sin((i*pi)/(dotAmount/2))-circr,...
            xc-(fromcenposx)*cos((i*pi)/(dotAmount/2))+circr,yc-(fromcenposy)*sin((i*pi)/(dotAmount/2))+circr],linethickness);
    end
    
    Screen('Flip',w);
    
    KbReleaseWait;
    
    KbWait;
    
end

KbReleaseWait;

KbWait;

ShowCursor;
ListenChar(0);
Screen('CloseAll');