

%% Initilization variables

clear all
close all

rng('shuffle')

labComp = 1;
lapComp = 0;
eegComp = 0;
netStation = 0;
DAQTimingTester = 0;

% Inputs
% buttonO = KbName('o');
% buttonN = KbName('n');
buttonEscape = KbName('escape');
buttonSpace = KbName('space');
buttonS = KbName('s');
buttonJ = KbName('j');
buttonF = KbName('f');
button1 = KbName('1!');
button2 = KbName('2@');
button3 = KbName('3#');
button4 = KbName('4$');

c = clock;
time_stamp = sprintf('%02d/%02d/%04d %02d:%02d:%02.0f',c(2),c(3),c(1),c(4),c(5),c(6)); % month/day/year hour:min:sec
datecode = datestr(now,'mmddyy');
experiment = 'Ens_VEP';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
if eegComp == 1
    datadir = '/Users/gideon/Documents/Kyle/R15 Distractor/Data/';
elseif labComp == 1
    datadir = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/';
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

if labComp == 0
    HideCursor;
    ListenChar(2);
end

if labComp == 1 || lapComp == 1
    %     Screen('Preference', 'SkipSyncTests', 1);
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
elseif lapComp == 1
    mon_width_cm = 43;
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
if presComp == 1
    dev_id=nums(strcmp(names,'Apple Keyboard'));
elseif labComp == 1 || lapComp == 1
    dev_id=nums(1);
end

screenWide=1024;
screenHigh=768;

%Get information about the current screen properties, and what to return
%the screen to after the experiment.
% oldScreen=Screen('Resolution',0);
% Set the correct values for SyncTest
[maxStddev, minSamples, maxDeviation, maxDuration] = Screen('Preference','SyncTestSettings' ,0.001,50,0.1,5);

% Set the Screen resolution and refresh rate to the values appropriate for
% your experiment;
if labComp == 1
    hz = 120;
    screenNum = 1;
elseif lapComp == 1
    hz = 85;
    screenNum = 0;
elseif eegComp == 1
    hz = 120;
    screenNum = 1;
    Screen('Resolution',screenNum,screenWide,screenHigh,hz);
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
orientationListIdx = [1 2 3 4 5];
nOri = length(orientationListIdx);
sizeListIdx = [1 2 3 4 5];
nSize = length(sizeListIdx);
taskList = [1 2];
nTask = length(taskList);

% Randomly determine what the order of presentation of blocks (task) will
% be, based on run #
if flickerTimingTester == 1 || DAQTimingTester == 1
    taskBlockChose = randi(2);
else
    [ensDataStruct] = ensLoadData('LoadVEP',subjid,runid);
    taskBlockChose = ensDataStruct.taskBlockChose;
end

taskBlockOrder = [taskBlockChose 3-taskBlockChose taskBlockChose 3-taskBlockChose taskBlockChose];

% Make lists
repetitions = 5;   % Number of repetitions per block
nBlocks = 5;   % Number of different blocks
trialsPerBlock = repetitions*nSize*nOri;

for i=1:nBlocks
    varList(i,:,:) = repmat(fullfact([nOri nSize]),[repetitions,1]);   % Get all combinations of conditions
    presOrder = randperm(length(varList));   % Randomize the order of presentation
    varList(i,:,:) = varList(i,presOrder,:);
end

trialOrder = squeeze([varList(1,:,:) varList(2,:,:) varList(3,:,:) varList(4,:,:) varList(5,:,:)]);

for i=1:length(taskBlockOrder)
    trialOrder((i*trialsPerBlock)-(trialsPerBlock-1):i*trialsPerBlock,3) = taskBlockOrder(i);
end

% Run number
trialOrder(:,4) = runid;

% On each trial alternate between more/less items
% Determine randomly what the starting amount for each trial will be
% 1=start more; 2=start less
numItemsList = [1 2];
nItems = length(numItemsList);
numItemsVarList = zeros(trialsPerBlock,5);
for i=1:nOri
    for j=1:nSize
        numItemsRandomizer = [randperm(nItems) randperm(nItems) randi(2)];
        numItemsVarList(trialOrder(1:trialsPerBlock,1)==i & trialOrder(1:trialsPerBlock,2)==j,1) = numItemsRandomizer;
        
        numItemsRandomizer = [randperm(nItems) randperm(nItems) randi(2)];
        numItemsVarList(trialOrder(trialsPerBlock+1:trialsPerBlock*2,1)==i & trialOrder(trialsPerBlock+1:trialsPerBlock*2,2)==j,2) = numItemsRandomizer;
        
        numItemsRandomizer = [randperm(nItems) randperm(nItems) randi(2)];
        numItemsVarList(trialOrder(trialsPerBlock*2+1:trialsPerBlock*3,1)==i & trialOrder(trialsPerBlock*2+1:trialsPerBlock*3,2)==j,3) = numItemsRandomizer;
        
        numItemsRandomizer = [randperm(nItems) randperm(nItems) randi(2)];
        numItemsVarList(trialOrder(trialsPerBlock*3+1:trialsPerBlock*4,1)==i & trialOrder(trialsPerBlock*3+1:trialsPerBlock*4,2)==j,4) = numItemsRandomizer;
        
        numItemsRandomizer = [randperm(nItems) randperm(nItems) randi(2)];
        numItemsVarList(trialOrder(trialsPerBlock*4+1:trialsPerBlock*5,1)==i & trialOrder(trialsPerBlock*4+1:trialsPerBlock*5,2)==j,5) = numItemsRandomizer;
    end
end
trialOrder(:,5) = [numItemsVarList(:,1); numItemsVarList(:,2); numItemsVarList(:,3); numItemsVarList(:,4); numItemsVarList(:,5)];


%% Stimulus variables

% Give participants a break in between blocks
break_trials = trialsPerBlock+1:trialsPerBlock:length(trialOrder);   % Each block contains 250 trials, so after every 50th trial give the participants a break. Only
instructionCounter = 1:trialsPerBlock:length(trialOrder);   % Determine when to present task instructions
impedenceCounter = length(trialOrder)/2 + 1;   % Half-way into the run pause to check impedences

% Amount of jitter
jitterAmount = 10;

% Size of one cell
cellSize = rect(4)/8;

% Timing vars
preBlockTime = 3;
preFixTime = 1;
stimTime = .3; % 300 ms
fixTimeStandard = randi([800,1200],1)/1000; % 800-1200 ms
fixTimeExtra = 2;

% Create the stimulus variables for orientation and size
% The maximum size of the largest circle should not allow the ellipse to
% move oustide of it cell. In DoVA
standardSize = 1;
standardOri = 270;

sizeVariance = .25;
% sizeList = [0 .1 .25 .5 1];
oriVariance = 10;
% oriList = [0 10 25 45 90];

if DAQTimingTester == 1
    sizeList = [0 .1 .25 .5 1];
    oriList = [0 10 25 45 90];
else
    oriList = ensDataStruct.oriList;
    sizeList = ensDataStruct.sizeList;
end

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

% Connect to NetStation
if netStation == 1
    NetStation('Connect', NS_host, NS_port)
    % NetStation('Synchronize', NS_synclimit)
    NetStation('StartRecording');
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
while 1
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    if  keycode(buttonS)
        KbReleaseWait(dev_id);
        break
    end
end

%% Practice
if DAQTimingTester == 0
    rawdataPractice = Ens_VEP_Practice(rect,w,button1,button2,button3,button4,flip_interval_correction,xc,yc,PPD,dev_id,runid,sizeList,oriList);
    
    text1='End of practice trials.';
    text2='Tell the experimener to start the experiment...';
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-50,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc+0,[0 0 0]);
    Screen('Flip',w);
    
    while 1
        [keyisdown, secs, keycode] = KbCheck(dev_id);
        if keycode(buttonS)
            KbReleaseWait(dev_id);
            break;
        end
    end
end

%% Experiment start

% Wait for the data to normalize
if netStation == 1
    Screen('Flip',w);
    WaitSecs(10);
end

[keyisdown, secs, keycode] = KbCheck(dev_id);
% while ~keycode(buttonEscape)
for n=1:length(trialOrder)
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    
    clear ellipseCoords ellipseSize ellipseOri oriIdx sizeIdx taskResponseHolder ellipseTexture
    
    % Determine the delta to be used for size and orientation
    % rawdata(1) = ori
    % rawdata(2) = size
    % rawdata(3) = task; 1=ori, 2=size
    % rawdata(4) = run number
    % rawdata(5) = number of items present; 1=less, 2=more
    oriIdx = trialOrder(n,1);
    rawdata(n,1) = oriIdx;
    sizeIdx = trialOrder(n,2);
    rawdata(n,2) = sizeIdx;
    taskIdx = trialOrder(n,3);
    rawdata(n,3) = taskIdx;
    runIdx = trialOrder(n,4);
    rawdata(n,4) = runIdx;
    itemsIdx = trialOrder(n,5);
    rawdata(n,5) = itemsIdx;
    
    % Blank screen texture
    blank_tex = Screen('MakeTexture',w,128*ones(1,1));
    
    % Fixation Texture
    fix_tex = Screen('MakeTexture',w,0*ones(1,1));
    
    % For photdiode timing testing
    if DAQTimingTester == 1
        photo_tex(1) = Screen('MakeTexture',w,zeros(1,1)+255);
        photo_tex(2) = Screen('MakeTexture',w,zeros(1,1));
        photo_rect=[xc-50,yc-50,xc+50,yc+50];
    else
        photo_tex(1) = Screen('MakeTexture',w,zeros(1,1));
        photo_tex(2) = Screen('MakeTexture',w,zeros(1,1));
        photo_rect = [xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];
    end
    
    % Don't have breaks if doing photodiode testing
    if DAQTimingTester == 0
        % Draw one reference ellipse at the standard size and orientaion
        ref_tex = Screen('MakeTexture',w,zeros([(round((standardSize+(sizeList(1)))*PPD))*2 round(((standardSize+(sizeList(1)))*PPD)/2)*2]) + 128);
        Screen('FrameOval',ref_tex,[0 0 0],[],5);
        
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
                elseif taskIdx == 2   % Size task
                    text1='Please pay attention to the average SIZE of the group.';
                    text2='The changes to the groups size might be large or small, or there might be no change.';
                    text3='Additionally, you should ignore any changes you might notice to the average orientation.';
                    text4='You will be asked to report any changes you may have seen at the end of the trial.';
                    text5='Specifically, you will be asked to determine how much LARGER the average of the group was';
                    text6='compared to an example ellipase shown after the trial. You will use the ''1'' - ''4''';
                    text7='keys to indicate how much larger it was. ''1'' being no difference,';
                    text8='''2'' - ''4'' being small to large difference respectively. Lastly, although you shouldn''t rush,';
                    text9='you will have 3 seconds per trial to respond, so do so as quickly as possible.';
                    text10='Press any key to begin the next trial...';
                end
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
                Screen('Flip',w);
                WaitSecs(1);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(dev_id);
                    if keyisdown
                        break;
                    end
                end
                Screen('DrawTextures',w,[fix_tex photo_tex(2)]',[],[fix_rect' photo_rect']);   % Fixation
                Screen('Flip',w);
                WaitSecs(preBlockTime);
            end
        end
        
        % Set up a stopping point half way to check impedances
        for b = impedenceCounter
            if n == b
                text1='IMPEDENCE CHECK!';
                text2='Please tell the experimenter...';
                
                width=RectWidth(Screen('TextBounds',w,text1));
                Screen('DrawText',w,text1,xc-width/2,yc-150,[0 0 0]);
                width=RectWidth(Screen('TextBounds',w,text2));
                Screen('DrawText',w,text2,xc-width/2,yc-100,[0 0 0]);
                Screen('Flip',w);
                WaitSecs(1);
                while 1
                    [keyisdown, secs, keycode] = KbCheck(dev_id);
                    if keyisdown
                        break;
                    end
                end
            end
        end
    end
    
    % Clear screen
    Screen('DrawTextures',w,[fix_tex photo_tex(2)]',[],[fix_rect' photo_rect']);   % Fixation
    Screen('Flip',w);
    WaitSecs(preFixTime);
    
    % Preallocate stim presentations before each trial
    
    % Determine the number of items that will be presented.
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
    
    clear ellipseOriHolder
    ellipseOriHolder=randn(4,numItemsPerQuad);
    ellipseOriHolder=ellipseOriHolder-mean(ellipseOriHolder,2);
    ellipseOriHolder=ellipseOriHolder./(std(ellipseOriHolder,0,2));
    ellipseOriHolder=ellipseOriHolder.*oriVariance;
    ellipseOriHolder=ellipseOriHolder+((standardOri+(oriList(oriIdx))));
    ellipseOri{n}=reshape(ellipseOriHolder',[1,currentNumItems]);
    
    % Determine size
    clear ellipseSizeHolder
    ellipseSizeHolder=randn(4,numItemsPerQuad);
    ellipseSizeHolder=ellipseSizeHolder-mean(ellipseSizeHolder,2);
    ellipseSizeHolder=ellipseSizeHolder./(std(ellipseSizeHolder,0,2));
    ellipseSizeHolder=ellipseSizeHolder.*sizeVariance*PPD  ;
    ellipseSize{n}=ellipseSizeHolder+((standardSize+(sizeList(sizeIdx)))*PPD);
    
    % Add in positional jitter for x and y directions
    xJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
    yJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
    
    xSize = round(ellipseSize{n}./2);
    ySize = round(xSize/2);
    
    % Create the coords for the ellipses
    ellipseCoords{n} = [[blockCenterCoords(quadPosition(1,:),1,1); blockCenterCoords(quadPosition(2,:),1,2); blockCenterCoords(quadPosition(3,:),1,3); blockCenterCoords(quadPosition(4,:),1,4)]' - [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)] + [xJitter(1,:) xJitter(2,:) xJitter(3,:) xJitter(4,:)];...
        [blockCenterCoords(quadPosition(1,:),2,1); blockCenterCoords(quadPosition(2,:),2,2); blockCenterCoords(quadPosition(3,:),2,3); blockCenterCoords(quadPosition(4,:),2,4)]' - [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)] + [yJitter(1,:) yJitter(2,:) yJitter(3,:) yJitter(4,:)];...
        [blockCenterCoords(quadPosition(1,:),1,1); blockCenterCoords(quadPosition(2,:),1,2); blockCenterCoords(quadPosition(3,:),1,3); blockCenterCoords(quadPosition(4,:),1,4)]' + [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)] + [xJitter(1,:) xJitter(2,:) xJitter(3,:) xJitter(4,:)];...
        [blockCenterCoords(quadPosition(1,:),2,1); blockCenterCoords(quadPosition(2,:),2,2); blockCenterCoords(quadPosition(3,:),2,3); blockCenterCoords(quadPosition(4,:),2,4)]' + [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)] + [yJitter(1,:) yJitter(2,:) yJitter(3,:) yJitter(4,:)]];
    
    counter=1;
    xSizeVector = [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)];
    ySizeVector = [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)];
    for k=1:length(ellipseCoords{n})
        
        % Create a single texture ellipse using the xSize/YSize that can be
        % individually rotated
        ellipseTexture{n}(k) = Screen('MakeTexture', w, zeros([xSizeVector(counter)*4 ySizeVector(counter)*4]) + 128);
        
        % Draw all the circles onto the texture
        Screen('FrameOval',ellipseTexture{n}(k),[0 0 0],[],5);
        %             Screen('FrameRect',ellipseTexture{i}(k),[0 0 0],[],5);
        
        counter = counter+1;
        
    end
    
    % Send TTL Pulse
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % Send the TTL pulse
    if netStation == 1
        DaqDOut(trigDevice,0,2)
        WaitSecs(TTL_pulse_dur);
        DaqDOut(trigDevice,0,0)
    end
    
    Screen('DrawTextures',w,[fix_tex photo_tex(1)]',[],[fix_rect' photo_rect']);
    sync_time= Screen('Flip',w);
    
    % Draw stimuli
    % Present stim.
    Screen('DrawTextures',w,[ellipseTexture{n} fix_tex photo_tex(2)]',[],[ellipseCoords{n}' fix_rect' photo_rect'],[llipseOri{n} 0 0]);
    %     Screen('DrawTexture',w,fix_tex,[],fix_rect);
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
    [~, stimOnTime, ~, ~, ~] = Screen('Flip',w,sync_time - flip_interval_correction);
    
    % Blank screen
    Screen('DrawTexture',w,[blank_tex fix_tex photo_tex(2)]',[],[rect' fix_rect' photo_rect']);
    %     Screen('DrawTexture',w,fix_tex,[],fix_rect);
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
    [~, stimOffTime, ~, ~, ~] = Screen('Flip',w,stimOnTime + stimTime - flip_interval_correction);
    
    % Record stim on stim off
    rawdata(n,6) = stimOnTime;
    rawdata(n,7) = stimOffTime;
    
    % Task
    if DAQTimingTester == 0
        % Ask participant how rightward tilted or how much larger the average
        % was compared to a single standard on a scale of 1-4, 1 being the same
        % 2-4 progressively more rightward/larger.
        if taskIdx==1   % orientation task
            text1='Was the average more rightward tilted than the reference ellipse?';
        elseif taskIdx==2
            text1='Was the average larger than the reference ellipse?';
        end
        text2='Use the ''1'' - ''4'' keys to indicate how much change you saw.';
        text3='''1'' being no change and ''4'' being max change.';
        
        width=RectWidth(Screen('TextBounds',w,text1));
        Screen('DrawText',w,text1,xc-width/2,yc-250,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text2));
        Screen('DrawText',w,text2,xc-width/2,yc-200,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text3));
        Screen('DrawText',w,text3,xc-width/2,yc-150,[0 0 0]);
        
        % Draw one reference ellipse at the standard size and orientaion
        Screen('DrawTexture',w,ref_tex,[],[xc-((standardSize+(sizeList(1)))*PPD)/2 yc-(((standardSize+(sizeList(1)))*PPD)/2)/2 ...
            xc+((standardSize+(sizeList(1)))*PPD)/2 yc+(((standardSize+(sizeList(1)))*PPD)/2)/2 ],(standardOri+(oriList(1))));
        %     text1=sprintf('%d',oriIdx);
        %     text2=sprintf('%d',sizeIdx);
        %     width=RectWidth(Screen('TextBounds',w,text1));
        %     Screen('DrawText',w,text1,width,yc-300,[0 0 0]);
        %     width=RectWidth(Screen('TextBounds',w,text2));
        %     Screen('DrawText',w,text2,width,yc-250,[0 0 0]);
        Screen('Flip',w);
        
        fixStartTime = GetSecs;
        responseBreak = 0;
        while 1
            
            % While the total time is less than time elapsed keep looping
            time_now = GetSecs;
            response_check_extra = (time_now - fixStartTime) > fixTimeStandard+fixTimeExtra;
            response_check_standard = (time_now - fixStartTime) > fixTimeStandard;
            
            [keyisdown, secs, keycode] = KbCheck(dev_id);
            switch response_check_extra
                case 0
                    if keycode(button1)
                        rawdata(n,8) = 1;
                        responseBreak = 1;
                    elseif keycode(button2)
                        rawdata(n,8) = 2;
                        responseBreak = 1;
                    elseif keycode(button3)
                        rawdata(n,8) = 3;
                        responseBreak = 1;
                    elseif keycode(button4)
                        rawdata(n,8) = 4;
                        responseBreak = 1;
                    end
                    switch responseBreak & response_check_standard
                        case 1
                            break
                        otherwise
                    end
                case 1
                    rawdata(n,8) = 0;   % 0=no response
                    break
            end
        end
        
        Priority(0);
        
        % Feedback: Did they get it correct?
        % Did they say there was a change when there actually was one?
        if rawdata(n,3) == 1  % Ori task
            if (rawdata(n,8) == 1) && (rawdata(n,1) == 1)   % No change and they said no change
                rawdata(n,9) = 1;
            elseif (rawdata(n,8) == 2 || rawdata(n,8) == 3 || rawdata(n,8) == 4) &&...
                    (rawdata(n,1) == 2 || rawdata(n,1) == 3 || rawdata(n,1) == 4 || rawdata(n,1) == 5) % Change and they said change
                rawdata(n,9) = 1;
            else
                rawdata(n,9) = 0;
            end
        elseif rawdata(n,3) == 2   % Size task
            if (rawdata(n,8) == 1) && (rawdata(n,2) == 1)   % No change and they said no change
                rawdata(n,9) = 1;
            elseif (rawdata(n,8) == 2 || rawdata(n,8) == 3 || rawdata(n,8) == 4) &&...
                    (rawdata(n,2) == 2 || rawdata(n,2) == 3 || rawdata(n,2) == 4 || rawdata(n,2) == 5) % Change and they said change
                rawdata(n,9) = 1;
            else
                rawdata(n,9) = 0;
            end
        end
    end
    
    % Close any remaining open textures to clear memory
    windowPointers = Screen('Windows');
    Screen('Close',windowPointers);
    
    % Save rawdata and flicker info after ever trial
    save(datafile,'rawdata');
    
end

% Save
save(datafile,'rawdata','rawdataPractice');
save(datafile_full);

Screen('CloseAll');

if labComp == 0
    ShowCursor;
    ListenChar(0);
end







