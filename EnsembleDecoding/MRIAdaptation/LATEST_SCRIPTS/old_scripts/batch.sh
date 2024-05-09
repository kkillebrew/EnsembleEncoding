#!/bin/tcsh
# this script should be run from ~/MR_DATA/CLAB/[experiment]/
#
# quick script for batch processing of some datasets in
# subject directories.
echo "== $0 starting"


set origdir = `pwd`

# ( AJ KM KK GG JV NS RS )
foreach s ( AJ )
    echo; echo "== processing $s data..."

    #------------------------------------------------
    # always start from where you executed the script
    cd $origdir

    #--------------------------
    # move to subject directory
    cd $s

    #-------------------------------------------------------------------
    # do something - comment out anything that you don't want to run now
    #./scripts/mt0_to3d.sh; # convert dicoms
    #cd preprocessing; ../scripts/mt1_tscvr.sh; # time-slice correction and motion correction
    #cd preprocessing; ../scripts/mt3_anat.sh; # anatomical alignment
    #cd preprocessing; ../scripts/mt4_glmprep.sh; # preprocessing for a GLM
    #cd analysis; ../scripts/mt5_glmsurf.sh; # run surface-based GLM
end

echo "== $0 complete"
exit 0
