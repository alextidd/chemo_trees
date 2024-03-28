#!/bin/bash

# dirs
wd=/lustre/scratch126/casm/team154pc/at31/chemo_trees/
canapps_dir=/nfs/cancer_ref01/nst_links/live/
cd $wd

(
    echo -e 'donor_id,sample_id,project_number,bam,pindel_vcf,caveman_vcf' ;
    while read -r donor_id donor_id_long project_number exp_number age ; do

        for sample_path in $(ls -d $canapps_dir/$project_number/${donor_id}*/) ; do
            sample_id=$(basename $sample_path)
            
            # check for bam file
            bam=$sample_path/$sample_id.sample.dupmarked.bam
            [[ ! -f $bam ]] && bam=NA

            # check for pindel output
            pindel=$sample_path/$sample_id.pindel.annot.vcf.gz
            [[ ! -f $pindel ]] && pindel=NA

            # check for caveman output
            caveman_c=$sample_path/$sample_id.caveman_c.annot.vcf.gz
            [[ ! -f $caveman_c ]] && caveman_c=NA
            
            echo -e "$donor_id,$sample_id,$project_number,$bam,$pindel,$caveman_c" ;
        done

    done < <(sed 1d data/donor_metadata.tsv)
) | cat > data/sample_sheet.csv
