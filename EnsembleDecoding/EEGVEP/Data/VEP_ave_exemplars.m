% Average trials in groups of 5 for cleaner MVPA analysis

function conditions = VEP_ave_exemplars(interp_comb,numTrials2Ave)

%% Segment into groups according to trial type

trials_ori1 = find(interp_comb.trialinfo(:,2)==1);   % Pull all trials for orientation 1, across all size lvls, orientation task
trials_ori2 = find(interp_comb.trialinfo(:,2)==2);
trials_ori3 = find(interp_comb.trialinfo(:,2)==3);
trials_ori4 = find(interp_comb.trialinfo(:,2)==4);
trials_ori5 = find(interp_comb.trialinfo(:,2)==5);

trials_size1 = find(interp_comb.trialinfo(:,3)==1);   % Pull all trials for size 1, across all orientation lvls, size task
trials_size2 = find(interp_comb.trialinfo(:,3)==2);
trials_size3 = find(interp_comb.trialinfo(:,3)==3);
trials_size4 = find(interp_comb.trialinfo(:,3)==4);
trials_size5 = find(interp_comb.trialinfo(:,3)==5);

% Find minimum number of trials
min_length_ori = min([length(trials_ori1),length(trials_ori2),length(trials_ori3),length(trials_ori4),length(trials_ori5)]);
min_length_size = min([length(trials_size1),length(trials_size2),length(trials_size3),length(trials_size4),length(trials_size5)]);

col_len_ori = floor(min_length_ori/numTrials2Ave)*numTrials2Ave;
col_len_size = floor(min_length_size/numTrials2Ave)*numTrials2Ave;

%% Seperate trials into groups of 2. May leave out 1 or 2 trials if there is
% odd number of trials. 
% Orientation
trial_samp_ori = 1:numTrials2Ave:col_len_ori;
for i = 1:floor(min_length_ori/numTrials2Ave)

    s_numTrials2Ave_ori1(i,1:numTrials2Ave) = interp_comb.trial(1,trials_ori1(trial_samp_ori(i):trial_samp_ori(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_ori2(i,1:numTrials2Ave) = interp_comb.trial(1,trials_ori2(trial_samp_ori(i):trial_samp_ori(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_ori3(i,1:numTrials2Ave) = interp_comb.trial(1,trials_ori3(trial_samp_ori(i):trial_samp_ori(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_ori4(i,1:numTrials2Ave) = interp_comb.trial(1,trials_ori4(trial_samp_ori(i):trial_samp_ori(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_ori5(i,1:numTrials2Ave) = interp_comb.trial(1,trials_ori5(trial_samp_ori(i):trial_samp_ori(i)+(numTrials2Ave-1),1));
    
end
% Average across groups of 5. 
for i = 1:size(s_numTrials2Ave_ori1,1)
    av_ori1(1,i) = {mean(cat(3,s_numTrials2Ave_ori1{i,:}),3)};
    av_ori2(1,i) = {mean(cat(3,s_numTrials2Ave_ori2{i,:}),3)};
    av_ori3(1,i) = {mean(cat(3,s_numTrials2Ave_ori3{i,:}),3)};
    av_ori4(1,i) = {mean(cat(3,s_numTrials2Ave_ori4{i,:}),3)};
    av_ori5(1,i) = {mean(cat(3,s_numTrials2Ave_ori5{i,:}),3)};
end

% Size
trial_samp_size = 1:numTrials2Ave:col_len_size;
for i = 1:floor(min_length_size/numTrials2Ave)

    s_numTrials2Ave_size1(i,1:numTrials2Ave) = interp_comb.trial(1,trials_size1(trial_samp_size(i):trial_samp_size(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_size2(i,1:numTrials2Ave) = interp_comb.trial(1,trials_size2(trial_samp_size(i):trial_samp_size(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_size3(i,1:numTrials2Ave) = interp_comb.trial(1,trials_size3(trial_samp_size(i):trial_samp_size(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_size4(i,1:numTrials2Ave) = interp_comb.trial(1,trials_size4(trial_samp_size(i):trial_samp_size(i)+(numTrials2Ave-1),1));
    s_numTrials2Ave_size5(i,1:numTrials2Ave) = interp_comb.trial(1,trials_size5(trial_samp_size(i):trial_samp_size(i)+(numTrials2Ave-1),1));
    
end
% Average across groups of 5. 
for i = 1:size(s_numTrials2Ave_size1,1)
    av_size1(1,i) = {mean(cat(3,s_numTrials2Ave_size1{i,:}),3)};
    av_size2(1,i) = {mean(cat(3,s_numTrials2Ave_size2{i,:}),3)};
    av_size3(1,i) = {mean(cat(3,s_numTrials2Ave_size3{i,:}),3)};
    av_size4(1,i) = {mean(cat(3,s_numTrials2Ave_size4{i,:}),3)};
    av_size5(1,i) = {mean(cat(3,s_numTrials2Ave_size5{i,:}),3)};
end

%% Remake the interp file to use w/ MVPA
% Orientation
interpOri = interp_comb;

% Create a data file by removing all trials except the number of averaged trials
for i = floor(min_length_ori/numTrials2Ave)+1:length(interp_comb.trial)   
     bad_seg_all_ori(i,1) = interp_comb.sampleinfo((i))+1;
     bad_seg_all_ori(i,2) = bad_seg_all_ori(i,1)+250; 
end
% Clear out the remaining trials so you can then set them to the averaged values (should be same length as av_ori1)
bad_seg_all_ori(1:length(av_ori1),:) = [];   

% Macgyver the ft_rejectartifact function to reject all the excess trials
% in the interp file
% Remember that the trialinfo in the data file is not accurate
cfg_ori.artfctdef.eog.artifact = bad_seg_all_ori;
interpOri = ft_rejectartifact(cfg_ori, interpOri);

conditions.ori1 = interpOri;
conditions.ori2 = interpOri;
conditions.ori3 = interpOri;
conditions.ori4 = interpOri;
conditions.ori5 = interpOri;

conditions.ori1.trial = av_ori1;
conditions.ori2.trial = av_ori2;
conditions.ori3.trial = av_ori3;
conditions.ori4.trial = av_ori4;
conditions.ori5.trial = av_ori5;


% Size
interpSize = interp_comb;

% Create a data file by removing all trials except the number of averaged trials
for i = floor(min_length_size/numTrials2Ave)+1:length(interp_comb.trial)   
     bad_seg_all_size(i,1) = interp_comb.sampleinfo((i))+1;
     bad_seg_all_size(i,2) = bad_seg_all_size(i,1)+250; 
end
% Clear out the remaining trials so you can then set them to the averaged values (should be same length as av_ori1)
bad_seg_all_size(1:length(av_size1),:) = [];   

% Macgyver the ft_rejectartifact function to reject all the excess trials
% in the interp file
cfg_size.artfctdef.eog.artifact = bad_seg_all_size;
interpSize = ft_rejectartifact(cfg_size, interpSize);

conditions.size1 = interpSize;
conditions.size2 = interpSize;
conditions.size3 = interpSize;
conditions.size4 = interpSize;
conditions.size5 = interpSize;

conditions.size1.trial = av_size1;
conditions.size2.trial = av_size2;
conditions.size3.trial = av_size3;
conditions.size4.trial = av_size4;
conditions.size5.trial = av_size5;




end


