# Run this file to get the Shiny server running. This also serves as the base code for importing other functionality into the server/app.

# To profile: run this line in console - profvis::profvis(runApp(here::here()))

# Need to clear old variables
rm(list=ls())

# Setup - must be library calls for shiny server to work
# Edits here must be added to Dockerfile!!!
library(shinyMobile)
library(plotly)
# library(shinyWidgets) # Only uses prettyRadioButtons in a deprecated file?
library(dplyr)
library(lubridate)
library(ggdark)
library(here)
library(purrr) # Only uses negate in 'Helper functions.R'?
library(shinycssloaders)
# library(shinyjs) # Unused?
# library(shinyTime) # Unused?
library(RPostgres)
library(DBI)
library(zoo)
library(tidyr)
# library(Hmisc) # Unused?
library(magrittr)
library(shiny.pwa)
# library(firebase)
library(polished)
library(sever)
library(polishedpayments)

### Setup ############################################

###### ###### ###### ###### ###### ###### ###### ###### ######

# Polished authentication
# configure the global sessions when the app initially starts up.
polished::global_sessions_config(
  app_name = "harden",
  api_key = "api_key",
  firebase_config = list(
    apiKey = "apiKey",
    authDomain = "authDomain",
    projectId = "projectID"
  ),
  is_invite_required = FALSE,
  sign_in_providers = c("email"),
  is_email_verification_required = TRUE
)

# Configure sign-in page
custom_signin_page <- sign_in_ui_default(
  color = "#000000",
  company_name = "Harden",
  logo_top = tags$img(
    src = "harden_logo3.png",
    style = "width: 300px; margin-bottom: 15px; padding-top: 15px;"
  )
)

## Configure polished payments

# # Production config
polishedpayments::polished_payments_config(
  stripe_secret_key = 'stripe_secret_key',
  stripe_public_key = 'stripe_public_key',
  stripe_prices = c('stripe_prices'), # $5.00
  trial_period_days = 0,
  free_roles = 'free_user'
)

###### ###### ###### ###### ###### ###### ###### ###### ######

# Source analytics functions
source(here::here("Analytics", "Streak stats.R"))
source(here::here("Analytics", "Relapse stats.R"))
source(here::here("Analytics", "Timeseries plots.R"))
source(here::here("Analytics", "Spaghetti plots.R"))
source(here::here("Analytics", "Weekday analysis.R"))
source(here::here("Analytics", "Correlation stats.R"))

# Helper functions
source(here::here("Code preparation", "Helper functions.R"))

# Choose database to query - select either local Postgres ('test') or elephantSQL ('production')
dbChoice <- 'production'

# Load database
source(here::here("Database manipulation", "Database queries.R"))

# Variable to signal if first load occurred
first_load_done <<- FALSE

# Customise sever() page
disconnected <- sever_default(
  title = "Whoops!", 
  subtitle = "Your session has been disconnected. Check that your device is online, and reconnect.", 
  button = "Reconnect", 
  button_class = "info"
)
