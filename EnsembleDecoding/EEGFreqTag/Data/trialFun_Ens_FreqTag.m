% Trialfun function for Frequency Tagging

function [trl, event] = trialFun_Ens_FreqTag(cfg)

%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events
%hdr        = ft_read_header(cfg.headerfile);
event = ft_read_event(cfg.headerfile);

%% from here on it becomes specific to the experiment and the data format
% for the events of interest, find the sample numbers (these are integers)
% for the events of interest, find the trigger values (these are strings in the case of BrainVision)

EVsample   = [event.sample]';
% EVsample(1,:) = [];
EVvalue    = {event.value}';
% EVvalue(1,:) = [];

% Really only useful if you have other dins beisded DIN2 popping up (?)
l = find(strcmp(EVvalue,'DIN2'));
l = l';

task = cfg.info(:,1);

% This is specifically for ZZ in freq tag who missed a DIN after mid-way
% impedence check.
% Removes the trial for the missed DIN
if length(l) < length(cfg.info)
    missingDINIdx = find(strcmp('IBEG',EVvalue))-1;   % Find the first impedance DIN
    task(missingDINIdx) = [];
end

PreTrig   = 0;   % No baseline here, just the calculated offset
PostTrig  = 19999;

%all_trials = 1:length(task);

begsample = EVsample(l) - PreTrig;
endsample = EVsample(l) + PostTrig;

offset = (-6*ones(size(endsample)));   % Just set to 0 and implement the offset in the actual segment

%% the last part is again common to all trial functions
% return the trl matrix (required) and the event structure (optional)
trl = [begsample endsample offset task];

end % function
