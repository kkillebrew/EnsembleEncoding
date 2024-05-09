close all;
clear all;

load('PreallocateSize');
load('PreallocateNoise');
load('PreallocateOrientation');
load('PreallocateOrientationStim');
ListenChar(2);
HideCursor;

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

% Sets the inputs to come in from the other computer
[nums, names] = GetKeyboardIndices;
dev_ID=nums(1);
con_ID=nums(1);

rect=[0, 100, 1024, 868];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

KbName('UnifyKeyNames');

buttonUp = KbName('UpArrow');
buttonDown = KbName('DownArrow');
buttonLeft = KbName('LeftArrow');
buttonRight = KbName('RightArrow');
buttonEscape = KbName('Escape');
buttonOne = KbName('1!');
buttonTwo = KbName('2@');
buttonThree = KbName('3#');
buttonFour = KbName('4$');
buttonR = KbName('R');
buttonT = KbName('T');
buttonLArrow = KbName(',<');
buttonRArrow = KbName('.>');
buttonColon = KbName(';:');
buttonL = KbName('L');
buttonQ = KbName('Q');
buttonE = KbName('E');

jitter=10;
elongateRadius = 10;
radiusAnnulusBig=384;
radiusAnnulusSmall=200;
divisions=16;

radiusMax=(tand(wedgeSize)*radiusAnnulusBig)/(1+tand(wedgeSize));
radiusJitter=radiusMax-jitter;

% Make texture for noise filter
Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason
noise=Screen('MakeTexture',w,noiseMatrix);
for i=1:nCircles
    gabor(i) = Screen('MakeTexture',w,scaledtexture{i});
    shift(i) = randi(360);
end

Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
WaitSecs(.5);
Screen('TextSize',w,20);
text='Please choose the set of circles that had the largest mean or variance depending on the instructions.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-200,textColor);
Screen('TextSize',w,20);
text='If the preceding screen has a red outline choose the set with the largest mean size.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-150,textColor);
Screen('TextSize',w,20);
text='If the preceding screen has a green outline choose the set with the largest difference in size.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-100,textColor);
Screen('TextSize',w,20);
text='Press any key to begin.';
width=RectWidth(Screen('TextBounds',w,text));
Screen('DrawText',w,text,x0-width/2,y0-50,textColor);
Screen('Flip',w);
KbWait(dev_ID);
KbReleaseWait(dev_ID);

xCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);
yCircleCenter=radiusAnnulusBig-radiusMax+(randi((jitter*2)+1)-jitter+1);

alphaVal = 0;

counter = 1;

% Toggle values
alphaToggle = 1;
dispInfoToggle = 1;
instructionToggle = 1;

% Size Values
varIdx = 1;
meanValIdxSize = 1;
compareMeanIdx = 1;

% Ori Values
varValIdx = 1;
varStairIdx = 1;
meanStairIdx = 1;
meanValIdxOrient = 6;

% Switch values
sizeOrientSwitch = 1;
varMeanSwitch = 1;

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck(dev_ID);
    
    % 1 takes a screen shot
    if keycode(buttonOne);
        imagetemp(counter).image = Screen('GetImage',w);
        ListenChar(0);
        imageName{counter} = input('Enter Title of ScreenShot:','s');
        ListenChar(2);
        counter=counter+1;
        KbReleaseWait;
    end
    
    % 4 takes a screen shot of blank with fixation and start and end screen for mean and var and outputs as fixScreen
    if keycode(buttonFour)
        % Blank Fixation Size
        Screen('FillRect',w,[0 0 0],[0 0 1024 768]);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        backFixSize.image = Screen('GetImage',w);
        imwrite(backFixSize.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/fixScreenSize.jpeg','jpg')
        
        % Blank Fixation Ori
        Screen('FillRect',w,[128 128 128],[0 0 1024 768]);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        backFixOri.image = Screen('GetImage',w);
        imwrite(backFixOri.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/fixScreenOri.jpeg','jpg')
        
        % Variance Start Ori
        Screen('FillRect',w,[128 128 128],[0 0 1024 768]);
        Screen('FrameRect',w,[0 256 0],[0 0 1024 768],10);
        Screen('TextSize',w,50);
        text='Variance Trial';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        varStartOri.image = Screen('GetImage',w);
        imwrite(varStartOri.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/varStartOri.jpeg','jpg')
        
        % Mean Start Ori
        Screen('FillRect',w,[128 128 128],[0 0 1024 768]);
        Screen('FrameRect',w,[256 0 0],[0 0 1024 768],10);
        Screen('TextSize',w,50);
        text='Mean Trial';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        meanStartOri.image = Screen('GetImage',w);
        imwrite(meanStartOri.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/meanStartOri.jpeg','jpg')
        
        % Variance Start Size
        Screen('FillRect',w,[0 0 0],[0 0 1024 768]);
        Screen('FrameRect',w,[0 256 0],[0 0 1024 768],10);
        Screen('TextSize',w,50);
        text='Variance Trial';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        varStart.image = Screen('GetImage',w);
        imwrite(varStart.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/varStart.jpeg','jpg')
        
        % Mean Start Size
        Screen('FillRect',w,[0 0 0],[0 0 1024 768]);
        Screen('FrameRect',w,[256 0 0],[0 0 1024 768],10);
        Screen('TextSize',w,50);
        text='Mean Trial';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-300,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        meanStart.image = Screen('GetImage',w);
        imwrite(meanStart.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/meanStart.jpeg','jpg')
            
        % Ori Var End
        Screen('FillRect',w,[128 128 128],[0 0 1024 768]);
        Screen('TextSize',w,50);
        text='Press Left Shift or Right Shift';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-70,textColor);
        text='Which had the greatest Variability?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-130,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        oriVarEnd.image = Screen('GetImage',w);
        imwrite(oriVarEnd.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/oriVarEnd.jpeg','jpg')
        
        % Ori Mean End 
        Screen('TextSize',w,50);
        Screen('FillRect',w,[128 128 128],[0 0 1024 768]);
        text='Press Left Shift or Right Shift';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-70,textColor);
        text='Which was more Rightward?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-130,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        oriMeanEnd.image = Screen('GetImage',w);
        imwrite(oriMeanEnd.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/oriMeanEnd.jpeg','jpg')
        
        % Size Var End
        Screen('FillRect',w,[0 0 0],[0 0 1024 768]);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        WaitSecs(.5);
        Screen('TextSize',w,50);
        text='Press A or K';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-70,textColor);
        text='Which had the greatest variabiltiy?';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-130,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        sizeVarEnd.image = Screen('GetImage',w);
        imwrite(sizeVarEnd.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/sizeVarEnd.jpeg','jpg')
        
        % Size Mean End
        Screen('FillRect',w,[0 0 0],[0 0 1024 768]);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        WaitSecs(.5);
        Screen('TextSize',w,50);
        text='Press A or K';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-70,textColor);
        text='Which had the greatest Variability';
        width=RectWidth(Screen('TextBounds',w,text));
        Screen('DrawText',w,text,x0-width/2,y0-130,textColor);
        Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
        Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
        Screen('Flip',w);
        sizeMeanEnd.image = Screen('GetImage',w);
        imwrite(sizeMeanEnd.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/sizeMeanEnd.jpeg','jpg')
        
        KbReleaseWait;
    end
    
    % Switch for size to orient
    if keycode(buttonUp)
        sizeOrientSwitch = 1;
        KbReleaseWait;
    elseif keycode(buttonDown)
        sizeOrientSwitch = 2;
        KbReleaseWait;
    end
    
    % Switch for mean to variance
    if keycode(buttonLArrow)
        varMeanSwitch = 1;
        KbReleaseWait;
    elseif keycode(buttonRArrow)
        varMeanSwitch = 2;
        KbReleaseWait;
    end
    
    % Toggle on and off the info display
    if keycode(buttonQ)
        if dispInfoToggle == 1
            dispInfoToggle = 0;
            KbReleaseWait;
        else
            dispInfoToggle = 1;
            KbReleaseWait;
        end
    end
    
    switch sizeOrientSwitch
        % Up for size
        case 1
            Screen('FillRect',w,[0 0 0],rect);
            % Less than key for variance
            switch varMeanSwitch
                case 1
                    % Repeats until call for mean
                    for i=.5:trialsDotAmountSize(1)-.5
                        radiusCircle=trialsDotSizeNoiseVariance(1,i+.5,varIdx);
                        Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmountSize(1)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmountSize(1)/2)))-(radiusCircle)),...
                            ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmountSize(1)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmountSize(1)/2))+(radiusCircle)))],5);
                    end
                    Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                    Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                    Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                    
                    % Displays the info about the array
                    if dispInfoToggle == 1
                        Screen('DrawText',w,sprintf('%s%d','Size, Variance, ', varIdx), 10, 10,[255 255 255]);
                    end
                    Screen('Flip',w);
                    
                    % L toggles on and off noise
                    if keycode(buttonL)
                        if alphaToggle == 1
                            alphaVal = .6;
                            alphaToggle = 0;
                        elseif alphaToggle == 0
                            alphaVal = 0;
                            alphaToggle = 1;
                        end
                        KbReleaseWait;
                    end
                    
                    % Left and right arrow increase/decrease variance
                    if keycode(buttonRight)
                        if varIdx >= 11
                            varIdx = varIdx;
                        else
                            varIdx = varIdx+1;
                        end
                        KbReleaseWait;
                    elseif keycode(buttonLeft)
                        if varIdx <= 1
                            varIdx = varIdx;
                        else
                            varIdx = varIdx-1;
                        end
                        KbReleaseWait;
                    end
                    % Greater than key for mean
                case 2
                    % Repeats until call for variance
                    for i=.5:trialsDotAmountSize(1)-.5
                        radiusCircle=1*PPD;
                        Screen('FrameOval',w,[dotColor dotColor dotColor], [((x0-xCircleCenter*cos((i*pi)/(trialsDotAmountSize(1)/2)))-(radiusCircle)),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmountSize(1)/2)))-(radiusCircle)),...
                            ((x0-xCircleCenter*cos((i*pi)/(trialsDotAmountSize(1)/2))+(radiusCircle))),((y0-yCircleCenter*sin((i*pi)/(trialsDotAmountSize(1)/2))+(radiusCircle)))],5);
                    end
                    Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                    Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                    Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                    
                    % Displays the info about the array
                    if dispInfoToggle == 1
                        Screen('DrawText',w,sprintf('%s%d%s%d','Size, Mean, ', compareMeanIdx, ', ', meanValIdxSize), 10, 10,[255 255 255]);
                    end
                    Screen('Flip',w);
                    
                    % L toggles on and off noise
                    if keycode(buttonL)
                        if alphaToggle == 1
                            alphaVal = .6;
                            alphaToggle = 0;
                        elseif alphaToggle == 0
                            alphaVal = 0;
                            alphaToggle = 1;
                        end
                        KbReleaseWait;
                    end
                    
                    % Left and right arrow increase/decrease % of mean
                    if keycode(buttonRight)
                        if compareMeanIdx >= 11
                            compareMeanIdx = compareMeanIdx;
                        else
                            compareMeanIdx = compareMeanIdx+1;
                        end
                        KbReleaseWait;
                    elseif keycode(buttonLeft)
                        if compareMeanIdx <= 1
                            compareMeanIdx = compareMeanIdx;
                        else
                            compareMeanIdx = compareMeanIdx-1;
                        end
                        KbReleaseWait;
                    end
                    
                    % 2&3 Increases the average mean size
                    if keycode(buttonThree)
                        if meanValIdxSize >= 5
                            meanValIdxSize = meanValIdxSize;
                        else
                            meanValIdxSize = meanValIdxSize + 1;
                        end
                        KbReleaseWait;
                    elseif keycode(buttonTwo)
                        if meanValIdxSize <= 1
                            meanValIdxSize = meanValIdxSize;
                        else
                            meanValIdxSize = meanValIdxSize - 1;
                        end
                        KbReleaseWait;
                    end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        % Down for orientation
        case 2
            Screen('FillRect',w,[128 128 128],rect);
            switch varMeanSwitch
                case 1
                    % Repeats until call for mean
                    for m=1:nCircles
                        
                        [keyIsDown, secs, keycode] = KbCheck;
                        for i=.5:trialsDotAmountOrientation(1,m)-.5
                            radius(m)=imSize(m)/2;
                            destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m)))-(radius(m))),...
                                ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                                ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m))+(radius(m)))),...
                                ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                            Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationVarianceStair(1,i+.5,varValIdx,varStairIdx));
                        end
                    end
                    
                    destRect = rect;
                    Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                    Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                    Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                    
                    % Displays the info about the array
                    if dispInfoToggle == 1
                        Screen('DrawText',w,sprintf('%s%d','Orientation, Variance, ', varStairIdx), 10, 10,[255 255 255]);
                    end
                    Screen('Flip',w);
                    
                    % L toggles on and off noise
                    if keycode(buttonL)
                        if alphaToggle == 1
                            alphaVal = .7;
                            alphaToggle = 0;
                        elseif alphaToggle == 0
                            alphaVal = 0;
                            alphaToggle = 1;
                        end
                        KbReleaseWait;
                    end
                    
                    % Left and right arrow increase/decrease variance
                    if keycode(buttonRight)
                        if varStairIdx >= 11
                            varStairIdx = varStairIdx;
                        else
                            varStairIdx = varStairIdx+1;
                        end
                        KbReleaseWait;
                    elseif keycode(buttonLeft)
                        if varStairIdx <= 1
                            varStairIdx = varStairIdx;
                        else
                            varStairIdx = varStairIdx-1;
                        end
                        KbReleaseWait;
                    end
                    % Greater than key for mean
                case 2
                    % Repeats until call for variance
                    for m=1:nCircles
                        [keyIsDown, secs, keycode] = KbCheck;
                        for i=.5:trialsDotAmountOrientation(1,m)-.5
                            radius(m)=imSize(m)/2;
                            destRect=[((x0-xCenter(m)*cos((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m)))-(radius(m))),...
                                ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m)))-(radius(m)+elongateRadius)),...
                                ((x0-xCenter(m)*cos((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m))+(radius(m)))),...
                                ((y0-yCenter(m)*sin((i*pi)/(trialsDotAmountOrientation(1,m)/2)+shift(m))+(radius(m)+elongateRadius)))];
                            Screen('DrawTexture',w, gabor(m),[],destRect,trialsOrientationMeanStair(1,i+.5,meanValIdxOrient,meanStairIdx));
                        end
                    end
                    destRect = rect;
                    Screen('DrawTexture',w,noise,[],destRect,[],[],alphaVal);
                    Screen('FillOval',w, [256 0 0], [x0-4, y0-4, x0+4, y0+4]);      % fixation
                    Screen('FillOval',w, [0 0 0], [x0-2, y0-2, x0+2, y0+2]);
                    
                    % Displays the info about the array
                    if dispInfoToggle == 1
                        Screen('DrawText',w,sprintf('%s%d','Orientation, Mean, ', meanStairIdx), 10, 10,[255 255 255]);
                    end
                    Screen('Flip',w);
                    
                    % L toggles on and off noise
                    if keycode(buttonL)
                        if alphaToggle == 1
                            alphaVal = .7;
                            alphaToggle = 0;
                        elseif alphaToggle == 0
                            alphaVal = 0;
                            alphaToggle = 1;
                        end
                        KbReleaseWait;
                    end
                    
                    % Left and right arrow increase/decrease % of mean
                    if keycode(buttonRight)
                        if meanStairIdx >= 11
                            meanStairIdx = meanStairIdx;
                        else
                            meanStairIdx = meanStairIdx+1;
                        end
                        KbReleaseWait;
                    elseif keycode(buttonLeft)
                        if meanStairIdx <= 1
                            meanStairIdx = meanStairIdx;
                        else
                            meanStairIdx = meanStairIdx-1;
                        end
                        KbReleaseWait;
                    end
            end
    end
    
    
end


counter=counter-1;

for i=1:counter
    imwrite(imagetemp(i).image,sprintf('%s%s%s','/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/',imageName{i},'.jpeg'),'jpg')
end

ShowCursor;
ListenChar(0);
Screen('CloseAll');












