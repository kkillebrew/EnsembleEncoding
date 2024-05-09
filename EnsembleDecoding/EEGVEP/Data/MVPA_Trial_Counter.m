% Uses the conditions file, from the VEP MVPA script, which gives how many
% trials per condition you have (after preprocessing and subaveraging).

for i=1:length(conditions)
        
    trialCounter(i,1) = length(conditions{i}.ori1.trial);
    trialCounter(i,2) = length(conditions{i}.ori2.trial);
    trialCounter(i,3) = length(conditions{i}.ori3.trial);
    trialCounter(i,4) = length(conditions{i}.ori4.trial);
    trialCounter(i,5) = length(conditions{i}.ori5.trial);
    
    trialCounter(i,6) = length(conditions{i}.size1.trial);
    trialCounter(i,7) = length(conditions{i}.size2.trial);
    trialCounter(i,8) = length(conditions{i}.size3.trial);
    trialCounter(i,9) = length(conditions{i}.size4.trial);
    trialCounter(i,10) = length(conditions{i}.size5.trial);
        
end