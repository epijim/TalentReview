library(TalentReview)
library(shiny)
library(bslib)
library(dplyr)
library(glue)
library(gt)

months_in_role_cuts <- c(12*3,12*6)

config <- read_config()
people <- read_people()

app_data <- enrich_people(
  people = people, config = config, months_in_role_cuts
)

source("www/card.R")



# cat(sapply(
#   highlights,
#   function(x)
#     paste0(
#       "<li>",x,"</li>"
#     )
# ))


