function sbfGUI
% GUI for applying SBF_fmri_analysis function
%
% Can specify subject, hemipshere, analysis type, F-stat threshold, and
% ROIs. Select these options and click on "Plot Bargraph" button to
% generate graph. Can also generate an SPSS-friendly, tab-delimited, .txt
% file.
%
% see SBF_fmri_analysis for details onhow bar graphs are generated
%
% last edit: GE 3/10/14 added average across hemisphere option
% GE 3/7/14 added button for generating SPSS output
% GE 2/27/14 changed subject from dropdown to checkbox
% GE 11/22/13 unhardcoded hidden file ignore
% GE 9/25/13 added option to look at all subjects
% GE 9/24/13 added option to combine ROIs. Changed size
% GE 9/23/13

% note to self: should SPSS output button be a checkbox and saving the file
% an argument in sSBF_fmri_analysis? That way you don't have to call the
% function twice (once to make the bargraph and once to make the file);
% however, there's no nice way to average across hemispheres inside
% SBF_fmri_analysis at the moment...
% GUI doesn't save anything to workspace, so you can't change the F-stat
% threshold and just change how the data is filtered; you end up reloading
% in all of the data again. Not sure how to get around this.

% initialize GUI which is a Matlab figure; make invisible as we create it
f = figure('Visible','off','Position',[100,100,1000,900]);
% set some properties
set(f,'Name','Analysis GUI');

% get list of subjects who's rois we have 
%d = dir('/Volumes/imaginguser/MR_DATA/CLAB/SBF_contour/rois');
d = dir(pwd);
subjIDs = {'all'};
for ii = 1:length(d)
    if ~strcmp(d(ii).name(1),'.')
        subjIDs = [subjIDs {d(ii).name}];
    end
end
nSubj = length(subjIDs);

% dropdown menu for subjects
%subjID = subjIDs{1}; % initialize subjID by setting default to first value
%hdropdown = uicontrol('Style','popupmenu','String',subjIDs,'FontSize',16,'Position',[800,725,100,50],'Callback',{@subject_Callback});
% label for the dropdown menu
%htext = uicontrol('Style','text','String','Select Subject','FontSize',16,'Position',[780,775,150,20]);

% checkbox menu for different subjects
subjID = {};
cbsubjh = zeros(nSubj,1);
for s = 1:nSubj
    % arrange into two rows (may be a less hardcode-y way of doing this)
    if s < nSubj/2
        boxPos = [730+(s-1)*50,760,80,20];
    else
        boxPos = [730+(s-floor(nSubj/2)-1)*50,735,80,20];
    end
    cbsubjh(nSubj) = uicontrol(f,'Style','checkbox','String',subjIDs{s},'Value',0,'FontSize',14,'Position',boxPos,'Callback',{@subj_checkbox});
end
htext = uicontrol('Style','text','String','Select Subject','FontSize',16,'Position',[780,800,150,20]);

% list of all possible ROIs
mtobjROInames = {'FFA','PPA','LOC','PFS','OFA','hMT'};
retROInames = {'V1','V2v','V2d','V3v','V3d','hV4','V01','V02','PHC1',...
    'PHC2','L01','L02','T01','T02','V3a','V3b','V7','IPS1','IPS2','IPS3'};
ROInames = [mtobjROInames retROInames];
nROIs = length(ROInames);

ROI = {}; % initialize the ROI variable
% checkboxes for different ROIs
cbroih = zeros(nROIs,1);
for rois = 1:nROIs
    if rois <= nROIs/2 % arrange into two columns
        boxPos = [780,675-(rois-1)*20,80,20];
    else
        boxPos = [855,675-(rois-nROIs/2-1)*20,80,20];
    end
    % set handle
    cbroih(rois) = uicontrol(f,'Style','checkbox','String',ROInames{rois},'Value',0,'FontSize',14,'Position',boxPos,'Callback',{@roi_checkbox});
end
% label for ROIs
htext = uicontrol('Style','text','String','Select ROIs','FontSize',14,'Position',[800,700,100,20]);

% radio button for left, right or both hemispheres 
rbh1 = uicontrol(f,'Style','radiobutton','String','Left','Value',1,'FontSize',16,'Position',[760,375,150,20]);
rbh2 = uicontrol(f,'Style','radiobutton','String','Right','Value',0,'FontSize',16,'Position',[820,375,150,20]);
rbh3 = uicontrol(f,'Style','radiobutton','String','Both','Value',0,'FontSize',16,'Position',[900,375,150,20]);
set(rbh1,'UserData',rbh2,'Callback',{@set_mutually_exclusive});
set(rbh1,'UserData',rbh3,'Callback',{@set_mutually_exclusive});
set(rbh2,'UserData',rbh1,'Callback',{@set_mutually_exclusive});
set(rbh2,'UserData',rbh3,'Callback',{@set_mutually_exclusive});
set(rbh3,'UserData',rbh1,'Callback',{@set_mutually_exclusive});
set(rbh3,'UserData',rbh2,'Callback',{@set_mutually_exclusive});
% initialize hemisphere variable
hemisphere = 'left';
% label for hemisphere
htext = uicontrol('Style','text','String','Select Hemisphere','FontSize',16,'Position',[780,400,150,20]);

% radio button for combined or independent mask
rbh4 = uicontrol(f,'Style','radiobutton','String','Independent ROIs','Value',1,'FontSize',16,'Position',[760,300,200,20]);
rbh5 = uicontrol(f,'Style','radiobutton','String','Combine ROIs','Value',0,'FontSize',16,'Position',[760,280,200,20]);
set(rbh4,'UserData',rbh5,'Callback',{@set_mutually_exclusive});
set(rbh5,'UserData',rbh4,'Callback',{@set_mutually_exclusive});
% initialize hemisphere variable
combine = 0;
% label for hemisphere
htext = uicontrol('Style','text','String','Combine ROIs?','FontSize',16,'Position',[780,330,150,20]);


% initialize threshold value
threshold = 25;
% box to fill in threshold value
hslider = uicontrol('Style','slider','Min',0,'Max',300,'Value',threshold,'SliderStep',[1/301,10*1/301],'Position',[755,200,200,20],'Callback',{@threshold_Callback});
% label for threshold
slidertext = uicontrol('Style','text','String',['Set F-stat threshold: ' num2str(threshold)],'FontSize',16,'Position',[755,225,180,20]);
% box to display slider value


% radio button for measure: absolute or ratio
rbh6 = uicontrol(f,'Style','radiobutton','String','Absolute','Value',1,'FontSize',16,'Position',[760,150,150,20]);
rbh7 = uicontrol(f,'Style','radiobutton','String','Ratio','Value',0,'FontSize',16,'Position',[860,150,150,20]);
set(rbh6,'UserData',rbh7,'Callback',{@set_mutually_exclusive});
set(rbh7,'UserData',rbh6,'Callback',{@set_mutually_exclusive});
% initialize measure variable
measure = 'abs';
% label for measure
htext = uicontrol('Style','text','String','Select Measure','FontSize',16,'Position',[780,175,150,20]);

% axes where the bargraph is going to be drawn
ha = axes('Units','pixels','Position',[100,200,600,600]);

% plot button
hplot = uicontrol('Style','pushbutton','String','Create Bargraph','Position',[280,130,200,40],'FontSize',18,'Callback',{@plotbutton_Callback});

% SPSS output button
hSPSS = uicontrol('Style','pushbutton','String','Make SPSS-friendly .txt File','Position',[730,90,240,40],'FontSize',16,'Callback',{@spssbutton_Callback});

% make the GUI visible
movegui(f,'center');
set(f,'Visible','on');






% Callback functions for buttons
%     function subject_Callback(source,eventdata)
%         str = get(source,'String');
%         val = get(source,'Value');
%         subjID = str{val};
%     end

    function subj_checkbox(source,eventdata)
        val = get(source,'Value');
        str = get(source,'String');
        % if checked, add to subj string
        if val
            subjID = [subjID str];
        else % remove from ROI string
            subjID(strcmp(subjID,str))=[];
        end    
    end

    function roi_checkbox(source,eventdata)
        val = get(source,'Value');
        str = get(source,'String');
        % if checked, add to ROI string
        if val
            ROI = [ROI str];
        else % remove from ROI string
            ROI(strcmp(ROI,str))=[];
        end    
    end

    function set_mutually_exclusive(source,eventdata)
        current_button = gcbo;
        if any([rbh1,rbh2,rbh3]==current_button)
            hemisphere = lower(get(source,'String'));
            set(rbh1,'Value',0);set(rbh2,'Value',0);set(rbh3,'Value',0); 
        elseif any([rbh4,rbh5]==current_button)
            combine = isempty(strfind(lower(get(source,'String')),'independent'));
            set(rbh4,'Value',0);set(rbh5,'Value',0);
        elseif any([rbh6,rbh7]==current_button)
            measure = lower(get(source,'String'));
            set(rbh6,'Value',0);set(rbh7,'Value',0);
        end
        set(current_button,'Value',1);
    end

    function threshold_Callback(source,eventdata)
        val = get(source,'Value');
        threshold = round(val);
        set(slidertext,'String',['Set F-stat threshold: ' num2str(threshold)]);
    end

    function plotbutton_Callback(source,eventdata)
        global vs
        vs = SBF_fmri_analysis(ROI,hemisphere,threshold,combine,subjID,measure);
    end

    function spssbutton_Callback(source,eventdata)
        global vs
        create_SBF_SPSS_file(vs);
    end
end