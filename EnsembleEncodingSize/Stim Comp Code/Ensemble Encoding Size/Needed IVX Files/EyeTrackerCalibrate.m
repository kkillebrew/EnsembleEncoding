function [results]=EyeTrackerCalibrate(ivx,acceptable_error,dev_ID,con_ID,screen_ID)

results=0;
space=KbName('space');                          %sets up response keys
goback=KbName('LeftArrow');
advance=KbName('RightArrow');

pause=60;                                       %sets flash parameters
% xmatrix=[282 512 742];                           %calibration dot positions for 1024x768 monitor
% ymatrix=[211 387 557];
xmatrix=[52 512 972];                           %calibration dot positions for 1024x768 monitor
ymatrix=[39 386 729];

% order_matrix=[2,1,3,3,1;2,1,1,3,3]; %order of dot presentations
order_matrix=[2,1,3,1,3,1,2,3,2;2,1,1,3,3,2,1,2,3]; %order of dot presentations

n=pause;                                            %flash timing variables
flashrate=200;
time_on=1;
r1=3;                                               %calibration dot sizes
r2=10;

Screen('TextSize',screen_ID,24);
text='Fixate the dots as they appear.';             %directions
width=RectWidth(Screen('TextBounds',screen_ID,text));
Screen('DrawText', screen_ID, text,(1024/2)-width/2,(768/2)-50,[255 255 0]);
text='Press "Space Bar" when you are fixated.';
width=RectWidth(Screen('TextBounds',screen_ID,text));
Screen('DrawText', screen_ID, text,(1024/2)-width/2,(768/2),[255 255 0]);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',screen_ID,text));
Screen('DrawText', screen_ID, text,(1024/2)-width/2,(768/2)+50,[255 255 0]);

Screen('Flip',screen_ID);
disp('Directions Visible');                         %note to experimenter
WaitSecs(1);
KbWait(dev_ID);
WaitSecs(.5);
disp('Calibration Beginning');                       %note to experimenter

[result, ivx]=iViewXComm('open', ivx);              %open connection
[success, ivx]=iViewXComm('send', ivx, 'ET_CLR');   %clear buffer
[success, ivx]=iViewXComm('send', ivx, 'ET_EST');   %datastreamingoff

iViewXComm('send', ivx, 'ET_CAL');                  %start calibration

for i=1:9
    xpoint=xmatrix(order_matrix(1,i));              %set point location
    ypoint=ymatrix(order_matrix(2,i));
    gotit=0;
    while gotit==0                                  %repeat till valid data
        start_time=GetSecs;
        
        while GetSecs<=start_time+time_on;          %flash animation
            
            if n==pause*(flashrate/2)
                Screen('FillOval',screen_ID,[255 255 0],[xpoint-r2,ypoint-r2,...
                    xpoint+r2,ypoint+r2]);
                Screen('FillOval',screen_ID,[0 0 0],[xpoint-r1,ypoint-r1,...
                    xpoint+r1,ypoint+r1]);
                
                Screen('Flip',screen_ID);
            end
            
            if n==pause*flashrate
                Screen('FillOval',screen_ID,[0 0 0],[xpoint-r1,ypoint-r1,...
                    xpoint+r1,ypoint+r1]);
                
                Screen('Flip',screen_ID);
                n=pause;
            end
            n=n+1;
        end
        
        [keyisdown,secs,keycode]=KbCheck(dev_ID);
        while ~keycode(space);                          %stable point, accept with spacebar
            [keyisdown,secs,keycode]=KbCheck(dev_ID);
            
            Screen('FillOval',screen_ID,[255 255 0],[xpoint-r2,ypoint-r2,...
                xpoint+r2,ypoint+r2]);
            Screen('FillOval',screen_ID,[0 0 0],[xpoint-r1,ypoint-r1,...
                xpoint+r1,ypoint+r1]);
            
            Screen('Flip',screen_ID);
        end
        iViewXComm('send', ivx, 'ET_ACC');
        thischeck=1;
        while 1
            [keyisdown,secs,keycode]=KbCheck(con_ID);
            if thischeck==1                                 %experimenter checks if point was valid, move on (right) or go back (left)
                disp('Valid? "Left Arrow" to repeat, "Right Arrow" to advance')
                thischeck=2;
            end
            if keycode(advance)
                gotit=1;
                disp('Moving On')
                break
            elseif keycode(goback);
                disp('Trying Again')
                break
            end
        end
    end
    n=pause;
    WaitSecs(.5);
end
while KbCheck(con_ID); end
[result, ivx]=iViewXComm('close', ivx);   %close the connection
results=1;
[overerror, successful]=EyeTrackerValidate(ivx,acceptable_error,dev_ID,con_ID,screen_ID); %move on to validation