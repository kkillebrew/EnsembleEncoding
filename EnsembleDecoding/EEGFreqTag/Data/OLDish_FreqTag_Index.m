% Script for creating index values from the OB frequency tags -
% 032219

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

stimRateOB = [.6 .75 .8 2];

%% Create index values collapsing across both att hemifeild and task type
for n=1:length(subjList)
    
    %% First load in data
    fprintf('%s%d\n','Subj: ',n)
    fprintf('%s\n','Loading and preping...')
    cd(sprintf('%s',subjList{n},'/',subjList{n},'_results_60HzLP/'))   % cd into participant folder
    
%     load('FFT_Results_Oddball','trialFFTAtt','trialFFTUnAtt','trialFFTAttWPhase','trialFFTUnAttWPhase');
      load('FFT_Results_Oddball','trialFFTAtt','trialFFTUnAtt');

%     trialFFTAttGroup(n,:,:,:,:,:,:) = trialFFTAtt(:,:,:,:,:,:);
%     trialFFTUnAttGroup(n,:,:,:,:,:,:) = trialFFTUnAtt(:,:,:,:,:,:);
%     
%     trialFFTAttWPhaseGroup(n,:,:,:,:,:,:) = trialFFTAttWPhase(:,:,:,:,:,:);
%     trialFFTUnAttWPhaseGroup(n,:,:,:,:,:,:) = trialFFTUnAttWPhase(:,:,:,:,:,:);
    
    cd ../../
    
    %% Make the index for each participant
    fprintf('%s\n','Making the index...')
    % trialFFTAtt(1) = task
    % trialFFTAtt(2) = att hemifield
    % trialFFTAtt(3) = Level
    % trialFFTAtt(4) = OB Frequency
    % trialFFTAtt(5) = electrode
    % trialFFTAtt(6) = frequency bin
    
    % For each frequency first, pick off the 3 frequencies
    % that correspond to that OB and then create the index.
    
    for i=1:4
        % Create the index
        idxAtt(:,:,:,i,:,:) = ( (trialFFTAtt(:,:,:,i,:,stimRateOB(i)*20+1:stimRateOB(i)*20:3*stimRateOB(i)*20+1) -...
            trialFFTUnAtt(:,:,:,i,:,stimRateOB(i)*20+1:stimRateOB(i)*20:3*stimRateOB(i)*20+1)) ./...
            (trialFFTAtt(:,:,:,i,:,stimRateOB(i)*20+1:stimRateOB(i)*20:3*stimRateOB(i)*20+1) +...
            trialFFTUnAtt(:,:,:,i,:,stimRateOB(i)*20+1:stimRateOB(i)*20:3*stimRateOB(i)*20+1)) );
        
        idxAttGroup(n,:,:,:,i,:,:) = idxAtt(:,:,:,i,:,:);% Store with group data
    end
    
    % Collapse across attended hemifeild
    idxAttAveAtt(:,:,:,:,:) = squeeze(nanmean(idxAtt,2));
    idxAttAveAttGroup(n,:,:,:,:,:) = idxAttAveAtt;
    
    % Collapse across task type
    idxAttAveAttTask(:,:,:,:) = squeeze(nanmean(idxAttAveAtt,1));
    idxAttAveAttTaskGroup(n,:,:,:,:) = idxAttAveAttTask;
    
end

%% Collapse across participants
% First average togethere each OB frequency within each participant
idxAttAveAttTaskFreqGroup = squeeze(nanmean(idxAttAveAttTaskGroup,3));

% Then average across participants
idxAttAveAttTaskFreqPartGroup = squeeze(nanmean(idxAttAveAttTaskFreqGroup,1));

% Calculate FDR

% Plot on a topo using the FDR
figure()





















