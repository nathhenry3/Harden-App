# Contains the server code for Shiny.

server <- function(input, output, session) {
  # Customized disconnect screen
  sever(html=disconnected,
        bg_color="#000")
  session$allowReconnect(FALSE)
  # If user signs in, get their userid and email address
  User_ID <<- session$userData$user()$user_uid
  email_address <<- session$userData$user()$email
  
  # Get client's current time (linked to Javascript in ui.R). ALL TIMES ARE CONVERTED TO UTC - PRETEND ONLY UTC TIMEZONE
  client_time <<- as.numeric(input$client_time) / 1000 # in s
  time_zone_offset <<- as.numeric(input$client_time_zone_offset) * 60 # s from GMT
  curr_datetime <<- as_datetime(client_time - time_zone_offset)
  
  # Servers
  source(here::here('Server', 'Variables server.R'), local=TRUE)
  source(here::here('Server', 'Dashboard server.R'), local=TRUE)
  source(here::here('Server', 'Settings server.R'), local=TRUE)
  # source(here::here('Server', 'Instructions server.R'), local=TRUE)
}

###### ###### ###### ###### ###### ###### ###### ###### ######

# Secure server behind polished, and wrap in polished_payments
polished::secure_server(
  polishedpayments::payments_server(server),
  account_module = polishedpayments::app_module
  )

###### ###### ###### ###### ###### ###### ###### ###### ######