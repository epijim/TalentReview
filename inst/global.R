#################### global ##############################
months_in_role_cuts <- c(12*3,12*6)

sheet_id <- Sys.getenv("TALENTREVIEW_SHEETID")

## Google sheet
googlesheets4::gs4_auth(cache = "secrets", email = Sys.getenv("TALENTREVIEW_EMAIL"))

config <- read_config(sheet_id)
people <- read_people(sheet_id)

app_data <- enrich_people(
  people = people, config = config, months_in_role_cuts
)

#################### Roche ##############################

board <- pins::board_rsconnect(server = "https://connect.apollo.roche.com")

app_data <- app_data %>%
  dplyr::left_join(
    pins::pin_read(board, "blackj9/dsx_team") %>%
      dplyr::select(
        userid = unixid,
        location = group
      ),
    by = "userid"
  )


# add Roche photos (in loop as httr request)
photos <- NULL
for(i in app_data$name){
  photo_url = tolower(i)
  photo_url = gsub(" ","-",photo_url)
  photo_url = paste0(
    "https://pages.github.roche.com/DSX/DSX/author/",photo_url,"/avatar.jpg"
  )

  # check exists
  if (httr::http_error(photo_url)) {
    photo_url <- paste0("https://i.pravatar.cc/150?img=",round(runif(n = 1,0,50)))
  }
  photos <- dplyr::bind_rows(
    tibble::tibble(
      name = i,
      photo_url = photo_url
    ),
    photos
  )
}

app_data <- app_data %>%
  dplyr::left_join(photos, by = "name")
