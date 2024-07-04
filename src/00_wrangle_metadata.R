# dirs
wd <- "/lustre/scratch126/casm/team154pc/at31/chemo_trees/"
canapps_dir <- "/nfs/cancer_ref01/nst_links/live/"
setwd(wd)
dir.create("out/metadata", showWarnings = FALSE)

# libraries
library(magrittr)

# get files from donor metadata
donor_metadata <-
  readr::read_tsv("data/donor_metadata.tsv")
sample_sheet <-
  donor_metadata %>%
  purrr::pmap(function(donor_id, donor_id_long, project_id, experiment_id,
                       donor_age) {
    list.files(file.path(canapps_dir, project_id), pattern = donor_id,
               full.names = TRUE) %>%
      tibble::enframe(value = "sample_dir") %>%
      dplyr::transmute(
        donor_id,
        sample_id = basename(sample_dir),
        bam = file.path(sample_dir, paste0(sample_id, ".sample.dupmarked.bam")),
        pindel_vcf = file.path(sample_dir, 
                               paste0(sample_id, ".pindel.annot.vcf.gz")),
        caveman_vcf = file.path(sample_dir, 
                                paste0(sample_id, ".caveman_c.annot.vcf.gz"))
      ) %>%
      # check files exist
      dplyr::filter(file.exists(bam),
                    file.exists(pindel_vcf),
                    file.exists(caveman_vcf))
  }) %>%
  dplyr::bind_rows()

# write sample sheet
sample_sheet %>%
  readr::write_csv("out/metadata/sample_sheet.csv")

# extract colony metadata
colony_metadata_raw <-
  readr::read_tsv("data/colony_metadata.tsv") %>%
  dplyr::mutate(donor_id = stringr::str_sub(PD_ID, 1, 7),
                # remove whitespaces
                dplyr::across(where(is.character), stringr::str_remove_all, 
                              pattern = stringr::fixed(" "))) %>%
  {split(., .$donor_id)}

# fix PD55781 IDs first
colony_metadata_PD55781 <-
  colony_metadata_raw$PD55781 %>%
  # fix colony type
  dplyr::mutate(sample_ID_in_COSMIC = gsub("Normal_blood", "Normal-blood", 
                                           sample_ID_in_COSMIC)) %>%
  tidyr::separate_wider_delim(
    sample_ID_in_COSMIC, delim = "_",
    names = c("donor_cosmic_id", "colony_timepoint", "donor_age_sex", 
              "plate_id", "colony_type", "well_id"))

# do others
colony_metadata <-
  colony_metadata_raw[!names(colony_metadata_raw) == "PD55781"] %>%
  dplyr::bind_rows() %>%
  # remove well entry
  dplyr::mutate(sample_ID_in_COSMIC = gsub("well_", "",
                                           sample_ID_in_COSMIC)) %>%
  tidyr::separate_wider_delim(
    sample_ID_in_COSMIC, delim = "_",
    names = c("donor_cosmic_id", "colony_timepoint", "donor_age_sex",
              "plate_id", "well_id", "colony_type")) %>%
  # bind together
  dplyr::bind_rows(colony_metadata_PD55781) %>%
  dplyr::transmute(
    colony_id = PD_ID,
    donor_id = stringr::str_sub(PD_ID, 1, 7),
    donor_cosmic_id,
    colony_timepoint,
    donor_age = stringr::str_sub(donor_age_sex, end = -3),
    donor_sex = stringr::str_sub(donor_age_sex, start = -2, end = -2),
    plate_id,
    well_id,
    colony_type) %>%
  dplyr::distinct()

# write colony metadata
colony_metadata %>%
  readr::write_tsv("out/metadata/colony_metadata.tsv")
