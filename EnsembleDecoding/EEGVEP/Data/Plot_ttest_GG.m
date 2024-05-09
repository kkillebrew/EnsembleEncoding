clear all
close all

midline = [31 26 21 15 8 257 81 90 101 119 126 137 147]; %13
anterior_left = [32 37 46 54 47 38 33 27 34 39 48 40 35 28 22 29 36 23]; %18
anterior_right= [25 18 10 1 2 11 19 20 12 3 222 223 4 13 14 5 224 6]; %18
center_left= [ 68 55 62 69 74 83 94 84 75 70 63 56 49 57 64 71 76 77 72 65 58 50 41 30 42 51 59 66 78 89 79 60 52 43 24 16 17 44 53 80 45 9]; %21
center_right= [210 221 211 202 192 191 190 179 180 193 203 212 213 204 194 181 172 163 173 182 195 205 214 215 206 196 183 164 154 130 143 155 184 197 207 7 195 185 144 131 132 186]; %21
posterior_right= [88 100 110 99 87 86 98 109 118 117 106 97 85 96 107 116 125 124 115 106 95 105 114 123 136 135 122 113 104 112 121 134 146 145 133 120 111]; %37
posterior_left= [142 129 128 141 153 162 152 140 127 139 151 161 171 170 160 150 138 149 159 169 178 177 168 158 148 157 167 176 189 188 175 166 156 165 174 187 199]; %37
cheek_left= [102 91 256 251 247 243 246 250 255 82 92 103 93 73 254 249 245 242 241 244 248 252 253 67 61]; %25
cheek_right= [208 216 229 233 237 240 236 232 228 217 209 200 201 218 227 231 235 239 238 234 230 226 225 219 220]; %25

load('Stats_exp3.mat')
%load('Stats_exp3.mat')

save_figs = 0;

labels = {'cheek_left','anterior_left','center_left', 'posterior_left','midline','cheek_right','anterior_right','center_right','posterior_right'};
lnclr = [0 0 0];
font_size = 36;
title_size = 38;
tick_size = 28;
sig_thresh = 0.05;
alpha_thresh = .4;
graph_size = 1; %Thickness of graph edges
fig_dims = [500 500 1700 800];

for i = 1:length(labels)
this_mat = eval(labels{i});
  x(i) = length(this_mat);
  x2(i) = length(this_mat)/2;
end

for i = 1:length(labels)
    
    if i ==1
        ticks(i) = x2(i);
        
    else
        ticks(i) = x2(i)+sum(x(1:i-1));
    end
end




conds_stat = {'Stats.toolnessERP','Stats.shapeERP'};
conds_sig = {'Stats.toolnessERP.P','Stats.shapeERP.P'};
conds_labels = {'Toolness: Tool vs Non-Tool','Shape: Long vs Stubby'}; 

for z = 1:length(conds_stat)
    
    this_stats = eval(conds_stat{z});
    this_stats_sig = eval(conds_sig{z});
    
    for p = 2:550
        for l = 1:257
            this_statsT(l,p) = this_stats.STATS(l,p).tstat;
            
            if this_stats_sig(l,p) <=this_stats.FDR_p
                alphaP(l,p) =1;
                
            else
                alphaP(l,p) = alpha_thresh;
            end
            
        end
    end
    
    
   figure1 = figure(z);
   
%    if save_figs ==1
%        pause(0.00001);
%        frame_h = get(handle(gcf),'JavaFrame');
%        set(frame_h,'Maximized',1);
%    end
   %subplot(2,1,1)
    set(gcf,'color','white')
    set(figure1,'position',fig_dims)
    %hold on
    
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
   % x = imagesc(this_statsT([cheek_left, anterior_left,center_left,posterior_left,midline,cheek_right, anterior_right,center_right,posterior_right],51:end),'Parent',axes1,'CDataMapping','scaled');
   x = imagesc(this_statsT([cheek_left, anterior_left,center_left,posterior_left,midline,cheek_right, anterior_right,center_right,posterior_right],51:end),[-round(max(this_statsT(:))) round(max(this_statsT(:)))]);
    set(x,'AlphaData',alphaP([cheek_left, anterior_left,center_left,posterior_left,midline,cheek_right, anterior_right,center_right,posterior_right],51:end))
    
    
    grid on
    grid minor
    set(gca,'GridLineStyle',':')
    set(gca,'MinorGridLineStyle',':')
   colormap jet
    %colormap(flipud(jet))
    c = colorbar('peer',axes1,'TickLength',0,'LineWidth',graph_size,'FontSize',font_size);
    c.Ticks = [-round(max(this_statsT(:))):round(max(this_statsT(:)))];
    %c = colorbar;
    c.Label.String = 't values';
    c.Label.FontSize = tick_size;
    c.FontSize = tick_size-8;
    box(axes1,'on');
    axis(axes1,'ij');
    
    %set(gca, 'XTick', [0:0.1:1]*512, 'XTickLabel', [0:0.1:1]*100) % 10 ticks
    set(axes1,'LineWidth',graph_size,'TickLength',[0 0],'Layer','top','YTick',ticks,'YTickLabel',{'Cheek Left','Anterior Left','Center Left', 'Posterior Left','Midline','Cheek Right','Anterior Right','Center Right','Posterior Right'},'FontSize',tick_size);
    
    counter = 0;
    for i = 1:length(labels)-1
        this_mat = eval(labels{i});
        
        
        lx = length(this_mat);
        h = line([0 500], [lx+counter lx+counter]);
        set(h,'LineWidth',3)
        set(h, 'Color', lnclr)
        counter = counter +lx;
        
    end
    
    xlabel('Time(ms)','FontSize',font_size) % x-axis label
    ylabel('Electrode Group','FontSize',font_size) % y-axis label
    title(conds_labels{z},'FontSize',title_size)
    pbaspect([2 1 1])
    ylim([1 257])
    xlim([0 500])
    
    if save_figs ==1
        pause(0.25);
        this_path = sprintf('%s%s%s','/Users/clab/Documents/Gena/Research/Category_MVPA/ERP_Exp2/EEG_data/Figures');
        cd(this_path)
        saveas(gcf,sprintf('%s%s',conds_labels{z},'_ERP','.tiff'))
    end
    
    clearvars this_stats this_stats_sig alphaP
    

end

