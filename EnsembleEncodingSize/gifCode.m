

% %GetImage call. Alter the rect argument to change the location of the screen shot
% imageArray = Screen('GetImage', w, [(edgeBufferX-20) (edgeBufferY-20) (rect(3)-edgeBufferX+20) (rect(4)-edgeBufferY+20)]);
% %imwrite is a Matlab function, not a PTB-3 function
% imwrite(imageArray, 'test.jpg')

%Creates the .gif
delayTime = .5; %Screen refresh rate of 60Hz = 1/60
for i=1:length(imageArray)
    %Gifs can't take RBG matrices: they have to be specified with the pixels as indices into a colormap
    %See the help for imwrite for more details
    [y, newmap] = cmunique(imageArray{i});
    
    %Creates a .gif animation - makes first frame, then appends the rest
    if i==1
        imwrite(y, newmap, 'DegredationDemo.gif');
    else
        imwrite(y, newmap, 'DegredationDemo.gif', 'DelayTime', delayTime, 'WriteMode', 'append','LoopCount',inf);
    end
end


% Making a video file using timing
HideCursor;
imArrayCount=1;
imageArray=[];
alphaVal=.6;    % Sets the alpha value to be changed over each iteration
for j=1:3
    
    startTime=GetSecs;
    while GetSecs-startTime<=stimTime
        for i=1:16
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(i), trialsYTopNoise(i), trialsXBotNoise(i), trialsYBotNoise(i)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],(alphaVal));
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    
    startTime=GetSecs;
    while GetSecs-startTime<=delayTime
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);
        imArrayCount=imArrayCount+1;
    end
    alphaVal=alphaVal+.1;
end

Screen('Close',w);

vidObj = VideoWriter('ensembleDemo'); %#ok .
vidObj.FrameRate = 60;

open(vidObj);

for i=1:length(imageArray);
    imshow(imageArray(i).image);
    axis off;
    currFrame = getframe;  % grabs current figure as a video frame
    writeVideo(vidObj,currFrame);  % writes the current frame to vidObj
end
close(vidObj);


% Making a vid file using calculated frame rates
HideCursor;
imArrayCount=1;
imageArray=[];
alphaVal=.5;    % Sets the alpha value to be changed over each iteration
for j=1:3
    for l=1:round(60*stimTime)
        for i=1:16
            Screen('FrameOval',w,[dotColor dotColor dotColor],[trialsXTopNoise(i), trialsYTopNoise(i), trialsXBotNoise(i), trialsYBotNoise(i)],(5));
        end
        Screen('DrawTexture',w,noise,[],destRect,[],[],(alphaVal));
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);       %Records the frame from front buffer and appends to the imageArray matrix
        imArrayCount=imArrayCount+1;
    end
    
    for k=1:round(60*delayTime)
        Screen('Flip',w);
        imageArray(imArrayCount).image=Screen('GetImage', w);
        imArrayCount=imArrayCount+1;
    end
    alphaVal=alphaVal+.1;
end

Screen('Close',w);

vidObj = VideoWriter('ensembleDemo'); % #ok .
vidObj.FrameRate = 60;

open(vidObj);

for i=1:length(imageArray)
    imshow(imageArray(i).image);
    axis off;
    currFrame = getframe;  % grabs current figure as a video frame
    writeVideo(vidObj,currFrame);  % writes the current frame to vidObj
end
close(vidObj);

ListenChar(0);
ShowCursor;
