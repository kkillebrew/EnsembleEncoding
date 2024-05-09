#!/bin/tcsh

# This file provides a central location to store a set of global
# or "shared" variables that are used (i.e., "sourced") by other scripts.
# By convention, global variable names are UPPERCASE, whereas local
# (i.e., within-script) variable names are lowercase


#------------------
# General Variables
# the subj should be the same as used for the surfaces directory
set SUBJ = "KK";


#------------------------
# Functional Scans (EPIs)
# the following should be 3-digit scan ids
set FUNC_SCANS = (004 005 006 007 008 009); # functional scans (in run order)

# the following should all be the same length as the $func_scans array above
set FUNC_SERIES_NAME = (retino_wedges_BOLDX4 retino_wedges_BOLDX4 retino_wedges_BOLDX4 retino_wedges_BOLDX4 retino_rings_BOLDX2 retino_rings_BOLDX2); # directory suffix of dicom data for each associated scan in $FUNC_SCANS
set ALLRUNS = (r01  r02  r03  r04  r05  r06); # list of functional run labels (r01 r02 ...)
set NSLICES = (32   32   32   32   32   32); # number of slices for each run
set TPS     = (136  136  136  136  168  168); # number of time points (TP) or volumes for each run
set TR      = (2500 2500 2500 2500 2500 2500); # TR for each run


#---------------------
# Reference Run/Volume
# the following are important for motion correction, fieldmap alignment, etc.
# you should choose a volume in a run that is not an outlier (see output of to3d during conversion from dicom)
# I usually aim for a $refrun near the middle of this set of runs and a $refbase near the middle of $refrun
set REFRUN  = r04; # which run should be used for motion correction (see $refbase), fieldmap alignment, etc.
set REFBASE = 80; # which volume in $refrun should be used for motion correction, etc.


#-------------------------
# Preprocessing Parameters
# the following are used by some preprocessing scripts (see specific comments for each variable)
set VOLSMOOTHS  = (4 6); # an array of smoothing values to apply in volume space.  enter zero (0) for no smoothing.
set POLORT      = 2; # polort level for 3dDeconvolve (GLM) and 3dDetrend (1 = linear; 2 = linear+quadratic; etc.)
set HEMIS       = (lh rh); # hemispheres for surface projection.  usually (lh rh) for both hemispheres


#----------
# Field Map
# the following are important ONLY for fieldmap correction parameters.
# if you are not doing fieldmap correction, the values here won't matter.
# But you should still fill in $fmap_scans correctly (or leave it empty) so that
# the dicoms are converted (without error) and tar-gzipped.
set FMAP_SCANS = (014 015); # fieldmap scans (mag phase).  Leave empty if not using fieldmap
set SCANNER     = "UCDavis_skyra"; # "UCDavis_skyra" (for fmap params)
set IPAT_FACTOR = 2; # set to 0 if no iPAT used
set UNWARPDIR   = y; # x for Coronal, y for Axial (but check the results!): oblique data may be tricky
set FMAP_SM     = 4; # size of gaussian smoothing kernal for phase (mm) - helps clean up around the edges
# N.B. above two parameters will determine the final epi-aligned phase map's filename
#     e.g., phase_rads_s${fmsm}${unwarpdir}_to_reference_brain.nii.gz


#--------------
# Surface Stuff
# assume that we will always be working off the fileserver                      
set SURFDIR = /Volumes/cbs/CLAB/MR_DATA/surfaces; # no trailing '/'             
set SUMADIR = ${SURFDIR}/${SUBJ}/SUMA; # no trailing '/'                        
# validate directories                                                          
if ( ! -d $SURFDIR ) then
    echo "ERROR: can't locate surfaces directory.  Are you connected to the fileserver?"
    exit 1
endif
if ( ! -d $SUMADIR ) then
    echo "ERROR: can't locate SUMA directory.  Are you connected to the fileserver?"
    exit 1
endif
