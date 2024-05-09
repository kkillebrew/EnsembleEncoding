% 072618

%% Initilization variables

% clear workspace and close open matlab windown
clear all
close all

rng('shuffle')

labComp = 1;
lapComp = 0;
eegComp = 0;
netStation = 0;
DAQTimingTester = 0;
flickerTimingTester = 1;

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
experiment = 'Ens_FFTOddball_DualStream';

% get input
subjid = input('Enter Subject Code:','s');
runid  = input('Enter Run:');
if eegComp == 1
    datadir = '/Users/gideon/Documents/Kyle/R15 Distractor/Data/';
elseif labComp == 1
    datadir = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/';
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
dev_id=nums(1);

screenWide=1024;
screenHigh=768;

%Get information about the current screen properties, and what to return
%the screen to after the experiment.
% oldScreen=Screen('Resolution',0);
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

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

%% Trial variables
orientationList = [1 2 3 4 5];
nOri = length(orientationList);
sizeList = [1 2 3 4 5];
nSize = length(sizeList);
taskList = [1 2];
nTask = length(taskList);
attendList = [1];   % Only attend to one side per run
nAttend = length(attendList);

% Use initial user input to determine which side needs to be attended
% load();

% Make lists
repetitions = 1;   % Number of repetitions per block
nBlocks = 4;   % Number of different blocks
trialsPerBlock = repetitions*nSize*nOri;

% Randomly determine what the order of presentation of blocks (task) will be
taskBlockChose = randi(2);
taskBlockOrder = [taskBlockChose 3-taskBlockChose taskBlockChose 3-taskBlockChose];

% Randomly determine what side will be attended for this run
if runid == 1
    dirAttend = randi(2);   % 1=left 2=right
elseif runid == 2
    % On the second run, load in the last run to check the attended direction
    datafile=sprintf('%s_%s_%s_%03d',subjid,experiment,runid);
    load(sprintf('%s_%s_%s_%03d',subjid,experiment,1),'rawdata');
    oldDirAttend = rawdata(1,4);
    clear rawdata
    dirAttend = oldDirAttend;
end

for i=1:nBlocks
    varList(i,:,:) = repmat(fullfact([nOri nSize]),[repetitions,1]);   % Get all combinations of conditions
    presOrder = randperm(length(varList));   % Randomize the order of presentation
    varList(i,:,:) = varList(i,presOrder,:);
end

trialOrder = squeeze([varList(1,:,:) varList(2,:,:) varList(3,:,:) varList(4,:,:)]);

for i=1:length(taskBlockOrder)
    trialOrder((i*trialsPerBlock)-(trialsPerBlock-1):i*trialsPerBlock,3) = taskBlockOrder(i);
end

trialOrder(:,4) = dirAttend;

% On each trial alternate between more/less items
% Determine randomly what the starting amount for each trial will be
% 1=start more; 2=start less
numItemsList = [1 2];
nItems = length(numItemsList);
numItemsVarList = zeros(25,4);
for i=1:nOri
    for j=1:nSize
        numItemsVarList(trialOrder(1:25,1)==i & trialOrder(1:25,2)==j,1) = randi(2);
        numItemsVarList(trialOrder(26:50,1)==i & trialOrder(26:50,2)==j,2) = randi(2);
        numItemsVarList(trialOrder(51:75,1)==i & trialOrder(51:75,2)==j,3) = randi(2);
        numItemsVarList(trialOrder(76:100,1)==i & trialOrder(76:100,2)==j,4) = randi(2);
    end
end
trialOrder(:,5) = [numItemsVarList(:,1); numItemsVarList(:,2); numItemsVarList(:,3); numItemsVarList(:,4)];

% Randomly determine which stim gets which baseline rate for each trial
% 1=left faster; 2=rightfaster
chosenStimRate(:,1) = repmat(fullfact([2]),[length(trialOrder)/2,1]);
chosenStimRate(:,1) = chosenStimRate(randperm(length(chosenStimRate)));
% Randomly determine which OB rates will be assigned to which features for the left side
% 1=1st freq ori; 2=1st freq size
chosenStimRate(:,2) = repmat(fullfact([2]),[length(trialOrder)/2,1]);
chosenStimRate(:,2) = chosenStimRate(randperm(length(chosenStimRate)),2);
% Randomly determine which OB rates will be assigned to which features for the right side
% 1=1st freq ori; 2=2nd freq size
chosenStimRate(:,3) = repmat(fullfact([2]),[length(trialOrder)/2,1]);
chosenStimRate(:,3) = chosenStimRate(randperm(length(chosenStimRate)),2);

%% Stimulus variables

% Give participants a break in between blocks
break_trials = 51:50:length(trialOrder);   % Each block contains 50 trials, so after every 50th trial give the participants a break. Only
instructionCounter = 1:50:length(trialOrder);   % Determine when to present task instructions

% Amount of jitter
jitterAmount = 10;

% Size of one cell
cellSize = rect(4)/8;

% Timing variables
totalTrialTime = 20;

% Create the stimulus variables for orientation and size
% The maximum size of the largest circle should not allow the ellipse to
% move oustide of it cell. In DoVA
standardSize = 1;
standardOri = 270;

sizeVariance = .25;
sizeList = [0 .1 .25 .5 1];
oriVariance = 10;
oriList = [0 10 25 45 90];

numItemArray = [36 44];   % Number of items present

fix_size = 5;   % Fixaiton size (in pixels)
fix_rect =[xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];

% Flicker Frequency Rates (3 Hz, .5 Hz, .3 Hz; )
stim_rate_BL(1) = 3;
stim_rate_BL(2) = 5;
stim_rate_OB(1,1) = .6;
stim_rate_OB(1,2) = .75;
stim_rate_OB(2,1) = .8;
stim_rate_OB(2,2) = 2;

% Calculate the total stim presentations in a trial given total time and flicker rate
StimPresBL(1) = totalTrialTime*stim_rate_BL(1);
StimPresBL(2) = totalTrialTime*stim_rate_BL(2);
StimPresOB(1,1) = totalTrialTime*stim_rate_OB(1,1);
StimPresOB(1,2) = totalTrialTime*stim_rate_OB(1,2);
StimPresOB(2,1) = totalTrialTime*stim_rate_OB(2,1);
StimPresOB(2,2) = totalTrialTime*stim_rate_OB(2,2);

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
text1='You will be shown groups of rapidly changing ellipses.';
text2='Each group will have an average orientation and size.';
text3='The ellipses on the left and right side of the center of the screen';
text4='will change at different rates. For this experiment you will attend to the ellipses on';
if dirAttend == 1
    text5='the LEFT side of the group, and ignore the ellipses on the right side.';
    text6='In addition to only attending to the left, you will also only pay attention to one of the two';
elseif dirAttend == 2
    text5='the RIGHT side of the group, and ignore the ellipses on the left side.';
    text6='In addition to only attending to the right, you will also only pay attention to one of the two';
end
text7='features: either the average orientation or size. This averaging task';
text8='will change in blocks of 25 trials. Before the begining of each block,';
text9='instructions will appear to let you know what task you will be doing.';
text10='Lastly, make sure you maintain fixation on the fixation dot in the';
text11='center of the screen, and only attend covertly.';
text12='Let''s start with some practice trials.';
text13='Tell the experimenter when you are ready to start...' ;

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
while 1
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    if  keycode(buttonS)
        KbReleaseWait(dev_id);
        break
    end
end

%% Practice
% [rawdataPractice] = Ens_FFTOddball_DualStream_Practice(rect,w,button1,button2,button3,button4,xc,yc,PPD,dev_id,hz,dirAttend);

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
    % rawdata(4) = attention direction; 1=left, 2=right
    % rawdata(5) = number of items present; 1=start more; 2=start less
    oriIdx = trialOrder(n,1);
    rawdata(n,1) = oriIdx;
    sizeIdx = trialOrder(n,2);
    rawdata(n,2) = sizeIdx;
    taskIdx = trialOrder(n,3);
    rawdata(n,3) = taskIdx;
    attendIdx = trialOrder(n,4);
    rawdata(n,4) = attendIdx;
    itemsIdx = trialOrder(n,5);
    rawdata(n,5) = itemsIdx;
    
    % Blank screen texture
    blank_tex = Screen('MakeTexture',w,128*ones(1,1));
    
    % Fixation Texture
    fix_tex = Screen('MakeTexture',w,0*ones(1,1));
    
    % For photdiode timing testing
    if DAQTimingTester == 1 || flickerTimingTester == 1
        photo_tex(1) = Screen('MakeTexture',w,zeros(1,1)+255);
        photo_tex(2) = Screen('MakeTexture',w,zeros(1,1));
        photo_rect=[xc-50,yc-50,xc+50,yc+50];
    else
        photo_tex(1) = Screen('MakeTexture',w,zeros(1,1));
        photo_tex(2) = Screen('MakeTexture',w,zeros(1,1));
        photo_rect = [xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];
    end
    
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
                if dirAttend == 1
                    text2='Look for any changes on the ATTENDED (LEFT) side of the screen only.';
                elseif dirAttend == 2
                    text2='Look for any changes on the ATTENDED (RIGHT) side of the screen only.';
                end
                text3='The changes to the groups orientation might be large or small, or there might be no change.';
                text4='Additionally, the changes might not occur on every new presentation. In other words, although';
                text5='the individual ellipses might change, the average orientation remains the same.';
                text6='Ignore any changes you might notice to average size.';
                text7='You will be asked to report any changes you may have seen at the end of the trial.';
                text8='Get ready for the next trial...' ;
            elseif taskIdx == 2   % Size task
                text1='Please pay attention to the average SIZE of the group.';
                if dirAttend == 1
                    text2='Look for any changes on the ATTENDED (LEFT) side of the screen only.';
                elseif dirAttend == 2
                    text2='Look for any changes on the ATTENDED (RIGHT) side of the screen only.';
                end
                text3='The changes to the groups size might be large or small, or there might be no change.';
                text4='Additionally, the changes might not occur on every new presentation. In other words, although';
                text5='the individual ellipses might change, the average size remains the same.';
                text6='Ignore any changes you might notice to average orientation.';
                text7='You will be asked to report any changes you may have seen at the end of the trial.';
                text8='Get ready for the next trial...' ;
            end
            width=RectWidth(Screen('TextBounds',w,text1));
            Screen('DrawText',w,text1,xc-width/2,yc-200,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text2));
            Screen('DrawText',w,text2,xc-width/2,yc-150,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text3));
            Screen('DrawText',w,text3,xc-width/2,yc-100,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text4));
            Screen('DrawText',w,text4,xc-width/2,yc-50,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text5));
            Screen('DrawText',w,text5,xc-width/2,yc+0,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text6));
            Screen('DrawText',w,text6,xc-width/2,yc+50,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text7));
            Screen('DrawText',w,text7,xc-width/2,yc+100,[0 0 0]);
            width=RectWidth(Screen('TextBounds',w,text8));
            Screen('DrawText',w,text8,xc-width/2,yc+150,[0 0 0]);
            Screen('Flip',w);
            while 1
                [keyisdown, secs, keycode] = KbCheck(dev_id);
                if keyisdown
                    break;
                end
            end
            Screen('DrawTextures',w,[fix_tex photo_tex(2)]',[],[fix_rect' photo_rect']);   % Fixation
            Screen('Flip',w);
            WaitSecs(2);
        end
    end
    
    % Present pre stimulus attention cue
    if dirAttend==1
        Screen('DrawLines',w,[xc-15,yc-20;xc+15,yc-20;...
            xc-14,yc-20;xc-4,yc-30;...
            xc-14,yc-20;xc-4,yc-10]',4,[0 0 0]);
    elseif dirAttend==2
        Screen('DrawLines',w,[xc-15,yc-20;xc+15,yc-20;...
            xc+14,yc-20;xc+4,yc-30;...
            xc+14,yc-20;xc+4,yc-10]',4,[0 0 0]);
    end
    Screen('DrawTextures',w,[fix_tex photo_tex(2)]',[],[fix_rect' photo_rect']);   % Fixation
    Screen('Flip',w);
    
    % Determine how many different stimulus presentations necessary for
    % this trial for either side of the screen
    if chosenStimRate(n,1) == 1   % If BL rate chosen for this trial is 1, present left as faster rate
        
        baselineStimPres(1) = StimPresBL(2);   % Baseline rate left
        baselineStimPres(2) = StimPresBL(1);   % Baseline rate right
        % Calculate the time each stim should be on the screen given frequency rate
        rateBL(1)=1/(2*stim_rate_BL(2));
        rateBL(2)=1/(2*stim_rate_BL(1));
        
        % Assign the randomly determined OB freqs for left
        % oddballStimPres = feature (1=ori,2=size) x side (1=left,2=right)
        if chosenStimRate(n,2) == 1   % For left side; faster rate=ori, slower rate=size
            oddballStimPres(1,1) = StimPresOB(2,2);
            oddballStimPres(2,1) = StimPresOB(2,1);
        elseif chosenStimRate(n,2) == 2   % For left side; faster rate=size, slower rate=ori
            oddballStimPres(1,1) = StimPresOB(2,1);
            oddballStimPres(2,1) = StimPresOB(2,2);
        end
        
        % Assign the randomly determined OB freqs for right
        % oddballStimPres = trial x feature (1=ori,2=size) x side (1=left,2=right)
        if chosenStimRate(n,3) == 1   % For right side; faster rate=ori, slower rate=size
            oddballStimPres(1,2) = StimPresOB(1,2);
            oddballStimPres(2,2) = StimPresOB(1,1);
        elseif chosenStimRate(n,3) == 2
            oddballStimPres(1,2) = StimPresOB(1,1);
            oddballStimPres(2,2) = StimPresOB(1,2);
        end
        
    elseif chosenStimRate(n,1) == 2   % If BL rate chosen for this trial is 2, present right as faster rate
        
        baselineStimPres(1) = StimPresBL(1);   % Baseline rate left
        baselineStimPres(2) = StimPresBL(2);   % Baseline rate right
        % Calculate the time each stim should be on the screen given frequency rate
        rateBL(1)=1/(2*stim_rate_BL(1));
        rateBL(2)=1/(2*stim_rate_BL(2));
        
        % Assign the randomly determined OB freqs for left
        % oddballStimPres = trial x feature (1=ori,2=size) x side (1=left,2=right)
        if chosenStimRate(n,2) == 1   % For left side; faster rate=ori, slower rate=size
            oddballStimPres(1,1) = StimPresOB(1,2);
            oddballStimPres(2,1) = StimPresOB(1,1);
        elseif chosenStimRate(n,2) == 2   % For left side; faster rate=size, slower rate=ori
            oddballStimPres(1,1) = StimPresOB(1,1);
            oddballStimPres(2,1) = StimPresOB(1,2);
        end
        
        % Assign the randomly determined OB freqs for right
        % oddballStimPres = feature (1=ori,2=size) x side (1=left,2=right)
        if chosenStimRate(n,3) == 1   % For right side; faster rate=ori, slower rate=size
            oddballStimPres(1,2) = StimPresOB(2,2);
            oddballStimPres(2,2) = StimPresOB(2,1);
        elseif chosenStimRate(n,3) == 2
            oddballStimPres(1,2) = StimPresOB(2,1);
            oddballStimPres(2,2) = StimPresOB(2,2);
        end
        
    end
    
    % Preallocate regular stim presentations
    for j=1:2   % Determine left side then right side
        
        sizeCount=0;
        oriCount=0;
        
        % Determine how many items you will show for this stim pres
        if itemsIdx == 1   % Start the trial with more items
            numItemsHolder = 2;
        elseif itemsIdx == 2   % Start the trial with less items
            numItemsHolder = 1;
        end
        
        texArrayCounter = 0;
        
        for i=1:baselineStimPres(j)+1   % Make separte textures for gray stim
            clear xSizeVector ySizeVector xSize ySize xJitter yJitter
            for m=1:2   % Duplicate the texture arrays w/ blank textures
                
                % Every other array will be gray (blank)
                if m==1
                    ellipseColor=[0 0 0];
                elseif m==2
                    ellipseColor=[128 128 128];
                end
                
                texArrayCounter = texArrayCounter + 1;
                
                if m==1
                    % Check to see if this presentation is a condition change
                    sizeCount=sizeCount+1;   % Check to see if this is a size change trial and update the size index value
                    oriCount=oriCount+1;   % Check to see if this is a size change trial and update the size index value
                    % oddballStimPres = feature (1=ori,2=size) x side (1=left,2=right)
                    if rem(oriCount,oddballStimPres(1,j)) == 0 && rem(sizeCount,oddballStimPres(2,j)) == 0
                        sizeIdxHolder(n,i,j) = sizeIdx;
                        oriIdxHolder = oriIdx;
                    elseif rem(oriCount,oddballStimPres(1,j)) == 0
                        sizeIdxHolder(n,i,j) = 1;
                        oriIdxHolder = oriIdx;
                    elseif rem(sizeCount,oddballStimPres(2,j)) == 0
                        sizeIdxHolder(n,i,j) = sizeIdx;
                        oriIdxHolder = 1;
                    else
                        sizeIdxHolder(n,i,j) = 1;
                        oriIdxHolder = 1;
                    end
                    
                    % Determine the number of items that will be presented based on numItems.
                    currentNumItems = numItemArray(numItemsHolder)/2;
                    numItemsPerQuad = floor(currentNumItems/2);
                    
                    % Distribute the items evenly throughout each qadrant. Randomly choose a
                    % quadrant to start in and randomly chose a cell to place the item in,
                    % then move around the grid chosing cells in each quadrant until there
                    % are no more items.
                    clear quadPosition
                    if j==1   % Left side of screen
                        quadPosition(1,:) = datasample(1:15, numItemsPerQuad, 'Replace', false);
                        quadPosition(2,:) = datasample([1:3,5:15], numItemsPerQuad, 'Replace', false);
                    elseif j==2   % Right side of screen
                        quadPosition(1,:) = datasample([1:12,14:15], numItemsPerQuad, 'Replace', false);
                        quadPosition(2,:) = datasample(2:15, numItemsPerQuad, 'Replace', false);
                    end
                    
                    % Determine orientation
                    clear ellipseOriHolder
                    ellipseOriHolder=randn(2,numItemsPerQuad);
                    ellipseOriHolder=ellipseOriHolder-mean(ellipseOriHolder,2);
                    ellipseOriHolder=ellipseOriHolder./(std(ellipseOriHolder,0,2));
                    ellipseOriHolder=ellipseOriHolder.*oriVariance;
                    %             ellipseOri{i}=reshape(ellipseOriHolder',[1,currentNumItems]);
                    
                    % Determine size
                    clear ellipseSizeHolder
                    ellipseSizeHolder=randn(2,numItemsPerQuad);
                    ellipseSizeHolder=ellipseSizeHolder-mean(ellipseSizeHolder,2);
                    ellipseSizeHolder=ellipseSizeHolder./(std(ellipseSizeHolder,0,2));
                    ellipseSizeHolder=ellipseSizeHolder.*sizeVariance*PPD  ;
                    ellipseSize{texArrayCounter}=ellipseSizeHolder+((standardSize+(sizeList(sizeIdxHolder(n,i,j))))*PPD);
                    
                    
                    % Add in positional jitter for x and y directions (only
                    % every other array)
                    xJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
                    yJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
                    
                    xSize = ellipseSize{texArrayCounter}./2;
                    ySize = xSize/2;
                    
                    % Switch the number of items present every other stim array
                    numItemsHolder = 3-numItemsHolder;
                end
                
                % Create ori array outside of if
                ellipseOri{j}{texArrayCounter}=ellipseOriHolder+((standardOri+(oriList(oriIdxHolder))));
                
                % Determine which coords from blockCenterCoords you want to use
                % based on which side of the screen is being calculated (quads
                % 1 and 4 or quads 2 and 3.
                if j==1
                    quadSelect = [1 4];
                elseif j==2
                    quadSelect = [2 3];
                end
                
                ellipseCoords{j}{texArrayCounter} = [[blockCenterCoords(quadPosition(1,:),1,quadSelect(1)); blockCenterCoords(quadPosition(2,:),1,quadSelect(2))]' - [xSize(1,:) xSize(2,:)] + [xJitter(1,:) xJitter(2,:)];...
                    [blockCenterCoords(quadPosition(1,:),2,quadSelect(1)); blockCenterCoords(quadPosition(2,:),2,quadSelect(2))]' - [ySize(1,:) ySize(2,:)] + [yJitter(1,:) yJitter(2,:)];...
                    [blockCenterCoords(quadPosition(1,:),1,quadSelect(1)); blockCenterCoords(quadPosition(2,:),1,quadSelect(2))]' + [xSize(1,:) xSize(2,:)] + [xJitter(1,:) xJitter(2,:)];...
                    [blockCenterCoords(quadPosition(1,:),2,quadSelect(1)); blockCenterCoords(quadPosition(2,:),2,quadSelect(2))]' + [ySize(1,:) ySize(2,:)] + [yJitter(1,:) yJitter(2,:)]];
                
                counter=1;
                xSizeVector = round([xSize(1,:) xSize(2,:)]);
                ySizeVector = round([ySize(1,:) ySize(2,:)]);
                for k=1:length(ellipseCoords{j}{texArrayCounter})
                    
                    % Create a single texture ellipse using the xSize/YSize that can be
                    % individually rotated
                    ellipseTexture{j}{texArrayCounter}(k) = Screen('MakeTexture', w, zeros([xSizeVector(counter)*4 ySizeVector(counter)*4]) + 128);
                    ellipseTexture{j}{texArrayCounter}(k) = Screen('MakeTexture', w, zeros([xSizeVector(counter)*4 ySizeVector(counter)*4]) + 128);
                    
                    % Draw all the circles onto the texture
                    Screen('FrameOval',ellipseTexture{j}{texArrayCounter}(k),ellipseColor,[],5);
                    %             Screen('FrameRect',ellipseTexture{i}(k),[0 0 0],[],5);
                    
                    counter = counter+1;
                    
                end
            end
        end
    end
    
    % Variable that determines whether or not a screen flip is
    % necessary
    check = 0;
    stimPresCounter1=1;
    stimPresCounter2=1;
    %     taskResponseCounter = 1;
    
    % Sets which phase of flicker the image is in.
    flip1 = 1;
    flip2 = 1;
    flipPhoto = 2;
    
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
        
    Screen('DrawTextures',w,[ellipseTexture{1}{stimPresCounter1} ellipseTexture{2}{stimPresCounter2} fix_tex photo_tex(1)],[],...
        [ellipseCoords{1}{stimPresCounter1} ellipseCoords{2}{stimPresCounter2} fix_rect' photo_rect'],...
        [ellipseOri{1}{stimPresCounter1}(1,:) ellipseOri{1}{stimPresCounter1}(2,:)...
        ellipseOri{2}{stimPresCounter2}(1,:) ellipseOri{2}{stimPresCounter2}(2,:) 0 0]);
    
    Screen('DrawingFinished',w,2);
    
    run_start=Screen('Flip',w,sync_time,2);
    
    % Determine slip for each of the stimuli
    t1 = run_start;
    t2 = t1;
    
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
                rate1_check = (time_now - t1) > rateBL(1)-1/hz;
                rate2_check = (time_now - t2) > rateBL(2)-1/hz;
                
                switch rate1_check
                    case 1
                        flip1 =  3-flip1;
                        switch flickerTimingTester
                            case 1
                                flipPhoto = 3-flipPhoto;
                        end
                        t1=t1+rateBL(1);
                        check =1;
                        stimPresCounter1 = stimPresCounter1+1;
                    otherwise
                end
                switch rate2_check
                    case 1
                        flip2 =  3-flip2;
                        t2=t2+rateBL(2);
                        check =1;
                        stimPresCounter2 = stimPresCounter2+1;
                    otherwise
                end
                
                %Update changes on the screen
                
                switch check
                    
                    case 1   % Draw the stimuli
                        
                        Screen('DrawTextures',w,[ellipseTexture{1}{stimPresCounter1} ellipseTexture{2}{stimPresCounter2} fix_tex photo_tex(flipPhoto)],[],...
                            [ellipseCoords{1}{stimPresCounter1} ellipseCoords{2}{stimPresCounter2} fix_rect' photo_rect'],...
                            [ellipseOri{1}{stimPresCounter1}(1,:) ellipseOri{1}{stimPresCounter1}(2,:)...
                            ellipseOri{2}{stimPresCounter2}(1,:) ellipseOri{2}{stimPresCounter2}(2,:) 0 0]);
                        
%                         text1=sprintf('%d',oriIdx);
%                         text2=sprintf('%d',sizeIdx);
%                         text3=sprintf('%d',baselineStimPres(1));
%                         text4=sprintf('%d',baselineStimPres(2));
%                         text5=sprintf('%d',round(oddballStimPres(1,1)));
%                         text6=sprintf('%d',round(oddballStimPres(2,1)));
%                         text7=sprintf('%d',round(oddballStimPres(1,2)));
%                         text8=sprintf('%d',round(oddballStimPres(2,2)));
%                         
%                         width=RectWidth(Screen('TextBounds',w,text1));
%                         Screen('DrawText',w,text1,width,150,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text2));
%                         Screen('DrawText',w,text2,rect(3)-width-5,150,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text3));
%                         Screen('DrawText',w,text3,width,200,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text4));
%                         Screen('DrawText',w,text4,rect(3)-width-5,200,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text5));
%                         Screen('DrawText',w,text5,width,250,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text6));
%                         Screen('DrawText',w,text6,width,300,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text7));
%                         Screen('DrawText',w,text7,rect(3)-width-5,250,[0 0 0]);
%                         width=RectWidth(Screen('TextBounds',w,text8));
%                         Screen('DrawText',w,text8,rect(3)-width-5,300,[0 0 0]);
                        
                        
                        Screen('DrawingFinished',w,2);
                        
                        Screen('Flip',w,time_now,2);
                        
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
    Screen('DrawTextures',w,[blank_tex fix_tex photo_tex(2)]',[],[rect; fix_rect; photo_rect]');
    Screen('Flip',w);
    
    if DAQTimingTester == 0 && flickerTimingTester == 0
        % Task question
        if taskIdx == 1   % Size task
            if dirAttend==1
                text1='How much did the average ORIENTATION on the LEFT side of the screen change?';
            elseif dirAttend==2
                text1='How much did the average ORIENTATION on the RIGHT side of the screen?';
            end
        elseif taskIdx == 2
            if dirAttend==1
                text1='How much did the average SIZE on the LEFT side of the screen?';
            elseif dirAttend==2
                text1='How much did the average SIZE on the RIGHT side of the screen?';
            end
        end
        text2='Press ''1'' if it did not change at all.';
        text3='If you did notice a change, indicate how much change using ''2'', ''3'', or ''4'' keys,';
        text4='''4'' being maximum change and ''2'' being minimum change.';
        
        width=RectWidth(Screen('TextBounds',w,text1));
        Screen('DrawText',w,text1,xc-width/2,yc-150,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text2));
        Screen('DrawText',w,text2,xc-width/2,yc-100,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text3));
        Screen('DrawText',w,text3,xc-width/2,yc-50,[0 0 0]);
        width=RectWidth(Screen('TextBounds',w,text4));
        Screen('DrawText',w,text4,xc-width/2,yc+0,[0 0 0]);
        Screen('Flip',w);
        
        while 1
            [keyisdown, secs, keycode] = KbCheck(dev_id);
            if keycode(button1)
                rawdata(n,6) = 1;
                break
            elseif keycode(button2)
                rawdata(n,6) = 2;
                break
            elseif keycode(button3)
                rawdata(n,6) = 3;
                break
            elseif keycode(button4)
                rawdata(n,6) = 4;
                break
            end
        end
        
        % Did they say there was a change when there actually was one?
        if rawdata(n,3) == 1  % Ori task
            if (rawdata(n,6) == 1) && (rawdata(n,1) == 1)   % No change and they said no change
                rawdata(n,7) = 1;
            elseif (rawdata(n,6) == 2 || rawdata(n,6) == 3 || rawdata(n,6) == 4) &&...
                    (rawdata(n,1) == 2 || rawdata(n,1) == 3 || rawdata(n,1) == 4 || rawdata(n,1) == 5) % Change and they said change
                rawdata(n,7) = 1;
            else
                rawdata(n,7) = 0;
            end
        elseif rawdata(n,3) == 2   % Size task
            if (rawdata(n,6) == 1) && (rawdata(n,2) == 1)   % No change and they said no change
                rawdata(n,7) = 1;
            elseif (rawdata(n,6) == 2 || rawdata(n,6) == 3 || rawdata(n,6) == 4) &&...
                    (rawdata(n,2) == 2 || rawdata(n,2) == 3 || rawdata(n,2) == 4 || rawdata(n,2) == 5) % Change and they said change
                rawdata(n,7) = 1;
            else
                rawdata(n,7) = 0;
            end
        end
    end
    
    % Close any remaining open textures to clear memory
    windowPointers = Screen('Windows');
    Screen('Close',windowPointers);
    
    % Save rawdata and flicker info after ever trial
    save(datafile,'rawdata','chosenStimRate');
    
%     infoVar = Screen('GetWindowInfo',w);
%     
%     Screen('DrawTexture',w,fix_tex,[],fix_rsect);   % Fixation
%     Screen('Flip',w);
%     WaitSecs(1);
    
end

% Save
save(datafile,'rawdata','chosenStimRate','rawdataPractice');
save(datafile_full);

Screen('CloseAll');

if labComp == 0
    ShowCursor;
    ListenChar(0);
end


