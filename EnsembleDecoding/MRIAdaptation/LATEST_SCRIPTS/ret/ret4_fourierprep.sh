#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/preprocessing/
#
# N.B. For retinotopy, we will run a Fourier analysis to extrac the signal at
#      a particular frequency (which matches the stimulus).  No need for signal
#      scaling (i.e., normalization).  But we want to detrend the timeseries
#      to clean up some of the low-freq noise that is inherent in fMRI data.
#      (note that detrending occurs in 3dDeconvolve for a GLM analysis).
#
#      This script implements:
#      1. Detrending
#      2. Volume Smoothing (optional, can be set to zero)
#      3. Project to the surface.
#      3. Copy final surface files to ../analysis/ (will be input to Fourier analysis)
echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# local variables


# for quick commenting
if ( 0 ) then
endif
set curfunc = "_tscvr";



#____________________________________
# detrending
foreach run ($ALLRUNS)
    echo; echo "== detrending run $run"

   # you *could* detrend motion correction params here, but it often leads to noisy output, especially
    # if there is very little motion.
    #   -vector ${SUBJ}_${run}_tscvr.1D'[1..6]' \
   3dDetrend \
       -prefix ${SUBJ}_${run}${curfunc}dt \
       -polort $POLORT \
       ${SUBJ}_${run}${curfunc}+orig

    # 3dDetrend will remove the mean of the signal, along with higher-order signals, so we want to add back the mean.
    # N.B. the mean may have already been calculated in the anatomical alignment script.
    if ( ! -e ${SUBJ}_${run}${curfunc}_mean+orig.HEAD ) then
        3dTstat \
	    -prefix ${SUBJ}_${run}${curfunc}_mean \
	    ${SUBJ}_${run}${curfunc}+orig
    endif

    # add mean back to detrending
    3dcalc \
       -a ${SUBJ}_${run}${curfunc}dt+orig \
	-b ${SUBJ}_${run}${curfunc}_mean+orig \
	-prefix ${SUBJ}_${run}${curfunc}dtm \
	-expr "a+b"
end
set curfunc = ${curfunc}dtm;



# loop over every run
set base_curfunc = $curfunc; # we'll need to reset this back to the original value for different smoothing levels
foreach run ($ALLRUNS)
    # loop over every volume-smoothing value (may be zero)
    foreach sm ($VOLSMOOTHS)
	set curfunc = $base_curfunc; # reset curfunc for new smoothing level

        #_________________________
	# smoothing at $VOLSMOOTHS
	echo; echo "== smoothing run $run with $sm mm kernal"
	if ( $sm == 0 ) then
	    # for zero smoothing, we still want a file with "sm0" appended, just to be explicit.
	    # so although this is really of a waste of disc space, we'll make a copy of the curfunc.
	    3dcopy ${SUBJ}_${run}${curfunc}+orig ${SUBJ}_${run}${curfunc}sm$sm+orig
	else
	    3dmerge \
		-1blur_fwhm $sm \
		-doall \
		-prefix ${SUBJ}_${run}${curfunc}sm$sm \
		${SUBJ}_${run}${curfunc}+orig
	endif
	set curfunc = ${curfunc}sm$sm


        #______________________________________________________________
	# project smoothed data to surface (separately for lh and rh)
	foreach hs ($HEMIS)
	    # project to surface
	    echo; echo "== projecting $hs data to surface for run $run ($sm mm sm) to .niml.dset (tmp)"
	    3dVol2Surf \
		-spec ${SUMADIR}/${SUBJ}_${hs}.spec \
		-surf_A ${hs}.pial.asc \
		-surf_B ${hs}.smoothwm.asc \
		-sv ../analysis/${SUBJ}_NoSkull_SurfVol_Alnd_Exp+orig \
		-grid_parent ${SUBJ}_${run}${curfunc}+orig \
		-map_func ave \
		-oob_value -0 \
		-f_steps 10 \
		-f_index voxels \
		-out_niml ${SUBJ}_${run}${curfunc}.$hs.niml.dset

	    # convert to .1D for multi_retino.m script
	    echo; echo "== converting $hs data for run $run ($sm mm sm) to .1D.dset"
	    ConvertDset \
		-o_1D \
		-prepend_node_index_1D \
		-input ${SUBJ}_${run}${curfunc}.$hs.niml.dset \
		-prefix ${SUBJ}_${run}${curfunc}.$hs.1D.dset

	    # remove .niml.dset since they are so dang large!
	    # N.B. you could use -out_1D with 3dVol2Surf, but the resulting .1D.dset files
	    #      have more columns and are about 30% larger.  So using -out_niml and then
	    #      ConvertDset, while more processing time, saves a significant amount of
	    #      space.
	    echo; echo "== removing .niml.dset tmp file"
	    rm -f ${SUBJ}_${run}${curfunc}.$hs.niml.dset

	    # move (copy?) final data to analysis directory
	    mv -f ${SUBJ}_${run}${curfunc}.$hs.1D.dset ../analysis/
	end
    end
end


echo; echo "== $0 complete"
exit 0
