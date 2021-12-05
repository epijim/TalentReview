#' Merge the people and config files
#'
#' @description
#' `enrich_people()` Merge the people and config file outputs from the `read_`
#' files.
#'
#' @param people People from the output of [read_people()].
#' @param config Config data from [read_config()].
#' @param months_in_role_cuts Numeric vector of length 2 with cut points for time in role badges.
#' @return Tibble with info per-person. I
#' @export
#'
#'

enrich_people <- function(
  people = NULL,
  config = NULL,
  months_in_role_cuts = c(12*3,12*6)
){
  # checks
  if (length(months_in_role_cuts) != 2) stop("months_in_role_cuts should be length 2")
  if (!class(months_in_role_cuts) == "numeric") stop("months_in_role_cuts should be numeric")


  people %>%
    # Job level order
    dplyr::left_join(
      config$job_levels %>%
        dplyr::mutate(
          job_colour = dplyr::case_when(
            dplyr::row_number() %% 2 == 0 ~ "teal",
             TRUE ~ "lightblue"
          )
          ) %>%
          dplyr::rename(
            job_order = order
          ),
      by = c("job_level" = "job_levels")
    )  %>%
    # Eoy rating levels
    dplyr::left_join(
      config$eoy_rating_levels %>%
        dplyr::select(
          eoy_rating_levels, eoy_order = order
        ),
      by = c("eoy_rating" = "eoy_rating_levels")
    )  %>%
    # enrich with mutates
    dplyr::mutate(
      month_in_role = round(as.numeric(Sys.Date() - as.Date(job_level_since))/30.25,1)
    ) %>%
    dplyr::mutate(
      eoy_rating_badge = glue::glue(
        '<span class="right badge badge-secondary" status="secondary">{eoy_rating}</span>'
      ),
      promotion_badge = dplyr::case_when(
        promotion_readiness != "NA" ~ glue::glue(
          '<span class="right badge badge-danger" status="danger">Promotion: {promotion_readiness}</span>'
        ),
        TRUE ~ ""
      ),
      month_badge = dplyr::case_when(
        is.na(month_in_role) ~ glue::glue(""),
        month_in_role < months_in_role_cuts[1] ~ glue::glue(
          '<span class="right badge badge-info" status="info">{paste0({month_in_role},"months in role.")}</span>'
        ),
        month_in_role < months_in_role_cuts[2] ~ glue::glue(
          '<span class="right badge badge-success" status="success">{paste({month_in_role},"months in role.")}</span>'
        ),
        TRUE ~ glue::glue(
          '<span class="right badge badge-warning" status="warning">{paste({month_in_role},"months in role.")}</span>'
        )
      )
    )

}



