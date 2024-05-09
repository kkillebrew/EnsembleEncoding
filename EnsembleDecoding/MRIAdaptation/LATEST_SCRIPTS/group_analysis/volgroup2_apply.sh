#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/$SUBJ/analysis/


#
# this script is a basic outline of how to apply the same spatial normalization
# of an anatomical into Talairach space to other datasets, such as EPIs or GLM
# buckets in AFNI.  see group1_spatialnorm.sh for info on the initial transformation.

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# 1. local variables
set curanat  = "_NoSkull_SurfVol_Alnd_Exp"; # anatomical prefix (no subj or +tlrc) of the already Talairached anatomy
set isores   = 3; # desired isotropic voxel resolution of transformed volumes


# 2. apply spatial transformation to epi or bucket
# N.B. if you get an "if: Expression Syntax." error, it may be that your input is not defined correctly and @auto_tlrc can't find the file
foreach sm ( $VOLSMOOTHS )
    #set this_curfunc = $curfunc; # expand the smoothing ($sm) of the input file
    set curfunc  = "_tscvrsm"$sm"_norm_bucket_REML"; # target volume prefix (no subj or +orig) you want to transform

    # apply spatial transformation stored in the +tlrc anatomy to other datasets
    @auto_tlrc \
	-onewarp \
	-apar ${SUBJ}${curanat}+tlrc \
	-input ${SUBJ}${curfunc}+orig \
	-dxyz $isores
end


echo; echo "== $0 complete"
exit 0
