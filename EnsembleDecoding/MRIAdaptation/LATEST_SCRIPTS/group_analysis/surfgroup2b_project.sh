#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
#
# this script provides a basic outline of how to project volume data directly to a subject's
# icosahedron standard surface space, which can serve as input to a group analysis.

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# 1. local variables
set icoprefix = std.141; # 'std.141' or 'std.60' : determines which icosahedron (resolution) surface to use.  use 141 unless you specifically want a lower resolution space


# 2. project volume BRIK to icosahedron surface space
foreach sm ( $VOLSMOOTHS )
    #set this_curfunc = $curfunc; # expand the smoothing ($sm) of the input file
    set curfunc  = "_tscvrsm"$sm"_norm_bucket_REML"; # target volume prefix (no subj or .niml.dset, etc.) you want to transform

    foreach hs ( $HEMIS )
	echo "== $hs"

	set this_input  = ${SUBJ}${curfunc}+orig;
	set this_output = $icoprefix.${SUBJ}${curfunc}.$hs.niml.dset;
	echo "   $this_input -> $this_output"

	# project to surface
	3dVol2Surf \
	    -spec ${SUMADIR}/${icoprefix}.${SUBJ}_${hs}.spec \
	    -surf_A ${icoprefix}.${hs}.pial.asc \
	    -surf_B ${icoprefix}.${hs}.smoothwm.asc \
	    -sv ${SUBJ}_NoSkull_SurfVol_Alnd_Exp+orig \
	    -grid_parent $this_input \
	    -map_func ave \
	    -oob_value -0 \
	    -f_steps 10 \
	    -f_index voxels \
	    -out_niml $this_output
    end
end

echo; echo "== $0 complete"
exit 0
