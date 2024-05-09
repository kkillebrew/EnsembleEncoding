clear
ListenChar(2);

ave=50;
originalAve=ave;
backColor=0;

escape=KbName('Escape');
leftarrow=KbName('leftarrow');
rightarrow=KbName('rightarrow');
enter=KbName('Return');

[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor]);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

HideCursor;
[keyIsDown, secs, keycode] = KbCheck;
while ~keycode(enter)
    
    Screen('FillOval',w, [128 128 128], [x0-ave, y0-ave, x0+ave, y0+ave]);
    
    if keycode(leftarrow)
        ave=ave-1;
    end
    if keycode(rightarrow)
        ave=ave+1;
    end
    
    if ave<1
        break
    end
    if ave>(originalAve*10)
        break
    end
    
    Screen('Flip',w);
    [keyIsDown, secs, keycode] = KbCheck;
    
end

ListenChar(0);
Screen('Close',w);
ShowCursor;
