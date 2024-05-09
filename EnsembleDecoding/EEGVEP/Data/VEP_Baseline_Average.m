% Script for baseline correction, segmenting into conditions, and averaging
% for VEP dissertation project - 100418

clear all; 
% close all;

segAll = 0;
segCond = 1;

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Ori','Size'};

% Load in behavioral subject data
cd ../../
ensDataStructBehav = ensLoadData_LabComp2('VEPBehav','All');
cd ./'EEG VEP'/Data/

subjList = ensDataStructBehav.subjid;

%% Segment/Trial Average/Baseline
for n=1:length(subjList)
% for n=11:length(subjList)
    fprintf('%s%d\n','Subj: ',n)
    clear ERP_AV_allConds ERP_AV_Ori ERP_AV_Size
    for j=1:2   % For each run
        fprintf('%s%d\n','Run: ',j)
        % Clear out cfg and interp files for next load
        clear cfg interp trl_rejection
        
        % Load in preprocessed data
%         cd(sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results'))   % CD into the participant results folder to grab the preproc data
        cd(sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
        load(sprintf('%s%s%d',subjList{n},'_Ens_VEP_Prep_',j))   % Load
        cd ../../ % CD back into data folder
        
        %Baseline
        cfg.baseline = [-100 0];
        interp.cfg.keeptrials  = 'yes';
        
        % Clean up the cfg/interp structure a bit to avoid warnings in output
%         cfg.preproc.reref = cfg.reref;
%         cfg.preproc.refchannel = cfg.refchannel;
        cfg.preproc.bpfilter = cfg.bpfilter;
        cfg.preproc.bpfreq = cfg.bpfreq;
%         cfg = rmfield(cfg,{'reref','refchannel','bpfilter','bpfreq'});
        cfg = rmfield(cfg,{'bpfilter','bpfreq'});
        interp = rmfield(interp,'info');
        
        % Segment trials into 50 groups and do BLC/averaging across those
        % groups.
        % Segment trials into condition groups: % 1=ori1,size1,taskori; 2=ori2,size1,taskori; 3=ori3,size1,taskori;...;
        % 24=ori4,size5,taskori; 25=ori5,size5,taskori; 26=ori1,size1,tasksize
        if segAll == 1
            for i=1:length(cats.ori)*length(cats.size)*length(cats.task)
                clear trl thiserp
                
                %pick off trials corresponding to each condition,
                trl = find(interp.trialinfo(:,1)==i);
                
                % Baseline correct
                %Perform baseline correction on ERP data
                cfg.trials = trl;   % Set config file to only trials in this condition
                
                thiserp.av = ft_timelockanalysis(cfg, interp);
                [thiserp.av] = ft_timelockbaseline(cfg,thiserp.av);
                %Save to ERP_AV cell
                % Record both ave's from each run
                ERP_AV_allConds{j,i} = thiserp.av;
            end
        end
        
        % Segment into 5 groups for both feature per task, 20 total (segment across all size
        % levels for each orienation and vice versa). Means there will be
        % overlap in trials in each group. 1=ori1sizeall,oritask;
        % 2=ori2sizeall,oritask;...;6=ori1sizeall,sizetask
        if segCond ==1
            for i=1:length(cats.ori)*length(cats.task)
                clear trlOri trlSize thiserpOri thiserpSize
                
                % Pick off trials corresponding to each condition
                trlOri = find(interp.trialinfo(:,2)==i);   % Find trials corresponding to ori condition
                trlSize = find(interp.trialinfo(:,3)==i);   % Find trials corresponding to size condition
                
                % Baseline correct for ori
                cfg.trials = trlOri;
                thiserpOri.av = ft_timelockanalysis(cfg, interp);
                [thiserpOri.av] = ft_timelockbaseline(cfg,thiserpOri.av);
                ERP_AV_Ori{j,i} = thiserpOri.av;   % Save to ERP_AV
                
                % Baseline correct for size
                cfg.trials = trlSize;
                thiserpSize.av = ft_timelockanalysis(cfg, interp);
                [thiserpSize.av] = ft_timelockbaseline(cfg,thiserpSize.av);
                ERP_AV_Size{j,i} = thiserpSize.av;   % Save to ERP_AV
                
            end
        end
    end
    
    % Save
    if segAll == 1
        % Go from struct to array
        for j=1:2
            for k=1:size(ERP_AV_allConds,2)
                ERP_AV_allCondsMat(n,j,k,:,:) = ERP_AV_allConds{j,k}.avg;
            end
        end
        
        % Save the data segmented into conditions and averaged
        ERP_segAll = ERP_AV_allCondsMat(n,:,:,:,:);
        %         cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results'))
        %         save(sprintf('%s',subjList{n},'_segAll'),'ERP_segAll');
        cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
        save(sprintf('%s',subjList{n},'_segAll_30HzLP'),'ERP_segAll');
        cd ../../
        clear ERP_segAll
    end
    if segCond ==1
        % Go from struct to array
        for j=1:2
            for k=1:size(ERP_AV_Ori,2)
                ERP_AV_OriCondsMat(n,j,k,:,:) = ERP_AV_Ori{j,k}.avg;
                ERP_AV_SizeCondsMat(n,j,k,:,:) = ERP_AV_Size{j,k}.avg;
            end
        end
        
        % Save the data segmented into conditions and averaged
        ERP_segOri = ERP_AV_OriCondsMat(n,:,:,:,:);
        ERP_segSize = ERP_AV_SizeCondsMat(n,:,:,:,:);
%         cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results'))
%         save(sprintf('%s',subjList{n},'_segOri'),'ERP_segOri');
%         save(sprintf('%s',subjList{n},'_segSize'),'ERP_segSize');
        cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
        save(sprintf('%s',subjList{n},'_segOri_30HzLP'),'ERP_segOri');
        save(sprintf('%s',subjList{n},'_segSize_30HzLP'),'ERP_segSize');
        cd ../../
        clear ERP_segOri ERP_segSize
    end
    
    
%     %% IMPORTANT STUFF FOR COSMO SETUP FROM GENA SCRIPT Exp_Analysis
%     %Custom script averages exemplars in groups of 5
%     conditions = av_exemplars(interp);   % Gena custom script
%     
%     %Append all data together
%     data_all = ft_appenddata(cfg, conditions.bird, conditions.insect, conditions.grsp, conditions.tool);
%     
%     %Prep for cosmo format
%     cfg.keeptrials  = 'yes';
%     cfg.trials = 'all';
%     All_trials = ft_timelockanalysis(cfg, data_all);
%     
%     %Convert to cosmo format
%     %All_trials_ds = cosmo_meeg_dataset(All_trials);   % Function TO CONVERT INTO COSMO FORMAT
%     
%     %% DO THIS IN A SEPARATE SCRIPT (DON'T NEED A FUNCTION)
%     %Call custom function to run mvpa on the time series. Row 1: LDA, row
%     %2: Naive bayes
%     mvpa.Animate = run_mvpa_erp(All_trials,'Animate');
%     mvpa.Inanimate = run_mvpa_erp(All_trials,'Inanimate');
%     mvpa.Animacy = run_mvpa_erp(All_trials,'Animacy');
%     mvpa.all_cats = run_mvpa_erp(All_trials,'all');
%     
    
    
    
    
end

%% Group averages
if segAll == 1
    % Average across runs
    ERPcrossCondRunAve = squeeze(mean(ERP_AV_allCondsMat,2));
    
    % Separate trials based on condition
    condSelect(1,1,:,:) = [1,6,11,16,21; 2,7,12,17,22; 3,8,13,18,23; 4,9,14,19,24; 5,10,15,20,25];   % Ori1-5 - ori task
    condSelect(2,1,:,:) = [26,31,36,41,46; 27,32,37,42,47; 28,33,38,43,48; 29,34,39,44,49; 30,35,40,45,50];   % Size1-5 - ori task
    condSelect(1,2,:,:) = [1,2,3,4,5; 6,7,8,9,10; 11,12,13,14,15; 16,17,18,19,20; 21,22,23,24,25];   % Ori1-5 - size task
    condSelect(2,2,:,:) = [26,27,28,29,30; 31,32,33,34,35; 36,37,38,39,40; 41,42,43,44,45; 46,47,48,49,50];   % Ori1-5 - size task
    for n=1:size(ERPcrossCondRunAve,1)  % Subj
        for i=1:2   % task 1=ori 2=size
            for j=1:2   % stimuli 1=ori 2=size
                for k=1:5   % 5 lvls
                    
                    ERPcrossCond{n,i,j,k} = squeeze(cat(1,ERPcrossCondRunAve(n,condSelect(i,j,k,1),:,:),ERPcrossCondRunAve(n,condSelect(i,j,k,2),:,:),...
                        ERPcrossCondRunAve(n,condSelect(i,j,k,3),:,:),ERPcrossCondRunAve(n,condSelect(i,j,k,4),:,:),ERPcrossCondRunAve(n,condSelect(i,j,k,5),:,:)));
                    
                end
            end
        end
    end
    
    % Average acrros the non relevant feature
    for n=1:size(ERPcrossCond,1)   % Subj
        for i=1:2   % task 1=ori 2=size
            for j=1:2   % stimuli 1=ori 2=size
                for k=1:5   % 5 lvls
                    ERPcrossCondAve(n,i,j,k,:,:) = squeeze(mean(squeeze(ERPcrossCond{n,i,j,k}),1));
                end
            end
        end
    end
    
    % Save data now that it is averaged across runs and the relevant feature
    for i=1:length(subjList)
        ERP_segAve = squeeze(ERPcrossCondAve(i,:,:,:,:,:));
%         cd(sprintf('%s','./',subjList{i},'/',subjList{i},'_results'))
        cd(sprintf('%s','./',subjList{i},'/',subjList{i},'_results_100msBL_NoReref'))
        save(sprintf('%s',subjList{i},'_segAllAve_30HzLP'),'ERP_segAve');
        cd ../../
        clear ERP_segAve
    end
    
    % Average across participant
    ERPcrossCondPartAve = squeeze(mean(ERPcrossCondAve,1));
    
    % Save averaged data
    cd ./Group_Results_100msBL_NoReref/
    save('Group_segPartAve_30HzLP','ERPcrossCondPartAve');
    cd ../
    
end

if segCond ==1
    % Average across runs
    ERP_segOri_RunsAve = squeeze(mean(ERP_AV_OriCondsMat,2));
    ERP_segSize_RunsAve = squeeze(mean(ERP_AV_SizeCondsMat,2));
    
    % Save data now that it is averaged across runs
    for i=1:length(subjList)
        ERP_segOriAve = squeeze(ERP_segOri_RunsAve(i,:,:,:,:,:));
        ERP_segSizeAve = squeeze(ERP_segSize_RunsAve(i,:,:,:,:,:));
%         cd(sprintf('%s','./',subjList{i},'/',subjList{i},'_results'))
        cd(sprintf('%s','./',subjList{i},'/',subjList{i},'_results_100msBL_NoReref'))
        save(sprintf('%s',subjList{i},'_segOriAve_30HzLP'),'ERP_segOriAve');
        save(sprintf('%s',subjList{i},'_segSizeAve_30HzLP'),'ERP_segSizeAve');
        cd ../../
        clear ERP_segAve
    end
    
    % Average across participants
    ERP_segOri_PartAve = squeeze(mean(ERP_segOri_RunsAve,1));
    ERP_segSize_PartAve = squeeze(mean(ERP_segSize_RunsAve,1));    
    
    % Save group averaged data
    cd ./Group_Results_100msBL_NoReref/
%     save('Group_segOriPartAve','ERP_segOri_PartAve');
%     save('Group_segSizePartAve','ERP_segSize_PartAve');
    save('Group_segOriPartAve_30HzLP','ERP_segOri_PartAve');
    save('Group_segSizePartAve_30HzLP','ERP_segSize_PartAve');
    cd ../
end

%% Plot the data
elecList(1,:) = [136, 147, 148];   % Occipital
elecList(2,:) = [88, 119, 142];   % Parietal
elecList(3,:) = [35, 21, 4];   % Frontal

subTitleList = {'Occipital','Parietal','Frontal'};

titleList{1} = 'Ori During Ori';
titleList{2} = 'Size During Size';

if segAll == 1
    for k=1:2   % Task
        figure()
        counter = 1;
        suptitle(sprintf('%s\n\n',titleList{k}))
        for j=1:size(elecList,1)   % Area of electrode (occ, par, front)
            for i=1:size(elecList,2)   % Number of electrode
                subplot(3,3,counter)
                plot(squeeze([ERPcrossCondPartAve(k,k,1,elecList(j,i),:),ERPcrossCondPartAve(k,k,2,elecList(j,i),:),ERPcrossCondPartAve(k,k,3,elecList(j,i),:),...
                    ERPcrossCondPartAve(k,k,4,elecList(j,i),:),ERPcrossCondPartAve(k,k,5,elecList(j,i),:)])')   % Ori doing ori task
                hold on
                title(sprintf('%s%s%d',subTitleList{j},' Elec # ',elecList(j,i)));
                legend('1','2','3','4','5')
                
                counter = counter+1;
            end
        end
    end
end

if segCond ==1
    for k=1:2
        figure()
        counter = 1;
        suptitle(sprintf('%s\n\n',titleList{k}))
        for j=1:size(elecList,1)   % Area of electrode (occ, par, front)
            for i=1:size(elecList,2)   % Number of electrode
                subplot(3,3,counter)
                if k==1   % Ori
                    plot(squeeze([ERP_segOri_PartAve(1,elecList(j,i),:),ERP_segOri_PartAve(2,elecList(j,i),:),ERP_segOri_PartAve(3,elecList(j,i),:),...
                        ERP_segOri_PartAve(4,elecList(j,i),:),ERP_segOri_PartAve(5,elecList(j,i),:)])')   % Ori doing ori task
                elseif k==2   % Size
                    plot(squeeze([ERP_segSize_PartAve(1,elecList(j,i),:),ERP_segSize_PartAve(2,elecList(j,i),:),ERP_segSize_PartAve(3,elecList(j,i),:),...
                        ERP_segSize_PartAve(4,elecList(j,i),:),ERP_segSize_PartAve(5,elecList(j,i),:)])')   % Ori doing ori task
                end
                hold on
                title(sprintf('%s%s%d',subTitleList{j},' Elec # ',elecList(j,i)));
                legend('1','2','3','4','5')
                
                counter = counter + 1;
            end
        end
    end
end








