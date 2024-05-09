% Calls from 'ensLoadData'. Load in another data file to fill in all the structs to use w/ fake data.
% Perform everything up to the ft_preprocessing command and send 

cd ../../
ensDataStructEEG = ensLoadData('VEPEEG','KK');
cd ./'EEG VEP'/Data/

%% Define trial info
%trialfun function segments data
% CFG - configure data
cfg = [];
cfg.trialfun = 'trialFun_Ens_VEP';
cfg.dataset = sprintf('%s%s',ensDataStructEEG.rawdataVEPEEGPath{m},'.mff');   % Raw EEG data file
cfg.headerfile = sprintf('%s%s',ensDataStructEEG.rawdataVEPEEGPath{m},'.mff');  % Same thing
cfg.datafile = sprintf('%s%s',ensDataStructEEG.rawdataVEPEEGPath{m},'.mff');   % Same thing

%Store info containing category info in cfg
if m==1
    cfg.info = ensDataStructEEG.info(1:length(ensDataStructEEG.info)/2,:);   % Indices for you conditions 1 by numtrials
elseif m==2
    cfg.info = ensDataStructEEG.info(length(ensDataStructEEG.info)/2+1:end,:);   % Indices for you conditions 1 by numtrials
end
%define trial function
% Calls trialfun here
cfg = ft_definetrial(cfg);   % Define each trial based on behavioral data; define start/end/offset

%% Load/Segment EEG data/Reref/Filter
% Specify certain preprocesisng params
cfg.continuous = 'yes';

%rereference to avergae ref
cfg.reref         = 'yes';   % Reref to average
cfg.refchannel    = {'all'};

%bandpass filter .5-50
cfg.bpfilter      =  'yes';
cfg.bpfreq    =    [59 .5];

%Load data
data = ft_preprocessing(cfg);