
server <- function(input, output, session) {

  ## Filter data -------------------------------------------
  filtered_data <- reactive({
    i_data <- app_data %>%
      filter(
        job_level_desc %in% input$input_jobdesc &
        eoy_rating %in% input$input_eoy_rating &
        manager %in% input$input_manager
        )

    if (input$input_promotion == "Candidate") {
      i_data <- app_data %>%
        filter(
          promotion_readiness != "NA"
        )
    }

    validate(
      need(nrow(app_data) > 0, 'Too many filters applied! No one is left.')
    )

    i_data

  })

  ## Cards -------------------------------------------------

  output$cards <- renderUI({
    i_data <- filtered_data()
    # First make the cards
    args <-
      lapply(1:dim(i_data)[1], function(x)
        card(
          img = i_data[x, "photo_url"],
          name = i_data[x, "name"],
          job_level = i_data[x, "job_level_desc"],
          highlights_1 = i_data[x, "highlights"][[1]][[1]][1],
          highlights_2 = i_data[x, "highlights"][[1]][[1]][2],
          highlights_3 = i_data[x, "highlights"][[1]][[1]][3],
          dev_1 = i_data[x, "key_dev_areas"][[1]][[1]][1],
          dev_2 = i_data[x, "key_dev_areas"][[1]][[1]][2],
          dev_3 = i_data[x, "key_dev_areas"][[1]][[1]][3],
          months_in_role = i_data[x, "month_in_role"],
          rating = i_data[x, "eoy_rating_formatted"],
          job_colour = i_data[x, "job_colour"],
          promotion = i_data[x, "promotion"],
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

  ## Tables -------------------------------------------------

  table_data <- reactive({
    filtered_data() %>%
      select(
        Rating = eoy_rating,
        `Job title` = job_level_desc,
        `Grade` = job_level,
        Manager = manager
      )
  })

  output$table_rating <-  render_gt({
    table_data() %>%
      group_by(Rating) %>%
      summarise(
        People = n()
      ) %>%
      mutate(
        `%` = People / sum(People)
      ) %>%
      gt() %>%
      tab_header(
        "Overall number of people by rating"
        ) %>%
      fmt_percent(
        columns = `%`,
        decimals = 0
      )
  })

  output$table_rating_manager <-  render_gt({
    table_data() %>%
      group_by(Manager,Rating) %>%
      summarise(
        People = n()
      ) %>% group_by(Manager) %>%
      mutate(
        `%` = People / sum(People)
      ) %>%
      gt(groupname_col = "Manager") %>%
      tab_header(
        "Overall number of people by rating"
      ) %>%
      fmt_percent(
        columns = `%`,
        decimals = 0
      ) %>%
      tab_options(
        row_group.background.color = "grey"
      )
  })

  output$table_title <- render_gt({
    table_data() %>%
      group_by(`Job title`) %>%
      summarise(
        People = n()
      ) %>% ungroup() %>%
      mutate(
        `%` = People / sum(People)
      ) %>%
      gt() %>%
      tab_header(
        "Overall number of people by title"
      ) %>%
      fmt_percent(
        columns = `%`,
        decimals = 0
      )
  })

  ## Plots -------------------------------------------------

  output$ratings_labels <- renderPlot({
    filtered_data() %>%
      dplyr::select(userid, eoy_rating_clean, eoy_rating_formatted) %>%
      left_join(
        config$eoy_rating_levels,
        by = c("eoy_rating_clean" = "name")
      ) %>%
      mutate(
        score = case_when(
          eoy_rating_clean == eoy_rating_formatted ~ as.double(order),
          TRUE ~ order - 0.5
        )
      ) %>%
      arrange(score) %>%
      mutate(
        y = row_number()
      ) %>%
      ggplot2::ggplot() +
      ggplot2::geom_label(
        ggplot2::aes(
          x = score,y = y,label = userid,
          size = 4,
          fill = factor(userid)
        ),
        colour = "white", fontface = "bold",
        vjust="inward", hjust="inward",
        show.legend = FALSE
      ) +
      ggplot2::labs(
        title = "Team ratings",
        x = "Job levels",
        y = "People",
        subtitle = "More contribution needed <------> Exceptional"
      ) +
      ggplot2::theme_void()
  })

  output$levels_plot <- renderPlot({
    filtered_data() %>%
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
      ggthemes::theme_fivethirtyeight() +
      ggplot2::labs(
        title = "Team job level distribution",
        x = "Job levels",
        y = "People",
        subtitle = paste("Total team size =",nrow(app_data),"data scientists.")
      )
  })

  output$rating_manager <- renderPlot({
    filtered_data() %>%
      dplyr::group_by(eoy_rating, manager) %>%
      dplyr::summarise(
        n = n()
      ) %>%
      dplyr::mutate(
        order = factor(eoy_rating, config$eoy_rating_levels$name)
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
      dplyr::group_by(eoy_rating, job_level_desc) %>%
      dplyr::summarise(
        n = n()
      ) %>%
      dplyr::mutate(
        order = factor(eoy_rating, config$eoy_rating_levels$name)
      ) %>%
      ggplot2::ggplot(
        ggplot2::aes(
          x = order,
          y = n,
          fill = job_level_desc
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

  output$table <- DT::renderDataTable({
    DT::datatable(cars)
  })
}


