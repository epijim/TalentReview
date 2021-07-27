#' Read in the formatted 'people' YAMLs
#'
#' @description
#' \Sexpr[results=rd, stage=render]{lifecycle::badge("questioning")}
#' `read_people()` allows you to pull in data from the YAML files that
#' contain info on your team.
#'
#' @param path The path to the files of interest. Defaults to current dir.
#' @param exclude As it pulls all files ending in `.yaml`, this lets you
#' exclude certain files that don't contain data, like `config.yaml`.
#' @return Tibble with info per-person. Itemized info, like highlights
#' and dev areas are nested vectors within a cell. See
#' the function [enrich_people()] to tidy up the data.
#' @export
#'
read_people <- function(
  path = ".",
  exclude = c("config.yaml")
){
  files <- list.files(
    path = path,
    pattern = "\\.yaml$"
  )

  files <- setdiff(
    files,exclude
  )

  output <- NULL
  for (file in files) {
    manager <- gsub(".yaml","",file)
    manager <- gsub("_"," ",manager)
    i_manager <- yaml::read_yaml(file.path(path,file))
    for (person in names(i_manager)) {
      output <- dplyr::bind_rows(
        hlp_extract_person(i_manager, person,manager),
        output
      )
    }
  }

  output
}

#' Take person from list
#'
#' Pulls out person data from list extracted from YAML.
#'
#' @param manager_data Data from one managers YAML
#' @param j Name of the person to extract
#'
#' @noRd
hlp_extract_person <- function(manager_data, j, manager){
  # input data has hard coded fixed format
  value <- name <- job_level <- NULL

# function
  j_all_roles <- manager_data[[j]]$job_levels %>%
    extract_nested %>%
    dplyr::mutate(
      job_level = name,
      name = j,
      manager = manager
    )

  photo_url <- manager_data[[j]]$photo_url

  if (is.null(photo_url)) photo_url <- paste0("https://i.pravatar.cc/150?img=",round(runif(n = 1,0,50)))

  # Make tibble with person data
  tibble::tibble(
    name = j,
    userid = manager_data[[j]]$userid,
    photo_url = photo_url,
    job_level = j_all_roles %>%
      dplyr::filter(order == max(order)) %>%
      dplyr::pull(job_level),
    started_role = j_all_roles %>%
      dplyr::filter(order == max(order)) %>%
      dplyr::pull(value),
    draft_eoy_rating = manager_data[[j]]$draft_eoy_rating,
    promotion_readiness = as.character(manager_data[[j]]$promotion_readiness),

    highlights = list(manager_data[[j]]$highlights),
    key_dev_areas = list(manager_data[[j]]$key_dev_areas)
  )
}















