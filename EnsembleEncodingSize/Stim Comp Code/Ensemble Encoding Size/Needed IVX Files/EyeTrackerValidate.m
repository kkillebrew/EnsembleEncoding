function [overerror, successful]=EyeTrackerValidate(ivx,acceptable_error,dev_ID,con_ID,screen_ID)
successful=0;
while KbCheck(dev_ID); end

r1=3;    %validation dot sizes
r2=10;
pause=60;           %flash variables
flashrate=200;
time_on=1;
xc=1024/2;          %screen center
yc=768/2;

xmatrix=[xc-136 xc xc+136];     %dot locations
ymatrix=[yc-136 yc yc+136];
order_matrix=[1,3,1,3,2;1,1,3,3,2];     %order of dot presentations

data=[];
error=[];

[result, ivx]=iViewXComm('open', ivx);              %open connection
[success, ivx]=iViewXComm('send', ivx, 'ET_CLR');   %clear buffer
[success, ivx]=iViewXComm('send', ivx, 'ET_EST');   %datastreamingoff

Screen('TextSize',screen_ID,24);                    %directions
text='Fixate the dots as they appear.';
width=RectWidth(Screen('TextBounds',screen_ID,text));
Screen('DrawText', screen_ID, text,(1024/2)-width/2,(768/2)-50,[255 255 0]);
text='When you feel you are fixated, press space bar.';
width=RectWidth(Screen('TextBounds',screen_ID,text));
Screen('DrawText', screen_ID, text,(1024/2)-width/2,(768/2),[255 255 0]);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',screen_ID,text));
Screen('DrawText', screen_ID, text,(1024/2)-width/2,(768/2)+50,[255 255 0]);

Screen('Flip',screen_ID);

disp('Directions Visible');                     %Note to experimenters

WaitSecs(1);
KbWait(dev_ID);

disp('Starting Validation');                    %Note to experimenters

while ~KbCheck(dev_ID); end

for u=1:5
    
    xpoint=xmatrix(order_matrix(1,u));          %set point location
    ypoint=ymatrix(order_matrix(2,u));
    
    start_time=GetSecs;
    n=pause;
    while GetSecs<=start_time+time_on;          %flash animation
        
        if n==pause*(flashrate/2)
            Screen('FillOval',screen_ID,[255 255 0],[xpoint-r2,ypoint-r2,xpoint+r2,ypoint+r2]);
            Screen('FillOval',screen_ID,[0 0 0],[xpoint-r1,ypoint-r1,xpoint+r1,ypoint+r1]);
            
            Screen('Flip',screen_ID);
        end
        
        if n==pause*flashrate
            Screen('FillOval',screen_ID,[0 0 0],[xpoint-r1,ypoint-r1,xpoint+r1,ypoint+r1]);
            
            Screen('Flip',screen_ID);
            n=pause;
        end
        n=n+1;
    end
    
    [success, ivx]=iViewXComm('send', ivx, 'ET_CLR');   %clear buffer
    
    result=iViewXComm('send', ivx, 'ET_STR');  %datastreamingon
    
    while ~KbCheck(dev_ID)                              %track eye position while viewing stable point
        
        [data, ivx]=iViewX('receivedata', ivx);data
        
        if 1==strfind(data, 'ET_SPL') % spooled data
            Screen('FillOval',screen_ID,[255 255 0],[xpoint-r2,ypoint-r2,xpoint+r2,ypoint+r2]);
            Screen('FillOval',screen_ID,[0 0 0],[xpoint-r1,ypoint-r1,xpoint+r1,ypoint+r1]);
            mygaze=str2num(data(8:end));
            xeye=mygaze(2);
            yeye=mygaze(4);
            Screen('Flip',screen_ID,0,0);
        end
    end
    xdiff = xpoint-xeye;                            %calculate discrepancy between eye position and dot position
    ydiff = ypoint-yeye;
    
    error(u)=sqrt((xdiff^2)+(ydiff^2));
    
    result=iViewXComm('send', ivx, 'ET_EST');
    
    while KbCheck(dev_ID); end
    disp('Point Accepted');                         %Note to experimenters
end
overerror=(error(1)+error(2)+error(3)+error(4)+error(5))/5  %calculater overall error
[result, ivx]=iViewXComm('close', ivx);
if overerror<=acceptable_error                              %move on if error low enough
    successful=1;
    disp('Calibration/Validation successful');
else                                                        %restart calibration if error too high
    disp('Restarting Calibration');
    [results]=EyeTrackerCalibrate(ivx,acceptable_error,dev_ID,con_ID,screen_ID);
end

