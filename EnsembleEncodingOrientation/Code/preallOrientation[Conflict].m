clear all;
close all;

datafile='PreallocateOrientation';
datafile_full=sprintf('%s_full',datafile);

stdOrient = 40;    % Std of 1º 

% Making the lists
experimentList=[1 2];   % Chooses mean or variance
nExperiment=length(experimentList);
filterList=[0 .8];    % How opaque the filter is
nFilter=length(filterList);
iterationList=[1 2]; % Which number staircase you are on
nIteration=length(iterationList);
startList=[1 2];
nStart=length(startList);
% meanOrientationList = [310 320 330 340 350 0 10 20 30 40 50];        % Mean orientation in degrees (theta in experiment code)
meanOrientationList = [-50 -40 -30 -20 -10 0 10 20 30 40 50];
nOrient = length(meanOrientationList);
nTrials=25;                             % Number of trials per staircase

dotAmount = 16;

numTrials=nFilter*nIteration*nStart*nTrials*nExperiment;

% rect=[0 0 2560 1440];     % screen dimension for lab comps
rect=[0 0 1024 768];     % test comps
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

% Preallocating the dot amount
for i=1:numTrials;
    trialsDotAmount(i)=dotAmount;
end

% Preallocating the mean conditions
for h=1:nOrient
    for i=1:numTrials
        orientation=[];
        orientation=randn(1,trialsDotAmount(i));
        orientation=orientation-mean(orientation);
        orientation=orientation/(std(orientation));
        orientation=orientation*stdOrient;
        orientation=orientation+(meanOrientationList(h));
        
        for j=1:trialsDotAmount(i)
            if orientation(j) > 360
                oreintation(j)=orientation(j)-360;
            end
            trialsOrientation(i,j,h)=orientation(j);
        end
    end
end

save(datafile,'trialsOrientation','trialsDotAmount','numTrials','nTrials','nOrient','meanOrientationList',...
    'nStart','startList','nIteration','iterationList','nFilter','filterList','nExperiment','experimentList','dotAmount');
save(datafile_full);