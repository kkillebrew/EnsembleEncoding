function [stimtimes] = UNR_ExtractStimTimes(subj_initials,analysis_type)
% function to extract stimtimes from textfiles that were used as input to
% 3dDevconvolve


% the following assumes all stim_times files are located in
% $SUBJ/scripts/stim_times/ and are called $REGNAME_times.1D
regnames = {'ori11' 'ori11' 'ori11' 'ori11' 'ori11' 'ori11' 'ori11' 'ori11'...
    'ori11' 'ori11' 'ori11' 'ori11' 'ori11' 'ori11' 'ori11' 'ori11'};
for rncell = regnames
    rn = rncell{1}; % convert to string
    this_file = ['../' subj_initials '/scripts/stim_times/' rn '_times.1D'];
    first_block_trial = importdata(this_file);  
    
    % hack to get rid of * at the end of each line
    for ii = 1:size(first_block_trial,1)
        %if strcmpi(first_block_trial{ii}(end-1:end),' *')
        %    first_block_trial{ii}(end-1:end) = [];
        %end
        first_block_trial{ii} = [str2double(first_block_trial{ii}(1:2)) str2double(first_block_trial{ii}(4:6))];
    end
    
    
%    tmp = regexp(analysis_type,'^.*wise','match');
%    switch tmp{1}
%        case 'blockwise'
            stimtimes.(rn) = first_block_trial;
%        case 'trialwise'
%            stimtimes.(rn) = cellfun(@(x) x:6:x+30,first_block_trial,'UniformOutput',false);
%        otherwise
%            error('undefined analysis_type (%s)',analysis_type)
%    end
end


