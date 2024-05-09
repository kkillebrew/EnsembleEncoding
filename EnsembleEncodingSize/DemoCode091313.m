clear
ListenChar(2);
backColor = 0;
dotColor = 124;

PPD=33;
dotBuffer=20;

escape=KbName('escape');

[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor]);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

ave=2.5*PPD;
stdev=.5*PPD;
delayTime=.5;
stimTime=.2;

dotSize=[];
dotSize=randn(1,16);
dotSize=dotSize-mean(dotSize);
dotSize=dotSize/(std(dotSize));
dotSize=dotSize*stdev;
dotSize=dotSize+(ave);
dotSize=round(dotSize);

edgeBufferX=(rect(3)-(4*(max(dotSize))+dotBuffer)*2)/2;
edgeBufferY=(rect(4)-(4*(max(dotSize))+dotBuffer)*2)/2;

for i=1:16
    trialsXTopNoise(i) = randi(rect(3)-dotBuffer-dotSize(i));
    trialsYTopNoise(i) = randi(rect(4)-dotBuffer-dotSize(i));
    trialsXBotNoise(i) = trialsXTopNoise(i) + dotSize(i);
    trialsYBotNoise(i) = trialsYTopNoise(i) + dotSize(i);
end

screenArray = zeros(rect(4),rect(3));    % creates an array of zeroes that represents the pixels on the screen

% sets the edge values in the screenArray to 1
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

for j=1:16
    while 1
        recheck=0;
        for k=trialsXTopNoise(j):trialsXBotNoise(j)+dotBuffer
            for l=trialsYTopNoise(j):trialsYBotNoise(j)+dotBuffer
                if screenArray(l,k)==1
                    trialsXTopNoise(j) = randi(rect(3)-dotBuffer-dotSize(j));
                    trialsYTopNoise(j) = randi(rect(4)-dotBuffer-dotSize(j));
                    trialsXBotNoise(j) = trialsXTopNoise(j) + dotSize(j);
                    trialsYBotNoise(j) = trialsYTopNoise(j) + dotSize(j);
                    recheck=1;
                end
            end
        end
        if recheck == 0
            trialsXTopNoise(j+1) = randi(rect(3)-dotBuffer-dotSize(j));
            trialsYTopNoise(j+1) = randi(rect(4)-dotBuffer-dotSize(j));
            trialsXBotNoise(j+1) = trialsXTopNoise(j+1) + dotSize(j);
            trialsYBotNoise(j+1) = trialsYTopNoise(j+1) + dotSize(j);
            break
        end
    end
    for k=trialsXTopNoise(j):trialsXBotNoise(j)+dotBuffer
        for l=trialsYTopNoise(j):trialsYBotNoise(j)+dotBuffer
            screenArray(l,k) = 1;
        end
    end
end

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

% vidObj = VideoWriter('ensembleDemo'); %#ok .
% vidObj.FrameRate = 60;
% 
% open(vidObj);
% 
% for i=1:length(imageArray);
%     imshow(imageArray(i).image);
%     axis off;
%     currFrame = getframe;  % grabs current figure as a video frame
%     writeVideo(vidObj,currFrame);  % writes the current frame to vidObj
% end
% close(vidObj);

ListenChar(0);
ShowCursor;


