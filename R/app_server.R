#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

    # hide waiter
    #waiter::waiter_hide()

  ## Filter data -------------------------------------------
  filtered_data <- reactive({

    validate(
      need(nrow(app_data) > 0, 'Waiting on data.')
    )

    i_data <- app_data %>%
      dplyr::filter(
        job_level %in% input$input_jobdesc &
          eoy_rating %in% input$input_eoy_rating &
          manager %in% input$input_manager &
          location %in% input$input_location
      )

    validate(
      need(nrow(i_data) > 0, 'Too many filters applied! No one is left.')
    )

    i_data

  })


  ## Cards -------------------------------------------------

  output$cards <- renderUI({
    i_data <- filtered_data() %>%
      dplyr::arrange(job_order,month_in_role)

    # First make the cards
    args <-
      lapply(1:dim(i_data)[1], function(x)
        card(
          img = i_data[x, "photo_url"],
          name = i_data[x, "name"],
          job_level = i_data[x, "job_level"],
          highlights_1 = i_data[x, "highlight_1"],
          highlights_2 = i_data[x, "highlight_2"],
          highlights_3 = i_data[x, "highlight_3"],
          dev_1 = i_data[x, "dev_1"],
          dev_2 = i_data[x, "dev_2"],
          dev_3 = i_data[x, "dev_3"],
          months_in_role = i_data[x, "month_in_role"],
          rating = i_data[x, "eoy_rating"],
          job_colour = i_data[x, "job_colour"],
          promotion = i_data[x, "promotion_readiness"],
          # options
          months_in_role_cuts = months_in_role_cuts
        )
      )

    # Make sure to add other arguments to the list:
    args$cellArgs <- list(style = "
            width: 500px;
            height: auto;
            margin: 5px;
            ")

    # make five columns with four images each
    # cols <-
    #   lapply(seq(4, dim(i_data)[1], 4), function(x) {
    #     column(width = 2, verticalLayout(args[(x - 3):x], fluid = TRUE))
    #   })


    # then use fluidRow to arrange the columns
    do.call(shiny::fluidRow, args)

  })

  #### Plots --------

  output$levels_plot <- renderPlot({
    filtered_data() %>%
      dplyr::select(job_order,grade,name,job_level) %>%
      dplyr::mutate(name = paste0(name," (",grade,")")) %>%
      dplyr::group_by(job_level) %>%
      dplyr::mutate(
        order = dplyr::row_number()
      ) %>%
      ggplot2::ggplot() +
      ggplot2::geom_label(
        ggplot2::aes(
          x = factor(job_level, unique(config$job_levels$job_levels)),
          y = order,label = name,
          size = 4,
          fill = factor(job_level)), colour = "white", fontface = "bold",
        show.legend = FALSE
      ) +
      ggthemes::theme_fivethirtyeight() +
      ggplot2::labs(
        title = "Team job level distribution",
        x = "Job levels",
        y = "People",
        subtitle = paste0("Total team size = ",nrow(app_data)," data scientists (currently",nrow(filtered_data()),")")
      )
  })

  #### Ratings Plots --------

  output$ratings_labels <- renderPlot({
    filtered_data() %>%
      dplyr::select(job_order,grade,name,job_level,eoy_rating) %>%
      dplyr::mutate(name = paste0(name," (",grade,")")) %>%
      dplyr::group_by(eoy_rating) %>% dplyr::arrange(grade) %>%
      dplyr::mutate(
        order = dplyr::row_number()
      ) %>%
      ggplot2::ggplot() +
      ggplot2::geom_label(
        ggplot2::aes(
          x = factor(eoy_rating, unique(config$eoy_rating_levels$eoy_rating_levels)),
          y = order,label = name,
          size = 4,
          fill = factor(job_level)), colour = "white", fontface = "bold",
        show.legend = FALSE
      ) +
      ggthemes::theme_fivethirtyeight() +
      ggplot2::labs(
        title = "Team rating distribution",
        x = "Rating",
        y = "People",
        subtitle = paste0("Total team size = ",nrow(app_data)," data scientists (currently",nrow(filtered_data()),")")
      )
  })

  output$rating_manager <- renderPlot({
    filtered_data() %>%
      dplyr::group_by(eoy_rating, manager) %>%
      dplyr::summarise(
        n = dplyr::n()
      ) %>%
      dplyr::mutate(
        order = factor(eoy_rating, config$eoy_rating_levels$eoy_rating_levels)
      ) %>%
      ggplot2::ggplot(
        ggplot2::aes(
          x = order,
          y = n,
          fill = manager
        )
      ) +
      ggplot2::geom_bar(
        stat = "identity"
      ) +
      ggthemes::theme_fivethirtyeight() +
      ggplot2::labs(
        title = "Ratings by manager",
        x = "Ratings",
        y = "People",
        subtitle = paste("Total team size =",nrow(filtered_data()),"data scientists.")
      )
  })

  output$rating_jobtitle <- renderPlot({
    filtered_data() %>%
      dplyr::group_by(eoy_rating, job_level) %>%
      dplyr::summarise(
        n = dplyr::n()
      ) %>%
      dplyr::mutate(
        order = factor(eoy_rating, config$eoy_rating_levels$eoy_rating_levels)
      ) %>%
      ggplot2::ggplot(
        ggplot2::aes(
          x = order,
          y = n,
          fill = job_level
        )
      ) +
      ggplot2::geom_bar(
        stat = "identity"
      ) +
      ggthemes::theme_fivethirtyeight() +
      ggplot2::labs(
        title = "Ratings by job level",
        x = "Ratings",
        y = "People",
        subtitle = paste("Total team size =",nrow(filtered_data()),"data scientists.")
      )
  })

  ### TAble -----------

  table_data <- reactive({
    filtered_data() %>%
      dplyr::arrange(job_order) %>%
      dplyr::select(
        Rating = eoy_rating,
        `Job title` = job_level,
        `Grade` = grade,
        Manager = manager,
        Location = location
      )
  })

  output$table_rating <-  gt::render_gt({
    table_data() %>%
      dplyr::group_by(Rating) %>%
      dplyr::summarise(
        People = dplyr::n()
      ) %>%
      dplyr::left_join(
        config$eoy_rating_levels,
        by = c("Rating" = "eoy_rating_levels")
      ) %>% dplyr::arrange(order) %>% dplyr::select(-order) %>%
      dplyr::mutate(
        `%` = People / sum(People)
      ) %>%
      gt::gt() %>%
      gt::tab_header(
        "Overall number of people by rating"
      ) %>%
      gt::fmt_percent(
        columns = `%`,
        decimals = 0
      )
  })

  output$table_rating_manager <-  gt::render_gt({
    table_data() %>%
      dplyr::group_by(Manager,Rating) %>%
      dplyr::summarise(
        People = dplyr::n()
      ) %>% dplyr::group_by(Manager) %>%
      dplyr::left_join(
        config$eoy_rating_levels,
        by = c("Rating" = "eoy_rating_levels")
      ) %>% dplyr::arrange(order) %>% dplyr::select(-order) %>%
      dplyr::mutate(
        `%` = People / sum(People)
      ) %>%
      gt::gt(groupname_col = "Manager") %>%
      gt::tab_header(
        "Overall number of people by rating by manager"
      ) %>%
      gt::fmt_percent(
        columns = `%`,
        decimals = 0
      ) %>%
      gt::tab_options(
        row_group.background.color = "grey"
      )
  })

  output$table_rating_location <-  gt::render_gt({
    table_data() %>%
      dplyr::group_by(Location,Rating) %>%
      dplyr::summarise(
        People = dplyr::n()
      ) %>% dplyr::group_by(Location) %>%
      dplyr::left_join(
        config$eoy_rating_levels,
        by = c("Rating" = "eoy_rating_levels")
      ) %>% dplyr::arrange(order) %>% dplyr::select(-order) %>%
      dplyr::mutate(
        `%` = People / sum(People)
      ) %>%
      gt::gt(groupname_col = "Location") %>%
      gt::tab_header(
        "Overall number of people by rating by location"
      ) %>%
      gt::fmt_percent(
        columns = `%`,
        decimals = 0
      ) %>%
      gt::tab_options(
        row_group.background.color = "grey"
      )
  })

  output$table_rating_job <-  gt::render_gt({
    table_data() %>%
      dplyr::group_by(`Job title`,Rating) %>%
      dplyr::summarise(
        People = dplyr::n()
      ) %>% dplyr::group_by(`Job title`) %>%
      dplyr::left_join(
        config$eoy_rating_levels,
        by = c("Rating" = "eoy_rating_levels")
      ) %>% dplyr::arrange(order) %>% dplyr::select(-order) %>%
      dplyr::mutate(
        `%` = People / sum(People)
      ) %>%
      gt::gt(groupname_col = "Job title") %>%
      gt::tab_header(
        "Overall number of people by rating by job title"
      ) %>%
      gt::fmt_percent(
        columns = `%`,
        decimals = 0
      ) %>%
      gt::tab_options(
        row_group.background.color = "grey"
      )
  })

  output$table_rating_grade <-  gt::render_gt({
    table_data() %>%
      dplyr::group_by(Grade,Rating) %>%
      dplyr::summarise(
        People = dplyr::n()
      ) %>% dplyr::group_by(Grade) %>%
      dplyr::left_join(
        config$eoy_rating_levels,
        by = c("Rating" = "eoy_rating_levels")
      ) %>% dplyr::arrange(order) %>% dplyr::select(-order) %>%
      dplyr::mutate(
        `%` = People / sum(People)
      ) %>%
      gt::gt(groupname_col = "Grade") %>%
      gt::tab_header(
        "Overall number of people by rating by grade"
      ) %>%
      gt::fmt_percent(
        columns = `%`,
        decimals = 0
      ) %>%
      gt::tab_options(
        row_group.background.color = "grey"
      )
  })

  output$table_title <- gt::render_gt({
    table_data() %>%
      dplyr::group_by(`Job title`) %>%
      dplyr::summarise(
        People = dplyr::n()
      ) %>% dplyr::ungroup() %>%
      dplyr::left_join(
        config$job_levels,
        by = c("Job title" = "job_levels")
      ) %>% dplyr::arrange(order) %>% dplyr::select(-c(order)) %>%
      dplyr::mutate(
        `%` = People / sum(People)
      ) %>%
      gt::gt() %>%
      gt::tab_header(
        "Overall number of people by title"
      ) %>%
      gt::fmt_percent(
        columns = `%`,
        decimals = 0
      )
  })

}
