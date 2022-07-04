# Dashboard tab
f7Tab(
  tabName = "Dashboard",
  icon = f7Icon("graph_square"),
  active = FALSE,
  
  # Title
  f7Align(
    f7BlockTitle('Dashboard', 'large'),
    'center'),
  
  # Current streak length
  f7Accordion(
    id='streakDaysAccord',
    
    f7AccordionItem(
      title='Your current streak length is...',
      open=TRUE,
      # Plot with spinner
      withSpinner(plotlyOutput("streakDays")
      )
    )
  ),
  
  # Mean streak length
  f7Accordion(
    id='streakMeanAccord',
    
    f7AccordionItem(
      title='Your average streak length is...',
      withSpinner(plotlyOutput("streakMean")
      )
    )
  ),
  
  # Distribution of streak lengths
  f7Accordion(
    id='streakLengthAccord',
    
    f7AccordionItem(
      title='Distribution of streak lengths',
      withSpinner(plotlyOutput("streakLengths")
      )
    )
  ),
  
  # Relapse weekdays
  f7Accordion(
    id='relapseDaysAccord',
    
    f7AccordionItem(
      title='Relapses by weekday',
      withSpinner(plotlyOutput("relapseDays")
      )
    )
  ),
  
  # Relapse hours
  f7Accordion(
    id='relapseHoursAccord',
    
    f7AccordionItem(
      title='Relapses by hour',
      withSpinner(plotlyOutput("relapseHours")
      )
    )
  ),

  # Timeseries graphs
  f7Accordion(
    id='tseriesAccord',
    
    f7AccordionItem(
      title='Timeline of variables',

      # Choose var to plot
      uiOutput("tseriesSelect"),

      br(),
      
      # Plot with spinner
      withSpinner(plotlyOutput("tseriesGraph")
      )
    )
  ),
  
  # Spaghetti mixed graph
  f7Accordion(
    id='spagMixedAccord',
    
    f7AccordionItem(
      title='Current streak vs previous streaks',

      # Choose var
      uiOutput("spagMixedSelect"),

      br(),

      withSpinner(plotlyOutput("spagMixedGraph")
      )
    )
  ),

  # Mean all graph
  f7Accordion(
    id='meanAllAccord',
    
    f7AccordionItem(
      title='Average of all streaks',

      # Choose var
      uiOutput("meanAllSelect"),

      br(),

      withSpinner(plotlyOutput("meanAllGraph"))
    )
  ),
  
  # Before after relapse graph
  f7Accordion(
    id='beforeAfterAccord',
    
    f7AccordionItem(
      title='Before & after relapse',

      # Choose var
      uiOutput("beforeAfterSelect"),

      br(),

      withSpinner(plotlyOutput("beforeAfterGraph")
      )
    )
  ),

  # Weekday analysis
  f7Accordion(
    id='weekdayAccord',
    
    f7AccordionItem(
      title='Weekday analysis',

      # Choose var
      uiOutput("weekdaySelect"),

      br(),

      withSpinner(plotlyOutput("weekdayGraph")
      )
    )
  ),

  # Correlations
  f7Accordion(
    id='correlAccord',
    
    f7AccordionItem(
      title='Correlations between variables',

      # Choose vars
      uiOutput("xCorrelSelect"),
      uiOutput("yCorrelSelect"),
      
      # Choose type of plot
      f7Select(
        'trendType',
        'Type of trend:',
        selected='Linear',
        choices=c('Linear', 'Loess')
      ),

      br(),

      withSpinner(plotlyOutput("correlGraph")
      )
    )
  ),
  
  br(),

  f7Align(
    h3(motiv_quote),
    'center'),
    
  br(), br(), br() # Always necessary at the bottom
)