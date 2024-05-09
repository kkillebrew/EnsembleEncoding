% batching the UNRraw script

subjs = {'CB','GC','GG','JV','KK','KM','LS','MG','NS'};
hems = {'left','right'};

nSubjs = length(subjs);

for s = 1:nSubjs
    this_subj = subjs{s};
    for h = 1:2
        
        this_hem = hems{h};
        
        [TC CB] = UNR_rawTC(this_subj,1:8,{'V1v','V1d','V2v','V2d','V3v','V3d'},this_hem,{'tstat' 1.96},'exp_reg','flash','output_tail','flash_fig3');
        %[TC CB] = UNR_rawTC(this_subj,1:8,{'hV4','VO1','VO2','PHC1','PHC2','LO1','LO2','TO1','TO2','V3a','V3b','IPS0','IPS1','IPS2','IPS3','IPS4','IPS5'},this_hem,{'tstat' 1.96},'exp_reg','flash','output_tail','otherROIs');
        
        %[TC CB] = UNR_rawTC_strip(this_subj,1:8,{'V1vs','V1ds','V2vs','V2ds','V3vs','V3ds'},this_hem,{'tstat' 1.98},'exp_reg','flash','output_tail','comb_flash_strip');
        %[TC CB] = UNR_rawTC_control(this_subj,1:8,{'V1v','V1d','V2v','V2d','V3v','V3d'},this_hem,{'tstat' 1.98},'exp_reg','flash','output_tail','flash_control');
    end
end