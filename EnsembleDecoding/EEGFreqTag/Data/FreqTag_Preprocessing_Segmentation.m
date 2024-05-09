% Script for loading, preprocessing, and segmenting of freqeuncy tagging data for ENS
% dissertation project - 021319

clear all; close all;

plotArtifacts=0;
fakeData=0;

% Load in behavioral subject data
if fakeData == 0
    cd ../../
    ensDataStructBehav = ensLoadData('FreqTagBehav','All');
    cd ./'EEG Freq Tag'/Data/
    
    subjList = ensDataStructBehav.subjid;
elseif fakeData == 1
    % Make subject list equal to FakeData
    cd ../../
    ensDataStructBehav = ensLoadData('FreqTagBehavFake');
    cd ./'EEG Freq Tag'/Data/
    
    subjList = ensDataStructBehav.subjid;
end
%% Start analysis for each subject
% for n = 1:length(subjList)
for n=19:length(subjList)
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
    ensDataStructEEG = ensLoadData('FreqTagEEG',subjList{n});
    cd ./'EEG Freq Tag'/Data/
    
    rawdataEEG = ensDataStructBehav.rawdata{n};   % EEG Behavioral rawdata
    
    for m=1:2   % Load in/process both EEG runs
        
        fprintf('%s%d\n','RUN NUM: ',m);
        
        % Clear out old variables
        clear cfg data interp bad_chans EOGchans EOGchansIdx goodTrials neighbours trl_rejection x y artifactTotals
        
        %% Define trial info
        %trialfun function segments data
        % CFG - configure data
        cfg = [];
        cfg.trialfun = 'trialFun_Ens_FreqTag';
        cfg.dataset = sprintf('%s%s',ensDataStructEEG.rawdataFreqTagEEGPath{m},'.mff');   % Raw EEG data file
        cfg.headerfile = sprintf('%s%s',ensDataStructEEG.rawdataFreqTagEEGPath{m},'.mff');  % Same thing
        cfg.datafile = sprintf('%s%s',ensDataStructEEG.rawdataFreqTagEEGPath{m},'.mff');   % Same thing
        
        %Store info containing category info in cfg
        if m==1
            cfg.info = ensDataStructEEG.info(1:length(ensDataStructEEG.info)/2,:);   % Indices for you conditions 1 by numtrials
        elseif m==2
            cfg.info = ensDataStructEEG.info(length(ensDataStructEEG.info)/2+1:end,:);   % Indices for you conditions 1 by numtrials
        end
        
        %define trial function
        % Calls trialfun here
        cfg = ft_definetrial(cfg);   % Define each trial based on behavioral data; define start/end/offset
        
        % This is specifically for ZZ in freq tag who missed a DIN after mid-way
        % impedence check.
        % Update cfg file to reflect the missing channel
        if strcmp(subjList{n},'ZZ') & m == 1  
            missingDINIdx = find(strcmp('IBEG',{cfg.event.value}))-1;   % Find the first impedance DIN label 'IBEG'
            cfg.info(missingDINIdx,:) = [];
        end
        
        %% Load/Segment EEG data/Reref/Filter
        % Specify certain preprocesisng params
        cfg.continuous = 'yes';
        
        % DO THIS AT THE END
        %rereference to avergae ref
        %         cfg.reref         = 'yes';   % Reref to average
        %         cfg.refchannel    = {'all'};
        
        %bandpass filter .5 - 60
        cfg.bpfilter      =  'yes';
        cfg.bpfreq    =    [.5 60];
        
        %Load data
        data = ft_preprocessing(cfg);
        
        % If looking at fake data then create it here and insert into the
        % 'trial' sub feild according to its location in the info subfeild.
        if fakeData == 1
            clear eegDataHolder fakeDataAmpSelect fakeDataSelect
            
            % Create EEG data
            
            % Assign amplitudes for each condition
            fakeDataAmpSelect(1,:) = [1 3 5 7 9];
            fakeDataAmpSelect(2,:) = [2 4 6 8 10];
            
            %time axis - 1000 time points (1 second)
            t = 0:.001:.699;
            
            % random noise value
            noise = 0.1;
            
            % Find indices of trials in each condition
            counter = 0;
            for i=1:5
                counter = counter+1;
                fakeDataSelect{1,i} = find(cfg.info(:,2)==counter);
                
                fakeDataSelect{2,i} = find(cfg.info(:,3)==counter);
            end
            
            % Generate sine waves to insert into data
            for i=1:5
                for j=1:size(data.trial{1},1)
                    % Orientation
                    for k=1:size(fakeDataSelect{1,i})
                        eegDataHolder1(i,k,j,:) = (fakeDataAmpSelect(1,i) .*sin(pi*2*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));
                    end
                    
                    % Size
                    for k=1:size(fakeDataSelect{2,i})
                        eegDataHolder2(i,k,j,:) = (fakeDataAmpSelect(2,i) .*sin(pi*2*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));
                    end
                end
            end
            
            %             % Double check to make sure the amps are what they should be by
            %             % plotting the averages of all trials.
            %             figure('Name','Orientation')
            %             for i=1:5
            %                 plot(squeeze(mean(squeeze(eegDataHolder1(i,:,1,:)),1))')
            %                 hold on
            %             end
            %             ylim([-10 10]);
            %             legend({'1','2','3','4','5'})
            %
            %             figure('Name','Size')
            %             for i=1:5
            %                 plot(squeeze(mean(squeeze(eegDataHolder2(i,:,1,:)),1))')
            %                 hold on
            %             end
            %             ylim([-10 10]);
            %             legend({'1','2','3','4','5'})
            
            % Make a new data file to compare
            data2 = data;
            
            % Insert the fake data into the dataset
            for i=1:5
                for j=1:size(fakeDataSelect{1,i})   % Orientation
                    data2.trial{1,fakeDataSelect{1,i}(j)} = squeeze(eegDataHolder1(i,j,:,:));
                end
                
                for j=1:size(fakeDataSelect{2,i})   % Size
                    data2.trial{1,fakeDataSelect{2,i}(j)} = squeeze(eegDataHolder2(i,j,:,:));
                end
            end
            
            % Make on 2 bad channels in each trial and save which channels
            % they are
            for i=1:length(data2.trial)
                for j=1:2
                    fakeDataBadChanList(n,i,j) = randi(257);
                    if j==1
                        data2.trial{i}(fakeDataBadChanList(n,i,j),:) = (100 .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));
                    elseif j==2
                        data2.trial{i}(fakeDataBadChanList(n,i,j),:) = (75 .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));
                    end
                end
            end
            
            %             %  Compare old data with new data
            %             figure('Name','Fake Data Orientation')
            %             counter = 0;
            %             for i=1:5
            %                 for j=1:2
            %                     counter = counter+1;
            %                     subplot(5,2,counter)
            %                     if j==1
            %                         plot(squeeze(data2.trial{1,fakeDataSelect{1,i}(j)})')
            %                         hold on
            %                         ylim([-10 10]);
            %                     elseif j==2
            %                         plot(squeeze(data.trial{1,fakeDataSelect{1,i}(j)})')
            %                         hold on
            %                         ylim([-50 50]);
            %                     end
            %                 end
            %             end
            %
            %             figure('Name','Size')
            %             counter = 0;
            %             for i=1:5
            %                 for j=1:2
            %                     counter = counter+1;
            %                     subplot(5,2,counter)
            %                     if j==1
            %                         plot(squeeze(data2.trial{1,fakeDataSelect{2,i}(j)})')
            %                         hold on
            %                         ylim([-10 10]);
            %                     elseif j==2
            %                         plot(squeeze(data.trial{1,fakeDataSelect{2,i}(j)})')
            %                         hold on
            %                         ylim([-50 50]);
            %                     end
            %                 end
            %             end
            
            % Set new data struct
            data = data2;
            
        end
        
        %% Artfiact detection - bad channels
        %Call custom script for bad channel detection, returns bad_chans
        %conatining bad chans per trail
        [bad_chans]= BCD_FreqTag(data.trial);
        
        %Define nets
        cfg.elec = ft_read_sens('GSN-HydroCel-257.sfp');
        cfg.layout = cfg.elec;
        
        %method for neighbors search
        cfg.method = 'distance';
        
        %Define Neighbors for BCR
        [neighbours, cfg] = ft_prepare_neighbours(cfg,data);
        cfg.neighbours = neighbours;
        
        %method for BCR
        cfg.method = 'weighted';
        
        interp = data;  % Holder variable
        
        %Repair the channels
        for i = 1:length(data.trial)
            
            if bad_chans{i}(:) == 0
                cfg.badchannel = [];
                cfg.trials = i;
            else
                bad_chans{i}(:) = bad_chans{i}(:);
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
        % For FreqTag we don't want to reject trials for EBs or EMs unless
        % there are an excessive amount (>10 in a 20 s trial).
        
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
        
        % List every time point for all 20,000 in each trial
        %Find all segments (ms) for each trial
        for i = 1:length(cfg.info)
            cfg.trl_all(i,:) = cfg.trl(i,1):cfg.trl(i,2);
        end
        
        % Find the corresponding trial number for each artifact
        % WILL GIVE REPEATS AS MULTIPLE ARTIFACTS CAN HAPPEN IN A SINGLE TRIAL
        counter=1;
        counter2=0;
        for i = 1:length(trl_rejection.artifact)
            % Check to see if the segment exists, if not ignore it
            if ~isempty(find(cfg.trl_all == trl_rejection.artifact(i,1)))
                
                counter2 = counter2+1;
                
                [x(counter2,1),y(counter2,1)] = find(cfg.trl_all == trl_rejection.artifact(i,1));
                [x(counter2,2),y(counter2,2)] = find(cfg.trl_all == trl_rejection.artifact(i,2));
                
                trl_rejection.bad_trials(counter2,1) = x(counter2,1);
                trl_rejection.bad_trials(counter2,2:3) = y(counter2,:);
                % store a variable that determines what artifacts are part of which
                % trials
                if counter2>=2
                    if x(counter2,1)~=x(counter2-1,1)
                        counter=counter+1;
                    end
                end
                trl_rejection.bad_trials(counter2,4) = counter;
            end
        end
        
        %         %get rid of redundency (some trials contain multiple artifacts)
        %         if isempty (trl_rejection.artifact) == 0
        %             trl_rejection.bad_trials_noRepeats = unique(trl_rejection.bad_trials(:,1));
        %         end
        
        % Make a list of the number of artifacts per trial
        counter = 1;
        counter2 = 1;
        holder = trl_rejection.bad_trials(1);
        for i=2:length(trl_rejection.bad_trials)
            if holder == trl_rejection.bad_trials(i)
                counter = counter + 1;
            else
                holder = trl_rejection.bad_trials(i);
                counter = 1;
                counter2 = counter2+1;
            end
            artifactTotals(counter2,1) = counter;
        end
        
        % Add the artifact totals to the trl_rejection struct
        trl_rejection.artifactTotals = artifactTotals;
        
        %% Visualize the bad trials
        if plotArtifacts == 1
            % Make an array of the EOG elecs
            for i=1:length(EOGchans)
                EOGchansIdx(i) = find(strcmp(EOGchans{i},interp.label)==1);
            end
            
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
        %if trials contains this many bad channels, it will be removed
        trl_rejection.bad_chan_thresh = 100;
        
        %Find segments that have too many bad chans
        for i= 1:length(bad_chans)
            if length(bad_chans{i}) > trl_rejection.bad_chan_thresh
                trl_rejection.bad_seg_ch(i,1) =1;
            else
                trl_rejection.bad_seg_ch(i,1) = 0;
            end
        end
        
        %Combine all bad trials into single variable
        if isempty(trl_rejection.artifact) == 0
            trl_rejection.bad_segs_all = vertcat(find(trl_rejection.artifactTotals >= 10), find(trl_rejection.bad_seg_ch));
        elseif isempty(trl_rejection.artifact) == 1
            trl_rejection.bad_segs_all = vertcat(find(trl_rejection.bad_seg_ch));
        end
        trl_rejection.bad_segs_all = sort(unique(trl_rejection.bad_segs_all));
        
        %create segement time containing artifact
        for i = 1:length(trl_rejection.bad_segs_all)
            trl_rejection.bad_seg_all_time(i,1) = cfg.trl(trl_rejection.bad_segs_all(i));
            trl_rejection.bad_seg_all_time(i,2) = trl_rejection.bad_seg_all_time(i,1)+size(interp.trial{1},2);
        end
        
        %Remove bad trials
        if ~isempty(trl_rejection.bad_segs_all)
            cfg.artfctdef.eog.artifact = trl_rejection.bad_seg_all_time;
            interp = ft_rejectartifact(cfg, interp);
        end
        
        % Add the other 2 columns to 'trialinfo'
        interp.trialinfo(:,2) = cfg.info(setdiff(1:size(cfg.info,1),trl_rejection.bad_segs_all),2);
        interp.trialinfo(:,3) = cfg.info(setdiff(1:size(cfg.info,1),trl_rejection.bad_segs_all),3);
        interp.trialinfo(:,4) = cfg.info(setdiff(1:size(cfg.info,1),trl_rejection.bad_segs_all),4);
        interp.trialinfo(:,5) = cfg.info(setdiff(1:size(cfg.info,1),trl_rejection.bad_segs_all),5);
        interp.trialinfo(:,6) = cfg.info(setdiff(1:size(cfg.info,1),trl_rejection.bad_segs_all),6);
        
        interp.info = interp.trialinfo;
        if fakeData == 1
            %Create folder to store results for subject & naviagte into that folder
            %         resultsDir = sprintf('%s%s',subjList{n},'_results');
            resultsDir = sprintf('%s%s%s%s',subjList{n},'_FakeData/',subjList{n},'_FakeData_results');
            % check to see if this file exists
            cd ./FakeData/
            if exist(resultsDir,'file')
            else
                mkdir(resultsDir);
            end
            cd(sprintf('%s','./',resultsDir))
            
            % Save the preprocessing data for each participant in their respective
            % folders
            save(sprintf('%s%s%d',subjList{n},'_FakeData_Ens_FreqTag_Prep_',m),'interp','cfg','trl_rejection','fakeDataBadChanList');
            
            % CD back to the data folder for next participant
            cd ../../../
        else
            
            %Create folder to store results for subject & naviagte into that folder
            %         resultsDir = sprintf('%s%s',subjList{n},'_results');
            resultsDir = sprintf('%s%s',subjList{n},'_results_60HzLP');
            % check to see if this file exists
            cd(sprintf('%s','./',subjList{n}))
            if exist(resultsDir,'file')
            else
                mkdir(resultsDir);
            end
            cd(sprintf('%s','./',resultsDir))
            
            % B/c the data is so large (interp.trial = ~4GB) seperate and save
            % into individual files. Have one file for each trial and one
            % interp file with no trial subfeild. In the next script load
            % in and re-combine the files.
            % CD/Make the trial directory
            trialDir = sprintf('%s%s%d',subjList{n},'_Ens_FreqTag_Prep_',m);
            if exist(trialDir,'file')
            else
                mkdir(trialDir);
            end
            cd(sprintf('%s','./',trialDir))
            
            for i=1:length(interp.trial)
                % Preall a new variable using eval and assign trial to that value
                eval(sprintf('%s%d','Run_',m,'_Trial_',i,'(:,:) = interp.trial{i};'))                
                
                % Save the trial to a folder for that run
                save(sprintf('%s%d','Run_',m,'_Trial_',i),sprintf('%s%d','Run_',m,'_Trial_',i));
                
                % Clear that trial from interp.trial and new variable from
                % workspace to save space
                interp.trial{i} = {};
                clear(sprintf('%s%d%s%d','Run_',m,'_Trial_',i))
            end
            
            % Return to result directory
            cd ../
            
            % Save the preprocessing data for each participant in their respective
            % folders
            save(sprintf('%s%s%d',subjList{n},'_Ens_FreqTag_Prep_',m),'interp','cfg','trl_rejection');
            
            % CD back to the data folder for next participant
            cd ../../
        end
    end
end







