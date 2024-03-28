#!/bin/bash
# cd /lustre/scratch126/casm/team154pc/at31/chemo_trees/; . ~/.bashrc; mamba activate trees; ~/bin/jsub lsf -q week -n lcm_filt -c 1 -m 10g -l log "bash src/01_apply_LCM_filters.sh" | bsub

# dirs
wd=/lustre/scratch126/casm/team154pc/at31/chemo_trees/
out_dir=out/lcm_filtered/
cd $wd
mkdir -p $out_dir

# modules
module load hairpin/1.0.6
module load vcfilter/1.0.4
module load tabix/1.13
module load cgpVAFcommand/2.5.0
module load R/4.1.0 

# inputs
nf=/software/team154/at31/process_sanger_lcm-nf/main.nf
config_file=/lustre/scratch125/casm/team268im/at31/RA_som_mut/scomatic/config/LSF.config
reference_genome=/lustre/scratch124/casm/team78pipelines/canpipe/live/ref/human/GRCh38_full_analysis_set_plus_decoy_hla/genome.fa
high_depth_region=/lustre/scratch124/casm/team78pipelines/canpipe/live/ref/human/GRCh38_full_analysis_set_plus_decoy_hla/shared/HiDepth_mrg1000_no_exon_coreChrs_v3.bed.gz

# create sample paths file

DONOR_ID= PD56034
LONG_DONOR_ID= PD56034_80M1
ALL_PROJECT_NUMBERS=2966 #If have more than one project number , can have as comma separated
EXP_ID=set1
DONOR_AGE=80

nextflow-23.10.1-all run $nf \
    -c $config_file \
    --sample_paths ${sample_paths} \
    --mut_type ${mut_type} \
    --reference_genome ${reference_genome} \
    --high_depth_region ${high_depth_region} \
    --outdir ${out_dir}"
