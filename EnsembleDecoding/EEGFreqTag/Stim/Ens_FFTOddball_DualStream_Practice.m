function [rawdataPractice] = Ens_FFTOddball_DualStream_Practice(rect,w,button1,button2,button3,button4,xc,yc,PPD,dev_id,hz,dirAttend,oriList,sizeList)


%% Trial variables
orientationListIdx = [1 2 3 4 5];
nOri = length(orientationListIdx);
sizeListIdx = [1 2 3 4 5];
nSize = length(sizeListIdx);

repetitions = 1;

% Varlist for orientation trials
varList(:,:,1) = repmat(fullfact([2 2]),[repetitions,1]);   % Get all combinations of conditions
varList(varList(:,1,1)==1,1,1) = 1; 
varList(varList(:,1,1)==2,1,1) = 5; 
% Varlist for size trials
varList(:,:,2) = repmat(fullfact([2 2]),[repetitions,1]);
varList(varList(:,2,2)==1,2,2) = 1; 
varList(varList(:,2,2)==2,2,2) = 5; 
presOrder = randperm(size(varList,1));   % Randomize the order of presentation
varList(:,:,:) = varList(presOrder,:,:);

% Randomly select which task comes first
trialOrder = [varList(:,:,1); varList(:,:,2)];
trialOrder(:,3) = [zeros([4,1])+1; zeros([4,1])+2];

% Use only the chosen attend direction (dirAttend)
trialOrder(:,4) = zeros([8,1])+dirAttend;

% For each stim combo for each task for each block assign randomly 1 or 2
% for test/ref more/less items
trialOrder(:,5) = [1 2 1 2 1 2 1 2];
trialOrder(:,5) = trialOrder(randperm(size(trialOrder,1)),5);

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

instructionCounter = 1:10:length(trialOrder);   % Determine when to present task instructions

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
% sizeList = [0 .1 .25 .5 1];
oriVariance = 10;
% oriList = [0 10 25 45 90];

numItemArray = [36 44];   % Number of items present

% Flicker Frequency Rates (3 Hz, .5 Hz, .3 Hz; )
stim_rate_BL(1) = 3;
stim_rate_BL(2) = 5;
stim_rate_OB(1,1) = .6;
stim_rate_OB(1,2) = .75;
stim_rate_OB(2,1) = .8;
stim_rate_OB(2,2) = 2;

fix_size = 5;   % Fixaiton size (in pixels)
fix_rect =[xc-fix_size, yc-fix_size, xc+fix_size, yc+fix_size];

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


%% Draw stimulus
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
    rawdataPractice(n,1) = oriIdx;
    sizeIdx = trialOrder(n,2);
    rawdataPractice(n,2) = sizeIdx;
    taskIdx = trialOrder(n,3);
    rawdataPractice(n,3) = taskIdx;
    attendIdx = trialOrder(n,4);
    rawdataPractice(n,4) = attendIdx;
    itemsIdx = trialOrder(n,5);
    rawdataPractice(n,5) = itemsIdx;
    
    % Blank screen texture
    blank_tex = Screen('MakeTexture',w,128*ones(1,1));
    
    % Fixation Texture
    fix_tex = Screen('MakeTexture',w,0*ones(1,1));
    
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
            Screen('DrawTexture',w,fix_tex,[],fix_rect);   % Fixation
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
    Screen('DrawTexture',w,fix_tex,[],fix_rect);   % Fixation
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
        % oddballStimPres = trial x feature (1=ori,2=size) x side (1=left,2=right)
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
        % oddballStimPres = trial x feature (1=ori,2=size) x side (1=left,2=right)
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
                        sizeIdxHolder = sizeIdx;
                        oriIdxHolder = oriIdx;
                    elseif rem(oriCount,oddballStimPres(1,j)) == 0
                        sizeIdxHolder = 1;
                        oriIdxHolder = oriIdx;
                    elseif rem(sizeCount,oddballStimPres(2,j)) == 0
                        sizeIdxHolder = sizeIdx;
                        oriIdxHolder = 1;
                    else
                        sizeIdxHolder = 1;
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
                    ellipseSize{texArrayCounter}=ellipseSizeHolder+((standardSize+(sizeList(sizeIdxHolder)))*PPD);
                    
                    
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
    
    % Making sure that the computer assigns all of its priority to
    % Matlab in order to maximize timing accuracy
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    sync_time= Screen('Flip',w,[],2);
    
    Screen('DrawTextures',w,[ellipseTexture{1}{stimPresCounter1} ellipseTexture{2}{stimPresCounter2} fix_tex],[],...
        [ellipseCoords{1}{stimPresCounter1} ellipseCoords{2}{stimPresCounter2} fix_rect'],...
        [ellipseOri{1}{stimPresCounter1}(1,:) ellipseOri{1}{stimPresCounter1}(2,:)...
        ellipseOri{2}{stimPresCounter2}(1,:) ellipseOri{2}{stimPresCounter2}(2,:) 0]);
    
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
                        
                        Screen('DrawTextures',w,[ellipseTexture{1}{stimPresCounter1} ellipseTexture{2}{stimPresCounter2} fix_tex],[],...
                            [ellipseCoords{1}{stimPresCounter1} ellipseCoords{2}{stimPresCounter2} fix_rect'],...
                            [ellipseOri{1}{stimPresCounter1}(1,:) ellipseOri{1}{stimPresCounter1}(2,:)...
                            ellipseOri{2}{stimPresCounter2}(1,:) ellipseOri{2}{stimPresCounter2}(2,:) 0]);
                        
                        %                         text1=sprintf('%d',stimPresCounter1);
                        %                         width=RectWidth(Screen('TextBounds',w,text1));
                        %                         Screen('DrawText',w,text1,width,150,[0 0 0]);
                        %                         text2=sprintf('%d',stimPresCounter2);
                        %                         width=RectWidth(Screen('TextBounds',w,text2));
                        %                         Screen('DrawText',w,text2,rect(4)-width-5,150,[0 0 0]);
                        
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
    Screen('DrawTextures',w,[blank_tex fix_tex]',[],[rect; fix_rect]');
    Screen('Flip',w);
    
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
            rawdataPractice(n,6) = 1;
            break
        elseif keycode(button2)
            rawdataPractice(n,6) = 2;
            break
        elseif keycode(button3)
            rawdataPractice(n,6) = 3;
            break
        elseif keycode(button4)
            rawdataPractice(n,6) = 4;
            break
        end
    end
    
    % Did they say there was a change when there actually was one?
    if rawdataPractice(n,3) == 1  % Ori task
        if (rawdataPractice(n,6) == 1) && (rawdataPractice(n,1) == 1)   % No change and they said no change
            text='Correct!';
        elseif (rawdataPractice(n,6) == 2 || rawdataPractice(n,6) == 3 || rawdataPractice(n,6) == 4) &&...
                (rawdataPractice(n,1) == 2 || rawdataPractice(n,1) == 3 || rawdataPractice(n,1) == 4 || rawdataPractice(n,1) == 5) % Change and they said change
            text='Correct!';
        else
            text='Incorrect!';
        end
    elseif rawdataPractice(n,3) == 2   % Size task
        if (rawdataPractice(n,6) == 1) && (rawdataPractice(n,2) == 1)   % No change and they said no change
            text='Correct!';
        elseif (rawdataPractice(n,6) == 2 || rawdataPractice(n,6) == 3 || rawdataPractice(n,6) == 4) &&...
                (rawdataPractice(n,2) == 2 || rawdataPractice(n,2) == 3 || rawdataPractice(n,2) == 4 || rawdataPractice(n,2) == 5) % Change and they said change
            text='Correct!';
        else
            text='Incorrect!';
        end
    end
    
    width=RectWidth(Screen('TextBounds',w,text));
    Screen('DrawText',w,text,xc-width/2,yc+0,[0 0 0]);
    Screen('Flip',w);
    WaitSecs(2);
    
    % Close any remaining open textures to clear memory
    windowPointers = Screen('Windows');
    Screen('Close',windowPointers);
    
%     infoVar = Screen('GetWindowInfo',w);
%     
%     Screen('DrawTexture',w,fix_tex,[],fix_rsect);   % Fixation
%     Screen('Flip',w);
%     WaitSecs(1);
    
end

