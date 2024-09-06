# dirs
canapps_dir <- "/nfs/cancer_ref01/nst_links/live/"
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

# write sample sheet for low_input_trees
sample_sheet %>%
  readr::write_csv("out/metadata/sample_sheet.csv")

# write sample sheet for process_sanger_lcm-nf
# sample_id, pdid, bam, bai, vcf, vcf_tbi, match_normal_id, bam_match, bai_match
# indel cols: vcf_indel  vcf_tbi_indel
# snv cols: vcf_snv  vcf_tbi_snv
# indels sample sheet
sample_sheet %>%
  dplyr::transmute(sample_id, pdid = donor_id,
                   bam,
                   bai = paste0(bam, ".bai"),
                   bas = paste0(bam, ".bas"),
                   met = paste0(bam, ".met.gz"),
                   vcf_snp = caveman_vcf,
                   vcf_tbi_snp = paste0(caveman_vcf, ".tbi"),
                   vcf_indel = pindel_vcf,
                   vcf_tbi_indel = paste0(pindel_vcf, ".tbi"),
                   match_normal_id = "PDv38is_wgs",
                   bam_match = "/nfs/cancer_ref01/nst_links/live/2480/PDv38is_wgs/PDv38is_wgs.sample.dupmarked.bam",
                   bai_match = paste0(bam_match, ".bai")) %>%
  readr::write_tsv("out/process_sanger_lcm/sample_sheet.tsv")

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
