#!/bin/tcsh
# this script should be run from an experiment-central location, like /Volumes/cbs/CLAB/MR_DATA/[experiment]/group_analysis/
#
# this script is a basic outline of how to run a group-level analysis after
# you have applied the same same spatial normalization to all of your subject's
# datasets (e.g., GLM buckets, etc.).
#
# This script shows examples for using 3dMEMA to run a Mixed-Effets Meta Analysis.
# Gang Chen (the writer of 3dMEMA) suggests using the contrasts at the single-subject
# level as input (this is why the -condition option that you may see in old 3dMEMA
# examples is no longer functioning and causes an "Illegal parameters on command line:"
# error.  See 3dMEMA -help for more info, and read it carefully!
#
# The example here assumes that you have used the surface icosahedron for spatial normalization.
#
# You'll need to update the script to reflect your subject's (and how many) and the
# contrast you want to compare.  Obviously, the same contrast must be run in each individual
# subject, and you should always use 3dREMLfit when generating the input for 3dMEMA (so that
# the variance estimates are correct).  Additionally, you can update the path to each subject's data -
# in other words, you don't need a local copy of the data, you can point to each
# subject's analysis directory and store the group output whereever you run the
# script from.

echo "== $0 starting"

# 1. local variables
set test = "mema"; # for now, just "mema" (but could potentially incorporate one-sample "ttest" or "wilcoxon", so there are placeholders)
set smoothing = "sm6"; # defines smoothing and subdirectory for output

# assuming SUMA icosahedron surface-space
set icoprefix = "std.141"
set input_prefix = "_tscvr"${smoothing}"_norm_bucket_REML"; # this defines your input
set ext          = ".niml.dset"
set hemis = ( lh rh ); # defines which hemispheres to run the surface-based group analysis on

# this script takes a single contrast (or regressor) name.
# N.B. 3dttest++ (at least) will crop the labels to 12 characters!
##See mema_batch.sh ## set contrast = left_vs_right
set output_tag = _$contrast; # a string to identify different iterations for different condition comparisons.


echo "== $test"
echo "   $contrast"
echo "   output_tag = $output_tag"

# loop over hemispheres
foreach hs ( $hemis )
    echo "== $hs"

    # do the analysis
    switch ( $test)
	echo; echo "== ${input_prefix}${ext}"; echo
	
	case ttest:
	    echo; echo "== ERROR: one-sample ttest not setup yet"
	    exit 1
#	    set this_output = ${icoprefix}.group${input_prefix}_ttest${output_tag}.${hs}${ext}
#	    echo "   $this_output"
#	    rm -f $this_output; # remove output file
#	    # OPTIONS:
#	    # for a paired test, include -paired (and make sure the order of subjects is matched for A and B)
#	    # to skip the one-sample tests (against 0), include -no1sam
#	    3dttest++ \
#		-paired \
#		-setA $condA \
#		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-setB $condB \
#		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-prefix $this_output
	    breaksw
	    
	case wilcoxon:
	    echo; echo "== ERROR: one-sample wilcoxon not setup yet"
	    exit 1
#	    set this_output = ${icoprefix}.group${input_prefix}_wilcoxon${output_tag}.${hs}${ext}
#	    echo "   $this_output"
#	    rm -f $this_output; # remove output file
#	    # it seems like 3dWilcoxon is doing (set 2) - (set 1), which is opposite of 3dttest++ and 3dMEMA (A-B)
#	    3dWilcoxon \
#		-dset 1 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-dset 1 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
#		-dset 2 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
#		-out $this_output
	    breaksw
	    
	case mema:
	    set this_output = ./${smoothing}/${icoprefix}.group${input_prefix}_mema${output_tag}.${hs}${ext}
	    rm -f $this_output; # remove output file
	    echo "   $this_output"
	    # 3dMEMA will weight the contribution of each subject (on a per-voxel basis) by the variance for that subject.
	    # be sure to use the output of 3dREMLfit for 3dMEMA as the variance estimates are more accurate than 3dDeconvolve.
	    #
	    # N.B. 3dMEMA requires that R is install - see 3dMEMA -help for more information and link to Gang Chen's webpage
	    #
	    # for faster execution, use -jobs #, where # is the number of core you have.  But you'll need to have the 'snow'
	    # package installed in R.
	    3dMEMA \
		-set $contrast \
		    AW ../AW/analysis/${icoprefix}.AW${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../AW/analysis/${icoprefix}.AW${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    MG ../MG/analysis/${icoprefix}.MG${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../MG/analysis/${icoprefix}.MG${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${contrast}'#0_Coef]' ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${contrast}'#0_Tstat]' \
		-HKtest \
		-missing_data 0 \
		-model_outliers \
		-residual_Z \
		-verb 1 -cio \
		-prefix $this_output
	    breaksw
	    
	default:
	    echo "ERROR: invalid test ($test)."
	    exit 1
	    breaksw
    endsw
end

echo; echo "== $0 complete"
exit 0
