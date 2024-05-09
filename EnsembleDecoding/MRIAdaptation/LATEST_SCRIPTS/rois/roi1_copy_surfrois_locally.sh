#!/bin/tcsh
# this script should be run from /Volumes/cbs/CLAB/MR_DATA/[experiment]/rois/
#
# create a local copy of the rois in the surfaces directory.
# although this is not strictly necessary (since you could directly
# refer to the rois in the surfaces directory), this intermediate step
# has the advantage of maintaining a copy of the ROIs used for a subject
# in a given experiment, even if there are subsequent changes to the ROIs
# in the surfaces directory.
echo "== $0 starting"

# verify correct usage
if ($#argv != 1 && $#argv != 2) then
    echo "Usage: $0 subj ?force_copy?"
    exit
endif

# extract args
set subj = $1
if ($#argv == 1) then
    set force_copy = 0
else
    set force_copy = $2
endif


# assume that we will always be working off the fileserver
echo "== checking for surfaces directory..."
set surfdir = /Volumes/cbs/CLAB/MR_DATA/surfaces; # no trailing '/'             
if ( ! -d $surfdir ) then
    echo "ERROR: can't locate surfaces directory.  Are you connected to the fileserver?"
    exit 1
endif


# verify there is a surface directory (and roi subdirectory) for this subject
echo "== checking for subject-specific subdirectory and roi directory..."
if ( ! -e ${surfdir}/$subj ) then
    echo "ERROR: no surfaces directory for subj $subj"
endif
set roidir = ${surfdir}/${subj}/rois
if ( ! -e $roidir ) then
    echo "ERROR: no roi subdirectory in subj $subj surfaces directory"
endif


# create local subdir for this subject
echo "== checking for local subject directory..."
if ( ! -e ./${subj}/ ) then
    echo " - creating for local subject directory..."
    mkdir $subj
endif


# copy all surface rois (1D and niml) to the local directory
echo "== copying files..."
foreach region ('ret' 'mt-obj') # 'cortical'
    echo " - $region"
    foreach hs ('lh' 'rh')
	foreach ext ('.1D.dset' '.niml.roi')
	    set rfile = ${region}-${hs}${ext}; # full filename of surface roi (no path)

	    # add paths (input and outpu)
	    set source_file = ${roidir}/$rfile
	    set target_file = ./${subj}/$rfile
	    
	    if ( ! -e $source_file ) then
		echo "   $rfile (no source file in surface directory, skipping)"
	    else if ( ! -e $target_file || $force_copy ) then
		echo "   $rfile (copying)"
		cp -f $source_file $target_file
	    else
		echo "   $rfile (targe file exists locally, skipping)"
	    endif
	end
    end
end

echo; echo "== $0 complete"
exit 0
