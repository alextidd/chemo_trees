#!/bin/bash
# cd /lustre/scratch126/casm/team154pc/at31/chemo_trees; bsub -q basement -M2000 -R "span[hosts=1] select[mem>2000] rusage[mem=2000]" -J chemo_trees -o log/chemo_trees_%J.out -e log/chemo_trees_%J.err "bash src/01_run_chemo_trees.sh"

# modules
module load singularity

# run the workflow 
nextflow run ../low_input_trees/ \
    --sample_sheet out/metadata/sample_sheet.csv \
    --sequencing_type WGS \
    -profile sanger_hg38 \
    --outdir out/low_input_trees/ \
    -w work/low_input_trees/ \
    -N at31@sanger.ac.uk \
    -resume
