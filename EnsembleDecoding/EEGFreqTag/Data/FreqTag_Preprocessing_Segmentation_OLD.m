% Script for loading, preprocessing, and segmenting of freqeuncy tagging data for ENS
% dissertation project - 021319

clear all; close all;

plotArtifacts=0;
fakeData=0;
plotFakeData=0;

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
for n = length(subjList)
    % for n=16
    %% Load in behavioral data
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
        fprintf('%s%d\n','SUBJ NUM: ',n);
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
        
        fprintf('%s\n','Loading and preprocessing...');
        
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
            clear eegDataHolder fakeDataAmpSelect fakeDataSelect eegDataSum  
            
            fprintf('%s\n','Generating Fake Data...');
            
            % Create EEG data
            
            % Assign amplitudes for each condition
            fakeDataAmpSelect(1,:) = [2 2.2 2.4 2.6 2.8];   % 3 Hz att
            fakeDataAmpSelect(2,:) = [2.1 2.3 2.5 2.7 2.9];   % 5 Hz att
            fakeDataAmpSelect(3,:) = [0 .2 .4 .6 .8];   % 3 Hz unatt
            fakeDataAmpSelect(4,:) = [.1 .3 .5 .7 .9];   % 5 Hz unatt
            
            %time axis - 1000 time points (1 second)
            t = 0:.001:19.999;
            
            % random noise value
            noise = 0;
            
            % Preallocate the data array
            eegDataHolder = zeros(100,2,256,20000);
            
            % Determine the level of ori and size for each trial
            for i=1:length(cfg.info)
               condLvlIdx(i,1) = mod(cfg.info(i,2),5);   % Ori lvl
               condLvlIdx(i,2) = mod(cfg.info(i,3),5);   % Size lvl
               
               if condLvlIdx(i,1) == 0
                   condLvlIdx(i,1)=5;
               end
               if condLvlIdx(i,2) == 0
                   condLvlIdx(i,2)=5;
               end
            end
            
            % Generate sine waves to insert into data
            % For each trial you need to create 2 waveforms: 1 for 3Hz and
            % one for 5Hz. For both of these you need to know: which was
            % attended and not attended (for which you'll need to determine
            % which was presented right vs left) and the level presented
            % for that feature.
            for i=1:length(cfg.info)  % For all trials
                for j=1:256   % For all electrodes
                    if cfg.info(i,4)==1   % 3Hz left 5Hz right
                        if (cfg.info(i,1)>=1 && cfg.info(i,1)<=25) || (cfg.info(i,1)>=51 && cfg.info(i,1)<=75)   % Left att
                            if cfg.info(i,2) <= 10   % Orientation attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(1,condLvlIdx(i,1)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz att left ori task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(4,condLvlIdx(i,2)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz unatt right ori task
                            elseif cfg.info(i,2) >= 11   % Size attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(1,condLvlIdx(i,2)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz att left size task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(4,condLvlIdx(i,1)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz unatt right size task                            
                            end
                        elseif (cfg.info(i,1)>=26 && cfg.info(i,1)<=50) || (cfg.info(i,1)>=76 && cfg.info(i,1)<=100)   % Right att
                            if cfg.info(i,2) <= 10   % Orientation attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(3,condLvlIdx(i,2)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz unatt left ori task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(2,condLvlIdx(i,1)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz att right ori task
                            elseif cfg.info(i,2) <= 11   % Size attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(3,condLvlIdx(i,1)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz unatt left size task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(2,condLvlIdx(i,2)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz att right size task                         
                            end
                        end
                    elseif cfg.info(i,4)==2   % 3Hz right 5Hz left
                        if (cfg.info(i,1)>=1 && cfg.info(i,1)<=25) || (cfg.info(i,1)>=51 && cfg.info(i,1)<=75)   % Left att
                            if cfg.info(i,2) <= 10   % Orientation attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(3,condLvlIdx(i,2)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz unatt left ori task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(2,condLvlIdx(i,1)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz att right ori task
                            elseif cfg.info(i,2) >= 11   % Size attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(3,condLvlIdx(i,1)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz unatt left size task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(2,condLvlIdx(i,2)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz att right size task                            
                            end
                        elseif (cfg.info(i,1)>=26 && cfg.info(i,1)<=50) || (cfg.info(i,1)>=76 && cfg.info(i,1)<=100)   % Right att
                            if cfg.info(i,2) <= 10   % Orientation attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(1,condLvlIdx(i,1)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz att right ori task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(4,condLvlIdx(i,2)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz unatt left ori task
                            elseif cfg.info(i,2) <= 11   % Size attend
                                eegDataHolder(i,1,j,:) = (fakeDataAmpSelect(1,condLvlIdx(i,2)) .*sin(pi*3*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 3Hz att right size task
                                eegDataHolder(i,2,j,:) = (fakeDataAmpSelect(4,condLvlIdx(i,1)) .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));   % 5Hz unatt left size task                         
                            end
                        end
                    end
                end
            end
            
            % Add togethere the 2 waveforms for each trial
            % Preallocate the data array
            eegDataSum = zeros(100,257,20000);
            for i=1:size(eegDataHolder,1)
                for j=1:size(eegDataHolder,3)
                   eegDataSum(i,j,:) =  squeeze(eegDataHolder(i,1,j,:)+eegDataHolder(i,2,j,:));
                end
            end
            
            % Make a new data file to compare
            data2 = data;
            
            % Insert the fake data into the dataset
            for i=1:size(eegDataSum)
                data2.trial{1,i}(:,:) = eegDataSum(i,:,:);
            end
            
            % Make only 2 bad channels in each trial and save which channels
            % they are
            for i=1:length(data2.trial)
                for j=1:2
                    fakeDataBadChanList(n,i,j) = randi(257);
                    if j==1
                        data2.trial{i}(fakeDataBadChanList(n,i,j),:) = (10 .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));
                    elseif j==2
                        data2.trial{i}(fakeDataBadChanList(n,i,j),:) = (10 .*sin(pi*5*t))+(-noise+(noise-(-noise)).*rand(1,size(t,2)));
                    end
                end
            end
            
            % Set new data struct
            data = data2;

            % Analyze/plot some of the fake data to ensure it is correct
            if plotFakeData == 1
            
                % Make a list for each trial of: 3/5 Hz attended,and the
                % amplitude of each of those depending on att/no att.
                randTrial = randi(100,[10 1]);
                for i=1:length(randTrial)
                    % Which hemifeild is attended
                    if (cfg.info(randTrial(i),1) >= 1 && cfg.info(randTrial(i),1) <= 25) || (cfg.info(randTrial(i),1) >= 51 && cfg.info(randTrial(i),1) <= 75)   % Attend left
                        infoFakeDataTest(i,1) = 1;
                    elseif (cfg.info(randTrial(i),1) >= 26 && cfg.info(randTrial(i),1) <= 50) || (cfg.info(randTrial(i),1) >= 76 && cfg.info(randTrial(i),1) <= 100)   % Attend right
                        infoFakeDataTest(i,1) = 2;
                    end
                    
                    % Which position was 3/5 hz presented in for this trial
                    if cfg.info(randTrial(i),4) == 2 && infoFakeDataTest(i,1) == 1   % If 3Hz left and left att
                        infoFakeDataTest(i,2) = 1;
                    elseif cfg.info(randTrial(i),4) == 1 && infoFakeDataTest(i,1) == 1   % If 5Hz left and left att
                        infoFakeDataTest(i,2) = 2;
                    elseif cfg.info(randTrial(i),4) == 2 && infoFakeDataTest(i,1) == 2   % If 3Hz right and right att
                        infoFakeDataTest(i,2) = 3;
                    elseif cfg.info(randTrial(i),4) == 1 && infoFakeDataTest(i,1) == 2   % If 5Hz right and right att
                        infoFakeDataTest(i,2) = 4;
                    end
                    
                    % What task was presented
                    if cfg.info(randTrial(i),2)<=10 && cfg.info(randTrial(i),3)>=11   % Ori task
                        infoFakeDataTest(i,3) = 1;
                    elseif cfg.info(randTrial(i),2)>=11 && cfg.info(randTrial(i),3)<=10   % Size task
                        infoFakeDataTest(i,3) = 2;
                    end
                    
                    % what lvl of that task was presented
                    if infoFakeDataTest(i,3)==1   % If ori task
                        if cfg.info(randTrial(i),2) == 1 || cfg.info(randTrial(i),2) == 6   % lvl 1 (left or right att)
                            infoFakeDataTest(i,4) = 1;
                        elseif cfg.info(randTrial(i),2) == 2 || cfg.info(randTrial(i),2) == 7   % lvl 2 (left or right att)
                            infoFakeDataTest(i,4) = 2;
                        elseif cfg.info(randTrial(i),2) == 3 || cfg.info(randTrial(i),2) == 8   % lvl 3 (left or right att)
                            infoFakeDataTest(i,4) = 3;
                        elseif cfg.info(randTrial(i),2) == 4 || cfg.info(randTrial(i),2) == 9   % lvl 4 (left or right att)
                            infoFakeDataTest(i,4) = 4;
                        elseif cfg.info(randTrial(i),2) == 5 || cfg.info(randTrial(i),2) == 10   % lvl 5 (left or right att)
                            infoFakeDataTest(i,4) = 5;
                        end
                    elseif infoFakeDataTest(i,3)==2   % If size task
                        if cfg.info(randTrial(i),3) == 1 || cfg.info(randTrial(i),3) == 6   % lvl 1 (left or right att)
                            infoFakeDataTest(i,4) = 1;
                        elseif cfg.info(randTrial(i),3) == 2 || cfg.info(randTrial(i),3) == 7   % lvl 2 (left or right att)
                            infoFakeDataTest(i,4) = 2;
                        elseif cfg.info(randTrial(i),3) == 3 || cfg.info(randTrial(i),3) == 8   % lvl 3 (left or right att)
                            infoFakeDataTest(i,4) = 3;
                        elseif cfg.info(randTrial(i),3) == 4 || cfg.info(randTrial(i),3) == 9   % lvl 4 (left or right att)
                            infoFakeDataTest(i,4) = 4;
                        elseif cfg.info(randTrial(i),3) == 5 || cfg.info(randTrial(i),3) == 10   % lvl 5 (left or right att)
                            infoFakeDataTest(i,4) = 5;
                        end
                    end
                    
                    % Using the infoFakeDataTest determine what amplitudes
                    % are be present in each trial to later compare with
                    % the plots.
                    % First do the FFT on the selected trials and select
                    % the correct amplitudes.
                    for j=1:256
                        fftFakeDataFull(i,j,:) = abs(fft(data2.trial{randTrial(i)}(j,:)));
                        
                        fftFakeData(i,j,1) = fftFakeDataFull(i,j,31);   % 3 Hz
                        fftFakeData(i,j,2) = fftFakeDataFull(i,j,51);   % 5 Hz
                    end
                    
                    % Compare the actual FFT with the values that should be
                    % there.
                    % fakeDataAmpSelect(1,:) = [2 2.2 2.4 2.6 2.8];   % 3 Hz att
                    % fakeDataAmpSelect(2,:) = [2.1 2.3 2.5 2.7 2.9];   % 5 Hz att
                    % fakeDataAmpSelect(3,:) = [0 .2 .4 .6 .8];   % 3 Hz unatt
                    % fakeDataAmpSelect(4,:) = [.1 .3 .5 .7 .9];   % 5 Hz unatt
                    
                    % Attended amplitude
                    if infoFakeDataTest(i,2) == 1  || infoFakeDataTest(i,2) == 3   % If 3Hz left or right
                        fftFakeDataCompare(i,1) = fftFakeData(i,1,1);   % Extracted 3 Hz amp
                        fftFakeDataCompare(i,2) = fakeDataAmpSelect(1,infoFakeDataTest(i,4));   % Expected amp for the given lvl
                    elseif infoFakeDataTest(i,2) == 2  ||  infoFakeDataTest(i,2) == 4   % If 5Hz left or right
                        fftFakeDataCompare(i,1) = fftFakeData(i,1,2);   % Extracted 5 Hz amp
                        fftFakeDataCompare(i,2) = fakeDataAmpSelect(2,infoFakeDataTest(i,4));   % Expected amp for the given lvl
                    end
                    
                end
            end
        end
        
        %% Artfiact detection - bad channels
        
        fprintf('%s\n','Bad channel detection and repair...');
        
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
        % For FreqTag we don't want to reject trials for EBs or EMs unless
        % there are an excessive amount (>10 in a 20 s trial).
        
        fprintf('%s\n','Artifact detection and removal...');
        
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
        
        %         %get rid of redundency (some trials contain multiple artifacts)
        %         if isempty (trl_rejection.artifact) == 0
        %             trl_rejection.bad_trials_noRepeats = unique(trl_rejection.bad_trials(:,1));
        %         end
        
        % Make a list of the number of artifacts per trial
        counter = 1;
        counter2 = 1;
        if isempty(trl_rejection.bad_trials)
            artifactTotals = 0;
        else
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
            resultsDir = sprintf('%s%s%s%s',subjList{n},'_FakeData/',subjList{n},'_FakeData_results_60HzLP');
            % check to see if this file exists
            cd ./FakeData/
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







