#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # loading
    waiter::use_waiter(),
    waiter::waiterPreloader(),
    # Your application UI logic
    fluidPage(
      theme = bslib::bs_theme(bootswatch = "minty"),
      fluidRow(
        column(3, navlistPanel(
          widths = c(12, 12), "Filters",
          tabPanel(
            selectizeInput(
              "input_jobdesc",
              "Job title",
              unique(app_data$job_level),
              selected = unique(app_data$job_level),
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
              unique(app_data$promotion_readiness),
              selected = unique(app_data$promotion_readiness),
              multiple = TRUE
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
          ),
          tabPanel(
            selectizeInput(
              "input_location",
              "Location",
              unique(app_data$location),
              selected = unique(app_data$location),
              multiple = TRUE
            )
          ),
          tabPanel(hr()),
          tabPanel(
            actionButton(
              inputId='ab1',
              label="Edit data",
              icon = icon("external-link-alt"),
              onclick ="window.open('https://docs.google.com/spreadsheets/d/1DmXreJumY6EE2cTfwCsuQW_93aq-n3kQiPJXRAFUXhY/edit#gid=0', '_blank')"
            )
          )
        ))
        ,
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
              hr(),
              plotOutput("rating_manager"),
              plotOutput("rating_jobtitle")
            ),
            tabPanel(
              "Tables",
              h2("Ratings"),
              gt::gt_output("table_rating"),
              hr(),
              gt::gt_output("table_rating_manager"),
              hr(),
              gt::gt_output("table_rating_location"),
              hr(),
              gt::gt_output("table_rating_job"),
              hr(),
              gt::gt_output("table_rating_grade"),
              hr(),
              h2("Titles"),
              gt::gt_output("table_title"),
            )
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){

  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'TalentReview'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}

