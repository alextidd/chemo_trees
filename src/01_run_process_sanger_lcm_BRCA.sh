#!/bin/bash
# cd /lustre/scratch126/casm/team154pc/at31/chemo_trees; bsub -q basement -M2000 -R "span[hosts=1] select[mem>2000] rusage[mem=2000]" -J process_sanger_lcm -o log/process_sanger_lcm_%J.out -e log/process_sanger_lcm_%J.err "bash src/01_run_process_sanger_lcm_BRCA.sh"

# modules
module load python/3.11.4
# pip install scipy
module load hairpin/1.0.7
module load vcfilter/1.0.4
module load tabix/1.18
module load cgpVAFcommand/2.5.0
module load R/4.1.3
module load gatk-4.5.0.0

# dirs
outdir=out/process_sanger_lcm/BRCA/

# run on the BRCA donors only
head -n1 out/process_sanger_lcm/sample_sheet.tsv \
> $outdir/sample_sheet.tsv
cat out/process_sanger_lcm/sample_sheet.tsv |
grep "PD63266\|PD63267\|PD63268" \
>> $outdir/sample_sheet.tsv

# run the workflow
marker_basename=/lustre/scratch126/casm/team267ms/al35/hackathon2024/markers/GRCh38.autosomes.phase3_shapeit2_mvncall_integrated.20130502.SNV.genotype.sselect_v4_MAF_0.4_LD_0.8.liftover
nextflow run ../process_sanger_lcm-nf/ \
  --sample_paths $outdir/sample_sheet.tsv \
  --reference_genome /lustre/scratch124/casm/team78pipelines/canpipe/live/ref/human/GRCh38_full_analysis_set_plus_decoy_hla/genome.fa \
  --high_depth_region /lustre/scratch126/casm/team273jn/share/pileups/reference_data/hg38/highdepth.bed.gz \
  --outdir $outdir/ \
  --marker_bed $marker_basename.bed \
  --marker_txt $marker_basename.txt \
  -w work/process_sanger_lcm/ \
  -c ../process_sanger_lcm-nf/sanger_lsf.config \
  -N at31@sanger.ac.uk \
  -resume
