#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
#
# this is a template version of a shell script that will create local volume
# ROIs from the surface ROI files located in the local rois directory for the
# current experiment.
#
# A separate file is created for ROIs in the left and right hemispheres (because of
# the separation of the surface ROI files) and for each set of rois (e.g., retinotopy,
# object and mt localizer, etc.)
#
# To obtain a local copy of the surface rois, see roi1_copy_surfrois_locally.sh
#
# After running this script, you can extract the mean response from an ROI with
# something like the following (for example, see 3dmaskave -help for more info):
#      3dmaskave -mask KK_objROIs_lh+orig -quiet -mrange 2 2 KK_tscvrsm2_norm_bucket+orig. > ffa_lh.txt
# Alternatively, you can use Matlab and BrikLoad (part of the afni matlab toolbox) to load
# both the data and the mask into Matlab and manipulate/plot the data as you wish.

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# Local Variables
set cortical_make  = 0; # should we make a cortical mask ROI? (it takes ~1 min/hemisphere and is only useful for certain circumstances)
set cortical_force = 0; # should we re-create the cortical rois, even if the files already exist? (must have cortical_make==1)

# the default preprocessing stream creates an automask (see prep3_anat.sh or equivilent) based on an EPI image,
# so we can use that as an experiment-universal gridparent, which defines the resolution and "grid" for the output.
# N.B. if you don't have an "automask", just replace this with any EPI that is aligned to the surface anatomy
set gridparent = ${SUBJ}_automask; # the automask can be used in all circumstances (fieldmap or no fieldmap, different analysis 

# this is the experimental volume that is aligned to the surface anaomical (i.e., output of @SUMA_AlignToExperiment)
set al_anat = ${SUBJ}_NoSkull_SurfVol_Alnd_Exp; # suffix for surface anatomy already aligned to experiment (w/ or w/out 'NoSkull_')

# using a local copy of the surface ROIs forces you to keep a local copy of the ROI files used for each experiment,
# just in case things change in the surfaces directory down the road.
# N.B. the only exception is for the 'custom' rois, which will be searched for in the current directory (i.e.,
#      the analysis subdirectory of each subject, where this script should be executed from)
set roidir = "../../rois/$SUBJ"; # no trailing "/"
echo "***== Using local roidir: $roidir"


# for quick commenting
if (0) then
endif

#_________________________________________________________________
# Convert Surface ROIs into Volume Space
echo; echo "== ROI Creation";
foreach region ('ret' 'mt-obj') # 'custom' 'cortical'
    # additional check for cortical roi
    #    the cortical mask only needs to be done once because it should never change,
    #    although there is an option to force doing it again (it takes a few mins/hs)
    if ( $region == 'cortical') then
	# did user request cortical ROI?
	if ( ! $cortical_make ) then
	    continue
	endif
	# does file exist and user did not request force remaking cortical roi?
	if ( -e ${SUBJ}_corticalROIs+orig.HEAD && ! $cortical_force) then
	    continue
	endif
    endif

    foreach hs ($HEMIS)
	echo " - ${region}-$hs"

	# figure out what the output file will look like
	set outprefix = ${SUBJ}_${region}ROIs_${hs}

	# remove previous output files
	# N.B. there is no check at this stage, since you need to first use copy_surfrois_locally.sh,
	#      which has a built-in overwrite check
	if ( -e ${outprefix}+orig.HEAD ) then
	    rm -f ${outprefix}+orig.*
	endif

	# roi file (full path)
	if ($region == 'custom') then
	    # the "custom" label is meant to be a quick way to define ROIs based on the current experiment
	    set roif = ./${region}-${hs}.1D.dset
	else
	    # shared rois in subject-specific surface directory (probably copied locally)
	    set roif = ${roidir}/${region}-${hs}.1D.dset
	endif
	    
	if (-e $roif) then
	    3dSurf2Vol \
		-spec ${SUMADIR}/${SUBJ}_${hs}.spec \
		-surf_A ${SUMADIR}/${hs}.smoothwm \
		-surf_B ${SUMADIR}/${hs}.pial \
		-sv ${al_anat}+orig \
		-grid_parent ${gridparent}+orig \
		-sdata_1D $roif \
		-map_func mode \
		-f_steps 10000 \
		-f_index voxels \
		-prefix ${outprefix}
	else
	    echo "   ***WARNING: skipping $hs@$region for $SUBJ. $roif not found"
	endif
    end

    if ( $region == 'cortical') then
	# merge lh and rh cortical masks into one file
	if ( -e ${SUBJ}_corticalROIs+orig.HEAD ) then
	    rm -f ${SUBJ}_corticalROIs+orig.*
	endif
	3dcalc -a ${SUBJ}_corticalROIs_lh+orig -b ${SUBJ}_corticalROIs_rh+orig -expr 'or(a,b)' -prefix ${SUBJ}_corticalROIs
    endif
end


echo; echo "== $0 complete"
exit 0
