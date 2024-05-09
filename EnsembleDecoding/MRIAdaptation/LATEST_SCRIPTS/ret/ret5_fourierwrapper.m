% this Matlab script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
%
% This script will run the Fourier analysis on fMRI timeseries.
% The analysis is performed on the surface.
% Preprocessing (sm, etc) is specific by curfunc string.
%
% N.B. This is only a wrapper script - the real work is done by
% multi_retino.m, which should also reside in the scripts directory.
%
% The easiest way to execute this script from the analysis
% directory is to start with the following from the Matlab prompt:
% > addpath('../scripts/');
% > ret5a_multiVariablesPolar
%
% N.B. Because this is a Matlab script, we cannot easily use the
% shared variables in global_vars.sh so variables have to be
% updated by hand at the top of the script

clear all
clear mex


%----------------------------
% update these parameters
subj    = 'KK';
curfunc = '_tscvrdtmsm'; % naming convention that comes after run, not including the final sm number
volsmooths = [4 6];

hemo_delay = 4; % assumed hemodynamic delay in s

% for polar angle runs
polar.runs       = [1 2 3 4]; % which runs are polar angle runs?
polar.TR         = 2.5; % TR in seconds
polar.nTRs       = 136; % total number of TRs per run
polar.TR_start   = 9; % starting at 1 for first TR
polar.TR_end     = 136;
polar.ncycles    = 8; % Number of cycles
polar.directions = [-1 +1 -1 +1]; % clockwise = +1, counter-clockwise = -1 (to match colmaps)

% for eccentricity runs
eccen.runs       = [5 6]; % which runs are eccentricity runs?
eccen.TR         = 2.5; % TR in seconds
eccen.nTRs       = 168; % total number of TRs per run
eccen.TR_start   = 9; % starting at 1 for first TR
eccen.TR_end     = 168;
eccen.ncycles    = 8; % Number of cycles
eccen.directions = [-1 +1]; % inward = +1, outward = -1 (to match colmaps)


% -------------------
% options that will probably not need to be adjusted
overwrite_mat_files = 0; % by default, read .mat files if they exist.  set to 1 to force overwrite them (e.g., recreated input files with same name)
do_stderr = 0; % set to 0 to turn off stderr computation, which is time (~10x slower) and memory intensive



% do the work...
for rettypecell = {'polar' 'eccen'} % 1 for polar, 2 for eccen
    rettype = rettypecell{1}; % cell -> str
    
    for sm = volsmooths
        
        for hscell = {'lh' 'rh'}
            hs = hscell{1}; % cell -> str
            
            fprintf('\n== starting: %s sm%d %s\n',rettype,sm,hs)
            
            % --- polar or eccen?  copy appropriate params structure to
            % 'this' structure for easy use
            eval(sprintf('this = %s;',rettype));

            
            % --- input datafiles ---
            % we just want a TRs x voxels/nodes matrix for multi_retino.
            % if datafiles end in:
            %  .1D/.dset : will use afni_matlab's Read_1D. It is assumed that
            %        the first column is the node index and data values start
            %        at column 7 (what you get with SUMA's 3dVol2Surf by default).
            %  .BRIK/BRIK.gz: will use afni_matlab's BrikLoad (not yet supported)
            %  .nii or nii.gz: will use nifti_matlab (not yet supported)
            %
            % For efficiency, we will create a .mat file for each run, in the same
            % directory as the datafiles, and use those if they exist. Be sure to
            % delete the .mat files if the datafiles change but retain the same name,
            % so a new up to date mat file can be created.
            datafiles = [];
            opts.data = [];
            for r = 1:length(this.runs)
                datafiles{r} = [subj '_r' sprintf('%02d',this.runs(r)) curfunc num2str(sm) '.' hs '.1D.dset'];
            end
            
            % -- output suma_output ---
            % output suma file for displaying results.
            % note that the output matrices from multi_retino are also part of the
            % output and will be in the base workspace (phase,amp,ifund,mlog10p,stderr)
            suma_output = [subj '_' rettype curfunc num2str(sm) '.' hs '.1D.dset'];
            
            
            % --- opts fields --- see "help multi_retino" for more info
            opts.ncycles    = this.ncycles; % ncycles *over the TRs above*
            opts.directions = this.directions;
            opts.TR         = this.TR; % in seconds
            opts.delay      = hemo_delay; % in seconds
            opts.detrend    = 0; % 1 = detrend, 0 = no detrending
            opts.stderr_paired = 0; % 1 = sum over corresponding +1/-1 directions, 0 = do not
            opts.stderr_paired_nohemo = 0; % 1 = don't do freesurfer hemo/direction correction as well, 0 = do it
            
            
            % sanity check
            runs = length(datafiles);
            if length(opts.directions) ~= runs
                error('number of directions must match the number of runs');
            end
            
            
            % make .mat files if necessary
            fprintf('doing setup...\n');
            for r = 1:runs
                [pathstr name ext]    = fileparts(datafiles{r});
                [pathstr2 name2 ext2] = fileparts(name); % handle double extensions (e.g,., .BRIK.gz or .1D.dset)
                if ~isempty(ext2)
                    longext = strcat(ext2,ext);
                    name = name2;
                else
                    longext = ext;
                end
                if ~isempty(pathstr)
                    base = fullfile(pathstr,name);
                else
                    base = name;
                end
                file_mat = [base '.mat'];
                if ~exist(file_mat,'file')
                    fprintf('%s not found, creating ...\n',file_mat);
                    switch longext
                        case {'.1D','.1D.dset'}
                            fprintf('reading file with afni_matlab''s Read_1D\n');
                            [err this_run info] = Read_1D(datafiles{r});
                            if err
                                error('could not read %s',datafiles{r});
                            end
                            this_run = single(this_run);
                            if r == 1
                                indices = this_run(:,1); % get the indices, which is assumed to be first col
                            end
                            
                            % ncols_this_run, the number of columns in
                            % this_run, will either be nTRs+1 (first column is
                            % node list) or nTRs+6 (first column is 6
                            % node/coords), depending on how the .1D.dset
                            % file was created [3dVol2Surf -out_1D vs.
                            % 3dVol2Surf -out_niml followed by ConvertDset]
                            ncols_this_run = size(this_run,2); % number of columns in this_run
                            if ncols_this_run == this.nTRs+6
                                % 3dVol2Surf -out_1D yields first 6 columns
                                % as "node 1dindex i j k vals"
                                this_run = this_run(:,6+this.TR_start:6+this.TR_end);
                            elseif ncols_this_run == this.nTRs+1
                                % 3dVol2Surf -out_niml followed by
                                % ConvertDset yields first 1 column as "node"
                                this_run = this_run(:,this.TR_start+1:this.TR_end+1);
                            else
                                error('nTRs (%s) supplied in script does not match input datafile %s',this.nTRs,datafiles{r});
                            end
                            this_run = this_run'; % want TRs x nodes, not nodes x TRs
                            
                        case {'.BRIK','.BRIK.gz'}
                            disp('reading file with afni_matlab''s BrikLoad');
                            error('not yet implemented. contact author for an update.');
                            
                        case {'.nii','nii.gz'}
                            disp('reading file with nifti_matlab');
                            error('not yet implemented. contact author for an update.');
                            
                        otherwise
                            error('unrecognized extension in %s',datafiles{r});
                    end
                    
                    save(file_mat,'this_run','indices');
                else
                    load(file_mat); % just read from disc
                end
                opts.data{r} = file_mat;

                % sanity check - make sure the data loaded for current run is same as previous runs.
                [ntp vals] = size(this_run);
                if r > 1
                    if ntp ~= r1_ntp
                        error('different number of timepoints in run %d (%d) than first run (%d)',r,ntp,r1_ntp);
                    end
                    if vals ~= r1_vals
                        error('different number of voxels (or nodes) in run %d (%d) than first run (%d)',r,vals,r1_vals);
                    end
                else
                    r1_ntp = ntp;
                    r1_vals = vals;
                end

                clear this_run; % clear biggest matrix from memory once .mat files have been created
            end

            
            
            % call multi_retino
            fprintf('calling multi_retino...\n');
            if do_stderr
                [phase ifund amp mlog10p stderr realsamples imagsamples] = multi_retino(opts);
                %stderr = max(stderr)-stderr; % invert stderr???
            else
                [phase ifund amp mlog10p] = multi_retino(opts);
                stderr = NaN(size(indices),'single');
            end
            
            
            % save results as a suma datafile
            fprintf('saving file for SUMA...\n');
            fid = fopen(suma_output,'wt');
            if ~fid
                error('could not open %s for writing',suma_output);
            end
            fprintf(fid,'# phase amp -log10(p) -stderr\n');
            for n = 1:length(indices)
                fprintf(fid,'%d %f %f %f %f\n',indices(n),phase(ifund,n),amp(ifund,n),mlog10p(n),-stderr(n));
            end
            fclose(fid);
            
            plot(mean(amp(2:end,:),2));
            xlabel('frequency');
            ylabel('amplitude');
            fprintf('== complete: %s sm%d %s\n',rettype,sm,hs)
        end
    end
end
