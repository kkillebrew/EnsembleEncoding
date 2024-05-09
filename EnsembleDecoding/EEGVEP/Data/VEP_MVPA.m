% Run MVPA analysis on each milisecond of VEP data across all electrodes
% and participants.

clear all;
% close all;

%Input:
%data: Feildtrip data struct containing all data trials
%condition: String corresponding to decoding condition

% Load in behavioral subject data
cd ../../
ensDataStructBehav = ensLoadData_LabComp2('VEPBehav','All');
cd ./'EEG VEP'/Data/

subjList = ensDataStructBehav.subjid;

% How many trials should be averaged together before MVPA analysis
numTrials2Ave = 5;

%% Segment/Trial Average/Baseline
for n=1:length(subjList)
    % for n=1
    
    %% Load data
    clear interp1 interp2
    % Load in the two preprocessed data files (for each run).
    %     cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results'))
    cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_100msBL_NoReref'))
    interp1 = load(sprintf('%s',subjList{n},'_Ens_VEP_Prep_1.mat'),'interp');
    interp2 = load(sprintf('%s',subjList{n},'_Ens_VEP_Prep_2.mat'),'interp');
    cd ../../
    
    interp1 = interp1.interp;
    interp2 = interp2.interp;
    
    % Manually combine the info files since ft_appenddata doesn't do this
    info_comb = cat(1,interp1.info,interp2.info);
    sampleinfo_comb = cat(1,interp1.sampleinfo,interp2.sampleinfo+interp1.sampleinfo(end,2)+10);
    
    % Combine the two runs into one file using ft_appenddata
    interp_comb = ft_appenddata([],interp1,interp2);
    interp_comb.info = info_comb;
    interp_comb.sampleinfo = sampleinfo_comb;
    
    % Recreate the config file combining the two runs
    %     cfg_comb =
    
    %% SUPER IMPORTANT COSMO FORMATING STUFF
    %Custom script averages exemplars in groups of 5
    conditions = VEP_ave_exemplars(interp_comb,numTrials2Ave);   % custom script
    
    %Append all data together
    data_all_ori = ft_appenddata([], conditions.ori1, conditions.ori2, conditions.ori3, conditions.ori4, conditions.ori5);
    data_all_size = ft_appenddata([], conditions.size1, conditions.size2, conditions.size3, conditions.size4, conditions.size5);
    
    %Prep for cosmo format
    cfg.keeptrials  = 'yes';
    cfg.trials = 'all';
    All_trials_ori = ft_timelockanalysis(cfg, data_all_ori);
    All_trials_size = ft_timelockanalysis(cfg, data_all_size);
    
    %Which category to run (what conditions are being compared)
    categories = 'BigVSmall';
    
    % Run classifier for each level comparison (1-2,1-3,1-4,1-5)
    for m=2:5
        
        switch categories
            % Biggest/Most tilted vs smallest/least tilted
            case 'BigVSmall'
                num_cats = 2;
                cat_idx = [1 m];
                cat_idxall = [1 2 3 4 5];
        end
        
        %Convert FT file into cosmomvpa format
        All_trials_ds_ori = cosmo_meeg_dataset(All_trials_ori);
        All_trials_ds_size = cosmo_meeg_dataset(All_trials_size);
        
        %Length of data (number of trials)
        ldata_ori = length(All_trials_ds_ori.sa.trialinfo);
        ldata_size = length(All_trials_ds_size.sa.trialinfo);
        
        %Create trialinfo & target matrix
        mymat_ori = ones(ldata_ori,1);
        ech_cond = ldata_ori/5;
        ths_mat_ori = 1:ech_cond:ldata_ori;
        for i = 1:length(cat_idxall)
            mymat_ori(ths_mat_ori(i):(ths_mat_ori(i)+(ech_cond-1)),1) = cat_idxall(i);
        end
        
        mymat_size = ones(ldata_size,1);
        ech_cond = ldata_size/5;
        ths_mat_size = 1:ech_cond:ldata_size;
        for i = 1:length(cat_idxall)
            mymat_size(ths_mat_size(i):(ths_mat_size(i)+(ech_cond-1)),1) = cat_idxall(i);
        end
        
        %Set trialinfo and target variables
        All_trials_ds_ori.sa.trialinfo = mymat_ori;
        All_trials_ds_ori.sa.targets = All_trials_ds_ori.sa.trialinfo(:,1);
        
        All_trials_ds_size.sa.trialinfo = mymat_size;
        All_trials_ds_size.sa.targets = All_trials_ds_size.sa.trialinfo(:,1);
        
        %Set chunks. This analgous to fMRI runs. Each trial can be viewed as an independent chunk
        %This will be later changed using cosmo_chunkize
        All_trials_ds_ori.sa.chunks=[(1:length(All_trials_ds_ori.sa.trialinfo))]';
        All_trials_ds_size.sa.chunks=[(1:length(All_trials_ds_size.sa.trialinfo))]';
        
        %String labels for each category
        index_label_ori = {'ori1','ori2','ori3','ori4','ori5'};
        index_label_size = {'size1','size2','size3','size4','size5'};
        
        %Set sa.labels variable
        % Ori
        for i = 1:length(All_trials_ds_ori.sa.trialinfo)
            if All_trials_ds_ori.sa.trialinfo(i,1) ==1
                All_trials_ds_ori.sa.labels{i,1} = index_label_ori{1};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==2
                All_trials_ds_ori.sa.labels{i,1} = index_label_ori{2};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==3
                All_trials_ds_ori.sa.labels{i,1} = index_label_ori{3};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==4
                All_trials_ds_ori.sa.labels{i,1} = index_label_ori{4};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==5
                All_trials_ds_ori.sa.labels{i,1} = index_label_ori{5};
                
            end
        end
        % Size
        for i = 1:length(All_trials_ds_ori.sa.trialinfo)
            if All_trials_ds_ori.sa.trialinfo(i,1) ==1
                All_trials_ds_ori.sa.labels{i,1} = index_label_size{1};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==2
                All_trials_ds_ori.sa.labels{i,1} = index_label_size{2};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==3
                All_trials_ds_ori.sa.labels{i,1} = index_label_size{3};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==4
                All_trials_ds_ori.sa.labels{i,1} = index_label_size{4};
                
            elseif All_trials_ds_ori.sa.trialinfo(i,1) ==5
                All_trials_ds_ori.sa.labels{i,1} = index_label_size{5};
                
            end
        end
        
        %if there are only 2 categories, remove the others using cosmo_slice
        if num_cats == 2
            
            % Ori
            for i = 1:ldata_ori
                if mymat_ori(i) == cat_idx(1) || mymat_ori(i) == cat_idx(2)
                    mat_slice_ori(i) = 1;
                else
                    mat_slice_ori(i) = 0;
                end
            end
            
            %Create logical variable categories of interest
            mat_slice_ori = logical(mat_slice_ori);
            
            %Remove categories that are not being used
            All_trials_ds_ori = cosmo_slice(All_trials_ds_ori, mat_slice_ori);
            
            % Size
            for i = 1:ldata_size
                if mymat_size(i) == cat_idx(1) || mymat_size(i) == cat_idx(2)
                    mat_slice_size(i) = 1;
                else
                    mat_slice_size(i) = 0;
                end
            end
            
            %Create logical variable categories of interest
            mat_slice_size = logical(mat_slice_size);
            
            %Remove categories that are not being used
            All_trials_ds_size = cosmo_slice(All_trials_ds_size, mat_slice_size);
        end
        
        % Use cosmo_chunkize to break the runs into nchunks
        nchunks = 10;
        chunks_out_ori=cosmo_chunkize(All_trials_ds_ori,nchunks);
        chunks_out_size=cosmo_chunkize(All_trials_ds_size,nchunks);
        
        %Udpate sa.chunks
        All_trials_ds_ori.sa.chunks = chunks_out_ori;
        All_trials_ds_size.sa.chunks = chunks_out_size;
        
        %check data set to make sure everything is ok
        is_ok_ori = cosmo_check_dataset(All_trials_ds_ori);
        is_ok_size = cosmo_check_dataset(All_trials_ds_size);
        
        %Number of samples (trials)
        nsamples_ori=size(All_trials_ds_ori.samples,1);
        nsamples_size=size(All_trials_ds_size.samples,1);
        
        %Time samples to loop through
        time_samples_ori = length(unique(All_trials_ds_ori.fa.time));
        time_samples_size = length(unique(All_trials_ds_size.fa.time));
        
        %number of folds to loop through at each time point
        nfolds_ori = numel(unique(All_trials_ds_ori.sa.chunks));
        nfolds_size = numel(unique(All_trials_ds_size.sa.chunks));
        
        %% Ori MVPA
        %loop through each millisecond, perform
        for i = 1:time_samples_ori
            % allocate space for preditions for all samples
            %Try 3 classifiers svm, lda & niave bayes
            all_pred_lda_ori=zeros(nsamples_ori,1);
            all_pred_nb_ori=zeros(nsamples_ori,1);
            %all_pred_svm=zeros(nsamples,1);
            
            %create copy of all All_trials_ds to be used in this loop
            ds_ori = All_trials_ds_ori;
            
            %pull out samples corresponding to this millisecond(i)
            ds_ori.samples = ds_ori.samples(:,ds_ori.fa.time ==i);
            
            %Need to update channel and time information for new ds variable
            ds_ori.fa.chan =1:257;
            ds_ori.fa.time = ones(1,257)*i;
            
            %Create train and test indcies
            p_ori=cosmo_nfold_partitioner(ds_ori);
            q_ori=cosmo_balance_partitions(p_ori,ds_ori);
            
            %loop through number of folds
            for fold=1:nfolds_ori
                % Pull out train samples from ds dataset, store in ds_train
                ds_train_ori=cosmo_slice(ds_ori,q_ori.train_indices{fold});
                
                % Pull out test samples from ds dataset, store in ds_test
                ds_test_ori=cosmo_slice(ds_ori,q_ori.test_indices{fold});
                
                % Use cosmo_classify to get predicted targets for the
                % samples in 'ds_test'. To do so, use the samples and targets
                % from 'ds_train' for training (as first and second argument for
                % cosmo_classify), and the samples from 'ds_test' for testing
                % (third argument for cosmo_classify_lda).
                % Assign the result to the variable 'fold_pred', which should be a 6x1
                fold_pred_lda_ori=cosmo_classify_lda(ds_train_ori.samples,ds_train_ori.sa.targets,ds_test_ori.samples);
                fold_pred_nb_ori=cosmo_classify_naive_bayes(ds_train_ori.samples,ds_train_ori.sa.targets,ds_test_ori.samples);
                %fold_pred_svm=cosmo_classify_svm(ds_train.samples,ds_train.sa.targets,ds_test.samples);
                
                % store the predictions from 'fold_pred' in the 'all_pred' vector,
                % at the positions masked by 'test_msk'.
                all_pred_lda_ori(q_ori.test_indices{fold})=fold_pred_lda_ori;
                all_pred_nb_ori(q_ori.test_indices{fold})=fold_pred_nb_ori;
                %all_pred_svm(q.test_indices{fold})=fold_pred_svm;
            end
            
            %Balancing partitions with 10 chunks may cause certain trials to be excluded
            %This will lead to 0s in the all_pred file. Find zeros and those remove positions
            blanks = find(all_pred_lda_ori ==0);
            all_pred_lda_ori(blanks) = [];
            temp_target_lda_ori = ds_ori.sa.targets;
            temp_target_lda_ori(blanks) =[];
            
            blanks = find(all_pred_nb_ori ==0);
            all_pred_nb_ori(blanks) = [];
            temp_target_nb_ori = ds_ori.sa.targets;
            temp_target_nb_ori(blanks) =[];
            
            %     blanks = find(all_pred_svm ==0);
            %     all_pred_svm(blanks) = [];
            %     temp_target_svm = ds.sa.targets;
            %     temp_target_svm(blanks) =[];
            
            %Store accuracy for each time point & classifier
            accuracy_ori(1,i)=100.*mean(all_pred_lda_ori==temp_target_lda_ori);
            accuracy_ori(2,i)=100.*mean(all_pred_nb_ori==temp_target_nb_ori);
            %    accuracy(3,i)=mean(all_pred_svm==ds.sa.targets);
            
            %         %Store confusion matrix and accuracy for each classifier
            %         [confusion_matrix label_index]=cosmo_confusion_matrix(temp_target_lda,all_pred_lda);
            %         CM{1,i} = confusion_matrix;
            %
            %         [confusion_matrix label_index]=cosmo_confusion_matrix(temp_target_nb,all_pred_nb);
            %         CM{2,i} = confusion_matrix;
            
            %     [confusion_matrix label_index]=cosmo_confusion_matrix(temp_target_svm,all_pred_svm);
            %     CM{3,i} = confusion_matrix;
        end
        
        %% Size MVPA
        %loop through each millisecond, perform
        for i = 1:time_samples_size
            % allocate space for preditions for all samples
            %Try 3 classifiers svm, lda & niave bayes
            all_pred_lda_size=zeros(nsamples_size,1);
            all_pred_nb_size=zeros(nsamples_size,1);
            %all_pred_svm=zeros(nsamples,1);
            
            %create copy of all All_trials_ds to be used in this loop
            ds_size = All_trials_ds_size;
            
            %pull out samples corresponding to this millisecond(i)
            ds_size.samples = ds_size.samples(:,ds_size.fa.time ==i);
            
            %Need to update channel and time information for new ds variable
            ds_size.fa.chan =1:257;
            ds_size.fa.time = ones(1,257)*i;
            
            %Create train and test indcies
            p_size=cosmo_nfold_partitioner(ds_size);
            q_size=cosmo_balance_partitions(p_size,ds_size);
            
            %loop through number of folds
            for fold=1:nfolds_size
                % Pull out train samples from ds dataset, store in ds_train
                ds_train_size=cosmo_slice(ds_size,q_size.train_indices{fold});
                
                % Pull out test samples from ds dataset, store in ds_test
                ds_test_size=cosmo_slice(ds_size,q_size.test_indices{fold});
                
                % Use cosmo_classify to get predicted targets for the
                % samples in 'ds_test'. To do so, use the samples and targets
                % from 'ds_train' for training (as first and second argument for
                % cosmo_classify), and the samples from 'ds_test' for testing
                % (third argument for cosmo_classify_lda).
                % Assign the result to the variable 'fold_pred', which should be a 6x1
                fold_pred_lda_size=cosmo_classify_lda(ds_train_size.samples,ds_train_size.sa.targets,ds_test_size.samples);
                fold_pred_nb_size=cosmo_classify_naive_bayes(ds_train_size.samples,ds_train_size.sa.targets,ds_test_size.samples);
                %fold_pred_svm=cosmo_classify_svm(ds_train.samples,ds_train.sa.targets,ds_test.samples);
                
                % store the predictions from 'fold_pred' in the 'all_pred' vector,
                % at the positions masked by 'test_msk'.
                all_pred_lda_size(q_size.test_indices{fold})=fold_pred_lda_size;
                all_pred_nb_size(q_size.test_indices{fold})=fold_pred_nb_size;
                %all_pred_svm(q.test_indices{fold})=fold_pred_svm;
            end
            
            %Balancing partitions with 10 chunks may cause certain trials to be excluded
            %This will lead to 0s in the all_pred file. Find zeros and those remove positions
            blanks = find(all_pred_lda_size ==0);
            all_pred_lda_size(blanks) = [];
            temp_target_lda_size = ds_size.sa.targets;
            temp_target_lda_size(blanks) =[];
            
            blanks = find(all_pred_nb_size ==0);
            all_pred_nb_size(blanks) = [];
            temp_target_nb_size = ds_size.sa.targets;
            temp_target_nb_size(blanks) =[];
            
            %     blanks = find(all_pred_svm ==0);
            %     all_pred_svm(blanks) = [];
            %     temp_target_svm = ds.sa.targets;
            %     temp_target_svm(blanks) =[];
            
            %Store accuracy for each time point & classifier
            accuracy_size(1,i)=100.*mean(all_pred_lda_size==temp_target_lda_size);
            accuracy_size(2,i)=100.*mean(all_pred_nb_size==temp_target_nb_size);
            %    accuracy(3,i)=mean(all_pred_svm==ds.sa.targets);
            
            %         %Store confusion matrix and accuracy for each classifier
            %         [confusion_matrix label_index]=cosmo_confusion_matrix(temp_target_lda,all_pred_lda);
            %         CM{1,i} = confusion_matrix;
            %
            %         [confusion_matrix label_index]=cosmo_confusion_matrix(temp_target_nb,all_pred_nb);
            %         CM{2,i} = confusion_matrix;
            
            %     [confusion_matrix label_index]=cosmo_confusion_matrix(temp_target_svm,all_pred_svm);
            %     CM{3,i} = confusion_matrix;
        end
        
        
        %% Plot participant accuracy
        %Function output:
        % Participant x Lvl Comparison x feature
        mvpa_accuracy(n,m,1).accuracy = accuracy_ori; %time series accuracy
        mvpa_accuracy(n,m,2).accuracy = accuracy_size;
        
        disp(n)
        
        %     figure('Name',subjList{n})
        %     % Ori
        %     subplot(2,2,1)
        %     plot(1:550,accuracy_ori(1,:));
        %     title(sprintf('%s%d%s%d','Average LDA Accuracy Orientation: ',cat_idx(1),' - ',cat_idx(2)));
        %     ylabel('Average Accuracy (Chance 50%)');
        %     ylim([30 70]);
        %
        %     subplot(2,2,2)
        %     plot(1:550,accuracy_ori(2,:));
        %     title(sprintf('%s%d%s%d','Average NB Accuracy Orientation: ',cat_idx(1),' - ',cat_idx(2)));
        %     ylabel('Average Accuracy (Chance 50%)');
        %     ylim([30 70]);
        %
        %     % Size
        %     subplot(2,2,3)
        %     plot(1:550,accuracy_size(1,:));
        %     title(sprintf('%s%d%s%d','Average LDA Accuracy Size: ',cat_idx(1),' - ',cat_idx(2)));
        %     ylabel('Average Accuracy (Chance 50%)');
        %     ylim([30 70]);
        %
        %     subplot(2,2,4)
        %     plot(1:550,accuracy_size(2,:));
        %     title(sprintf('%s%d%s%d','Average NB Accuracy Size: ',cat_idx(1),' - ',cat_idx(2)));
        %     ylabel('Average Accuracy (Chance 50%)');
        %     ylim([30 70]);
        %
        %     %Create folder to store results for subject & naviagte into that folder
        %     resultsDir = sprintf('%s%s',subjList{n},'_MVPA_results_30HzLP');
        %     % check to see if this file exists
        %     cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_30HzLP/'))
        %     if exist(resultsDir,'file')
        %     else
        %         mkdir(resultsDir);
        %     end
        %     cd(sprintf('%s','./',resultsDir))
        %
        % Save the preprocessing data for each participant in their respective
        % folders
        
    end
    
    % Create folder to store results for subject & naviagte into that folder
    resultsDir = sprintf('%s%s',subjList{n},'_MVPA_results_30HzLP');
    % check to see if this file exists
    cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_100msBL_NoReref/'))
    if exist(resultsDir,'file')
    else
        mkdir(resultsDir);
    end
    cd(sprintf('%s','./',resultsDir))
    
    %     save(sprintf('%s%d%s',subjList{n},numTrials2Ave,'a_MVPA_Ori'),'accuracy_ori');
    %     save(sprintf('%s%d%s',subjList{n},numTrials2Ave,'a_MVPA_Size'),'accuracy_size');
    save(sprintf('%s%d%s',subjList{n},numTrials2Ave,'a_MVPA_Ori_30HzLP_AllComparisons'),'accuracy_ori');
    save(sprintf('%s%d%s',subjList{n},numTrials2Ave,'a_MVPA_Size_30HzLP_AllComparisons'),'accuracy_size');
    
    % CD back to the data folder for next participant
    cd ../../../
    
    clearvars -except subjList n mvpa_accuracy cat_idx numTrials2Ave
    
end

%% Group analysis
% Average across participants
% Participant x Lvl Comparison x Feature x classifier x T.P.'s
for i=1:4
    for j=1:size(mvpa_accuracy,1)
        mvpa_acc_mat(j,i,1,:,:) = mvpa_accuracy(j,i+1,1).accuracy;
        mvpa_acc_mat(j,i,2,:,:) = mvpa_accuracy(j,i+1,2).accuracy;
    end
end

mvpa_acc_ave_ori = squeeze(mean(squeeze(mvpa_acc_mat(:,:,1,:,:)),1));
mvpa_acc_ste_ori = squeeze(ste(squeeze(mvpa_acc_mat(:,:,1,:,:)),1));

mvpa_acc_ave_size = squeeze(mean(squeeze(mvpa_acc_mat(:,:,2,:,:)),1));
mvpa_acc_ste_size = squeeze(ste(squeeze(mvpa_acc_mat(:,:,2,:,:)),1));

%% Save the group data
save(sprintf('%s%d%s','./Group_results_100msBL_NoReref/',numTrials2Ave,'a_MVPA_Ori_30HzLP_AllComparisons'),...
    'mvpa_acc_mat','mvpa_acc_ave_ori','mvpa_acc_ste_ori','mvpa_acc_ave_size','mvpa_acc_ste_size');

%% Plot data
fig_dims = [1 1 10.5 9];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off
lineWidth = 2;
fontSize = 12;
cat_idx = [1 2;1 3;1 4;1 5];
classi_label = {'LDA','Naive Bayes'};

% Orientation
for j=1:2   % Plot both classifiers
    thisFig = figure('Name','Average Orientation','Units','inches','Position',fig_dims);
    for i=1:4   % Draw results from all 4 classifications
        subplot(4,1,i)
        shadedErrorBar(1:700,mvpa_acc_ave_ori(i,j,:),mvpa_acc_ste_ori(i,j,:))
        hold on
        xAX = get(gca,'XAxis');   % Change font of x/y ticks
        set(xAX,'FontSize',10);
        yAX = get(gca,'YAxis');
        set(yAX,'FontSize',10);
        yline(50);  % Chance level
        xline(50,'-','LineWidth',4);   % Mark baseline
        title(sprintf('%s%s%d%s%d',classi_label{j},' Accuracy - Orientation: ',cat_idx(i,1),' vs ',cat_idx(i,2)),'FontSize',12);
        ylabel('Accuracy (%)','FontSize',12);
        ylim([30 70]);
        
        %Make background white
        set(gcf,'color','white')
        %Specify demensions of figure
        set(thisFig,'position',fig_dims)
        %Set figure thickness and border
        hold on
        set(gca,'linewidth',fig_size,'box',fig_box)
        
        % y-axis are levels being correlated
        set(gca,'TickLength',[0 0])
        
        thisFig.PaperPositionMode = 'auto';
        thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
    end
    
    % Save figures
    savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/',numTrials2Ave,'a_',classi_label{j},'_MVPA_Ori_30HzLP_AllComparisons.fig'));
    print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/',numTrials2Ave,'a_',classi_label{j},'_MVPA_Ori_30HzLP_AllComparisons.tif'),'-dtiffn');   % Save .tif
    
end

% Size
for j=1:2   % Plot both classifiers
    thisFig = figure('Name','Average Size','Units','inches','Position',fig_dims);
    for i=1:4   % Draw results from all 4 classifications
        subplot(4,1,i)
        shadedErrorBar(1:700,mvpa_acc_ave_size(i,j,:),mvpa_acc_ste_size(i,j,:))
        hold on
        xAX = get(gca,'XAxis');   % Change font of x/y ticks
        set(xAX,'FontSize',10);
        yAX = get(gca,'YAxis');
        set(yAX,'FontSize',10);
        yline(50);  % Chance level
        xline(50,'-','LineWidth',4);   % Mark baseline
        title(sprintf('%s%s%d%s%d',classi_label{j},' Accuracy - Size: ',cat_idx(i,1),' vs ',cat_idx(i,2)),'FontSize',12);
        ylabel('Accuracy (%)','FontSize',12);
        ylim([30 70]);
        
        %Make background white
        set(gcf,'color','white')
        %Specify demensions of figure
        set(thisFig,'position',fig_dims)
        %Set figure thickness and border
        hold on
        set(gca,'linewidth',fig_size,'box',fig_box)
        
        % y-axis are levels being correlated
        set(gca,'TickLength',[0 0])
        
        thisFig.PaperPositionMode = 'auto';
        thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
    end
    
    % Save figures
    savefig(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/',numTrials2Ave,'a_',classi_label{j},'_MVPA_Size_30HzLP_AllComparisons.fig'));
    print(thisFig,sprintf('%s%d%s%s%s','./Group_results_100msBL_NoReref/',numTrials2Ave,'a_',classi_label{j},'_MVPA_Size_30HzLP_AllComparisons.tif'),'-dtiffn');   % Save .tif
    
end


% Save group analysis
cd ./Group_Results/
% save(sprintf('%s%d%s','group_VEP_MVPA_Acc_',numTrials2Ave,'a_Ori'),'mvpa_acc_ave_ori','mvpa_acc_ste_ori');
% save(sprintf('%s%d%s','group_VEP_MVPA_Acc_',numTrials2Ave,'a_Size'),'mvpa_acc_ave_size','mvpa_acc_ste_size');
save(sprintf('%s%d%s','group_VEP_MVPA_Acc_',numTrials2Ave,'a_Ori_30HzLP'),'mvpa_acc_ave_ori','mvpa_acc_ste_ori');
save(sprintf('%s%d%s','group_VEP_MVPA_Acc_',numTrials2Ave,'a_Size_30HzLP'),'mvpa_acc_ave_size','mvpa_acc_ste_size');
cd ../


%% Make and save pretty figs for presentations
% fig_box = 'off'; %Figure border on/off
fig_dims = [500 500 2000 500];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

% Change directory
cd ./Figures/PrettyFigs/

% Orientation - LDA
thisFig = figure('Name',sprintf('%s%d%s%d','Average LDA Accuracy Orientation: ',cat_idx(1),' - ',cat_idx(2)));
shadedErrorBar(1:550,mvpa_acc_ave_ori(1,:),mvpa_acc_ste_ori(1,:))
hold on

titleProp = title(sprintf('%s%d%s%d','Average LDA Accuracy Orientation: ',cat_idx(1),' - ',cat_idx(2)),'FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Accuracy (Chance 50%)','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xline(50,'-','LineWidth',4);   % Mark baseline
yline(50);   % Mark chance
ylim([30 70]);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,'MVPA_Ori_LDA_1v5','-dpdf')


% Orientation - NB
thisFig = figure('Name',sprintf('%s%d%s%d','Average LDA Accuracy Orientation: ',cat_idx(1),' - ',cat_idx(2)));
shadedErrorBar(1:550,mvpa_acc_ave_ori(2,:),mvpa_acc_ste_ori(2,:))
hold on

titleProp = title(sprintf('%s%d%s%d','Average NB Accuracy Orientation: ',cat_idx(1),' - ',cat_idx(2)),'FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Accuracy (Chance 50%)','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xline(50,'-','LineWidth',4);   % Mark baseline
yline(50);   % Mark chance
ylim([30 70]);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,'MVPA_Ori_NB_1v5','-dpdf')


% Size - LDA
thisFig = figure('Name',sprintf('%s%d%s%d','Average LDA Accuracy Size: ',cat_idx(1),' - ',cat_idx(2)));
shadedErrorBar(1:550,mvpa_acc_ave_size(1,:),mvpa_acc_ste_size(1,:))
hold on

titleProp = title(sprintf('%s%d%s%d','Average LDA Accuracy Size: ',cat_idx(1),' - ',cat_idx(2)),'FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Accuracy (Chance 50%)','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xline(50,'-','LineWidth',4);   % Mark baseline
yline(50);   % Mark chance
ylim([30 70]);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,'MVPA_Size_LDA_1v5','-dpdf')


% Size - NB
thisFig = figure('Name',sprintf('%s%d%s%d','Average NB Accuracy Size: ',cat_idx(1),' - ',cat_idx(2)));
shadedErrorBar(1:550,mvpa_acc_ave_size(2,:),mvpa_acc_ste_size(2,:))
hold on

titleProp = title(sprintf('%s%d%s%d','Average NB Accuracy Size: ',cat_idx(1),' - ',cat_idx(2)),'FontSize',30,'Units','pixels');
xAX = get(gca,'XAxis');   % Change font of x/y ticks
set(xAX,'FontSize',25);
yAX = get(gca,'YAxis');
set(yAX,'FontSize',25);
ylabel('Accuracy (Chance 50%)','FontSize',30);
xlabel('Time (ms)','FontSize',30);
xline(50,'-','LineWidth',4);   % Mark baseline
yline(50);   % Mark chance
ylim([30 70]);

%Make background white
set(gcf,'color','white')
%Specify demensions of figure
set(thisFig,'position',fig_dims)
%Set figure thickness and border
hold on
set(gca,'linewidth',fig_size,'box',fig_box)

% y-axis are levels being correlated
set(gca,'TickLength',[0 0])

% Save image
thisFig.PaperPositionMode = 'auto';
thisFig.PaperSize = [thisFig.PaperPosition(3) thisFig.PaperPosition(4)];
print(thisFig,'MVPA_Size_NB_1v5','-dpdf')

cd ../../


