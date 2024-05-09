clear
ListenChar(2);
backColor = 0;
dotColor = 124;
textColor = [230 0 0];

PPD=33;
dotBuffer=5;

escape=KbName('escape');

[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor]);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

ave=3*PPD;
stdev=0;
delayTime=.5;
stimTime=.2;

% Making 3 demos each for the variance and mean exp...1 at 0 var one at .5
% one at 1 compared to clear at .5 with mean constant...and mean values of 2 2.5 and 3 with var const with
% two resp windows one with compare dot small and two with compare dot
% big...have 3 differnt noise levels at .7 .8 .9
for i=1:6
    if i<=3
        dotSizeHolder=[];
        dotSizeHolder=randn(1,16);
        dotSizeHolder=dotSizeHolder-mean(dotSizeHolder);
        dotSizeHolder=dotSizeHolder/(std(dotSizeHolder));
        dotSizeHolder=dotSizeHolder*stdev;
        dotSizeHolder=dotSizeHolder+(ave);
        dotSizeHolder=round(dotSizeHolder);
        stdev=stdev+(.5*PPD);
    else
        if i==4
            stdev=.5*PPD;
            ave=2.5*PPD;
        end
        dotSizeHolder=[];
        dotSizeHolder=randn(1,16);
        dotSizeHolder=dotSizeHolder-mean(dotSizeHolder);
        dotSizeHolder=dotSizeHolder/(std(dotSizeHolder));
        dotSizeHolder=dotSizeHolder*stdev;
        dotSizeHolder=dotSizeHolder+(ave);
        dotSizeHolder=round(dotSizeHolder);
        ave=ave+(.5*PPD);
    end
    for j=1:16
        dotSize(i,j)=dotSizeHolder(j);
    end
end

% Making the comparison circle set for variance trials
for i=1:3
    stdev=.5*PPD;
    ave=2.5*PPD;
    dotSizeCompHolder=[];
    dotSizeCompHolder=randn(1,16);
    dotSizeCompHolder=dotSizeCompHolder-mean(dotSizeCompHolder);
    dotSizeCompHolder=dotSizeCompHolder/(std(dotSizeCompHolder));
    dotSizeCompHolder=dotSizeCompHolder*stdev;
    dotSizeCompHolder=dotSizeCompHolder+(ave);
    dotSizeCompHolder=round(dotSizeCompHolder);
    for j=1:16
        dotSizeCompare(i,j)=dotSizeCompHolder(j);
    end
end

edgeBufferX=(rect(3)-((4*(ave+10)+dotBuffer)*2))/2;
edgeBufferY=(rect(4)-((4*(ave+10)+dotBuffer)*2))/2;

noiseMatrix=[];
for i=1:1440
    for j=1:2560
        n=randi(2);
        if n==1
            noiseMatrix(i,j)=255;
        else
            noiseMatrix(i,j)=0;
        end
    end
end
destRect = [0,0,rect(3),rect(4)];
noise=Screen('MakeTexture',w,noiseMatrix);

% sets the edge values in the screenArray to 1
for p=1:6
    screenArray = zeros(rect(4),rect(3));    % creates an array of zeroes that represents the pixels on the screen
    
    for k=1:rect(4)
        for l=1:edgeBufferX
            screenArray(k,l) = 1;
        end
    end
    
    for k=1:rect(4)
        for l=(rect(3)-edgeBufferX):rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=1:edgeBufferY
        for l=1:rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=rect(4)-edgeBufferY:rect(4)
        for l=1:rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=(x0-20):(x0+20)
        for l=(y0-20):(y0+20)
            screenArray(l,k) = 1;
        end
    end
    
    trialsXTopNoise(p,1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSize(p,1)-edgeBufferX)-edgeBufferX);
    trialsYTopNoise(p,1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSize(p,1)-edgeBufferY)-edgeBufferY);
    trialsXBotNoise(p,1) = trialsXTopNoise(p,1) + dotSize(p,1);
    trialsYBotNoise(p,1) = trialsYTopNoise(p,1) + dotSize(p,1);
    
    for j=1:16
        while 1
            recheck=0;
            for k=trialsXTopNoise(p,j):trialsXBotNoise(p,j)+dotBuffer
                for l=trialsYTopNoise(p,j):trialsYBotNoise(p,j)+dotBuffer
                    if screenArray(l,k)==1
                        trialsXTopNoise(p,j) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSize(p,j)-edgeBufferX)-edgeBufferX);
                        trialsYTopNoise(p,j) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSize(p,j)-edgeBufferY)-edgeBufferY);
                        trialsXBotNoise(p,j) = trialsXTopNoise(p,j) + dotSize(p,j);
                        trialsYBotNoise(p,j) = trialsYTopNoise(p,j) + dotSize(p,j);
                        recheck=1;
                    end
                end
            end
            if recheck == 0
                trialsXTopNoise(p,j+1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSize(p,j)-edgeBufferX)-edgeBufferX);
                trialsYTopNoise(p,j+1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSize(p,j)-edgeBufferY)-edgeBufferY);
                trialsXBotNoise(p,j+1) = trialsXTopNoise(p,j+1) + dotSize(p,j);
                trialsYBotNoise(p,j+1) = trialsYTopNoise(p,j+1) + dotSize(p,j);
                break
            end
        end
        for k=trialsXTopNoise(p,j):trialsXBotNoise(p,j)+dotBuffer
            for l=trialsYTopNoise(p,j):trialsYBotNoise(p,j)+dotBuffer
                screenArray(l,k) = 1;
            end
        end
    end
end

for p=1:3
    
    screenArray = zeros(rect(4),rect(3));    % creates an array of zeroes that represents the pixels on the screen
    
    for k=1:rect(4)
        for l=1:edgeBufferX
            screenArray(k,l) = 1;
        end
    end
    
    for k=1:rect(4)
        for l=(rect(3)-edgeBufferX):rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=1:edgeBufferY
        for l=1:rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=rect(4)-edgeBufferY:rect(4)
        for l=1:rect(3)
            screenArray(k,l) = 1;
        end
    end
    
    for k=(x0-20):(x0+20)
        for l=(y0-20):(y0+20)
            screenArray(l,k) = 1;
        end
    end
    
    trialsXTopCompare(p,1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeCompare(p,1)-edgeBufferX)-edgeBufferX);
    trialsYTopCompare(p,1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeCompare(p,1)-edgeBufferY)-edgeBufferY);
    trialsXBotCompare(p,1) = trialsXTopCompare(p,1) + dotSizeCompare(p,1);
    trialsYBotCompare(p,1) = trialsYTopCompare(p,1) + dotSizeCompare(p,1);
    
    for j=1:16
        while 1
            recheck=0;
            for k=trialsXTopCompare(p,j):trialsXBotCompare(p,j)+dotBuffer
                for l=trialsYTopCompare(p,j):trialsYBotCompare(p,j)+dotBuffer
                    if screenArray(l,k)==1
                        trialsXTopCompare(p,j) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeCompare(p,j)-edgeBufferX)-edgeBufferX);
                        trialsYTopCompare(p,j) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeCompare(p,j)-edgeBufferY)-edgeBufferY);
                        trialsXBotCompare(p,j) = trialsXTopCompare(p,1) + dotSizeCompare(p,j);
                        trialsYBotCompare(p,j) = trialsYTopCompare(p,1) + dotSizeCompare(p,j);
                        recheck=1;
                    end
                end
            end
            if recheck == 0
                trialsXTopCompare(p,j+1) = (edgeBufferX-1)+randi((rect(3)-dotBuffer-dotSizeCompare(p,j)-edgeBufferX)-edgeBufferX);
                trialsYTopCompare(p,j+1) = (edgeBufferY-1)+randi((rect(4)-dotBuffer-dotSizeCompare(p,j)-edgeBufferY)-edgeBufferY);
                trialsXBotCompare(p,j+1) = trialsXTopCompare(p,j+1) + dotSizeCompare(p,j);
                trialsYBotCompare(p,j+1) = trialsYTopCompare(p,j+1) + dotSizeCompare(p,j);
                break
            end
        end
        for k=trialsXTopCompare(p,j):trialsXBotCompare(p,j)+dotBuffer
            for l=trialsYTopCompare(p,j):trialsYBotCompare(p,j)+dotBuffer
                screenArray(l,k) = 1;
            end
        end
    end
end

HideCursor;
dotStep=0;
imArrayCount=1;
imageArray=[];
alphaVal=.5;    % Sets the alpha value to be changed over each iteration
for j=1:6
    if j>3
        if j==4
            alphaVal=.5;
        end
        for i=1:round(60*delayTime)
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        
        for l=1:round(60*stimTime)
            for i=1:16
                Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(j,i), trialsYTopNoise(j,i), trialsXBotNoise(j,i), trialsYBotNoise(j,i)],(5));
            end
            Screen('DrawTexture',w,noise,[],destRect,[],[],(alphaVal));
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        
        for k=1:round(60*delayTime)
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);
            imArrayCount=imArrayCount+1;
        end
        
        for p=1:round(60*delayTime)
            Screen('FrameOval',w,[dotColor dotColor dotColor],[(x0-(mean(dotSize(j,:))/2)-200) (y0-(mean(dotSize(j,:))/2)) (x0+(mean(dotSize(j,:))/2)-200) (y0+(mean(dotSize(j,:))/2))],(5));
            Screen('FrameOval',w,[dotColor dotColor dotColor],[(x0-((mean(dotSize(j,:))+dotStep)/2)+200) (y0-((mean(dotSize(j,:))+dotStep)/2)) (x0+((mean(dotSize(j,:))+dotStep)/2)+200) (y0+((mean(dotSize(j,:))+dotStep)/2))],(5));
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);
            imArrayCount=imArrayCount+1;
        end
        dotStep=dotStep+1*PPD;
        alphaVal=alphaVal+.1;
    else
        for i=1:round(60*delayTime)
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        
        for l=1:round(60*stimTime)
            for i=1:16
                Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(j,i), trialsYTopNoise(j,i), trialsXBotNoise(j,i), trialsYBotNoise(j,i)],(5));
            end
            Screen('DrawTexture',w,noise,[],destRect,[],[],(alphaVal));
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        for i=1:round(60*delayTime)
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        for l=1:round(60*stimTime)
            for i=1:16
                Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopCompare(j,i), trialsYTopCompare(j,i), trialsXBotCompare(j,i), trialsYBotCompare(j,i)],(5));
            end
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        for p=1:round(60*delayTime)
            Screen('TextSize',w,24);
            text='Which set of circles had the greatest difference in size?';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
            Screen('TextSize',w,24);
            text='Press A for the first option or k for the second';
            width=RectWidth(Screen('TextBounds',w,text));
            Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
            Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
            Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
            Screen('Flip',w);
            imageArray(j,imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
            imArrayCount=imArrayCount+1;
        end
        
        alphaVal=alphaVal+.1;
    end
    imArrayCount=1;
end

ListenChar(0);
ShowCursor;
Screen('Close',w);

for k=1:6
    vidObj = VideoWriter(sprintf('%s%d','ensembleDemo_',k)); %#ok .
    vidObj.FrameRate = 60;
    
    open(vidObj);
    
    for i=1:length(imageArray(k,:))
        imshow(imageArray(k,i).image);
        axis off;
        currFrame = getframe;  % grabs current figure as a video frame
        writeVideo(vidObj,currFrame);  % writes the current frame to vidObj
    end
    
    close(vidObj);
end



