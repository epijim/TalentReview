
library(shiny)
library(bs4Dash)
library(TalentReview)
library(DT)


config <- read_config()
people <- read_people()

app_data <- enrich_people(
  people = people, config = config
  )

talent_review_app(app_data)

## APP
talent_review_app <- function(app_data){
  require(shiny)
  shinyApp(
    ui = dashboardPage(
      header = dashboardHeader(disable = TRUE),
      sidebar = dashboardSidebar(
        sidebarMenu(
          id = "sidebarMenu",
          menuItem(
            "Team",
            tabName = "team",
            icon = icon("circle")
          ),
          menuItem(
            "Job Levels",
            tabName = "joblevels",
            icon = icon("circle")
          ),
          menuItem(
            "Promotions",
            tabName = "promotions",
            icon = icon("circle")
          ),
          menuItem(
            "Highest EoY",
            tabName = "eoy",
            icon = icon("circle")
          )
        )
      ),
      body = dashboardBody(
        tabItems(
          tabItem(
            tabName = "team",
            fluidRow(
              lapply(1:nrow(app_data), function(i) {
                i_data <- app_data[i,]
                userBox(
                  id = "userbox",
                  width = 4,
                  title = userDescription(
                    title = i_data$name,
                    subtitle = i_data$job_level_desc,
                    type = 2,
                    image = i_data$photo_url,
                  ),
                  status = i_data$job_colour,
                  #gradient = TRUE,
                  background = i_data$job_colour,
                  boxToolSize = "lg",
                  list(
                    h4("Highlights"),
                    p(i_data$highlights[[1]][1]),
                    p(i_data$highlights[[1]][2]),
                    p(i_data$highlights[[1]][3]),
                    h4("Dev areas"),
                    p(i_data$key_dev_areas[[1]][1]),
                    p(i_data$key_dev_areas[[1]][2]),
                    p(i_data$key_dev_areas[[1]][3])
                  ),
                  footer = HTML(paste(i_data$draft_eoy_rating_badge,i_data$month_badge," ",i_data$promotion_badge))
                )
              })
            )
          ),
          tabItem(
            tabName = "joblevels",
            plotOutput("joblevels")
          ),
          tabItem(
            tabName = "promotions",
            DTOutput("promotions")
          ),
          tabItem(
            tabName = "eoy",
            DTOutput("eoy")
          )
        )
      ),
      controlbar = dashboardControlbar(),
      title = "Box layout columns"
    ),
    server = function(input, output) {
      output$joblevels <- renderPlot({
        app_data %>%
          dplyr::select(job_order,job_level_desc,name) %>%
          dplyr::group_by(job_order,job_level_desc) %>%
          dplyr::mutate(
            order = dplyr::row_number()
          ) %>%
          ggplot2::ggplot() +
          ggplot2::geom_label(
            ggplot2::aes(
              x = job_level_desc,y = order,label = name,
              size = 4,
              fill = factor(job_level_desc)), colour = "white", fontface = "bold",
            show.legend = FALSE
          ) +
          ggthemes::theme_hc() +
          ggplot2::labs(
            title = "Team job level distribution",
            x = "Job levels",
            y = "People",
            subtitle = paste("Total team size =",nrow(app_data),"data scientists.")
          )
      })
      output$promotions = renderDT({
        app_data %>%
          dplyr::filter(promotion_readiness != "NA") %>%
          dplyr::arrange(job_level) %>%
          dplyr::mutate(
            Name = name,
            `Job level` = glue::glue("{job_level_desc} ({job_level})"),
            `EoY` = draft_eoy_rating,
            Highlights = highlights,
            `Dev areas` = key_dev_areas,
            `Months in role` = month_in_role,
            Timing = promotion
          ) %>%
          dplyr::select(Name:Timing) %>%
          DT::datatable(rownames = FALSE)
      })
      output$eoy = renderDT({
        app_data %>%
          dplyr::filter(draft_eoy_rating_order == max(draft_eoy_rating_order)) %>%
          dplyr::arrange(job_level) %>%
          dplyr::mutate(
            Name = name,
            `Job level` = glue::glue("{job_level_desc} ({job_level})"),
            `EoY` = draft_eoy_rating,
            Highlights = highlights,
            `Dev areas` = key_dev_areas,
            `Months in role` = month_in_role,
            Timing = promotion
          ) %>%
          dplyr::select(Name:Timing) %>%
          DT::datatable(rownames = FALSE)
      })
    }
  )

}









