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

# nf inputs
nf=/software/team154/at31/process_sanger_lcm-nf/main.nf
config_file=/lustre/scratch125/casm/team268im/at31/RA_som_mut/scomatic/config/LSF.config
reference_genome=/lustre/scratch124/casm/team78pipelines/canpipe/live/ref/human/GRCh38_full_analysis_set_plus_decoy_hla/genome.fa
high_depth_region=/lustre/scratch124/casm/team78pipelines/canpipe/live/ref/human/GRCh38_full_analysis_set_plus_decoy_hla/shared/HiDepth_mrg1000_no_exon_coreChrs_v3.bed.gz

# create sample paths file
echo -e "sample_id\tmatch_normal_id\tpdid\tdata_dir"
echo -e "PD56034"

DONOR_ID= PD56034
LONG_DONOR_ID= PD56034_80M1
ALL_PROJECT_NUMBERS=2966 #If have more than one project number , can have as comma separated
EXP_ID=set1
DONOR_AGE=80

sample_paths=path/to/lcm_processing_input_snv.tsv
mut_type=snv
reference_genome=absolute/path/to/genome.fa
high_depth_region=absolute/path/to/HiDepth_mrg1000_no_exon_coreChrs_v3.bed.gz
reference_genome_cachedir=path/to/genome/cachedir
mutmat_kmer=3
outdir=path/to/out/directory

nextflow run $nf \
    -c $config_file \
    --sample_paths ${sample_paths} \
    --mut_type ${mut_type} \
    --reference_genome ${reference_genome} \
    --high_depth_region ${high_depth_region} \
    --outdir ${out_dir}
