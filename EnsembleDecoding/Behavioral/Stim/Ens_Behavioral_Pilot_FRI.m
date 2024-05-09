
%% Initilization variables

% clear workspace and close open matlab windown
clear all
close all

rng('shuffle')

labComp = 1;
lapComp = 0;
presComp = 0;

% Inputs
buttonEscape = KbName('escape');
buttonSpace = KbName('space');
buttonJ = KbName('j');
buttonF = KbName('f');

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'Ens_Behavioral';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
if presComp == 1
    datadir = '/Users/gideon 3/Desktop/Kyle/Dissertation Stuff/Experiments/Behavioral/Data/';
elseif labComp == 1
    datadir = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Data/';
elseif lapComp == 1
    datadir = '/Users/C-Lab/Desktop/Diss Stuff/';
end

datafile=sprintf('%s_%s_%s_%03d',subjid,experiment,runid);
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

if labComp == 1 || lapComp == 1
    Screen('Preference', 'SkipSyncTests', 1);
end

%% Setup  variables
%BASIC WINDOW/SCREEN SETUP
% PPD stuff
if labComp == 1
    mon_width_cm = 53;
    mon_dist_cm = 73;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (1024/mon_width_deg);
elseif lapComp == 1
    mon_width_cm = 43;
    mon_dist_cm = 73;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (1024/mon_width_deg);
elseif presComp == 1
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
    screenNum = 1;
elseif lapComp == 1
    hz = 85;
    screenNum = 0;
elseif presComp == 1
    hz = 120;
    screenNum = 1;
    Screen('Resolution',screenNum,screenWide,screenHigh,hz);
end

% [w, rect] = Screen('Openwindow', w, [128 128 128],[0 0 screenWide screenHigh]);
[w, rect] = Screen('Openwindow', screenNum, [128 128 128],[],[],[],[],100);
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

%% Practice
rawdataPractice = Ens_Behav_Practice(rect,w,buttonF,buttonJ,xc,yc,PPD,dev_id);

%% Trial variables
orientationList = [1 2 3 4 5];
nOri = length(orientationList);
sizeList = [1 2 3 4 5];
nSize = length(sizeList);
taskList = [1 2];
nTask = length(taskList);

% Make lists
repetitions = 2;   % Number of repetitions per block
nBlocks = 2;   % Number of different blocks

% Ensure that an equal number of trials are present where the test is
% larger/more dense than reference and vice versa.
numItemsList = [1 2];
nItems = length(numItemsList);

for i=1:nTask
    for j=1:nBlocks
        varList(:,:,i,j) = repmat(fullfact([nOri nSize]),[repetitions,1]);   % Get all combinations of conditions
        presOrder = randperm(size(varList,1));   % Randomize the order of presentation
        varList(:,:,i,j) = varList(presOrder,:,i,j);
    end
end

% Randomly select which task comes first
taskSelect = randi(2);   % 1=ori, 2=size
trialOrder = [varList(:,:,taskSelect,1); varList(:,:,3-taskSelect,1); varList(:,:,taskSelect,2); varList(:,:,3-taskSelect,2)];
trialOrder(:,3) = repmat([zeros(50,1)+taskSelect; zeros(50,1)+(3-taskSelect)],[2,1]);

% For each stim combo for each task for each block assign randomly 1 or 2
% for test/ref more/less items
numItemsVarList = zeros(50,4);
for i=1:nOri
    for j=1:nSize
        numItemsRandomizer = numItemsList;
        numItemsIdx = randperm(size(numItemsRandomizer,2));
        numItemsRandomizer = numItemsRandomizer(numItemsIdx);        
        numItemsVarList(trialOrder(1:50,1)==i & trialOrder(1:50,2)==j,1) = numItemsRandomizer;
        
        numItemsRandomizer = numItemsList;
        numItemsIdx = randperm(size(numItemsRandomizer,2));
        numItemsRandomizer = numItemsRandomizer(numItemsIdx);       
        numItemsVarList(trialOrder(51:100,1)==i & trialOrder(51:100,2)==j,2) = randperm(2);
        
        numItemsRandomizer = numItemsList;
        numItemsIdx = randperm(size(numItemsRandomizer,2));
        numItemsRandomizer = numItemsRandomizer(numItemsIdx);       
        numItemsVarList(trialOrder(101:150,1)==i & trialOrder(101:150,2)==j,3) = randperm(2);
        
        numItemsRandomizer = numItemsList;
        numItemsIdx = randperm(size(numItemsRandomizer,2));
        numItemsRandomizer = numItemsRandomizer(numItemsIdx);       
        numItemsVarList(trialOrder(151:200,1)==i & trialOrder(151:200,2)==j,4) = randperm(2);
    end
end
trialOrder(:,4) = [numItemsVarList(:,1); numItemsVarList(:,2); numItemsVarList(:,3); numItemsVarList(:,4)];


%% Stimulus variables

% Give participants a break in between blocks
break_trials = 51:50:length(trialOrder);   % Each block contains 50 trials, so after every 50th trial give the participants a break. Only
instructionCounter = 1:50:length(trialOrder);   % Determine when to present task instructions

% Amount of jitter
jitterAmount = 10;

% Size of one cell
cellSize = rect(4)/8;

% Timing vars
stimTime = .3; % 300 ms
fixTime = .5; % 500 ms

% Create the stimulus variables for orientation and size
% The maximum size of the largest circle should not allow the ellipse to
% move oustide of it cell. In DoVA
standardSize = 1.25;
standardOri = 270;

% sizeVariance = .5;
sizeVariance = .25;
sizeList = [0 .1 .25 .5 1];
% oriVariance = 15;
oriVariance = 10;
oriList = [0 10 25 45 90];

numItemArray = [36 44];   % Number of items present

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

%% Start experiment
[keyisdown, secs, keycode] = KbCheck(dev_id);
% while ~keycode(buttonEscape)
for n=1:length(trialOrder)
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    
    clear ellipseCoords ellipseSize ellipseOri taskResponseHolder ellipseTexture
    
    % Determine the delta to be used for size and orientation.
    oriIdx = trialOrder(n,1);
    rawdata(n,1) = oriIdx;
    sizeIdx = trialOrder(n,2);
    rawdata(n,2) = sizeIdx;
    taskIdx = trialOrder(n,3);   % 1=ori, 2=size
    rawdata(n,3) = taskIdx;
    densityIdx = trialOrder(n,4);   % 1=test more items, 2=ref more items
    rawdata(n,4) = densityIdx;
     
    % Set up breaks in between blocks
    this_b = 0;
    for b = break_trials
        if n == b
            this_b = b;
            break
        end
    end
    if this_b
        % display break message
        text='Please take a break. Feel free to blink or move your eyes.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,xc-width/2,yc,[0 0 0]);
        text='Please do not make any unnecessary movements.';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,xc-width/2,yc+50,[0 0 0]);
        Screen('Flip',w);
        WaitSecs(1);
        while 1
            [keyisdown, secs, keycode] = KbCheck(dev_id);
            if keyisdown
                break;
            end
        end
    end
    
    % Present task instructions at the beginning of each block
    for b = instructionCounter
        if n == b
            if taskIdx == 1   % Ori task
                text1='You will be shown 2 groups of ellipses sequentially.';
                text2='Each group will have an average orientation and size.';
                text3='For the next few trials, please pay attention to the average ORIENTATION of the group.';
                text4='If the first groups orientation was more rightward leaning, press ''F''.';
                text5='If the second groups orientation was more rightward leaning, press ''J''.';
                text6='Press any key when you are ready to start...' ;
            elseif taskIdx == 2   % Size task
                text1='You will be shown 2 groups of ellipses sequentially.';
                text2='Each group will have an average orientation and size';
                text3='For the next few trials, please pay attention to the average SIZE of the group.';
                text4='If the first groups orientation was more larger, press ''F''.';
                text5='If the second groups orientation was more larger, press ''J''.';
                text6='Press any key when you are ready to start...' ;
            end
            width=RectWidth(Screen('TextBounds',w,text1));
            Screen('DrawText',w,text1,xc-width/2,yc-350,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text2));
            Screen('DrawText',w,text2,xc-width/2,yc-250,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text3));
            Screen('DrawText',w,text3,xc-width/2,yc-150,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text4));
            Screen('DrawText',w,text4,xc-width/2,yc-50,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text5));
            Screen('DrawText',w,text5,xc-width/2,yc+50,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text6));
            Screen('DrawText',w,text6,xc-width/2,yc+150,[0 0 0]);
            Screen('Flip',w);
            while 1
                [keyisdown, secs, keycode] = KbCheck(dev_id);
                if keyisdown
                    break;
                end
            end
            Screen('Flip',w);
            WaitSecs(2);
        end
    end
    
    % Preallocate stim presentations before each trial
    % Determine which will come first test or ref
    stimOrder = randperm(2);   % 1=test, 2=ref
    rawdata(n,[5,6]) = stimOrder;
    for i=stimOrder   % Test and ref
        
        % Determine the number of items that will be presented based on
        % what is being preallocated test or ref.
        if (i == 1 && densityIdx == 1) || (i == 2 && densityIdx == 2)  % if more items (densityIdx = 1)
            currentNumItems = numItemArray(2);
        elseif (i == 1 && densityIdx == 2) || (i == 2 && densityIdx == 1)
            currentNumItems = numItemArray(1);
        end
        
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
        
        if i == 1   % if test
            % Determine orientation
            clear ellipseOriHolder
            ellipseOriHolder=randn(4,numItemsPerQuad);
            ellipseOriHolder=ellipseOriHolder-mean(ellipseOriHolder,2);
            ellipseOriHolder=ellipseOriHolder./(std(ellipseOriHolder,0,2));
            ellipseOriHolder=ellipseOriHolder.*oriVariance;
            ellipseOriHolder=ellipseOriHolder+((standardOri+(oriList(oriIdx))));
            ellipseOri{i}=reshape(ellipseOriHolder',[1,currentNumItems]);
            
            % Determine size
            clear ellipseSizeHolder
            ellipseSizeHolder=randn(4,numItemsPerQuad);
            ellipseSizeHolder=ellipseSizeHolder-mean(ellipseSizeHolder,2);
            ellipseSizeHolder=ellipseSizeHolder./(std(ellipseSizeHolder,0,2));
            ellipseSizeHolder=ellipseSizeHolder.*sizeVariance*PPD  ;
            ellipseSize{i}=ellipseSizeHolder+((standardSize+(sizeList(sizeIdx)))*PPD);
        elseif i == 2   % if ref
            % Determine orientation
            clear ellipseOriHolder
            ellipseOriHolder=randn(4,numItemsPerQuad);
            ellipseOriHolder=ellipseOriHolder-mean(ellipseOriHolder,2);
            ellipseOriHolder=ellipseOriHolder./(std(ellipseOriHolder,0,2));
            ellipseOriHolder=ellipseOriHolder.*oriVariance;
            ellipseOriHolder=ellipseOriHolder+((standardOri+(oriList(1))));
            ellipseOri{i}=reshape(ellipseOriHolder',[1,currentNumItems]);
            
            % Determine size
            clear ellipseSizeHolder
            ellipseSizeHolder=randn(4,numItemsPerQuad);
            ellipseSizeHolder=ellipseSizeHolder-mean(ellipseSizeHolder,2);
            ellipseSizeHolder=ellipseSizeHolder./(std(ellipseSizeHolder,0,2));
            ellipseSizeHolder=ellipseSizeHolder.*sizeVariance*PPD  ;
            ellipseSize{i}=ellipseSizeHolder+((standardSize+(sizeList(1)))*PPD);
        end
        
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
    
    % Present stim.
    Screen('DrawTextures',w,ellipseTexture{stimOrder(1)},[],ellipseCoords{stimOrder(1)},ellipseOri{stimOrder(1)});
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    Screen('Flip',w);
    WaitSecs(stimTime);
    
    % Blank screen
    Screen('DrawTexture',w,blank_tex,[],rect);
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    Screen('Flip',w);
    WaitSecs(fixTime);
    
    % Present stim.
    Screen('DrawTextures',w,ellipseTexture{stimOrder(2)},[],ellipseCoords{stimOrder(2)},ellipseOri{stimOrder(2)});
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    Screen('Flip',w);
    WaitSecs(stimTime);
    
    %                                 % Dispay which condition is being presented
    %                                 text=sprintf('%s%d%s%d%s%d','Size: ',sizeIdx(stimPresCounter), '   Ori: ',oriIdx(stimPresCounter),'   StimPres: ',stimPresCounter);
    %                                 Screen('DrawText',w,text,10,10,[0 0 0]);
    %                                 text=sprintf('%s%d%s%d','SizeStimPres: ',sizeStimPres,'   OriStimPres: ',oriStimPres);
    %                                 Screen('DrawText',w,text,10,40,[0 0 0]);
    
    % Blank screen
    Screen('DrawTexture',w,blank_tex,[],rect);
    Screen('Flip',w);
    
    % Task question
    if taskIdx == 1   % ori task
        text1='Which group looked more rightward leaning on average?';
        text2='If the first, press ''F''. If the last, press ''J''';
    elseif taskIdx == 2   % size task
        text1='Which group looked larger on average?';
        text2='If the first, press ''F''. If the last, press ''J''';
    end
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc+50,[0 0 0]);
    
%     if rawdata(n,5) == 1   % Test first
%         text3='PRESS ''F''';
%     elseif rawdata(n,5) == 2   % Ref first
%         text3='PRESS ''J''';
%     end
%     width=RectWidth(Screen('TextBounds',w,text3));
%     Screen('DrawText',w,text3,xc-width/2,yc+150,[0 0 0]);
%     disp(rawdata(n,:));
    
    Screen('Flip',w);
    
    while 1
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        if keycode(buttonF)   % Said the first was larger/rightward
            rawdata(n,7) = 1;
            break;
        elseif keycode(buttonJ)   % Said the second was larger/rightward
            rawdata(n,7) = 2;
            break;
        end
    end
    
    % Did they say the test was larger/rightward than ref (1) or not (0)
    if rawdata(n,7)==1   % They said the first was larger/rightward
        if rawdata(n,5)==1   % The first was the test
            rawdata(n,8) = 1;   % They chose test
        elseif rawdata(n,5)==2   % The second was the test
            rawdata(n,8) = 0;   % They chose ref
        end
    elseif rawdata(n,7)==2   % They said the second was larger/rightward
        if rawdata(n,5)==1   % The first was the test
            rawdata(n,8) = 0;   % They chose ref
        elseif rawdata(n,5)==2   % The second was the test
            rawdata(n,8) = 1;   % They chose test
        end
    end
    
    WaitSecs(1);
    
    % Close open textures to save memory
    Screen('Close',[ellipseTexture{stimOrder(1)},ellipseTexture{stimOrder(2)}]);
    
    % Save rawdata
    save(datafile,'rawdata');
    
end

% Save
save(datafile,'rawdata','rawdataPractice');
save(datafile_full);

Screen('CloseAll');
ListenChar(0);
ShowCursor;

%% Analysis - PSE plots
% rawdata(1) = orientation
% rawdata(2) = size
% rawdata(3) = task
% rawdata(4) = density 1:test more, 2:ref more
% rawdata(5:6) = pres order 1:test, 2:ref
% rawdata(7) = response 1:first, 2:second
% rawdata(8) = chose test:1 ref:0

% load(sprintf('%s',fileID,rawdataID{n},'/'));

% Calculate curve fit and PSE values
x_axis_ori = oriList;
xx_axis_ori = 0:.001:100;

x_axis_size = sizeList+standardSize;
xx_axis_size = 1.2:.001:2.3;

lineColor{1} = [1 0 0];
lineColor{2} = [0 0 1];
lineColor{3} = [0 1 0];
lineColor{4} = [1 0 1];

for i=1:length(oriList)
    oriTitle{i}  = num2str(oriList(i));
end
for i=1:length(sizeList)
    sizeTitle{i}  = num2str(sizeList(i)+standardSize);
end

% Separate the data based on task
rawdataOri = rawdata(rawdata(:,3)==1,:);
rawdataSize = rawdata(rawdata(:,3)==2,:);

% Sum up number of times participant reported test as larger/more rightward
% than reference
for j=1:nOri
    numOri(j) = sum(rawdataOri(:,1)==j);
    numRight(j) = sum(rawdataOri(:,1)==j & rawdataOri(:,8)==1);
    percentRight(j) = numRight(j)/numOri(j);
    
    numSize(j) = sum(rawdataSize(:,2)==j);
    numLarge(j) = sum(rawdataSize(:,2)==j & rawdataSize(:,8)==1);
    percentLarge(j) = numLarge(j)/numSize(j);
end

% Calculate fits for ori and size seperately
figure()
% Ori
datafitTemp = [numRight; numOri]';
bTemp = glmfit(x_axis_ori',datafitTemp,'binomial','logit');
fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_ori') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_ori'));
PSETempOri = -bTemp(1)/bTemp(2);

% Plot participant data
subplot(1,2,1)
h(n,i) = plot(x_axis_ori,100*percentRight','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
hold on
set(gca,'ylim',[0,100]);
set(gca,'xtick',oriList,'xTickLabels',oriTitle);
plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
plot(xx_axis_ori,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
plot(PSETempOri*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE

clear datafitTemp bTemp fitData

% Size
datafitTemp = [numLarge; numSize]';
bTemp = glmfit(x_axis_size',datafitTemp,'binomial','logit');
fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_size') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_size'));
PSETempSize = -bTemp(1)/bTemp(2);

subplot(1,2,2)
h(n,i) = plot(x_axis_size,100*percentLarge','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
hold on
set(gca,'ylim',[0,100]);
set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
plot(xx_axis_size,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
plot(PSETempSize*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE


%% Look at the data for orientation while doing the size task and vice versa
% Sum up number of times participant reported test as larger/more rightward
% than reference when doing the opposite task
for j=1:nOri
    % Looking at size accuracy while doing the orientation task
    numSizeWhileOri(j) = sum(rawdataOri(:,2)==j);
    numLargeWhileOri(j) = sum(rawdataOri(:,2)==j & rawdataOri(:,8)==1);
    percentLargeWhileOri(j) = numLargeWhileOri(j)/numSizeWhileOri(j);
    
    % Looking at ori accuracy while doing the size task
    numOriWhileSize(j) = sum(rawdataSize(:,1)==j);
    numRightWhileSize(j) = sum(rawdataSize(:,1)==j & rawdataSize(:,8)==1);
    percentRightWhileSize(j) = numRightWhileSize(j)/numOriWhileSize(j);
end

clear datafitTemp bTemp fitData

% Calculate fits for ori and size seperately
figure()
% Ori
datafitTemp = [numLargeWhileOri; numSizeWhileOri]';
bTemp = glmfit(x_axis_ori',datafitTemp,'binomial','logit');
fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_ori') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_ori'));
PSETempSizeWhileOri = -bTemp(1)/bTemp(2);   % Looking at size accuracy while doing the orientation task

% Plot participant data
subplot(1,2,1)
h(n,i) = plot(x_axis_ori,100*percentLargeWhileOri','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
hold on
set(gca,'ylim',[0,100]);
set(gca,'xtick',oriList,'xTickLabels',oriTitle);
plot(x_axis_ori,50*ones(length(x_axis_ori),1),'k--','LineWidth',2);   % Plot the 50% line
plot(xx_axis_ori,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
plot(PSETempSizeWhileOri*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE

clear datafitTemp bTemp fitData

% Size
datafitTemp = [numRightWhileSize; numOriWhileSize]';
bTemp = glmfit(x_axis_size',datafitTemp,'binomial','logit');
fitdata = 100 * exp(bTemp(1) + bTemp(2) * xx_axis_size') ./ (1 + exp(bTemp(1) + bTemp(2) * xx_axis_size'));
PSETempOriWhileSize = -bTemp(1)/bTemp(2);

subplot(1,2,2)
h(n,i) = plot(x_axis_size,100*percentRightWhileSize','Color',lineColor{1},'LineWidth',2);   % Plot the rawdata
hold on
set(gca,'ylim',[0,100]);
set(gca,'xtick',sizeList+standardSize,'xTickLabels',sizeTitle);
plot(x_axis_size,50*ones(length(x_axis_size),1),'k--','LineWidth',2);   % Plot the 50% line
plot(xx_axis_size,fitdata','Color',lineColor{2},'LineWidth',2);    % Plot the curve fit
plot(PSETempOriWhileSize*ones(51,1),[0:50],'k--','LineWidth',2);    % Plot the PSE






