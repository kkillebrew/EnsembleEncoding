clear all
close all

Screen('Preference', 'SkipSyncTests', 1);

%BASIC WINDOW/SCREEN SETUP
% PPD stuff
mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (1024/mon_width_deg);

% Color vars
backColor = [128 128 128];
circColor{1} = [0 0 255];
circColor{2} = [255 128 0];
circOutline = [0 0 0];

[w, rect] = Screen('Openwindow', 0, backColor);
x0 = rect(3)/2;
y0 = rect(4)/2;

% Stim vars
numCircles = 20;
numPlains = 5;    % How many planes will there be per group?
minDist = .15;

% Lists that determine the max size and velocity possible as well as the
% proportions of the size and velocity steps within each group. Distance of the depth plane is
% also listed along with distance steps.
aveRad = [30 40 50 60 70];  
aveVel = [10 15 20 25 30];
depth = [.4 .5 .6 .7 .8];
distStep = [-.1 -.05 0 .05 .1];

HideCursor;
ListenChar(2);

buttonEscape = KbName('escape');
buttonEnter = KbName('return');

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

buffer=1;

[keyIsDown, secs, keycode] = KbCheck;
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck;
    
    % Randomly choose the starting values of the size, velocity, and depth
    %     size(1) = randi(length(aveSize));
    %     size(2) = randi(length(aveSize));
    %     vel(1) =  randi(length(aveVel));
    %     vel(2) = randi(length(aveVel));
    rad(1) = 5;
    rad(2) = 5;
    vel(1) = 3;
    vel(2) = 3;
    dist(1) = randi(length(depth));
    dist(2) = randi(length(depth));
    for m=1:length(rad)
        counter = 0;
        for i = 1:numPlains
            for j = 1:numCircles/numPlains
                counter=counter+1;
                % Calculate the proportional size of each circle based on
                % its depth
                circSizeProp(counter,m) = depth(dist(m))+distStep(i);
                % Calculates the size based on the different proportions of
                % the largest size, calculated based on depth choosen
                circSize(counter,m) = aveRad(rad(m))*circSizeProp(counter,m);  
                circVel(counter,m) = aveVel(vel(m))*(depth(dist(m))+distStep(i));
                circSizeArray{counter,m} = [-circSize(counter,m), -circSize(counter,m), circSize(counter,m), circSize(counter,m)];
                circVelArray{counter,m} = [circVel(counter,m), 0, circVel(counter,m), 0];
            end
        end
    end
    
    % Assign a random location to each of the circles
    for m=1:length(rad)
        for i=1:numCircles

            circLoc{i,m} = [randi(round(x0+(((rect(3)*circSizeProp(i,m))/2))))*((-1)^randi(2)),...
                randi(round(y0+(((rect(4)*circSizeProp(i,m))/2))))*((-1)^randi(2))];
            
            while circLoc{i,m}(1) <= x0-(((rect(3)*circSizeProp(i,m))/2)+circSizeArray{i,m}(1)) ||...
                    circLoc{i,m}(1) >= x0+(((rect(3)*circSizeProp(i,m))/2)-circSizeArray{i,m}(3))
                circLoc{i,m}(1) = randi(round(x0+(((rect(3)*circSizeProp(i,m))/2))))*((-1)^randi(2));
            end
            
            while circLoc{i,m}(2) <= y0-(((rect(4)*circSizeProp(i,m))/2)+circSizeArray{i,m}(2))||...
                    circLoc{i,m}(2) >= y0+(((rect(4)*circSizeProp(i,m))/2)-circSizeArray{i,m}(4))
                circLoc{i,m}(2) = randi(round(y0+(((rect(4)*circSizeProp(i,m))/2))))*((-1)^randi(2));
            end
            
            circLoc{i,m} = [circLoc{i,m},circLoc{i,m}];
            
            LArray{i,m} = [circLoc{i,m}(1), y0+(y0*circSizeProp(i,m)), circLoc{i,m}(1), circLoc{i,m}(2)];
            
        end
    end
    
    % Must draw the smaller circles behind the big circles no matter
    % what group they are a part of. To do this go through each size
    % array and create a new numCirc*2 x 2 array in the order of the
    % smallest to biggest sizes
    counter = 0;
    for m=1:length(rad)
        for i=1:numCircles
            counter = counter+1;
            % Size of radius of each circle
            combArray(counter,1) = circSizeArray{i,m}(3);
            % Which group the circle is part of
            combArray(counter,2) = m;
            % Which circle within each group
            combArray(counter,3) = i;
            % Proportion of the size of each circle based on its depth
            combArray(counter,4) = circSizeProp(i,m);  
        end
    end
    [y,u] = sort(combArray(:,4));
    combArray = combArray(u,:);
    
    while ~keycode(buttonEnter)
        [keyIsDown, secs, keycode] = KbCheck;
        
        % 2560x1440
        Screen('FrameRect', w, circOutline, [x0-(rect(3)/2)*minDist,...
            y0-(rect(4)/2)*minDist,...
            x0+(rect(3)/2)*minDist,...
            y0+(rect(4)/2)*minDist], 5);
        Screen('DrawLine', w, circOutline, x0-(rect(3)/2)*minDist+2,...
            y0-(rect(4)/2)*minDist+2,0,0,5)
        Screen('DrawLine', w, circOutline, x0-(rect(3)/2)*minDist+2,...
            y0+(rect(4)/2)*minDist-2,0,rect(4),5)
        Screen('DrawLine', w, circOutline, x0+(rect(3)/2)*minDist-2,...
            y0-(rect(4)/2)*minDist+2,rect(3),0,5)
        Screen('DrawLine', w, circOutline, x0+(rect(3)/2)*minDist-2,...
            y0+(rect(4)/2)*minDist-2,rect(3),rect(4),5)
        
        for m=1:size(combArray,1)
            

%             Screen('FrameRect', w, circOutline, [x0-(rect(3)/2)*combArray(m,4),...
%                 y0-(rect(4)/2)*combArray(m,4),...
%                 x0+(rect(3)/2)*combArray(m,4),...
%                 y0+(rect(4)/2)*combArray(m,4)], 1);
            
%             Screen('DrawLine', w, [0 0 0], LArray{combArray(m,3),combArray(m,2)}(1),...
%                 LArray{combArray(m,3),combArray(m,2)}(2),...
%                 LArray{combArray(m,3),combArray(m,2)}(3),...
%                 LArray{combArray(m,3),combArray(m,2)}(4),5);
            
            Screen('FillOval', w, [50 50 50], [circLoc{combArray(m,3),combArray(m,2)}(1)+circSizeArray{combArray(m,3), combArray(m,2)}(1),...
                LArray{combArray(m,3),combArray(m,2)}(2)-(.25*combArray(m,1)),...
                circLoc{combArray(m,3),combArray(m,2)}(3)+circSizeArray{combArray(m,3), combArray(m,2)}(3),...
                LArray{combArray(m,3),combArray(m,2)}(2)])

            Screen('FillOval', w, circColor{combArray(m,2)},...
                circLoc{combArray(m,3),combArray(m,2)}+circSizeArray{combArray(m,3), combArray(m,2)});
            Screen('FrameOval', w, circOutline,...
                circLoc{combArray(m,3),combArray(m,2)}+circSizeArray{combArray(m,3),combArray(m,2)});
          
            circLoc{combArray(m,3),combArray(m,2)} = circLoc{combArray(m,3),combArray(m,2)} +...
                circVelArray{combArray(m,3),combArray(m,2)};
            
            % If the edge of any of the circles reaches the edge of the
            % screen in either direction, change the direction of motion
            if circLoc{combArray(m,3),combArray(m,2)}(1)+circSizeArray{combArray(m,3),combArray(m,2)}(1) <= x0-(x0*combArray(m,4)) ||...
                    circLoc{combArray(m,3),combArray(m,2)}(3)+circSizeArray{combArray(m,3),combArray(m,2)}(3) >= x0+(x0*combArray(m,4))
                
                circVelArray{combArray(m,3),combArray(m,2)} = circVelArray{combArray(m,3),combArray(m,2)}.*(-1);
                
            end
        end

        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        
        Screen('Flip',w);
    end
end

ShowCursor;
ListenChar(0);
Screen('CloseAll')

