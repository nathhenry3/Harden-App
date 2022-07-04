# Settings server

# # Send the theme to javascript
# observe({
#   session$sendCustomMessage(
#     type="ui-tweak",
#     message=list(os=input$theme 
#                  # skin=input$color
#     )
#   )
# })

# On first Settings load, if user hasn't already consented (i.e. no Privacy_user), ask for their consent to use data publicly
observe(if (reactiveVal(input$mainTabs)() == 'Settings' & nrow(Privacy_user) == 0) {
  updateF7Popup("privacySettings")
  
  # Render checkboxes based on settings_user
  output$checkboxBlogPrivacy <- renderUI({
    f7Checkbox('toggleBlogPrivacy',
               'Allow my data to be used anonymously for online blog posts?',
               value=TRUE)
  })
  
  output$checkboxGlobalPrivacy <- renderUI({
    f7Checkbox('toggleGlobalPrivacy',
               'Allow my data to be used anonymously within the app, for global statistics?',
               value=TRUE)
  })
})
  
# Toggle variable choice popups
observeEvent(input$toggleAddVars, {
  updateF7Popup(id='addVars')
})
observeEvent(input$toggleAddNewVars, {
  updateF7Popup(id='addNewVars')
})
observeEvent(input$toggleRemoveVars, {
  # Update list of vars to remove
  output$remVarList <- renderUI({
    f7Select("varRemove",
             "Remove variable from your current list:",
             choices=chosen_vars)
  })
  
  updateF7Popup(id='removeVars')
})

######################################333333

# Add selected variable to list of chosen vars
observeEvent(input$varSelectConfirm, {
  
  # Alert user
  f7Dialog(text='Adding variable...please wait',
           title='',
           type='alert'
  )
  
  # Connect to Lifehack database
  conn <- lifehack_conn()
  
  # Check if variable already present in variables_metadata
  var_present_check <- dbSendQuery(conn,
                                   'SELECT *
                                   FROM variables_metadata
                                   WHERE "UserID" = $1
                                   AND "VariableName" = $2 
                                   ;') %>% 
    dbBind(list(User_ID, input$varSelect)) %>% 
    dbFetch()

  # If variable not present, then add var_select to postgres table.
  if (nrow(var_present_check) == 0) {
    
    # Add chosen variable to variables_metadata in postgres
    var_select <- tibble('UserID' = User_ID,
                         'VariableName' = input$varSelect,
                         'DataType' = 'Slider (0-10)',
                         'UpperBound' = 10,
                         'Increment' = 0.25)
    dbWriteTable(con=conn,
                name='variables_metadata',
                value=var_select,
                append=TRUE,
                row.names=FALSE)
    
    # Add variable to the variables table in postgres if not already present
    curr_names <- dbGetQuery(conn,"SELECT column_name, data_type
                                 FROM   information_schema.columns
                                 WHERE  table_name = 'variables'") %>% 
      select(column_name) %>% 
      unlist(use.names=FALSE)
    
    # Possibly needs sanitizing??
    if (input$varSelect %notin% curr_names) {
      dbSendQuery(conn, paste0("ALTER TABLE variables
                             ADD COLUMN \"", input$varSelect, "\" NUMERIC;")
      )
    }
    
    # Alert user
    f7Dialog(text='Variable has been added!',
             title='',
             type='alert'
    )
    
    # Update variables, metadata etc, and closes connections
    user_conn()
        
  } else { 
    # Variable already present
    f7Dialog(text='Variable is already in use! Please add a different variable.',
             title='',
             type='alert'
    )
  }

})

#########################################33333

# If variable type is count or time slider, then allow user to select upper bound. Otherwise, set upper bound for them
observeEvent(input$varType, {
  if (input$varType %in% c('Slider (Hours)', 'Slider (Minutes)', 'Count')) {
    output$varUpperBoundSelect <- renderUI({
      f7Select("varUpperBound",
               "Set upper bound for variable:",
               choices=c(1:1000), # Must be integer
               10)
    })
  } else { 
    # Display nothing
    output$varUpperBoundSelect <- renderUI({
    })
  }
})

# Add self-created variable
observeEvent(input$varCreateConfirm, {
  
  # variable name check...
  if (nchar(input$varCreate) < 2) { # Var must have >1 chars
    f7Dialog(text='Your variable name must contain at least two letters, digits and/or spaces!',
             title='',
             type='alert'
    )
  } else if (grepl('[^[:alnum:] ]', input$varCreate)) { # name must contain all alphanumeric & spaces
    f7Dialog(text='Your variable name can only contain letters, digits and spaces!',
             title='',
             type='alert'
    )
  } else {
  
    # Alert user
    f7Dialog(text='Adding variable...please wait',
             title='',
             type='alert'
    )
    
    # Connect to Lifehack database
    conn <- lifehack_conn()
    
    # Check if variable already present in variables_metadata - sanitized SQL version
    var_present_check <- dbSendQuery(conn,
                                     'SELECT *
                                     FROM variables_metadata
                                     WHERE "UserID" = $1
                                     AND "VariableName" = $2 
                                     ;') %>% 
      dbBind(list(User_ID, input$varCreate)) %>% 
      dbFetch()
    
    # If variable not present, then add var_select to postgres table.
    if (nrow(var_present_check) == 0) {
      
      # Add dummy value so that case_when always has a value for upper_bound, even if input$varUpperBound doesn't exist
      upper_bound <- ifelse(is.null(input$varUpperBound), NA_real_, input$varUpperBound)
      
      # Add chosen variable to variables_metadata in postgres
      var_create <- tibble('UserID' = User_ID,
                           'VariableName' = input$varCreate,
                           'DataType' = input$varType,
                           'UpperBound' = case_when(input$varType == 'Slider (0-10)' ~ 10,
                                                    input$varType == 'Binary (True or False)' ~ 1, 
                                                    input$varType %in% c('Slider (Hours)', 'Slider (Minutes)', 'Count') ~ as.double(upper_bound)),
                           'Increment' = case_when(input$varType %in% c('Slider (0-10)', 'Slider (Hours)') ~ 0.25,
                                                   input$varType %in% c('Slider (Minutes)', 'Count', 'Binary (True or False)') ~ 1)
                           )
      
      dbWriteTable(con=conn,
                   name='variables_metadata',
                   value=var_create,
                   append=TRUE,
                   row.names=FALSE)
      
      # Add variable to the variables table in postgres if not already present
      curr_names <- dbGetQuery(conn,"SELECT column_name, data_type
                                   FROM   information_schema.columns
                                   WHERE  table_name = 'variables'") %>% 
        select(column_name) %>% 
        unlist(use.names=FALSE)
      
      if (input$varCreate %notin% curr_names) {
        dbSendQuery(conn, paste0("ALTER TABLE variables
                               ADD COLUMN \"", input$varCreate, "\" NUMERIC;")
        )
      }
      
      # Alert user
      f7Dialog(text='Variable has been added!',
               title='',
               type='alert'
      )
     
      # Update variables, metadata etc, and closes connections
      user_conn()
       
    } else { # Variable already present
      f7Dialog(text='Variable is already in use! Please add a different variable.',
               title='',
               type='alert'
      )
    }
  }
  
})

###################################33

# Confirm remove variable
observeEvent(input$varRemoveConfirm, {
  # Check with user
  f7Dialog(
    "varRemoveIsConfirmed",
    "All data for this variable will be deleted. Are you sure you want to continue?",
    text='',
    type='confirm'
  )
})

# Remove variable
observeEvent(input$varRemoveIsConfirmed, {
  if (input$varRemoveIsConfirmed) {
    # Alert user
    f7Dialog(text='Removing variable...please wait',
             title='',
             type='alert'
    )
    
    # Connect to Lifehack database
    conn <- lifehack_conn()
    
    # # Delete variables_metadata row
    dbSendQuery(conn,
                paste0(
                  'DELETE FROM variables_metadata
                      WHERE "UserID" = \'', User_ID, '\'
                      AND "VariableName" = \'', input$varRemove, '\';'))
    
    # # Delete variables_metadata row - sanitized SQL version
    # dbSendQuery(conn, 
    #             paste0(
    #               'DELETE FROM variables_metadata
    #                   WHERE "UserID" = $1
    #                   AND "VariableName" = $2;')) %>% 
    # dbBind(list(User_ID, input$varSelect))
    
    # Delete all values in 'variables'
    dbSendQuery(conn,
                paste0(
                  'UPDATE variables
                    SET "', input$varRemove, '" = NULL
                    WHERE "UserID" = \'', User_ID, '\';'
                ))
    
    # # Delete all values in 'variables' - sanitized SQL version
    # dbSendQuery(conn,
    #             paste0(
    #               'UPDATE variables 
    #                 SET "', input$varRemove, '" = NULL 
    #                 WHERE "UserID" = $1;'
    #             )) %>% 
    # dbBind(list(User_ID))
    
    # Update variables, metadata etc, and closes connections
    user_conn()
    
    # Alert user
    f7Dialog(text='Variable has been removed!',
             title='',
             type='alert'
    )
    
    # Update list of vars to remove
    output$remVarList <- renderUI({
      f7Select("varRemove",
               "Remove variable from your current list:",
               choices=chosen_vars)
    })
  }
})

#########################################################

## Email alerts
observeEvent(input$toggleEmailAlerts, {
  updateF7Popup('emailAlerts')
  
  # Render email setting based on settings_user
  output$checkboxDailyEmail <- renderUI({
    f7Checkbox('toggleDailyEmail',
               'Receive daily emails?',
               value=ifelse(nrow(Email_user) == 0,
                            TRUE,
                            Email_user$Subscribed_daily[1]))
  })
})

# Email settings popup
observeEvent(input$emailSettingConfirm, {
  
  # Alert user
  f7Dialog(text='Saving settings...please wait',
           title='',
           type='alert'
  )
  
  # Create df with data for update
  email_update <- tibble(UserID=User_ID,
                           Email_address=Email_user$Email_address[1],
                           Subscribed_daily=input$toggleDailyEmail # Consent to daily emails
  )
  
  # Connect to Lifehack database
  conn <- lifehack_conn()
  
  if (User_ID %in% Email_user$UserID) {
    # Delete old row in Email table. Needs sanitizing?
    dbSendQuery(conn,
                paste0(
                  'DELETE FROM email
                    WHERE "UserID" = \'', User_ID, '\';'))
  }
  
  # Append data to Email table
  dbWriteTable(con=conn,
               name='email',
               value=email_update,
               append=TRUE,
               row.names=FALSE)
  
  # Alert user
  f7Dialog(text='Settings have been saved!',
           title='',
           type='alert'
  )
  
  # Rerun user_conn to update Variables_user etc. Also closes connection afterwards
  user_conn()
})











## Privacy settings
observeEvent(input$togglePrivacySettings, {
  updateF7Popup('privacySettings')
  
  # Render checkboxes based on settings_user
  output$checkboxBlogPrivacy <- renderUI({
    f7Checkbox('toggleBlogPrivacy',
               'Allow my data to be used anonymously for online blog posts?',
               value=ifelse(nrow(Privacy_user) == 0, 
                            TRUE,
                            Privacy_user$Blog_consent[1]))
  })
  
  output$checkboxGlobalPrivacy <- renderUI({
    f7Checkbox('toggleGlobalPrivacy',
               'Allow my data to be used anonymously within the app, for global statistics?',
               value=ifelse(nrow(Privacy_user) == 0, 
                            TRUE,
                            Privacy_user$Global_consent[1]))
  })
})

# Privacy settings popup
observeEvent(input$privacySettingConfirm, {
  
  # Alert user
  f7Dialog(text='Saving settings...please wait',
           title='',
           type='alert'
  )
  
  # Create df with data for update
  privacy_update <- tibble(UserID=User_ID,
                       Blog_consent=input$toggleBlogPrivacy, # Consent to data in blogs
                       Global_consent=input$toggleGlobalPrivacy # Consent to data in global app stats
  )
  
  # Connect to Lifehack database
  conn <- lifehack_conn()
  
  if (User_ID %in% Privacy_user$UserID) {
    # Delete old row in Privacy table. Needs sanitizing?
    dbSendQuery(conn,
                paste0(
                  'DELETE FROM privacy
                    WHERE "UserID" = \'', User_ID, '\';'))
  }
  
  # Append data to Privacy table
  dbWriteTable(con=conn,
               name='privacy',
               value=privacy_update,
               append=TRUE,
               row.names=FALSE)
  
  # Alert user
  f7Dialog(text='Settings have been saved!',
           title='',
           type='alert'
  )
  
  # Rerun user_conn to update Variables_user etc. Also closes connection afterwards
  user_conn()
})

##########################################################

## Sign out
observeEvent(input$signOut, {
  sign_out_from_shiny()
  session$reload()
})

## Delete account & data
observeEvent(input$deleteAccount, {
  # No easy way to remove the tychobra person. Perhaps create another lifehack table that lets you know whether the user has signed out or not, then emails hardenapp@gmail.com on a daily basis with latest users to sign out, so you can remove manually. 
  f7Dialog(text='This button will work soon...if you really want me to delete your data then email hardenapp@gmail.com.',
           title='',
           type='alert'
  )
})