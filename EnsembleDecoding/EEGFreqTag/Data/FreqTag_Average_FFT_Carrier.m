% Script for segmenting into conditions and performing the FFT analysis for the carrier frequencies -
% 022019

clear all;
close all;

fakeData=0;
newSubjs = 1;

cats.ori = {'Ori1','Ori2','Ori3','Ori4','Ori5'};
cats.size = {'Size1','Size2','Size3','Size4','Size5'};
cats.task = {'Ori','Size'};
cats.attend = {'Left','Right'};

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

stimRateConvert = round(stimRate/0.1);

% If you are starting on new subjects, load in the group data files to
% append to them.
if newSubjs == 1
    load('./GroupResults/Group_results_60HzLP/Group_FFT_Results');
end

%% Segment/Trial Average/Index
% for n=17:length(subjList)
for n=17
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
            clear holder
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
    clear oriFFTFull sizeFFTFull
    
    % Segment into 5 groups for both feature per task and attended location, 10 trials
    % total, per each of the 20 conditions (segment across all size levels for each orienation and vice versa). Means there will be
    % overlap in trials in each group. 1=ori1, sizeAll, oriTask, leftAtt; 2=ori2, sizeAll,
    % oriTask, leftAtt; 6=ori1,sizeAll,oriTask,rightAtt;11=ori1,sizeAll,sizeTask,leftAtt
    % Preallocate the FFT arrays for speed
    for i=1:length(cats.ori)*length(cats.attend)
        
        %% Segment into conditions
        clear trlOri trlSize
        
        % Pick off trials corresponding to each condition
        trlOri = find(interp.trialinfo(:,2)==i);   % Find trials corresponding to ori condition
        trlSize = find(interp.trialinfo(:,3)==i);   % Find trials corresponding to size condition
        
        % Group trials based on condition
        % Ori
        for j=1:length(trlOri)
            for k=1:size(interp.trial{trlOri(j)},1)
                oriSeg{i}(j,k,:) = interp.trial{trlOri(j)}(k,:);
            end
        end
        % Size
        for j=1:length(trlSize)
            for k=1:size(interp.trial{trlSize(j)},1)
                sizeSeg{i}(j,k,:) = interp.trial{trlSize(j)}(k,:);
            end
        end
        
        % Pick off the frequency tags you want
        % in interp.info:
        % first column: 1=left faster rate; 2=right faster rate
        % second column - left side oddball rates: 1=ori faster oddball; 2=sizefaster oddball
        % third column - right side oddball rates: 1=ori faster; 2=size faster
        
        % stim_rate_BL(1) = 3;
        % stim_rate_BL(2) = 5;
        % stim_rate_OB(1,1) = .6;
        % stim_rate_OB(1,2) = .75;
        % stim_rate_OB(2,1) = .8;
        % stim_rate_OB(2,2) = 2;
        % Bin sizes are determined by sample rate / time points (1000/20000) = .05 Hz
        
        % Store the frequencies in one array, nConditions (20) long, that
        % corresponds to the chosen frequencies for left right BL, ori/size
        % OB rates for left, right.
        % chosenFreqs{condition}(1)=leftBL; (2)=rightBL; (3)=leftoriOB;
        % (4)=leftsizeOB; etc.
        
        
        %% Ori
        for j=1:length(trlOri)
            % Determine the BL rates for left/right
            if interp.info(trlOri(j),4)==1   % If 1 faster rate on left (5Hz left)
                rateBL(1)=stimRateConvert(1,2); rateBL(2)=stimRateConvert(1,1);
            elseif interp.info(trlOri(j),4)==2
                rateBL(1)=stimRateConvert(1,1); rateBL(2)=stimRateConvert(1,2);
            end
            
            % Determine the OB rates for ori/size for the 3 Hz side
            if interp.info(trlOri(j),5)==1   % If 1, ori faster stim (first position)
                rateLeft(1)=stimRateConvert(2,2);rateLeft(2)=stimRateConvert(2,1);
            elseif interp.info(trlOri(j),5)==2   % If 2, size faster stim (second position)
                rateLeft(1)=stimRateConvert(2,1);rateLeft(2)=stimRateConvert(2,2);
            end
            
            % Determine the OB rates for ori/size for the 5 Hz side
            if interp.info(trlOri(j),6)==1
                rateRight(1)=stimRateConvert(3,2);rateRight(2)=stimRateConvert(3,1);
            elseif interp.info(trlOri(j),6)==2
                rateRight(1)=stimRateConvert(3,1);rateRight(2)=stimRateConvert(3,2);
            end
            
            % Determine if this is a left/right attend trial
            if (interp.info(trlOri(j),2)>=1 && interp.info(trlOri(j),2)<=5) || (interp.info(trlOri(j),2)>=11 && interp.info(trlOri(j),2)<=15)
                attDir = 1;
            elseif (interp.info(trlOri(j),2)>=6 && interp.info(trlOri(j),2)<=10) || (interp.info(trlOri(j),2)>=16 && interp.info(trlOri(j),2)<=20)
                attDir = 2;
            end
            
            % ChosenFreqs:
            % (1)=left rate, (2)=right rate
            % (3)=3 Hz ori, (4)=3 Hz size
            % (5)=5 Hz ori, (6)=5 Hz size
            % (7)=attDir 1left 2right
            chosenFreqsOri{i}(j,:) = [rateBL(1),rateBL(2),...
                rateLeft(1),rateLeft(2),...
                rateRight(1),rateRight(2),attDir];
            
            clear rateRight rateLeft attDir rateBL
        end
        
        %% Size
        for j=1:length(trlSize)
            % Determine the BL rates for left/right
            if interp.info(trlSize(j),4)==1
                rateBL(1)=stimRateConvert(1,2); rateBL(2)=stimRateConvert(1,1);
            elseif interp.info(trlSize(j),4)==2
                rateBL(1)=stimRateConvert(1,1); rateBL(2)=stimRateConvert(1,2);
            end
            
            % Determine the OB rates for ori/size on the left
            if interp.info(trlSize(j),5)==1
                rateLeft(1)=stimRateConvert(2,2);rateLeft(2)=stimRateConvert(2,1);
            elseif interp.info(trlSize(j),5)==2
                rateLeft(1)=stimRateConvert(2,1);rateLeft(2)=stimRateConvert(2,2);
            end
            
            % Determine the OB rates for or/size on the right
            if interp.info(trlSize(j),6)==1
                rateRight(1)=stimRateConvert(3,2);rateRight(2)=stimRateConvert(3,1);
            elseif interp.info(trlSize(j),6)==2
                rateRight(1)=stimRateConvert(3,1);rateRight(2)=stimRateConvert(3,2);
            end
            
            % Determine if this is a left/right attend trial
            if (interp.info(trlSize(j),3)>=1 && interp.info(trlSize(j),3)<=5) || (interp.info(trlSize(j),3)>=11 && interp.info(trlSize(j),3)<=15)
                attDir = 1;
            elseif (interp.info(trlSize(j),3)>=6 && interp.info(trlSize(j),3)<=10) || (interp.info(trlSize(j),3)>=16 && interp.info(trlSize(j),3)<=20)
                attDir = 2;
            end
            
            chosenFreqsSize{i}(j,:) = [rateBL(1),rateBL(2),...
                rateLeft(1),rateLeft(2),...
                rateRight(1),rateRight(2),attDir];
            
            clear rateRight rateLeft attDir rateBL
        end
        
        % Select electrodes to display
        elecSelect(1) = 137;   % Ceneter parietal
        elecSelect(2) = 90;   % Occ
        elecSelect(3) = 21;   % Frontal
        
        %% Carrier freq analysis (3/5 Hz)
        % right) and take the FFT of the average
        fprintf('%s%d%s\n','Performing carrier freq FFT for condition ',i,'...')
        
        %% Orientation
        % Find the 5Hz att and 3Hz att trials
        hzTrialsCarrier{1} = find(chosenFreqsOri{i}(:,1)==stimRateConvert(1,1));
        hzTrialsCarrier{2} = find(chosenFreqsOri{i}(:,1)==stimRateConvert(1,2));
        
        % Average the trials
        for j=1:256
            if length(hzTrialsCarrier{1})==1
                oriSegAveCarrier(i,1,j,:) = squeeze(oriSeg{i}(hzTrialsCarrier{1},j,:));
                oriSegAveCarrier(i,2,j,:) = mean(squeeze(oriSeg{i}(hzTrialsCarrier{2},j,:)),1);
            elseif length(hzTrialsCarrier{2})==1
                oriSegAveCarrier(i,1,j,:) = mean(squeeze(oriSeg{i}(hzTrialsCarrier{1},j,:)),1);
                oriSegAveCarrier(i,2,j,:) = squeeze(oriSeg{i}(hzTrialsCarrier{2},j,:));
            else
                oriSegAveCarrier(i,1,j,:) = mean(squeeze(oriSeg{i}(hzTrialsCarrier{1},j,:)),1);
                oriSegAveCarrier(i,2,j,:) = mean(squeeze(oriSeg{i}(hzTrialsCarrier{2},j,:)),1);
            end
        end
        
        % Do the FFT
        for l=1:256
            oriFFTFullCarrier(i,1,l,:) = squeeze(abs(fft(oriSegAveCarrier(i,1,l,:))));   % 3Hz att
            oriFFTFullCarrier(i,2,l,:) = squeeze(abs(fft(oriSegAveCarrier(i,2,l,:))));   % 5Hz att
        end
        
        % For 3Hz att trials grab 3Hz and 5hz (unattended) and for 5hz
        % att trials grab 3Hz (unattended) and 5Hz
        oriFFTCarrierFullSelect(i,1,1,1,:) = squeeze(oriFFTFullCarrier(i,1,:,61));   % 3 Hz attend first harmonic
        oriFFTCarrierFullSelect(i,1,2,1,:) = squeeze(oriFFTFullCarrier(i,2,:,61));   % 3 Hz unattend first harmonic
        
        oriFFTCarrierFullSelect(i,1,1,2,:) = squeeze(oriFFTFullCarrier(i,1,:,121));   % 3 Hz attend second harmonic
        oriFFTCarrierFullSelect(i,1,2,2,:) = squeeze(oriFFTFullCarrier(i,2,:,121));   % 3 Hz unattend second harmonic
        
        oriFFTCarrierFullSelect(i,1,1,3,:) = squeeze(oriFFTFullCarrier(i,1,:,181));   % 3 Hz attend third harmonic
        oriFFTCarrierFullSelect(i,1,2,3,:) = squeeze(oriFFTFullCarrier(i,2,:,181));   % 3 Hz unattend third harmonic
        
        oriFFTCarrierFullSelect(i,2,1,1,:) = squeeze(oriFFTFullCarrier(i,2,:,101));   % 5 Hz attend first harmonic
        oriFFTCarrierFullSelect(i,2,2,1,:) = squeeze(oriFFTFullCarrier(i,1,:,101));   % 5 Hz unattend first harmonic
        
        oriFFTCarrierFullSelect(i,2,1,2,:) = squeeze(oriFFTFullCarrier(i,2,:,201));   % 5 Hz attend second harmonic
        oriFFTCarrierFullSelect(i,2,2,2,:) = squeeze(oriFFTFullCarrier(i,1,:,201));   % 5 Hz unattend second harmonic
        
        oriFFTCarrierFullSelect(i,2,1,3,:) = squeeze(oriFFTFullCarrier(i,2,:,301));   % 5 Hz attend third harmonic
        oriFFTCarrierFullSelect(i,2,2,3,:) = squeeze(oriFFTFullCarrier(i,1,:,301));   % 5 Hz unattend third harmonic
        
        clear hzTrialsCarrier
        
        %% Size
        % Find the 5Hz att and 3Hz att trials
        hzTrialsCarrier{1} = find(chosenFreqsSize{i}(:,1)==stimRateConvert(1,1));
        hzTrialsCarrier{2} = find(chosenFreqsSize{i}(:,1)==stimRateConvert(1,2));
        
        % Average the trials
        for j=1:256
            if length(hzTrialsCarrier{1})==1
                sizeSegAveCarrier(i,1,j,:) = squeeze(sizeSeg{i}(hzTrialsCarrier{1},j,:));
                sizeSegAveCarrier(i,2,j,:) = mean(squeeze(sizeSeg{i}(hzTrialsCarrier{2},j,:)),1);
            elseif length(hzTrialsCarrier{2})==1
                sizeSegAveCarrier(i,1,j,:) = mean(squeeze(sizeSeg{i}(hzTrialsCarrier{1},j,:)),1);
                sizeSegAveCarrier(i,2,j,:) = squeeze(sizeSeg{i}(hzTrialsCarrier{2},j,:));
            else
                sizeSegAveCarrier(i,1,j,:) = mean(squeeze(sizeSeg{i}(hzTrialsCarrier{1},j,:)),1);
                sizeSegAveCarrier(i,2,j,:) = mean(squeeze(sizeSeg{i}(hzTrialsCarrier{2},j,:)),1);
            end
        end
        
        % Do the FFT
        for l=1:256
            sizeFFTFullCarrier(i,1,l,:) = squeeze(abs(fft(sizeSegAveCarrier(i,1,l,:))));   % 3Hz att
            sizeFFTFullCarrier(i,2,l,:) = squeeze(abs(fft(sizeSegAveCarrier(i,2,l,:))));   % 5Hz att
        end
        
        % For 3Hz att trials grab 3Hz and 5hz (unattended) and for 5hz
        % att trials grab 3Hz (unattended) and 5Hz
        sizeFFTCarrierFullSelect(i,1,1,1,:) = squeeze(sizeFFTFullCarrier(i,1,:,61));   % 3 Hz attend first harmonic
        sizeFFTCarrierFullSelect(i,1,2,1,:) = squeeze(sizeFFTFullCarrier(i,2,:,61));   % 3 Hz unattend first harmonic
        
        sizeFFTCarrierFullSelect(i,1,1,2,:) = squeeze(sizeFFTFullCarrier(i,1,:,121));   % 3 Hz attend second harmonic
        sizeFFTCarrierFullSelect(i,1,2,2,:) = squeeze(sizeFFTFullCarrier(i,2,:,121));   % 3 Hz unattend second harmonic
        
        sizeFFTCarrierFullSelect(i,1,1,3,:) = squeeze(sizeFFTFullCarrier(i,1,:,181));   % 3 Hz attend third harmonic
        sizeFFTCarrierFullSelect(i,1,2,3,:) = squeeze(sizeFFTFullCarrier(i,2,:,181));   % 3 Hz unattend third harmonic
        
        sizeFFTCarrierFullSelect(i,2,1,1,:) = squeeze(sizeFFTFullCarrier(i,2,:,101));   % 5 Hz attend first harmonic
        sizeFFTCarrierFullSelect(i,2,2,1,:) = squeeze(sizeFFTFullCarrier(i,1,:,101));   % 5 Hz unattend first harmonic
        
        sizeFFTCarrierFullSelect(i,2,1,2,:) = squeeze(sizeFFTFullCarrier(i,2,:,201));   % 5 Hz attend second harmonic
        sizeFFTCarrierFullSelect(i,2,2,2,:) = squeeze(sizeFFTFullCarrier(i,1,:,201));   % 5 Hz unattend second harmonic
        
        sizeFFTCarrierFullSelect(i,2,1,3,:) = squeeze(sizeFFTFullCarrier(i,2,:,301));   % 5 Hz attend third harmonic
        sizeFFTCarrierFullSelect(i,2,2,3,:) = squeeze(sizeFFTFullCarrier(i,1,:,301));   % 5 Hz unattend third harmonic
        
        clear hzTrialsCarrier
    end
    
    %% Sort and save
    fprintf('%s\n','Sorting and saving...')
    % Collapse the select freqs across attended hemifeild so you are just left with 3Hz att,
    % 3Hz unatt, 5Hz att, and 5Hz unatt (and the 3 harmonics), for each
    % condition.
    for i=1:5
        for j=1:size(oriFFTCarrierFullSelect,2)   % Attended
            for k=1:size(oriFFTCarrierFullSelect,3)   % Unattended
                for l=1:size(oriFFTCarrierFullSelect,4)   % Harmonics
                    for o=1:size(oriFFTCarrierFullSelect,5)   % Electrode
                        oriFFTFullSelectAtt(i,j,k,l,o) = nanmean([oriFFTCarrierFullSelect(i,j,k,l,o) oriFFTCarrierFullSelect(i+5,j,k,l,o)]);
                        sizeFFTFullSelectAtt(i,j,k,l,o) = nanmean([sizeFFTCarrierFullSelect(i,j,k,l,o) sizeFFTCarrierFullSelect(i+5,j,k,l,o)]);
                    end
                end
            end
        end
    end
    
    % Clear out most of the timepoints in the FFT for easier saving and
    % ploting
    for i=1:size(oriFFTFullCarrier,1)
        oriFFT(i,:,:,:) = oriFFTFullCarrier(i,:,:,1:750);
        sizeFFT(i,:,:,:) = sizeFFTFullCarrier(i,:,:,1:750);
    end
    
    % Collapse all FFT amps across attended hemifeild
    for i=1:5
        for j=1:size(oriFFT,2)
            for k=1:size(oriFFT,3)
                oriFFTAtt(i,j,k,:) = nanmean([oriFFT(i,j,k,:) oriFFT(i+5,j,k,:)]);
                sizeFFTAtt(i,j,k,:) = nanmean([sizeFFT(i,j,k,:) sizeFFT(i+5,j,k,:)]);
            end
        end
    end
    
    % Plot the power spectrum for 3Hz att and 5Hz att (which contain 5Hz
    % and 3Hz unatt respectively)
    freq_axis = 0:1/20:1000-1/20;
    
    % Orientation
    for i=1:2   % 3Hz att and 5Hz att
        figure()
        counter = 0;
        for j=1:5
            for k=1:length(elecSelect)
                counter = counter+1;
                subplot(5,3,counter);
                stem(freq_axis(1:size(oriFFTAtt,4)),squeeze(oriFFTAtt(j,i,elecSelect(k),:)))
                hold on
                stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(oriFFTAtt(j,i,elecSelect(k),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
                stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(oriFFTAtt(j,i,elecSelect(k),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
            end
        end
    end
    
    % Size
    for i=1:2   % 3Hz att and 5Hz att
        figure()
        counter = 0;
        for j=1:5
            for k=1:length(elecSelect)
                counter = counter+1;
                subplot(5,3,counter);
                stem(freq_axis(1:size(sizeFFTAtt,4)),squeeze(sizeFFTAtt(j,i,elecSelect(k),:)))
                hold on
                stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(sizeFFTAtt(j,i,elecSelect(k),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
                stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(sizeFFTAtt(j,i,elecSelect(k),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
            end
        end
    end
    
%         % Store group data
%         for n=1:length(subjList)   % To load in ind subjs data
%             cd(sprintf('%s','./',subjList{n},'/',subjList{n},'_results_60HzLP/'))
%     
%             load('FFT_Results')
    
    oriFFTSelectAttGroup(n,:,:,:,:,:) = oriFFTFullSelectAtt;
    sizeFFTSelectAttGroup(n,:,:,:,:,:) = sizeFFTFullSelectAtt;
    
    oriFFTFullGroup(n,:,:,:,:) = oriFFT;
    sizeFFTFullGroup(n,:,:,:,:) = sizeFFT;
    
    oriFFTFullAttGroup(n,:,:,:,:) = oriFFTAtt;
    sizeFFTFullAttGroup(n,:,:,:,:) = sizeFFTAtt;

    
%             cd ../../
%     
%             clear chosenFreasOri chosenFreasSize oriFFT oriFFTAtt oriFFTFullSelectAtt sizeFFT sizeFFTAtt sizeFFTFullSelectAtt
%     
%         end
    
    % Save each participants data
    cd ../
    save(sprintf('%s%s',dataDir,'/FFT_Results'),'chosenFreqsOri','chosenFreqsSize','oriFFT','sizeFFT','oriFFTFullSelectAtt','sizeFFTFullSelectAtt',...
        'oriFFTAtt','sizeFFTAtt');
    
    % Save each group seperately since they are too big to save together
    tcircDir = sprintf('%s%s%d',dataDir,'/tCircData');
    if exist(tcircDir,'file')
    else
        mkdir(tcircDir);
    end
    cd(sprintf('%s','./',tcircDir))
    
    for i=1:length(oriSeg)
        oriSegTCirc = oriSeg{i};
        sizeSegTCirc = sizeSeg{i};
        save(sprintf('%s%d','tcir_Seg_Data_',i),'oriSegTCirc','sizeSegTCirc');
        
        clear oriSegTCirc sizeSegTCirc
    end
    
    cd ../../../
    
    % Clear out variables for next participant
    clear chosenFreqsOri chosenFreqsSize oriSeg sizeSeg oriFFTFull sizeFFTFull sizeFFT oriFFT...
        oriFFTFullSelect sizeFFTFullSelect oriFFTFullSelectAtt sizeFFTFullSelectAtt oriSegAve sizeSegAve oriFFTAtt sizeFFTAtt
    
end

%% Group averages
% Collapse across participants
oriFFTSelectAttGroupAve = squeeze(nanmean(oriFFTSelectAttGroup,1));
sizeFFTSelectAttGroupAve = squeeze(nanmean(sizeFFTSelectAttGroup,1));

oriFFTFullAttGroupAve = squeeze(nanmean(oriFFTFullAttGroup,1));
sizeFFTFullAttGroupAve = squeeze(nanmean(sizeFFTFullAttGroup,1));

oriFFTFullGroupAve = squeeze(nanmean(oriFFTFullGroup,1));
sizeFFTFullGroupAve = squeeze(nanmean(sizeFFTFullGroup,1));


%% Plot the power spectrum for 3Hz att and 5Hz att (which contain 5Hz
% and 3Hz unatt respectively)
freq_axis = 0:1/20:1000-1/20;

% Orientation
for i=1:2   % 3Hz att and 5Hz att
    figure()
    counter = 0;
    for j=1:5
        for k=1:length(elecSelect)
            counter = counter+1;
            subplot(5,3,counter);
            stem(freq_axis(1:size(oriFFTFullAttGroupAve,4)),squeeze(oriFFTFullAttGroupAve(j,i,elecSelect(k),:)))
            hold on
            stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(oriFFTFullAttGroupAve(j,i,elecSelect(k),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
            stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(oriFFTFullAttGroupAve(j,i,elecSelect(k),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
        end
    end
end

% Size
for i=1:2   % 3Hz att and 5Hz att
    figure()
    counter = 0;
    for j=1:5
        for k=1:length(elecSelect)
            counter = counter+1;
            subplot(5,3,counter);
            stem(freq_axis(1:size(sizeFFTFullAttGroupAve,4)),squeeze(sizeFFTFullAttGroupAve(j,i,elecSelect(k),:)))
            hold on
            stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(sizeFFTFullAttGroupAve(j,i,elecSelect(k),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
            stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(sizeFFTFullAttGroupAve(j,i,elecSelect(k),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
        end
    end
end


%% Look at averaged data without collapsing across attended hemifeild
% Ori
for i=1:2   % 3Hz vs 5Hz
    for j=1:2   % Left vs right attend
        figure()
        counter = 0;
        for k=1:5   % Level
            for l=1:length(elecSelect)
                counter = counter+1;
                subplot(5,3,counter);
                stem(freq_axis(1:size(oriFFTFullGroupAve,4)),squeeze(oriFFTFullGroupAve(k+(j-1),i,elecSelect(l),:)))
                hold on
                stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(oriFFTFullGroupAve(k+(j-1),i,elecSelect(l),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
                stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(oriFFTFullGroupAve(k+(j-1),i,elecSelect(l),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
            end
        end
    end
end
% Size
for i=1:2   % 3Hz vs 5Hz
    for j=1:2   % Left vs right attend
        figure()
        counter = 0;
        for k=1:5   % Level
            for l=1:length(elecSelect)
                counter = counter+1;
                subplot(5,3,counter);
                stem(freq_axis(1:size(sizeFFTFullGroupAve,4)),squeeze(sizeFFTFullGroupAve(k+(j-1),i,elecSelect(l),:)))
                hold on
                stem(freq_axis(3*20+1:3*20:6*3*20+1),squeeze(sizeFFTFullGroupAve(k+(j-1),i,elecSelect(l),(3*20+1:3*20:6*3*20+1))),'g')   % 3Hz green
                stem(freq_axis(5*20+1:5*20:6*5*20+1),squeeze(sizeFFTFullGroupAve(k+(j-1),i,elecSelect(l),(5*20+1:5*20:6*5*20+1))),'r')   % 5Hz red
            end
        end
    end
end

% Look at the differences between 3Hz/5Hz att/unatt for both left/right
% attend
for k=1:10   % Condition
    oriFFTFullGroupAveAtt(k,1,:,:) = oriFFTFullGroupAve(k,1,:,(3*20+1:3*20:3*3*20+1)) - oriFFTFullGroupAve(k,2,:,(3*20+1:3*20:3*3*20+1));
    oriFFTFullGroupAveAtt(k,2,:,:) = oriFFTFullGroupAve(k,2,:,(5*20+1:5*20:3*5*20+1)) - oriFFTFullGroupAve(k,1,:,(5*20+1:5*20:3*5*20+1));
    
    sizeFFTFullGroupAveAtt(k,1,:,:) = sizeFFTFullGroupAve(k,1,:,(3*20+1:3*20:3*3*20+1)) - sizeFFTFullGroupAve(k,2,:,(3*20+1:3*20:3*3*20+1));
    sizeFFTFullGroupAveAtt(k,2,:,:) = sizeFFTFullGroupAve(k,2,:,(5*20+1:5*20:3*5*20+1)) - sizeFFTFullGroupAve(k,1,:,(5*20+1:5*20:3*5*20+1));
end

% Plot
taskTitle = {'Ori' 'Size'};
attTitle = {'Left' 'Right'};
freqTitle = {'3Hz' '5Hz'};
% Ori
for i=1:2   % 3Hz vs 5Hz
    for j=1:2   % Left vs right attend
        figure()
        suptitle(sprintf('%s%s%s',taskTitle{1},attTitle{j},freqTitle{i}));
        counter = 0;
        for k=1:5   % Level
            for l=1:3   % 3 Harmonics
                counter = counter+1;
                subplot(5,3,counter);
                
                bar(squeeze(oriFFTFullGroupAveAtt(k+(j-1),i,...
                    [elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],l)));
                hold on
                % Plot horizontal black lines to separate the electrode groups
                runningSum = 0;
                for o=1:length(elecArray)
                    runningSum = runningSum + length(elecArray{o});
                    xline(runningSum,'k','LineWidth',2);
                end
                xticks(place2plot);
                if k==5
                    xticklabels(labels);
                    xtickangle(45);
                else
                    xticklabels([]);
                end
                ylim([-6000 6000])
            end
        end
    end
end

% Size
for i=1:2   % 3Hz vs 5Hz
    for j=1:2   % Left vs right attend
        figure()
        suptitle(sprintf('%s%s%s',taskTitle{2},attTitle{j},freqTitle{i}));
        counter = 0;
        for k=1:5   % Level
            for l=1:3   % 3 Harmonics
                counter = counter+1;
                subplot(5,3,counter);
                
                bar(squeeze(sizeFFTFullGroupAveAtt(k+(j-1),i,...
                    [elecArray{1} elecArray{2} elecArray{3} elecArray{4} elecArray{5} elecArray{6} elecArray{7} elecArray{8} elecArray{9}],l)));
                hold on
                % Plot horizontal black lines to separate the electrode groups
                runningSum = 0;
                for o=1:length(elecArray)
                    runningSum = runningSum + length(elecArray{o});
                    xline(runningSum,'k','LineWidth',2);
                end
                xticks(place2plot);
                if k==5
                    xticklabels(labels);
                    xtickangle(45);
                else
                    xticklabels([]);
                end
                ylim([-6000 6000])
            end
        end
    end
end

%% Do the FDR corrected stats

%% Ori FDR
% Grab the relevant freq tags from the 750
for i=1:2   % For 3 Hz and 5 Hz
    oriFFTFullGroupHolder(:,:,i,:,:) = oriFFTFullGroup(:,:,i,:,(stimRate(1,i)*20+1:stimRate(1,i)*20:stimRate(1,i)*3*20+1));
end

% Average across frequencies
oriFFTFullGroupFreqAve = squeeze(nanmean(oriFFTFullGroupHolder,3));

% Calculate the tstat that corresp with pval of .05
alphaTStat = abs(tinv(.05/2,size(oriFFTFullGroup,1)-1));

% Calculate the threshold that corresp with an FDR of .1
% Initially set the actual difference value to be high
differenceActual([1:10]) = 100;

% Create a range of threshold values
threshold = .0001:.0001:.1;
numSig = zeros(size(oriFFTFullGroup,2),length(threshold),3);

% Loop through a range of threshold values to find the one that is
% closest to an FDR of .1 (threshold at which the ratio of expected FA's
% to number of significant electrodes is .1)
for i=1:size(oriFFTFullGroup,2)-5   % Loop through all conditions
    for j=1:length(threshold)
        
        for k=1:3   % For each of the 3 harmonics
            % loop through for all the electrodes
            for z=1:size(oriFFTFullGroup,3)
                
                % Calculate the tval that corresponds to the threshold that is set
                [S, P(i,j,z,k), CI, T{i,j,z,k}] = ttest(oriFFTFullGroupFreqAve(:,i,z,k),0,threshold(j));
                
                % How many electrodes are sig at each threshold
                % If the the pval is less than the threshold count up
                if P(i,j,z,k) < threshold(j)
                    numSig(i,j,k) = numSig(i,j,k) + 1;
                end
            end
        end
        
        % Calculate the expected number of false positives due to chance at the
        % threshold given
        expectedFA(i,j) = threshold(j)*size(oriFFTFullGroupFreqAve,3);
        
        % Calculate the FDR q for the threshold chosen
        FDR(i,j) = expectedFA(i,j)/numSig(i,j);
        
        % Is the FDR for this threshold the closest to .1?
        differenceHolder = abs(FDR(i,j) - .1);
        if differenceHolder < differenceActual(i)
            differenceActual(i) = differenceHolder;
            closestThresh(i) = FDR(i,j);
            closestThreshP(i) = threshold(j);
            thresholdIdx(i) = j;
        end
    end
end

clear S P CI T

% Calculate the tstat that corresponds with the pval
for i=1:length(closestThreshP)
    thresholdTStat(i) = abs(tinv((closestThreshP(i)/2),size(oriFFTFullGroupFreqAve,3)-1));
end

% Perform the ttest using participant data for each electrode.
for i=1:size(oriFFTFullGroupFreqAve,2)-5
    
    for k=1:3   % Harmonics
        for j=1:size(oriFFTFullGroupFreqAve,3)   % num of electrodes
            [S, P(i,j), CI, T{i,j}] = ttest(oriFFTFullGroupFreqAve(:,i,j,k),0,.05);
        end
    end
    
    % Make an array of tvalues from the struct
    for j=1:size(T,2)
        tArray(i,j) = T{i,j}.tstat;
    end
    
    % Sort the tvals based on significance
    [pSorted(i,:), pIndex(i,:)] = sort(P(i,:),2,'ascend');
    tSorted(i,:) = tArray(i,pIndex(i,:));
    
%     h = figure();
%     bar(tSorted(i,:))
%     line([1,257],[alphaTStat,alphaTStat],'Color',[1 0 0])
%     line([1,257],[thresholdTStat(i),thresholdTStat(i)],'Color',[0 1 0])
%     title(sprintf('%s%d','Ori Level ',i));
%     set(gca,'ylim',[-2,12])
%     ylabel('Test Statistic')
%    
%     % Save the figure and then close it
%     cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%     savefig(h,sprintf('%s%d%s','Carrier_TTest_Ori_Level_',i,'.fig'));
%     close(h)
%     cd ../../
end

% Plot the data in topos thresholded by FDR
plotVal = 't';
individualColors = true;
markerProps = {'facecolor','none','edgecolor','none','markersize',2,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
        
fig_dims = [1 1 8.5 11];   % Size of figure
fig_size = 4; %Thickness of borders
fig_box = 'on'; %Figure border on/off

h = figure('Units','inches','Position',fig_dims);
levelCounter = 1:2:9;
for c = 1:5  % For each level
    subplot(5,2,levelCounter(c))
    hold on
    cMap = colormap(jmaColors('pval'));
    if ~individualColors
        colorIdx = 1:length(conditions);
    else
        colorIdx = c;
    end
    switch plotVal
        case {'p','pval','p-value'}
            cMapMin = 0;
            cMapMax = 1;
            valsToPlot = squeeze(oriTCirc_p(condChoose(c,1),condChoose(c,2),:));
        case {'t','tval','t-value'}
            valsToPlot = squeeze(tArray(c,:))'; % plot t-stat
            cMapMax = 12; %ceil(max(max(valsToPlot(:,colorIdx))));
            cMapMin = 0;
        case 'mean'
            valsToPlot = abs(oriTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
            cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
            cMapMin = 0;
    end
    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(c)),false,markerProps);
    
    % Count the number of significant electrodes for ori
    oriSigElecCountOri(c) = length(find(tArray(c,:)<thresholdTStat(c)));
    
    set(gcf,'ColorMap',cMap);
    set(gca, 'Clim',[cMapMin,cMapMax]);
    title(sprintf('%s%d%s','Orientation Level ',c),'FontSize',12);
    
    text1 = sprintf('%s','o : significant electrodes at a');
    text(0,-15,text1,'FontSize',10,'HorizontalAlignment','center');
    text2 = sprintf('%s%.4f','FDR corrected threshold of ',closestThreshP(c));
    text(0,-19,text2,'FontSize',10,'HorizontalAlignment','center');
    
    hold off
    
%     % Save the figure and then close it
%     cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%     print(h,sprintf('%s%d%s','Carrier_TTest_Ori_Level_',c,'_Topo.tif'),'-dtiffn');   % Save .tif
%     savefig(h,sprintf('%s%d%s','Carrier_TTest_Ori_Level_',c,'_Topo.fig'));
%     close(h)
%     cd ../../
end

% Clear variables for size calculation
clear thresholdTStat alphaTStat differenceActual numSig S P CT T expectedFA FDR closestThresh closestThreshP thresholdIdx differenceHolder...
    thresholdTStat tArray tSorted pSorted pIndex


%% Size FDR
% Grab the relevant freq tags from the 750
for i=1:2   % For 3 Hz and 5 Hz
    sizeFFTFullGroupHolder(:,:,i,:,:) = sizeFFTFullGroup(:,:,i,:,(stimRate(1,i)*20+1:stimRate(1,i)*20:stimRate(1,i)*3*20+1));
end

% Average across frequencies
sizeFFTFullGroupFreqAve = squeeze(nanmean(sizeFFTFullGroupHolder,3));

% Calculate the tstat that corresp with pval of .05
alphaTStat = abs(tinv(.05/2,size(sizeFFTFullGroup,1)-1));

% Calculate the threshold that corresp with an FDR of .1
% Initially set the actual difference value to be high
differenceActual([1:10]) = 100;

% Create a range of threshold values
threshold = .0001:.0001:.1;
numSig = zeros(size(sizeFFTFullGroup,2),length(threshold),3);

% Loop through a range of threshold values to find the one that is
% closest to an FDR of .1 (threshold at which the ratio of expected FA's
% to number of significant electrodes is .1)
for i=1:size(sizeFFTFullGroup,2)-5   % Loop through all conditions
    for j=1:length(threshold)
        
        for k=1:3   % For each of the 3 harmonics
            % loop through for all the electrodes
            for z=1:size(sizeFFTFullGroup,3)
                
                % Calculate the tval that corresponds to the threshold that is set
                [S, P(i,j,z,k), CI, T{i,j,z,k}] = ttest(sizeFFTFullGroupFreqAve(:,i,z,k),0,threshold(j));
                
                % How many electrodes are sig at each threshold
                % If the the pval is less than the threshold count up
                if P(i,j,z,k) < threshold(j)
                    numSig(i,j,k) = numSig(i,j,k) + 1;
                end
            end
        end
        
        % Calculate the expected number of false positives due to chance at the
        % threshold given
        expectedFA(i,j) = threshold(j)*size(sizeFFTFullGroupFreqAve,3);
        
        % Calculate the FDR q for the threshold chosen
        FDR(i,j) = expectedFA(i,j)/numSig(i,j);
        
        % Is the FDR for this threshold the closest to .1?
        differenceHolder = abs(FDR(i,j) - .1);
        if differenceHolder < differenceActual(i)
            differenceActual(i) = differenceHolder;
            closestThresh(i) = FDR(i,j);
            closestThreshP(i) = threshold(j);
            thresholdIdx(i) = j;
        end
    end
end

clear S P CI T

% Calculate the tstat that corresponds with the pval
for i=1:length(closestThreshP)
    thresholdTStat(i) = abs(tinv((closestThreshP(i)/2),size(sizeFFTFullGroupFreqAve,3)-1));
end

% Perform the ttest using participant data for each electrode.
for i=1:size(sizeFFTFullGroupFreqAve,2)-5
    
    for k=1:3   % Harmonics
        for j=1:size(sizeFFTFullGroupFreqAve,3)   % num of electrodes
            [S, P(i,j), CI, T{i,j}] = ttest(sizeFFTFullGroupFreqAve(:,i,j,k),0,.05);
        end
    end
    
    % Make an array of tvalues from the struct
    for j=1:size(T,2)
        tArray(i,j) = T{i,j}.tstat;
    end
    
    % Sort the tvals based on significance
    [pSorted(i,:), pIndex(i,:)] = sort(P(i,:),2,'ascend');
    tSorted(i,:) = tArray(i,pIndex(i,:));
    
%     h = figure();
%     bar(tSorted(i,:))
%     line([1,257],[alphaTStat,alphaTStat],'Color',[1 0 0])
%     line([1,257],[thresholdTStat(i),thresholdTStat(i)],'Color',[0 1 0])
%     title(sprintf('%s%d','Size Level ',i));
%     set(gca,'ylim',[-2,12])
%     ylabel('Test Statistic')
%    
%     % Save the figure and then close it
%     cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
%     savefig(h,sprintf('%s%d%s','Carrier_TTest_Size_Level_',i,'.fig'));
%     close(h)
%     cd ../../
end
levelCounter = 2:2:10;
for c = 1:5   % For each level
    subplot(5,2,levelCounter(c))
    hold on
    cMap = colormap(jmaColors('pval'));
    if ~individualColors
        colorIdx = 1:length(conditions);
    else
        colorIdx = c;
    end
    switch plotVal
        case {'p','pval','p-value'}
            cMapMin = 0;
            cMapMax = 1;
            valsToPlot = squeeze(sizeTCirc_p(condChoose(c,1),condChoose(c,2),:));
        case {'t','tval','t-value'}
            valsToPlot = squeeze(tArray(c,:))'; % plot t-stat
            cMapMax = 12; %ceil(max(max(valsToPlot(:,colorIdx))));
            cMapMin = 0;
        case 'mean'
            valsToPlot = abs(sizeTCirc_Z_est(condChoose(c,1),condChoose(c,2),:)); % plot vector-mean amplitude
            cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
            cMapMin = 0;
    end
    mrC.plotOnEgi(valsToPlot(:,1),[cMapMin,cMapMax],true,find(tArray(c,:)>thresholdTStat(c)),false,markerProps);
    
    % Count the number of significant electrodes for ori
    sizeSigElecCountSize(c) = length(find(tArray(c,:)<thresholdTStat(c)));
    
    set(gcf,'ColorMap',cMap);
    set(gca, 'Clim',[cMapMin,cMapMax]);
    title(sprintf('%s%d%s','Size Level ',c),'FontSize',12);
    
    text1 = sprintf('%s','o : significant electrodes at a');
    text(0,-15,text1,'FontSize',10,'HorizontalAlignment','center');
    text2 = sprintf('%s%.4f','FDR corrected threshold of ',closestThreshP(c));
    text(0,-19,text2,'FontSize',10,'HorizontalAlignment','center');
    hold off
    
    
end

% Save the figure and then close it
cd ./GroupResults/Group_results_60HzLP/   % From the data folder CD into group results
savefig(h,'Carrier_TTest_OriAndSize_Level_AllLevels_Topo.fig');
print(h,'Carrier_TTest_OriAndSize_Level_AllLevels_Topo.tif','-dtiffn');   % Save .tif
% close(h)
cd ../../

%% Look at the differences between 3Hz/5Hz att/unatt
for i=1:5   % Levels
    for j=1:3   % Harmonics
        oriFFTSelectAttGroupAveDiff(i,1,j,:) = oriFFTSelectAttGroupAve(i,1,1,j,:) - oriFFTSelectAttGroupAve(i,1,2,j,:);   % 3Hz att - 3Hz unatt
        oriFFTSelectAttGroupAveDiff(i,2,j,:) = oriFFTSelectAttGroupAve(i,2,1,j,:) - oriFFTSelectAttGroupAve(i,2,2,j,:);   % 5Hz att - 5Hz unatt
        
        sizeFFTSelectAttGroupAveDiff(i,1,j,:) = sizeFFTSelectAttGroupAve(i,1,1,j,:) - sizeFFTSelectAttGroupAve(i,1,2,j,:);   % 3Hz att - 3Hz unatt
        sizeFFTSelectAttGroupAveDiff(i,2,j,:) = sizeFFTSelectAttGroupAve(i,2,1,j,:) - sizeFFTSelectAttGroupAve(i,2,2,j,:);   % 5Hz att - 5Hz unatt
    end
end

figure()
subplot(1,2,1)
bar(squeeze(oriFFTSelectAttGroupAveDiff(1,2,1,elecSelect)))
subplot(1,2,2)
bar(squeeze(oriFFTSelectAttGroupAveDiff(1,2,2,elecSelect)))

% Plot the differences
% Ori
figure()
counter = 0;
for i=1:5
    for j=1:3
        counter=counter+1;
        subplot(3,5,counter)
        bar(squeeze(oriFFTSelectAttGroupAveDiff(i,1,j,:)),'g');
        hold on
        bar(squeeze(oriFFTSelectAttGroupAveDiff(i,2,j,:)),'r');
    end
end
% Size
figure()
counter = 0;
for i=1:5
    for j=1:3
        counter=counter+1;
        subplot(3,5,counter)
        bar(squeeze(sizeFFTSelectAttGroupAveDiff(i,1,j,:)),'g');
        hold on
        bar(squeeze(sizeFFTSelectAttGroupAveDiff(i,2,j,:)),'r');
    end
end

% Save group data
groupResultsDir = 'GroupResults/Group_results_60HzLP/';
% check to see if this file exists
if exist(groupResultsDir,'file')
else
    mkdir(groupResultsDir);
end
cd(sprintf('%s','./',groupResultsDir))

save('Group_FFT_Results','oriFFTSelectAttGroupAve','sizeFFTSelectAttGroupAve',...
    'oriFFTFullGroup','sizeFFTFullGroup','oriFFTFullAttGroupAve','sizeFFTFullAttGroupAve')

cd ../../








