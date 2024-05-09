function [xeye, yeye, delta]=EyeTrackerGazeCheck(ivx,x_cur,y_cur,screen_ID)

[success, ivx]=iViewXComm('send', ivx, 'ET_CLR');   %clear buffer

[data, ivx]=iViewX('receivedata', ivx);

if 1==strfind(data, 'ET_SPL') % spooled data
    mygaze=str2num(data(8:end));
    xeye=mygaze(2);
    yeye=mygaze(4);
else
    xeye=x_cur;
    yeye=y_cur;
end



