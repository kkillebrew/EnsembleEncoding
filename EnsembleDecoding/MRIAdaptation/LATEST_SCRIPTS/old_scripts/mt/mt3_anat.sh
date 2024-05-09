#!/bin/tcsh
# this script should be run from ~/MR_DATA/CLAB/[experiment]/$SUBJ/preprocessing/
echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# local variables
set manual_nudge = 0; # should we open AFNI to allow for manual nudging of the surfvol before alignment?  otherwise, use a default "coarse" pass using 3dAllineate (see below)
set deoblique_anat = 0; # should we de-oblique the anatomical as part of the coarse alignement?  sometimes this helps, but not always.  default is no (0).


# for quick commenting
if ( 0 ) then
endif
set curfunc = "_tscvr"
set curanat = "_surfvol"; # should always be "_surfvol"; this script assumes that you have copied a version of the NoSkull_SurfVol to the ./orig/${SUBJ}_surfvol directory, and potentially manually nudged it to be close to alignment with the motion corrected EPIs.


#______________________________________________________________________________
# get a copy of the original data.
# by keeping the original data in ./orig/, you can reset the preprocessing/analysis
# by deleting all files in ./analysis/, without fear of loosing the original data or
# having to re-convert from dicom.
cp ../orig/${SUBJ}_surfvol+orig.* ./


#____________________________________
# get grand-average EPI
# since we've already aligned all of our functionals, we can average them all together and use
# a single average EPI frame (which visibly has better structure in many cases) for alignment with our 
# anatomical.

# average over timepoints (do this first, since number of TPs may differ across runs)
echo; echo "== calculating grand mean EPI volume"
foreach run ($ALLRUNS)
    3dTstat \
	-prefix ${SUBJ}_${run}${curfunc}_mean+orig \
	${SUBJ}_${run}${curfunc}+orig.HEAD
end

# average over runs (timepoint by timepoint, but there is only 1 TP/run now)
3dMean \
    -prefix ${SUBJ}_allruns${curfunc}_mean \
    ${SUBJ}_r??${curfunc}_mean+orig.HEAD
set meanEPI_for_automask = ${SUBJ}_allruns${curfunc}_mean+orig


#----------------------------------------------------------
# surfvol to epi alignment
# implementing a double-alignment: first pass is "coarse" (and potentially manual), second-pass is "fine"
#
# N.B. by using the option "-Allineate_opts -warp shift_rotate" we are doing a rigid-body, 6-parameter, linear alignment
# N.B. If the following fails, consider...
#      - for failure at the 3dSkullStrip stage for the EPI, try -epi_strip 3dAutomask (e.g., helps with very smaller coverage of brain)
#      - try -partial_coverage for smaller coverage
#      - see -AddEdge for some additional information to compare alignment (see align_epi_anat.py -help)

echo; echo "== starting coarse alignment (first-pass)"
if ($manual_nudge) then
    # if the default automatic coarse alignment is not working well (and you don't want to spend time tweaking the default parameters)
    # you can implement a manual coarse alignment using the NudgeDataset plugin of AFNI.  This code will create the file you want to
    # manually nudge (_nudged), open AFNI, wait until you nudge the dataset and close AFNI, and then continue along with the fine
    # pass alignment.

    # make a copy of the surfvol that you will manually nudge
    3dcopy ${SUBJ}_surfvol+orig ${SUBJ}_surfvol_nudged+orig.

    setenv AFNI_DETACH NO; # don't let AFNI detach from terminal so we can nudge dataset before proceeding
    echo; echo "*** manually nudge surfvol_nudged dataset in AFNI to be close to the $curfunc of one run.  close AFNI to continue ***"
    afni
    setenv AFNI_DETACH YES; # back to default
    set curanat = ${curanat}_nudged
else
# the following is the default "coarse" alignment.  It uses 3dAllineate to get the surfvol close enough to the mean epi
    # for the fine alignment to work.
    # N.B. Previously, the coarse alignement was implemented using -giant_move of align_epi_anat.py.  But, because -giant_move
    #      resets -Allineate_opts, using -giant_move caused a non-linear (12 parameter) warping of the anatomical, even with 
    #      -Allineate_opts "-warp shift_rotate"
    #      Here, we are implementing something similar to -giant_move does, but not as elegantly and probably not over such
    #      a large search space.
    # N.B. equivilent -giant_move arguments for 3dAllineate are:
    #           -twobest 11 -twopass -VERB -maxrot 45 -maxshf 40 -fineblur 1(??) -source_automask+2
    #      but using these caused poor alignment on some test datasets for reasons that I do not fully understand.
    # N.B. you can emulate -giant_move and still get a rigid body transform with these options for align_epi_anat.py:
    #           -Allineate_opts "-weight_frac 1.0 -maxrot 45 -maxshf 40 -VERB -warp shift_rotate" -big_move -cmass cmass 
    # N.B. If you ever do use -giant_move, make sure to include -master_anat SOURCE so that the anatomical is not cropped to the size
    #      of the EPI, which will lead to subsequent failure of the alignment between the _al_al and SurfVol.


    # sometimes deobliquing the anatomical helps.  it usually gets it closer aligned with the EPI, if the EPIs were
    # collected at an oblique angle.  but this isn't always the case and usually we can deal with it without deobliquing
    # the anatomy.  set deoblique_anat = 1 (above) if automatic alignment fails and surfvol and the epi are rotated far
    # apart to begin with.
    if ( $deoblique_anat ) then
	3dWarp -verb -card2oblique ${SUBJ}_${REFRUN}+orig. -prefix ${SUBJ}${curanat}_obl+orig ${SUBJ}${curanat}+orig.
	set curanat = ${curanat}_obl
    endif 
    3dAllineate \
	-prefix ${SUBJ}${curanat}_coarse+orig \
	-base ${SUBJ}_allruns${curfunc}_mean+orig. \
	-master ${SUBJ}${curanat}+orig \
	-warp shift_rotate \
	${SUBJ}${curanat}+orig
    set curanat = ${curanat}_coarse
endif


# "fine" alignment
# now that the surfvol is "close" to the EPI, do another pass using the default align_epi_anat.py parameters
# N.B. Sometimes, for reasons unknown to me, this will fail miserably, and take a pretty-close alignment
#      between the EPI and the coarse-SurfVol and output something that is way off.  In that case, you can
#      try the following.  If you know that the input EPI and ANAT to this fine-pass are very close (as they
#      should be - you can visually check in AFNI), then limit the range of startings points for the alignment
#      search by updating the -Allineate_opts as follows (but note that you may want/need to play with the exact
#      values for -maxrot and -maxshf):
#          -Allineate_opts "-warp shift_rotate -maxrot 5 -maxshf 10"
echo; echo "== starting fine alignment (second-pass)"
align_epi_anat.py \
    -anat ${SUBJ}${curanat}+orig \
    -epi ${SUBJ}_allruns${curfunc}_mean+orig \
    -epi_base 0 \
    -volreg off \
    -tshift off \
    -deoblique off \
    -anat_has_skull no \
    -Allineate_opts "-warp shift_rotate"
set curanat = ${curanat}_al


#______________________________________________________________________________
# align high-res surface anatomical to epi-aligned anatomical
# N.B. align_epi_anat.py skull-strips the anatomical, so use NoSkull hi-res for surface alignment
# output is ${SUBJ}_[NoSkull_]SurfVol_Alnd_Exp+orig
echo; echo "== aligning surface volume"
@SUMA_AlignToExperiment \
    -align_centers \
    -strip_skull neither \
    -surf_anat ${SUMADIR}/${SUBJ}_NoSkull_SurfVol+orig \
    -exp_anat ${SUBJ}${curanat}+orig

# move (copy?) experiment-aligned surface volumne to ./analysis
mv -f ${SUBJ}_NoSkull_SurfVol_Alnd_Exp+orig.* ../analysis/



#______________________________________________________________________________
# create automask - just after motion correction/undistortion AND anatomical alignment,
# BUT before smoothing/filtering/normalization etc.
# this can be used to speed up 3dDeconvolve by ignoring the out-of-brain voxels
# create binary mask from average EPI brik
echo; echo "== creating automask"
3dAutomask \
    -prefix ${SUBJ}_automask \
    -dilate 3 \
    $meanEPI_for_automask

# move (copy?) automask and meanEPI for checking alignment (now that we've used it for the automask)
mv -f ${SUBJ}_automask+orig.* ../analysis/
mv -f ${meanEPI_for_automask}.* ../analysis/


echo; echo "== $0 complete"
exit 0
