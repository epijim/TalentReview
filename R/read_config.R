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
  path = ".",
  file = "config.yaml"
){
  config <- yaml::read_yaml(file.path(path,file))

  job_levels <- config$job_levels %>%
    extract_nested()

  eoy_rating_levels <- tibble::tibble(
    name = config$draft_eoy_rating
    ) %>%
    dplyr::mutate(
      order = dplyr::row_number()
    )

  valid_colours <- tibble::tibble(
    name = config$valid_colours
    ) %>%
    dplyr::mutate(
      order = dplyr::row_number()
    )

  list(
    "job_levels" = job_levels,
    "eoy_rating_levels" = eoy_rating_levels,
    "valid_colours" = valid_colours
  )
}






