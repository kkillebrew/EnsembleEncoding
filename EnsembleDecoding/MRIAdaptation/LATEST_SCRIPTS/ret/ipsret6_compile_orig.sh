#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/Retmapping/$SUBJ/analysis/
#
# This script will collect data from the original retinotopy scans and copy it to
# a subdirectory of the current directory, which is assumed to be a XXips IPS retinotopy
# analysis directory.
#
# IPS Retinotopy phase maps are re-labeled "IPS"
# Orig Retinotopy phase maps are labeled "ORIG"
# Orig Retinotopy preprocessed files for input into Fourier analysis are runs 90+
# The phase maps from the combination of orig and ips files are labeled "COMBO"

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# local variables
set outdir = "orig_ips_comparison"
mkdir $outdir


# for quick commenting
if ( 0 ) then
endif
set curfunc = "_tscvrdtmsm"; # DO NOT INCLUDE SMOOTHING #


# loop over hemispheres
foreach hs ($HEMIS)
    foreach sm ($VOLSMOOTHS)
	# 1. rename IPS phase files
	cp -f ${SUBJ}_polar${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_IPS_polar${curfunc}${sm}.${hs}.1D.dset

	# 2. copy ORIG phase files and rename
	cp -f ../../${SUBJ}/analysis/${SUBJ}_polar${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_RET_polar${curfunc}${sm}.${hs}.1D.dset
	cp -f ../../${SUBJ}/analysis/${SUBJ}_eccen${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_RET_eccen${curfunc}${sm}.${hs}.1D.dset

	# **ASSUMING 4 RUNS IN IPS AND ORIG SCANNING SESSIONS***
	# 4. copy IPS raw files
	cp -f ${SUBJ}_r01${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r01${curfunc}${sm}.${hs}.1D.dset
	cp -f ${SUBJ}_r02${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r02${curfunc}${sm}.${hs}.1D.dset
	cp -f ${SUBJ}_r03${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r03${curfunc}${sm}.${hs}.1D.dset
	cp -f ${SUBJ}_r04${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r04${curfunc}${sm}.${hs}.1D.dset

	# 3. copy ORIG raw files and rename
	cp -f ../../${SUBJ}/analysis/${SUBJ}_r01${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r91${curfunc}${sm}.${hs}.1D.dset
	cp -f ../../${SUBJ}/analysis/${SUBJ}_r02${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r92${curfunc}${sm}.${hs}.1D.dset
	cp -f ../../${SUBJ}/analysis/${SUBJ}_r03${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r93${curfunc}${sm}.${hs}.1D.dset
	cp -f ../../${SUBJ}/analysis/${SUBJ}_r04${curfunc}${sm}.${hs}.1D.dset ./$outdir/${SUBJ}_r94${curfunc}${sm}.${hs}.1D.dset
    end
end


echo; echo "== $0 complete"
exit 0
