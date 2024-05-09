#!/bin/tcsh
#
# this script should be run from /MRDATA/CLAB/(EXPERIMENT)/$SUBJ/   <--- note!
# Unzipping the DICOM folder, moving files around, and rezipping takes a very long time on the server (cbs)
# because there are thousands of files. 
#
# There is currently a strange bug that mixes up the image file older when run on cbs
#
#echo "== $0 starting"

# get global (i.e., "shared") variables for this subject (by convention, global variables are all UPPERCASE)
source ./scripts/global_vars.sh

# check to see if DICOMDIR exists, if it doesn't check to see if zipped folder exists
if ( ! -d DICOMDIR) then
    if (-f DICOMDIR.zip) then
	unzip DICOMDIR.zip -d DICOMDIR
    else if (-f DICOM.zip) then
	unzip DICOM.zip -d DICOMDIR
    else
	echo "ERROR: No DICOMDIR or DICOM folder found."
	exit 1
    endif
endif

# total number of runs (from number of run names)
set nRuns = $#FUNC_SCANS
# create an array that is going to store the number of images per run
set nImages = `seq 1 $nRuns`

set i = 0;
foreach scan ($FUNC_SCANS)
    @ i++;

    # create directory for each run
    mkdir ${scan}_${FUNC_SERIES_NAME[$i]};

    # determine the number of image files that are in each run
    @ nImages[$i] = $NSLICES[$i] * $TPS[$i];
end    

# move image files from DICOM folder into new, run folders
# also, relable images

# initialize counters
set i = 0; # file number counter
set r = 1; # run number counter
set i_r = 0; # files in run counter
set z = 0; # space counter
set t = 1; # time counter

echo "Creating run $r files"

foreach imFile ("`find ./DICOMDIR/DICOM -name 'IM*' -depth 1 ; find ./DICOMDIR/DICOM -name 'IM*' -depth 2 `")
# NB the find . command returns all of the files in the subdirectories first and then the files in the directory
# however, the files in the directory are chronologically first so we need a work-around to get those file names first
# the -depth option tells find to look either only in the immediate folder (-depth 1) or only in the subfolders (-depth 2)

    # update image counters
    @ i++;
    @ i_r++;

    # if we have copied all images from the current run, go to the next run
    if ( $i_r > $nImages[$r]) then
	# reset counters
	set i_r = 1;
	set t = 1;
	set z = 0;
	@ r++; # update run number
	echo "Creating run $r files"
    endif

    # imgage number 
    # images come in in tz format -- all timepoints for slice 1, slice 2, etc.
    # convert to zt format to conform to prep0_to3d script
    set imgn = `expr $t + $z \* $NSLICES[$r]` 

    # store images with 0s ahead of them so that they are loaded in in correct order (anticipating fewer than 10,000 images per run)
    if ($imgn < 10) then
	set ii = 000${imgn}
    else if ($imgn < 100) then
	set ii = 00${imgn}
    else if ($imgn < 1000) then
	set ii = 0${imgn}
    else
	set ii = ${imgn}
    endif

    # update space and time counters
    @ z++;
    if ( $z % $TPS[$r] == 0 ) then 
	set z = 0
	@ t++
    endif

    # move from DICOM folder to newly created runs folders
    mv $imFile ${FUNC_SCANS[$r]}_${FUNC_SERIES_NAME[$r]}/IM_${ii}.dcm
    # NB the image files come with no extensions so we need to add the .dcm extension to them

end

# remove the DICOM folder and all of its contents (should now be empty)
rm -rf DICOMDIR

echo "Done!"
exit 0
