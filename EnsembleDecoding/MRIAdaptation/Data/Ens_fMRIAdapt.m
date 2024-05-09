

%% Initilization variables

clear all
close all

rng('shuffle')

labComp = 1;
lapComp = 0;
fmriComp = 0;

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
    dev_id = dev(strcmp(name,'Apple Keyboard'));
elseif labComp == 1
    scanner_id = dev(1);
    dev_id = dev(1);
end

allowed_keys = zeros(1,256);
allowed_keys([button1 button2 button3 button4 button5 triggerKey]) = 1;

KbQueueCreate(scanner_id, allowed_keys);
KbQueueStart(scanner_id);
KbQueueFlush(scanner_id);

experiment = 'Ens_fMRIAdapt';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
if labComp == 1
    datadir = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/MRI Adaptation/Data/';
end

datafile=sprintf('%s_%s_%03d',subjid,experiment,runid);
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

if labComp == 0
    HideCursor;
    ListenChar(2);
end

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
% elseif eegComp == 1
%     mon_width_cm = 40;
%     mon_dist_cm = 73;
%     mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
%     PPD = (1024/mon_width_deg);
end

screenWide=1024;
screenHigh=768;

%Get information about the current screen properties, and what to return
%the screen to after the experiment.
oldScreen=Screen('Resolution',0);

% Set the Screen resolution and refresh rate to the values appropriate for
% your experiment;
if labComp == 1
    hz = 120;
    screenNum = 1;
elseif lapComp == 1
    hz = 85;
    screenNum = 0;
% elseif eegComp == 1
%     hz = 120;
%     screenNum = 1;
%     Screen('Resolution',screenNum,screenWide,screenHigh,hz);
end

% [w, rect] = Screen('Openwindow', w, [128 128 128],[0 0 screenWide screenHigh]);
[w, rect] = Screen('Openwindow', screenNum, [128 128 128],[0 0 screenWide screenHigh],[],[],[],[8]);
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
runid = 1;  % start with run 1 and count up to total in outer trial (run) loop
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
standardSize = 1.25;
standardOri = 270;

sizeVariance = .25;
sizeList = [0 .25 .5 1];
oriVariance = 10;
oriList = [0 25 45 90];

numItemArray = [36 44];   % Number of items present

fix_size = 5;   % Fixaiton size (in pixels)
fix_rect =[xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];

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

% Instructions
% PRESENT INITIAL INSTRUCTIONS BASED ON RAWDATA(4); 1=attend left 2=attend right
text1='You will be shown a group of ellipses.';
text2='The group will have an average orientation and size.';
text3='For this experiment you will only be attending to ONE of the two features.';
text4='This averaging task will change in blocks of 125 trials.';
text5='Before the begining of each block, instructions will appear';
text6='to let you know what task you will be doing.';
text7='Lastly, make sure you maintain fixation on the fixation dot in the center of the screen';
text8='Let''s start with some practice trials.';
text9='Tell the experimener to start the experiment...' ;

width=RectWidth(Screen('TextBounds',w,text1));
Screen('DrawText',w,text1,xc-width/2,yc-250,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text2));
Screen('DrawText',w,text2,xc-width/2,yc-200,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text3));
Screen('DrawText',w,text3,xc-width/2,yc-150,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text4));
Screen('DrawText',w,text4,xc-width/2,yc-100,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text5));
Screen('DrawText',w,text5,xc-width/2,yc-50,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text6));
Screen('DrawText',w,text6,xc-width/2,yc+0,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text7));
Screen('DrawText',w,text7,xc-width/2,yc+50,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text8));
Screen('DrawText',w,text8,xc-width/2,yc+100,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text9));
Screen('DrawText',w,text9,xc-width/2,yc+150,[0 0 0]);

Screen('Flip',w);

KbQueueFlush(dev_id);
[press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
while ~any(lastPress(button5))
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
end

%% Practice
% rawdataPractice = Ens_VEP_Practice(rect,w,button1,button2,button3,button4,flip_interval_correction,xc,yc,PPD,dev_id,runid,datafile);

text1='End of practice trials.';
text2='Tell the experimener to start the experiment...';

width=RectWidth(Screen('TextBounds',w,text1));
Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
width=RectWidth(Screen('TextBounds',w,text2));
Screen('DrawText',w,text2,xc-width/2,yc+0,[0 0 0]);
Screen('Flip',w);

KbQueueFlush(dev_id);
[press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
while ~any(lastPress(button5))
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(dev_id);
end

%% Experiment start
trialCounter = 0;
currRun = 1; % Keep track of what run in case the exp crashes between runs for some reason
for m=1:runsPerExp   % runs loop
    
    % Clear out old variables
    clear ellipseCoords ellipseSize ellipseOri oriIdx sizeIdx taskResponseHolder ellipseTexture
    
    % Blank screen texture
    blank_tex = Screen('MakeTexture',w,128*ones(1,1));
    
    % Fixation Texture
    fix_tex = Screen('MakeTexture',w,0*ones(1,1));
    
    % Make a new trialOrder variable that contains only the trials for that block
    trialOrderBlock = trialOrder(trialOrder(:,4) == currRun,:);
    currRun = currRun+1;
    
    % Create/Load in the textures for this run using the values from 'trialOrderBlock'
    [ellipseTexture,ellipseOri,ellipseCoords] = Ens_fMRIAdapt_Preall(w,xc,yc,rect,PPD,trialOrderBlock);
    
    % PRESENT INITIAL RUN INSTRUCTIONS FOR PARTICIPANT TO INITIATE
    text1='Please pay attention to the average ORIENTATION of the group.';
    text2='The changes to the groups orientation might be large or small, or there might be no change.';
    text3='Additionally, you should ignore any changes you might notice to the average size.';
    text4='You will be asked to report any changes you may have seen at the end of the trial.';
    text5='Specifically, you will be asked to determine how much more RIGHTWARD the average of the group was';
    text6='compared to an example ellipase shown after the trial. You will use the ''1'' - ''4''';
    text7='keys to indicate how much more rightward it was. ''1'' being no difference,';
    text8='''2'' - ''4'' being small to large difference respectively. Lastly, although you shouldn''t rush,';
    text9='you will have 3 seconds per trial to respond, so do so as quickly as possible.';
    text10='Press any key to begin the next trial...';
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-300,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc-250,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text3));
    Screen('DrawText',w,text3,xc-width/2,yc-200,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text4));
    Screen('DrawText',w,text4,xc-width/2,yc-150,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text5));
    Screen('DrawText',w,text5,xc-width/2,yc-100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text6));
    Screen('DrawText',w,text6,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text7));
    Screen('DrawText',w,text7,xc-width/2,yc+0,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text8));
    Screen('DrawText',w,text8,xc-width/2,yc+50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text9));
    Screen('DrawText',w,text9,xc-width/2,yc+100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text10));
    Screen('DrawText',w,text10,xc-width/2,yc+150,[0 0 0]);
    
    % Show ins then let participant initiate before waiting for trigger pulse
    [~, runInstructionEndTime, ~, ~, ~] = Screen('Flip',w);
    
    KbQueueFlush(dev_id);
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    while ~any(lastPress([button1 button2 button3 button4]))
        [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    end
    
    % WAIT FOR TRIGGER PULSE FROM SCANNER
    text1='Waiting for scanner...';
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-100,[0 0 0]);
    Screen('Flip',w);
    
    KbQueueFlush(scanner_id);
    [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    while ~any(lastPress(triggerKey))
        [press, firstPress, firstRel, lastPress, lastRel] = KbQueueCheck(scanner_id);
    end
    runStartTime(m) = GetSecs;   % Start time of the experiment
    
    firstBlock = 1;
        
    for n=1:length(trialOrderBlock)   % run for the length of the run in trial order
                
        if firstBlock == 1
            responseTimeOffset = 0;
        elseif firstBlock == 0
            responseTimeOffset = responseTime;
        end
        
        trialCounter = trialCounter+1;
        
        % Determine the delta to be used for size and orientation
        % rawdata(1) = ori
        % rawdata(2) = size
        % rawdata(3) = task; 1=ori, 2=size
        % rawdata(4) = run number
        % rawdata(5) = block number
        % rawdata(6) = number of items present; 1=start less, 2=start more
        oriIdx = trialOrder(trialCounter,1);
        rawdata(trialCounter,1) = oriIdx;
        sizeIdx = trialOrder(trialCounter,2);
        rawdata(trialCounter,2) = sizeIdx;
        taskIdx = trialOrder(trialCounter,3);
        rawdata(trialCounter,3) = taskIdx;
        runIdx = trialOrder(trialCounter,4);
        rawdata(trialCounter,4) = runIdx;
        blockIdx = trialOrder(trialCounter,5);
        rawdata(trialCounter,5) = blockIdx;
        itemsIdx = trialOrder(trialCounter,6);
        rawdata(trialCounter,6) = itemsIdx;
        
        % Present task instructions at the beginning of each block; THEY
        % WILL ONLY BE PRESENT FOR 3 SECONDS SO ENSURE THEY ARE SIMPLE.
        % PRESENT MORE THOROUGH INSTRUCTIONS AT START OF RUN.
        if taskIdx==1   % orientation task
            text1='This is an ORIENTATION block.';
            text2='Please pay attention to any changes in average orientation.';
        elseif taskIdx==2
            text1='This is a SIZE block.';
            text2='Please pay attention to any changes in average size.';
        end

        width=RectWidth(Screen('TextBounds',w,text1));
        Screen('DrawText',w,text1,xc-width/2,yc-250,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text2));
        Screen('DrawText',w,text2,xc-width/2,yc-200,[0 0 0]);
        %         [~, instructionStartTime, ~, ~, ~] = Screen('Flip',w, runStartTime(m) + initIBITimeList(n) - responseTimeOffset - flip_interval_correction);
        [~, instructionStartTime, ~, ~, ~] = Screen('Flip',w);
        
        % The start of the 12s IBI is the start of the response from the
        % previous block. If we are on anything but the first block, add in
        % the response time.
        if firstBlock == 1
            ibiStartTime(n,m) = instructionStartTime - runStartTime(m);
        elseif firstBlock == 2
            ibiStartTime(n,m) = (instructionStartTime+responseEndTime(n,m)) - runStartTime(m);
        end
             
        % Set priority
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
                
        % Leave instructions on for 4 seconds
        Screen('DrawTexture',w,fix_tex,[],fix_rect);   % Fixation
        %         [~, instructionEndTime, ~, ~, ~] = Screen('Flip',w, instructionStartTime + instructionTime - preallDelay - flip_interval_correction);
        [~, instructionEndTime, ~, ~, ~] = Screen('Flip',w, instructionStartTime + instructionTime - flip_interval_correction);

        % FIXATION FOR 5 SECONDS AFTER THE instructions,
        % UNLESS FIRST BLOCK OF RUN THEN FIXATION FOR 8 SECONDS
        Screen('DrawTexture',w,fix_tex,[],fix_rect);
        if firstBlock == 1
            [~, blockStartTime(n,m), ~, ~, ~] = Screen('Flip',w, instructionEndTime + firstIBITime - flip_interval_correction);
        elseif firstBlock == 0
            [~, blockStartTime(n,m), ~, ~, ~] = Screen('Flip',w, instructionEndTime + IBITime - flip_interval_correction);
        end
        
        % Record start of the block
        rawdata(trialCounter,7) = blockStartTime(n,m)-runStartTime(m);
        
        % Start trial loop for the block
        for j=1:repsPerBlock*2
            % Draw stimuli
            % Present stim.
            Screen('DrawTextures',w,ellipseTexture{n,j},[],ellipseCoords{n,j},ellipseOri{n,j});
            Screen('DrawTexture',w,fix_tex,[],fix_rect);
            %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
            [~, stimOnTime, ~, ~, ~] = Screen('Flip',w, (blockStartTime(n,m) - interBlockInterval) + initTrialTimeList(j,1) - flip_interval_correction);
            
            % Blank screen
            Screen('DrawTexture',w,blank_tex,[],rect);
            Screen('DrawTexture',w,fix_tex,[],fix_rect);
            %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
            [~, stimOffTime, ~, ~, ~] = Screen('Flip',w,stimOnTime + stimTime - flip_interval_correction);
            
            % Record stim on stim off for each trial
            trialStartTime(trialCounter,j,1) = stimOnTime;
            trialStartTime(trialCounter,j,2) = stimOffTime;
            trialStartTime(trialCounter,j,3) = round(stimOnTime-blockStartTime(n,m),6);
            trialStartTime(trialCounter,j,4) = round(stimOffTime-blockStartTime(n,m),6);
            trialStartTime(trialCounter,j,5) = round(stimOffTime - stimOnTime,6);
        end
        
        % Task
        % Ask participant how rightward tilted or how much larger the average
        % was compared to a single standard on a scale of 1-4, 1 being the same
        % 2-4 progressively more rightward/larger.
        if taskIdx==1   % orientation task
            text1='How much did the average ORIENTATION change?';
        elseif taskIdx==2
            text1='How much did the average SIZE change?';
        end
        text2='Use the ''1'' - ''4'' keys to indicate how much change you saw.';
        text3='''1'' being no change and ''4'' being max change.';
        
        width=RectWidth(Screen('TextBounds',w,text1));
        Screen('DrawText',w,text1,xc-width/2,yc-250,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text2));
        Screen('DrawText',w,text2,xc-width/2,yc-200,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text3));
        Screen('DrawText',w,text3,xc-width/2,yc-150,[0 0 0]);
        
        %         [~, blockEndTime, ~, ~, ~] = Screen('Flip',w,stimOffTime - flip_interval_correction);
        [~, responseStartTime(n,m), ~, ~, ~] = Screen('Flip',w,stimOffTime - flip_interval_correction);
        
        while 1
            
            % While the total time is less than time elapsed keep looping
            time_now = GetSecs;
            response_check = (time_now - responseStartTime(n,m)) > responseTime;
            
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
        
        % Did they say there was a change when there actually was one?
        if rawdata(trialCounter,3) == 1  % Ori task
            if (rawdata(trialCounter,8) == 1) && (rawdata(trialCounter,1) == 1)   % No change and they said no change
                rawdata(trialCounter,9) = 1;
            elseif (rawdata(trialCounter,8) == 2 || rawdata(trialCounter,8) == 3 || rawdata(trialCounter,8) == 4) &&...
                    (rawdata(trialCounter,1) == 2 || rawdata(trialCounter,1) == 3 || rawdata(trialCounter,1) == 4 || rawdata(trialCounter,1) == 5) % Change and they said change
                rawdata(trialCounter,9) = 1;
            else
                rawdata(trialCounter,9) = 0;
            end
        elseif rawdata(trialCounter,3) == 2   % Size task
            if (rawdata(trialCounter,8) == 1) && (rawdata(trialCounter,2) == 1)   % No change and they said no change
                rawdata(trialCounter,9) = 1;
            elseif (rawdata(trialCounter,8) == 2 || rawdata(trialCounter,8) == 3 || rawdata(trialCounter,8) == 4) &&...
                    (rawdata(trialCounter,2) == 2 || rawdata(trialCounter,2) == 3 || rawdata(trialCounter,2) == 4 || rawdata(trialCounter,2) == 5) % Change and they said change
                rawdata(trialCounter,9) = 1;
            else
                rawdata(trialCounter,9) = 0;
            end
        end
        
        % Close any remaining open textures to clear memory
        windowPointers = ellipseTexture{n,j};
        Screen('Close',windowPointers);
        
        firstBlock = 0;
        
        responseEndTime(n,m) = GetSecs-responseStartTime(n,m);
    end
    
    % Calculate total run time
    runEndTime(m) = GetSecs - runStartTime(m);
    
    % Close any remaining open textures to clear memory
    windowPointers = Screen('Windows');
    Screen('Close',windowPointers);
    
    % Save rawdata and flicker info after ever trial
    save(datafile,'rawdata','trialStartTime','blockStartTime','runStartTime','responseStartTime','trialOrder');
    % Save all data after each run in case of crash
    save(datafile_full);
end


% Save
save(datafile,'rawdata','trialStartTime','blockStartTime','runStartTime','responseStartTime','trialOrder');
save(datafile_full);

Screen('CloseAll');

if labComp == 0
    ShowCursor;
    ListenChar(0);
end


% Calculate some of the timing values to esure proper timing relative to the start of the run
% Start of each block
rawdata(trialCounter,7);
initBlockTimeList;

% Start of each IBI
ibiStartTime;   % Measured
initIBITimeList;   % Actual

% Start of each trial relative to block start
trialStartTime(trialCounter,j,3);   % Measured
initTrialTimeList;   % Actual

% Length of each run
runEndTime;   % Measured
totalRunTime;   % Actual




