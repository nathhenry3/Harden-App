# This file contains code to connect to the Lifehack Postgres database.

user_conn <- function(connect=TRUE, userid=User_ID, first_load=FALSE) {

  # Connect to Lifehack database
  if (connect) conn <- lifehack_conn()

  # Filter for data only from User ID.
  Variables_user <<- dbGetQuery(conn, paste0('select * from variables where "UserID" = \'', userid, '\''))
  VariablesMetadata_user <<- dbGetQuery(conn, paste0('select * from variables_metadata where "UserID" = \'', userid, '\''))
  Relapses_user <<- dbGetQuery(conn, paste0('select * from relapses where "UserID" = \'', userid, '\''))
  Email_user <<- dbGetQuery(conn, paste0('select * from email where "UserID" = \'', userid, '\''))
  Privacy_user <<- dbGetQuery(conn, paste0('select * from privacy where "UserID" = \'', userid, '\''))
  
  # If no variables_metadata present (AND it's their first load), then create variables for user
  if (nrow(VariablesMetadata_user) == 0 & first_load) {
    # Add default variables to variables_metadata table
    default_vars <- tibble(
      'UserID' = rep(userid, 5),
      'VariableName' = start_vars,
      'DataType' = rep('Slider (0-10)', 5),
      'UpperBound' = rep(10, 5),
      'Increment' = rep(0.25, 5)
    )
    dbWriteTable(
      con=conn,
      name='variables_metadata',
      value=default_vars,
      append=TRUE,
      row.names=FALSE
    )
    
    # Reload VariablesMetadata_user
    VariablesMetadata_user <<- dbGetQuery(conn, paste0('select * from variables_metadata where "UserID" = \'', userid, '\''))
    
    # Add email address to the Email table
    email_data <- tibble(
      'UserID' = userid,
      'Email_address' = email_address,
      'Subscribed_daily' = TRUE
    )
    dbWriteTable(
      con=conn,
      name='email',
      value=email_data,
      append=TRUE,
      row.names=FALSE
    )
  }
  
  # Close database connection
  dbDisconnect(conn)

  #########################33
  
  # Get user's variables
  chosen_vars <<- VariablesMetadata_user %>% 
    select(VariableName) %>% 
    unlist(use.names=FALSE)

  # Get variables_metadata row for that chosen variable
  # rowChosenVars <- chosen_vars_row()
  
  ###############################################################################################################

  # Convert variables to numeric
  # Variables_data[, chosen_vars] <- sapply(Variables_data[, chosen_vars], as.numeric)
  Variables_user[, chosen_vars] <<- sapply(Variables_user[, chosen_vars], as.numeric)
}

# Get chosen_vars only
user_conn_chosen_vars <- function(userid = User_ID) {
  # Connect to db
  conn <- lifehack_conn()
  
  # refresh chosen_vars
  chosen_vars <<- dbGetQuery(conn, paste0('select * from variables_metadata where "UserID" = \'', userid, '\'')) %>% 
    select(VariableName) %>%
    unlist(use.names=FALSE)
  
  # Close db connection
  dbDisconnect(conn)
}