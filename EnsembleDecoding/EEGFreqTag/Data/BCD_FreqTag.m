function [bad_chans] = BCD_FreqTag(n)

plotBadChannels = 0;

eeg_trials = n;

eeg_trials = eeg_trials';

moving_av = 50;
amp_thresh = 200;


%eeg_trials = data.trial;
% eeg_trials = eeg_trials';

time = size(eeg_trials{1,1}(1,:),2);
chans = 256;
trials = length(eeg_trials);
ch_array = 1:chans;

moving_ac_tp = 1:moving_av:time;
thresh = 4;
thresh2 = .3;
%std above mean

% number of itertaions %% note: after each iteration the bad channels from
% the previous iteration are removed. Thus, more itertaions = more
% stringent BCD
% iterations = 1;
%
% %preallocate file for storing bad channel info
% bad_chans =cell(trials,2);
% [bad_chans{:}] = deal(0);
%
% thresh_1 = 5; %how many STDs to search within for course pass
% thresh_2 = .5; %if channel is bad for more than thresh_2 (%), mark bad


%% First find and remove super crazy electrodes that will throw off the mean/std 
%disp(j)
% For every trial at every time point take the mean and std across
% electrodes
for k = 1:trials
    for i = 1:time
        eeg_mean(k,i) = mean(eeg_trials{k,1}(:,i));
        eeg_std(k,i) = std(eeg_trials{k,1}(:,i));
    end
end


for k= 1:trials
    for i = 1:chans
        % Find the peaks in each waveform (all trials for all elecs), peaks
        % defined as +20 in either direction away from mean
        [p{k,i}(1,:), l{k,i}(1,:)] = findpeaks(eeg_trials{k,1}(i,:),'minpeakdistance',20);
        
        % For every peak, compare the peak w/ the standard deviation of all
        % electrodes in that trial. 
        for j = 1:length(p{k,i})
            % If the absolute value of the peak of that waveform is
            % greaterl than 4 standard deviations away from 0, mark it.
            if abs(p{k,i}(j)) > 100
                my_var{k,i}(j) = 1;
            else
                my_var{k,i}(j) = 0;
            end
        end
    end
end


% If there are more than 20 points where the waveform is greater than the
% rest of the electrodes mark it as a bad channel for that trial. 
for k = 1:size(my_var,1)
    for i = 1:size(my_var,2)
        if length(find(my_var{k,i})) > 20
            bad_chan_std(k,i) = 1;
        else
            bad_chan_std(k,i) = 0;
        end
    end
end

% If a channel is bad on >40% of trials (40 trials) mark it bad for all
% trials (less stringent/higher threshold than below).
totalBadCoarse = sum(bad_chan_std);
for k=1:size(totalBadCoarse,2)
    if totalBadCoarse(k) >=40
        for i=1:size(bad_chan_std,1)
            bad_chan_std(i,k) = 1;
        end
    end
end

% Keep track of the number of the channels that are bad on each trial
for k = 1:size(bad_chan_std,1)
    for i = 1:size(bad_chan_std,2)
        if sum(bad_chan_std(k,:)) == 0
            bad_chans_std2{k} = [];
        else
            bad_chans_std2{k}(1,:) = find(bad_chan_std(k,:));
        end
    end
end

% Make a new array to keep track of what electrodes to use in fine pass BCD
for k=1:size(bad_chans_std2,2)
    if isempty(bad_chans_std2{k})
        good_chans{k} = 1:257;
    else
        good_chans{k} = 1:257;
        for i=1:length(bad_chans_std2{k})
            good_chans{k}(good_chans{k} == bad_chans_std2{k}(i)) = [];
        end
    end
end

% Plot trials w/ and w/out bad channels as well as bad channels
% Find the top 5 most noisy segments
% sum_bad_chan = sum(bad_chan_std,2);
% [topBadChan topBadChanIdx] = maxk(sum_bad_chan,7);
% for i=1:length(topBadChanIdx)
%    
%     figure('Name',sprintf('%s%d','Course Pass Trial: ',i))
%     subplot(1,3,1)
%     plot(eeg_trials{topBadChanIdx(i)}(:,:)')
%     hold on
%     title('All Channels')
%     
%     subplot(1,3,2)
%     plot(eeg_trials{topBadChanIdx(i)}(good_chans{k},:)')
%     hold on
%     title('Good Channels')
%     
%     subplot(1,3,3)
%     plot(eeg_trials{topBadChanIdx(i)}(bad_chans_std2{topBadChanIdx(i)},:)')
%     hold on
%     title('Bad Channels')
%     
% end

%% Fine pass BCD
% Now that outlier channels are removed, we can take a more accurate moving
% window average.
% Average over a moving window (defined by moving_ac_tp and moving_ac)
for k =1:trials
    for i = 1:length(good_chans{k})
        for z = 1:length(moving_ac_tp)   % Average over segs of 50ms
            % I think we want to exclude the elecs from course pass?
            temp_ch_array{k}(good_chans{k}(i),z) = mean(eeg_trials{k,1}(good_chans{k}(i),moving_ac_tp(z):moving_ac_tp(z)+49));   
        end
    end
end

% Look at the min/max points in a given waveform and if they are greater
% than 200 count it as a bad channel
for k = 1:trials
    for i = 1:length(good_chans{k})
        if max(temp_ch_array{k}(good_chans{k}(i),:)) - min(temp_ch_array{k}(good_chans{k}(i),:)) > 200
            temp_ch_array2{k}(good_chans{k}(i)) = 1;
        else
            temp_ch_array2{k}(good_chans{k}(i)) = 0;
        end
    end
end

% Add these bad electrodes to the list from the coarse pass
for k = 1:trials
    bad_chans2{k} = find(temp_ch_array2{k});
end

% Combine all bad cannels from fine and coarse pass
for k = 1:trials
    if isempty(bad_chans_std2{k}) == 1 && isempty(bad_chans2{k}) == 1
        bad_chan_all{k} = [];
    elseif isempty(bad_chans_std2{k}) == 0 && isempty(bad_chans2{k}) == 1
        bad_chan_all{k}(1,:) = unique(bad_chans_std2{k}(1,:));
    elseif isempty(bad_chans_std2{k}) == 1 && isempty(bad_chans2{k}) == 0
        bad_chan_all{k}(1,:) = unique(bad_chans2{k}(1,:));
    else
        bad_chan_all{k}(1,:) = unique([bad_chans2{k}(1,:) bad_chans_std2{k}(1,:)]);
    end
end

% Re-plot the worst segments (from end of coarse pass above)
if plotBadChannels == 1
    clear sum_bad_chan topBadChan topBadChanIdx
    sum_bad_chan = sum(bad_chan_std,2);
    [topBadChan topBadChanIdx] = maxk(sum_bad_chan,7);
    for i=1:length(topBadChanIdx)
        
        figure('Name',sprintf('%s%d','Course Pass Trial: ',i))
        subplot(1,3,1)
        plot(eeg_trials{topBadChanIdx(i)}(:,:)')
        hold on
        title('All Channels')
        
        subplot(1,3,2)
        plot(eeg_trials{topBadChanIdx(i)}(good_chans{k},:)')
        hold on
        title('Good Channels')
        
        subplot(1,3,3)
        plot(eeg_trials{topBadChanIdx(i)}(bad_chans_std2{topBadChanIdx(i)},:)')
        hold on
        title('Bad Channels')
        
    end
end

%% Display and format arrays
% Number of bad channels
for k = 1:length(bad_chan_all)
    length_bc(k) = length(bad_chan_all{k});
end

% Convert from cell array to matrix.
% It takes a copy of bad_chan_all, but makes each cell the same size by
% filing in the rest of the cells with 0s. So bad_chans3 = bad_chan_all,
% except each cell has equal number of cells which is = to max number of
% bad channels across all trials.
length_bc = max(length_bc);
bad_chans3 =cell(trials,1);
[bad_chans3{:}] = deal(zeros(1,length_bc));
for k = 1:length(eeg_trials')
    if isempty(bad_chan_all{k}) == 0
        disp(k)   % Display the trials that contain at least 1 bad channel
        bad_chans3{k}(1:length(bad_chan_all{k}(1,:))) = bad_chan_all{k}(1,:);   
    elseif isempty(bad_chan_all{k}) == 1
        
    end
end

% Find report all unique channels that are bad across all trials
bad_chans3_mat = cell2mat(bad_chans3);
unique_chans = nonzeros(unique(bad_chans3_mat));

% Determine how often each channel is bad (use num_bad_chans in tandem w/
% unique_chans to determine which electrodes were bad and how many trials
% were they bad in.
if isempty(unique_chans)
    xx = [];
else
    for i = 1:length(unique_chans)
        xx(i) =    length(find(bad_chans3_mat == unique_chans(i)));
    end
end
num_bad_chans = xx';

% Find channels that are > than the threshold for % of bad trials.
if isempty(num_bad_chans)
    badch_final = [];
else
    for i = 1:length(num_bad_chans)
        if num_bad_chans(i) > ceil(trials*thresh2)   % If the channel is bad in > than 30% of trials
            badch_final(i) = unique_chans(i);        % mark the channel number for removal.
        else
            badch_final(i) = 0;
        end
    end
end
badch_final = nonzeros(badch_final);   % Unique channels that need removal

% Make a new array (bad_chan_all4) that marks channels as bad in all
% trials, that are found to be bad in more than 30% of trials.
for k = 1:length(bad_chan_all)
    if isempty(bad_chan_all{k})
        bad_chan_all4{k}(1,:) = 0;
    else
        bad_chan_all4{k}(1,:) = unique([bad_chan_all{k}(1,:), badch_final']);
    end
end

% Make matrix that marks all electrodes as either good/bad for every trial
bad_ch_count = deal(zeros(chans,trials));
for l = 1:chans
    for i = 1:trials
        if ismember(l,bad_chan_all4{i})
            bad_ch_count(l,i) = 1;
        else
            bad_ch_count(l,i) = 0;
        end
    end
end

% Count the number of trials each electrode was bad in
for i = 1:256
    bad_ch_count2(i) =  length(find(bad_ch_count(i,:)));
end

% Find any outliers in terms of # bad channels
bad_chans_multiple = find(bad_ch_count2 >= 90);

% Update bad channel to exclude the outliers
badchans = bad_chan_all4;
for i = 1:length(badchans)   % Number of trials
    this_length =  size(badchans{i});   % Number of bad channels per trial
    for z = 1:length(bad_chans_multiple)
        if sum(badchans{i}(1,:)) == 0
            badchans{i}(1,z) = bad_chans_multiple(1,z);
        else
            badchans{i}(1,(this_length(2)+z))= bad_chans_multiple(1,z);
        end
    end
    bad_chansALL{i}(1,:) = unique(badchans{i}(1,:));
end

% Create final count and final bad chan array
for i = 1:length(bad_chansALL)
    num_bad(i) = length(bad_chansALL{i}(1,:));
end
disp('Average number of bad channels per trial:')
disp(ceil(mean(num_bad)))
bad_chans = bad_chansALL;

end