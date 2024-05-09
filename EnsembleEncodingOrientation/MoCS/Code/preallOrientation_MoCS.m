clear all;
close all;

datafile='PreallocateOrientationMoCS';
datafile_full=sprintf('%s_full',datafile);

% Making the lists
experimentList=[1 2];   % Chooses mean or variance
nExperiment=length(experimentList);
filterList=[0 .65];    % How opaque the filter is
nFilter=length(filterList);
% iterationList=[1 2]; % Which number staircase you are on
% nIteration=length(iterationList);
% startList=[1 2];
% nStart=length(startList);

% Mean Variables
stdevOrientMean = 10;    % Std of 1º 
% meanOrientationList = [310 320 330 340 350 0 10 20 30 40 50];        % Mean orientation in degrees (theta in experiment code)
meanOrientationList = [-30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30];
nMeanOrient = length(meanOrientationList);
meanStaircaseList = [-15 -10 -5 0 5 10 15];   % Degrees away from the mean for the staircase
nMeanStair = length(meanStaircaseList);

% Variance Variables
stdevOrientVariance = [-15,15];
% varianceOrientationList = [-30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30];
varianceOrientationList = [-10 0 10];
nVarianceOrient = length(varianceOrientationList);
% varianceStaircaseList = [0 5 10 15 20 25 30 35 40 45 50];     % Variance staircase values centered around stdevOrientVariance
% varianceStaircaseList = [1 3.9 6.8 9.7 12.6 15.5 18.4 21.3 24.2 27.1 30];
% varianceStaircaseList = [0 2 4 6 8 10 15 20 25 30 35];
varianceStaircaseList = [-1,1; -5,5; -10,10; -15,15; -20,20; -25,25; -30,30];
nVarianceStair = length(varianceStaircaseList);

% Number of trials
nTrials=15;                             % Number of trials per staircase
dotAmount = [10 12 14];
numTrials=nFilter*nVarianceStair*nTrials*nExperiment;

% rect=[0 0 2560 1440];     % screen dimension for lab comps
rect=[0 0 1024 768];     % test comps
x0 = rect(3)/2;% screen center
y0 = rect(4)/2;

nCircles = 3;    % Number of circles of stimuli

%% Preallocating the dot amount
for i=1:numTrials;
    for j=1:nCircles
        trialsDotAmount(i,j)=dotAmount(j);
    end
end
%% Preallocating the mean conditions
for h=1:nMeanOrient
    for i=1:numTrials
        for l=1:nCircles
            orientation=[];
            orientation=randn(1,trialsDotAmount(i,l));
            orientation=orientation-mean(orientation);
            orientation=orientation/(std(orientation));
            orientation=orientation*stdevOrientMean;
            orientation=orientation+(meanOrientationList(h));
            
            for j=1:trialsDotAmount(i,l)
                %             if orientation(j) > 360
                %                 oreintation(j)=orientation(j)-360;
                %             end
                trialsOrientationMean(i,j,h)=orientation(j);
            end
        end
    end
end
%% Preallocated orientations for staircases in mean condition. Starting at 50 degrees away from the mean in either direction
for i=1:nMeanOrient
    for k=1:nMeanStair
        for j=1:numTrials
            for l=1:nCircles
                orientation=[];
                orientation=randn(1,trialsDotAmount(j,l));
                orientation=orientation-mean(orientation);
                orientation=orientation/(std(orientation));
                orientation=orientation*stdevOrientMean;
                orientation=orientation+(meanOrientationList(i))+meanStaircaseList(k);
                
                for l=1:trialsDotAmount(j,l)
                    %                 if orientation(l) > 360
                    %                     oreintation(l)=orientation(l)-360;
                    %                 end
                    trialsOrientationMeanStair(j,l,i,k)=orientation(l);
                end
            end
        end
    end
end
%% Preallocating the variance conditions
for i=1:numTrials
    for k=1:nVarianceOrient
        for l=1:nCircles
            orientation=[];
%             orientation=randn(1,trialsDotAmount(i,l));
%             orientation=orientation-mean(orientation);
%             orientation=orientation/(std(orientation));
%             orientation=orientation*stdevOrientVariance;
%             orientation=orientation+varianceOrientationList(k);

            orientation = randi(stdevOrientVariance,[1,trialsDotAmount(i,l)]);
            
            for j=1:trialsDotAmount(i,l)
                trialsOrientationVariance(i,j,k)=orientation(j);
            end
        end
    end
end
%% Preallocating the varinace staircases
for i=1:nVarianceStair
    for p=1:nVarianceOrient
        for k=1:numTrials
            for l=1:nCircles
                
                orientation=[];
%                 orientation=randn(1,trialsDotAmount(k,l));
%                 orientation=orientation-mean(orientation);
%                 orientation=orientation/(std(orientation));
%                 orientation=orientation*varianceStaircaseList(i);
%                 orientation=orientation+varianceOrientationList(p);
%                 orientation=round(orientation);

                orientation = randi(varianceStaircaseList(i,:),[1,trialsDotAmount(k,l)]); 

                for j=1:trialsDotAmount(k,l)
                    trialsOrientationVarianceStair(k,j,p,i)=orientation(j);
                end
            end
        end
    end
end
%% Saving
save(datafile,'trialsOrientationMean','trialsDotAmount','numTrials','nTrials','nMeanOrient','meanOrientationList',...
    'nFilter','filterList','nExperiment','experimentList','dotAmount',...
    'trialsOrientationMeanStair','nMeanStair','meanStaircaseList','varianceOrientationList','nVarianceOrient',...
    'varianceStaircaseList','nVarianceStair','trialsOrientationVariance','trialsOrientationVarianceStair');
save(datafile_full);
