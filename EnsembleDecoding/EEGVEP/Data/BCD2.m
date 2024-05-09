function [bad_chans] = BCD2(n)

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



%disp(j)
% take mean and std
for k = 1:trials
    for i = 1:time
        eeg_mean{k,1}(1,i) = mean(eeg_trials{k,1}(:,i));
        eeg_std{k,1}(1,i) = std(eeg_trials{k,1}(:,i));
    end
end

for k= 1:trials
    for i = 1:chans
        [p l] = findpeaks(eeg_trials{k,1}(i,:),'minpeakdistance',20);
        for j = 1:length(p)
            if abs(p(j)) > abs(eeg_std{k,1}(1,l(j))*thresh)
                my_var{k,1}(i,j) = 1;
            else
                my_var{k,1}(i,j) = 0;
            end
            
        end
    end
end


for k = 1:length(my_var)
    for i = 1:chans
        if length(find(my_var{k,1}(i,:))) > 30;
            bad_chan_std{k,1}(i,1) = 1;
        else
            bad_chan_std{k,1}(i,1) = 0;
            
        end
        
    end
end


for k = 1:length(bad_chan_std)
    for i = 1:chans
        
        if sum(bad_chan_std{k,1}(:,1)) == 0;
            bad_chans_std2{k,1} = [];
        else
            bad_chans_std2{k,1}(1,:) = find(bad_chan_std{k,1}(:,1));
        end
    end
end



for k =1:trials
    for i = 1:chans
        for z = 1:length(moving_ac_tp)
            temp_ch_array{k,1}(i,z) = mean(eeg_trials{k,1}(i,moving_ac_tp(z):moving_ac_tp(z)+49));
            
        end
    end
    
end



for k = 1:trials
    for i = 1:chans
        if max(temp_ch_array{k,1}(i,:)) - min(temp_ch_array{k,1}(i,:)) > 100;
            temp_ch_array2{k,1}(i) = 1;
        else
            temp_ch_array2{k,1}(i) = 0;
            
        end
        
    end
end

for k = 1:trials
    bad_chans2{k,1}(1,:) = find(temp_ch_array2{k, :});
end



for k = 1:trials
    if isempty(bad_chans_std2{k,1}) == 1 && isempty(bad_chans2{k,1}) == 1
        bad_chan_all{k,1} = [];
    elseif isempty(bad_chans_std2{k,1}) == 0 && isempty(bad_chans2{k,1}) == 1
        bad_chan_all{k,1}(1,:) = unique(bad_chans_std2{k,1}(1,:));
    elseif isempty(bad_chans_std2{k,1}) == 1 && isempty(bad_chans2{k,1}) == 0
        bad_chan_all{k,1}(1,:) = unique(bad_chans2{k,1}(1,:));
    else
        bad_chan_all{k,1}(1,:) = unique([bad_chans2{k,1}(1,:) bad_chans_std2{k,1}(1,:)]);
    end
end




for k = 1:length(bad_chan_all)
    length_bc(k) = length(bad_chan_all{k,1});
end

length_bc = max(length_bc);

bad_chans3 =cell(trials,1);
[bad_chans3{:}] = deal(zeros(1,length_bc));


for k = 1:length(n)
    if isempty(bad_chan_all{k,1}) == 0
        disp(k)
        bad_chans3{k,1}(1:length(bad_chan_all{k,1}(1,:))) = bad_chan_all{k,1}(1,:);
    elseif isempty(bad_chan_all{k,1}) == 1
        
    end
end

unique_chans = nonzeros(unique(cell2mat(bad_chans3)));


for i = 1:length(unique_chans)
    xx(i) =    length(find(cell2mat(bad_chans3) == unique_chans(i)));
end
num_bad_chans = xx';

for i = 1:length(num_bad_chans)
    if num_bad_chans(i) > ceil(trials*thresh2)
        badch_final(1,i) = unique_chans(i);
    else
        badch_final(1,i) = 0;
    end
    
end

badch_final = nonzeros(badch_final);


for k = 1:length(bad_chan_all)
    
    if isempty(bad_chan_all{k,1})
        bad_chan_all4{k,1}(1,:) = 0;
    else
        bad_chan_all4{k,1}(1,:) = unique([bad_chan_all{k,1}(1,:), badch_final']);
    end
end


bad_ch_count = deal(zeros(chans,trials));

for l = 1:chans
    for i = 1:trials
        if ismember(l,bad_chan_all4{i,:})
            bad_ch_count(l,i) = 1;
        else
            bad_ch_count(l,i) = 0;
        end
    end
end


for i = 1:chans
    bad_ch_count2(i) =  length(find(bad_ch_count(i,:)));
    
end

bad_chans_multiple = find(bad_ch_count2 >= 250);

badchans = bad_chan_all4;

for i = 1:length(badchans)
    this_length =  size(badchans{i,1});
    for z = 1:length(bad_chans_multiple)
        if sum(badchans{i,1}(1,:)) == 0
            badchans{i,1}(1,z) = bad_chans_multiple(1,z);
        else
            badchans{i,1}(1,(this_length(2)+z))= bad_chans_multiple(1,z);
        end
        
    end
    bad_chansALL{i,1}(1,:) = unique(badchans{i,1}(1,:));
    
end




for i = 1:length(bad_chansALL)
    num_bad(i) = length(bad_chansALL{i,1}(:));
end

disp('Average number of bad channels per trial:')
disp(ceil(mean(num_bad)))

bad_chans = bad_chansALL;

end



