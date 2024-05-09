function [rawdataPractice] = Ens_VEP_Practice(rect,w,button1,button2,button3,button4,flip_interval_correction,xc,yc,PPD,dev_id,runid,sizeList,oriList)

%% Trial variables
orientationListIdx = [1 2 3 4 5];
nOri = length(orientationListIdx);
sizeListIdx = [1 2 3 4 5];
nSize = length(sizeListIdx);
taskList = [1 2];
nTask = length(taskList);

% Make lists
repetitions = 1;   % Number of repetitions per block

% Varlist for orientation trials
varList(:,:,1) = repmat(fullfact([2 nSize]),[repetitions,1]);   % Get all combinations of conditions
varList(varList(:,1,1)==1,1,1) = 1; 
varList(varList(:,1,1)==2,1,1) = 5; 
% Varlist for size trials
varList(:,:,2) = repmat(fullfact([nOri 2]),[repetitions,1]);
varList(varList(:,2,2)==1,2,2) = 1; 
varList(varList(:,2,2)==2,2,2) = 5; 
presOrder = randperm(size(varList,1));   % Randomize the order of presentation
varList(:,:,:) = varList(presOrder,:,:);

% Randomly select which task comes first
trialOrder = [varList(:,:,1); varList(:,:,2)];
% taskRandomizer = randi(2);
taskRandomizer = 1;
trialOrder(:,3) = [zeros([10,1])+taskRandomizer; zeros([10,1])+(3-taskRandomizer)];

% Run number
trialOrder(:,4) = zeros([1 size(trialOrder,1)])+runid;

% On each trial alternate between more/less items
% Determine randomly what the starting amount for each trial will be
% 1=start more; 2=start less
trialOrder(:,5) = [1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2];
trialOrder(:,5) = trialOrder(randperm(size(trialOrder,1)),5);


%% Stimulus variables

% Give participants a break in between blocks
instructionCounter = 1:10:length(trialOrder);   % Determine when to present task instructions

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

[keyisdown, secs, keycode] = KbCheck(dev_id);
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
    rawdataPractice(n,1) = oriIdx;
    sizeIdx = trialOrder(n,2);
    rawdataPractice(n,2) = sizeIdx;
    taskIdx = trialOrder(n,3);
    rawdataPractice(n,3) = taskIdx;
    runIdx = trialOrder(n,4);
    rawdataPractice(n,4) = runIdx;
    itemsIdx = trialOrder(n,5);
    rawdataPractice(n,5) = itemsIdx;
    
    % Blank screen texture
    blank_tex = Screen('MakeTexture',w,128*ones(1,1));
    
    % Fixation Texture
    fix_tex = Screen('MakeTexture',w,0*ones(1,1));
    
    % Draw one reference ellipse at the standard size and orientaion
    ref_tex = Screen('MakeTexture',w,zeros([(round((standardSize+(sizeList(1)))*PPD))*2 round(((standardSize+(sizeList(1)))*PPD)/2)*2]) + 128);
    Screen('FrameOval',ref_tex,[0 0 0],[],5);    
    
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
            while 1
                [keyisdown, secs, keycode] = KbCheck(dev_id);
                if keyisdown
                    break;
                end
            end
            Screen('DrawTexture',w,fix_tex,[],fix_rect);   % Fixation
            Screen('Flip',w);
            WaitSecs(preBlockTime);
        end
    end
    
    % Clear screen
    Screen('DrawTexture',w,fix_tex,[],fix_rect);   % Fixation
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
    
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    sync_time= Screen('Flip',w);
    
    % Draw stimuli
    % Present stim.
    Screen('DrawTextures',w,ellipseTexture{n},[],ellipseCoords{n},ellipseOri{n});
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
%     text1=sprintf('%d',oriIdx);
%     text2=sprintf('%d',sizeIdx);
%     width=RectWidth(Screen('TextBounds',w,text1));
%     Screen('DrawText',w,text1,width,yc-300,[0 0 0]);
%     width=RectWidth(Screen('TextBounds',w,text2));
%     Screen('DrawText',w,text2,width,yc-250,[0 0 0]);
    [~, stimOnTime, ~, ~, ~] = Screen('Flip',w,sync_time - flip_interval_correction);
    
    % Blank screen
    Screen('DrawTexture',w,blank_tex,[],rect);
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    %[VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', window,StartTime + curTiming(i) - ifi/4);
    [~, stimOffTime, ~, ~, ~] = Screen('Flip',w,stimOnTime + stimTime - flip_interval_correction);

    % Record stim on stim off
    rawdataPractice(n,6) = round(stimOnTime,5);
    rawdataPractice(n,7) = round(stimOffTime,5);
    
    % Task
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
                    rawdataPractice(n,8) = 1;
                    responseBreak = 1;
                elseif keycode(button2)
                    rawdataPractice(n,8) = 2;
                    responseBreak = 1;
                elseif keycode(button3)
                    rawdataPractice(n,8) = 3;
                    responseBreak = 1;
                elseif keycode(button4)
                    rawdataPractice(n,8) = 4;
                    responseBreak = 1;
                end
                switch responseBreak & response_check_standard
                    case 1
                        rawdata(n,8) = 0;   % 0=no response
                        break
                    otherwise
                end
            case 1
                break
        end
    end
    
    Priority(0);
    
    % Did they say there was a change when there actually was one?
    if rawdataPractice(n,3) == 1  % Ori task
        if (rawdataPractice(n,8) == 1) && (rawdataPractice(n,1) == 1)   % No change and they said no change
            rawdataPractice(n,9) = 1;
        elseif (rawdataPractice(n,8) == 2 || rawdataPractice(n,8) == 3 || rawdataPractice(n,8) == 4) &&...
                (rawdataPractice(n,1) == 2 || rawdataPractice(n,1) == 3 || rawdataPractice(n,1) == 4 || rawdataPractice(n,1) == 5) % Change and they said change
            rawdataPractice(n,9) = 1;
        else
            rawdataPractice(n,9) = 0;
        end
    elseif rawdataPractice(n,3) == 2   % Size task
        if (rawdataPractice(n,8) == 1) && (rawdataPractice(n,2) == 1)   % No change and they said no change
            rawdataPractice(n,9) = 1;
        elseif (rawdataPractice(n,8) == 2 || rawdataPractice(n,8) == 3 || rawdataPractice(n,8) == 4) &&...
                (rawdataPractice(n,2) == 2 || rawdataPractice(n,2) == 3 || rawdataPractice(n,2) == 4 || rawdataPractice(n,2) == 5) % Change and they said change
            rawdataPractice(n,9) = 1;
        else
            rawdataPractice(n,9) = 0;
        end
    end
    
    % Feedback: Did they get it correct?    
    if rawdataPractice(n,9) == 1
        text1='Correct!';
    elseif rawdataPractice(n,9) == 0
        text1='Incorrect!';
    end
    
%     % Save rawdata and flicker info after ever trial
%     save(datafile,'rawdataPractice');
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-250,[0 0 0]);
    Screen('Flip',w);
    WaitSecs(1.5);  
    
    % Close any remaining open textures to clear memory
    windowPointers = Screen('Windows');
    Screen('Close',windowPointers);     
end



