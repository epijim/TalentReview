#' Extract nested
#'
#' Takes out the named vector and gives back tibble with order as col
#'
#' @param data List from YAML
#'
#' @noRd
extract_nested <- function(data){
  # created by enframe
  #value <- NULL

  # function
  tibble::enframe(data) %>%
    tidyr::unnest(
      cols = c(value)
    ) %>%
    dplyr::mutate(
      order = dplyr::row_number()
    )
}
