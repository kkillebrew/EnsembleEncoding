% Script for loading, preprocessing, and segmenting of VEP

clear all; close all;

plotArtifacts=0;
fakeData=0;

% Load in behavioral subject data
if fakeData == 0
    cd ../../
    ensDataStructBehav = ensLoadData('VEPBehav','All');
    cd ./'EEG VEP'/Data/
    
    subjList = ensDataStructBehav.subjid;
elseif fakeData == 1
    % Make subject list equal to FakeData
    cd ../../
    ensDataStructBehav = ensLoadData('VEPBehavFake');
    cd ./'EEG VEP'/Data/
    
    subjList = ensDataStructBehav.subjid;
end
%% Start analysis for each subject
for n = 1:length(subjList)
% for n=16
    %% Load in behavioral data
    fprintf('%s%d\n','SUBJ NUM: ',n);
    %      %Return to main path
    %     this_path = '/Users/clab/Documents/Gena/Research/Category_MVPA/ERP_Exp1/Analysis_NEW';
    %     cd(this_path)
    %
    %     %Load info files conatining trial info & odd ball
    %     % Load in info from behavioral file (USE ENSLOADDATA)
    %     load(sprintf('%s%s',subjects{p},'_info'));
    
    % Load individual participant EEG data
    cd ../../
    ensDataStructEEG = ensLoadData('VEPEEG',subjList{n});
    cd ./'EEG VEP'/Data/
    
    rawdataEEG = ensDataStructBehav.rawdata{n};   % EEG Behavioral rawdata
    
    for m=1:2   % Load in/process both EEG runs
        
        fprintf('%s%d\n','RUN NUM: ',m);
        
        % Clear out old variables
        clear cfg data interp bad_chans EOGchans EOGchansIdx goodTrials neighbours trl_rejection x y
        
        %% Define trial info
        %trialfun function segments data
        % CFG - configure data
        cfg = [];
        cfg.trialfun = 'trialFun_Ens_VEP';
        cfg.dataset = sprintf('%s%s',ensDataStructEEG.rawdataVEPEEGPath{m},'.mff');   % Raw EEG data file
        cfg.headerfile = sprintf('%s%s',ensDataStructEEG.rawdataVEPEEGPath{m},'.mff');  % Same thing
        cfg.datafile = sprintf('%s%s',ensDataStructEEG.rawdataVEPEEGPath{m},'.mff');   % Same thing
        
        %Store info containing category info in cfg
        if m==1
            cfg.info = ensDataStructEEG.info(1:length(ensDataStructEEG.info)/2,:);   % Indices for you conditions 1 by numtrials
        elseif m==2
            cfg.info = ensDataStructEEG.info(length(ensDataStructEEG.info)/2+1:end,:);   % Indices for you conditions 1 by numtrials
        end
        %define trial function
        % Calls trialfun here
        cfg = ft_definetrial(cfg);   % Define each trial based on behavioral data; define start/end/offset
        
        %% Load/Segment EEG data/Reref/Filter
        % Specify certain preprocesisng params
        cfg.continuous = 'yes';
        
        %rereference to avergae ref
        cfg.reref         = 'yes';   % Reref to average
        cfg.refchannel    = {'all'};
        
        %bandpass filter .5-50
        cfg.bpfilter      =  'yes';
        cfg.bpfreq    =    [30 .5];
        
        %Load data
        data = ft_preprocessing(cfg);
        
        %% Artfiact detection - bad channels
        %Call custom script for bad channel detection, returns bad_chans
        %conatining bad chans per trail
        [bad_chans]= BCD2(data.trial);
        
        %Define nets
        cfg.elec = ft_read_sens('GSN-HydroCel-257.sfp');
        cfg.layout =cfg.elec;
        
        %method for neighbors search
        cfg.method = 'distance';
        
        %Define Neighbors for BCR
        [neighbours, cfg] = ft_prepare_neighbours(cfg,data);
        cfg.neighbours = neighbours;
        
        %method for BCR
        cfg.method = 'weighted';
        
        interp = data;  % Holder variable
        
        %Repair channels 
        for i = 1:length(data.trial)
            
            if bad_chans{i}(:) == 0
                cfg.badchannel = [];
                cfg.trials = i;
            else
                bad_chans{i}(:) = bad_chans{i}(:)+3;   % Add three to all values to compensate for cfg.elec.label having 3 elecs in first three positions
                cfg.badchannel = cfg.elec.label(bad_chans{i}(:));
                cfg.trials = i;
            end
            [interp2] = ft_channelrepair(cfg, interp);
            
            interp3.trial{1,i} = interp2.trial{1,1};
            disp(i)
        end
        
        interp.trial = interp3.trial;
        
        clearvars interp2 interp3
        
        %% Artfiact detection - Eye movements/blinks
        disp(n)
        %set up specs for EOG artifact detection
        cfg.continuous = 'no';
        cfg.artfctdef.eog.bpfilter   = 'yes';
        cfg.artfctdef.eog.bpfilttype = 'but';
        cfg.artfctdef.eog.bpfreq     = [1 15];
        cfg.artfctdef.eog.bpfiltord  = 4;
        cfg.artfctdef.eog.hilbert    = 'yes';
        
        %define eye channels
        EOGchans = {'E46','E241','E37','E18','E238','E10','E226','E252'};
        
        cfg.artfctdef.eog.channel      = ft_channelselection(EOGchans, interp.label);
        cfg.artfctdef.eog.cutoff       = 5;
        %     cfg.artfctdef.eog.trlpadding   = 0.5;
        %     cfg.artfctdef.eog.fltpadding   = 0.1;
        cfg.artfctdef.eog.trlpadding   = 0;
        cfg.artfctdef.eog.fltpadding   = 0;
        cfg.artfctdef.eog.artpadding   = 0.1;
        
        %Find EOG artifacts. artifact contains EOG artifact segments
        % Specifically for blinks and eye movements
        [cfg, trl_rejection.artifact] = ft_artifact_eog(cfg, interp);
        
        % Find the corresponding trial numbers for each EOG artifact
        %Find all segments (ms) for each trial
        for i = 1:length(cfg.info)
            cfg.trl_all(i,:) = cfg.trl(i,1):cfg.trl(i,2);
        end
        %Find the trails that contain EOG artifacts, store in bad_trials
        % WILL GIVE REPEATS AS MULTIPLE ARTIFACTS CAN HAPPEN IN A SINGLE TRIAL
        counter=1;
        for i = 1:length(trl_rejection.artifact)
            [x(i,1),y(i,1)] = find(cfg.trl_all == trl_rejection.artifact(i,1));
            [x(i,2),y(i,2)] = find(cfg.trl_all == trl_rejection.artifact(i,2));
            
            trl_rejection.bad_trials(i,1) = x(i,1);
            trl_rejection.bad_trials(i,2:3) = y(i,:);
            % store a variable that determines what artifacts are part of which
            % trials
            if i>=2
                if x(i,1)~=x(i-1,1)
                    counter=counter+1;
                end
            end
            trl_rejection.bad_trials(i,4) = counter;
        end
        
        %get rid of redundency (some trials contain multiple artifacts)
        if isempty (trl_rejection.artifact) == 0
            trl_rejection.bad_trials_noRepeats = unique(trl_rejection.bad_trials(:,1));
        end
        
        % Visualize the bad trials
        % Make an array of the EOG elecs
        for i=1:length(EOGchans)
            EOGchansIdx(i) = find(strcmp(EOGchans{i},interp.label)==1);
        end
        if plotArtifacts == 1
            counter=1;
            figure('Name','Bad Trials')
            % Create a counter to keep track of which segments need to be drawn
            % on which trials
            artiCounter = 1;
            for i=1:length(trl_rejection.bad_trials_noRepeats)
                % Plot them in figures of 49 per figure to minimize total num of figs
                subplot(7,7,counter)
                plot(interp.trial{trl_rejection.bad_trials_noRepeats(i)}(EOGchansIdx,:)');
                hold on
                
                while artiCounter < length(trl_rejection.bad_trials)
                    % Draw lines to mark the artifact on the trial
                    plot([trl_rejection.bad_trials(artiCounter,2) trl_rejection.bad_trials(artiCounter,2)],[-50 50],'c');
                    plot([trl_rejection.bad_trials(artiCounter,3) trl_rejection.bad_trials(artiCounter,3)],[-50 50],'g');
                    if trl_rejection.bad_trials(artiCounter,4)~=trl_rejection.bad_trials(artiCounter+1,4)   % Keep checking the next item in the array to make sure it isn't part of the same trial
                        artiCounter = artiCounter+1;
                        break
                    end
                    artiCounter = artiCounter+1;
                end
                
                title(sprintf('%s%d','Trial: ',trl_rejection.bad_trials_noRepeats(i)));
                ylim([-50 50]);
                
                if counter>=49
                    counter=0;
                    figure('Name','Bad Trials')
                end
                counter=counter+1;
            end
            % Visualize the good trials to compare
            % Make an array of non artifact trials
            goodTrials = setdiff(1:length(data.trial),trl_rejection.bad_trials_noRepeats);
            counter=1;
            figure('Name','Good Trials')
            for i=1:length(goodTrials)
                % Plot them in figures of 49 per figure to minimize total num of figs
                subplot(7,7,counter)
                plot(interp.trial{goodTrials(i)}(EOGchansIdx,:)');
                hold on
                title(sprintf('%s%d','Trial: ',goodTrials(i)));
                ylim([-50 50]);
                
                if counter>=49
                    counter=0;
                    figure('Name','Good Trials')
                end
                counter=counter+1;
            end
        end
        
        %% Remove bad trials
        %if trials contains this many bad chans, remove
        trl_rejection.bad_chan_thresh = 100;
        
        %Find segments that have too many bad chans
        for i= 1:length(bad_chans)
            if length(bad_chans{i}) >trl_rejection.bad_chan_thresh
                trl_rejection.bad_seg_ch(i,1) =1;
            else
                trl_rejection.bad_seg_ch(i,1) = 0;
            end
        end
        
        %Combine all bad trials into single variable
        if isempty(trl_rejection.artifact) == 0
            trl_rejection.bad_segs_all = vertcat(trl_rejection.bad_trials_noRepeats, find(trl_rejection.bad_seg_ch));
        elseif isempty(trl_rejection.artifact) == 1
            trl_rejection.bad_segs_all = vertcat(find(trl_rejection.bad_seg_ch));
        end
        trl_rejection.bad_segs_all = sort(unique(trl_rejection.bad_segs_all));
        
        %create segement time containing artifact
        for i = 1:length(trl_rejection.bad_segs_all)
            trl_rejection.bad_seg_all_time(i,1) = cfg.trl(trl_rejection.bad_segs_all(i));
            trl_rejection.bad_seg_all_time(i,2) = trl_rejection.bad_seg_all_time(i,1)+250;
        end
        
        %Remove bad trials
        
        cfg.artfctdef.eog.artifact = trl_rejection.bad_seg_all_time;
        interp = ft_rejectartifact(cfg, interp);
        
        % Add the other 2 columns to 'trialinfo'
        interp.trialinfo(:,2) = cfg.info(setdiff(1:625,trl_rejection.bad_segs_all),2);
        interp.trialinfo(:,3) = cfg.info(setdiff(1:625,trl_rejection.bad_segs_all),3);
        interp.info = interp.trialinfo;
        if fakeData == 1
            %Create folder to store results for subject & naviagte into that folder
            %         resultsDir = sprintf('%s%s',subjList{n},'_results');
            resultsDir = sprintf('%s%s%s%s',subjList{n},'_FakeData/',subjList{n},'_FakeData_results_30HzLP');
            % check to see if this file exists
            cd ./FakeData/
            if exist(resultsDir,'file')
            else
                mkdir(resultsDir);
            end
            cd(sprintf('%s','./',resultsDir))
            
            % Save the preprocessing data for each participant in their respective
            % folders
            save(sprintf('%s%s%d',subjList{n},'_FakeData_Ens_VEP_Prep_',m),'interp','cfg','trl_rejection','fakeDataBadChanList');
            
            % CD back to the data folder for next participant
            cd ../../../
        else
            %Create folder to store results for subject & naviagte into that folder
            %         resultsDir = sprintf('%s%s',subjList{n},'_results');
            resultsDir = sprintf('%s%s',subjList{n},'_results_100msBL');
            % check to see if this file exists
            cd(sprintf('%s','./',subjList{n}))
            if exist(resultsDir,'file')
            else
                mkdir(resultsDir);
            end
            cd(sprintf('%s','./',resultsDir))
            
            % Save the preprocessing data for each participant in their respective
            % folders
            save(sprintf('%s%s%d',subjList{n},'_Ens_VEP_Prep_',m),'interp','cfg','trl_rejection');
            
            % CD back to the data folder for next participant
            cd ../../
        end
        
    end
end











