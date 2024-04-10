#!/bin/bash

# Run the workflow on the test data, and write the output to output/
nextflow run ../main.nf \
    --sample_sheet sample_sheet.csv \
    --outdir out \
    -c /lustre/scratch125/casm/team268im/at31/RA_som_mut/scomatic/config/LSF.config


# from Lori:
# usage:
# runlcmfilter.sh \
#   <vcfin> \
#   <BAM>\
#   <outputdirectory> \
#   <PREFIX> \
#   <build> \
#   <fragthreshold|4>

cd /lustre/scratch126/casm/team154pc/at31/chemo_trees/nf-chemo-trees/test/work/ac/13dba96a658cf4872ab8bf2131b516
/lustre/scratch126/casm/team273jn/share/runlcmfilter.sh \
    PD56034ct.caveman_c.annot.vcf.gz \
    PD56034ct.sample.dupmarked.bam \
    out/ \
    PD56034ct \
    hg38 \
    3