library(readxl)

donor_id <- "PD55782_75M1"
donor_file <- switch(donor_id,
                     "PD55782_75M1" = "~/Data/chemo/canapps/75M1_PD55782_Cancer_Pipeline_Reports_SampleDetails.xls")

pt <- read_excel(path = donor_file,
                 sheet = 1, skip = 2)

pt <- pt[1:384,]
pt <- pt[pt$Sample != "PD55782aa", ]
# paste0(pt$Sample, collapse = ",")
# paste0(rep("2911", 384), collapse = ",")
# paste0(rep("2480", 384), collapse = ",")
# paste0(rep("PDv38is_wgs", 384), collapse = ",")

sample_ids <- pt$Sample
new_commands <- sapply(sample_ids, function(sample_id){
  one_command <- paste0('bsub -R "select[mem>12000] rusage[mem=12000] span[hosts=1]" -M12000 -o out.%J.log -e err.%J.log -n 12 hairpin -v /lustre/scratch119/casm/team154pc/ld18/chemo/PD55782_75M1/sub/', sample_id,'_complete.vcf -b /nfs/cancer_ref01/nst_links/live/2911/', sample_id, '/', sample_id,'.sample.dupmarked.bam -o /lustre/scratch119/casm/team154pc/ld18/chemo/PD55782_75M1/sub/ -g "38"')
  return(one_command)
})

fileConn<-file(sprintf("~/chemo/%s_commands_hairpin.txt", donor_id))
writeLines(new_commands, fileConn)
close(fileConn)

