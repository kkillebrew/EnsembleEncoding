clear all
close all

subjects = {'GG','KK','IB','MW','MH','TL','CP'};
%5279
%

block_order =  [1 2 3 4 2 3 4 1 3 4 1 2 4 1 2 3];
num_blocks = 96;
trials_oer_block = 15;
bob = 6:6:96;
bob2 = 1:6:96;





for k = 1:16;
    
    my_mat(bob2(k):bob(k)) = block_order(k);
    
end



bird = find(my_mat == 1)';
isct = find(my_mat == 2)';
grsp = find(my_mat == 3)';
tool = find(my_mat == 4)';

animate = find(my_mat == 1 | my_mat ==2)';
inanimate = find(my_mat == 3 | my_mat ==4)';



% I think, this loop loads in data then randomly splits categories into
% 2 groups, before averaging them togethere.
for i = 1:length(subjects)
    
    
    
    load(sprintf('%s%s',subjects{i},'.mat'))
    
    switch i
        case 1
            data = GG_CAT_20160219_035025_fil_seg_bcr_refmff;
        case 2
            data = KK_20160223_015600_fil_seg_bcr_refmff;
        case 3
            data = IB_20160224_114715_fil_seg_bcr_refmff;
        case 4
            data = MW_20160226_125135_fil_seg_bcr_refmff;
        case 5
            data = MH_20160226_034601_fil_seg_bcr_refmff;
        case 6
            data = TL_20160229_122727_fil_seg_bcr_ref_1mff;
        case 7
            data = CP_20160310_111006_fil_seg_bcr_refmff;
    end
    
    data = data';
    data(:,2) = [];
    
    if i == 3
        temp_mat(1:5,1) = data([55 56 57 59 60],1);
        temp_mat_av = {mean(cat(3,temp_mat{:}),3)};
        
        temp_data = data(58:95,1);
        data(58:95) = [];
        
        data(58,1) = temp_mat_av;
        data(59:96) = temp_data;
    end
    
    
    check_length = length(data);
    
    if check_length ~= 96
        
        disp(sprintf('%s%s%s%s%s','warning: check the number of segments. Subject ',subjects{i},' has ', num2str(check_length), ' segements'));
        %KbWait
        
    end
    
    split_data = randperm(24);
    half_1 = split_data(1:12);
    half_2 = split_data(13:24);
    
    
    bird_data(:,i) = data(bird);
    isct_data(:,i) = data(isct);
    grsp_data(:,i) = data(grsp);
    tool_data(:,i) = data(tool);
    
    bird_data1(:,i) = bird_data(half_1,i);
    bird_data2(:,i) = bird_data(half_2,i);
    
    isct_data1(:,i) = isct_data(half_1,i);
    isct_data2(:,i) = isct_data(half_2,i);
    
    grsp_data1(:,i) = grsp_data(half_1,i);
    grsp_data2(:,i) = grsp_data(half_2,i);
    
    tool_data1(:,i) = tool_data(half_1,i);
    tool_data2(:,i) = tool_data(half_2,i);
    
    
    
    bird_av(:,i) = {mean(cat(3,bird_data{:,i}),3)};
    isct_av(:,i) = {mean(cat(3,isct_data{:,i}),3)};
    grsp_av(:,i) = {mean(cat(3,grsp_data{:,i}),3)};
    tool_av(:,i) = {mean(cat(3,tool_data{:,i}),3)};
    
    
    bird_av1(:,i) = {mean(cat(3,bird_data1{:,i}),3)};
    bird_av2(:,i) = {mean(cat(3,bird_data2{:,i}),3)};
    
    isct_av1(:,i) = {mean(cat(3,isct_data1{:,i}),3)};
    isct_av2(:,i) = {mean(cat(3,isct_data2{:,i}),3)};
    
    grsp_av1(:,i) = {mean(cat(3,grsp_data1{:,i}),3)};
    grsp_av2(:,i) = {mean(cat(3,grsp_data2{:,i}),3)};
    
    tool_av1(:,i) = {mean(cat(3,tool_data1{:,i}),3)};
    tool_av2(:,i) = {mean(cat(3,tool_data2{:,i}),3)};
    
    
    
    ani_data(:,i) = data(animate);
    inani_data(:,i) = data(inanimate);
    
    
    ani_av(:,i) = {mean(cat(3,ani_data{:,i}),3)};
    inani_av(:,i) = {mean(cat(3,inani_data{:,i}),3)};
    
    
    
end


% This loop performs the FFT.
for k = 1:length(subjects)
    for i = 1:257
        bird_fft{1,k}(i,:) = abs(fft(bird_av{1,k}(i,:)));
        isct_fft{1,k}(i,:) = abs(fft(isct_av{1,k}(i,:)));
        tool_fft{1,k}(i,:) = abs(fft(tool_av{1,k}(i,:)));
        grsp_fft{1,k}(i,:) = abs(fft(grsp_av{1,k}(i,:)));
        % %
        %
        %         fft.bird{1,k}(i,:) = abs(fft(bird_av{1,k}(i,:)));
        %         fft.isct{1,k}(i,:) = abs(fft(isct_av{1,k}(i,:)));
        %         fft.grsp{1,k}(i,:) = abs(fft(grsp_av{1,k}(i,:)));
        %        fft.tool{1,k}(i,:) = abs(fft(tool_av{1,k}(i,:)));
        
        %
        ani_fft{1,k}(i,:) = abs(fft(ani_av{1,k}(i,:)));
        inani_fft{1,k}(i,:) = abs(fft(inani_av{1,k}(i,:)));
        %
        %
        bird_fft1{1,k}(i,:) = abs(fft(bird_av1{1,k}(i,:)));
        bird_fft2{1,k}(i,:) = abs(fft(bird_av2{1,k}(i,:)));
        
        isct_fft1{1,k}(i,:) = abs(fft(isct_av1{1,k}(i,:)));
        isct_fft2{1,k}(i,:) = abs(fft(isct_av2{1,k}(i,:)));
        
        grsp_fft1{1,k}(i,:) = abs(fft(grsp_av1{1,k}(i,:)));
        grsp_fft2{1,k}(i,:) = abs(fft(grsp_av2{1,k}(i,:)));
        
        tool_fft1{1,k}(i,:) = abs(fft(tool_av1{1,k}(i,:)));
        tool_fft2{1,k}(i,:) = abs(fft(tool_av2{1,k}(i,:)));
        
        
    end
end

% Averaging the FFT's
group_av_fft.bird = {mean(cat(3,bird_fft{:}),3)};
group_av_fft.isct = {mean(cat(3,isct_fft{:}),3)};
group_av_fft.tool = {mean(cat(3,tool_fft{:}),3)};
group_av_fft.grsp = {mean(cat(3,grsp_fft{:}),3)};

group_av_fft.ani = {mean(cat(3,ani_fft{:}),3)};
group_av_fft.inani = {mean(cat(3,inani_fft{:}),3)};



group_av_fft.bird1 = {mean(cat(3,bird_fft1{:}),3)};
group_av_fft.bird2 = {mean(cat(3,bird_fft2{:}),3)};

group_av_fft.isct1 = {mean(cat(3,isct_fft1{:}),3)};
group_av_fft.isct2 = {mean(cat(3,isct_fft2{:}),3)};

group_av_fft.grsp1 = {mean(cat(3,grsp_fft1{:}),3)};
group_av_fft.grsp2 = {mean(cat(3,grsp_fft2{:}),3)};

group_av_fft.tool1 = {mean(cat(3,tool_fft1{:}),3)};
group_av_fft.tool2 = {mean(cat(3,tool_fft1{:}),3)};


% figure
% for i = 50:75
%     plot(ani_fft{1, 3}(i,1:500))
%     figure(i+1)
% end

%animate - inanimate/ animate + inanimate

%  for x = 1:length(subjects)
%     for a = 1:257
%
%
%     end
%  end


% Making the index values
for x = 1:length(subjects)
    for a = 1:257
        %animate - inanimate
        index_1{1,x}(a,1) = (ani_fft{1,x}(a,91) - inani_fft{1,x}(a,91))/(ani_fft{1,x}(a,91) + inani_fft{1,x}(a,91));
        index_2{1,x}(a,1) = (ani_fft{1,x}(a,181) - inani_fft{1,x}(a,181))/(ani_fft{1,x}(a,181) + inani_fft{1,x}(a,181));
        index_3{1,x}(a,1) = (ani_fft{1,x}(a,271) - inani_fft{1,x}(a,271))/(ani_fft{1,x}(a,271) + inani_fft{1,x}(a,271));
        
        %tool - grsp
        index_1_inani{1,x}(a,1) = (tool_fft{1,x}(a,91) - grsp_fft{1,x}(a,91))/(tool_fft{1,x}(a,91) + grsp_fft{1,x}(a,91));
        index_2_inani{1,x}(a,1) = (tool_fft{1,x}(a,181) - grsp_fft{1,x}(a,181))/(tool_fft{1,x}(a,181) + grsp_fft{1,x}(a,181));
        index_3_inani{1,x}(a,1) = (tool_fft{1,x}(a,271) - grsp_fft{1,x}(a,271))/(tool_fft{1,x}(a,271) + grsp_fft{1,x}(a,271));
        
        
        %bird - insect
        index_1_ani{1,x}(a,1) = (bird_fft{1,x}(a,91) - isct_fft{1,x}(a,91))/(bird_fft{1,x}(a,91) + isct_fft{1,x}(a,91));
        index_2_ani{1,x}(a,1) = (bird_fft{1,x}(a,181) - isct_fft{1,x}(a,181))/(bird_fft{1,x}(a,181) + isct_fft{1,x}(a,181));
        index_3_ani{1,x}(a,1) = (bird_fft{1,x}(a,271) - isct_fft{1,x}(a,271))/(bird_fft{1,x}(a,271) + isct_fft{1,x}(a,271));
        
        
        
        %bird - insect
        index_1_ani1{1,x}(a,1) = (bird_fft1{1,x}(a,91) - isct_fft1{1,x}(a,91))/(bird_fft1{1,x}(a,91) + isct_fft1{1,x}(a,91));
        index_2_ani1{1,x}(a,1) = (bird_fft1{1,x}(a,181) - isct_fft1{1,x}(a,181))/(bird_fft1{1,x}(a,181) + isct_fft1{1,x}(a,181));
        index_3_ani1{1,x}(a,1) = (bird_fft1{1,x}(a,271) - isct_fft1{1,x}(a,271))/(bird_fft1{1,x}(a,271) + isct_fft1{1,x}(a,271));
        
        %bird - insect
        index_1_ani2{1,x}(a,1) = (bird_fft2{1,x}(a,91) - isct_fft2{1,x}(a,91))/(bird_fft2{1,x}(a,91) + isct_fft2{1,x}(a,91));
        index_2_ani2{1,x}(a,1) = (bird_fft2{1,x}(a,181) - isct_fft2{1,x}(a,181))/(bird_fft2{1,x}(a,181) + isct_fft2{1,x}(a,181));
        index_3_ani2{1,x}(a,1) = (bird_fft2{1,x}(a,271) - isct_fft2{1,x}(a,271))/(bird_fft2{1,x}(a,271) + isct_fft2{1,x}(a,271));
        
        
        %tool - grsp
        index_1_inani1{1,x}(a,1) = (tool_fft1{1,x}(a,91) - grsp_fft1{1,x}(a,91))/(tool_fft1{1,x}(a,91) + grsp_fft1{1,x}(a,91));
        index_2_inani1{1,x}(a,1) = (tool_fft1{1,x}(a,181) - grsp_fft1{1,x}(a,181))/(tool_fft1{1,x}(a,181) + grsp_fft1{1,x}(a,181));
        index_3_inani1{1,x}(a,1) = (tool_fft1{1,x}(a,271) - grsp_fft1{1,x}(a,271))/(tool_fft1{1,x}(a,271) + grsp_fft1{1,x}(a,271));
        
        %tool - grsp
        index_1_inani2{1,x}(a,1) = (tool_fft2{1,x}(a,91) - grsp_fft2{1,x}(a,91))/(tool_fft2{1,x}(a,91) + grsp_fft2{1,x}(a,91));
        index_2_inani2{1,x}(a,1) = (tool_fft2{1,x}(a,181) - grsp_fft2{1,x}(a,181))/(tool_fft2{1,x}(a,181) + grsp_fft2{1,x}(a,181));
        index_3_inani2{1,x}(a,1) = (tool_fft2{1,x}(a,271) - grsp_fft2{1,x}(a,271))/(tool_fft2{1,x}(a,271) + grsp_fft2{1,x}(a,271));
        
        
        
        
    end
end


index_1 = index_1';
index_2 = index_2';
index_3 = index_3';

index_1_inani = index_1_inani';
index_2_inani = index_2_inani';
index_3_inani = index_3_inani';

index_1_ani = index_1_ani';
index_2_ani = index_2_ani';
index_3_ani = index_3_ani';

index_1_inani1 = index_1_inani1';
index_2_inani1 = index_2_inani1';
index_3_inani1 = index_3_inani1';

index_1_inani2 = index_1_inani2';
index_2_inani2 = index_2_inani2';
index_3_inani2 = index_3_inani2';

index_1_ani1 = index_1_ani1';
index_2_ani1 = index_2_ani1';
index_3_ani1 = index_3_ani1';

index_1_ani2 = index_1_ani2';
index_2_ani2 = index_2_ani2';
index_3_ani2 = index_3_ani2';

%%%% take means of indices

index_1av = {mean(cat(3,index_1{:,1}),3)};
index_2av = {mean(cat(3,index_2{:,1}),3)};
index_3av = {mean(cat(3,index_3{:,1}),3)};

index_1av_inani = {mean(cat(3,index_1_inani{:,1}),3)};
index_2av_inani = {mean(cat(3,index_2_inani{:,1}),3)};
index_3av_inani = {mean(cat(3,index_3_inani{:,1}),3)};

index_1av_ani = {mean(cat(3,index_1_ani{:,1}),3)};
index_2av_ani = {mean(cat(3,index_2_ani{:,1}),3)};
index_3av_ani = {mean(cat(3,index_3_ani{:,1}),3)};



index_1av_inani1 = {mean(cat(3,index_1_inani1{:,1}),3)};
index_2av_inani1 = {mean(cat(3,index_2_inani1{:,1}),3)};
index_3av_inani1 = {mean(cat(3,index_3_inani1{:,1}),3)};


index_1av_inani2 = {mean(cat(3,index_1_inani2{:,1}),3)};
index_2av_inani2 = {mean(cat(3,index_2_inani2{:,1}),3)};
index_3av_inani2 = {mean(cat(3,index_3_inani2{:,1}),3)};


index_1av_ani1 = {mean(cat(3,index_1_ani1{:,1}),3)};
index_2av_ani1 = {mean(cat(3,index_2_ani1{:,1}),3)};
index_3av_ani1 = {mean(cat(3,index_3_ani1{:,1}),3)};

index_1av_ani2 = {mean(cat(3,index_1_ani2{:,1}),3)};
index_2av_ani2 = {mean(cat(3,index_2_ani2{:,1}),3)};
index_3av_ani2 = {mean(cat(3,index_3_ani2{:,1}),3)};


index_all = [index_1av{1,1}(:,1),index_2av{1,1}(:,1),index_3av{1,1}(:,1)];

index_all_ani = [index_1av_ani{1,1}(:,1),index_2av_ani{1,1}(:,1),index_3av_ani{1,1}(:,1)];

index_all_inani = [index_1av_inani{1,1}(:,1),index_2av_inani{1,1}(:,1),index_3av_inani{1,1}(:,1)];

index_all_ani1 = [index_1av_ani1{1,1}(:,1),index_2av_ani1{1,1}(:,1),index_3av_ani1{1,1}(:,1)];
index_all_ani2 = [index_1av_ani2{1,1}(:,1),index_2av_ani2{1,1}(:,1),index_3av_ani2{1,1}(:,1)];

index_all_inani1 = [index_1av_inani1{1,1}(:,1),index_2av_inani1{1,1}(:,1),index_3av_inani1{1,1}(:,1)];
index_all_inani2 = [index_1av_inani2{1,1}(:,1),index_2av_inani2{1,1}(:,1),index_3av_inani2{1,1}(:,1)];

save('index_all','index_all')
save('index_all_ani','index_all_ani')
save('index_all_inani','index_all_inani')

save('index_all_ani1','index_all_ani1')
save('index_all_ani2','index_all_ani2')

save('index_all_inani1','index_all_inani1')
save('index_all_inani2','index_all_inani2')




