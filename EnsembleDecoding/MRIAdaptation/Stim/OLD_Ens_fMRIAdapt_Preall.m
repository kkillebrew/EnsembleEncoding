% Funtion to preallocate the texture values for the fMRI ensemble
% experiment. 081718

function [ellipseTexture,ellipseOri,ellipseCoords] = Ens_fMRIAdapt_Preall(w,xc,yc,rect,PPD,trialOrder,oriList,sizeList)

%% Initilization variables
screenWide=1024;
screenHigh=768;

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

%% Trial variables
orientationListIdx = [1 2 3 4];
nOri = length(orientationListIdx);
sizeListIdx = [1 2 3 4];
nSize = length(sizeListIdx);
taskList = [1 2];
nTask = length(taskList);
runid = 1;  % start with run 1 and count up to total in outer trial (run) loop
runsPerExp = 12;   % total # runs
blocksPerRun = 4;   % Blocks per run (per task)
repsPerBlock = 8;   % Repetitions of test to ref per block (per task)

%% Stimulus variables

% Amount of jitter
jitterAmount = 10;

% Size of one cell
cellSize = rect(4)/8;

% Create the stimulus variables for orientation and size
% The maximum size of the largest circle should not allow the ellipse to
% move oustide of it cell. In DoVA
standardSize = 1;
standardOri = 270;

sizeVariance = .25;
% sizeList = [0 .25 .5 1];
% sizeList = [1 1 1 1];
oriVariance = 10;
% oriList = [0 25 45 90];

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

%% Preallocation start
trialCounter = 0;

% Make a new trialOrder variable that contains only the trials for that block
trialOrderBlock = trialOrder;

firstBlock = 1;

for n=1:length(trialOrderBlock)   % run for the length of the block in trial order
    
    trialCounter = trialCounter+1;
    
    % Determine the delta to be used for size and orientation
    % rawdata(1) = ori
    % rawdata(2) = size
    % rawdata(3) = task; 1=ori, 2=size
    % rawdata(4) = run number
    % rawdata(5) = block number
    % rawdata(6) = number of items present; 1=start less, 2=start more
    oriIdx = trialOrderBlock(trialCounter,1);
    sizeIdx = trialOrderBlock(trialCounter,2);
    itemsIdx = trialOrderBlock(trialCounter,6);
    
    % Preallocate stim presentations for each trial in block
    for j=1:repsPerBlock*2
        
        % Switch the index to ref for odd trials and test for even
        if mod(j,2)==1
            oriIdxHolder = 1;
            sizeIdxHolder = 1;
        elseif mod(j,2)==0
            oriIdxHolder = oriIdx;
            sizeIdxHolder = sizeIdx;
        end
        
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
        ellipseOriHolder=ellipseOriHolder-repmat(mean(ellipseOriHolder,2),[1,size(ellipseOriHolder,2)]);
        ellipseOriHolder=ellipseOriHolder./(std(ellipseOriHolder,0,2));
        ellipseOriHolder=ellipseOriHolder.*oriVariance;
        ellipseOriHolder=ellipseOriHolder+((standardOri+(oriList(oriIdxHolder))));
        ellipseOri{n,j}=reshape(ellipseOriHolder',[1,currentNumItems]);
        
        % Determine size
        clear ellipseSizeHolder
        ellipseSizeHolder=randn(4,numItemsPerQuad);
        ellipseSizeHolder=ellipseSizeHolder-repmat(mean(ellipseSizeHolder,2),[1,size(ellipseSizeHolder,2)]);
        ellipseSizeHolder=ellipseSizeHolder./(std(ellipseSizeHolder,0,2));
        ellipseSizeHolder=ellipseSizeHolder.*(sizeVariance*PPD);
        ellipseSize{n,j}=ellipseSizeHolder+((standardSize+(sizeList(sizeIdxHolder)))*PPD);
        
        % Add in positional jitter for x and y directions
        xJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
        yJitter = randi([-jitterAmount jitterAmount],[numItemsPerQuad,4])';
        
        xSize = round(ellipseSize{n,j}./2);
        ySize = round(xSize/2);
        
        % Create the coords for the ellipses
        ellipseCoords{n,j} = [[blockCenterCoords(quadPosition(1,:),1,1); blockCenterCoords(quadPosition(2,:),1,2); blockCenterCoords(quadPosition(3,:),1,3); blockCenterCoords(quadPosition(4,:),1,4)]' - [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)] + [xJitter(1,:) xJitter(2,:) xJitter(3,:) xJitter(4,:)];...
            [blockCenterCoords(quadPosition(1,:),2,1); blockCenterCoords(quadPosition(2,:),2,2); blockCenterCoords(quadPosition(3,:),2,3); blockCenterCoords(quadPosition(4,:),2,4)]' - [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)] + [yJitter(1,:) yJitter(2,:) yJitter(3,:) yJitter(4,:)];...
            [blockCenterCoords(quadPosition(1,:),1,1); blockCenterCoords(quadPosition(2,:),1,2); blockCenterCoords(quadPosition(3,:),1,3); blockCenterCoords(quadPosition(4,:),1,4)]' + [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)] + [xJitter(1,:) xJitter(2,:) xJitter(3,:) xJitter(4,:)];...
            [blockCenterCoords(quadPosition(1,:),2,1); blockCenterCoords(quadPosition(2,:),2,2); blockCenterCoords(quadPosition(3,:),2,3); blockCenterCoords(quadPosition(4,:),2,4)]' + [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)] + [yJitter(1,:) yJitter(2,:) yJitter(3,:) yJitter(4,:)]];
        
        counter=1;
        xSizeVector = [xSize(1,:) xSize(2,:) xSize(3,:) xSize(4,:)];
        ySizeVector = [ySize(1,:) ySize(2,:) ySize(3,:) ySize(4,:)];
        for k=1:length(ellipseCoords{n,j})
            
            % Create a single texture ellipse using the xSize/YSize that can be
            % individually rotated
            ellipseTexture{n,j}(k) = Screen('MakeTexture', w, zeros([xSizeVector(counter)*4 ySizeVector(counter)*4]) + 128);
            
            % Draw all the circles onto the texture
            Screen('FrameOval',ellipseTexture{n,j}(k),[0 0 0],[],5);
            %             Screen('FrameRect',ellipseTexture{i}(k),[0 0 0],[],5);
            
            counter = counter+1;
            
        end
    end
    
    % Set priority
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    firstBlock = 0;
end






