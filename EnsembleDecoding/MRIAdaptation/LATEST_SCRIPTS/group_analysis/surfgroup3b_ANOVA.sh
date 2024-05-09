#!/bin/tcsh
# this script should be run from an experiment-central location, like /Volumes/cbs/CLAB/MR_DATA/[experiment]/group_analysis/
#
# this script is a basic outline of how to run a group-level analysis after
# you have applied the same same spatial normalization to all of your subject's
# datasets (e.g., GLM buckets, etc.).
#
# This script shows examples for a 2-way repeated-measures ANOVA (2 fixed factors, and subject as a random factor)
#
# The example here assumes that you have used the surface icosahedron for spatial normalization.
#
# You'll need to update the script to reflect your subject's (and how many) and the
# conditions (i.e., regressors) you want to compare.  Right now, they are labeled
# SUBJ# and COND#.  Additionally, you can update the path to each subject's data -
# in other words, you don't need a local copy of the data, you can point to each
# subject's analysis directory and store the group output whereever you run the
# script from.

echo "== $0 starting"

# 1. local variables
set test = "ANOVA"; # for now, "ANOVA"

# assuming SUMA icosahedron surface-space
set icoprefix = "std.141"
set input_prefix = "_tscvrsm4_norm_bucket_REML"; # this defines your input
set ext          = ".niml.dset"
set hemis = ( lh rh ); # defines which hemispheres to run the surface-based group analysis on

# this script will do the A-B comparison (but note that this requires switching
# the order of input for some functions, like 3dWilcoxon)
# N.B. 3dttest++ (at least) will crop the labels to 12 characters!
set condA1B1 = 'ori_left'
set condA1B2 = 'ori_right'
set condA2B1 = 'let_left'
set condA2B2 = 'let_right'
set output_tag = '_OLandLR'; # a string to identify different iterations for different condition comparisons


echo "== $test"
echo "   $condA1B1 : $condA1B2 : $condA2B1 : $condA2B2"
echo "   output_tag = $output_tag"

# loop over hemispheres
foreach hs ( $hemis )
    echo "== $hs"

    # do the analysis
    switch ( $test)
	echo; echo "== ${input_prefix}${ext}"; echo
	
	case ANOVA:
	    set this_output = ${icoprefix}.group${input_prefix}_ANOVA${output_tag}.${hs}${ext}
	    echo "   $this_output"
	    rm -f $this_output; # remove output file
	    # OPTIONS:
	    # -type 4 : for a two-way repeated-measures ANOVA (2 fixed factors, plus subject as a random factor)
	    3dANOVA3 \
		-type 4 \
		-alevels 2 \
		-blevels 2 \
		-clevels 8 \
		-dset 1 1 1 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 1 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 1 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 1 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 2 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 2 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 2 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 2 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 3 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 3 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 3 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 3 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 4 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 4 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 4 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 4 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 5 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 5 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 5 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 5 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 6 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 6 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 6 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 6 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 7 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 7 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 7 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 7 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-dset 1 1 8 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA1B1}'#0_Coef]' \
		-dset 2 1 8 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA2B1}'#0_Coef]' \
		-dset 1 2 8 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA1B2}'#0_Coef]' \
		-dset 2 2 8 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA2B2}'#0_Coef]' \
		-voxel 12345 \
		-fa 'stim' \
		-fb 'side' \
		-fab 'stimXside' \
		-adiff 1 2 'stim_O-L' \
		-bdiff 1 2 'side_L-R' \
		-bucket $this_output
	    breaksw	    
	    
	default:
	    echo "ERROR: invalid test ($test)."
	    exit 1
	    breaksw
    endsw
end

echo; echo "== $0 complete"
exit 0
