ui <- fluidPage(
  theme = bs_theme(bootswatch = "minty"),
  tags$head(
    tags$script(src = "https://cdn.jsdelivr.net/npm/admin-lte@3.1/dist/js/adminlte.min.js"),
    tags$link(rel = "stylesheet", type = "text/css", href = "app.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "app.min.css")
  ),
  fluidRow(
    column(3, navlistPanel(
      widths = c(12, 12), "Filters",
      tabPanel(
        selectizeInput(
          "input_jobdesc",
          "Job title",
          unique(app_data$job_level_desc),
          selected = unique(app_data$job_level_desc),
          multiple = TRUE
        )
      ),
      tabPanel(
        selectizeInput(
          "input_eoy_rating",
          "EoY rating",
          unique(app_data$eoy_rating),
          selected = unique(app_data$eoy_rating),
          multiple = TRUE
        )
      ),
      tabPanel(
        selectizeInput(
          "input_promotion",
          "Promotion status",
          c("Candidate","Everyone"),
          selected = "Everyone",
          multiple = FALSE
        )
      ),
      tabPanel(
        selectizeInput(
          "input_manager",
          "Manager",
          unique(app_data$manager),
          selected = unique(app_data$manager),
          multiple = TRUE
        )
      )
    )),
    column(
      9,
      navbarPage(
        title = "Talent review",
        tabPanel(
          "Cards",
          uiOutput("cards")
        ),
        tabPanel(
          "Levels",
          plotOutput("levels_plot")
          ),
        tabPanel(
          "Ratings",
          plotOutput("ratings_labels"),
          plotOutput("rating_manager"),
          plotOutput("rating_jobtitle")
          ),
        tabPanel(
          "Tables",
          h2("Ratings"),
          gt_output("table_rating"),
          hr(),
          gt_output("table_rating_manager"),
          hr(),
          h2("Titles"),
          gt_output("table_title"),
          )
        )
    )
  )
)


