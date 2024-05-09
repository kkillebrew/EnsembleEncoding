#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/$SUBJ/analysis/
#
# spatial normalization of a surface to the buckner40 space occurs automatically
# in the FreeSurfer/SUMA pipeline.  There are two icosahedron surfaces that can 
# be used, with different resolutions (i.e., number of nodes). E.g.,
# std60...
# std141...
#
# to utilize the icosahedrons, we need to create a mapping file, which provides SUMA
# with the information to allow conversion of surface files between the native (subject-
# specic) and standard (icosahedron) spaces.  These take the form of a set of weights
# that define the mapping between native and standard space.  For different types of data,
# we should use different types of mapping files.  For continuous data (time courses,
# GLM outputs, etc.), we want to use a weighted-average.  For categorical data (ROI files),
# we want to use a neighest-neighbor approach so that the output is also categorical.
#
# the mapping files only need to be created once for each subject; they are not experiment-
# specific.  they are stored in each subject's surfaces/SUBJ/SUMA/ directory (along with the
# native and icosahedron surface files).  this script will determine if the mapping files
# exist and create them if needed.  if you want to overwrite existing mapping files, you will
# need to manually rename/delete the existing ones in the subject's SUMA directory.  but be
# aware that this is a shared resource, so you should only do this if you have a very good
# reason.  
#
# see MapIcosahedron -help for more info on Icosahedron surfaces.

echo "== $0 starting"


# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ../scripts/global_vars.sh


# 1. local variables
set icoprefix = std.141; # 'std.141' or 'std.60' : determines which icosahedron (resolution) surface to use.  use 141 unless you specifically want a lower resolution space


# 2. check for existing mapping files and create them if they don't exist
foreach hs ( $HEMIS )
    # Native -> Icosahedron
    foreach tag ( AVG NN )
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

	set thisoutput = $icoprefix.native2ico.${hs}.$tag
	echo " = $hs, $description"
	echo "   $thisoutput.niml.M2M"
	if ( -e ${SUMADIR}/$thisoutput.niml.M2M ) then
	    echo "      mapping file already exists, SKIPPING..."
	else
	    echo "      generating new mapping file..."
	    SurfToSurf \
		-i_fs ${SUMADIR}/$icoprefix.$hs.smoothwm.asc \
		-i_fs ${SUMADIR}/$hs.smoothwm.asc \
		-output_params $method \
		-prefix ${SUMADIR}/$thisoutput
	endif
    end
end

echo; echo "== $0 complete"
exit 0
