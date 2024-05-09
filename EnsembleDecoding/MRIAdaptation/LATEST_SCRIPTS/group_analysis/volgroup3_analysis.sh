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
# The example here assumes that you have used @auto_tlrc for spatial normalization,
# although there are other options (e.g., surface-based spatial normalization in SUMA).
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

# assuming AFNI's @auto_tlrc using TT_N27 or TT_avg152 template
set input_prefix = _tscvrsm6_norm_bucket_REML; # this defines your input
set ext          = "+tlrc.HEAD"

# this script will do the A-B comparison (but note that this requires switching
# the order of input for some functions, like 3dWilcoxon)
# N.B. 3dttest++ (at least) will crop the labels to 12 characters!
set condA = 'subbrik name of condition A Coef'
set condB = 'subbrik name of condition B Coef'
set output_tag = '_TAG'; # a string to identify different iterations for different condition comparisons

# do the analysis
switch ( $test)
    echo; echo "== ${input_prefix}${ext}"; echo

    case ttest:
	echo; echo "== $test"; echo
	rm -f group${input_prefix}_ttest${ext}; # remove output file
	# OPTIONS:
	# for a paired test, include -paired (and make sure the order of subjects is matched for A and B)
	# to skip the one-sample tests (against 0), include -no1sam
	3dttest++ \
	    -paired \
	    -setA $condA \
		SUBJ1 SUBJ1${input_prefix}${ext}'['${condA}'#0_Coef]' \
		SUBJ2 SUBJ2${input_prefix}${ext}'['${condA}'#0_Coef]' \
		SUBJ3 SUBJ3${input_prefix}${ext}'['${condA}'#0_Coef]' \
	    -setB $condB \
		SUBJ1 SUBJ1${input_prefix}${ext}'['${condB}'#0_Coef]' \
		SUBJ2 SUBJ2${input_prefix}${ext}'['${condB}'#0_Coef]' \
		SUBJ3 SUBJ3${input_prefix}${ext}'['${condB}'#0_Coef]' \
	    -prefix group${input_prefix}_ttest${output_tag}${ext}
	breaksw

    case wilcoxon:
	echo; echo "== $test"; echo
	rm -f group${input_prefix}_wilcoxon${ext}; # remove output file
        # it seems like 3dWilcoxon is doing (set 2) - (set 1), which is opposite of 3dttest++ and 3dMEMA (A-B)
	3dWilcoxon \
	    -dset 1 SUBJ1${input_prefix}${ext}'['${condB}'#0_Coef]' \
	    -dset 2 SUBJ1${input_prefix}${ext}'['${condA}'#0_Coef]' \
	    -dset 1 SUBJ2${input_prefix}${ext}'['${condB}'#0_Coef]' \
	    -dset 2 SUBJ2${input_prefix}${ext}'['${condA}'#0_Coef]' \
	    -dset 1 SUBJ3${input_prefix}${ext}'['${condB}'#0_Coef]' \
	    -dset 2 SUBJ3${input_prefix}${ext}'['${condA}'#0_Coef]' \
	    -out group${input_prefix}_wilcoxon${output_tag}${ext}
        breaksw

    case mema:
	echo; echo "== $test"; echo
	rm -f group${input_prefix}_mema${ext}; # remove output file
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
		SUBJ1 SUBJ1${input_prefix}${ext}'['${condB}'#0_Coef]' SUBJ1${input_prefix}${ext}'['${condB}'#0_Tstat]' \
		SUBJ2 SUBJ2${input_prefix}${ext}'['${condB}'#0_Coef]' SUBJ2${input_prefix}${ext}'['${condB}'#0_Tstat]' \
	        SUBJ3 SUBJ3${input_prefix}${ext}'['${condB}'#0_Coef]' SUBJ3${input_prefix}${ext}'['${condB}'#0_Tstat]' \
	    -set ${condA} \
		SUBJ1 SUBJ1${input_prefix}${ext}'['${condA}'#0_Coef]' SUBJ1${input_prefix}${ext}'['${condA}'#0_Tstat]' \
	        SUBJ2 SUBJ2${input_prefix}${ext}'['${condA}'#0_Coef]' SUBJ2${input_prefix}${ext}'['${condA}'#0_Tstat]' \
		SUBJ3 SUBJ3${input_prefix}${ext}'['${condA}'#0_Coef]' SUBJ3${input_prefix}${ext}'['${condA}'#0_Tstat]' \
	    -HKtest \
	    -verb 1 -cio \
	    -prefix group${input_prefix}_mema${output_tag}${ext}
	breaksw

    default:
	echo "ERROR: invalid test ($test)."
	exit 1
	breaksw
endsw

echo; echo "== $0 complete"
exit 0
