function voxStat = SBF_fmri_analysis(ROI,hemisphere,thresh,combine,subjID,measure,plotit)
% create bar graphs for SBF fMRI experiment
%
% INPUTS:
%   ROI     - string or cell array containing ROIs of interest
%             possible values: all, mtobj, ret, FFA, PPA, LOC, PFS, OFA,
%               hMT, V1, V2v, V2d, V3v, V3d, hV4, V01, V02, PHC1, PHC2,
%               L01, L02, T01, T02, V3a, V3b, V7, IPS1, IPS2, IPS3
%             all means do all ROIs; mtobj: only for mtobj ROIS;
%             ret: only for retinotopy ROIs
%   HEMISPHERE - 'l' or 'left', 'r' or 'right', 'lr','b','both','a', or 'all'
%   THRESH  - threshold for full F-stat
%   COMBINE - 0: look at each ROI individually
%             1: combine ROIs into a single mask
%             (can also take "true","comb","combine","false","ind","independent)
%   SUBJID  - two letter subject ID, or cell array of subject IDs or 'all'
%   MEASURE - 'absolute' or 'abs': absolute score
%             'ratio' or 'rat': (condition-control)/(condition+control)
%             both measures are computed regardless; only a setting for plotting
%   PLOTIT  - plot (1) or do not plot (0)
%
%   OUTPUTS: 
%   VOXSTAT - structure that contains individual subject data, averaged
%           data used to make bar plots, voxel counts per ROI, and ROI
%           labels (corresponding to rows of each of the above).
%
% Note that in the set paths section of this file, the locations of several
% file directories are hard-coded
%
% Note: If there are NaNs in the beta weight matrix used to generate the
% bar plot, this could be for two reasons: (1) no ROI labels for that
% subject for that ROI, or (2) no voxels in that ROI exceed threshold
%
% example: SBF_fmri_analysis({'hMT','V01','V02'},'left',30,0,'JV','abs',1)
%
%
% last edit: GE 3/11/14 corrected standard error computationwhen collapsing
% across hemispheres
% GE 3/10/14 can average across both hemispheres; plotting is
% now a separate function (still within this file)
% GE 3/7/14 removed SPSS output, now need to call separate
% script: create_SBF_SPSS_file; added y-axis label
% GE 2/27/14 updated comments; output returned in same order as
% ROIs specified (previously auto-sorted by name); checks for repeat
% subjects; outputs data also in SPSS-friendly format (voxstat.barData_forstats)
% GE 11/22/13 unhardcoded hidden file ignore
% GE 11/18/13 moved load BRIK outside of loop for speedup; added
% plotit option; updated comments; fixed bug when collapsing across ROIs
% and subjects; added output options; if one subject completely missing
% ROI BRIK file, will still plot for all other subjects
% GE 9/26/13 fixed bug in plotting combined data and bug in
% plotting errorbars when using ratio measure
% GE 9/25/13 fixed plotting issue for combined data,
% can average across all subjects
% GE 9/24/13 added comments, fixed bug when selecting ROI from
% both ret and mt-obj
% GE 9/23/13 can select ROIs from mt-obj and ret; option to
% combine ROIs into single mask or look at separately; option to use
% different kinds of measures (absolute or ratio)
% GE 9/20/13 changed ROI names, updated help, added hemisphere
% GE 9/18/13 created

% TO DO:
% -sometimes the GUI crashes, but cannot replicate reliably
% -allow averaging across hemispheres?

% Note: for now keeping everything in one file, but may want to break up
% into separate files later

% % % %    check input    % % % %

if nargin<7
    plotit=1; % plot by default
end
if nargin<6
    warning('No measure provided, using absolute as default');
end
if nargin<5
    error('Must provide a subject ID')
end
if nargin<4
    warning('Not indicated whether ROIs should be combined or treated separately. Combining by default');
    combine = 1;
end
if nargin<3
    warning('No threshold provided; using default value');
    thresh = 25;
end
if nargin<2
    error('No hemisphere specified');
end
if nargin<1
    error('No ROI specified');
end
if ~isnumeric(plotit) || numel(plotit)>1 || (plotit~=1 && plotit~=0)
    warning('plotit must be 0 or 1. Plotting by default.')
end
if ~any(strcmpi({'ratio','rat','absolute','abs'},measure))
    error('Measure must be "absolute" or "ratio"');
end
measure = lower(measure); % convert to lowercase
if strcmp('ratio',measure) % check for valid abbreviations
    measure = 'rat';
elseif strcmp('absolute',measure)
    measure = 'abs';
end
if any(strcmpi({'true','comb','combine'},combine))
    combine = 1;
elseif any(strcmp({'false','independent','ind'},combine))
    combine = 0;
end
if combine~=0 && combine ~=1
    error('Combine must be 0 (treat ROIs separately) or 1 (combine ROIs');
end
if ~isnumeric(thresh)
    error('Threshold must be a number');
end
if thresh<0
    warning('Negative threshold provided; using threshold of 25');
    thresh = 25;
end
if ~ischar(hemisphere) || ~any(strcmpi({'l','left','r','right','b','both','a','all','lr'},hemisphere))
    error('hemisphere must either be "left" or "right" or "both"');
else
    hemisphere = lower(hemisphere); % convert to lowercase
end
if strcmp(hemisphere,'left') % change from 'left' to 'l' to match file name
    hemisphere  = 'l';
elseif strcmp(hemisphere,'right')
    hemisphere = 'r';
elseif strcmp(hemisphere,'both') || strcmp(hemisphere,'a') || strcmp(hemisphere,'all') || strcmp(hemisphere,'lr')
    hemisphere = 'b';
end

% if looking at both hemispheres, run the function separately for each,
% then average the resulting data
if strcmp(hemisphere,'b')
    % run function for each hemisphere separately (without plotting)
    vsL = SBF_fmri_analysis(ROI,'l',thresh,combine,subjID,measure,0);
    vsR = SBF_fmri_analysis(ROI,'r',thresh,combine,subjID,measure,0);
    
    % save individual hemisphere data to output structure
    voxStat.leftHem = vsL;
    voxStat.rightHem = vsR;
    
    % average data from both hemisphers
    % note: taking nanmean, so if data missing for one hemisphere, average
    % will show up as the values from the hemisphere that has those data
    voxStat.barData = nanmean(cat(4,vsL.barData,vsR.barData),4);
    voxStat.ratBarData = nanmean(cat(4,vsL.ratBarData,vsR.ratBarData),4);
    voxStat.avgBarData = nanmean(cat(3,vsL.avgBarData,vsR.avgBarData),3);
    voxStat.avgRatBarData = nanmean(cat(3,vsL.avgRatBarData,vsR.avgRatBarData),3);
    % recompute standard deviation
    nSubjPerROI = sum(~isnan(voxStat.barData(:,1,:)),3);
    voxStat.sdBarData = nanstd(voxStat.barData,[],3)./repmat(sqrt(nSubjPerROI),1,size(voxStat.barData,2));
    voxStat.sdRatBarData = nanstd(voxStat.ratBarData,[],3)./repmat(sqrt(nSubjPerROI),1,size(voxStat.ratBarData,2));
    % copy analysis-specific parameters from individual hemisphere data
    voxStat.settings = voxStat.leftHem.settings;
    voxStat.conditionNames = voxStat.leftHem.conditionNames;
    voxStat.subjID = voxStat.leftHem.subjID;
    voxStat.ROIs = voxStat.leftHem.ROIs;
    voxStat.settings.hemisphere = 'b';
    
    % plotting
    if plotit % if plotting
        % determine which data to plot
        if strcmp(measure,'abs')
            plotData = voxStat.avgBarData;
            errorData = voxStat.sdBarData;
        elseif strcmp(measure,'rat')
            plotData = voxStat.avgRatBarData;
            errorData = voxStat.sdRatBarData;
        end
        plotBetaWeights(plotData,errorData,vsL.ROIs,size(vsL.barData,3),vsL.conditionNames,measure,combine);
    end
    
    return; % don't evaluate the rest of the function; exit out
    
    % NOTE: if data are missing for one hemisphere, this will return an
    % error when it tries to run analysis on that hemisphere. Do we want
    % that to happen or do we want it to output results for the hemisphere
    % for which data exists? Note that if data are only missing for one
    % subject out of several or for one ROI out of several, the function
    % will still run.
end

% list of all possible ROIs
mtobjROInames = {'FFA','PPA','LOC','PFS','OFA','hMT'};
retROInames = {'V1','V2v','V2d','V3v','V3d','hV4','V01','V02','PHC1',...
    'PHC2','L01','L02','T01','T02','V3a','V3b','V7','IPS1','IPS2','IPS3'};
ROInames = {mtobjROInames retROInames};

% if only a single ROI was given as a string, convert it to a cell
if ischar(ROI)
    ROI = {ROI};
end

% if used keywords mtobj, ret, or all, in selecting ROI, select appropriate ones matching name
if any(strcmpi(ROI,'mtobj')) || any(strcmpi(ROI,'mt-obj'))
    ROI(strcmpi(ROI,'mtobj') | strcmpi(ROI,'mt-obj'))=[]; % remove "mt-obj" string
    ROI = [ROI mtobjROInames]; % add in the ROIs from mt-obj
elseif any(strcmpi(ROI,'ret'))
    ROI(strcmpi(ROI,'ret')) = []; % remove "ret" string
    ROI = [ROI retROInames]; % add in the ROIs from ret
elseif any(strcmpi(ROI,'all'))
    ROI = [mtobjROInames,retROInames]; % if "all", then use all ROIs
end
ROI = unique_no_sort(ROI); % get rid of repeats as in case of {'FFA','mt-obj'}

% NOTE: perhaps this next part can be done more elegantly

% check to see if user asked for a valid ROI
nROIs = length(ROI); % number of ROIs asked for
namesToRemove = false(nROIs,1);
ROIfile = {}; % cell array to store (parts of) names or ROI BRIK files
for roiIdx = 1:nROIs
    if (any(strcmpi(mtobjROInames,ROI{roiIdx})) || strcmpi('all',ROI{roiIdx}))
        ROIfile(1) = {'_mt-objROIs_'};
    elseif (any(strcmpi(retROInames,ROI{roiIdx})) || strcmpi('all',ROI{roiIdx}))
        ROIfile(2) = {'_retROIs_'};
    else
        warning([ROI{roiIdx} ' is not a valid ROI name. Skipping.']);
        namesToRemove(roiIdx)=1; % if ROI name is invalid, remove from list (after loop)
    end
end
ROI(namesToRemove) = [];
if isempty(ROI)
    error('No valid ROI names provided. See help for valid names');
end
nROIs = length(ROI); % recompute number of ROIs after removing invalid names

% if looking at all subjects, get names of those that have ROI files
if any(strcmpi(subjID,'all'))
    % get list of all ROI files
    d = dir('/Volumes/imaginguser/MR_DATA/CLAB/SBF_contour/rois/');
    subjID = {}; % stores subject names
    scounter = 1; % counter for number of subjects
    for ii = 1:length(d)
        % ignore hidden files
        if ~strcmp(d(ii).name(1),'.')
            subjID(scounter) = {d(ii).name};
            scounter = scounter+1;
        end
    end % looping over files
elseif ~iscell(subjID) % convert to cell array if only one subjname
    subjID = {subjID};
end
% check for repeat subjects
subjID = unique_no_sort(subjID);
nSubj = length(subjID);
    
% % % % get fMRI and ROI/mask data for each subject for each ROI  % % % %

% addpath to afni script (BrikLoad) that lets you read BRIK data
if ~exist('BrikLoad','file')
    addpath /Volumes/G-DRIVE/GideonsFiles/mvpa/afni_matlab/
end
    
% conditions <-- must change for every experiment!!
% if there are no control conditions for ratio measure, set nControls = 0
conditionNames = {'Circle Rot','Circle Shift','Square Rot','Square Shift','Rand Rot','Rand Shift'};
nConditions = length(conditionNames);
nControls = 2; % number of control conditions
% preallocate array that will store data
if combine % if combining across ROIs
    barData = nan(1,nConditions,nSubj);
    ratBarData = nan(1,nConditions-nControls,nSubj);% array for ratio measure
    voxStat.propVoxelSelected = cell(1,4,nSubj); % array for storing voxel selection info
else
    barData = nan(nROIs,nConditions,nSubj);
    ratBarData = nan(nROIs,nConditions-nControls,nSubj); 
    voxStat.propVoxelSelected = cell(nROIs,4,nSubj);
end


% initialize counters that will be updated if any data is missing. If
% plotting all subjects' data, and one subject does not have a requested
% ROI, will skip that subject, but still run the code. If all subjects are
% missing that ROI, will throw back an error.
nLabeledROIs=0; nMissingDataFolders=0; nMissingBuckets=0;

for subj = 1:nSubj
    % get current subject
    thisSubj = subjID{subj};
    
    % % % %     set paths to ROI data   % % % %
    
    % we repeat this calculation here because nROIs could be set to 1
    % later if we are using the "combine" option to collapse across ROIs
    nROIs = length(ROI);  
    % counter for how many missing ROI BRIKs there are for thisSubj
    % if there are no ROI BRIKs found, skip that subject
    nMissingROIBRIKs = 0; 
    
    % create path to data directory
    datapath = ['/Volumes/imaginguser/MR_DATA/CLAB/SBF_contour/' thisSubj '/analysis/'];
    
    % check to see if subject data exists; if missing, skip to next subject
    if ~exist(datapath,'dir')
        if nSubj==1
            error(['No data for subject ' thisSubj ' found in SBF_contour folder.']);
        else
            nMissingDataFolders = nMissingDataFolders+1;
            warning(['No data for subject ' thisSubj ' found in SBF_contour folder. Skipping.']);
            continue
        end
    end
    % check to see if any data found at all for any subject
    if nMissingDataFolders == nSubj
        error('No data found for any subjects');
    end
    
    % check to see if bucket exists
    bucketpath = [datapath thisSubj '_tscvrsm0_norm_bucket+orig'];
    if ~exist([bucketpath '.BRIK.gz'],'file') && ~exist([bucketpath '.BRIK'],'file')
        if nSubj==1
            error(['No BRIK file found in analysis in ' datapath]);
        else
            nMissingBuckets = nMissingBuckets+1;
            warning(['No BRIK file found in analysis in ' datapath ' for ' thisSubj '. Skipping']);
            continue
        end
    % load data BRIK if it exists    
    else
        [e, data, i, em] = BrikLoad(bucketpath,'vector'); % read in bucket data as a vector
    end
    % check to see if any data found at all
    if nMissingBuckets == nSubj
        error('No data BRIK file found for any subject.');
    end
                    
    % % % %   read in ROI data    % % % %
    
    % NOTE: Matlab 2012 and later have Map Containers which are dictionaries.
    % This next section can be recoded more nicely if they were used, but then
    % the function wouldn't work on older versions of Matlab. Instead, we do it
    % with cell arrays
    
    % ROI LABELS
    %
    % obj-mt
    % 0 - no ROI
    % 1 - FFA
    % 2 - PPA
    % 3 - LOC
    % 4 - PFS
    % 5 - OFA
    % 6 - hMT
    %
    % ret
    %
    % 1 - V1
    % 2 - V2v
    % 3 - V2d
    % 4 - V3v
    % 5 - V3d
    % 50 - hV4
    % 51 - V01
    % 52 - V02
    % 53 - PHC1
    % 54 - PHC2
    % 100 - L01
    % 101 - L02
    % 102 - T01
    % 103 - T02
    % 150 - V3a
    % 151 - V3b
    % 152 - V7
    % 153 - IPS1
    % 154 - IPS2
    % 155 - IPS3

    % these must match the order in ROInames above
    mtobjLabels = 1:6;
    retLabels = [1:5,50:54,100:103,150:155];
    roiLabels = {mtobjLabels retLabels};
    ROIfileCount = 0; % counter for number of ROI BRIK files available for subject
    
    % there is probably a nicer way of doing this part of the code. The
    % advantage of the current method is that it allows for flexibility if new
    % ROI files are added: just tack on new labels and names into the cell
    % arrays and little else needs to change. The disadvantage is that we now
    % look for each queried ROI in all of the files, which is a waste since we
    % know it can only appear in one of them. Also, it lumps together
    % checking if the ROI file exists, loading the file, and checking if
    % that particular ROI exists in that file.
    
    % preallocate mask array; each column corresponds to a different ROI
    if ~exist('roiMask','var')
        roiMask = zeros(size(data,1),nROIs);
    end
    
    for roif = 1:length(ROIfile) % step through however many roi files we need (mt-obj and ret)
        if ~isempty(ROIfile{roif}) % if only want ROI from one of the files, load only that file
            ROIfileCount = ROIfileCount+1;
            % define path to ROI BRIK
            roipath = [datapath, thisSubj, ROIfile{roif}, hemisphere, 'h+orig'];
            % check to see if ROI file exists
            if ~exist([roipath '.BRIK.gz'],'file') && ~exist([roipath '.BRIK'],'file')
                warning(['No ' ROIfile{roif} ' ROI BRIK file found in ' roipath]);
                nMissingROIBRIKs = nMissingROIBRIKs+1;
            else % found ROI BRIK file
                % load in ROI mask (MT left hemisphere)
                [e, mask, i, em] = BrikLoad(roipath,'vector');

                % retrieve masks based on requested ROI; step through all queried ROI names
                for roiIdx = 1:nROIs
                    % check if queried ROI name corresponds to ROI names in current ROI file
                    if any(strcmpi(ROInames{roif},ROI{roiIdx}))
                        % look up the matching label based on the provided ROI name
                        % identify the voxels that have that label and mark them in roiMask
                        roiMask(:,roiIdx) = mask==roiLabels{roif}(strcmpi(ROInames{roif},ROI{roiIdx}));
                        % see if labels found in mask; warn if not
                        if sum(roiMask(:,roiIdx))==0
                            warning(['No labels found for ' ROI{roiIdx} ' in ROI for ' thisSubj]);
                        end
                    end % ROI labels
                end % stepping thru ROIs
            end % if BRIK file found
        end % if loading particular BRIK file
    end % roi files
    
    % if missing all ROI BRIKs for the subject, skip to next subject
    if nMissingROIBRIKs == ROIfileCount
        continue
    end
    
    % if combining across ROIs, then just add across columns (ROIs)
    if combine
        roiMask = sum(roiMask,2);
        nROIs = 1; % for plotting later
    end
    
    roiMask = logical(roiMask); % convert to logical (all non-zero -> 1)
    
    % check to see if those ROIs are actually labeled in the image
    if sum(sum(roiMask))==0 % 2 sums in case ROI is 2D (not combining)
        if nSubj == 1
            error(['No labeled ROIs found for' thisSubj '. Check ROI file.']);
        else
            nLabeledROIs = nLabeledROIs + 1;
            warning(['No labeled ROIs found for' thisSubj '. Skipping.']);
            continue
        end
    end
    % check if any labeled ROIs were found for any subject
    if nLabeledROIs == nSubj
        error('No Labeled ROIs found for any subject. Check ROI files.');
    end
    
    % meaning of the 13 columns in data (conditions):
    
    % 0 - full fstat
    % odd - coeff
    % even - tstat
    
    % for this experiments:
    % 1-2 circle rot
    % 3-4 circle shift
    % 5-6 square rot
    % 7-8 square shift
    % 9-10 rand rot
    % 11-12 rand shift
    
    % NOTE: Matlab is 1-indexed so all values above are shifted up by 1
    
    % get masked/ROI data for each condition:
    for jj = 1:nROIs 
        % select the voxels that are within the ROI and exceed the threshold value
        dataFilt = roiMask(:,jj) & data(:,1)>=thresh;
        
        % compute average beta weights for each condition
        for ii = 1:nConditions % conditions
            barData(jj,ii,subj) = mean(data(dataFilt,(2*ii)));
        end
        
        % count the number of voxels in each ROI
        if combine 
            voxStat.propVoxelSelected{jj,1,subj} = ROI;
        else
            voxStat.propVoxelSelected{jj,1,subj} = ROI{jj};
        end
        voxStat.propVoxelSelected{jj,2,subj} = sum(dataFilt);
        voxStat.propVoxelSelected{jj,3,subj} = sum(roiMask(:,jj));
        voxStat.propVoxelSelected{jj,4,subj} = voxStat.propVoxelSelected{jj,2,subj}/voxStat.propVoxelSelected{jj,3,subj};
    end % roi
    
    % create ratio measure      NOTE: need to unhardcode
    ratBarData(:,1,subj) = (barData(:,1,subj)-barData(:,5,subj))./(barData(:,1,subj)+barData(:,5,subj));
    ratBarData(:,3,subj) = (barData(:,3,subj)-barData(:,5,subj))./(barData(:,3,subj)+barData(:,5,subj));
    ratBarData(:,2,subj) = (barData(:,2,subj)-barData(:,6,subj))./(barData(:,6,subj)+barData(:,6,subj));
    ratBarData(:,4,subj) = (barData(:,4,subj)-barData(:,6,subj))./(barData(:,4,subj)+barData(:,6,subj));
    
end % loop over subjects

% if user passed in valid ROI names but no subject had any data for any
% ROIs, terminate program here
if all(isnan(barData(:)))
    error('No labeled voxels found for selected ROIs for any subjects');
end

% there is an issue with what to do if a subject is missing a particular
% ROI - nix all analysis for that ROI or simply skip that subject and look
% at all other data. This code does the latter. This means that there are
% NaN's for missing data in barData. It also means that nSubj varies from ROI
% to ROI, which matters for computation of standard errors. This is taken
% into consideration here

% compute number of subjects that have non-NaN values for each ROI
nSubjPerROI = sum(~isnan(barData(:,1,:)),3);

avgBarData = nanmean(barData,3);
avgRatBarData = nanmean(ratBarData,3);
sdBarData = nanstd(barData,[],3)./repmat(sqrt(nSubjPerROI),1,nConditions);
sdRatBarData = nanstd(ratBarData,[],3)./repmat(sqrt(nSubjPerROI),1,nConditions-nControls);

% update output structure
voxStat.subjID = subjID;
voxStat.ROIs = ROI;
voxStat.settings.thresh = thresh;
voxStat.settings.hemisphere = hemisphere;
voxStat.settings.measure = measure;
voxStat.settings.combine = combine;
voxStat.barData = barData;
voxStat.ratBarData = ratBarData;
voxStat.avgBarData = avgBarData;
voxStat.avgRatBarData = avgRatBarData;
voxStat.sdBarData = sdBarData;
voxStat.sdRatBarData = sdRatBarData;
voxStat.conditionNames = conditionNames;

% % % %    plot the results    % % % %

% determine which data to plot
if strcmp(measure,'abs')
    plotData = avgBarData;
    errorData = sdBarData;
elseif strcmp(measure,'rat')
    plotData = avgRatBarData;
    errorData = sdRatBarData;
end

if plotit % if plotting
    plotBetaWeights(plotData,errorData,ROI,nSubj,conditionNames,measure,combine);
end

end % SBF_fmri_analysis

function plotBetaWeights(data,sds,ROI,nSubject,conditionNames,measure,combine)    

    nROI = size(data,1);
    nCond = size(data,2);
    
    % create plot
    bar(data,0.9,'edgecolor','k','linewidth',2);
    % errorbars
    if nSubject>1 
        if combine
            % if not combining across conditions, then there will be one bar
            % per condition
            x = 1:nCond;
        else
            % if not combining across conditions, need to get the x coordinates
            % of the center of each bar to know where to draw the errorbars
            cc = get(gca,'Children');
            x = zeros(nCond,nROI);
            for kk = 1:length(cc)
                dd = get(cc(kk),'Children');
                xx = get(dd,'XData');
                if length(cc)>1
                    x(kk,:) = mean(xx([1 nCond/2],:));
                else % slight hack for getting plots of just 1 ROI to work
                    x = mean(xx([1 nCond/2],:));
                end
            end
            % children are stored in reverse order, so need to flip x
            x = flipud(x)';
        end  
        hold on;
        errorbar(x,data,sds,'k','linestyle','none','linewidth',2);
        hold off; 

        %display number of subjects
        title(['Number of Subjects: ' num2str(nSubject)],'FontSize',18);
    end

    if strcmp(measure,'rat')
        ylabel('Beta Weight   (shape - control) / (shape + control)','fontsize',24);
    else
        ylabel('Beta Weight','fontsize',24);
    end

    % format plot
    if nROI>1 % if more than 1 ROI, include a legend and label each group based on ROI
        set(gca,'XTickLabel',ROI,'box','on','ticklength',[0 0],'fontsize',18,'xtick',1:nROI,'linewidth',2,'xgrid','off','ygrid','off');
        xlim([0 nROI+1]);
        legend(gca,conditionNames,'Location','NorthEast');
    else % if only 1 ROI, label bars based on conditions
        set(gca,'XTickLabel',conditionNames,'box','on','ticklength',[0 0],'fontsize',16,'xtick',1:nCond,'linewidth',2,'xgrid','off','ygrid','off');
    end

end % plotBetaWeights function