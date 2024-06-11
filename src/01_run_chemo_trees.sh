#!/bin/bash
# cd /lustre/scratch126/casm/team154pc/at31/chemo_trees; bsub -q week -M2000 -R "span[hosts=1] select[mem>2000] rusage[mem=2000]" -J chemo_trees -o log/chemo_trees_%J.out -e log/chemo_trees_%J.err "bash src/01_run_chemo_trees.sh"

# modules
module load singularity

# run the workflow 
nextflow run nf-chemo-trees/ \
    --sample_sheet out/metadata/sample_sheet.csv \
    --project_type WES \
    --outdir out \
    -c /lustre/scratch125/casm/team268im/at31/RA_som_mut/scomatic/config/LSF.config \
    -resume \
    -N at31@sanger.ac.uk
