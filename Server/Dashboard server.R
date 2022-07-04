# Dashboard server

# Reactively open graphs only if their accordion is open. 

# # Load plotly libs on login (lowest priority)
# observeEvent(input$hashed_cookie, {
#   output$streakDays <- renderPlotly({
#     streak_stats()
#   })
# }, priority=-1)

# Generate streak length graph automatically if tab = dashboard
observe(if ((reactiveVal(input$mainTabs)() == 'Dashboard')) {
  output$streakDays <- renderPlotly({
    streak_stats()
  })
})

# Mean streak length
observe(if (input$streakMeanAccord$state) {
  output$streakMean <- renderPlotly({
    streak_stats('mean')
  })
})

# Distribution of streak lengths
observe(if (input$streakLengthAccord$state) {
  output$streakLengths <- renderPlotly({
    relapse_stats('hist')
  })
})  
  
# Relapse weekdays
observe(if (input$relapseDaysAccord$state) {
  output$relapseDays <- renderPlotly({
    relapse_stats()
  })
})

# Relapse hours
observe(if (input$relapseHoursAccord$state) {
  output$relapseHours <- renderPlotly({
    relapse_stats('hours')
  })
})

# Timeseries graphs
observe(if (input$tseriesAccord$state) {
  output$tseriesGraph <- renderPlotly({
    tseries_basic(input$tseriesVar)
  })
})

# Spaghetti mixed graph
observe(if (input$spagMixedAccord$state) {
  output$spagMixedGraph <- renderPlotly({
    spag_basic(input$spagMixedVar, 'mixed')
  })
})

# Mean all graph
observe(if (input$meanAllAccord$state) {
  output$meanAllGraph <- renderPlotly({
    spag_basic(input$meanAllVar, 'mean_all')
  })
})

# Before after graph
observe(if (input$beforeAfterAccord$state) {
  output$beforeAfterGraph <- renderPlotly({
    spag_basic(input$beforeAfterVar, 'before_after')
  })
})

# Weekday analysis graph
observe(if (input$weekdayAccord$state) {
  output$weekdayGraph <- renderPlotly({
    weekday_stats(input$weekdayVar)
  })
})

# Correlation graphs
observe(if (input$correlAccord$state) {
  output$correlGraph <- renderPlotly({
    corr_stats(input$xCorrelVar, input$yCorrelVar, input$trendType)
  })
})

# Render all 'f7Select' UIs for dashboard
observe(if (reactiveVal(input$mainTabs)() == 'Dashboard') {
  # Timeline select
  output$tseriesSelect <- renderUI({
    f7Select(
      'tseriesVar',
      'Choose variable to plot:',
      selected=chosen_vars[1],
      choices=chosen_vars
    )
  })
  
  # Spaghetti mixed select
  output$spagMixedSelect <- renderUI({
    f7Select(
      'spagMixedVar',
      'Choose variable to plot:',
      selected=chosen_vars[1],
      choices=chosen_vars
    )
  })
  
  # Mean all select
  output$meanAllSelect <- renderUI({
    f7Select(
      'meanAllVar',
      'Choose variable to plot:',
      selected=chosen_vars[1],
      choices=chosen_vars
    )
  })
  
  # Before after select
  output$beforeAfterSelect <- renderUI({
    f7Select(
      'beforeAfterVar',
      'Choose variable to plot:',
      selected=chosen_vars[1],
      choices=chosen_vars
    )
  })
  
  # Weekday select
  output$weekdaySelect <- renderUI({
    f7Select(
      'weekdayVar',
      'Choose variable to plot:',
      selected=chosen_vars[1],
      choices=chosen_vars
    )
  })
  
  # Correlations select
  output$xCorrelSelect <- renderUI({
    f7Select(
      'xCorrelVar',
      'Variable on x-axis:',
      selected=chosen_vars[1],
      choices=chosen_vars
    )
  })
  
  output$yCorrelSelect <- renderUI({
    f7Select(
      'yCorrelVar',
      'Variable on y-axis:',
      selected=chosen_vars[2], # If chosen_vars only has 1 var, this won't show
      choices=chosen_vars
    )
  })
})