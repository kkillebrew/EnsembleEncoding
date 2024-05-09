#!/bin/tcsh
# this script should be run from ~/MR_DATA/CLAB/[experiment]/$SUBJ/analysis/
#
# This script will execute a volume-based REMLfit (GLM accounting for temporal auto-correlation)
#
# N.B. 3dREMLfit is the command to run a GLM accounting for temporal auto-correlation
#      in the data.  To use it, we first run the command we would use with 3dDeconvolve,
#      but we tell 3dDeconvolve to stop (just do the prep work and write out some files):
#          -x1D_stop
#      3dDeconvolve automatically creates a [prefix].REML_cmd txt file that you can
#      execute to run the appropriate 3dREMLfit command.
echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# local variables
set overwrite = 0; # overwrite bucket output files if they already exist?  if not, just stop script


foreach sm ( $VOLSMOOTHS )
    echo; echo "== starting GLM for smoothing of $sm mm"

    set curfunc = "_tscvrsm${sm}_norm"; # fully specifies all preprocessing (e.g., volume or surface smoothing)

    # get a list of all preprocessed files that will serve as input to the GLM
    set glminput = ""
    foreach run ($ALLRUNS)
	set glminput = "$glminput ${SUBJ}_${run}${curfunc}+orig"
    end

    # verify output bucket doesn't exist.  if it does, and local variable overwrite is 1, delete it.
    set output_prefix = ${SUBJ}${curfunc}_bucket; # do NOT include the _REML suffix that 3dREMLfit automatically adds (or +orig)
	if ( -e ${output_prefix}_REML+orig.HEAD ) then
	    echo "== output file ${output_prefix}_REML+orig.HEAD exists"
	    if ( $overwrite ) then
		echo "   overwriting..."
		rm -f ${output_prefix}_REML*+orig.HEAD ${output_prefix}_REML*+orig.BRIK*
	    else
		echo "   stopping (either delete ${output_prefix}_REML+orig.HEAD/BRIK or set overwrite to 1 in $0)"
		exit 1
	    endif
	endif

    
    # setup the GLM
    # N.B. could add a mask using -mask ${SUBJ}_automask+orig, but only makes sense for volume data
    3dDeconvolve \
	-input $glminput \
	-CENSORTR '*:0-5' \
	-polort 2 \
	-mask ${SUBJ}_automask+orig \
	-num_stimts 10 \
	-basis_normall 1 \
	-local_times \
	-stim_file 1 ${SUBJ}_mcparams.1D'[1]' \
	-stim_label 1 roll \
	-stim_base 1 \
	-stim_file 2 ${SUBJ}_mcparams.1D'[2]' \
	-stim_label 2 pitch \
	-stim_base 2 \
	-stim_file 3 ${SUBJ}_mcparams.1D'[3]' \
	-stim_label 3 yaw \
	-stim_base 3 \
	-stim_file 4 ${SUBJ}_mcparams.1D'[4]' \
	-stim_label 4 dIS \
	-stim_base 4 \
	-stim_file 5 ${SUBJ}_mcparams.1D'[5]' \
	-stim_label 5 dRL \
	-stim_base 5 \
	-stim_file 6 ${SUBJ}_mcparams.1D'[6]' \
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
	-x1D $output_prefix.xmat.1D \
	-x1D_stop \
	-tout
	
    # run 3dREMLfit command that was produced by 3dDeconvolve
    # N.B. 3dREMLfit will automatically run in parallel across all of the processors
    #      on the current computer.  If this is undesirable, you should uncomment the
    #      following line:
    #      setenv OMP_NUM_THREADS 1; # uncomment this line to NOT use multi-thread processing for 3dREMLfit
    tcsh $output_prefix.REML_cmd
end
    
echo; echo "== $0 complete"
exit 0

