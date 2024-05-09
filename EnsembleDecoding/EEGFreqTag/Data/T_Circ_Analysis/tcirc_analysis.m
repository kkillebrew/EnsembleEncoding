function [vectorMeans, ci_radii, p_vals, t2circ_stat] = tcirc_analysis(EEGfileName, condIdx, plotData)
% CHANGE TO FIT YOUR CODE - RUN THIS FUNCTION

%Set the Frequency 
freqset = 15;

%Set the Harmonic
harmonic = 1;

%Set number of electrodes
electrodes = 256;

%Set Alpha
alpha = 0.001;

%Set Values
values = 't'; % 't' = t-vals; 'p' = p-vals; 'mean' = mean vals

%% GENERATE PATHS FOR T-CIRC
codeFolder = '/Users/clab/Google Drive/Lab Projects/Today''s Stuff/Dissertation Stuff/Experiments/EEG Freq Tag/Data/';
addpath(genpath(sprintf('%s/git/mrC',codeFolder)));
addpath(genpath(sprintf('%s/T_Circ_Analysis',codeFolder)));

if nargin < 3
    plotData = true;
else
end

if nargin < 2
    condIdx = false;
else
end
%% THIS IS THE SETTING IF YOU JUST LOAD IN THE FILES
% fileData = load(EEGfileName,'*mff');
% fileData = load(EEGfileName,'checkers_oomph_TL_2_20180810_034243_fil_seg_blc_bcr_refmff');

fileData = load('checkers_oomph_TL_2_20180810_034243_fil_seg_blc_bcr_ref','checkers_oomph_TL_2_20180810_034243_fil_seg_blc_bcr_refmff');
fieldName = fieldnames(fileData);
timeData = fileData.(fieldName{:});



%timeData = EEGfileName; %  this was changed to preform t-circs from the initial script 
%  comment this if you are trying to run individual subject analysis
stimFreq = freqset;
nHarm = harmonic;
nElec = electrodes;
n_alpha = alpha;
plotVal = values;
individualColors = true;
timeData = cat(3,timeData{1,:});
timeData = timeData(1:nElec,:,:);

if ~condIdx
    condIdx = ones(1, size(timeData,3));
else
end

conditions = unique(condIdx);
conditions = conditions(conditions~=0);

%% compute t-circ
for c = 1:length(conditions)
    freqVals = fft(timeData(:,:,condIdx==c),[],2);
    freq_axis = 0:.1:1000-.1;
    freq_idx = freq_axis == (stimFreq * nHarm);
    
    harmData = squeeze(freqVals(:,freq_idx,:));
    
    nElectrodes = size(harmData,1);
    
    [vectorMeans(:,c), ci_radii(:,c), p_vals(:,c), t2circ_stat(:,c)] = t2circ_1tag(harmData,n_alpha);
end

%% PLOT THE DATA
close all;
if plotData
    markerProps = {'facecolor','none','edgecolor','none','markersize',10,'marker','o','markerfacecolor','none','MarkerEdgeColor','k','LineWidth',1};
    for c = 1:length(conditions)
        figure;
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
                valsToPlot = p_vals;
            case {'t','tval','t-value'}
                valsToPlot = t2circ_stat; % plot t-stat
                cMapMax = 5; %ceil(max(max(valsToPlot(:,colorIdx))));
                cMapMin = 0;
            case 'mean'
                valsToPlot = abs(vectorMeans); % plot vector-mean amplitude
                cMapMax = ceil(max(max(valsToPlot(:,colorIdx)))/100)*100;
                cMapMin = 0;
        end
        mrC.plotOnEgi(valsToPlot(:,c),[cMapMin,cMapMax],true,find(p_vals(:,c)<n_alpha),false,markerProps);
        colormap(gca,cMap);
        set(gca, 'Clim',[cMapMin,cMapMax]);
        hold off
    end
else
end
end

%% IF JUST RUNNING CODE - EXAMPLE OF MAKING THIS WORK ON INDIVIDUAL SUBJECTS

%%% LOAD YOUR BEHAV DATA
%load('/Users/clab/Documents/Taissa/Research/Experiments/Double_Drift_DD/Experiments/Pilot_Remastered/data/behavioral/GF/P3_T1_GF_061218.mat')

%%% CREATE TRIAL TYPES
% %Double Drift Vertical 
% dd_vert_vert = (rawdata(:,1) ==1 & rawdata(:,3)== 1);
% %Double Drift Horizontal
% dd_horz_horz = (rawdata(:,1) == 2 & rawdata(:,3)== 2);
% %Single Drift Vertical 
% sd_vert_vert = (rawdata(:,1) == 3 & rawdata(:,3)== 1);
% %Single Drift Horizontal
% sd_horz_horz = (rawdata(:,1) == 4 & rawdata(:,3)== 2);

%%% ATTRIBUTE TRIAL TYPES
% nTrials = 40;
% condIdx = zeros(1, nTrials);
% 
% %Double Drift Vertical 
% condIdx(dd_vert_vert) = 1;
% %Double Drift Horizontal
% condIdx(dd_horz_horz) = 2;
% %Single Drift Vertical 
% condIdx(sd_vert_vert) = 3;
% %Single Drift Horizontal
% condIdx(sd_horz_horz) = 4;

%%% LOAD IN EEG DATA INSIDE THE TCIRC FUNCTION 
%%% (substitute the fileName with your data location in comp)
% tcirc_analysis(('/Users/clab/Documents/Taissa/Research/Experiments/Double_Drift_DD/Experiments/Pilot_Remastered/data/good_trials_labeler/GF_fil_seg_blc_bcr_ref.mat'),condIdx);

%%% ****DONT FORGET!!!!****
%%% UNCOMMENT IN THE TCIRC FUNCTION: THIS IS THE SETTING IF YOU JUST LOAD IN THE FILES

