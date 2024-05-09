% 021617 - This code plots the different ensemble types for dissertation.
% Taking into account number of individuals, individual size,
% inter-stimulus distance, and total surface area. Stimuli design based on
% Piazza et. al. 2004.
%
% Piazza et. al. 2004 - 'Stimuli were designed so that, aside from the
% number change, all deviant stimuli were equally novel with respect to all
% physical parameters.'

%% Initilization variables

% clear workspace and close open matlab windown
clear all
close all

rng('shuffle')

labComp = 1;
eegComp = 0;
netStation = 0;
DAQtimingTester = 0;

% Inputs
% buttonO = KbName('o');
% buttonN = KbName('n');
buttonEscape = KbName('escape');
buttonSpace = KbName('space');
buttonJ = KbName('j');
buttonF = KbName('f');

%Give subject breaks
% break_trials = .1:.1:.9;    % list of proportion of total trials at which to offer subject a self-timed break

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'Ens_FFTOddball_SingleStream_3Hz';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
if eegComp == 1
    datadir = '/Users/gideon/Documents/Kyle/R15 Distractor/Data/';
elseif labComp == 1
    datadir = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Data/';
end

datafile=sprintf('%s_%s_%s_%03d',subjid,experiment,datecode,runid);
datafile_full=sprintf('%s_full',datafile);

% check to see if this file exists
if exist(fullfile(datadir,[datafile '.mat']),'file')
    tmpfile = input('File exists.  Overwrite? y/n:','s');
    while ~ismember(tmpfile,{'n' 'y'})
        tmpfile = input('Invalid choice. File exists.  Overwrite? y/n:','s');
    end
    if strcmp(tmpfile,'n')
        display('Bye-bye...');
        return; % will need to start over for new input
    end
end

HideCursor;
ListenChar(2);

if labComp == 1
    Screen('Preference', 'SkipSyncTests', 1);
end

%% Setup  variables
if netStation == 1
    %%%%%%%
    %Netstation communication params
    NS_host = '169.254.180.49'; % ip address of NetStation host computer % *** NEEDS TO BE UPDATED!!!
    NS_port = 55513; % the ethernet port to be used (Default is 55513 for NetStation.m)
    %NS_synclimit = 0.9; % the maximum allowed difference in milliseconds between PTB and NetStation computer clocks (.m default is 2.5)
    
    
    % Detect and initialize the DAQ for ttl pulses
    d=PsychHID('Devices');
    numDevices=length(d);
    trigDevice=[];
    dev=1;
    while isempty(trigDevice)
        if d(dev).vendorID==2523 && d(dev).productID==130 %if this is the first trigger device
            trigDevice=dev;
            %if you DO have the USB to the TTL pulse trigger attached
            disp('Found the trigger.');
        elseif dev==numDevices
            %if you do NOT have the USB to the TTL pulse trigger attached
            disp('Warning: trigger not found.');
            disp('Check out the USB devices by typing d=PsychHID(''Devices'').');
            break;
        end
        dev=dev+1;
    end
    %   trigDevice=4; %if this doesn't work, try 4
    %Set port B to output, then make sure it's off
    DaqDConfigPort(trigDevice,0,0);
    DaqDOut(trigDevice,0,0);
    TTL_pulse_dur = 0.005; % duration of TTL pulse to account for ahardware lag
end

%BASIC WINDOW/SCREEN SETUP
% PPD stuff
if labComp == 1
    mon_width_cm = 53;
    mon_dist_cm = 73;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (1024/mon_width_deg);
elseif eegComp == 1
    mon_width_cm = 40;
    mon_dist_cm = 73;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (1024/mon_width_deg);
end

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_id=nums(1);

screenWide=1024;
screenHigh=768;

%Get information about the current screen properties, and what to return
%the screen to after the experiment.
oldScreen=Screen('Resolution',0);

% Set the Screen resolution and refresh rate to the values appropriate for
% your experiment;
if labComp == 1
    hz = 85;
elseif eegComp == 1
    hz = 120;
    Screen('Resolution',screenNum,screenWide,screenHigh,hz);
end

% [w, rect] = Screen('Openwindow', w, [128 128 128],[0 0 screenWide screenHigh]);
[w, rect] = Screen('Openwindow', 1, [128 128 128],[],[],[],[],[8]);
% coordinates of screen center
xc = rect(3)/2;
yc = rect(4)/2;
%centers ul_c
corner_centers(1,:)= [xc-xc/2;...
    yc-yc/2;...
    xc-xc/2;...
    yc-yc/2];
%ur_c
corner_centers(2,:)= [xc+xc/2;...
    yc-yc/2;...
    xc+xc/2;...
    yc-yc/2];
%ll_c
corner_centers(3,:)= [xc-xc/2;...
    yc+yc/2;...
    xc-xc/2;...
    yc+yc/2];
%lr_c
corner_centers(4,:)= [xc+xc/2;...
    yc+yc/2;...
    xc+xc/2;...
    yc+yc/2];

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

%% Trial variables
orientationList = [1 2 3];
nOri = length(orientationList);
sizeList = [1 2 3];
nSize = length(sizeList);
taskList = [1 2];
nTask = length(taskList);

% Make lists
repetitions = 2;   % Number of repetitions per block
nBlocks = 5;   % Number of different blocks

for i=1:nBlocks
    varList(i,:,:) = repmat(fullfact([nOri nSize nTask]),[repetitions,1]);   % Get all combinations of conditions
    presOrder = randperm(length(varList));   % Randomize the order of presentation
    varList(i,:,:) = varList(i,presOrder,:);
end

trialOrder = squeeze([varList(1,:,:) varList(2,:,:) varList(3,:,:) varList(4,:,:) varList(5,:,:)]);

numItemsList = [1 2 3];
nItems = length(numItemsList);

% Randomly determine which stim gets which rate for each trial
chosenStimRate = repmat(fullfact([2]),[length(trialOrder)/2,1]);
chosenStimRate = chosenStimRate(randperm(length(chosenStimRate)));

% Randomly determine which direction each stimuli will go on each trial.
deltaDirectionSizeList = repmat(fullfact([2]),[length(trialOrder)/2,1]);
deltaDirectionSizeList = deltaDirectionSizeList(randperm(length(deltaDirectionSizeList)));
deltaDirectionOriList = repmat(fullfact([2]),[length(trialOrder)/2,1]);
deltaDirectionOriList = deltaDirectionOriList(randperm(length(deltaDirectionOriList)));

%% Stimulus variables

% Give participants a break in between blocks
break_trials = 37:36:length(trialOrder);   % Each block contains 36 trials, so after every 36th trial give the participants a break. Only 

% Amount of jitter
jitterAmount = 10;

% Size of one cell
cellSize = rect(4)/8;

% Create the stimulus variables for orientation and size
% The maximum size of the largest circle should not allow the ellipse to
% move oustide of it cell. In DoVA
standardSize = 2.5;
standardOri = 270;

% sizeVariance = .5;
sizeVariance = .5;
sizeList = [0 .75 1.5];   % +/- standard
% oriVariance = 15;
oriVariance = 5;
oriList = [0 30 60];

deltaDirectionSize = 1;
deltaDirectionOri = 1;

% Timing variables
totalTrialTime = 10;

%Flicker Frequency Rates (3 Hz, .5 Hz, .3 Hz)
stim_rate(1) = 3;
stim_rate(2) = .5;
stim_rate(3) = .3;

StimPres(1) = totalTrialTime*stim_rate(1);
StimPres(2) = totalTrialTime*stim_rate(2);
StimPres(3) = totalTrialTime*stim_rate(3);

numItemArray = [48 52 56];   % Number of items present

% Calculate the coordinates to make the grid lines. Make 4 separate grids for each quadrant, separated by 1 dova in the hor and vert meridians.
quadSpacingArray = [rect(2),(rect(4)-PPD)/2,(xc-PPD/2)-(((rect(4)-PPD)/2)-rect(2)),xc-PPD/2;...    % quad 1; y min, y max, x min, xmax
    rect(2),(rect(4)-PPD)/2,xc+PPD/2,(xc+PPD/2)+(((rect(4)-PPD)/2)-rect(2));...
    rect(4)-(rect(4)-PPD)/2,rect(4),xc+PPD/2,(xc+PPD/2)+(((rect(4)-PPD)/2)-rect(2));...
    rect(4)-(rect(4)-PPD)/2,rect(4),(xc-PPD/2)-(((rect(4)-PPD)/2)-rect(2)),xc-PPD/2];
for i=1:4
    
    yLineCoords = linspace(quadSpacingArray(i,1),quadSpacingArray(i,2),5);
    xLineCoords = linspace(quadSpacingArray(i,3),quadSpacingArray(i,4),5);
    
    vertCoordsTemp1 = [xLineCoords; repmat(yLineCoords(1),[1,length(yLineCoords)])];
    vertCoordsTemp2 = [xLineCoords; repmat(yLineCoords(end),[1,length(yLineCoords)])];
    vertCoords(:,:,i) = vertCoordsTemp2(:,[1;1]*(1:size(vertCoordsTemp2,2)));
    vertCoords(:,1:2:end,i) = vertCoordsTemp1;
    
    horzCoordsTemp1 = [repmat(xLineCoords(1),[1,length(xLineCoords)]); yLineCoords];
    horzCoordsTemp2 = [repmat(xLineCoords(end),[1,length(xLineCoords)]); yLineCoords];
    horzCoords(:,:,i) = horzCoordsTemp2(:,[1;1]*(1:size(horzCoordsTemp2,2)));
    horzCoords(:,1:2:end,i) = horzCoordsTemp1;
    
    % Create a cell array w/ center point coords of each block in the grid;
    % should be 16x2x4; 16 cells in each quad, x/y coords, 4 quads
    counter = 1;
    for n=1:2:(length(horzCoords(:,:,i))-2)
        for m=1:2:(length(vertCoords(:,:,i))-2)
            blockCenterCoords(counter,1,i) = mean([vertCoords(1,m+2,i) vertCoords(1,m,i)]);
            blockCenterCoords(counter,2,i) = mean([horzCoords(2,n+2,i) horzCoords(2,n,i)]);
            
            counter = counter+1;
        end
    end
    
end

% Blank screen texture
blank_tex = Screen('MakeTexture',w,128*ones(1,1));

% Fixation Texture
fix_size = 5;   % Fixaiton size (in pixels)
fix_rect =[xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];
fix_tex = Screen('MakeTexture',w,0*ones(1,1));

% For photdiode timing testing
if DAQtimingTester == 1
    photo_tex = Screen('MakeTexture',w,255*ones(1,1));
    photo_rect=[xc-50,yc-50,xc+50,yc+50];
else
    photo_tex = Screen('MakeTexture',w,0*ones(1,1));
    photo_rect = [xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];
end

% Taking screen shots
imageArray=[];

% Connect to NetStation
if netStation == 1
    NetStation('Connect', NS_host, NS_port)
    % NetStation('Synchronize', NS_synclimit)
    NetStation('StartRecording');
end

% Instructions
text='These are instructions.' ;
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,xc-width/2,yc-50,[0 0 0]);

Screen('Flip',w);
KbWait(dev_id);
KbReleaseWait(dev_id);

% Wait for the data to normalize
if netStation == 1
    Screen('Flip',w);
    WaitSecs(10);
end

%% Draw stimulus
[keyisdown, secs, keycode] = KbCheck(dev_id);
% while ~keycode(buttonEscape)
for n=1:length(trialOrder)
    [keyisdown, secs, keycode] = KbCheck(dev_id);

    clear ellipseCoords ellipseSize ellipseOri oriIdx sizeIdx taskResponseHolder ellipseTexture
    
    % Determine the delta to be used for size and orientation
    sizeIdx = trialOrder(n,1);
    rawdata(n,1) = sizeIdx;
    oriIdx = trialOrder(n,2);
    rawdata(n,2) = oriIdx;
    taskIdx = trialOrder(n,3);
    rawdata(n,3) = taskIdx;
    
    % Set up breaks in between blocks
    this_b = 0;
    for b = break_trials
        if n == round(b*length(trialOrder))
            this_b = b;
            break
        end
    end
    if this_b
        % display break message
        text='Please take a break. Feel free to blink or move your eyes.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,xc-width/2,yc,[255 255 255]);
        text='Please do not make any unnecessary movements. ';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,xc-width/2,yc+50,[255 255 255]);
        Screen('Flip',w);
        WaitSecs(1);
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        if keycode(button1)
           break 
        end
    end
    
    % Calculate the times need to change the stimuli
    rate=1/(2*stim_rate(1));
    
    % Determine how many different stimulus presentations you will do to
    % preallocate the stimulus sizes.
    baselineStimPres = StimPres(1);   % Baseline rate
    if chosenStimRate(n) == 1
        sizeStimPres = StimPres(2);
        oriStimPres = StimPres(3);
    elseif chosenStimRate(n) == 2
        sizeStimPres = StimPres(3);
        oriStimPres = StimPres(2);
    end
    
    sizeCount=0;
    oriCount=0;
    
    % Task Instructions
    if taskIdx == 1   % Size task
        text1='Please pay attention to the average SIZE of the group.';
        text2='You will be asked about any changes you may have seen at the end of the trial.';
        text3='Get ready for the next trial...' ;
    elseif taskIdx == 2
        text1='Please pay attention to  the average ORIENTATION of the group.';
        text2='You will be asked about any changes you may have seen at the end of the trial.';
        text3='Get ready for the next trial...' ;
    end
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-150,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text3));
    Screen('DrawText',w,text3,xc-width/2,yc+50,[0 0 0]);
    Screen('Flip',w);
    WaitSecs(2);
    
    % Preallocate regular stim presentations
    for i=1:baselineStimPres
        
        % Check to see if this presentation is a condition change
        sizeCount=sizeCount+1;   % Check to see if this is a size change trial and update the size index value
        oriCount=oriCount+1;   % Check to see if this is a size change trial and update the size index value
        if rem(oriCount,oriStimPres) == 0 && rem(sizeCount,sizeStimPres) == 0
            sizeIdx(i) = trialOrder(n,1);
            oriIdx(i) = trialOrder(n,2);
        elseif rem(oriCount,oriStimPres) == 0
            sizeIdx(i) = 1;
            oriIdx(i) = trialOrder(n,2);
        elseif rem(sizeCount,sizeStimPres) == 0
            sizeIdx(i) = trialOrder(n,1);
            oriIdx(i) = 1;
        else
            sizeIdx(i) = 1;
            oriIdx(i) = 1;
        end
        
        % Which direction from standard are you presenting the stimuli
        if deltaDirectionSizeList(n) == 1
            deltaDirectionSize = 1;
        elseif deltaDirectionSizeList(n) == 2
            deltaDirectionSize = -1;
        end
        if deltaDirectionOriList(n) == 1
            deltaDirectionOri = 1;
        elseif deltaDirectionOriList(n) == 2
            deltaDirectionOri = -1;
        end
                
        % Determine how many items you will show for this stim pres
        itemsIdx = randi(3);
        
        % Determine the number of items that will be presented based on numItems.
        currentNumItems = numItemArray(itemsIdx);
        numItemsPerQuad = floor(currentNumItems/4);
        
        % Distribute the items evenly throughout each qadrant. Randomly choose a
        % quadrant to start in and randomly chose a cell to place the item in,
        % then move around the grid chosing cells in each quadrant until there
        % are no more items.
        clear quadPosition
        quadPosition(1,:) = datasample(1:15, numItemsPerQuad, 'Replace', false);
        quadPosition(2,:) = datasample([1:12,14:15], numItemsPerQuad, 'Replace', false);
        quadPosition(3,:) = datasample(2:15, numItemsPerQuad, 'Replace', false);
        quadPosition(4,:) = datasample([1:3,5:15], numItemsPerQuad, 'Replace', false);   
               
        % Determine orientation
        clear ellipseOriHolder
        ellipseOriHolder=randn(4,numItemsPerQuad);
        ellipseOriHolder=ellipseOriHolder-mean(ellipseOriHolder);
        ellipseOriHolder=ellipseOriHolder./(std(ellipseOriHolder));
        ellipseOriHolder=ellipseOriHolder.*oriVariance;
        ellipseOriHolder=ellipseOriHolder+((standardOri+(oriList(oriIdx(i)))*deltaDirectionOri));
        ellipseOri{i}=reshape(ellipseOriHolder',[1,currentNumItems]);
        
        % Determine size
        clear ellipseSizeHolder
        ellipseSizeHolder=randn(4,numItemsPerQuad);
        ellipseSizeHolder=ellipseSizeHolder-mean(ellipseSizeHolder);
        ellipseSizeHolder=ellipseSizeHolder./(std(ellipseSizeHolder));
        ellipseSizeHolder=ellipseSizeHolder.*sizeVariance*PPD  ;
        ellipseSize{i}=ellipseSizeHolder+((standardSize+(sizeList(sizeIdx(i))*deltaDirectionSize))*PPD);
        
        
        % Add in positional jitter for x and y directions
        xJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
        yJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
        
        xSize = round(ellipseSize{i}./2);
        ySize = round(xSize/2);
        
        % Create the coords for the ellipses
        ellipseCoords{i} = [[blockCenterCoords(quadPosition(1,:),1,1); blockCenterCoords(quadPosition(2,:),1,2); blockCenterCoords(quadPosition(3,:),1,3); blockCenterCoords(quadPosition(4,:),1,4)]' - [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)] + [xJitter(1,:) xJitter(2,:) xJitter(3,:) xJitter(4,:)];...
            [blockCenterCoords(quadPosition(1,:),2,1); blockCenterCoords(quadPosition(2,:),2,2); blockCenterCoords(quadPosition(3,:),2,3); blockCenterCoords(quadPosition(4,:),2,4)]' - [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)] + [yJitter(1,:) yJitter(2,:) yJitter(3,:) yJitter(4,:)];...
            [blockCenterCoords(quadPosition(1,:),1,1); blockCenterCoords(quadPosition(2,:),1,2); blockCenterCoords(quadPosition(3,:),1,3); blockCenterCoords(quadPosition(4,:),1,4)]' + [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)] + [xJitter(1,:) xJitter(2,:) xJitter(3,:) xJitter(4,:)];...
            [blockCenterCoords(quadPosition(1,:),2,1); blockCenterCoords(quadPosition(2,:),2,2); blockCenterCoords(quadPosition(3,:),2,3); blockCenterCoords(quadPosition(4,:),2,4)]' + [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)] + [yJitter(1,:) yJitter(2,:) yJitter(3,:) yJitter(4,:)]];
        
        counter=1;
        xSizeVector = [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)];
        ySizeVector = [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)];
        for k=1:length(ellipseCoords{i})
            
            % Create a single texture ellipse using the xSize/YSize that can be
            % individually rotated
            ellipseTexture{i}(k) = Screen('MakeTexture', w, zeros([xSizeVector(counter)*4 ySizeVector(counter)*4]) + 128);
            
            % Draw all the circles onto the texture
            Screen('FrameOval',ellipseTexture{i}(k),[0 0 0],[],5);
%             Screen('FrameRect',ellipseTexture{i}(k),[0 0 0],[],5);
            
            counter = counter+1;
            
        end
        
    end
    
    % Variable that determines whether or not a screen flip is
    % necessary
    check = 0;
    stimPresCounter=0;
    taskResponseCounter = 1;
    
    % Sets which phase of flicker the image is in.
    flip1 = 1;
    
    % Making sure that the computer assigns all of its priority to
    % Matlab in order to maximize timing accuracy
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    sync_time= Screen('Flip',w,[],2);
    
    % Send the TTL pulse
    if netStation == 1
        DaqDOut(trigDevice,0,2)
        WaitSecs(TTL_pulse_dur);
        DaqDOut(trigDevice,0,0)
    end
    
    run_start=Screen('Flip',w,sync_time,2);
    
    % Determine slip for each of the stimuli
    t1 = run_start;
    
    while 1

        % While the total time is less than time elapsed keep looping
        time_now = GetSecs;
        trial_check = (time_now - run_start) > totalTrialTime;
        
        % While the time elapsed is less than the time of the total
        % trial keep checking for flip times
        switch trial_check
            case 0
                
                % Determines based on individual stimulus frequencies
                % whether or not a screen flip is necessary
                rate1_check = (time_now - t1) > rate-1/hz;

                switch rate1_check
                    case 1
                        flip1 =  3-flip1;
                        t1=t1+rate;
                        check =1;
                    otherwise
                end
                
                %Update changes on the screen

                switch check
                    
                    case 1   % Draw the stimuli
                        switch flip1
                            case 1
                                % Draw the textures w/ the ellipses in them and rotate
                                stimPresCounter = stimPresCounter+1;
                                
                                Screen('DrawTextures',w,ellipseTexture{stimPresCounter},[],ellipseCoords{stimPresCounter},ellipseOri{stimPresCounter});
                                Screen('DrawTexture',w,fix_tex,[],fix_rect);
                                                                
                                Screen('DrawingFinished',w,2);
                                
%                                 % Dispay which condition is being presented
%                                 text=sprintf('%s%d%s%d%s%d','Size: ',sizeIdx(stimPresCounter), '   Ori: ',oriIdx(stimPresCounter),'   StimPres: ',stimPresCounter);
%                                 Screen('DrawText',w,text,10,10,[0 0 0]);
%                                 text=sprintf('%s%d%s%d','SizeStimPres: ',sizeStimPres,'   OriStimPres: ',oriStimPres);
%                                 Screen('DrawText',w,text,10,40,[0 0 0]);
                                
                                Screen('Flip',w,time_now,2);

                            case 2
                                
                                % Blank screen
                                Screen('DrawTexture',w,blank_tex,[],rect);
                                Screen('DrawTexture',w,fix_tex,[],fix_rect);
                                
                                Screen('DrawingFinished',w,2);
                                
                                Screen('Flip',w,time_now,2);
                        end
                        
                        check=0;
                    case 0
                        WaitSecs(.0005);
                        
                end
                     
            case 1   % If total time has been reached break out of the loop
                break
        end
    end
    
    % Return priority settings to normal
    Priority(0);
        
    % Blank screen
    Screen('DrawTexture',w,blank_tex,[],rect);
    Screen('Flip',w);
    
    % Task question
    if taskIdx == 1   % Size task
        text1='Did you notice a change in the mean size?';
        text2='If you did, press ''F''. If you did not, press ''J''';
    elseif taskIdx == 2
        text1='Did you notice a change in the mean orientation?';
        text2='If you did, press ''F''. If you did not, press ''J''';
    end
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc+50,[0 0 0]);
    Screen('Flip',w);
    
    while 1
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        if keycode(buttonF)
            rawdata(n,4) = 1;
            break
        elseif keycode(buttonJ)
            rawdata(n,4) = 2;
            break
        end
    end
    
    % Did they get it correct
    if rawdata(n,3) == 1   % is it a size trial
        if rawdata(n,4)==1    % They said it was a change in size
            if rawdata(n,1) > 1   % It was a change in size
                rawdata(n,5) = 1;   % Correct
            elseif rawdata(n,1) == 1   % It wasn't a change in size
                rawdata(n,5) = 0;   % Inorrect
            end
        elseif rawdata(n,4)==2    % They said it wasn't a change in size
            if rawdata(n,1) > 1   % It was a change in size
                rawdata(n,5) = 0;   % Inorrect
            elseif rawdata(n,1) == 1   % It wasn't a change in size
                rawdata(n,5) = 1;   % Correct
            end
        end
    elseif rawdata(n,3) == 2   % ori trial
        if rawdata(n,4)==1    % They said it was a change in ori
            if rawdata(n,2) > 1   % It was a change in ori
                rawdata(n,5) = 1;   % Correct
            elseif rawdata(n,2) == 1   % It wasn't a change in ori
                rawdata(n,5) = 0;   % Inorrect
            end
        elseif rawdata(n,4)==2    % They said it wasn't a change in ori
            if rawdata(n,2) > 1   % It was a change in ori
                rawdata(n,5) = 0;   % Inorrect
            elseif rawdata(n,2) == 1   % It wasn't a change in ori
                rawdata(n,5) = 1;   % Correct
            end
        end
    end
    
    % Give feedback
    if rawdata(n,5) == 1
        text1='Correct';
    elseif rawdata(n,5) == 0
        text1 = 'Incorrect';
    end

    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
    Screen('Flip',w);
    WaitSecs(1);
    
end


Screen('CloseAll');
ListenChar(0);

