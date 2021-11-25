card <- function(
  img, name, job_level,
  highlights_1,highlights_2,highlights_3,
  dev_1,dev_2,dev_3,
  months_in_role,
  rating,
  job_colour,
  promotion,
  # options
  months_in_role_cuts
) {

  # badge colours ------

  # months in role
  if (!is.na(months_in_role)){




    if (months_in_role < months_in_role_cuts[1]) {
      badge_colour <- "success"
    } else if (months_in_role < months_in_role_cuts[2]) {
      badge_colour <- "warning"
    } else {
      badge_colour <- "danger"
    }

    months_in_role_html <- glue::glue(
      '<span class="right badge badge-{badge_colour}" status="info">{months_in_role} months in role</span>'
    )
  } else {
    months_in_role_html <- ""
  }

  # rating
  if (!is.na(rating)){

    if (rating == config$eoy_rating_levels$name[1]) {
      badge_colour <- "warning"
    } else if (rating == config$eoy_rating_levels$name[length(config$eoy_rating_levels$name)]) {
      badge_colour <- "success"
    } else {
      badge_colour <- "info"
    }

    rating_html <- glue::glue(
      '<span class="right badge badge-{badge_colour}" status="info">{rating}</span>'
    )
  } else {
    rating_html <- ""
  }

  # promotion
  if (promotion != "Promotion readiness: NA"){

    promotion_html <- glue::glue(
      '<span class="right badge badge-primary" status="info">{promotion}</span>'
    )
  } else {
    promotion_html <- ""
  }

  # Html
  HTML(
    glue(
      '
      <div class="col-sm-4">
      <div class="card bg-{job_colour} card-widget user-card widget-user-2 shiny-bound-input" id="userbox">
        <div class="widget-user-header bg-{job_colour}">
        <div class="card-tools float-right">
        <button class="btn btn-tool btn-lg" type="button" data-card-widget="collapse">
        <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
        </button>
        </div>
        <div class="widget-user-image">
        <img class="img-circle" src="{img}" alt="User Avatar">
        </div>
        <h3 class="widget-user-username">{name}</h3>
        <h5 class="widget-user-desc">{job_level}</h5>
        </div>
        <div class="card-body">
        <h4>Highlights</h4>
        <p>{highlights_1}</p>
        <p>{highlights_2}</p>
        <p>{highlights_3}</p>
        <h4>Dev areas</h4>
        <p>{dev_1}</p>
        <p>{dev_2}</p>
        <p>{dev_3}</p>
        </div>
        <div class="card-footer">{rating_html} {months_in_role_html} {promotion_html} </div>
      </div>
      </div>'
    )
  )
}
