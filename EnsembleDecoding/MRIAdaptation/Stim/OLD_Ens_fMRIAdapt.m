

%% Initilization variables

% clear all
% close all

rng('shuffle')

labComp = 0;
lapComp = 0;
fmriComp = 1;
crashSwitch = 0;

% Inputs
% buttonO = KbName('o');
% buttonN = KbName('n');
% buttonEscape = KbName('escape');
% buttonSpace = KbName('space');
% buttonS = KbName('s');
% buttonJ = KbName('j');
% buttonF = KbName('f');
button1 = KbName('1!');
button2 = KbName('2@');
button3 = KbName('3#');
button4 = KbName('4$');
button5 = KbName('5%');
triggerKey = KbName('6^');


% Sets the inputs to come in from the other computer
% Allows for accurate keyboard input (KbQueueWait)
KbName('UnifyKeyNames');
[dev,name] = GetKeyboardIndices;
if fmriComp == 1
    scanner_id = dev(strcmp(name,'Lumina Keyboard')); % test program on Apple; formal scan on Lumia box %Lumina Keyboard Apple Internal Keyboard / Trackpad
    dev_id = dev(strcmp(name,'Apple Internal Keyboard / Trackpad'));
    %         scanner_id = dev(strcmp(name,'Apple Internal Keyboard / Trackpad'));
    
    %     scanner_id = dev(1);
    %     dev_id = dev(1);
elseif labComp == 1
    scanner_id = dev(1);
    dev_id = dev(1);
end

allowed_keys = zeros(1,256);
allowed_keys([button1 button2 button3 button4 button5 triggerKey]) = 1;

KbQueueCreate(scanner_id, allowed_keys);
KbQueueStart(scanner_id);
KbQueueFlush(scanner_id);

KbQueueCreate(dev_id, allowed_keys);
KbQueueStart(dev_id);
KbQueueFlush(dev_id);

experiment = 'Ens_fMRIAdapt';

% get input
subjid = input('Enter Subject Code:','s');
if labComp == 1
    datadir = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/MRI Adaptation/Data/';
elseif fmriComp == 1
    datadir = '/Users/rendenUNR/Desktop/Scanning At Renown/CLAB/Kyle/MRI Adaptation/Data/';
end

datafile=sprintf('%s_%s',subjid,experiment);
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

if labComp == 0 || fmriComp == 1
    HideCursor;
    ListenChar(2);
end

if labComp == 1 || lapComp == 1
    Screen('Preference', 'SkipSyncTests', 1);
end


%% Setup  variables
%BASIC WINDOW/SCREEN SETUP
%Get information about the current screen properties, and what to return
%the screen to after the experiment.
% oldScreen=Screen('Resolution',0);

% Set the Screen resolution and refresh rate to the values appropriate for
% your experiment;
if labComp == 1
    hz = 120;
    screenNum = 1;
elseif lapComp == 1
    hz = 85;
    screenNum = 0;
elseif fmriComp == 1
    hz = 120;
    screenNum = 0;
    %     Screen('Resolution',screenNum,screenWide,screenHigh,hz);   % Change screen resolution and refresh rate
end

monRes = Screen('Resolution',screenNum);
screenWide=monRes.width;
screenHigh=monRes.height;

% Set the correct values for SyncTest
[maxStddev, minSamples, maxDeviation, maxDuration] = Screen('Preference','SyncTestSettings' ,0.002,50,0.2,5);

% [w, rect] = Screen('Openwindow', w, [128 128 128],[0 0 screenWide screenHigh]);
% [w, rect] = Screen('Openwindow', screenNum, [128 128 128],[0 0 screenWide screenHigh],[],[],[],[8]);
[w, rect] = Screen('Openwindow', screenNum, [128 128 128],[],[],[],[],[8]);

% PPD stuff
if labComp == 1
    mon_width_cm = 53;
    mon_dist_cm = 73;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (rect(3)/mon_width_deg);
elseif lapComp == 1
    mon_width_cm = 43;   % DOUBLE CHECK!
    mon_dist_cm = 73;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (rect(3)/mon_width_deg);
elseif fmriComp == 1
    %     mon_width_cm = 70;   % Scanning monitor dimensions
    %     mon_dist_cm = 130;
    mon_width_cm = 33;
    mon_dist_cm = 50;
    mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
    PPD = (rect(3)/mon_width_deg);
end

% If the program crashed and needs to be restarted at a given run
if crashSwitch == 1
    % Load in the datafile that was created (to load in the predetermined trialOrder
    load(sprintf('%s',datadir,datafile_full));
        
    % Ask what run to start on
    currRun = str2double(input('What run should we start on?','s'));
    
    % Reset trialCounter
    trialCounter = (currRun*8);
    
    % Make a new run counter
    runCounter = currRun:runsPerExp;
    
elseif crashSwitch == 2
    
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
    
    % measure the frame rate
    % Used to ensure very accurate stimulus onset and duration timing
    frame_rate = Screen('FrameRate',w); % in seconds.  this is what the operating system is set to, does not work on some systems (e.g., lcd or laptops)
    flip_interval = Screen('GetFlipInterval',w); % in seconds.  this is an actual measurement, should work on all systems
    flip_interval_correction = flip_interval/4; % this should work even on laptops that don't return a FrameRate value
    
    Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason
    
    
    %% Trial variables
    orientationList = [1 2 3 4];
    nOri = length(orientationList);
    sizeList = [1 2 3 4];
    nSize = length(sizeList);
    taskList = [1 2];
    nTask = length(taskList);
    runsPerExp = 12;   % total # runs
    blocksPerRun = 4;   % Blocks per run (per task)
    repsPerBlock = 8;   % Repetitions of test to ref per block (per task)
    
    trialOrder = [];
    for i=1:3   % For each 'cycle' or 4 runs
        cycleList = fullfact([nOri nSize nTask]);
        presOrder = randperm(size(cycleList,1));
        cycleList(:,:) = cycleList(presOrder,:);
        
        trialOrder = [trialOrder; cycleList];
    end
    trialOrder(:,4) = repelem([1:runsPerExp]',blocksPerRun*2);   % Run number
    % counter=0;
    % for i=1:runsPerExp
    %     for j=1:blocksPerRun*2
    %         counter = counter+1;
    %         trialOrder(counter,4) = i;
    %     end
    % end
    trialOrder(:,5) = repmat([1:blocksPerRun*2]',[runsPerExp,1]);   % Block number
    
    % On each trial alternate between more/less items
    % Determine randomly what the starting amount for each trial will be
    % 1=start more; 2=start less
    for i=1:nOri
        for j=1:nSize
            trialOrder(trialOrder(:,1)==i & trialOrder(:,2)==j & (trialOrder(:,4)==1|trialOrder(:,4)==2|trialOrder(:,4)==3|trialOrder(:,4)==4), 6) = randperm(2);
            trialOrder(trialOrder(:,1)==i & trialOrder(:,2)==j & (trialOrder(:,4)==5|trialOrder(:,4)==6|trialOrder(:,4)==7|trialOrder(:,4)==8), 6) = randperm(2);
            trialOrder(trialOrder(:,1)==i & trialOrder(:,2)==j & (trialOrder(:,4)==9|trialOrder(:,4)==10|trialOrder(:,4)==11|trialOrder(:,4)==12), 6) = randperm(2);
        end
    end
    
    % Preallocate the rawdata
    rawdata = zeros(length(trialOrder),9);
    
    %% Stimulus variables
    
    % Amount of jitter
    jitterAmount = 10;
    
    % Size of one cell
    cellSize = rect(4)/8;
    
    % Timing vars
    stimTime = .15; % 150 ms
    fixTime = .85; % 850 ms
    interBlockInterval = 12;
    totalTrialTime = stimTime+fixTime;
    totalBlockTime = ((stimTime + fixTime) * (repsPerBlock * 2));   % IBI + combined time of stim pres and fixation * repetitions * 2 (ref and test)
    totalRunTime = (totalBlockTime*blocksPerRun*2) + (interBlockInterval*((blocksPerRun*2)+1));   % Total blocks (trials+IbI) + an extra IBI for the start of the block
    totalExpTime = totalRunTime*runsPerExp;
    responseTime = 3;   % Time the participant has to respond after block ends
    instructionTime = 4;   % Time the instructions will appear on the screen before the block starts
    firstIBITime = 8;
    IBITime = 5;
    
    % Set all the timing values for accurate fMRI timing
    % Set the time of the start of the IBIs
    initIBITimeList(1) = 0;
    for i=2:blocksPerRun*2+1
        initIBITimeList(i) = initIBITimeList(i-1)+interBlockInterval+totalBlockTime;
    end
    
    % Set the time at which each block starts
    % First block starts after first 12 second IBI
    initBlockTimeList(1) = interBlockInterval;
    for i=2:blocksPerRun*2
        initBlockTimeList(i) = initBlockTimeList(i-1)+interBlockInterval+totalBlockTime;
    end
    
    % Set the time at which each trial starts
    for i=1:length(initBlockTimeList)
        initTrialTimeList(1,i) = initBlockTimeList(i);
        for j=2:repsPerBlock*2
            initTrialTimeList(j,i) = initTrialTimeList(j-1,i)+totalTrialTime;
        end
    end
    
    % Create the stimulus variables for orientation and size
    % The maximum size of the largest circle should not allow the ellipse to
    % move oustide of it cell. In DoVA
    standardSize = 1;
    standardOri = 270;
    
    sizeVariance = .25;
    % sizeList = [0 .25 .5 1];
    oriVariance = 10;
    % oriList = [0 25 45 90];
    
    % Load in participants size and ori values from behavioral data
    [ensDataStruct] = ensLoadData('LoadfMRI',subjid);
    oriList = ensDataStruct.oriList;
    sizeList = ensDataStruct.sizeList;
    
    numItemArray = [36 44];   % Number of items present
    
    % fix_size = 5;   % Fixaiton size (in pixels)
    % fix_rect =[xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];
    
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
    
    % Preallocate some arrays in increase speed
    ibiStartTime = zeros(repsPerBlock,runsPerExp);
    blockStartTime = zeros(repsPerBlock,runsPerExp);
    trialStartTime = zeros(length(trialOrder),repsPerBlock*2,5);
    responseStartTime = zeros(repsPerBlock,runsPerExp);
    responseEndTime = zeros(repsPerBlock,runsPerExp);
    instructionStartTime = zeros(repsPerBlock,runsPerExp);
    runEndTime = zeros(runsPerExp);
    runStartTime = zeros(runsPerExp);
    runEndStart = zeros(runsPerExp);
    
    % Instructions
    Screen('TextSize',w,15);
    text1='You will be shown groups of ellipses every 1 second for 16 seconds.';
    text2='While each individual ellipse has its own orientation and size,';
    text3='the group will have an average orientation and size.';
    text4='For this experiment you will identify any changes you see to the average';
    text5='orientation OR size. Specifically, you will make judgements on consecutively';
    text6='presented groups. For example, although 16 groups will be presented, you will';
    text7='judge differences between groups 1 and 2, 3 and 4, 5 and 6, etc.';
    text8='Instructions will appear at the beginning of the block to tell you what';
    text9='averaging task you will perform FOR THAT BLOCK. These will change on every block.';
    text10='The experiment will consist of 12 4 minute runs and each run will contain 8 blocks.';
    text11='Lastly, make sure you maintain fixation on the dot in the center of the screen';
    text12='Let''s start with some practice trials.';
    text13='Tell the experimener to start the experiment...' ;
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-350,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc-300,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text3));
    Screen('DrawText',w,text3,xc-width/2,yc-250,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text4));
    Screen('DrawText',w,text4,xc-width/2,yc-200,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text5));
    Screen('DrawText',w,text5,xc-width/2,yc-150,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text6));
    Screen('DrawText',w,text6,xc-width/2,yc-100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text7));
    Screen('DrawText',w,text7,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text8));
    Screen('DrawText',w,text8,xc-width/2,yc+0,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text9));
    Screen('DrawText',w,text9,xc-width/2,yc+50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text10));
    Screen('DrawText',w,text10,xc-width/2,yc+100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text11));
    Screen('DrawText',w,text11,xc-width/2,yc+150,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text12));
    Screen('DrawText',w,text12,xc-width/2,yc+200,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text13));
    Screen('DrawText',w,text13,xc-width/2,yc+250,[0 0 0]);
    
    Screen('Flip',w);
    
    KbQueueFlush(dev_id);
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
    while ~any(lastPress(button5))
        [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
    end
    
    %% Practice
    % rawdataPractice = Ens_VEP_Practice(rect,w,button1,button2,button3,button4,flip_interval_correction,xc,yc,PPD,dev_id,runid,datafile);
    
    % text1='End of practice trials.';
    % text2='Tell the experimener to start the experiment...';
    %
    % width=RectWidth(Screen('TextBounds',w,text1));
    % Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
    % width=RectWidth(Screen('TextBounds',w,text2));
    % Screen('DrawText',w,text2,xc-width/2,yc+0,[0 0 0]);
    % Screen('Flip',w);
    %
    % KbQueueFlush(dev_id);
    % [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
    % while ~any(lastPress(button5))
    %     [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
    % end
    
    
    trialCounter = 0;
    currRun = 1; % Keep track of what run in case the exp crashes between runs for some reason
    runCounter = 1:runsPerExp;
end

%% Experiment start
for m=runCounter   % runs loop
    % for m=10:12
    
    % Clear out old variables
    clear ellipseCoords ellipseSize ellipseOri oriIdx sizeIdx taskResponseHolder ellipseTexture
    
    % Blank screen texture
    blank_tex = Screen('MakeTexture',w,128*ones(1,1));
    
    % Make a new trialOrder variable that contains only the trials for that block
    trialOrderBlock = trialOrder(trialOrder(:,4) == currRun,:);
    
    % Create/Load in the textures for this run using the values from 'trialOrderBlock'
    [ellipseTexture,ellipseOri,ellipseCoords] = Ens_fMRIAdapt_Preall(w,xc,yc,rect,PPD,trialOrderBlock,oriList,sizeList);
    
    % Preallocate the rawdata/index values for this run
    % Determine the delta to be used for size and orientation
    % rawdata(1) = ori
    % rawdata(2) = size
    % rawdata(3) = task; 1=ori, 2=size
    % rawdata(4) = run number
    % rawdata(5) = block number
    % rawdata(6) = number of items present; 1=start less, 2=start more
    oriIdx = trialOrder(trialOrder(:,4) == currRun,1);
    rawdata(trialOrder(:,4)==currRun,1) = oriIdx;
    sizeIdx = trialOrder(trialOrder(:,4) == currRun,2);
    rawdata(trialOrder(:,4)==currRun,2) = sizeIdx;
    taskIdx = trialOrder(trialOrder(:,4) == currRun,3);
    rawdata(trialOrder(:,4)==currRun,3) = taskIdx;
    runIdx = trialOrder(trialOrder(:,4) == currRun,4);
    rawdata(trialOrder(:,4)==currRun,4) = runIdx;
    blockIdx = trialOrder(trialOrder(:,4) == currRun,5);
    rawdata(trialOrder(:,4)==currRun,5) = blockIdx;
    itemsIdx = trialOrder(trialOrder(:,4) == currRun,6);
    rawdata(trialOrder(:,4)==currRun,6) = itemsIdx;
    
    % Preallocate instruction cues 'S' vs 'O'
    for o=1:length(taskIdx)
        switch taskIdx(o)
            case 1
                taskCue{o} = 'O';
            case 2
                taskCue{o} = 'S';
        end
    end
    
    % Instructions
    text1='You will be shown groups of ellipses every 1 second for 16 seconds.';
    text2='While each individual ellipse has its own orientation and size,';
    text3='the group will have an average orientation and size.';
    text4='For this experiment you will identify any changes you see to the average';
    text5='orientation OR size. Specifically, you will make judgements on consecutively';
    text6='presented groups. For example, although 16 groups will be presented, you will';
    text7='judge differences between groups 1 and 2, 3 and 4, 5 and 6, etc.';
    text8='Instructions will appear at the beginning of the block to tell you what';
    text9='averaging task you will perform FOR THAT BLOCK. These will change on every block.';
    text10='The experiment will consist of 12 4 minute runs and each run will contain 8 blocks.';
    text11='Make sure that while doing one task you are ignoring the other feature.';
    text12='For example, while averaging size ignore any changes to average orientation.';
    text13='Lastly, make sure you maintain fixation on the dot in the center of the screen.';
    text14='Press any key when ready to begin...' ;
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-350,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc-300,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text3));
    Screen('DrawText',w,text3,xc-width/2,yc-250,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text4));
    Screen('DrawText',w,text4,xc-width/2,yc-200,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text5));
    Screen('DrawText',w,text5,xc-width/2,yc-150,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text6));
    Screen('DrawText',w,text6,xc-width/2,yc-100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text7));
    Screen('DrawText',w,text7,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text8));
    Screen('DrawText',w,text8,xc-width/2,yc+0,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text9));
    Screen('DrawText',w,text9,xc-width/2,yc+50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text10));
    Screen('DrawText',w,text10,xc-width/2,yc+100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text11));
    Screen('DrawText',w,text11,xc-width/2,yc+150,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text12));
    Screen('DrawText',w,text12,xc-width/2,yc+200,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text13));
    Screen('DrawText',w,text13,xc-width/2,yc+250,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text14));
    Screen('DrawText',w,text14,xc-width/2,yc+300,[0 0 0]);
    
    % Show ins then let participant initiate before waiting for trigger pulse
    [~, runInstructionEndTime, ~, ~, ~] = Screen('Flip',w);
    
    KbQueueFlush(dev_id);
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    while ~any(lastPress([button1 button2 button3 button4]))
        [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    end
    
    WaitSecs(2);
    
    % WAIT FOR TRIGGER PULSE FROM SCANNER
    text1='Waiting for scanner...';
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-100,[0 0 0]);
    text1=sprintf('%s%d','Starting run # ',currRun);
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
    Screen('Flip',w);
    
    KbQueueFlush(scanner_id);
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    while ~any(lastPress(triggerKey))
        [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    end
    runStartTime(m) = GetSecs;   % Start time of the experiment
    
    currRun = currRun+1;
    
    firstBlock = 1;
    
    %% Run start
    for n=1:length(trialOrderBlock)   % run for the length of the run in trial order
        
        %         tic;
        
        trialCounter = trialCounter+1;
        
        % Set priority
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        % Task cue
        text1=taskCue{n};
        
        % Draw initial cue
        width=RectWidth(Screen('TextBounds',w,text1));
        height=RectHeight(Screen('TextBounds',w,text1));
        Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
        switch firstBlock
            case 1
                [~, instructionStartTime(n,m), ~, ~, ~] = Screen('Flip',w,runStartTime(m) + initIBITimeList(n) - flip_interval_correction);
                ibiStartTime(n,m) = instructionStartTime(n,m)-runStartTime(m);
            case 0
                [~, instructionStartTime(n,m), ~, ~, ~] = Screen('Flip',w,runStartTime(m) + (initIBITimeList(n) + responseTime) - flip_interval_correction);
                ibiStartTime(n,m) = instructionStartTime(n,m)-responseTime-runStartTime(m);
        end
        
        % Keep cue on screen for correct time until trial starts
        Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
        switch firstBlock
            case 1
                [~, blockStartTime(n,m), ~, ~, ~] = Screen('Flip',w,runStartTime(m) + initIBITimeList(n) + instructionTime + firstIBITime  - flip_interval_correction);
            case 0
                [~, blockStartTime(n,m), ~, ~, ~] = Screen('Flip',w,runStartTime(m) + (initIBITimeList(n) + responseTime) + IBITime  + instructionTime - flip_interval_correction);
        end
        
        rawdata(trialCounter,7) = blockStartTime(n,m)-runStartTime(m);
        
        %         toc
        %         tic;
        
        % Start trial loop for the block
        firstTrial = 1;
        for j=1:repsPerBlock*2
            % Draw stimuli
            switch firstBlock
                case 1
                    Screen('DrawTextures',w,ellipseTexture{n,j},[],ellipseCoords{n,j},ellipseOri{n,j});
                    Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
                    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
                    [~, stimOnTime, ~, ~, ~] = Screen('Flip',w, runStartTime(m) + initIBITimeList(n) + instructionTime + firstIBITime + (initTrialTimeList(j,1) - interBlockInterval) - flip_interval_correction);
                    % Blank screen
                    Screen('DrawTexture',w,blank_tex,[],rect);
                    Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
                    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
                    [~, stimOffTime, ~, ~, ~] = Screen('Flip',w,runStartTime(m) + initIBITimeList(n) + instructionTime + firstIBITime + (initTrialTimeList(j,1) - interBlockInterval) + stimTime - flip_interval_correction);
                case 0
                    Screen('DrawTextures',w,ellipseTexture{n,j},[],ellipseCoords{n,j},ellipseOri{n,j});
                    Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
                    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
                    [~, stimOnTime, ~, ~, ~] = Screen('Flip',w, runStartTime(m) + (initIBITimeList(n) + responseTime) + instructionTime + IBITime + (initTrialTimeList(j,1) - interBlockInterval) - flip_interval_correction);
                    % Blank screen
                    Screen('DrawTexture',w,blank_tex,[],rect);
                    Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
                    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
                    [~, stimOffTime, ~, ~, ~] = Screen('Flip',w,runStartTime(m) + (initIBITimeList(n) + responseTime) + instructionTime + IBITime + (initTrialTimeList(j,1) - interBlockInterval)  + stimTime - flip_interval_correction);
            end
            
            
            % Record stim on stim off for each trial
            trialStartTime(trialCounter,j,1) = stimOnTime;
            trialStartTime(trialCounter,j,2) = stimOffTime;
            trialStartTime(trialCounter,j,3) = round(stimOnTime-blockStartTime(n,m),6);
            trialStartTime(trialCounter,j,4) = round(stimOffTime-blockStartTime(n,m),6);
            trialStartTime(trialCounter,j,5) = round(stimOffTime - stimOnTime,6);
        end
        
        % Wait the last 850ms ITI before starting IBI/response
        %         [~, stimOffTime2, ~, ~, ~] = Screen('Flip',w,stimOffTime + fixTime - flip_interval_correction,1);
        
        
        %% Response start (actual IBI start)
        text1 = '#';
        width=RectWidth(Screen('TextBounds',w,text1));
        height=RectHeight(Screen('TextBounds',w,text1));
        Screen('DrawText',w,text1,xc-width/2,yc-height/w,[0 0 0]);
        
        switch firstBlock
            case 1
                [~, responseStartTime(n,m), ~, ~, ~] = Screen('Flip',w,runStartTime(m) + initIBITimeList(n) + instructionTime + firstIBITime + (initTrialTimeList(end,1) - interBlockInterval)  + stimTime  + fixTime - flip_interval_correction);
            case 0
                [~, responseStartTime(n,m), ~, ~, ~] = Screen('Flip',w,runStartTime(m) + (initIBITimeList(n) + responseTime) + instructionTime + IBITime + (initTrialTimeList(end,1) - interBlockInterval)  + stimTime  + fixTime - flip_interval_correction);
        end
        
        %         toc
        %         tic;
        
        while 1
            
            % While the total time is less than time elapsed keep looping
            switch firstBlock
                case 1
                    response_check = (GetSecs - (runStartTime(m) + initIBITimeList(n) + instructionTime + firstIBITime + (initTrialTimeList(end,1) - interBlockInterval)  + stimTime  + fixTime - flip_interval_correction)) > responseTime;
                case 0
                    response_check = (GetSecs - (runStartTime(m) + (initIBITimeList(n) + responseTime) + instructionTime + IBITime + (initTrialTimeList(end,1) - interBlockInterval)  + stimTime  + fixTime - flip_interval_correction)) > responseTime;
            end
            
            [keyisdown, secs, keycode] = KbQueueCheck(scanner_id);
            switch response_check
                case 0
                    if keycode(button1)
                        rawdata(trialCounter,8) = 1;
                    elseif keycode(button2)
                        rawdata(trialCounter,8) = 2;
                    elseif keycode(button3)
                        rawdata(trialCounter,8) = 3;
                    elseif keycode(button4)
                        rawdata(trialCounter,8) = 4;
                    end
                case 1
                    rawdata(n,8) = 0;   % 0=no response
                    break
            end
        end
        
        Priority(0);
        
        % Close any remaining open textures to clear memory
        windowPointers = ellipseTexture{n,:};
        Screen('Close',windowPointers);
        
        firstBlock = 0;
        
        responseEndTime(n,m) = GetSecs - runStartTime(m);
        %         toc
    end
    
    % Present the rest of the last IBI before the run end
    % Blank screen   
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
    runEndStart(m) = GetSecs;
    while 1
        response_check = GetSecs-runEndStart(m) > 9;
        switch response_check
            case 1
                break
        end        
    end
    
    %% Run end
    % Calculate total run time
    runEndTime(m) = GetSecs - runStartTime(m);
    
    % Close any remaining open textures to clear memory
    windowPointers = Screen('Windows');
    Screen('Close',windowPointers);
    
    % Calculate and report accuracy for this run
    for i=1:repsPerBlock
        % Did they say there was a change when there actually was one?
        if rawdata(trialCounter-(repsPerBlock-(i)),3) == 1  % Ori task
            if (rawdata(trialCounter-(repsPerBlock-(i)),8) == 1) && (rawdata(trialCounter-(repsPerBlock-(i)),1) == 1)   % No change and they said no change
                rawdata(trialCounter-(repsPerBlock-(i)),9) = 1;
            elseif (rawdata(trialCounter-(repsPerBlock-(i)),8) == 2 || rawdata(trialCounter-(repsPerBlock-(i)),8) == 3 || rawdata(trialCounter-(repsPerBlock-(i)),8) == 4) &&...
                    (rawdata(trialCounter-(repsPerBlock-(i)),1) == 2 || rawdata(trialCounter-(repsPerBlock-(i)),1) == 3 || rawdata(trialCounter-(repsPerBlock-(i)),1) == 4 || rawdata(trialCounter-(repsPerBlock-(i)),1) == 5) % Change and they said change
                rawdata(trialCounter-(repsPerBlock-(i)),9) = 1;
            else
                rawdata(trialCounter-(repsPerBlock-(i)),9) = 0;
            end
        elseif rawdata(trialCounter-(repsPerBlock-(i)),3) == 2   % Size task
            if (rawdata(trialCounter-(repsPerBlock-(i)),8) == 1) && (rawdata(trialCounter-(repsPerBlock-(i)),2) == 1)   % No change and they said no change
                rawdata(trialCounter-(repsPerBlock-(i)),9) = 1;
            elseif (rawdata(trialCounter-(repsPerBlock-(i)),8) == 2 || rawdata(trialCounter-(repsPerBlock-(i)),8) == 3 || rawdata(trialCounter-(repsPerBlock-(i)),8) == 4) &&...
                    (rawdata(trialCounter-(repsPerBlock-(i)),2) == 2 || rawdata(trialCounter-(repsPerBlock-(i)),2) == 3 || rawdata(trialCounter-(repsPerBlock-(i)),2) == 4 || rawdata(trialCounter-(repsPerBlock-(i)),2) == 5) % Change and they said change
                rawdata(trialCounter-(repsPerBlock-(i)),9) = 1;
            else
                rawdata(trialCounter-(repsPerBlock-(i)),9) = 0;
            end
        end
    end
    
    % Calculate percent correct for this run
    percentCorrect = sum(rawdata((trialCounter-7):trialCounter,9))/8;
    
    % Display (soft) accuracy
    text1 = sprintf('%s%d%s','Run ',currRun,' finished!');
    text2 = sprintf('%s%d%s','Accuracy: ',percentCorrect,' %');
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc-50,[0 0 0]);
    Screen('Flip',w);
    
    WaitSecs(3);
    
    % Save rawdata and flicker info after ever trial46
    save(sprintf('%s',datadir,datafile),'rawdata','trialOrder','runStartTime','instructionStartTime','ibiStartTime','blockStartTime','trialStartTime','responseStartTime','responseEndTime','runEnsStart','runEndTime');
    % Save all data after each run in case of crash
    save(sprintf('%s',datadir,datafile_full));
end

% Save
save(sprintf('%s',datadir,datafile),'rawdata','trialOrder','runStartTime','instructionStartTime','ibiStartTime','blockStartTime','trialStartTime','responseStartTime','responseEndTime','runEnsStart','runEndTime');
save(sprintf('%s',datadir,datafile_full));

Screen('CloseAll');

if labComp == 0
    ShowCursor;
    ListenChar(0);
end
%
% % Start of each IBI
% time.measured.IBIStart = ibiStartTime;   % Measured
% time.actual.IBIStart = initIBITimeList;   % Actual
%
% % Calculate some of the timing values to esure proper timing relative to the start of the run
% % Start of each block
% counter=0;
% for i=1:12
%     for j=1:8
%         counter=counter+1;
%         time.measured.blockStart(j,i) = rawdata(counter,7);
%     end
% end
% time.actual.blockStart = initBlockTimeList;
%
% % Start of each trial relative to block start
% time.measure.trialStart = trialStartTime(trialCounter,j,3);   % Measured
% time.actual.trialStart = initTrialTimeList;   % Actual
%
% % Length of each run
% time.measured.runEnd = runEndTime;   % Measured
% time.actual.runEnd = totalRunTime;   % Actual




