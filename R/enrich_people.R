#' Merge the people and config files
#'
#' @description
#' \Sexpr[results=rd, stage=render]{lifecycle::badge("questioning")}
#' `enrich_people()` Merge the people and config file outputs from the `read_`
#' files.
#'
#' @param people People from the output of [read_people()].
#' @param config Config data from [read_config()].
#' @return Tibble with info per-person. I
#' @export
#'
#'

enrich_people <- function(
  people = NULL,
  config = NULL
){

  valid_colours <- config$valid_colours %>%
    dplyr::slice(1:nrow(config$job_levels)) %>%
    dplyr::pull(name)

  people %>%
    dplyr::left_join(
      config$job_levels %>%
        dplyr::mutate(job_colour = valid_colours) %>%
        dplyr::select(
          job_level = name, job_level_desc = value,
          job_colour, job_order = order
          ),
      by = "job_level"
    )  %>%
    dplyr::mutate(
      month_in_role = round(as.numeric(Sys.Date() - as.Date(started_role))/30.25,1),
      promotion = dplyr::case_when(
        is.null(promotion_readiness) ~ "NA",
        TRUE ~ paste("Promotion readiness:",promotion_readiness)
      )
    ) %>%
    dplyr::arrange(
      job_order, month_in_role
    )

}



