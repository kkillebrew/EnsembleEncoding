#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
#
# this script is a basic outline of how to perform spatial normalization
# of an anatomical into Talairach space in AFNI.  Note that in AFNI,
# we perform this transformation to one of a few built-in templates.  Some
# of the templates seem like they are MNI brains, but they have been
# transformed into Talairach space by AFNI.  After spatial normalization,
# you can use AFNI's whereami command and GUI interface to get MNI coordinates
# if you wish.
#
# A note on templates (see also, whereami -show_templates:
# TT_N27+tlrc
#     The Colin N27 Brain transformed into Talairach space
#     One nice thing about this template is there are a corresponding set of SUMA surfaces for this brain
# TT_avg152T1+tlrc
#     The MNI template based on the average of 152 brains, transformed into Talairach space
# see @auto_tlrc -help for more info and more templates

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# 1. local variables
set template = TT_N27+tlrc;  # TT_N27+tlrc, TT_avg152T1+tlrc, see @auto_tlrc -help and whereami -show_templates
set curanat  = "_NoSkull_SurfVol_Alnd_Exp";  # target anatomical prefix (no subj or +orig) you want to transform
set isores   = 1; # desired isotropic voxel resolution of transformed anatomical


# 2. get a local copy of template for comparison with transformed volume
@auto_tlrc -base $template -base_copy ./


# 3. @auto_tlrc
#    -init_xform CENTER causes an initial @Align_Centers to be performed and applied as part of the final transformation.
#                       this will help with datasets that are far apart, and shouldn't hurt if the datasets are close.
@auto_tlrc \
    -base $template \
    -no_ss \
    -dxyz $isores \
    -init_xform CENTER \
    -input ${SUBJ}${curanat}+orig

# 4. Now you should open AFNI and verify that the +tlrc version of the anatomical aligns reasonably well with the template
#    Load ${SUBJ}${curanat}+tlrc as underlay and TT_N27+tlrc as overlay

# 6. see group2_apply.sh to apply the talairach transformation to other volumes (e.g., EPIs or GLM Buckets)

echo; echo "== $0 complete"
exit 0
