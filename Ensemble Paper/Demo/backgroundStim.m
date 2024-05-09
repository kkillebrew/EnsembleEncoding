clear all
close all

load('PreallocateSize');
load('PreallocateNoise');
load('PreallocateOrientation');
load('PreallocateOrientationStim');
ListenChar(2);
HideCursor;

backColor = 128;
dotColor = 128;
textColor = [256, 256, 256];

mon_width_cm = 40;
mon_dist_cm = 73;
mon_width_deg = 2 * (180/pi) * atan((mon_width_cm/2)/mon_dist_cm);
PPD = (1024/mon_width_deg);

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

% circleSize = [4*PPD 4*PPD 4*PPD 4*PPD 3*PPD 3*PPD 3*PPD 3*PPD 2*PPD 2*PPD 2*PPD 2*PPD 1*PPD 1*PPD 1*PPD 1*PPD];
% 
% edgeBufferX = 150;
% edgeBufferY = 150;
% 
% sizeArray = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4];
% 
% check = 1;
% 
% 
% screenArray = zeros(rect(4),rect(3));    % creates an array of zeroes that represents the pixels on the screen
% 
% % sets the edge values in the screenArray to 1
% for k=1:rect(4)
%     for l=1:edgeBufferX
%         screenArray(k,l) = 1;
%     end
% end
% 
% for k=1:rect(4)
%     for l=(rect(3)-edgeBufferX):rect(3)
%         screenArray(k,l) = 1;
%     end
% end
% 
% for k=1:edgeBufferY
%     for l=1:rect(3)
%         screenArray(k,l) = 1;
%     end
% end
% 
% for k=rect(4)-edgeBufferY:rect(4)
%     for l=1:rect(3)
%         screenArray(k,l) = 1;
%     end
% end
% 
% for k=(x0-20):(x0+20)
%     for l=(y0-20):(y0+20)
%         screenArray(l,k) = 1;
%     end
% end
% 
% 
% dotBuffer = 20;
% 
% XTop(1) = (edgeBufferX)+randi(round((rect(3)-dotBuffer-circleSize(1)-edgeBufferX)-edgeBufferX));
% YTop(1) = (edgeBufferY)+randi(round((rect(4)-dotBuffer-circleSize(1)-edgeBufferY)-edgeBufferY));
% XBot(1) = XTop(1) + circleSize(1);
% YBot(1) = YTop(1) + circleSize(1);
% 
% for h=1:16
%     while 1
%         recheck=0;
%         for k=XTop(h):XBot(h)+dotBuffer
%             for l=YTop(h):YBot(h)+dotBuffer
%                 if screenArray(l,k)==1
%                     XTop(h) = (edgeBufferX-1)+randi(round((rect(3)-dotBuffer-circleSize(h)-edgeBufferX)-edgeBufferX));
%                     YTop(h) = (edgeBufferY-1)+randi(round((rect(4)-dotBuffer-circleSize(h)-edgeBufferY)-edgeBufferY));
%                     XBot(h) = XTop(h) + circleSize(h);
%                     YBot(h) = YTop(h) + circleSize(h);
%                     recheck=1;
%                 end
%             end
%         end
%         if recheck == 0
%             XTop(h+1) = (edgeBufferX-1)+randi(round((rect(3)-dotBuffer-circleSize(h)-edgeBufferX)-edgeBufferX));
%             YTop(h+1) = (edgeBufferY-1)+randi(round((rect(4)-dotBuffer-circleSize(h)-edgeBufferY)-edgeBufferY));
%             XBot(h+1) = XTop(h+1) + circleSize(h);
%             YBot(h+1) = YTop(h+1) + circleSize(h);
%             check = check+1;
%             if check>1000
%                 break
%             end
%             break
%         end
%     end
%     check = 1;
%     for k=XTop(h):XBot(h)+dotBuffer
%         for l=YTop(h):YBot(h)+dotBuffer
%             screenArray(l,k) = 1;
%         end
%     end
% end
% 
% 
% [keyIsDown, secs, keycode] = KbCheck(dev_ID);
% while ~keycode(buttonEscape)
%     for i=1:16
%         Screen('FillOval',w,[255 255 255],[XTop(i) YTop(i) XBot(i) YBot(i)]);
%     end
%     Screen('Flip',w);
%     
%     [keyIsDown, secs, keycode] = KbCheck(dev_ID);
%     
%     if keycode(buttonOne)
%         arielyStim.image = Screen('GetImage',w);
%         imwrite(arielyStim.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/arielyStim.jpeg','jpg')
%     end
%     
% end

KbReleaseWait;


varValIdx = 2;
varStairIdx = 1;

[keyIsDown, secs, keycode] = KbCheck(dev_ID);
while ~keycode(buttonEscape)
    [keyIsDown, secs, keycode] = KbCheck;
    for i=.5:trialsDotAmountOrientation(1,2)-.5
        radius(2)=imSize(2)/2;
        destRect=[((x0-xCenter(2)*cos((i*pi)/(trialsDotAmountOrientation(1,2)/2)+shift(2)))-(radius(2))),...
            ((y0-yCenter(2)*sin((i*pi)/(trialsDotAmountOrientation(1,2)/2)+shift(2)))-(radius(2)+elongateRadius)),...
            ((x0-xCenter(2)*cos((i*pi)/(trialsDotAmountOrientation(1,2)/2)+shift(2))+(radius(2)))),...
            ((y0-yCenter(2)*sin((i*pi)/(trialsDotAmountOrientation(1,2)/2)+shift(2))+(radius(2)+elongateRadius)))];
        Screen('DrawTexture',w, gabor(2),[],destRect,trialsOrientationVarianceStair(1,i+.5,varValIdx,varStairIdx));
    end
    
    destRect = [x0-radius(2), y0-radius(2)+elongateRadius, x0+radius(2), y0+radius(2)+elongateRadius];
    Screen('DrawTexture',w, gabor(2),[],destRect,trialsOrientationVarianceStair(1,i+.5,3,varStairIdx));
    
    Screen('Flip',w);
    
    if keycode(buttonOne)
        parksStim.image = Screen('GetImage',w);
        imwrite(parksStim.image,'/Users/C-Lab/Google Drive/Lab Projects/Ensemble Paper/VSS Figures/parksStim.jpeg','jpg')
        KbReleaseWait;
    end
end

ListenChar(1);
ShowCursor;

Screen('CloseAll');












