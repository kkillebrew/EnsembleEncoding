#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
#
# this script provdes a basic outline of how to transfer surface dsets from a subject's native
# space into an icosahedron standard space.  the transformation info is stored in the subject's
# SUMA directory.  see surfgroup1_spatialnorm.sh for info on generating these files.

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# variable validation
if ( $#VOLSMOOTHS == 0) then
    echo; echo "ERROR: you must define at least one level of smoothing in global_vars.sh, even if you set it to zero (0)."
    exit 1
endif


# 1. local variables
set icoprefix = std.141; # 'std.141' or 'std.60' : determines which icosahedron (resolution) surface to use.  use 141 unless you specifically want a lower resolution space
set tag = AVG; # AVG for Barycentric interpolation (averaging), use with continuous datasets; NN for Nearest Neighbor assignment (categorical), use with ROI files


# 2. extract other params based on $tag
switch ( $tag )
    case AVG:
	# AVG = Barycentric interpolation (averaging) = NearestTriangleNodes
	set description = "Barycentric interpolation (averaging)"
	set method = NearestTriangleNodes
	breaksw
    case NN:
	# NN  = Nearest Neighbor assignment (categorical) = NearestNode
	set description = "Nearest Neighbor assignment (categorical)"
	set method = NearestNode
	breaksw
    default
	echo "ERROR: invalid tag $tag.  no description/method defined."
	exit 1
endsw


# 3. convert native dset to icosahedron space
foreach sm ( $VOLSMOOTHS )
    #set this_curfunc = $curfunc; # expand the smoothing ($sm) of the input file
    set curfunc  = "_tscvrsm"$sm"_norm_bucket_REML"; # target volume prefix (no subj or .niml.dset, etc.) you want to transform

    foreach hs ( $HEMIS )
	echo "== $hs"
	echo "   using $description"

	set this_input  = ${SUBJ}${curfunc}.$hs.niml.dset; # include fill extension
	set this_output = $icoprefi.${SUBJ}${curfunc}.$hs.niml.dset; # no .niml.dset extension
	echo "   $this_input -> $this_output.1D.dset"

	# do the surface to surface mapping.  using -dset option maintains column labels in output
	# outout is the prefix.input.  will also output a .1D file with the weights/nodes for the
	# transformation
	SurfToSurf \
	    -i_fs ${SUMADIR}/$icoprefix.$hs.smoothwm.asc \
	    -i_fs ${SUMADIR}/$hs.smoothwm.asc \
	    -mapfile ${SUMADIR}/$icoprefix.native2ico.${hs}.$tag.niml.M2M \
	    -output_params $method \
	    -dset $this_input \
	    -prefix std.141
    end

end


echo; echo "== $0 complete"
exit 0
