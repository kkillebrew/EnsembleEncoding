#!/bin/tcsh
# this script should be run from an experiment-central location, like /Volumes/cbs/CLAB/MR_DATA/[experiment]/group_analysis/
#
# This script is for doing a serial batch process on multiple subjects

echo "== $0 starting"


#set contrasts_to_batch = "left_vs_right let_left_vs_right ori_left_vs_right allwm allwm_vs_pass let_vs_ori"; # first pass
#set contrasts_to_batch = "let_allwm ori_allwm left_let_vs_ori right_let_vs_ori"; # redoing for errors in first pass
#set contrasts_to_batch = "anywm anywm_vs_pass let_anywm ori_anywm let_anywm_vs_pass ori_anywm_vs_pass";
set contrasts_to_batch = "left_vs_right let_vs_ori anywm anywm_vs_pass"

foreach contrast ( $contrasts_to_batch )
    echo "== batch iteration for $contrast"
    source ./surfgroup3c_mema.sh
end

echo; echo "== $0 complete"
exit 0

