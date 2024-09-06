#!/bin/bash
# cd /lustre/scratch126/casm/team154pc/at31/chemo_trees; bsub -q basement -M2000 -R "span[hosts=1] select[mem>2000] rusage[mem=2000]" -J chemo_trees -o log/chemo_trees_%J.out -e log/chemo_trees_%J.err "bash src/01_run_chemo_trees.sh"

# modules
module load singularity

# run on the BRCA donors only
head -n1 out/metadata/sample_sheet.csv > out/metadata/sample_sheet_BRCA.csv
cat out/metadata/sample_sheet.csv |
grep "PD63266\|PD63267\|PD63268" \
>> out/metadata/sample_sheet_BRCA.csv

# run the workflow 
nextflow run ../low_input_trees/ \
    --sample_sheet out/metadata/sample_sheet_BRCA.csv \
    --sequencing_type WGS \
    -profile sanger_hg38 \
    --outdir out \
    -resume \
    -N at31@sanger.ac.uk
