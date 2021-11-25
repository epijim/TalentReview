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


  # body

  valid_colours <- config$valid_colours %>%
    dplyr::slice(1:nrow(config$job_levels)) %>%
    dplyr::pull(name)

  # tidy ratings
  people <- people %>%
    left_join(
      people %>%
        dplyr::select(userid, eoy_rating) %>%
        dplyr::mutate(
          rating = strsplit(as.character(eoy_rating), "/")
        ) %>%
        tidyr::unnest(rating) %>%
        mutate(trimws(rating)) %>%
        dplyr::left_join(
          config$eoy_rating_levels,
          by = c("rating" = "name")
        ) %>%
        dplyr::group_by(userid) %>%
        dplyr::mutate(
          rating_average = mean(order)
        ) %>% dplyr::arrange(desc(order)) %>% dplyr::slice(1) %>%
        dplyr::mutate(
          eoy_rating_formatted = dplyr::case_when(
            order == rating_average ~ rating,
            order < rating_average ~ paste(rating,"(borderline higher)"), # not posss?
            order > rating_average ~ paste(rating,"(borderline lower)")
          )
        ) %>%
        select(userid,eoy_rating_formatted,eoy_rating_clean = rating),
      by = "userid"
    )




  # clean everything else

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
    dplyr::left_join(
      config$eoy_rating_levels %>%
        dplyr::select(
          eoy_ratings = name, eoy_rating_order = order
        ),
      by = c("eoy_rating_clean" = "eoy_ratings")
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
    ) %>%
    dplyr::mutate(
      eoy_rating_badge = glue::glue(
        '<span class="right badge badge-secondary" status="secondary">{eoy_rating}</span>'
      ),
      promotion_badge = dplyr::case_when(

        promotion_readiness != "NA" ~ glue::glue(
          '<span class="right badge badge-danger" status="danger">{promotion}</span>'
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



