#!/bin/tcsh
# this script should be run from an experiment-central location, like /Volumes/cbs/CLAB/MR_DATA/[experiment]/group_analysis/
#
# this script is a basic outline of how to run a group-level analysis after
# you have applied the same same spatial normalization to all of your subject's
# datasets (e.g., GLM buckets, etc.).
#
# This script shows examples for 3 different test (3dttest++, 3dWilcoxon, 3dMEMA),
# but there are many more available directly within AFNI.  Beware, each program
# requires different types of inputs, performs different comparisons (A-B vs. B-A),
# and has a different output.  Read the -help for the program you want to use carefully.
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
set test = "ttest"; # for now, "ttest", "wilcoxon" or "mema"

# assuming SUMA icosahedron surface-space
set icoprefix = "std.141"
set input_prefix = "_tscvrsm4_norm_bucket_REML"; # this defines your input
set ext          = ".niml.dset"
set hemis = ( lh rh ); # defines which hemispheres to run the surface-based group analysis on

# this script will do the A-B comparison (but note that this requires switching
# the order of input for some functions, like 3dWilcoxon)
# N.B. 3dttest++ (at least) will crop the labels to 12 characters!
set condA = 'let_left'
set condB = 'let_right'
set output_tag = '_LetLR'; # a string to identify different iterations for different condition comparisons


echo "== $test"
echo "   $condA - $condB"
echo "   output_tag = $output_tag"

# loop over hemispheres
foreach hs ( $hemis )
    echo "== $hs"

    # do the analysis
    switch ( $test)
	echo; echo "== ${input_prefix}${ext}"; echo
	
	case ttest:
	    set this_output = ${icoprefix}.group${input_prefix}_ttest${output_tag}.${hs}${ext}
	    echo "   $this_output"
	    rm -f $this_output; # remove output file
	    # OPTIONS:
	    # for a paired test, include -paired (and make sure the order of subjects is matched for A and B)
	    # to skip the one-sample tests (against 0), include -no1sam
	    3dttest++ \
		-paired \
		-setA $condA \
		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-setB $condB \
		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-prefix $this_output
	    breaksw
	    
	case wilcoxon:
	    set this_output = ${icoprefix}.group${input_prefix}_wilcoxon${output_tag}.${hs}${ext}
	    echo "   $this_output"
	    rm -f $this_output; # remove output file
	    # it seems like 3dWilcoxon is doing (set 2) - (set 1), which is opposite of 3dttest++ and 3dMEMA (A-B)
	    3dWilcoxon \
		-dset 1 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-dset 1 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' \
		-dset 2 ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' \
		-out $this_output
	    breaksw
	    
	case mema:
	    set this_output = ${icoprefix}.group${input_prefix}_mema${output_tag}.${hs}${ext}
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
		-conditions ${condB} ${condA} \
		-set ${condB} \
		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condB}'#0_Coef]' ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condB}'#0_Tstat]' \
		-set ${condA} \
		    CB ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../CB/analysis/${icoprefix}.CB${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    GC ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../GC/analysis/${icoprefix}.GC${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    GG ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../GG/analysis/${icoprefix}.GG${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    JV ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../JV/analysis/${icoprefix}.JV${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    KK ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../KK/analysis/${icoprefix}.KK${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    KM ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../KM/analysis/${icoprefix}.KM${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    LS ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../LS/analysis/${icoprefix}.LS${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		    NS ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA}'#0_Coef]' ../NS/analysis/${icoprefix}.NS${input_prefix}.${hs}${ext}'['${condA}'#0_Tstat]' \
		-HKtest \
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
