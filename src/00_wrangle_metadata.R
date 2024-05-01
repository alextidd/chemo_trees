# dirs
wd <- "/lustre/scratch126/casm/team154pc/at31/chemo_trees/"
canapps_dir <- "/nfs/cancer_ref01/nst_links/live/"
setwd(wd)

# libraries
library(magrittr)

# get files from donor metadata
donor_metadata <-
    readr::read_tsv("data/donor_metadata.tsv")
sample_sheet <-
    donor_metadata %>%
    purrr::pmap(function(donor_id, donor_id_long, project_id, experiment_id, donor_age) {
        list.files(
            file.path(canapps_dir, project_id),
            pattern = donor_id, 
            full.names = T) %>%
            tibble::enframe(value = "sample_dir") %>%
            dplyr::transmute(
                donor_id = donor_id,
                sample_id = basename(sample_dir),
                project_id = project_id,
                experiment_id = experiment_id,
                bam = file.path(sample_dir, paste0(sample_id, ".sample.dupmarked.bam")),
                pindel_vcf = file.path(sample_dir, paste0(sample_id, ".pindel.annot.vcf.gz")),
                caveman_vcf = file.path(sample_dir, paste0(sample_id, ".caveman_c.annot.vcf.gz"))
            ) %>%
            # check if the files exist
            dplyr::mutate(
                dplyr::across(c('bam', 'pindel_vcf', 'caveman_vcf'),
                ~ ifelse(file.exists(.), ., NA)))
    }) %>%
    dplyr::bind_rows()

# write sample sheet
sample_sheet %>%
    readr::write_csv("data/sample_sheet.csv")