#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/
#
# This script is for doing a serial batch process on multiple subjects

echo "== $0 starting"

# a list of all the subject directories you want to process in batch
set subjs = "AW CB GC GG JV KK KM LS MG NS";

foreach s ( $subjs )
    echo "== batch iteration for $s"
    
    # within this loop, you should 'cd' into the current subject's directory
    # where you want to execute a particular script from, execute the script,
    # and then 'cd' back to the starting directory (experiment top-level).
    # 
    # two examples are provided below. typically, you would uncomment one 
    # script at a time, but once you are comfortable with quick_batch.sh
    # you may want to string together sets of serially-related scripts (as in
    # the preprocessing example below).
    #
    # N.B. you could use this script to do anything you would do in Terminal,
    #      like deleting a set of files (e.g., rm *bucket*) or making new 
    #      subdirectories (e.g., mkdir runwise_glm)
    
    # preprocessing directory stuff
    cd $s/preprocessing/
    ../../scripts_default/prep1_tscvr.sh
    ../../scripts_default/prep3_anat.sh
    #../../scripts_default/vol4_glmprep.sh
    #../../scripts_default/vol4b_tcprep.sh

    # analysis directory stuff
    #cd $s/analysis/
    #../../scripts_default/vol5_glm.sh

    # group analysis related stuff
    #cd $s/analysis/
    #../../group_analysis/surfgroup2b_project.sh

    # runwise GLMs (note the extra 'cd' needed to get back to the starting point)
    #cd $s/analysis/runwise_glm
    #../../../scripts_default/vol5b_glm_runwise.sh
    #cd ../

    cd ../../
end

echo; echo "== $0 complete"
exit 0

