function [ensDataStruct] = ensLoadData(dataType,subjid,runid)

% File to keep track of participants and data file names for all
% dissertation experiments - 080818

if ~exist('runid','var')
    % runid is not passed in so default it to 1
    runid = 1;
end

%% Behavioral variables
datadirBehavioral = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/Behavioral/Data/';
% datadirBehavioral = '/Users/clab/Documents/CLAB/Kyle/Dissertation/Behavioral/Data/';

subjBehavioral = {'KK','MM','JB','TL','NH','TW','ZZ','CM','DP','ES','HA','VG','JV','MC','001','GF','OK','MH','BS','AH','KL','02','MG','06'};   % Subject ID list

expNameBehavioral = 'Ens_Behavioral';   % Name of the experiment

%% Frequency tagging variables
datadirFreqTag = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/';
% datadirFreqTag = '/Users/clab/Documents/CLAB/Kyle/Dissertation/EEG Freq Tag/Data/';

% subjFreqTag = {'KK','TW','ZZ'};
subjFreqTag = {'KK','ZZ','TL','TW','KE','CS','HA','TS','RM','DH','RR','KL','SH','CS2','JV','BS','GF','OK','MG','AC'};

expNameFreqTag = 'Ens_FFTOddball_DualStream';   % Name of the experiment

% EEG data files
eegFreqTagList = {'KK_Ens_FreqTag_1_20190209_123222','KK_Ens_FreqTag_2_20190209_013143';'ZZ_Ens_FreqTag_1_20190212_034119','ZZ_Ens_FreqTag_2_20190214_033556';...
    'TL_Ens_FreqTag_1_20190216_011141','TL_Ens_FreqTag_2_20190216_023354';'TW_Ens_FreqTag_1_20190212_021922','TW_Ens_FreqTag_2_20190219_023119';...
    'KE_Ens_FreqTag_1_20190217_012616','KE_Ens_FreqTag_2_20190219_035758';'CS_Ens_FreqTag_1_20190215_104955','CS_Ens_FreqTag_2_20190222_121758';...
    'HA_Ens_FreqTag_1_20190219_052036','HA_Ens_FreqTag_2_20190227_113211';'TS_Ens_FreqTag_1_20190222_104505','TS_Ens_FreqTag_2_20190226_124502';...
    'RM_Ens_FreqTag_1_20190227_021416','RM_Ens_FreqTag_2_20190228_115323';'DH_Ens_FreqTag_1_20190304_113308','DH_Ens_FreqTag_2_20190306_111109';...
    'RR_Ens_FreqTag_1_20190305_113558','RR_Ens_FreqTag_2_20190308_012911';'KL_Ens_FreqTag_1_20190222_020641','KL_Ens_FreqTag_2_20190301_034202';...
    'SH_Ens_FreqTag_1_20190401_064514','SH_Ens_FreqTag_2_20190402_041738';'CS2_Ens_FreqTag1_20190404_031720','CS2_Ens_FreqTag_2_20190407_121455';...
    'JV_Ens_FreqTag_1_20190403_022413','JV_Ens_FreqTag_2_20190404_044812';'BS_Ens_FreqTag_1_20190409_112315','BS_Ens_FreqTag_2_20190416_010827';...
    'GF_Ens_FreqTag_1_20190411_021135','GF_Ens_FreqTag_2_20190412_054243';'OK_Ens_FreqTag_1_20190409_032406','OK_Ens_FreqTag_2_20190415_105010';...
    'MG_Ens_FreqTag_1_20190410_095754','MG_Ens_FreqTag_2_20190412_094644';'AC_Ens_FreqTag_1_20190416_042437','AC_Ens_FreqTag_2_20190417_124047'};

%% VEP variables
datadirVEP = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG VEP/Data/';
% datadirFreqTag = '/Users/clab/Documents/CLAB/Kyle/Dissertation/EEG VEP/Data/';

subjVEP = {'KK','HA','KL','GF','MN','BS','AH','MH','02','06','08','05','03','10','TW','ES','GF','TL','DH'};   % Subject ID list

expNameVEP = 'Ens_VEP';   % Name of the experiment

% EEG data files
eegVEPList = {'KK_Ens_VEP_1_20180911_095811','KK_Ens_VEP_2_20180911_031719';'HA_Ens_VEP_1_20180914_022812','HA_Ens_VEP_2_20180917_103212';...
    'KL_Ens_VEP_1_20180913_114214','KL_Ens_VEP_2_20180917_053353';'GF_Ens_VEP_1_20180919_112712','GF_Ens_VEP_2_20180920_103905';...
    'MN_Ens_VEP_1_20180927_104433','MN_Ens_VEP_2_20180928_123523';'BS_Ens_VEP_1_20180925_104632','BS_Ens_VEP_2_20181002_113920';...
    'AH_Ens_VEP_1_20180919_124629','AH_Ens_VEP_2_20181003_044123';'MH_Ens_VEP_1_20180915_020058','MH_Ens_VEP_2_20180918_061555';...
    '02_Ens_VEP_1_20180919_015509','02-Ens_VEP_2_20181004_052156';'06_Ens_VEP_1_20181009_042818','06_Ens_VEP_2_20181010_050211';...
    '08_Ens_VEP_1_20181018_033833','08_Ens_VEP_2_20181023_022440';'05_Ens_VEP_1_20181011_033948','05_Ens_VEP_2_20181025_034012';...
    '04_Ens_VEP_1_20181009_102353','04_Ens_VEP_2_20181015_052042';'03_Ens_VEP_1_20181008_054325','03_Ens_VEP_2_20181011_114603';...
    '10_Ens_VEP_1_20181106_122554','10_Ens_VEP_2_20181108_102010';'TW_Ens_VEP_1_20181003_055026','TW_Ens_VEP_2_20181017_013532';...
    'ES_Ens_VEP_1_20181025_103601','ES_Ens_VEP_2_20181102_033703';'GF_Ens_VEP_1_20180919_112712','GF_Ens_VEP_2_20180920_103905';...
    'TL_Ens_VEP_1_20190416_024527','TL_Ens_VEP_2_20190417_041153';'DH_Ens_VEP_1_20190313_112206','DH_Ens_VEP_2_20190418_113250'};
% eegVEPList = {'KK_Ens_VEP_1_20180911_095811','KK_Ens_VEP_2_20180911_031719'; 'KL_Ens_VEP_1_20180913_114214','KL_Ens_VEP_1_20180913_114214';...
%     'HA_Ens_VEP_1_20180914_022812','HA_Ens_VEP_2_20180914_022812';'MH_Ens_VEP_1_20180915_020058','MH_Ens_VEP_1_20180915_020058'};

%% fMRI variables
subjfMRI = {'ZZ','AR','KK','GC','MC','MG','NS','TL','MH','JV'};

expNamefMRI = 'Ens_fMRIAdapt';   % Name of the experiment

datadirfMRI = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/MRI Adaptation/Data/';

if strcmp(dataType,'Behavioral') || strcmp(dataType,'LoadBehavioral')
    %% Behavioral
    
    if strcmp(dataType,'Behavioral')
        
        for i=1:length(subjBehavioral)
                datafileList(i) = {sprintf('%s%s%s%s',subjBehavioral{i},'_',expNameBehavioral,'_001')};
                datafileFullList(i) = {sprintf('%s%s%s%s',subjBehavioral{i},'_',expNameBehavioral,'_001_full')};
                
                % Load in the data
                rawdataBehavioral{i} = load(sprintf('%s',datadirBehavioral,datafileList{i}),'rawdata');
                
                stepListHolder = load(sprintf('%s',datadirBehavioral,datafileList{i}),'stepList');
                stepList{i}(:,:) = double(stepListHolder.stepList);
        end
        
        if strcmp(subjid,'All')
            % Create a struct with the data
            ensDataStruct.subjid = subjBehavioral;
            ensDataStruct.rawdata = rawdataBehavioral;
        else
            subjidIdx = find(contains(subjBehavioral,subjid));
            ensDataStruct.steplist = stepList{subjidIdx,:}(:,:);
            ensDataStruct.runid = runListBehavioral{subjidIdx};
            ensDataStruct.rawdata = rawdataBehavioral{subjidIdx};
        end
        
    elseif strcmp(dataType,'LoadBehavioral')
        
        % Create a struct with the data
        ensDataStruct.subjid = subjBehavioral;
        ensDataStruct.runid = runListBehavioral;
        %         ensDataStruct.stepList =
        
    end
    
    
elseif strcmp(dataType,'FreqTagBehav') || strcmp(dataType,'LoadFreqTag') ||  strcmp(dataType,'FreqTagEEG') || strcmp(dataType,'FreqTagBehavFake')
    %% Freq Tag
    if strcmp(dataType,'FreqTagBehav')   % For data analysis
        
        for i=1:length(subjFreqTag)
                datafileList1{i} = sprintf('%s%s%s%s',subjFreqTag{i},'_',expNameFreqTag,'_001');
                datafileList2{i} = sprintf('%s%s%s%s',subjFreqTag{i},'_',expNameFreqTag,'_002');
                
                % Load in both rawdata files from each run
                rawdataFreqTagBehav1{i} = load(sprintf('%s',datadirFreqTag,subjFreqTag{i},'/',datafileList1{i}),'rawdata');
                rawdataFreqTagBehav2{i} = load(sprintf('%s',datadirFreqTag,subjFreqTag{i},'/',datafileList2{i}),'rawdata');
                
                % Combine the two rawdata files into one
                rawdataFreqTagBehav{i} = [rawdataFreqTagBehav1{i}.rawdata; rawdataFreqTagBehav2{i}.rawdata];
        end
        
        if strcmp(subjid,'All')
            % Create a struct with the behavioral data and subj lists
            ensDataStruct.subjid = subjFreqTag;
            ensDataStruct.rawdata = rawdataFreqTagBehav;
        else
            subjidIdx = find(contains(subjFreqTag,subjid));
            ensDataStruct.runid = runListBehavioral{subjidIdx};
            ensDataStruct.rawdata = rawdataFreqTagBehav{subjidIdx};
        end
        
    elseif strcmp(dataType,'LoadFreqTag')   % For experiment params - just load in the run and the participants subjective step values
        
        % Load in behavioral step list for size and orientation
        stepList = load(sprintf('%s',datadirBehavioral,subjid,'_',expNameBehavioral,'_001'),'stepList');
        ensDataStruct.oriList = double(stepList.stepList(1,[1 2 3 4 5]));
        ensDataStruct.sizeList = double(stepList.stepList(2,[1 2 3 4 5]));
        ensDataStruct.sizeList([2,3,4,5]) = ensDataStruct.sizeList([2,3,4,5])-1;
        
        % For freq tagging, force a minimum distance between step sizes
        % 10 degrees for ori .1 DoVA for size?
        % Be sure not to add it to their existing values, and only up their
        % original values to the 'minimum'. 
        standardSizes = [0 .1 .2 .3 .4];
        standardOris = [0 10 20 30 40];
        for i=1:length(ensDataStruct.oriList)
            if ensDataStruct.oriList(i) < standardOris(i)
                ensDataStruct.oriList(i) = standardOris(i);
            else 
                ensDataStruct.oriList(i) = ensDataStruct.oriList(i);
            end
        end
        for i=1:length(ensDataStruct.sizeList)
            if ensDataStruct.sizeList(i) < standardSizes(i)
                ensDataStruct.sizeList(i) = standardSizes(i);
            else
                ensDataStruct.sizeList(i) = ensDataStruct.sizeList(i);
            end
        end
        
        % Determine the correct direction of attention based on what was
        % chosen last time
        if runid == 1   % If first run then randomly choose a direction of attention
            ensDataStruct.dirAttend = randi(2);   % 1=left 2=right
        elseif runid == 2   % If second run then load in the dirAttend from first run and use the opposite
            oldTaskBlockChose = load(sprintf('%s',datadirFreqTag,subjid,'_',expNameFreqTag,'_001'),'dirAttend');
            ensDataStruct.dirAttend = 3-oldTaskBlockChose.dirAttend;
        end
        
    elseif strcmp(dataType,'FreqTagEEG')
        
        % Find the participants EEG file names using the user input subjid
        charEEGFreqTagList = char(eegFreqTagList{:,1});
        if length(subjid)==2
            firstLetter = charEEGFreqTagList(:,1);
            secondLetter = charEEGFreqTagList(:,2);
            subjLocIdx(:,1) = subjid(1) == firstLetter;
            subjLocIdx(:,2) = subjid(2) == secondLetter;
            subjIdx = find(subjLocIdx(:,2)==1 & subjLocIdx(:,1)==1);
        elseif length(subjid)==3
            firstLetter = charEEGFreqTagList(:,1);
            secondLetter = charEEGFreqTagList(:,2);
            thirdLetter = charEEGFreqTagList(:,3);
            subjLocIdx(:,1) = subjid(1) == firstLetter;
            subjLocIdx(:,2) = subjid(2) == secondLetter;
            subjLocIdx(:,3) = subjid(3) == thirdLetter;
            subjIdx = find(subjLocIdx(:,3)==1 & subjLocIdx(:,2)==1 & subjLocIdx(:,1)==1);
        end
        
        
        % Load in the paths to the EEG rawdata files
        ensDataStruct.rawdataFreqTagEEGPath{1} = sprintf('%s%s%s',datadirFreqTag,subjid,'/',eegFreqTagList{subjIdx(1),1});
        ensDataStruct.rawdataFreqTagEEGPath{2} = sprintf('%s%s%s',datadirFreqTag,subjid,'/',eegFreqTagList{subjIdx(1),2});
        
        % Load in/format trial info from VEP behavioral file
        datafileList{1} = sprintf('%s%s%s%s',subjid,'_',expNameFreqTag,'_001');
        datafileList{2} = sprintf('%s%s%s%s',subjid,'_',expNameFreqTag,'_002');
        
        % Load in both rawdata files from each run
        rawdataFreqTagBehav{1} = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{1}),'rawdata','chosenStimRate');
        rawdataFreqTagBehav{2} = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{2}),'rawdata','chosenStimRate');
        rawdataFreqTagBehavFull = [rawdataFreqTagBehav{1}.rawdata; rawdataFreqTagBehav{2}.rawdata];
  
        % Create a numTrialsx1 array with labels for each condition (1-100),
        % where 1=ori1,size1,taskori,leftatt; 2=ori2,size1,taskori,leftatt; 3=ori3,size1,taskori,leftatt;...;
        % 24=ori4,size5,taskori,leftatt; 25=ori5,size5,taskori,leftatt; 26=ori1,size1,taskori,rightatt; 27=ori2,size1,taskori,rightatt;...;
        % 49=ori4,size5,taskori,rightatt; 50=ori5,size5,taskori,rightatt; 51=ori1,size1,tasksize,leftatt; 52=ori2,size1,tasksize,leftatt  - for use w/ fieldtrip functions
        counter = 1;
        for k=1:2   % Task 1=ori 2=size
            for m=1:2   % Attended hemifeild 1=left 2=right
                for j=1:5   % Size
                    for i=1:5   % Ori
                        info(rawdataFreqTagBehavFull(:,1)==i & rawdataFreqTagBehavFull(:,2)==j & rawdataFreqTagBehavFull(:,3)==k & rawdataFreqTagBehavFull(:,4)==m,1) = counter;
                        counter = counter+1;
                    end
                end
            end
        end
        
        % Create two other columns to segment the data collapsing across
        % the irrelevant feature (ori levels regardless of size or size
        % regardless of ori). 1=ori1, sizeAll, oriTask, leftAtt; 2=ori2, sizeAll,
        % oriTask, leftAtt; 6=ori1,sizeAll,oriTask,rightAtt;11=ori1,sizeAll,sizeTask,leftAtt
        counter = 1;
        for k=1:2 % Task
            for m=1:2   % Attended hemifeild 1=left 2=right
                for j=1:5 % Ori
                    info(rawdataFreqTagBehavFull(:,3)==k & rawdataFreqTagBehavFull(:,1)==j & rawdataFreqTagBehavFull(:,4)==m,2) = counter;
                    counter = counter+1;
                end
            end
        end
        % Same for size. 1=size1, oriAll, sizeTask; 2=size2, oriAll,
        % sizeTask
        counter = 1;
        for k=2:-1:1 % Task
            for m=1:2   % Attended hemifeild 1=left 2=right
                for j=1:5 % Size
                    info(rawdataFreqTagBehavFull(:,3)==k & rawdataFreqTagBehavFull(:,2)==j & rawdataFreqTagBehavFull(:,4)==m,3) = counter;
                    counter = counter+1;
                end
            end
        end
        
        ensDataStruct.info = info;
        
        % Add the frequency rates to the ensDataStruct for each trial
        % first column: 1=left faster rate; 2=right faster rate
        % second column - left side oddball rates: 1=ori faster oddball; 2=sizefaster oddball
        % third column - right side oddball rates: 1=ori faster; 2=size faster
        chosenStimRate{1} = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{1}),'chosenStimRate');
        chosenStimRate{2} = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{2}),'chosenStimRate');
        ensDataStruct.chosenStimRates = [chosenStimRate{1}.chosenStimRate;chosenStimRate{2}.chosenStimRate];
        
        % Include the stim rates as part of the info file so they are
        % included/removed during artifcat removal.
        ensDataStruct.info(:,4:6) = [chosenStimRate{1}.chosenStimRate;chosenStimRate{2}.chosenStimRate];
        
        % Add in the variable storying the two carrier frequencies as well as the oddballs for each
        stimRateBL = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{1},'_full'),'stim_rate_BL');
        stimRateOB = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{1},'_full'),'stim_rate_OB');
        ensDataStruct.stimRateBL = stimRateBL.stim_rate_BL;
        ensDataStruct.stimRateOB = stimRateOB.stim_rate_OB;
        
        
    elseif strcmp(dataType,'FreqTagBehavFake')
        
        subjidFake = {'KK','HA'};
        
        % Load in data for KK and HA
        for i=1:length(subjidFake)
            datafileList1{i} = sprintf('%s%s%s%s',subjidFake{i},'_',expNameFreqTag,'_001');
            datafileList2{i} = sprintf('%s%s%s%s',subjidFake{i},'_',expNameFreqTag,'_002');
            
            % Load in both rawdata files from each run
            rawdataFreqTagBehav1{i} = load(sprintf('%s',datadirFreqTag,subjidFake{i},'/',datafileList1{i}),'rawdata');
            rawdataFreqTagBehav2{i} = load(sprintf('%s',datadirFreqTag,subjidFake{i},'/',datafileList2{i}),'rawdata');
            
            % Combine the two rawdata files into one
            rawdataFreqTagBehav{i} = [rawdataFreqTagBehav1{i}.rawdata; rawdataFreqTagBehav2{i}.rawdata];
        end
        
        % Create a struct with the behavioral data subject lists
        ensDataStruct.subjid = subjidFake;
        ensDataStruct.rawdata = rawdataFreqTagBehav;
        
%     elseif strcmp(dataType,'FreqTagFake')
%         
%         % Just load in my data and Hectors data
%         % Create 2 rawdata files that have the info needed for
%         % segmentation.
%         ensDataStruct.rawdataFreqTagEEGPath{1} = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/FakeData_ENS_Vep_1/';
%         ensDataStruct.rawdataFreqTagEEGPath{2} = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/FakeData_ENS_Vep_2/';
%         
%         % Load in/format trial info from VEP behavioral file
%         datafileList{1} = sprintf('%s%s%s%s',subjid,'_',expNameFreqTag,'_001');
%         datafileList{2} = sprintf('%s%s%s%s',subjid,'_',expNameFreqTag,'_002');
%         
%         % Load in both rawdata files from each run
%         rawdataFreqTagBehav{1} = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{1}),'rawdata');
%         rawdataFreqTagBehav{2} = load(sprintf('%s',datadirFreqTag,subjid,'/',datafileList{2}),'rawdata');
%         
%         rawdataFreqTagBehavFull = [rawdataFreqTagBehav{1}.rawdata; rawdataFreqTagBehav{2}.rawdata];
        
    end
            
elseif strcmp(dataType,'VEPBehav') ||  strcmp(dataType,'VEPEEG') || strcmp(dataType,'LoadVEP') || strcmp(dataType,'VEPFake')
    %% VEP
    
    if strcmp(dataType,'VEPBehav')   % For data analysis
        
        for i=1:length(subjVEP)
            datafileList1{i} = sprintf('%s%s%s%s',subjVEP{i},'_',expNameVEP,'_001');
            datafileList2{i} = sprintf('%s%s%s%s',subjVEP{i},'_',expNameVEP,'_002');
            
            % Load in both rawdata files from each run
            rawdataVEPBehav1{i} = load(sprintf('%s',datadirVEP,subjVEP{i},'/',datafileList1{i}),'rawdata');
            rawdataVEPBehav2{i} = load(sprintf('%s',datadirVEP,subjVEP{i},'/',datafileList2{i}),'rawdata');
            
            % Combine the two rawdata files into one
            rawdataVEPBehav{i} = [rawdataVEPBehav1{i}.rawdata; rawdataVEPBehav2{i}.rawdata];
        end
        
        if strcmp(subjid,'All')
            % Create a struct with the behavioral data subject lists
            ensDataStruct.subjid = subjVEP;
            ensDataStruct.rawdata = rawdataVEPBehav;
        else   % Load an individuals EEG data
            subjidIdx = find(contains(subjVEP,subjid));
            ensDataStruct.rawdata = rawdataVEPBehav{subjidIdx};
        end
        
    elseif strcmp(dataType,'VEPEEG')
        
        % Find the participants EEG file names using the user input subjid
        charEEGVEPList = char(eegVEPList{:,1});
        subjLocIdx = subjid == charEEGVEPList(:,1:2);
        subjIdx = find(subjLocIdx(:,2)==1 & subjLocIdx(:,1)==1);
        
        % Load in the paths to the EEG rawdata files
        ensDataStruct.rawdataVEPEEGPath{1} = sprintf('%s%s%s',datadirVEP,subjid,'/',eegVEPList{subjIdx(1),1});
        ensDataStruct.rawdataVEPEEGPath{2} = sprintf('%s%s%s',datadirVEP,subjid,'/',eegVEPList{subjIdx(1),2});
        
        
        % Load in/format trial info from VEP behavioral file
        datafileList{1} = sprintf('%s%s%s%s',subjid,'_',expNameVEP,'_001');
        datafileList{2} = sprintf('%s%s%s%s',subjid,'_',expNameVEP,'_002');
        
        % Load in both rawdata files from each run
        rawdataVEPBehav{1} = load(sprintf('%s',datadirVEP,subjid,'/',datafileList{1}),'rawdata');
        rawdataVEPBehav{2} = load(sprintf('%s',datadirVEP,subjid,'/',datafileList{2}),'rawdata');
        
        rawdataVEPBehavFull = [rawdataVEPBehav{1}.rawdata; rawdataVEPBehav{2}.rawdata];
        
        % Create a numTrialx1 array with labels for each condition (1-25),
        % where 1=ori1,size1,taskori; 2=ori2,size1,taskori; 3=ori3,size1,taskori;...;
        % 24=ori4,size5,taskori; 25=ori5,size5,taskori; 26=ori1,size1,tasksize - for use w/ fieldtrip functions
        counter = 1;
        for k=1:2   % Task
            for j=1:5   % Size
                for i=1:5   % Ori
                    info(rawdataVEPBehavFull(:,1)==i & rawdataVEPBehavFull(:,2)==j & rawdataVEPBehavFull(:,3)==k,1) = counter;
                    counter = counter+1;
                end
            end
        end
                
        % Create two other columns to segment the data collapsing across
        % the irrelevant feature (ori levels regardless of size or size
        % regardless of ori). 1=ori1, sizeAll, oriTask; 2=ori2, sizeAll,
        % oriTask, etc.
        counter = 1;
        for k=1:2 % Task
            for j=1:5 % Ori
               info(rawdataVEPBehavFull(:,3)==k & rawdataVEPBehavFull(:,1)==j,2) = counter; 
               counter = counter+1;
            end
        end
        % Same for size. 1=size1, oriAll, sizeTask; 2=size2, oriAll,
        % sizeTask
        counter = 1;
        for k=2:-1:1 % Task
            for j=1:5 % Size
               info(rawdataVEPBehavFull(:,3)==k & rawdataVEPBehavFull(:,2)==j,3) = counter; 
               counter = counter+1;
            end
        end
        
        ensDataStruct.info = info;
        
    elseif strcmp(dataType,'LoadVEP')   % For experiment params - just load in the run and the participants subjective step values
        
        % Load in behavioral step list for size and orientation
        stepList = load(sprintf('%s',datadirBehavioral,subjid,'_',expNameBehavioral,'_001'),'stepList');
        ensDataStruct.oriList = double(stepList.stepList(1,[1 2 3 4 5]));
        ensDataStruct.sizeList = double(stepList.stepList(2,[1 2 3 4 5]));
        ensDataStruct.sizeList([2,3,4,5]) = ensDataStruct.sizeList([2,3,4,5])-1;
        
        % Determine the correct order of block (task) presentation based on
        % last run
        if runid == 1   % If first run then randomly choose the order of presentation
            ensDataStruct.taskBlockChose = randi(2);   % 1=left 2=right
        elseif runid == 2   % If second run then load in the dirAttend from first run and use the opposite
            oldRawdata = load(sprintf('%s',datadirVEP,subjid,'_',expNameVEP,'_001'),'rawdata');
            oldTaskBlockChose = oldRawdata(1,3);   % Whatever the first run started with, starte w/ the opposite block type (task)
            ensDataStruct.taskBlockChose = 3-oldTaskBlockChose;
        end
        
    elseif strcmp(dataType,'VEPBehavFake')
        
        subjidFake = {'KK','HA'};
        
        % Load in data for KK and HA
        for i=1:length(subjidFake)
            datafileList1{i} = sprintf('%s%s%s%s',subjidFake{i},'_',expNameVEP,'_001');
            datafileList2{i} = sprintf('%s%s%s%s',subjidFake{i},'_',expNameVEP,'_002');
            
            % Load in both rawdata files from each run
            rawdataVEPBehav1{i} = load(sprintf('%s',datadirVEP,subjidFake{i},'/',datafileList1{i}),'rawdata');
            rawdataVEPBehav2{i} = load(sprintf('%s',datadirVEP,subjidFake{i},'/',datafileList2{i}),'rawdata');
            
            % Combine the two rawdata files into one
            rawdataVEPBehav{i} = [rawdataVEPBehav1{i}.rawdata; rawdataVEPBehav2{i}.rawdata];
        end
        
        % Create a struct with the behavioral data subject lists
        ensDataStruct.subjid = subjidFake;
        ensDataStruct.rawdata = rawdataVEPBehav;
        
%     elseif strcmp(dataType,'VEPFake')
%         
%         % Just load in my data and Hectors data
%         % Create 2 rawdata files that have the info needed for
%         % segmentation.
%         ensDataStruct.rawdataVEPEEGPath{1} = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG VEP/Data/FakeData_ENS_Vep_1/';
%         ensDataStruct.rawdataVEPEEGPath{2} = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG VEP/Data/FakeData_ENS_Vep_2/';
%         
%         % Load in/format trial info from VEP behavioral file
%         datafileList{1} = sprintf('%s%s%s%s',subjid,'_',expNameVEP,'_001');
%         datafileList{2} = sprintf('%s%s%s%s',subjid,'_',expNameVEP,'_002');
%         
%         % Load in both rawdata files from each run
%         rawdataVEPBehav{1} = load(sprintf('%s',datadirVEP,subjid,'/',datafileList{1}),'rawdata');
%         rawdataVEPBehav{2} = load(sprintf('%s',datadirVEP,subjid,'/',datafileList{2}),'rawdata');
%         
%         rawdataVEPBehavFull = [rawdataVEPBehav{1}.rawdata; rawdataVEPBehav{2}.rawdata];
        
    end
    
    
    
elseif strcmp(dataType,'fMRI') || strcmp(dataType,'LoadfMRI')
    %% fMRI
    
    if strcmp(dataType,'fMRI')   % For data analysis
        for i=1:length(subjfMRI)
                datafileList{i} = sprintf('%s%s%s',subjfMRI{i},'_',expNamefMRI);
                
                % Load in both rawdata files from each run
                rawdatafMRIBehav{i} = load(sprintf('%s',datadirfMRI,subjfMRI{i},'/',datafileList{i}),'rawdata');
        end
        
        if strcmp(subjid,'All')
            % Create a struct with the data
            ensDataStruct.subjid = subjfMRI;
            ensDataStruct.rawdata = rawdatafMRIBehav;
        else
            subjidIdx = find(contains(subjfMRI,subjid));
            ensDataStruct.rawdata = rawdatafMRIBehav{subjidIdx};
        end
        
    elseif strcmp(dataType,'LoadfMRI')   % For experiment params - just load in the run and the participants subjective step values
        
        %         subjIdx = strcmp(subjFreqTag,subjid);   % Find index of participant to find runList
        
        % Load in behavioral step list for size and orientation
        stepList = load(sprintf('%s',datadirBehavioral,subjid,'_',expNameBehavioral,'_001'),'stepList');
        
        ensDataStruct.oriList = double(stepList.stepList(1,[1 3 4 5]));
        ensDataStruct.sizeList = double(stepList.stepList(2,[1 3 4 5]));
        ensDataStruct.sizeList([2,3,4]) = ensDataStruct.sizeList([2,3,4])-1;
        
    end
    
end
