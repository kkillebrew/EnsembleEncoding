#!/bin/tcsh
# this script should be run from  /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/runwise_glm
#
# This script will execute a surface-based GLM using 3dDeconvolve or 3dREMLfit,
# separately for each run#
#
# N.B. 3dREMLfit is the command to run a GLM accounting for temporal auto-correlation
#      in the data.  To use it, we first run the command we would use with 3dDeconvolve,
#      but we tell 3dDeconvolve to stop (just do the prep work and write out some files):
#          -x1D_stop
#      3dDeconvolve automatically creates a [prefix].REML_cmd txt file that you can
#      execute to run the appropriate 3dREMLfit command.
echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# local variables
set overwrite = 0; # overwrite bucket output files if they already exist?  if not, just stop script
set use_REMLfit = 1; # boolean, should we use 3dREMLfit? you probably should use REMLfit, but there are special circumstances in which 3dDeconvolve may be beneficial in terms of speed. see 3dDeconvolve -help and 3dREMLfit -help for more info and ask others if you aren't sure what the difference is.
set ncores = 4; # how many CPU cores should be utilized for parallel processing?  N.B. if you are only running one instance of this script at a time on a single computer, you can speed things up by taking advantage of parallel processing by setting ncores = the number of cores on your computer.  however, if you run multiple instances of this script simultaneously, you may end up trying to use more cores than are available if ncores>1, which will cause a performance drop.


if ( $use_REMLfit ) then
    set REMLtag = "_REML";
else
    set REMLtag = "";
endif

set sm = $VOLSMOOTHS[1]; # we'll only worry about 1 smoothing level for this quality check.  you can change the index to run this script on a different smoothing level (see the order you defined in global_vars.sh)
set curfunc = "_tscvrsm${sm}_norm"; # fully specifies all preprocessing (e.g., volume or surface smoothing)

echo; echo "== starting run-wise GLMs using smoothing of $sm mm"


set i = 0;
foreach run ($ALLRUNS)
    @ i = $i + 1;

    # setup tmp stim_time files with just the desired run extracted
    # N.B. this requires some customization for your own experiment in terms of
    #      what regressors are defined and how the labeling conventions you use.
    foreach reg ( face house genobject scram )
	set tmp = `head -$i ../../scripts/stim_times/${reg}_times.1D | tail -1`
	if ( "$tmp" == "*" ) then
	    # the first run in a stim_times file must be ** (not *) to indicate no events for that run
	    set tmp = "**";
	endif
	echo "$tmp" > $run.${reg}_times.1D
    end


    # now run the GLM using only this run...
    foreach hs ( $HEMIS ) 

	# get a list of all preprocessed files that will serve as input to the GLM
	set glminput = "../${SUBJ}_${run}${curfunc}.${hs}.niml.dset"

	# verify output bucket doesn't exist.  if it does, and local variable overwrite is 1, delete it.
	set output_prefix = ${SUBJ}_${run}${curfunc}_bucket.${hs}; # do NOT include +orig or _REML tag
	set output = ${output_prefix}${REMLtag}.niml.dset; # add _REML via $REMLtag, if desired
	if ( -e $output ) then
	    echo "== output file $output exists"
	    if ( $overwrite ) then
		echo "   overwriting..."
		rm -f $output
	    else
		echo "   stopping (either delete $output or set overwrite to 1 in $0)"
		exit 1
	    endif
	endif
	

	# SETUP the 3dDeconvolve/3dREMLfit command using 3dDeconvolve -x1D_stop
	# N.B. this requires some customization beyond that in the vol5_glm.sh 
	#      script for run-wise GLMs.  Namely, motion parameters need to be
	#      indexed run-by-run.  These are located in the preprocessing directory.
	#      Stimtimes should refer to those in the current directory that were 
	#      created for each run above.
	# N.B. depending on your goal for the run-wise GLMs, you may want to skip
	#      some or all contrasts, to save a little time.
	3dDeconvolve \
	    -input $glminput \
	    -CENSORTR '*:0-5' \
	    -polort $POLORT \
	    -num_stimts 10 \
	    -basis_normall 1 \
	    -local_times \
	    -stim_file 1 ../../preprocessing/${SUBJ}_${run}_tscvr.1D'[1]' \
	    -stim_label 1 roll \
	    -stim_base 1 \
	    -stim_file 2 ../../preprocessing/${SUBJ}_${run}_tscvr.1D'[2]' \
	    -stim_label 2 pitch \
	    -stim_base 2 \
	    -stim_file 3 ../../preprocessing/${SUBJ}_${run}_tscvr.1D'[3]' \
	    -stim_label 3 yaw \
	    -stim_base 3 \
	    -stim_file 4 ../../preprocessing/${SUBJ}_${run}_tscvr.1D'[4]' \
	    -stim_label 4 dIS \
	    -stim_base 4 \
	    -stim_file 5 ../../preprocessing/${SUBJ}_${run}_tscvr.1D'[5]' \
	    -stim_label 5 dRL \
	    -stim_base 5 \
	    -stim_file 6 ../../preprocessing/${SUBJ}_${run}_tscvr.1D'[6]' \
	    -stim_label 6 dAP \
	    -stim_base 6 \
	    -stim_times 7 ./$run.face_times.1D 'BLOCK(15,1)' \
	    -stim_label 7 face \
	    -stim_times 8 ./$run.house_times.1D 'BLOCK(15,1)' \
	    -stim_label 8 house \
	    -stim_times 9 ./$run.genobject_times.1D 'BLOCK(15,1)' \
	    -stim_label 9 genobject \
	    -stim_times 10 ./$run.scram_times.1D 'BLOCK(15,1)' \
	    -stim_label 10 scram \
	    -gltsym 'SYM: 3*face -house -scram -genobject' \
	    -glt_label 1 face_vs_all \
	    -gltsym 'SYM: 3*house -face -scram -genobject' \
	    -glt_label 2 house_vs_all \
	    -gltsym 'SYM: 3*genobject -face -scram -house' \
	    -glt_label 3 genobject_vs_all \
	    -gltsym 'SYM: face  -house' \
	    -glt_label 4 face_vs_house \
	    -gltsym 'SYM: genobject  -scram' \
	    -glt_label 5 genobject_vs_scram \
	    -bucket $output_prefix \
	    -x1D ${output_prefix}${REMLtag}.xmat.1D \
	    -xjpeg ${output_prefix}${REMLtag}.xmat \
	    -tout \
	    -jobs $ncores \
	    -x1D_stop
	# N.B. the "-x1D_stop" argument MUST be the last argument of 3dDeconvolve for this script
	#      to work properly.


	# EXECUTE the 3dDeconvolve or 3dREMLfit command, depending on use_REMLfit
	if ( $use_REMLfit ) then
	    # use 3dREMLfit (to account for temporal autocorrelations in the data)
	    #    run 3dREMLfit command that was produced by 3dDeconvolve
	    #
	    # N.B. 3dREMLfit will automatically run in parallel across all of the processors
	    #      on the current computer, unless we manually set the environment variable
	    #      OMP_NUM_THREADS
	    setenv OMP_NUM_THREADS $ncores;
	    tcsh $output_prefix.REML_cmd
	else
	    # use the original 3dDeconvolve
	    #
	    # extract the exact 3dDeconvolve command written above, which is stored as a comment
	    # at the top of the REML_cmd script produced by 3dDeconvolve
	    set glmcmd = `head -1 $output_prefix.REML_cmd`
	    # remove the "# " at the begining of the line, and the " -x1D_stop" at the end
	    set glmcmd = `echo "$glmcmd" | sed 's/# //' | sed 's/ -x1D_stop//'`
	    # execute the command (N.B. the double quotes around $glmcmd are necessary or the shell 
	    #                           will misinterpret some special characters embedded in the
	    #                          command, which will result in a "No match" message)
	    eval "$glmcmd"
	endif

    end
end


# get a copy of the NoSkull_SurfVol_Alnd_Exp, if we don't have one already
if ( ! -e ${SUBJ}_NoSkull_SurfVol_Alnd_Exp+orig.HEAD ) then
    3dcopy ../${SUBJ}_NoSkull_SurfVol_Alnd_Exp+orig ./
endif


echo; echo "== $0 complete"
exit 0
