#!/bin/tcsh
# this script should be run from/Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
#
# This script will create union (OR) comparisons of other regressors or contrasts.
# This script must be run AFTER vol5_remlvol.sh, so that the appropriate bucket file exists.
#
# N.B. This script needs very specific updating for your own experiment.
#
# N.B. If you run this script twice, it will append duplicate subbricks to the original GLM output.
#      If you need to re-run this script, you may first wish to re-create a clean GLM bucket.
#
# N.B. This example script does NOT produce SIGNED output.  Meaning that it does an OR by taking the maximum t-value over a set of regressors, and then keeping the matched beta coeficient or t-stat.  If you want SIGNED output, you should take the max over the absolute values of the t-stats.
#
echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif

# local variables




# the union loop...
foreach sm ( $VOLSMOOTHS )
    echo; echo "== creating union sub-briks for smoothing of $sm mm"

    set curfunc = "_tscvrsm${sm}_norm"; # fully specifies all preprocessing (e.g., volume or surface smoothing)
    set bucket = ${SUBJ}${curfunc}_bucket_REML; # do NOT include +orig (but DO include _REML, if desired)


    #_________________________________________________________________
    # Create Union Maps
    # currently using a hardcoded list of regressors or contrasts for each union
    # N.B. that the current method of taking the largest t-value means significant negative t-values are ignored!
    #      so this is only valid for union comparisons in which HIGH t-values are of interest (A>B), not when large
    #      DIFFERENCES are of interest (A>B or A<B).  You have been warned!
    rm -f ${bucket}_union+orig.*


    echo; echo "== creating union map: anywm..."
    # take coef at max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left#0_Tstat]' \
	-b ${bucket}+orig'[let_right#0_Tstat]' \
	-c ${bucket}+orig'[let_both#0_Tstat]' \
	-d ${bucket}+orig'[ori_left#0_Tstat]' \
	-e ${bucket}+orig'[ori_right#0_Tstat]' \
	-f ${bucket}+orig'[ori_both#0_Tstat]' \
	-g ${bucket}+orig'[let_left#0_Coef]' \
	-h ${bucket}+orig'[let_right#0_Coef]' \
	-i ${bucket}+orig'[let_both#0_Coef]' \
	-j ${bucket}+orig'[ori_left#0_Coef]' \
	-k ${bucket}+orig'[ori_right#0_Coef]' \
	-l ${bucket}+orig'[ori_both#0_Coef]' \
	-expr 'pairmax(a,b,c,d,e,f,g,h,i,j,k,l)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'anywm#0_Coef' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...
    # take max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left#0_Tstat]' \
	-b ${bucket}+orig'[let_right#0_Tstat]' \
	-c ${bucket}+orig'[let_both#0_Tstat]' \
	-d ${bucket}+orig'[ori_left#0_Tstat]' \
	-e ${bucket}+orig'[ori_right#0_Tstat]' \
	-f ${bucket}+orig'[ori_both#0_Tstat]' \
	-expr 'pairmax(a,b,c,d,e,f,a,b,c,d,e,f)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'anywm#0_Tstat' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...


    echo; echo "== creating union map: let_anywm..."
    # take coef at max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left#0_Tstat]' \
	-b ${bucket}+orig'[let_right#0_Tstat]' \
	-c ${bucket}+orig'[let_both#0_Tstat]' \
	-d ${bucket}+orig'[let_left#0_Coef]' \
	-e ${bucket}+orig'[let_right#0_Coef]' \
	-f ${bucket}+orig'[let_both#0_Coef]' \
	-expr 'pairmax(a,b,c,d,e,f)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'let_anywm#0_Coef' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...
    # take max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left#0_Tstat]' \
	-b ${bucket}+orig'[let_right#0_Tstat]' \
	-c ${bucket}+orig'[let_both#0_Tstat]' \
	-expr 'pairmax(a,b,c,a,b,c)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'let_anywm#0_Tstat' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...


    echo; echo "== creating union map: ori_anywm..."
    # take max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[ori_left#0_Tstat]' \
	-b ${bucket}+orig'[ori_right#0_Tstat]' \
	-c ${bucket}+orig'[ori_both#0_Tstat]' \
	-expr 'pairmax(a,b,c,a,b,c)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'ori_anywm#0_Tstat' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...
    # take coef at max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[ori_left#0_Tstat]' \
	-b ${bucket}+orig'[ori_right#0_Tstat]' \
	-c ${bucket}+orig'[ori_both#0_Tstat]' \
	-d ${bucket}+orig'[ori_left#0_Coef]' \
	-e ${bucket}+orig'[ori_right#0_Coef]' \
	-f ${bucket}+orig'[ori_both#0_Coef]' \
	-expr 'pairmax(a,b,c,d,e,f)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'ori_anywm#0_Coef' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...

    echo; echo "== creating union map: anywm_vs_pass..."
    # take coef at max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left_vs_pass#0_Tstat]' \
	-b ${bucket}+orig'[let_right_vs_pass#0_Tstat]' \
	-c ${bucket}+orig'[let_both_vs_pass#0_Tstat]' \
	-d ${bucket}+orig'[ori_left_vs_pass#0_Tstat]' \
	-e ${bucket}+orig'[ori_right_vs_pass#0_Tstat]' \
	-f ${bucket}+orig'[ori_both_vs_pass#0_Tstat]' \
	-g ${bucket}+orig'[let_left_vs_pass#0_Coef]' \
	-h ${bucket}+orig'[let_right_vs_pass#0_Coef]' \
	-i ${bucket}+orig'[let_both_vs_pass#0_Coef]' \
	-j ${bucket}+orig'[ori_left_vs_pass#0_Coef]' \
	-k ${bucket}+orig'[ori_right_vs_pass#0_Coef]' \
	-l ${bucket}+orig'[ori_both_vs_pass#0_Coef]' \
	-expr 'pairmax(a,b,c,d,e,f,g,h,i,j,k,l)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'anywm_vs_pass#0_Coef' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...
    # take max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left_vs_pass#0_Tstat]' \
	-b ${bucket}+orig'[let_right_vs_pass#0_Tstat]' \
	-c ${bucket}+orig'[let_both_vs_pass#0_Tstat]' \
	-d ${bucket}+orig'[ori_left_vs_pass#0_Tstat]' \
	-e ${bucket}+orig'[ori_right_vs_pass#0_Tstat]' \
	-f ${bucket}+orig'[ori_both_vs_pass#0_Tstat]' \
	-expr 'pairmax(a,b,c,d,e,f,a,b,c,d,e,f)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'anywm_vs_pass#0_Tstat' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...


    echo; echo "== creating union map: let_anywm_vs_pass..."
    # take coef at max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left_vs_pass#0_Tstat]' \
	-b ${bucket}+orig'[let_right_vs_pass#0_Tstat]' \
	-c ${bucket}+orig'[let_both_vs_pass#0_Tstat]' \
	-d ${bucket}+orig'[let_left_vs_pass#0_Coef]' \
	-e ${bucket}+orig'[let_right_vs_pass#0_Coef]' \
	-f ${bucket}+orig'[let_both_vs_pass#0_Coef]' \
	-expr 'pairmax(a,b,c,d,e,f)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'let_anywm_vs_pass#0_Coef' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...
    # take max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[let_left_vs_pass#0_Tstat]' \
	-b ${bucket}+orig'[let_right_vs_pass#0_Tstat]' \
	-c ${bucket}+orig'[let_both_vs_pass#0_Tstat]' \
	-expr 'pairmax(a,b,c,a,b,c)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'let_anywm_vs_pass#0_Tstat' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...


    echo; echo "== creating union map: ori_anywm_vs_pass..."
    # take coef at max t-value over a set of regressors/contrasts.  	
    3dcalc \
	-a ${bucket}+orig'[ori_left_vs_pass#0_Tstat]' \
	-b ${bucket}+orig'[ori_right_vs_pass#0_Tstat]' \
	-c ${bucket}+orig'[ori_both_vs_pass#0_Tstat]' \
	-d ${bucket}+orig'[ori_left_vs_pass#0_Coef]' \
	-e ${bucket}+orig'[ori_right_vs_pass#0_Coef]' \
	-f ${bucket}+orig'[ori_both_vs_pass#0_Coef]' \
	-expr 'pairmax(a,b,c,d,e,f)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'ori_anywm_vs_pass#0_Coef' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...
    # take max t-value over a set of regressors/contrasts.  
    3dcalc \
	-a ${bucket}+orig'[ori_left_vs_pass#0_Tstat]' \
	-b ${bucket}+orig'[ori_right_vs_pass#0_Tstat]' \
	-c ${bucket}+orig'[ori_both_vs_pass#0_Tstat]' \
	-expr 'pairmax(a,b,c,a,b,c)' \
	-prefix ${bucket}_union+orig
    3drefit -sublabel 0 'ori_anywm_vs_pass#0_Tstat' ${bucket}_union+orig; # update label of newly created union
    3dbucket -glueto ${bucket}+orig ${bucket}_union+orig;     # integrate UNION back into output bucket
    rm -f ${bucket}_union+orig.*; # clean up tmp union bucket...


end


echo; echo "== $0 complete"
exit 0
