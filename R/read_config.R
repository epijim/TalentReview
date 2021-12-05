#' Read in the formatted 'config' YAML
#'
#' @description
#' `read_config()` pulls in the config file, that has info like what
#' are the different roles, and allowable values for some parameters (for CICD).
#'
#' @param path The path to the file of interest. Defaults to current dir.
#' @param file This is likely to always be `config.yaml`, but I was stuck
#' between calling it config, and 'lookups' - as initially it only contains
#' lookups.
#' See the function [enrich_people()] to tidy up the data.
#' @export
#'

read_config <- function(
  sheet_id
){
  add_order <- function(tibble){
    tibble %>%
      dplyr::mutate(order = dplyr::row_number())
  }

  list(
    "grade_levels" = googlesheets4::read_sheet(
        sheet_id,
        sheet = "lkp_grade_levels"
      ) %>% add_order,
    "job_levels" = googlesheets4::read_sheet(
      sheet_id,
      sheet = "lkp_job_levels"
    ) %>% add_order,
    "eoy_rating_levels" = googlesheets4::read_sheet(
      sheet_id,
      sheet = "lkp_eoy_levels"
    ) %>% add_order,
    "eoy_rating_levels" = googlesheets4::read_sheet(
      sheet_id,
      sheet = "lkp_promotion_levels"
    ) %>% add_order
  )
}






