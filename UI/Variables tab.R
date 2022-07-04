# Tab for variable input, relapses, etc. Home tab. 
f7Tab(
  tabName = "Variables",
  icon = f7Icon("keyboard"),
  active = TRUE,
  
  # Title
  f7Align(
    f7BlockTitle('Variables', 'large'),
    'center'),
    
  br(),
  
  # Current streak length (ADD BACK IN ONCE READY)
  # uiOutput('varStreakLength'),
  
  br(),
  
  # Add relapse popup, which is observed in the server
  f7Button(
    "toggleRelapsePopup", 
    "Relapsed?", 
    size='large',
    fill=TRUE,
    rounded=TRUE,
    color='deeppurple'
  ),
  
  f7Popup(
    id='relapsePopup',
    title=h2('When was your last relapse?'),
    closeButton=TRUE,
    
    # Choose relapse date
    uiOutput("relapseDateWidget"),
    
    # Choose relapse time
    f7Picker(
      'relapseHour', 
      'Hour of relapse (24 hour time):', 
      value="20:00", 
      choices=paste0(0:23, ":00")
    ),
    
    # Porn used?
    f7Picker(
      'relapsePorn',
      'Porn used:',
      value='Yes',
      choices=c('Yes', 'No')
    ),
    
    # Save relapse to database
    f7Button('updateRelapse', 
             'Save relapse',
             size='large',
             fill=TRUE,
             rounded=TRUE,
             color='deeppurple'),
    
    br(),
    
    # Motivational quote
    h3(motiv_quote)
  ),
  
  # Block for variable input
  f7Align(
    f7BlockTitle("How did your day go?",
               "medium"),
    "center"),
  
  f7Align(h4("If you don't want to save a variable, leave it closed!"), "center"),
  
  h4("Select day (you can overwrite old days):"),
  
  # Choose date for entering variables
  uiOutput('variableDateWidget'),
  
  h4("Enter variables:"),
  
  # Dynamic no. of sliders for variables
  withSpinner(uiOutput("sliders"),
              proxy.height='100px'),
  
  # Update variables button
  f7Button('updateVariables', 
           'Save data!',
           size='large',
           fill=TRUE,
           rounded=TRUE),
  
  f7Align(
    h3(motiv_quote),
    "center"),

  br(), br() # Always necessary at bottom
)