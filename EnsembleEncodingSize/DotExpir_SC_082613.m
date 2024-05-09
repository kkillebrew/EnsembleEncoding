

clear
[w,rect ]=Screen('OpenWindow',0,[0 0 0]);
xc=rect(3)/2; % xc and yc define the screen
yc=rect(4)/2;
r = 12;% radius of the circle moving across the screen
v = 10;% speed of the circle
x = r:v:rect(3)-r;
y = rect(4)/2+600;
n = 10;
space=KbName('space'); % define keys by entering KbDemo into command window, control c to exit
left=KbName('LeftArrow');
right=KbName('RightArrow');
escape=KbName('Escape');
move=1;

for z=1:n;% z is just a variable and records the number of trials by one
    ra=randi(104);
    for jj = 1:12 % number of dots drawn
        r2(jj) = randi(104); % makes each dot its own random
    end
    mean(r2)% this tell us the mean of the random dots actual
    a = [1  1 1 2 2 2  3 3 3 4 4 4]'; % column
    b = [1 2 3 1 2 3  1 2 3 1 2 3]';% rows
    
    for i=1:254;
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        % for stuff you want to always happen put outside of the switch and
        % for all conditions you want it to do that is conditional put
        % inside the switch case
        
        switch move % look at the value ( 1 or 2) and when it equals either one do case one and when it equals 2 do case 2.
            case 1
                Screen('FillOval',w,[255 255 255],[x(i)-r,y-r,x(i)+r,y+r]); % This one is the dot running at the bottom of the screen\
            case 2
                Screen('FillOval',w,[255 255 255],[x(127)-r,y-r,x(127)+r,y+r]);% this makes the dot stay still becasue i no longer equals the length of the screen but the exact location equaling 127
                
        end
        if i>115 && i < 135
            
            Screen('FillOval',w,[0 255 0],[xc-700-49-r2'+((a-1)*400),yc-300-49-r2'+((b-1)*300),xc-700+49+r2'+((a-1)*400),yc-300+49+r2'+((b-1)*300)]');% '= transposing of the matrix
        end
        Screen('Flip',w);
        if keyCode(escape)
            Screen('Close',w);
        end
        
    end
    % The following is for evaluation of the circles presented
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    while ~ keyCode(space); %waits for you to hit space bar to accept adjustment of circle
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        Screen('TextSize',w,40);
        Screen('DrawText',w,'Adujust to the AVERAGE size displayed then press space bar: Left Arrow to increases and Right Arrow to decreases',200, 400 , [0 255 0]);
        %Screen('DrawText',w,'A',750, 1100 , [0 255 0]);
        %Screen('DrawText',w,'OR',1100, 1100 , [0 255 0]);
        %Screen('DrawText',w,'B',1450, 1100 , [0 255 0]);
        if keyCode(left) % decreases circle
            ra=ra-1;
        end
        if keyCode(right)% increases circle
            ra=ra+1;
        end
        if keyCode(escape)
            Screen('Close',w);
        end
        Screen('FillOval',w,[0 255 0],[xc-300-49-ra+(375/2),yc-300-49-ra+(375),xc-300+49+ra+(375/2),yc-300+49+ra+(375)]); % circle initial display is at random size
        
        Screen('Flip',w);
        
    end
    if keyCode(escape)
        Screen('Close',w);
    end
end

Screen('Close',w);




% record the conditions mean max min, define what is being presented and
% what the person responded with.
% randi n- giedeon said to look up
% trail one having the participant adjust their percieved average size (case 1) and
% trial two giving an A or B option (50/50) on the average size
%Also need a stationary trial (move=2/ case 2) so two answer types
%adjustment or A&B