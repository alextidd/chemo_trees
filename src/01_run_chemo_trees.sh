#!/bin/bash
# cd /lustre/scratch126/casm/team154pc/at31/chemo_trees; ~/bin/jsub lsf -q week -n chemo_trees  -m 2g -l log "bash src/01_run_chemo_trees.sh" | bsub

# modules
module load singularity

# run the workflow 
nextflow run nf-chemo-trees/ \
    --sample_sheet data/sample_sheet.csv \
    --project_type WES \
    --outdir out \
    -c /lustre/scratch125/casm/team268im/at31/RA_som_mut/scomatic/config/LSF.config \
    -resume \
    -N at31@sanger.ac.uk
