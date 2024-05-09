function [rawdataPractice, rawdataPracticeTime] = Ens_Behav_Practice(rect,w,buttonF,buttonJ,xc,yc,PPD,dev_id,flip_interval_correction)


%% Trial variables
orientationList = [1 2 3 4 5];
nOri = length(orientationList);
sizeList = [1 2 3 4 5];
nSize = length(sizeList);
taskList = [1 2];
nTask = length(taskList);

% Make lists
repetitions = 1;   % Number of repetitions per block

% Ensure that an equal number of trials are present where the test is
% larger/more dense than reference and vice versa.
numItemsList = [1 2];
nItems = length(numItemsList);

% Varlist for orientation trials
varList(:,:,1) = repmat(fullfact([2 nSize]),[repetitions,1]);   % Get all combinations of conditions
varList(varList(:,1,1)==2,1,1) = 5; 
varList(varList(:,1,1)==1,1,1) = 2; 
% Varlist for size trials
varList(:,:,2) = repmat(fullfact([nOri 2]),[repetitions,1]);
varList(varList(:,2,2)==2,2,2) = 5; 
varList(varList(:,2,2)==1,2,2) = 2; 
presOrder = randperm(size(varList,1));   % Randomize the order of presentation
varList(:,:,:) = varList(presOrder,:,:);

% Randomly select which task comes first
trialOrder = [varList(:,:,1); varList(:,:,2)];
trialOrder(:,3) = [1 1 1 1 1 1 1 1 1 1, 2 2 2 2 2 2 2 2 2 2];

% For each stim combo for each task for each block assign randomly 1 or 2
% for test/ref more/less items
trialOrder(:,4) = [1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2];

%% Stimulus variables

% Give participants a break in between blocks
instructionCounter = 1:10:length(trialOrder);   % Determine when to present task instructions

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
standardSize = 1;
standardOri = 270;

% sizeVariance = .5;
sizeVariance = .25;
sizeList = [0 .1 .25 .5 .75];
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

% Practice screen instructions
text1='The next 20 trials will all be practice.';
text2='You will be shown 2 groups of ellipses sequentially.';
text3='Each individual ellipse will have a size and orientation and';
text4='each group will have an average orientation and size';
text5='You will make judgments about the average size or orientation between the two groups.';
text6='You will perform 1 of the 2 averaging tasks in blocks of trials.';
text7='Before each block instructions will appear to let you know what task you will do.';
text8='Press any key when you are ready to start...';

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
Screen('Flip',w);
while 1
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    if keyisdown
        KbReleaseWait(dev_id);
        break
    end
end

%% Start trials
[keyisdown, secs, keycode] = KbCheck(dev_id);
% while ~keycode(buttonEscape)
for n=1:length(trialOrder)
    [keyisdown, secs, keycode] = KbCheck(dev_id);
    
    clear ellipseCoords ellipseSize ellipseOri taskResponseHolder ellipseTexture
    
    % Determine the delta to be used for size and orientation.
    oriIdx = trialOrder(n,1);
    rawdataPractice(n,1) = oriIdx;
    sizeIdx = trialOrder(n,2);
    rawdataPractice(n,2) = sizeIdx;
    taskIdx = trialOrder(n,3);   % 1=ori, 2=size
    rawdataPractice(n,3) = taskIdx;
    densityIdx = trialOrder(n,4);   % 1=test more items, 2=ref more items
    rawdataPractice(n,4) = densityIdx;
     
    % Present task instructions at the beginning of each block
    for b = instructionCounter
        if n == b
            if taskIdx == 1   % Ori task
                text1='You will be shown 2 groups of ellipses sequentially.';
                text2='Each group will have an average orientation and size';
                text3='For the next few trials, please pay attention to the average ORIENTATION of the group.';
                text4='If the first groups orientation was more rightward leaning, press ''F''.';
                text5='If the second groups orientation was more rightward leaning, press ''J''.';
                text6='Press any key when you are ready to start...' ;
            elseif taskIdx == 2   % Size task
                text1='You will be shown 2 groups of ellipses sequentially.';
                text2='Each group will have an average orientation and size';
                text3='For the next few trials, please pay attention to the average SIZE of the group.';
                text4='If the first groups orientation was larger, press ''F''.';
                text5='If the second groups orientation was larger, press ''J''.';
                text6='Press any key when you are ready to start...' ;
            end
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
            Screen('Flip',w);
            while 1
                [keyisdown, secs, keycode] = KbCheck(dev_id);
                if keyisdown
                    break;
                end
            end
            Screen('DrawTexture',w,fix_tex,[],fix_rect);
            Screen('Flip',w);
            WaitSecs(2);
        end
    end
    
    % Preallocate stim presentations before each trial
    % Determine which will come first test or ref
    stimOrder = randperm(2);   % 1=test, 2=ref
    rawdataPractice(n,[5,6]) = stimOrder;
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
            % Multiple by 4 to enhance the res of the originial texture array (make the array larger but draw the texture at its normal size).
            ellipseTexture{i}(k) = Screen('MakeTexture', w, zeros([xSizeVector(counter)*4 ySizeVector(counter)*4]) + 128);
            
            % Draw all the circles onto the texture
            Screen('FrameOval',ellipseTexture{i}(k),[0 0 0],[],5);
            %             Screen('FrameRect',ellipseTexture{i}(k),[0 0 0],[],5);
            
            counter = counter+1;
            
        end
    end
    
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    Screen('Flip',w);
    WaitSecs(1);
    
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    sync_time = Screen('Flip',w);
    
    % Present stim.
    Screen('DrawTextures',w,ellipseTexture{stimOrder(1)},[],ellipseCoords{stimOrder(1)},ellipseOri{stimOrder(1)});
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    [~, stimOnTime, ~, ~, ~] = Screen('Flip',w,sync_time - flip_interval_correction);
%     KbWait(dev_id);
    
    % Blank screen
    Screen('DrawTexture',w,blank_tex,[],rect);
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    [~, fixOnTime, ~, ~, ~] = Screen('Flip',w,stimOnTime + stimTime - flip_interval_correction);
    
    % Present stim.
    Screen('DrawTextures',w,ellipseTexture{stimOrder(2)},[],ellipseCoords{stimOrder(2)},ellipseOri{stimOrder(2)});
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    [~, stimOffTime, ~, ~, ~] = Screen('Flip',w,fixOnTime + fixTime - flip_interval_correction);
%     KbWait(dev_id);
    
    % Blank screen
    Screen('DrawTexture',w,blank_tex,[],rect);
    Screen('DrawTexture',w,fix_tex,[],fix_rect);
    [~, fixOffTime, ~, ~, ~] = Screen('Flip',w,stimOffTime + stimTime - flip_interval_correction);
    
    % Task question
    if taskIdx == 1   % ori task
        text1='Which group looked more rightward leaning on average?';
        text2='If the first, press ''F''. If the last, press ''J''';
    elseif taskIdx == 2   % size task
        text1='Which group looked larger on average?';
        text2='If the first, press ''F''. If the last, press ''J''';
    end
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-100,[0 0 0]);
    width=RectWidth(Screen('TextBounds',w,text2));
    Screen('DrawText',w,text2,xc-width/2,yc-50,[0 0 0]);
    
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
            rawdataPractice(n,7) = 1;
            break;
        elseif keycode(buttonJ)   % Said the second was larger/rightward
            rawdataPractice(n,7) = 2;
            break;
        end
    end
    
    Priority(0);
    
    % Save timing variables
    rawdataPracticeTime(n,1) = stimOnTime-fixOnTime;   % How long was first stim on screen
    rawdataPracticeTime(n,2) = fixOnTime-stimOffTime;   % How long was delay on screen
    rawdataPracticeTime(n,3) = stimOffTime-fixOffTime;   % How long was second stim on screen
    
    % Did they say the test was larger/rightward than ref (1) or not (0)
    if rawdataPractice(n,7)==1   % They said the first was larger/rightward
        if rawdataPractice(n,5)==1   % The first was the test
            rawdataPractice(n,8) = 1;   % They chose test
        elseif rawdataPractice(n,5)==2   % The second was the test
            rawdataPractice(n,8) = 0;   % They chose ref
        end
    elseif rawdataPractice(n,7)==2   % They said the second was larger/rightward
        if rawdataPractice(n,5)==1   % The first was the test
            rawdataPractice(n,8) = 0;   % They chose ref
        elseif rawdataPractice(n,5)==2   % The second was the test
            rawdataPractice(n,8) = 1;   % They chose test
        end
    end
      
    % Give feedback
    if rawdataPractice(n,8) == 1
        text1='Correct';
    elseif rawdataPractice(n,8) == 0
        text1 = 'Incorrect';
    end
    
    width=RectWidth(Screen('TextBounds',w,text1));
    Screen('DrawText',w,text1,xc-width/2,yc-100,[0 0 0]);
    Screen('Flip',w);
    
    WaitSecs(2);
    
    % Close open textures to save memory
    Screen('Close',[ellipseTexture{stimOrder(1)},ellipseTexture{stimOrder(2)}]);
    
end








