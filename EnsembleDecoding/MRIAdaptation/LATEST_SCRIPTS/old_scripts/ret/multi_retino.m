function [phase,ifund,amp,mlog10p,stderr,realsamples,imagsamples] = multi_retino(opts)
%function [phase,ifund,amp,mlog10p,stderr,realsamples,imagsamples] = multi_retino(opts)
%
% required opts fields:
%   .data: 2D (single run) or 3D (multiple run) matrix that is 
%       TRs x voxels x runs,
%      OR: a cell array of .mat file names. From each will be
%       loaded the data for a run, which should be a TRs x voxels
%       matrix with the name "this_run".
%       This reduces memory requirements since only one run needs to be
%       in memory at any given time.
%   .directions: a row vector of +1 or -1, #runs in length
%   .ncycles: number of cycles per run
%   .TR: time between measurements in seconds
%
% optional opts fields:
%   .delay: hemodynamic delay in seconds
%       [default: 0]
%   .detrend: 1=detrend, 0=do not (detrend also removes mean)
%       [default: 0]
%   .stderr_paired: 1=pair runs, 0=do not (only used if returning stderr)
%       [default: 0], OR
%   .stderr_paired_nohemo: 1=no hemo/direction correction (will set stderr_paired)
%       [default: 0]
%
% output:
%   only 'phase' and 'ifund' are required. eliminating others off the end
%   will increase speed greatly (especially stderr)
%
%   phase, amp: at each frequency for each voxel
%       * generally you'll only be interested in results at
%       * the fundamental frequency (opts.ncycles over #TRs)
%           phase(ifund,:), amp(ifund,:)
%       * but examining the other frequencies may be instructive
%   ifund: the index of the fundamental frequency
%   mlog10p, stderr: at fundamental frequency only, for each voxel
%   mlog10p: -log10(p). For thresholding, when:
%            mlog10p > 2, p < .01
%            mlog10p > 3, p < .001
%            mlog10p > 4, p < .0001, etc
%   stderr: standard error of the phase
%   real/imagsamples: voxels x cycles x runs matrix of raw data used to
%       compute the stderr (so only exists if you asked for stderr)
%       which could be used for further analysis
%
% notes:
%   - skip TRs and voxels by removing them from opts.data prior to
%       calling this function.
%   However:
%   - it is probably not a good idea to skip TRs since the fundamental
%       frequency calculation depends on the number of timepoints in the
%       original experiment (unless you are skipping TRs outside of cycles)
%   - each voxel is processed independently, so any ROI should be okay.
%
% this function is a modification of selfreqavg, which is part of the
% Freesurfer package <http://surfer.nmr.mgh.harvard.edu>
%
% History:
% 2008.02.24    bdsinger@princeton.edu  began adapting sfa.m
% 2008.03.09    "                       all freqs, stderr
% 2008.04.09    "                       stderr_paired
% 2008.04.11    "                       stderr: use samples mean, pass samples back
%

%% Acknowledge where this work derives from
% This product is a derivative of Freesurfer
% Copyright (C) 2002-2008, The General Hospital Corporation (Boston, MA)
% <https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferOpenSourceLicense>

%% Check input
if ~exist('opts','var')
    error('opts struct required');
end
% required fields
if ~isfield(opts,'data')
    error('opts.data not supplied');
end
% opts.data handling
if iscell(opts.data) && ischar(opts.data{1})
    nruns = length(opts.data);
    loadruns=1;
    load(opts.data{1});
    if ~exist('this_run','var')
        error('matrix named "this_run" not found in opts.data{1}');
    end
    datasize=size(this_run);
else
    loadruns=0;
    datasize=size(opts.data);
    if ~isnumeric(opts.data) || length(datasize) < 2 || length(datasize) > 3
        error('opts.data must be a TRs x voxels x runs matrix');
    end
    if length(datasize) > 2
        nruns=datasize(3);
    else
        nruns=1;
    end
end
if ~isfield(opts,'directions')
    error('opts.directions not supplied');
end
rs=size(opts.directions);
if (rs(1) ~= 1) || (rs(2) ~= nruns)
    error('opts.directions is not 1 x runs');
end
for r=1:nruns
    if (opts.directions(r) ~= +1.0) && (opts.directions(r) ~= -1.0)
        error('opts.directions is not +1 or -1 for run %d',r);
    end
end
if ~isfield(opts,'ncycles')
    error('opts.ncycles not supplied');
end
if ~isfield(opts,'TR')
    error('opts.TR not supplied');
end
% optional fields
if ~isfield(opts,'delay')
    disp('no hemodynamic delay');
    opts.delay=0;
end
if ~isfield(opts,'detrend')
    disp('not detrending');
    opts.detrend=0;
elseif (opts.detrend ~= 0) && (opts.detrend ~= 1)
    error('opts.detrend needs to be 0 or 1');
end
if ~isfield(opts,'stderr_paired')
    opts.stderr_paired=0;
end
if ~isfield(opts,'stderr_paired_nohemo')
    opts.stderr_paired_nohemo=0;
end

% temp while testing whether we need freesurfer hemo/direction correction
% when averaging pairs (which seems to do the equivalent)
if opts.stderr_paired_nohemo
    opts.stderr_paired=1; % user only need set one or the other
end

if (nargout < 2)
    error('not enough output arguments. supply at least phase,ifund.');
end

do_amp = nargout > 2;
do_pvalue = nargout > 3;
do_stderr = nargout > 4;

%% If doing standard error, check method
if do_stderr && opts.stderr_paired
    posruns=find(opts.directions == +1);
    negruns=find(opts.directions == -1);
    numpos=length(posruns);
    numneg=length(negruns);
    numpaired=min(numpos,numneg);
    fprintf('stderr_paired: found %d paired runs\n',numpaired);
    fprintf('stderr_paired: the following runs will be paired together:\n');
    for r=1:numpaired
        fprintf('\t%d + %d\n',posruns(r),negruns(r));
    end
    if sum(opts.directions)
        warn('stderr_paired: directions unbalanced, extra runs will be ignored');
    end
end

%% Compute some basic numbers %%%
ntp = datasize(1);
Trun = opts.TR * ntp;
fundamental = opts.ncycles/Trun;

%% Get the fft index of the fundamental %%
df = 1/(ntp*opts.TR); % frequency increment
fr = fundamental/df + 1; % ratio of frequency to increment
if( rem(fr,1) ~= 0 )
  ifund = round(fr);
else
  ifund = fr;
end

%% Compute the fft indices of the harmonics (excl fund) %%%
top_harm = floor(ntp/2);
iharm = ifund+opts.ncycles:opts.ncycles:top_harm;
iharm = iharm(1:2);

%% Get the fft indicies of the noise, exclude first 3 and +/- harm %%
tmp = ones(top_harm,1);
tmp(1:3)   = 0;
tmp(ifund)   = 0;
tmp(ifund-1) = 0;
tmp(ifund+1) = 0;
tmp(iharm)   = 0;
tmp(iharm-1) = 0;
tmp(iharm+1) = 0;
inoise = find(tmp==1);

%% Compute the degrees of freedom %%
dof = (2 * length(inoise) - opts.detrend) * nruns;

%% phase of the delay %%
ph_delay = opts.delay * (2*pi)* fundamental;

if do_stderr
    Nv = datasize(2);
    cycle_tp = floor(ntp/opts.ncycles);
    %% get fundamental index for when leaving
    %% out one cycle
    sub_tp = ntp-cycle_tp;
    sub_trun = opts.TR * sub_tp;
    sub_fund = (opts.ncycles-1)/sub_trun;
    sub_df = 1/(sub_tp*opts.TR);
    sub_fr = sub_fund/sub_df + 1;
    if( rem(fr,1) ~= 0 )
        sub_ifund = round(sub_fr);
    else
        sub_ifund = sub_fr;
    end
    sub_ph_delay = opts.delay * (2*pi) * sub_fund;
    realsamples = zeros(Nv,opts.ncycles,nruns);
    imagsamples = zeros(Nv,opts.ncycles,nruns);
end

sum_real_signal = 0;
sum_imag_signal = 0;
sum_noise_var   = 0;
for r = 1:nruns
    fprintf('starting run %d/%d ...\n',r,nruns);
    if loadruns
        f = this_run;
    else
        f = squeeze(opts.data(:,:,r));
    end
    f2_fft = multi_fft(f,opts.detrend,opts.directions(r),ph_delay);
    if do_stderr
        for c = 1:opts.ncycles
            fprintf('stderr: creating samples, leaving out cycle %d/%d ...\n',c,opts.ncycles);
            if c>1
                beforeTRs=1:(c-1)*cycle_tp;
            else
                beforeTRs=[];
            end
            if c<opts.ncycles
                afterTRs=c*cycle_tp+1:opts.ncycles*cycle_tp;
            else
                afterTRs=[];
            end
            fc=[f(beforeTRs,:);f(afterTRs,:)];
            if opts.stderr_paired_nohemo
                % try without delay/direction correction since averaging
                % opposing directions together
                fc2_fft = multi_fft(fc,opts.detrend); 
            else
                fc2_fft = multi_fft(fc,opts.detrend,opts.directions(r),sub_ph_delay);
            end
            fc=[];
            realsamples(:,c,r) = real(fc2_fft(sub_ifund,:));
            imagsamples(:,c,r) = imag(fc2_fft(sub_ifund,:));
            fc2_fft=[];
        end
    end
    f=[];
    %% Extract Real/Imag of Signal, use the rest to estimate noise %%
    sum_real_signal = sum_real_signal + real(f2_fft(1:top_harm,:));
    sum_imag_signal = sum_imag_signal + imag(f2_fft(1:top_harm,:));
    sum_noise_var   = sum_noise_var + mean(abs(f2_fft(inoise,:)).^2);
    f2_fft=[];
    
    fprintf('completed run %d/%d ...\n',r,nruns);
    % load next run if doing it that way
    if loadruns && (r < nruns)
        disp('loading next run...');
        load(opts.data{r+1});
    end
end %% loop over number of runs %%

%% calculate results %%
% amplitude
real_signal = sum_real_signal/nruns;
imag_signal = sum_imag_signal/nruns;
if do_amp
    amp = sqrt( real_signal.^2 + imag_signal.^2 );
end

% phase
u = real_signal + sqrt(-1)*imag_signal;
phase = angle(u);

% p
if do_pvalue
    var_noise = sum_noise_var/nruns;
    var_noise(var_noise==0) = 10^10;
    F = (abs(u(ifund,:).^2))./(var_noise/nruns);
    z = dof./(dof + 2 * F); % see Ftest.m for sigf computation
    p = betainc(z, dof/2, 1/2);
    mlog10p = -log10(p);
    mlog10p(isinf(mlog10p))=50;
end

% stderr
if do_stderr
    stderr = zeros(1,Nv);
    if opts.stderr_paired
        nsamples=numpaired*opts.ncycles;
        fprintf('stderr: calculation from %d *paired* samples per voxel...\n',nsamples);
    else
        nsamples=nruns*opts.ncycles;
        fprintf('stderr: calculation from %d samples per voxel...\n',nsamples);
    end
    diff=zeros(1,nsamples);
    stdev=zeros(1,Nv);
    sub_real_signal = zeros(1,Nv);
    sub_imag_signal = zeros(1,Nv);
    for v=1:Nv
        sub_real_signal(v) = sum(realsamples(v,:));
        sub_imag_signal(v) = sum(imagsamples(v,:));
    end
    sub_real_signal = sub_real_signal / nsamples;
    sub_imag_signal = sub_imag_signal / nsamples;
    for v=1:Nv
        %a=[real_signal(ifund,v);imag_signal(ifund,v)];
        a=[sub_real_signal(v);sub_imag_signal(v)];
        norma=norm(a);
        s=1;
        if opts.stderr_paired
            for c=1:opts.ncycles
                for r=1:numpaired
                    sumpaired_real=realsamples(v,c,posruns(r))+realsamples(v,c,negruns(r));
                    sumpaired_imag=imagsamples(v,c,posruns(r))+imagsamples(v,c,negruns(r));
                    b=[sumpaired_real;sumpaired_imag];
                    cosdiff = dot(a,b)/(norma*norm(b));
                    diff(s) = acos(cosdiff);
                    s=s+1;
                end
            end
        else
            for c=1:opts.ncycles
                for r=1:nruns
                    b=[realsamples(v,c,r);imagsamples(v,c,r)];
                    cosdiff = dot(a,b)/(norma*norm(b));
                    diff(s) = acos(cosdiff);
                    s=s+1;
                end
            end
        end
        stdev(v)=sqrt(sum(diff.^2)/nsamples);
        if ~mod(v,1000)
            fprintf('%d/%d\n',v,Nv);
        end
    end
    stderr = stdev / sqrt(nsamples);
else
    realsamples=[];
    imagsamples=[];
end

end

%% multi_fft
function f2_fft = multi_fft(f,detrend,direction,ph_delay)

if exist('detrend') && (detrend > 0)   
    f = detrend2(f);
end

% Compute fft, and mag/phase %%
% Use conj so as to report phases as positive %
f_fft   = conj(fft(f));
mag_fft = abs(f_fft);
phz_fft = angle(f_fft);

if exist('ph_delay')
    % Rotate by specified delay %%
    phz_fft_tmp = phz_fft - ph_delay;
end
if exist('direction')
    % Modify the phase for negative direction %%
    phz_fft = direction*phz_fft_tmp;
end

% Recompute the Real/Imag fft %%;
f2_fft = mag_fft.*cos(phz_fft) + sqrt(-1)*mag_fft.*sin(phz_fft);

end

%% detrend for order 2; a specialized version of fmri_detrend.m
function ypost = detrend2(y)

nTP = size(y,1);

% Construct columns for detrending %
t = [0:nTP-1]'; 
f = [];
for n = 0:1
  f = [f t.^n];
end
SCM = f;                    % use only detrend columns
h = inv(SCM'*SCM)*SCM'*y;	% estimate trend and HDR simultaneously 
coeff = h(1:2,:);         % extract trend coeff
ypost = y - f*coeff;        % remove trend

end
