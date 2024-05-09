% Script for segmenting into conditions and performing the FFT analysis for the oddball frequencies -
% 022019

clear all;
close all;

fakeData=0;
plotData=0;

% Select electrodes to display
elecSelect(1) = 137;   % Ceneter parietal
elecSelect(2) = 90;   % Occ
elecSelect(3) = 21;   % Frontal

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Ori','Size'};
cats.attend = {'Left','Right'};

% Load in behavioral subject data
if fakeData == 0
    cd ../../
    ensDataStructBehav = ensLoadData_LabComp2('FreqTagBehav','All');
    cd ./'EEG Freq Tag'/Data/
    
    subjList = ensDataStructBehav.subjid;
elseif fakeData == 1
    % Make subject list equal to FakeData
    cd ../../
    ensDataStructBehav = ensLoadData('FreqTagBehavFake');
    cd ./'EEG Freq Tag'/Data/
    
    subjList = ensDataStructBehav.subjid;
end

elecGroupList = {'Occipital','Parietal','Frontal'};

% Electrode groups
elecArray{1} = [102 91 256 251 247 243 246 250 255 82 92 103 93 73 254 249 245 242 241 244 248 252 253 67 61]; %25  cheek_left
elecArray{2} = [32 37 46 54 47 38 33 27 34 39 48 40 35 28 22 29 36 23]; %18   anterior_left
elecArray{3} = [ 68 55 62 69 74 83 94 84 75 70 63 56 49 57 64 71 76 77 72 65 58 50 41 30 42 51 59 66 78 89 79 60 52 43 24 16 17 44 ...
    53 80 45 9]; %42   center_left
elecArray{4} = [142 129 128 141 153 162 152 140 127 139 151 161 171 170 160 150 138 149 159 169 178 177 168 158 148 157 167 176 ...
    189 188 175 166 156 165 174 187 199]; %37   posterior_left
elecArray{5} = [31 26 21 15 8 81 90 101 119 126 137 147]; %13   midline
elecArray{6} = [208 216 229 233 237 240 236 232 228 217 209 200 201 218 227 231 235 239 238 234 230 226 225 219 220]; %25   cheek_right
elecArray{7} = [25 18 10 1 2 11 19 20 12 3 222 223 4 13 14 5 224 6]; %18   anterior_right
elecArray{8} = [210 221 211 202 192 191 190 179 180 193 203 212 213 204 194 181 172 163 173 182 195 205 214 215 206 196 183 164 ...
    154 130 143 155 184 197 207 7 195 185 144 131 132 186]; %42   center_right
elecArray{9} = [88 100 110 99 87 86 98 109 118 117 106 97 85 96 107 116 125 124 115 106 95 105 114 123 136 135 122 113 104 ...
    112 121 134 146 145 133 120 111]; %37   posterior_right

labels = {'cheek l','anterior l','center l', 'posterior l','midline','cheek r','anterior r','center r','posterior r'};

% Determine where to plot the x axis labels based on the size of each sub
% group.
runningSum(1) = 0;
for i=2:length(labels)+1
    runningSum(i) = runningSum(i-1)+length(elecArray{i-1});
    place2plot(i-1) = floor(runningSum(i) - ((runningSum(i) - runningSum(i-1))/2));   % Where along the x axis should the label be
end

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

stimRateConvert = round(stimRate/0.05);

%% Segment/Trial Average/Index
for n=10:length(subjList)
    % for n=9
    %% Load/prep the data
    fprintf('%s%d\n','Subj: ',n)
    fprintf('%s\n','Loading and preping...')
    
    % Data directory
    if fakeData==1
        dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP');
    elseif fakeData==0
        dataDir = sprintf('%s%s%s%s',subjList{n},'/',subjList{n},'_results_60HzLP');
    end
    
    % Load in both runs of preprocessed data
    cd(dataDir)   % CD into the participant results folder to grab the preproc data
    
    % Load in everything but the trials
    % Clear out interp files for next load
    clear interp
    load(sprintf('%s%s',subjList{n},'_Ens_FreqTag_Prep_1'),'interp')   % Load
    combInterp{1} = interp;
    
    % Clear out cfg and interp files for next load
    clear interp
    load(sprintf('%s%s',subjList{n},'_Ens_FreqTag_Prep_2'),'interp')   % Load
    combInterp{2} = interp;
    
    % Load in the trials
    for j=1:2   % For both runs
        
        cd(sprintf('%s%s%s%d','./',subjList{n},'_Ens_FreqTag_Prep_',j))
        fileList = dir('*.mat');   % How many trial files are in the folder
        for i=1:length(fileList)
            load(sprintf('%s%d%s%d','Run_',j,'_Trial_',i));
            combInterp{j}.trial{i} = eval(sprintf('%s%d%s%d','Run_',j,'_Trial_',i));
            clear(sprintf('%s%d%s%d','Run_',j,'_Trial_',i))
        end
        cd ../   % CD back into pariticipant folder
        
        clear interp fileList
    end
    
    % Now combine the subfeilds of the two files (don't need to combine
    % everything in interp.cfg)
    interp.trial = [combInterp{1}.trial combInterp{2}.trial];
    interp.time = [combInterp{1}.time combInterp{2}.time];
    interp.trialinfo = [combInterp{1}.trialinfo; combInterp{2}.trialinfo];
    interp.sampleinfo = [combInterp{1}.sampleinfo; combInterp{2}.sampleinfo];
    interp.info = [combInterp{1}.info; combInterp{2}.info];
    interp.fsample = combInterp{1}.fsample;
    interp.label = combInterp{1}.label;
    interp.hdr.nChans = combInterp{1}.hdr.nChans;
    interp.hdr.label = combInterp{1}.hdr.label;
    interp.hdr.Fs = combInterp{1}.hdr.Fs;
    interp.hdr.nSample = [combInterp{1}.hdr.nSamples combInterp{2}.hdr.nSamples];
    interp.hdr.nSamplePre = [combInterp{1}.hdr.nSamplesPre combInterp{2}.hdr.nSamplesPre];
    interp.hdr.nTrials = [combInterp{1}.hdr.nTrials combInterp{2}.hdr.nTrials];
    
    cd ../   % CD back into data folder
    
    % Clear out the loading variables
    clear combInterp
    
    % NOT USING CFG HERE FOR FFT
    % Clean up the cfg/interp structure a bit to avoid warnings in output
    %     cfg.preproc.reref = cfg.reref;
    %     cfg.preproc.refchannel = cfg.refchannel;
    %     cfg.preproc.bpfilter = cfg.bpfilter;
    %     cfg.preproc.bpfreq = cfg.bpfreq;
    %     cfg = rmfield(cfg,{'reref','refchannel','bpfilter','bpfreq'});
    %     cfg = rmfield(cfg,{'bpfilter','bpfreq'});
    %     interp = rmfield(interp,'info');
    
    
    %% Segment and take the FFT
    fprintf('%s\n','Segmenting...')
    
    % Clear out variables
    clear newTrialInfo newTrial trialSegAtt trialSegUnAtt trialFFTAtt trialFFTUnAtt trialTags
    
    %% First lets make a more intuitive trial info array
    % newTrialInfo(1) = task (1=ori 2=size)
    % newTrialInfo(2) = attended hemifield (1=left 2=right)
    % newTrialInfo(3) = level (1-5)
    % newTrialInfo(4) = Attended carrier frequency (1=3,2=5)
    % newTrialInfo(5) = Attended OB frequency (1=.6,2=.75,3=.8,4=2)
    for i=1:length(interp.trialinfo)
        % Task
        if interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=10  % ori task
            newTrialInfo(i,1) = 1;
            
            % Attended hemifield
            if (interp.trialinfo(i,2)>=1 && interp.trialinfo(i,2)<=5)  % Att left
                newTrialInfo(i,2) = 1;
                
                % Carrier frequency
                if interp.trialinfo(i,4)==1   % If att left and 3Hz right
                    newTrialInfo(i,4) = 2;   % 5 hz attended
                    
                    % Oddball frequency attended
                    if interp.trialinfo(i,5)==1   % Ori faster OB rate
                        newTrialInfo(i,5) = 4;   % Faster 5Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Ori slower OB rate
                        newTrialInfo(i,5) = 3;   % Slower 5Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,6)==1   % Ori faster OB rate
                        newTrialInfo(i,6) = 2;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Ori slower OB rate
                        newTrialInfo(i,6) = 1;   % Slower 3Hz OB rate
                    end
                    
                elseif interp.trialinfo(i,4)==2   % If att left and 3Hz left
                    newTrialInfo(i,4) = 1;   % 3 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,5)==1   % Ori faster OB rate
                        newTrialInfo(i,5) = 2;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Ori slower OB rate
                        newTrialInfo(i,5) = 1;   % Slower 3Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,6)==1   % Ori faster OB rate
                        newTrialInfo(i,6) = 4;   % Faster 5Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Ori slower OB rate
                        newTrialInfo(i,6) = 3;   % Slower 5Hz OB rate
                    end
                    
                end
                
            elseif (interp.trialinfo(i,2)>=6 && interp.trialinfo(i,2)<=10)  % Att right
                newTrialInfo(i,2) = 2;
                
                % Carrier frequency
                if interp.trialinfo(i,4)==1   % If att right and 3Hz right
                    newTrialInfo(i,4) = 1;   % 3 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,6)==1   % Ori faster OB rate
                        newTrialInfo(i,5) = 2;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Ori slower OB rate
                        newTrialInfo(i,5) = 1;   % Slower 3Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,5)==1   % Ori faster OB rate
                        newTrialInfo(i,6) = 4;   % Faster 5Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Ori slower OB rate
                        newTrialInfo(i,6) = 3;   % Slower 5Hz OB rate
                    end
                    
                elseif interp.trialinfo(i,4)==2  % If att right and 3 Hz left
                    newTrialInfo(i,4) = 2;   % 5 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,6)==1   % Ori faster OB rate
                        newTrialInfo(i,5) = 4;   % Faster 5Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Ori slower OB rate
                        newTrialInfo(i,5) = 3;   % Slower 5Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,5)==1   % Ori faster OB rate
                        newTrialInfo(i,6) = 2;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Ori slower OB rate
                        newTrialInfo(i,6) = 1;   % Slower 3Hz OB rate
                    end
                    
                end
                
            end
            
            % Level
            if mod(interp.trialinfo(i,2),5) ~= 0
                newTrialInfo(i,3) = mod(interp.trialinfo(i,2),5);
            elseif mod(interp.trialinfo(i,2),5) == 0
                newTrialInfo(i,3) = 5;
            end
            
        elseif interp.trialinfo(i,3)>=1 && interp.trialinfo(i,3)<=10   % size task
            newTrialInfo(i,1) = 2;
            
            % Attended hemifield
            if (interp.trialinfo(i,3)>=1 && interp.trialinfo(i,3)<=5)  % Att left
                newTrialInfo(i,2) = 1;
                
                % Carrier frequency
                if interp.trialinfo(i,4)==1   % If att left and 3Hz right
                    newTrialInfo(i,4) = 2;   % 5 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,5)==1   % Size slower OB rate
                        newTrialInfo(i,5) = 3;   % Slower 5Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Size faster OB rate
                        newTrialInfo(i,5) = 4;   % Faster 5Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,6)==1   % Size slower OB rate
                        newTrialInfo(i,6) = 1;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Ori faster OB rate
                        newTrialInfo(i,6) = 2;   % Slower 3Hz OB rate
                    end
                    
                elseif interp.trialinfo(i,4)==2   % If att left and 3Hz left
                    newTrialInfo(i,4) = 1;   % 3 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,5)==1   % Size slower OB rate
                        newTrialInfo(i,5) = 1;   % Slower 5Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Size faster OB rate
                        newTrialInfo(i,5) = 2;   % Faster 5Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,5)==1   % Size slower OB rate
                        newTrialInfo(i,6) = 3;   % Faster 5Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Size faster OB rate
                        newTrialInfo(i,6) = 4;   % Slower 5Hz OB rate
                    end
                    
                end
                
            elseif (interp.trialinfo(i,3)>=6 && interp.trialinfo(i,3)<=10)  % Att right
                newTrialInfo(i,2) = 2;
                
                % Carrier frequency
                if interp.trialinfo(i,4)==1   % If att right and 3Hz right
                    newTrialInfo(i,4) = 1;   % 3 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,6)==1   % Size slower OB rate
                        newTrialInfo(i,5) = 1;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Size faster OB rate
                        newTrialInfo(i,5) = 2;   % Slower 3Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,5)==1   % Size slower OB rate
                        newTrialInfo(i,6) = 3;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,5)==2   % Ori faster OB rate
                        newTrialInfo(i,6) = 4;   % Slower 3Hz OB rate
                    end
                    
                elseif interp.trialinfo(i,4)==2  % If att right and 3 Hz left
                    newTrialInfo(i,4) = 2;   % 5 hz attended
                    
                    % Oddball frequency
                    if interp.trialinfo(i,6)==1   % Size slower OB rate
                        newTrialInfo(i,5) = 3;   % Faster 5Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Size faster OB rate
                        newTrialInfo(i,5) = 4;   % Slower 5Hz OB rate
                    end
                    
                    % Oddball frequency unattended (if the attended side is
                    % 3 Hz here, then the unattended is 5 Hz)
                    % What is the frequency of the ori change in the
                    % unattended hemifeild?
                    if interp.trialinfo(i,6)==1   % Size slower OB rate
                        newTrialInfo(i,6) = 1;   % Faster 3Hz OB rate
                    elseif interp.trialinfo(i,6)==2   % Ori faster OB rate
                        newTrialInfo(i,6) = 2;   % Slower 3Hz OB rate
                    end
                    
                end
                
            end
            
            % Level
            if mod(interp.trialinfo(i,2),5) ~= 0
                newTrialInfo(i,3) = mod(interp.trialinfo(i,2),5);
            elseif mod(interp.trialinfo(i,2),5) == 0
                newTrialInfo(i,3) = 5;
            end
            
        end
    end
    
    % Convert interp.trial from a cell array to a matrix
    newTrial = zeros(length(interp.trial),256,20000);
    for i=1:length(interp.trial)
        newTrial(i,:,:) = interp.trial{i}(1:256,:);
    end
    
    %% Group trials and do FFT
    % Segment into 40 groups per task, for each of the oddball freqs (4) by attended
    % hemifeild (2) by level (5). Grab the attended trials (.6 Hz left att) and
    % the unattended trials (.6 Hz left unatt, so 5Hz right att trials).
    % newTrialInfo(1) = task (1=ori 2=size)
    % newTrialInfo(2) = attended hemifield (1=left 2=right)
    % newTrialInfo(3) = level (1-5)
    % newTrialInfo(4) = Attended carrier frequency (1=3,2=5)
    % newTrialInfo(5) = Attended OB frequency (1=.6,2=.75,3=.8,4=2)
    stimRateConvertArray = [stimRateConvert(2,1) stimRateConvert(2,2) stimRateConvert(3,1) stimRateConvert(3,2)];
    dispCounter = 0;
    trialSegAtt = cell(2,2,5,4);
    trialSegUnAtt = cell(2,2,5,4);
    trialFFTAtt = zeros(2,2,5,4,256,750);
    trialFFTUnAtt = zeros(2,2,5,4,256,750);
    trialTags = zeros(2,2,5,4,256,2,3);
    
    % trialFFTAtt(1) = task
    % trialFFTAtt(2) = att hemifield
    % trialFFTAtt(3) = Level
    % trialFFTAtt(4) = OB Frequency
    % trialFFTAtt(5) = electrode
    % trialFFTAtt(6) = frequency bin
    for i=1:2   % Task
        for j=1:2   % Attended hemifield
            
            dispCounter = dispCounter+1;
            fprintf('%s%d%s\n','Performing FFT ',dispCounter,'...')
            
            for k=1:5   % Level
                for l=1:4   % OB Frequency
                    % Segment
                    % (When testing for bugs, remember that for the
                    % attended trials the last two columns (which
                    % correspond to the frequency of the attended OB (5th
                    % column) and unattended OB (6th  column) and should be
                    % opposite (when attended is 3 or 4 (5Hz) unattended
                    % should be either 1 or 2) and the tag of interest,
                    % either attended or unattended should be the same
                    % value for all trials wheres the other tag can vary
                    % between the other two attended OB frequencies.
                    % Attended
                    trialSegAtt{i,j,k,l}(:,:,:) = newTrial((newTrialInfo(:,1)==i & newTrialInfo(:,2)==j & newTrialInfo(:,3)==k & newTrialInfo(:,5)==l),:,:);
                    % Unattended
                    trialSegUnAtt{i,j,k,l}(:,:,:) = newTrial((newTrialInfo(:,1)==i & newTrialInfo(:,2)==j & newTrialInfo(:,3)==k & newTrialInfo(:,6)==l),:,:);
                    
                    % Average togethere
                    trialAveAtt = squeeze(nanmean(trialSegAtt{i,j,k,l},1));
                    trialAveUnAtt = squeeze(nanmean(trialSegUnAtt{i,j,k,l},1));
                    
                    % Do the FFT
                    for o=1:256   % For every electrode
                        trialFFTAttHolder(o,:) = squeeze(abs(fft(trialAveAtt(o,:))));
                        trialFFTUnAttHolder(o,:) = abs(fft(trialAveUnAtt(o,:)));
                        
                        % Take the FFT but preserve phase (for tcirc and
                        % other analysis)
                        trialFFTAttWPhaseHolder(o,:) = squeeze(fft(trialAveAtt(o,:)));
                        trialFFTUnAttWPhaseHolder(o,:) = fft(trialAveUnAtt(o,:));
                    end
                    
                    trialFFTAtt(i,j,k,l,:,1:750) = trialFFTAttHolder(:,1:750);
                    trialFFTUnAtt(i,j,k,l,:,1:750) = trialFFTUnAttHolder(:,1:750);
                    
                    trialFFTAttWPhase(i,j,k,l,:,1:750) = trialFFTAttWPhaseHolder(:,1:750);
                    trialFFTUnAttWPhase(i,j,k,l,:,1:750) = trialFFTUnAttWPhaseHolder(:,1:750);
                    
                    % Pick of the frequency tags you want
                    trialTags(i,j,k,l,:,1,1) = trialFFTAtt(i,j,k,l,:,stimRateConvertArray(l)+1);   % Attended (first harmonic)
                    trialTags(i,j,k,l,:,2,1) = trialFFTUnAtt(i,(3-j),k,l,:,stimRateConvertArray(l)+1);   % Unattended
                    
                    trialTags(i,j,k,l,:,1,2) = trialFFTAtt(i,j,k,l,:,(stimRateConvertArray(l)*2)+1);   % Attended (second harmonic)
                    trialTags(i,j,k,l,:,2,2) = trialFFTUnAtt(i,(3-j),k,l,:,(stimRateConvertArray(l)*2)+1);   % Unattended
                    
                    trialTags(i,j,k,l,:,1,1) = trialFFTAtt(i,j,k,l,:,(stimRateConvertArray(l)*3)+1);   % Attended (third harmonic)
                    trialTags(i,j,k,l,:,2) = trialFFTUnAtt(i,(3-j),k,l,:,(stimRateConvertArray(l)*3)+1);   % Unattended
                    
                    clear trialAveAtt trialAveUnAtt trialFFTAttHolder trialFFTUnAttHolder
                end
            end
        end
    end
     
    
    %% Sort and save
    fprintf('%s\n','Sorting and saving...')
    
    % Save each participants data
    cd(sprintf('%s%s%s','./',subjList{n},'_results_60HzLP/'))   % Move into the participants data folder
    
    save(sprintf('%s','FFT_Results_Oddball'),'trialFFTAtt','trialFFTUnAtt','trialFFTAttWPhase','trialFFTUnAttWPhase','trialTags');
    
    % Save each group seperately since they are too big to save together
    tcircDir = 'tCircData_Oddball';
    if exist(tcircDir,'file')
    else
        mkdir(tcircDir);
    end
    cd(sprintf('%s','./',tcircDir))
    
    for i=1:size(trialSegAtt,1)
        for j=1:size(trialSegAtt,2)
            for k=1:size(trialSegAtt,3)
                for l=1:size(trialSegAtt,4)
                    trialSegAttComp(:,:,:) = trialSegAtt{i,j,k,l}(:,:,:);
                    trialSegUnAttComp(:,:,:) = trialSegUnAtt{i,j,k,l}(:,:,:);
                    
                    trialSegAtt{i,j,k,l} = [];
                    trialSegUnAtt{i,j,k,l} = [];
                    
                    save(sprintf('%s%d%s%d%s%d%s%d','tcir_Seg_Att_',i,'_',j,'_',k,'_',l),'trialSegAttComp','trialSegUnAttComp');
                    
                    clear trialSegAttComp trialSegUnAttComp
                end
            end
        end
    end
    
    % x-axis for 200000 time points converted into frequency scale for
    % visualization
    freq_axis = 0:1/20:1000-1/20;
    
    if plotData == 1
        stimRateOB = [.6 .75 .8 2];
        
        % Orientation
        for i=1:4   % .6, .75, .8, and 2 Hz OB freqs
            figure()
            suptitle(sprintf('%d%s%s',stimRateOB(i),' Tag Orientation Subj: ',subjList{n}))
            counter = 0;
            for j=1:5
                for l=1:2
                    for k=1:length(elecSelect(1))   % Just plot one for now
                        % Attended
                        counter = counter+2;
                        subplot(5,4,counter-1);
                        stem(freq_axis(1:size(trialFFTAtt,6)),squeeze(trialFFTAtt(1,l,j,i,elecSelect(k),:))')
                        hold on
                        stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                            squeeze(trialFFTAtt(1,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
                        ylim([0 25000])
                        % Unattended
                        subplot(5,4,counter);
                        stem(freq_axis(1:size(trialFFTUnAtt,6)),squeeze(trialFFTUnAtt(1,l,j,i,elecSelect(k),:))')
                        hold on
                        stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                            squeeze(trialFFTUnAtt(1,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
                        ylim([0 25000])
                    end
                end
            end
        end
        
        % Size
        for i=1:4   % .6, .75, .8, and 2 Hz OB freqs
            figure()
            suptitle(sprintf('%d%s%s',stimRateOB(i),' Tag Size Subj: ',subjList{n}))
            counter = 0;
            for j=1:5
                for l=1:2
                    for k=1:length(elecSelect(1))   % Just plot one for now
                        % Attended
                        counter = counter+2;
                        subplot(5,4,counter-1);
                        stem(freq_axis(1:size(trialFFTAtt,6)),squeeze(trialFFTAtt(2,l,j,i,elecSelect(k),:))')
                        hold on
                        stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                            squeeze(trialFFTAtt(2,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
                        ylim([0 25000])
                        % Unattended
                        subplot(5,4,counter);
                        stem(freq_axis(1:size(trialFFTUnAtt,6)),squeeze(trialFFTUnAtt(2,l,j,i,elecSelect(k),:))')
                        hold on
                        stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                            squeeze(trialFFTUnAtt(2,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
                        ylim([0 25000])
                    end
                end
            end
        end
        
        % Save the figures
        
    end
    
    cd ../../../   % cd back out to data folder
    
    
    %
    %     %     % Store group data
    %     %     for n=1:length(subjList)   % To load in ind subjs data
    %     %         cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_60HzLP/'))
    %     %
    %     %         load('FFT_Results')
    %
    %     oriFFTSelectAttGroup(n,:,:,:,:,:) = oriFFTFullSelectAtt;
    %     sizeFFTSelectAttGroup(n,:,:,:,:,:) = sizeFFTFullSelectAtt;
    %
    %     oriFFTFullGroup(n,:,:,:,:) = oriFFT;
    %     sizeFFTFullGroup(n,:,:,:,:) = sizeFFT;
    %
    %     oriFFTFullAttGroup(n,:,:,:,:) = oriFFTAtt;
    %     sizeFFTFullAttGroup(n,:,:,:,:) = sizeFFTAtt;
    %
    %
    %     %         cd ../../
    %     %
    %     %         clear chosenFreasOri chosenFreasSize oriFFT oriFFTAtt oriFFTFullSelectAtt sizeFFT sizeFFTAtt sizeFFTFullSelectAtt
    %     %
    %     %     end
    
    
    
end

%% Group analysis
% First load in data
for i=1:length(subjList)
    cd(sprintf('%s',subjList{i},'/',subjList{i},'_results_60HzLP/'))   % cd into participant folder
    
    load('FFT_Results_Oddball','trialFFTAtt','trialFFTUnAtt','trialFFTAttWPhase','trialFFTUnAttWPhase');
    
    trialFFTAttGroup(i,:,:,:,:,:,:) = trialFFTAtt(:,:,:,:,:,:);
    trialFFTUnAttGroup(i,:,:,:,:,:,:) = trialFFTUnAtt(:,:,:,:,:,:);
    
    trialFFTAttWPhaseGroup(i,:,:,:,:,:,:) = trialFFTAttWPhase(:,:,:,:,:,:);
    trialFFTUnAttWPhaseGroup(i,:,:,:,:,:,:) = trialFFTUnAttWPhase(:,:,:,:,:,:);
    
    cd ../../
end

% Collapse across participants
trialFFTAttGroupAve = squeeze(nanmean(trialFFTAttGroup,1));
trialFFTAttGroupSTE = squeeze(ste(trialFFTAttGroup,1));
trialFFTUnAttGroupAve = squeeze(nanmean(trialFFTUnAttGroup,1));
trialFFTUnAttGroupSTE = squeeze(ste(trialFFTUnAttGroup,1));

trialFFTAttWPhaseGroupAve = abs(squeeze(nanmean(trialFFTAttWPhaseGroup,1)));
trialFFTUnAttWPhaseGroupAve = abs(squeeze(nanmean(trialFFTUnAttWPhaseGroup,1)));

stimRateOB = [.6 .75 .8 2];
freq_axis = 0:1/20:1000-1/20;

% Create an index using the attended and unattended values
for n=1:size(trialFFTAttGroup,1)
    for i=1:size(trialFFTAttGroup,2)
        for j=1:size(trialFFTAttGroup,3)
            for k=1:size(trialFFTAttGroup,4)
                for l=1:size(trialFFTAttGroup,5)
                    for o=1:size(trialFFTAttGroup,6)
                        if ~isempty(trialFFTAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1)) && ~isempty(trialFFTUnAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1))
                            trialFFTIdx(n,i,j,k,l,o,1) = ( (trialFFTAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1)) - (trialFFTUnAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1)) ) / ...
                                ( (trialFFTAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1)) + (trialFFTUnAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1)) );   % First harmonic
                            trialFFTIdx(n,i,j,k,l,o,2) = ( (trialFFTAttGroup(n,i,j,k,l,o,2*stimRateOB(l)*20+1)) - (trialFFTUnAttGroup(n,i,j,k,l,o,2*stimRateOB(l)*20+1)) ) / ...
                                ( (trialFFTAttGroup(n,i,j,k,l,o,2*stimRateOB(l)*20+1)) + (trialFFTUnAttGroup(n,i,j,k,l,o,2*stimRateOB(l)*20+1)) );   % Second harmonic
                            trialFFTIdx(n,i,j,k,l,o,3) = ( (trialFFTAttGroup(n,i,j,k,l,o,3*(stimRateOB(l)*20)+1)) - (trialFFTUnAttGroup(n,i,j,k,l,o,3*(stimRateOB(l)*20)+1)) ) / ...
                                ( (trialFFTAttGroup(n,i,j,k,l,o,3*(stimRateOB(l)*20)+1)) + (trialFFTUnAttGroup(n,i,j,k,l,o,3*(stimRateOB(l)*20)+1)) );   % Third harmonic
                        elseif isempty(trialFFTAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1)) || isempty(trialFFTUnAttGroup(n,i,j,k,l,o,stimRateOB(l)*20+1))
                            trialFFTIdx(n,i,j,k,l,o,1) = [];   % First harmonic
                            trialFFTIdx(n,i,j,k,l,o,2) = [];   % Second harmonic
                            trialFFTIdx(n,i,j,k,l,o,3) = [];   % Third harmonic
                        end
                    end
                end
            end
        end
    end
end

% Average indices across frequencies
trialFFTIdxFreqAve = squeeze(nanmean(trialFFTIdx,5));

% Average indices across participants
trialFFTIdxGroupAve = squeeze(nanmean(trialFFTIdxFreqAve,1));

%% Plot power spectrum for each frequency collapsed across participants
if plotData == 1
    stimRateOB = [.6 .75 .8 2];
    freq_axis = 0:1/20:1000-1/20;
    
    % Orientation
    for i=1:4   % .6, .75, .8, and 2 Hz OB freqs
        figure()
        suptitle(sprintf('%0.2f%s',stimRateOB(i),' Tag Orientation Average'))
        counter = 0;
        for j=1:5
            for l=1:2
                for k=1:length(elecSelect(1))   % Just plot one for now
                    % Attended
                    counter = counter+2;
                    subplot(5,4,counter-1);
                    stem(freq_axis(1:size(trialFFTAttGroupAve,6)),squeeze(trialFFTAttGroupAve(1,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTAttGroupAve(1,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                    % Unattended
                    subplot(5,4,counter);
                    stem(freq_axis(1:size(trialFFTUnAttGroupAve,6)),squeeze(trialFFTUnAttGroupAve(1,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTUnAttGroupAve(1,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                end
            end
        end
    end
    
    % Size
    for i=1:4   % .6, .75, .8, and 2 Hz OB freqs
        figure()
        suptitle(sprintf('%0.2f%s',stimRateOB(i),' Tag Size Average'))
        counter = 0;
        for j=1:5
            for l=1:2
                for k=1:length(elecSelect(1))   % Just plot one for now
                    % Attended
                    counter = counter+2;
                    subplot(5,4,counter-1);
                    stem(freq_axis(1:size(trialFFTAttGroupAve,6)),squeeze(trialFFTAttGroupAve(2,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTAttGroupAve(2,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                    % Unattended
                    subplot(5,4,counter);
                    stem(freq_axis(1:size(trialFFTUnAttGroupAve,6)),squeeze(trialFFTUnAttGroupAve(2,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTUnAttGroupAve(2,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                end
            end
        end
    end
end

%% Plot power spectrum for each frequency collapsed across participants before abs'ing phase out
if plotData == 1
    stimRateOB = [.6 .75 .8 2];
    freq_axis = 0:1/20:1000-1/20;
    
    % Orientation
    for i=1:4   % .6, .75, .8, and 2 Hz OB freqs
        figure()
        suptitle(sprintf('%0.2f%s',stimRateOB(i),' Tag Orientation Average'))
        counter = 0;
        for j=1:5
            for l=1:2
                for k=1:length(elecSelect(1))   % Just plot one for now
                    % Attended
                    counter = counter+2;
                    subplot(5,4,counter-1);
                    stem(freq_axis(1:size(trialFFTAttWPhaseGroupAve,6)),squeeze(trialFFTAttWPhaseGroupAve(1,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTAttWPhaseGroupAve(1,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                    % Unattended
                    subplot(5,4,counter);
                    stem(freq_axis(1:size(trialFFTUnAttWPhaseGroupAve,6)),squeeze(trialFFTUnAttWPhaseGroupAve(1,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTUnAttWPhaseGroupAve(1,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                end
            end
        end
    end
    
    % Size
    for i=1:4   % .6, .75, .8, and 2 Hz OB freqs
        figure()
        suptitle(sprintf('%0.2f%s',stimRateOB(i),' Tag Size Average'))
        counter = 0;
        for j=1:5
            for l=1:2
                for k=1:length(elecSelect(1))   % Just plot one for now
                    % Attended
                    counter = counter+2;
                    subplot(5,4,counter-1);
                    stem(freq_axis(1:size(trialFFTAttWPhaseGroupAve,6)),squeeze(trialFFTAttWPhaseGroupAve(2,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTAttWPhaseGroupAve(2,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                    % Unattended
                    subplot(5,4,counter);
                    stem(freq_axis(1:size(trialFFTUnAttWPhaseGroupAve,6)),squeeze(trialFFTUnAttWPhaseGroupAve(2,l,j,i,elecSelect(k),:))')
                    hold on
                    stem(freq_axis(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1),...
                        squeeze(trialFFTUnAttWPhaseGroupAve(2,l,j,i,elecSelect(k),(stimRateOB(i)*20+1:stimRateOB(i)*20:6*stimRateOB(i)*20+1)))','g')   % OB tags in green
%                     ylim([0 25000])
                end
            end
        end
    end
end

%% Plot the index values collapsed across frequency and participant
if plotData == 1
    for i=1:2   % Ori vs size
        for j=1:2   % Left vs right att
            figure()
            suptitle(sprintf('%s','Index Values ',cats.task{i},' ',cats.attend{j},' Attend'))
            counter = 0;
            for l=1:5   % Levels
                for k=1:3   %harmonics
                    counter=counter+1;
                    subplot(5,3,counter)
                    bar(squeeze(trialFFTIdxGroupAve(i,j,l,...
                        [elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],k)))
                    hold on
                    % Plot horizontal black lines to separate the electrode groups
                    runningSum = 0;
                    for o=1:length(elecArray)
                        runningSum = runningSum + length(elecArray{o});
                        xline(runningSum,'k','LineWidth',2);
                    end
                    xticks(place2plot);
                    if l==5
                        xticklabels(labels);
                        xtickangle(45);
                    else
                        xticklabels([]);
                    end
                end
            end
        end
    end
end


% %% Look at averaged data without collapsing across attended hemifeild
% % Ori
% for i=1:2   % 3Hz vs 5Hz
%     for j=1:2   % Left vs right attend
%         figure()
%         counter = 0;
%         for k=1:5   % Level
%             for l=1:length(elecSelect)
%                 counter = counter+1;
%                 subplot(5,3,counter);
%                 stem(freq_axis(1:size(oriFFTFullGroupAve,4)),squeeze(oriFFTFullGroupAve(k+(j-1),i,elecSelect(l),:)))
%                 hold on
%                 stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(oriFFTFullGroupAve(k+(j-1),i,elecSelect(l),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
%                 stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(oriFFTFullGroupAve(k+(j-1),i,elecSelect(l),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
%             end
%         end
%     end
% end
% % Size
% for i=1:2   % 3Hz vs 5Hz
%     for j=1:2   % Left vs right attend
%         figure()
%         counter = 0;
%         for k=1:5   % Level
%             for l=1:length(elecSelect)
%                 counter = counter+1;
%                 subplot(5,3,counter);
%                 stem(freq_axis(1:size(sizeFFTFullGroupAve,4)),squeeze(sizeFFTFullGroupAve(k+(j-1),i,elecSelect(l),:)))
%                 hold on
%                 stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(sizeFFTFullGroupAve(k+(j-1),i,elecSelect(l),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
%                 stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(sizeFFTFullGroupAve(k+(j-1),i,elecSelect(l),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
%             end
%         end
%     end
% end
%
% % Look at the differences between 3Hz/5Hz att/unatt for both left/right
% % attend
% for k=1:10   % Condition
%     oriFFTFullGroupAveAtt(k,1,:,:) = oriFFTFullGroupAve(k,1,:,(3*20+1:3*20:3*3*20+1)) - oriFFTFullGroupAve(k,2,:,(3*20+1:3*20:3*3*20+1));
%     oriFFTFullGroupAveAtt(k,2,:,:) = oriFFTFullGroupAve(k,2,:,(5*20+1:5*20:3*5*20+1)) - oriFFTFullGroupAve(k,1,:,(5*20+1:5*20:3*5*20+1));
%
%     sizeFFTFullGroupAveAtt(k,1,:,:) = sizeFFTFullGroupAve(k,1,:,(3*20+1:3*20:3*3*20+1)) - sizeFFTFullGroupAve(k,2,:,(3*20+1:3*20:3*3*20+1));
%     sizeFFTFullGroupAveAtt(k,2,:,:) = sizeFFTFullGroupAve(k,2,:,(5*20+1:5*20:3*5*20+1)) - sizeFFTFullGroupAve(k,1,:,(5*20+1:5*20:3*5*20+1));
% end
%
%
% % Plot
% taskTitle = {'Ori' 'Size'};
% attTitle = {'Left' 'Right'};
% freqTitle = {'3Hz' '5Hz'};
% % Ori
% for i=1:2   % 3Hz vs 5Hz
%     for j=1:2   % Left vs right attend
%         figure()
%         suptitle(sprintf('%s%s%s',taskTitle{1},attTitle{j},freqTitle{i}));
%         counter = 0;
%         for k=1:5   % Level
%             for l=1:3   % 3 Harmonics
%                 counter = counter+1;
%                 subplot(5,3,counter);
%
%                 bar(squeeze(oriFFTFullGroupAveAtt(k+(j-1),i,...
%                     [elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],l)));
%                 hold on
%                 % Plot horizontal black lines to separate the electrode groups
%                 runningSum = 0;
%                 for o=1:length(elecArray)
%                     runningSum = runningSum + length(elecArray{o});
%                     xline(runningSum,'k','LineWidth',2);
%                 end
%                 xticks(place2plot);
%                 if k==5
%                     xticklabels(labels);
%                     xtickangle(45);
%                 else
%                     xticklabels([]);
%                 end
%                 ylim([-6000 6000])
%             end
%         end
%     end
% end
%
% % Size
% for i=1:2   % 3Hz vs 5Hz
%     for j=1:2   % Left vs right attend
%         figure()
%         suptitle(sprintf('%s%s%s',taskTitle{2},attTitle{j},freqTitle{i}));
%         counter = 0;
%         for k=1:5   % Level
%             for l=1:3   % 3 Harmonics
%                 counter = counter+1;
%                 subplot(5,3,counter);
%
%                 bar(squeeze(sizeFFTFullGroupAveAtt(k+(j-1),i,...
%                     [elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],l)));
%                 hold on
%                 % Plot horizontal black lines to separate the electrode groups
%                 runningSum = 0;
%                 for o=1:length(elecArray)
%                     runningSum = runningSum + length(elecArray{o});
%                     xline(runningSum,'k','LineWidth',2);
%                 end
%                 xticks(place2plot);
%                 if k==5
%                     xticklabels(labels);
%                     xtickangle(45);
%                 else
%                     xticklabels([]);
%                 end
%                 ylim([-6000 6000])
%             end
%         end
%     end
% end
%
%
% %% Look at the differences between 3Hz/5Hz att/unatt
% for i=1:5   % Levels
%     for j=1:3   % Harmonics
%         oriFFTSelectAttGroupAveDiff(i,1,j,:) = oriFFTSelectAttGroupAve(i,1,1,j,:) - oriFFTSelectAttGroupAve(i,1,2,j,:);   % 3Hz att - 3Hz unatt
%         oriFFTSelectAttGroupAveDiff(i,2,j,:) = oriFFTSelectAttGroupAve(i,2,1,j,:) - oriFFTSelectAttGroupAve(i,2,2,j,:);   % 5Hz att - 5Hz unatt
%
%         sizeFFTSelectAttGroupAveDiff(i,1,j,:) = sizeFFTSelectAttGroupAve(i,1,1,j,:) - sizeFFTSelectAttGroupAve(i,1,2,j,:);   % 3Hz att - 3Hz unatt
%         sizeFFTSelectAttGroupAveDiff(i,2,j,:) = sizeFFTSelectAttGroupAve(i,2,1,j,:) - sizeFFTSelectAttGroupAve(i,2,2,j,:);   % 5Hz att - 5Hz unatt
%     end
% end
%
% figure()
% subplot(1,2,1)
% bar(squeeze(oriFFTSelectAttGroupAveDiff(1,2,1,elecSelect)))
% subplot(1,2,2)
% bar(squeeze(oriFFTSelectAttGroupAveDiff(1,2,2,elecSelect)))
%
% % Plot the differences
% % Ori
% figure()
% counter = 0;
% for i=1:5
%     for j=1:3
%         counter=counter+1;
%         subplot(3,5,counter)
%         bar(squeeze(oriFFTSelectAttGroupAveDiff(i,1,j,:)),'g');
%         hold on
%         bar(squeeze(oriFFTSelectAttGroupAveDiff(i,2,j,:)),'r');
%     end
% end
% % Size
% figure()
% counter = 0;
% for i=1:5
%     for j=1:3
%         counter=counter+1;
%         subplot(3,5,counter)
%         bar(squeeze(sizeFFTSelectAttGroupAveDiff(i,1,j,:)),'g');
%         hold on
%         bar(squeeze(sizeFFTSelectAttGroupAveDiff(i,2,j,:)),'r');
%     end
% end
%
% % Save group data
% groupResultsDir = 'GroupResults/Group_results_60HzLP/';
% % check to see if this file exists
% if exist(groupResultsDir,'file')
% else
%     mkdir(groupResultsDir);
% end
% cd(sprintf('%s','./',groupResultsDir))
%
% save('Group_FFT_Results','oriFFTSelectAttGroupAve','sizeFFTSelectAttGroupAve',...
%     'oriFFTFullGroup','sizeFFTFullGroup','oriFFTFullAttGroupAve','sizeFFTFullAttGroupAve')
%
% cd ../../
%
%






