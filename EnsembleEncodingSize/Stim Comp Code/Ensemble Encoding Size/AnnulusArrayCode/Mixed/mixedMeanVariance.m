close all;
clear all;

% datafile=input('Enter Subject Code:','s');
% datafile_full=sprintf('%s_full',datafile);

load('PreallocateBlock');
ListenChar(2);

backColor = 0;
dotColor = 128;
textColor = [256, 256, 256];

buttonA=KbName('A');
buttonK=KbName('K');

rawdata=[];

for h=1:nExperiment
    for i=1:nFilter
        for j=1:nIteration
            for k=1:nStart
                if k==2   % The second choice was more variable
                    stepCount(h,i,j,k)=nVar;     % Sets the value of stepCount at the greatest var until they choose another val
                    prevAns(h,i,j,k)=1;     % States that the test was more variable
                else
                    stepCount(h,i,j,k)=1;
                    prevAns(h,i,j,k)=2;      % Ref was more variable
                end
                placeList(h,i,j,k)=1;             % If you had a reversal add one to place list
            end
        end
    end
end

variableList=repmat(fullyfact([nExperiment nFilter nIteration nStart]),[nTrials,1]);        % repmap=repeat matrix; makes the large array to choose which variable to use per trial
trialOrder=randperm(numTrials);

rect=[0 0 1024 768];     % test comps
[w,rect]=Screen('OpenWindow', 0,[backColor backColor backColor],rect);
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

numTrials=100;

for n=1:numTrials
    experimentIdx=variableList(trialOrder(n),1);
    experimentVal=experimentList(experimentIdx);
    rawdata(n,1)=experimentVal;
    
    if experimentVal == 1
        Screen('FrameRect',w,[0 256 0],[0 0 1024 768],5);
        Screen('Flip',w);
        WaitSecs(.5);
    else
        Screen('FrameRect',w,[256 0 0],[0 0 1024 768],5);
        Screen('Flip',w);
        WaitSecs(.5);
    end
end

% save(datafile,'rawdata','reversalList');
% save(datafile_full);

ListenChar(0);
Screen('Close',w);
ShowCursor;