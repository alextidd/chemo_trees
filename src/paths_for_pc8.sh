#!/bin/bash
# creating table of paths to BAMs, intervals, and VAFs for Peter
wd=/lustre/scratch126/casm/team154pc/at31/chemo_trees
cd $wd
mkdir -p out/paths_for_pc8/

echo "donor_id,sample_id,bam,pindel_vcf,pindel_intervals,pindel_vaf,caveman_vcf,caveman_intervals,caveman_vaf" \
> out/paths_for_pc8/paths_for_pc8.csv
while read -r donor_id sample_id bam pindel_vcf caveman_vcf ; do

  # get snv intervals and vafs
  caveman_int=$wd/out/$donor_id/caveman/${donor_id}_intervals.bed
  caveman_vaf=$wd/out/$donor_id/caveman/${donor_id}_caveman_vaf.tsv
  if [ ! -f $caveman_vaf ] ; then 
    caveman_vaf=NA
  fi

  # get indel invervals and vafs
  pindel_int=$wd/out/$donor_id/pindel/${donor_id}_intervals.bed
  pindel_vaf=$wd/out/$donor_id/pindel/${donor_id}_pindel_vaf.tsv
  if [ ! -f $pindel_vaf ] ; then 
    pindel_vaf=NA
  fi

  echo "$donor_id,$sample_id,$bam,$pindel_vcf,$pindel_int,$pindel_vaf,$caveman_vcf,$caveman_int,$caveman_vaf" \
  >> out/paths_for_pc8/paths_for_pc8.csv

done < <(sed 1d out/metadata/sample_sheet.csv | grep "PD63266\|PD63267\|PD63268" | tr ',' '\t')

