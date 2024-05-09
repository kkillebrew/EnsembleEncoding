% Script for creating index values from the frequency tags -
% 030119

clear all;
close all;

plotData = 0;

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Ori','Size'};
cats.attend = {'Left','Right'};

% Load in behavioral subject data
cd ../../
ensDataStructBehav = ensLoadData('FreqTagBehav','All');
cd ./'EEG Freq Tag'/Data/

subjList = ensDataStructBehav.subjid;

% What stim rates should we pick off
% stim_rate_BL(1) = 3;
% stim_rate_BL(2) = 5;
% stim_rate_OB(1,1) = .6;
% stim_rate_OB(1,2) = .75;
% stim_rate_OB(2,1) = .8;
% stim_rate_OB(2,2) = 2;
stimRate(1,1) = 3;   % BL frequencies
stimRate(1,2) = 5;
stimRate(2,1) = .6;   % OB frequencies
stimRate(2,2) = .75;
stimRate(3,1) = .8;
stimRate(3,2) = 2;

stimRateConvert = round(stimRate/0.1);

carrierFreqsOri = cell(length(subjList),20,2,2);

for n=1:length(subjList)-1
% for n=1
    %% Load/prep the data
    fprintf('%s%d\n','Subj: ',n)
    fprintf('%s\n','Loading freq tags...')
    
    clear chosenFreqsOri oriFFTChosenFreqs oriFFTChosenFreqsSNRCompare oriFFTSNRDifference
    
    % Data directory
    dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP');
    
    % Load in both runs of preprocessed data
    cd(dataDir)   % CD into the participant results folder to grab the preproc data
    
    load('FFT_Results')

    %% Create the indices
    fprintf('%s\n','Creating indices...')
    
    % Now we have 6 frequencies for each trial. We need to extract the
    % appropriate frequencies for each specific trial type. (Not all
    % ori1,sizeall,oritask,leftatt trials will have the same BL and OB
    % frequencies assigned.)
    
    % Segment the trials based on carrier frequencies: trials for 3Hz
    % att/no att and for 5Hz att/no att
    
    % Ori
    for i=1:length(oriFFTChosenFreqs)   % Only look at ori task conditions for ori
        counter3_1=0;
        counter3_2=0;
        counter5_1=0;
        counter5_2=0;        
        for j=1:size(oriFFTChosenFreqs{i},2)
            
            % Which Hz is attended
            % If left and left is 3hz or if right and right is 3Hz
            if ((chosenFreqsOri{i}(j,7)==1 && chosenFreqsOri{i}(j,1)==60)) || ((chosenFreqsOri{i}(j,7)==2 && chosenFreqsOri{i}(j,2)==60))
                % First look at 3 Hz. Separate trials where 3 Hz is attended vs
                % not attended.
                if chosenFreqsOri{i}(1,7)==1   % If attend left
                    counter3_1=counter3_1+1;
                    carrierFreqsOri{n,i,1,1}(:,counter3_1) = oriFFTChosenFreqs{i}(1,j,1:256);   % 3Hz left attended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                    carrierFreqsOri{n,i,1,2}(:,counter3_1) = oriFFTChosenFreqs{i}(2,j,1:256);   % 3Hz right unattended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                elseif chosenFreqsOri{i}(1,7)==2   % If attend right
                    counter3_2=counter3_2+1;
                    carrierFreqsOri{n,i,1,1}(:,counter3_2) = oriFFTChosenFreqs{i}(2,j,1:256);   % 3Hz right attended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                    carrierFreqsOri{n,i,1,2}(:,counter3_2) = oriFFTChosenFreqs{i}(1,j,1:256);   % 3Hz left unattended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                end
                
            % If left and left is 5hz or if right and right is 5Hz
            elseif ((chosenFreqsOri{i}(j,7)==1 && chosenFreqsOri{i}(j,1)==100)) || ((chosenFreqsOri{i}(j,7)==2 && chosenFreqsOri{i}(j,2)==100))
                % 5Hz
                if chosenFreqsOri{i}(1,7)==1   % If attend left
                    counter5_1=counter5_1+1;
                    carrierFreqsOri{n,i,2,1}(:,counter5_1) = oriFFTChosenFreqs{i}(1,j,1:256);   % 3Hz left attended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                    carrierFreqsOri{n,i,2,2}(:,counter5_1) = oriFFTChosenFreqs{i}(2,j,1:256);   % 3Hz right unattended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                elseif chosenFreqsOri{i}(1,7)==2   % If attend right
                    counter5_2=counter5_2+1;
                    carrierFreqsOri{n,i,2,1}(:,counter5_2) = oriFFTChosenFreqs{i}(2,j,1:256);   % 3Hz right attended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                    carrierFreqsOri{n,i,2,2}(:,counter5_2) = oriFFTChosenFreqs{i}(1,j,1:256);   % 3Hz left unattended for the each cond (ori1,sizeall,oritask,leftatt; etc.)
                end
            end
        end
        clear counter3_1 counter3_2 counter5_1 counter5_2
    end
    
    % Size
    for i=1:length(sizeFFTChosenFreqs)   % Only look at size task conditions for size
        % First look at 3 Hz. Separate trials where 3 Hz is attended vs
        % not attended.
        if chosenFreqsSize{i}(1,7)==1   % If attend left
            carrierFreqsSize{n,i,1,1} = squeeze(sizeFFTChosenFreqs{i}(1,chosenFreqsSize{i}(:,1)==60,1:256));   % 3Hz left attended for the each cond (size1,oriall,sizetask,leftatt; etc.)
            carrierFreqsSize{n,i,1,2} = squeeze(sizeFFTChosenFreqs{i}(2,chosenFreqsSize{i}(:,1)==100,1:256));   % 3Hz right unattended for the each cond (size1,oriall,sizetask,leftatt; etc.)
        elseif chosenFreqsSize{i}(1,7)==2   % If attend right
            carrierFreqsSize{n,i,1,1} = squeeze(sizeFFTChosenFreqs{i}(2,chosenFreqsSize{i}(:,2)==60,1:256));   % 3Hz right attended for the each cond (size1,oriall,sizetask,leftatt; etc.)
            carrierFreqsSize{n,i,1,2} = squeeze(sizeFFTChosenFreqs{i}(1,chosenFreqsSize{i}(:,2)==100,1:256));   % 3Hz left unattended for the each cond (size1,oriall,sizetask,leftatt; etc.)
        end
        
        % 5Hz
        if chosenFreqsSize{i}(1,7)==1   % If attend left
            carrierFreqsSize{n,i,2,1} = squeeze(sizeFFTChosenFreqs{i}(1,chosenFreqsSize{i}(:,1)==100,1:256));   % 5Hz left attended for the each cond (size1,oriall,sizetask,leftatt; etc.)
            carrierFreqsSize{n,i,2,2} = squeeze(sizeFFTChosenFreqs{i}(2,chosenFreqsSize{i}(:,1)==60,1:256));   % 5Hz right unattended for the each cond (size1,oriall,sizetask,leftatt; etc.)
        elseif chosenFreqsSize{i}(1,7)==2   % If attend right
            carrierFreqsSize{n,i,2,1} = squeeze(sizeFFTChosenFreqs{i}(2,chosenFreqsSize{i}(:,2)==100,1:256));   % 5Hz right attended for the each cond (size1,oriall,sizetask,leftatt; etc.)
            carrierFreqsSize{n,i,2,2} = squeeze(sizeFFTChosenFreqs{i}(1,chosenFreqsSize{i}(:,2)==60,1:256));   % 5Hz left unattended for the each cond (size1,oriall,sizetask,leftatt; etc.)
        end
    end
    
    
    % Now once the trials are segmented further based on relevant
    % frequencies, we need to create the index using the UNATTENDED
    % location at the same frequency during the same task (which will be a
    % different set of trials, and will also be the same set of trials used
    % to examine the same level,task, and attended side, but using the
    % other BL frequency in the attended hemifield).
    
    % First sum up the attended tags and the unattend tags, then make the index.
    % carrierFreqsOri(subjNum, conditions (ori1,sizeAlle,etc), 1=3hz 2=5hz, 1=attended 2=notattended)
    % This then gives you an attended value and an unattended value for
    % every condition (1-5 ori lvls, 3Hz and 5Hz).
    for i=1:size(carrierFreqsOri,2)
        
        % Calculate for 3 and 5 hz
        for j=1:size(carrierFreqsOri,3)
            
            % Sum up the index values for attended and unattended
            for k=1:size(carrierFreqsOri,4)
                % If it is the case, that there are no 5/3 hz for that
                % condition (all 10 randomly were 5 Hz). Create an empty matrix
                % in the cell array of NaNs.
                if isempty(carrierFreqsOri{n,i,j,k})
                    carrierFreqsOriSum{n,i,j,k} = NaN(256,1);
                    carrierFreqsSizeSum{n,i,j,k} = mean(carrierFreqsSize{n,i,j,k});
                elseif isempty(carrierFreqsSize{n,i,j,k})
                    carrierFreqsOriSum{n,i,j,k} = mean(carrierFreqsOri{n,i,j,k},2);
                    carrierFreqsSizeSum{n,i,j,k} = mean(carrierFreqsSize{n,i,j,k});
                elseif isempty(carrierFreqsOri{n,i,j,k}) && isempty(carrierFreqsSize{n,i,j,k})
                    carrierFreqsOriSum{n,i,j,k} = NaN(256,1);
                    carrierFreqsSizeSum{n,i,j,k} = mean(carrierFreqsSize{n,i,j,k});
                else
                    carrierFreqsOriSum{n,i,j,k} = mean(carrierFreqsOri{n,i,j,k},2);
                    carrierFreqsSizeSum{n,i,j,k} = mean(carrierFreqsSize{n,i,j,k});
                end
            end
            % Now create the index
            carrierFreqOriIdx{n,i,j} = (carrierFreqsOriSum{n,i,j,1}-carrierFreqsOriSum{n,i,j,2}) ./ (carrierFreqsOriSum{n,i,j,1}+carrierFreqsOriSum{n,i,j,2});
            carrierFreqSizeIdx{n,i,j} = (carrierFreqsSizeSum{n,i,j,1}-carrierFreqsSizeSum{n,i,j,2}) ./ (carrierFreqsSizeSum{n,i,j,1}+carrierFreqsSizeSum{n,i,j,2});
            
            % Plot the average of 3 and 5 hz averaged accrossed
            % participants
            if plotData == 1
                
               % Convert to matrix from cell array for ease
               for l=1:size(carrierFreqOriIdx,1)
                   for o=1:size(carrierFreqOriIdx,2)
                       for p=1:size(carrierFreqOriIdx,3)
                           carrierFreqOriIdxMat(l,o,p,:) = carrierFreqOriIdx{l,o,p}(:);
                       end
                   end
               end
               
               % Average acrross participants
               carrierFreqOriIdxMatPart = squeeze(nanmean(carrierFreqOriIdxMat,1));
               
               % Plot both frequencies for each lvl across participants
               figure()
               % 1-5 3Hz left att
               for p=1:5
                   subplot(5,1,p)
                   bar(squeeze(carrierFreqOriIdxMatPart(p,1,:)))
               end
               % 1-5 3Hz right att
               figure()
               for p=1:5
                   subplot(5,1,p)
                   bar(squeeze(carrierFreqOriIdxMatPart(p+5,1,:)))
               end
               % 1-5 5Hz left att
               figure()
               for p=1:5
                   subplot(5,1,p)
                   bar(squeeze(carrierFreqOriIdxMatPart(p,2,:)))
               end
               % 1-5 5Hz right att
               figure()
               for p=1:5
                   subplot(5,1,p)
                   bar(squeeze(carrierFreqOriIdxMatPart(p+5,2,:)))
               end
            end
            
        end
        
        % Collapse the indices across the 2 frequencies
        carrierFreqOriIdxAccFreqs{n,i} = squeeze(mean([carrierFreqOriIdx{n,i,1}; carrierFreqOriIdx{n,i,2}],1));
        carrierFreqSizeIdxAccFreqs{n,i} = squeeze(mean([carrierFreqSizeIdx{n,i,1}; carrierFreqSizeIdx{n,i,2}],1));        
    end
    
    % Plot the index values for each electrode for the 5 lvls
    % Orienation
    if plotData == 1
        figure()
        for i=1:5
            subplot(5,1,i)
            bar(carrierFreqOriIdxFreqs{n,i})
            hold on
        end
        % Size
        figure()
        for i=1:5
            subplot(5,1,i)
            bar(carrierFreqSizeIdxFreqs{n,i})
            hold on
        end
    end
    
    % Save
    
    % Cd back to data folder to load new participant
    cd ../../
    
    
end

% Convert to matrix from cell
for i=1:size(carrierFreqOriIdxAccFreqs,1)
    for j=1:size(carrierFreqOriIdxAccFreqs,2)
        carrierFreqOriIdxAccFreqsMat(i,j,:) = carrierFreqOriIdxAccFreqs{i,j}(:);
    end
end

% Average across participants
carrierFreqOriIdxFreqsPartis(:,:) = squeeze(mean(carrierFreqOriIdxAccFreqsMat,1));


% WHY ARE THEY NAN - START HERE - MUST BE SOMETHING GOING WRONG DURING
% DIVISION FOR THE INDEX? Figure out what the 10 values represent. ori
% lvl1-5 


