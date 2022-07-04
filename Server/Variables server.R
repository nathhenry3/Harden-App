# Variables server

# Actions when user is first signed in (priority higher than plotly libs)
observeEvent(input$hashed_cookie, {
  # Connect to database
  user_conn(first_load=TRUE)

  # Render datetime for variable input
  output$variableDateWidget <- renderUI({
    f7DatePicker('variablesDate', 
                 NULL,
                 value=as.Date(curr_datetime)
    )
  })
  
  # Render sliders
  output$sliders <- renderUI({
    sliders_UI(chosen_vars, as.character(as.Date(curr_datetime)))
  })
  
  # Set var to signal that first load has occurred
  first_load_done <<- TRUE
})

# Dynamically add variable sliders to Variables tab when in Variables tab. Also add streak length
observe(if (reactiveVal(input$mainTabs)() == 'Variables' & first_load_done) {
  # If user has recorded a relapse...
  if (nrow(Relapses_user) > 0) {
    # Render current streak length
    curr_streak_length() # Calculate streak length; found in 'Streak stats.R'
    output$varStreakLength <- renderUI({
      f7Align(h2(
        paste('Your current streak length is', streak_length, 'days. KEEP GOING!')),
        'center')
    })
  }
  
  # Render sliders
  output$sliders <- renderUI({
    sliders_UI(chosen_vars, as.character(as.Date(curr_datetime)))
  })
})

# Change slider values based on date that user enters
observeEvent(input$variablesDate, {
  output$sliders <- renderUI({
    sliders_UI(chosen_vars, as.character(input$variablesDate))
  })
})

# Toggle relapse popup when 'Relapsed?' button pressed
observeEvent(input$toggleRelapsePopup, {
  updateF7Popup(id='relapsePopup')
  
  # Render date widget
  output$relapseDateWidget <- renderUI({
    f7DatePicker('relapseDate', 
                 'Day:',
                 value=as.Date(curr_datetime)
    )
  })
})

# Update relapses to postgres
observeEvent(input$updateRelapse, {

  # Get user's input datetime
  input_datetime <- paste0(
    input$relapseDate,
    ' ', 
    input$relapseHour,
    ':00 UTC'
  )
  
  # Check that relapse date isn't in future
  if (as_datetime(input_datetime) > as_datetime(curr_datetime)) {
    
    f7Dialog(text="Relapse time can't be in the future!",
             title='',
             type='alert')
    
  } else {
    
    # Alert user
    f7Dialog(text='Saving relapse...please wait',
             title='',
             type='alert'
    )
    
    # Create df with data for update
    relapse_update <- tibble(UserID=User_ID,
                             RelapseDatetime=input_datetime,
                             PornUsed=input$relapsePorn)

    # Connect to Lifehack database
    conn <- lifehack_conn()
    
    # Append data to Variables table
    dbWriteTable(con=conn,
                name='relapses',
                value=relapse_update,
                append=TRUE,
                row.names=FALSE)
    
    # Let user know the data was saved
    f7Dialog(text="Relapse has been saved. Don't give up!",
             title='',
             type='alert'
             )
    
    # Rerun user_conn to update Variables_user etc. Also closes connection afterwards
    user_conn()
    
    # Render current streak length
    curr_streak_length() # Calculate streak length; found in 'Streak stats.R'
    output$varStreakLength <- renderUI({
      f7Align(h2(
        paste('Your current streak length is', streak_length, 'days. KEEP GOING!')),
        'center')
    })
  }
})

# Update variables to postgres
observeEvent(input$updateVariables, {
  # Check that relapse date isn't in future
  if (as.Date(input$variablesDate) > as.Date(curr_datetime)) {
    
    f7Dialog(text="You can't enter variables in the future! Please change the date to either today or sometime in the past.",
             title='',
             type='alert')
    
  } else {
    
    # Alert user
    f7Dialog(text='Saving data...please wait',
             title='',
             type='alert'
    )
    
    # Create df with data for update. Use var_names from chosen_vars
    var_update <- tibble(UserID=User_ID,
                         Datetime=as.character(input$variablesDate)
    )
    
    for (var in chosen_vars) { 
      # Check that var accordion was opened; if so, add to var_update
      if (input[[paste0(gsub(' ', '_', var), '_accord')]]$state) {
        var_update[1, var] <- input[[gsub(' ', '_', var)]] # gsub necessary for variables with spaces
      }
    }
    
    # Connect to Lifehack database
    conn <- lifehack_conn()
    
    if (as.character(input$variablesDate) %in% Variables_user$Datetime) {
      # Delete old row in Variables table. Needs sanitizing?
      dbSendQuery(conn,
                  paste0(
                    'DELETE FROM variables
                      WHERE "UserID" = \'', User_ID, '\'
                      AND "Datetime" = \'', input$variablesDate, '\';'))
    }
      
    # Append data to Variables table
    dbWriteTable(con=conn,
                 name='variables',
                 value=var_update,
                 append=TRUE,
                 row.names=FALSE)
      
    # Alert user
    f7Dialog(text='Data has been saved!',
             title='',
             type='alert'
    )
    
    # Rerun user_conn to update Variables_user etc. Also closes connection afterwards
    user_conn()
  }
})