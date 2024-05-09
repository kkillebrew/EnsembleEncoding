This is a very rough guide to running the scripts in this
directory. Eventually, this will be updated to be more general and
contain more details, possibly integrated into an online wiki
documentation. 

Examples are given for the Object_Localizers

1. Create directory for new subject

2. Copy and organize dicom folders with raw data (e.g.,
012_objects_BOLD2X, etc.) 

3. Make a COPY of the scripts_defaults dir in your subject's directory
and rename it scripts.

4. Update global_vars.sh to reflect the specific variables for your
subject.

5. From your subject's top-level directory (e.g.,
.../Object_Localizers/$subj/), run prep0_to3d.sh
	./scripts/prep0_to3d.sh

This will convert the dicoms to BRIKs, create some directories and
tar-zip the dicom data.

6. From your subject's preprocessing directory, run the remaining 
preprocessing scripts:
	../scripts/prep1_tscvr.sh (check motion correction and motion
	correction parameters plot)
	../scripts/prep3_anat.sh (check aligment between anat and epi)

7. ...And the analysis scripts:
	../scripts/surf4_glmprep.sh

6a. When you are satisfied that you are done with preprocessing (this
might be after you've looked at the GLM results), tar-gzip the
preprocessing directory to save space:
	      tar czf preprocessing.tgz preprocessing

You can always unpack it to (re)do more preprocessing.
    tar xzf preprocessing.tgz

7. From your subject's analysis directory, run the glm analysis
   ../scripts/surf5_glmsurf.sh

8. Look at the results and draw your ROIs, etc.
