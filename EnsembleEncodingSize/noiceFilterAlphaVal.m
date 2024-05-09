clear
ListenChar(2);

ave=50;
originalAve=ave;
backColor=0;
noiseVar=.5;

escape=KbName('Escape');
leftarrow=KbName('leftarrow');
rightarrow=KbName('rightarrow');
uparrow=KbName('uparrow');
downarrow=KbName('downarrow');
enter=KbName('Return');

[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor]);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

Screen('BlendFunction',w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  % Must have for alpha values for some reason

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

HideCursor;
[keyIsDown, secs, keycode] = KbCheck;
while ~keycode(enter)
    
    Screen('FillOval',w, [128 128 128], [x0-ave, y0-ave, x0+ave, y0+ave]);
    
    if keycode(leftarrow)
        ave=ave-1;
        if ave<=2
            ave=2;
        end
    end
    if keycode(rightarrow)
        ave=ave+1;
        if ave>=originalAve*10
            ave=originalAve;
        end
    end
    
    destRect = [0,0,rect(3),rect(4)];
    
    noise=Screen('MakeTexture',w,noiseMatrix);
    Screen('DrawTexture',w,noise,[],destRect,[],[],noiseVar);
    
    if keycode(downarrow)
        noiseVar=noiseVar-.001;
        if noiseVar>=.999
            noiseVar=.999;
        end
    end
    if keycode(uparrow)
        noiseVar=noiseVar+.001;
        if noiseVar<=.002
            noiseVar=.002;
        end
    end
    
    
    Screen('Flip',w);
    [keyIsDown, secs, keycode] = KbCheck;
    
end

ListenChar(0);
Screen('Close',w);
ShowCursor;
