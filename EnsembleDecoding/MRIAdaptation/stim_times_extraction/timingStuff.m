% Gets the time for the GLM for wmIPS

clear all;
close all;

subID = 'AW';
% pathOut = '/Users/C-Lab/Google Drive/Lab Projects/Marians Stuff/wmIPS/Experiment/Timing/';
%%pathOut = sprintf('/Volumes/imaginguser/MR_DATA/BerryhillLab/WMIPS/%s/scripts/stim_times/',subID);
%%pathIn = '/Users/C-Lab/Google Drive/Lab Projects/Marians Stuff/wmIPS/Experiment/data/';

% override for local processing on CoreB1 (by Ryan)
pathOut = ['../' subID '/scripts/stim_times/'];
pathIn = './Data/';

switch subID
    case 'GG'
        file_list = {'GG_wm_030414_001', 'GG_wm_030414_002', 'GG_wm_030414_003', 'GG_wm_030414_004', 'GG_wm_030414_005', 'GG_wm_030414_006', 'GG_wm_030414_007'};
    case 'KK'
        file_list = {'KK_wm_030414_001', 'KK_wm_030414_002', 'KK_wm_030414_003', 'KK_wm_030414_004', 'KK_wm_030414_005', 'KK_wm_030414_006', 'KK_wm_030414_007'};
    case 'CB'
        file_list = {'CDB_wm_031414_001','CDB_wm_031414_002','CDB_wm_031414_003','CDB_wm_031414_004','CDB_wm_031414_005','CDB_wm_031414_006','CDB_wm_031414_007'};
    case 'JV'
        file_list = {'JEV_wm_031414_001','JEV_wm_031414_002','JEV_wm_031414_003','JEV_wm_031414_004','JEV_wm_031414_005','JEV_wm_031414_006','JEV_wm_031414_007'};
    case 'GC'
        file_list = {'GPC_wm_031814_001','GPC_wm_031814_002','GPC_wm_031814_003','GPC_wm_031814_004','GPC_wm_031814_005','GPC_wm_031814_006','GPC_wm_031814_007'};
    case 'MG'
        file_list = {'MG2_wm_040214_001','MG2_wm_040214_002','MG2_wm_040214_003','MG2_wm_040214_004','MG2_wm_040214_005','MG2_wm_040214_006','MG2_wm_040214_007'};
    case 'NS'
        file_list = {'NS_wm_040414_001', 'NS_wm_040414_002', 'NS_wm_040414_003', 'NS_wm_040414_004', 'NS_wm_040414_005', 'NS_wm_040414_006', 'NS_wm_040414_007'};
    case 'KM'
        file_list = {'KM_wm_041114_001', 'KM_wm_041114_002', 'KM_wm_041114_003', 'KM_wm_041114_004', 'KM_wm_041114_005', 'KM_wm_041114_006', 'KM_wm_041114_007'};
    case 'LS'
        file_list = {'LS_wm_041114_001', 'LS_wm_041114_002', 'LS_wm_041114_003', 'LS_wm_041114_004', 'LS_wm_041114_005', 'LS_wm_041114_006', 'LS_wm_041114_007'};
    case 'AW'
        file_list = {'AW_wm_072214_001', 'AW_wm_072214_002', 'AW_wm_072214_003', 'AW_wm_072214_004', 'AW_wm_072214_005', 'AW_wm_072214_006', 'AW_wm_072214_007'};
    otherwise
        error('file_list for subID %s undefined',subID)
end
fprintf('== remaking stim_times files for %s...',subID)

for a = 1:length(file_list)
    load(sprintf('%s%s',pathIn,file_list{a}));
    % Get the times of each block in a run
    t1 = timing.block_cue_blank_stop - timing.run_start;
    t2 = timing.block_cue_start - timing.run_start;
    
    % Time of orientation left non passive
    oriLeft(a,1) = t1(and(and(strcmp(blocks.stimtype,'orientation'),blocks.task==2),blocks.mem_side==-1));
    % Time of orientation right non passive
    oriRight(a,1) = t1(and(and(strcmp(blocks.stimtype,'orientation'),blocks.task==2),blocks.mem_side==1));
    % Time of orientation both non passive
    oriBoth(a,1) = t1(and(and(strcmp(blocks.stimtype,'orientation'),blocks.task==2),blocks.mem_side==2));
    
    % Time of letters left non passive
    letLeft(a,1) = t1(and(and(strcmp(blocks.stimtype,'letters'),blocks.task==2),blocks.mem_side==-1));
    % Time of letters right non passive
    letRight(a,1) = t1(and(and(strcmp(blocks.stimtype,'letters'),blocks.task==2),blocks.mem_side==1));
    % Time of letters both non passive
    letBoth(a,1) = t1(and(and(strcmp(blocks.stimtype,'letters'),blocks.task==2),blocks.mem_side==2));
    
    % Times of passive letters
    letPassive(a,1) = t1(and(strcmp(blocks.stimtype,'letters'),blocks.task==1));
    % Times of passive orient
    oriPassive(a,1) = t1(and(strcmp(blocks.stimtype,'orientation'),blocks.task==1));
    
    % Times of cue onset for orientation left non passive
    oriLeftCue(a,1) = t2(and(and(strcmp(blocks.stimtype,'orientation'),blocks.task==2),blocks.mem_side==-1));
    % Times of cue onset for orientation right non passive
    oriRightCue(a,1) = t2(and(and(strcmp(blocks.stimtype,'orientation'),blocks.task==2),blocks.mem_side==1));
    % Times of cue onset for orientation both non passive
    oriBothCue(a,1) = t2(and(and(strcmp(blocks.stimtype,'orientation'),blocks.task==2),blocks.mem_side==2));
    
    % Times of cue onset for letters left non passive cue
    letLeftCue(a,1) = t2(and(and(strcmp(blocks.stimtype,'letters'),blocks.task==2),blocks.mem_side==-1));
    % Times of cue onset for letters right non passive cue
    letRightCue(a,1) = t2(and(and(strcmp(blocks.stimtype,'letters'),blocks.task==2),blocks.mem_side==1));
    % Times of cue onset for letters both non passive cue
    letBothCue(a,1) = t2(and(and(strcmp(blocks.stimtype,'letters'),blocks.task==2),blocks.mem_side==2));
    
    % Times of passive letters cue
    letPassiveCue(a,1) = t2(and(strcmp(blocks.stimtype,'letters'),blocks.task==1));
    % Times of passive orient cue
    oriPassiveCue(a,1) = t2(and(strcmp(blocks.stimtype,'orientation'),blocks.task==1));
end

    % Writing to the individual files for use with the glm functions
    fileID = fopen(sprintf('%s%s_ori_left.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriLeft);
    fclose(fileID);
    fileID = fopen(sprintf('%s%s_ori_right.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriRight);
    fclose(fileID);
    fileID = fopen(sprintf('%s%s_ori_both.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriBoth);
    fclose(fileID);
    
    fileID = fopen(sprintf('%s%s_let_left.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letLeft);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_let_right.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letRight);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_let_both.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letBoth);
    fopen(fileID);
    
    fileID = fopen(sprintf('%s%s_let_pass.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letPassive);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_ori_pass.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriPassive);
    fopen(fileID);
    
    fileID = fopen(sprintf('%s%s_let_left_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letLeftCue);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_let_right_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letRightCue);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_let_both_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letBothCue);
    fopen(fileID);
    
    fileID = fopen(sprintf('%s%s_ori_left_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriLeftCue);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_ori_right_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriRightCue);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_ori_both_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriBothCue);
    fopen(fileID);
    
    fileID = fopen(sprintf('%s%s_let_pass_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',letPassiveCue);
    fopen(fileID);
    fileID = fopen(sprintf('%s%s_ori_pass_cue.1D',pathOut,subID),'w');
    fprintf(fileID,'%f\n',oriPassiveCue);
    fopen(fileID);
    
    
    
    % write files that define each trial of each block (6 trials/block, 6 s/trial)
    dlmwrite(sprintf('%s%s_ori_left_TRIALS.1D',pathOut,subID),bsxfun(@plus,oriLeft,0:6:30),'delimiter','\t');
    dlmwrite(sprintf('%s%s_ori_right_TRIALS.1D',pathOut,subID),bsxfun(@plus,oriRight,0:6:30),'delimiter','\t');
    dlmwrite(sprintf('%s%s_ori_both_TRIALS.1D',pathOut,subID),bsxfun(@plus,oriBoth,0:6:30),'delimiter','\t');

    dlmwrite(sprintf('%s%s_let_left_TRIALS.1D',pathOut,subID),bsxfun(@plus,letLeft,0:6:30),'delimiter','\t');
    dlmwrite(sprintf('%s%s_let_right_TRIALS.1D',pathOut,subID),bsxfun(@plus,letRight,0:6:30),'delimiter','\t');
    dlmwrite(sprintf('%s%s_let_both_TRIALS.1D',pathOut,subID),bsxfun(@plus,letBoth,0:6:30),'delimiter','\t');

    dlmwrite(sprintf('%s%s_let_pass_TRIALS.1D',pathOut,subID),bsxfun(@plus,letPassive,0:6:30),'delimiter','\t');
    dlmwrite(sprintf('%s%s_ori_pass_TRIALS.1D',pathOut,subID),bsxfun(@plus,oriPassive,0:6:30),'delimiter','\t');
    
    fprintf('done!\n',subID)

    
    