# This file contains general helper functions for use in the RMD files ######################################

###############

`%notin%` <- negate(`%in%`)

# Connect to Lifehack database
lifehack_conn <- function(db_choice = dbChoice) {
  if (db_choice == 'test') {
    connect <- tryCatch(
      dbConnect(
        drv=RPostgres::Postgres(),
        dbname='Lifehack',
        host='localhost',
        port=5432,
        user='nathan',
        password='nathan'),
      error = function(e) {print("Error connecting to database")})
  } else if (db_choice == 'production') {
      # Original method: ElephantSQL
    connect <- dbConnect(
        drv=RPostgres::Postgres(),
        dbname='unupnrpk',
        sslrootcert=here::here('Database manipulation', 'ElephantSQL_certs', 'SHA-2 Root USERTrust RSA Certification Authority.crt'), # Check elephantsql.com for instructions on how to download this
        host='otto.db.elephantsql.com',
        port=5432,
        user='user',
        password='password',
        sslmode='verify-full')
  } else {
    stop('No database type chosen. Test or production required?')
  }
  
  return(connect)
}

# Set general options for functions that use getOptions() functionality...
options(spinner.type=1 # Spinner type for withSpinner
        )

# Create function to pass to scale_y_continuous and scale_x_continuous, to force scales to use integers
integer_scale <- function(x) seq(ceiling(x[1]), floor(x[2]), by = 1)

# Create function to pass a blank graph with a text message at the centre, for graphs that don't meet the eval_paid criteria. 
blank_msg_graph <- function(message="Not enough data\nto plot graph!") {
  blank_plot <- ggplot() + 
    geom_text(data=tibble("text" = message), 
              aes(x=text, y=text, label=text),
              size=4.7) + 
    dark_theme_bw() + 
    theme(axis.text=element_blank(), 
          axis.ticks=element_blank(), 
          axis.title=element_blank(),
          panel.grid.major=element_blank(),
          panel.border=element_blank()
          )
  
  blank_plotly <- ggplotly(blank_plot,
                           height=400) %>% 
    plotly::config(displayModeBar=FALSE,
                   displaylogo=FALSE,
                   staticPlot=TRUE) %>% 
    style(hoverinfo='none') %>% 
    layout(yaxis=list(fixedrange=TRUE),
           xaxis=list(fixedrange=TRUE))
  
  return(blank_plotly)
}

# Create default ggplotly figures - remove bells and whistles etc
default_plotly <- function(gg_plot) {
  gg_plotly <- ggplotly(gg_plot,
                        height=400) %>%
    layout(legend = list(orientation = "h",
                         x = 0,
                         y = 1.1)) %>% # Orientate legend
    plotly::config(displayModeBar = 'hover',
                   displaylogo = FALSE,
                   modeBarButtonsToRemove = c("zoomIn2d", "zoomOut2d", 'hoverClosestPie', 'hoverClosestCartesian', 'hoverCompareCartesian', 'zoomInGeo', 'zoomOutGeo', 'autoScale2d', 'toggleSpikelines', 'select2d', 'lasso2d', 'pan2d', 'toImage')) %>%
    style(hoverinfo='none') %>% # Remove hoverinfo
    layout(yaxis=list(fixedrange=TRUE)) # remove y axis zoom
}

# Create default theme for plots
dark_theme_nh <- function(y_title=FALSE) {
  dark_theme_gray() %+replace%
    theme(
      panel.background = element_rect(color = "black"),
      panel.grid.major = element_line(color = "grey19", size = 0.2),
      panel.grid.minor = element_line(color = "grey19", size = 0.2),
      axis.ticks = element_blank())
      # axis.title.y = if (y_title) element_text() else element_blank())
}

# Create default colour schemes for plots, with each nested list containing both the bright and dark versions of colours, to favour colourblind. Based off https://davidmathlogic.com/colorblind/#%23D81B60-%231E88E5-%23FFC107-%23004D40
colour_scheme <- list(list('#FFC20A', '#0C7BDC'),
                      list('#1A85FF', '#D41159'),
                      list('#1AFF1A', '#D000E3'), 
                      list('#005AB5', '#FF8100')
)

# Create monochromatic duo colour schemes for default plots that don't have varying numbers of variables. Based off https://www.nceas.ucsb.edu/sites/default/files/2020-04/colorPaletteCheatsheet.pdf
colour_scheme_duo <- list(list('steelblue1', 'royalblue4'),
                          list('magenta', 'darkorchid4'),
                          list('green', 'green4'),
                          list('goldenrod1', 'yellow4'),
                          list('#FF2400', 'red2'))

# List of vars that every user starts with
start_vars <- c('Happiness', 'Urges', 'Productivity', 'Confidence', 'Anxiety')

# List of previous variables that users have listed
prev_vars <- sort(c('Motivation', 'Depression', 'Urges', 'Charisma', 'Confidence', 'Stress', 'Happiness', 'Self-acceptance', 'Anxiety', 'Guilt', 'Peace', 'Brain fog', 'Willpower', 'Extroversion', 'Energy', 'Concentration', 'Commitment', 'Focus', 'Sleep', 'Stamina', 'Strength'))

# Get user's chosen variable row
chosen_vars_row <- function(var_chosen) {
  return(VariablesMetadata_user %>% 
           filter(VariableName == var_chosen)
  )
}

# List of motivational quotes
motivate <- function() {
  quotes <- c(
    "\"The greatest glory in living lies not in never falling, but in rising every time we fall.\" -Nelson Mandela",
    "\"If life were predictable it would cease to be life, and be without flavor.\" -Eleanor Roosevelt",
    "\"The way to get started is to quit talking and begin doing.\" -Walt Disney",
    "\"If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success.\" -James Cameron",
    "\"It is during our darkest moments that we must focus to see the light.\" -Aristotle",
    "\"You will face many defeats in life, but never let yourself be defeated.\" -Maya Angelou",
    "\"Never let the fear of striking out keep you from playing the game.\" -Babe Ruth",
    "\"Life is either a daring adventure or nothing at all.\" -Helen Keller",
    "\"Many of life's failures are people who did not realize how close they were to success when they gave up.\" -Thomas A. Edison",
    "\"Success is not final; failure is not fatal. It is the courage to continue that counts.\" -Winston S. Churchill",
    "\"The real test is not whether you avoid this failure, because you won't. It's whether you let it shame you into inaction, or whether you learn from it; whether you choose to persevere.\" -Barack Obama",
    "\"I’ve missed more than 9,000 shots in my career. I’ve lost almost 300 games. 26 times I’ve been trusted to take the game winning shot and missed. I’ve failed over and over and over again in my life and that is why I succeed.\" -Michael Jordan",
    "\"The best time to plant a tree was 20 years ago. The second best time is now.\" -Chinese Proverb",
    "\"You can either experience the pain of discipline or the pain of regret. The choice is yours.\"  -Unknown",
    "\"The hard days are what make you stronger.\" -Aly Raisman",
    "\"I never lose. Either I win or learn.\" -Nelson Mandela",
    "\"The only thing standing in the way between you and your goal is the BS story you keep telling yourself as to why you can’t achieve it.\" -Jordan Belfort",
    "\"I always thought it was me against the world and then one day I realized it’s just me against me.\" -Kendrick Lamar",
    "\"The successful among us delay gratification. The successful among us bargain with the future.\" -Jordan Peterson",
    "\"Whether you think you can or think you can't, you're right.\" -Henry Ford",
    "\"Anyone who has ever made anything of importance was disciplined.\" -Andrew Hendrixson",
    "\"What you get by achieving your goals is not as important as what you become by achieving your goals.\" -Henry David Thoreau",
    "\"You must be the change you wish to see in the world.\" -Mahatma Gandhi",
    "\"Numbing the pain for a while will only make it worse when you finally feel it.\" -Albus Dumbledore",
    "\"I understood myself only after I destroyed myself. And only in the process of fixing myself, did I know who I really was.\" -Sade Andria Zabala",
    "\"It does not matter how slowly you go as long as you do not stop.\" -Confucius",
    "\"When everyone is sick, we no longer consider it a disease.\" -Naval Ravikant"
  )
  
  return(quotes[sample(1:length(quotes), 1)])
}
motiv_quote <- motivate() # Get motivational quote

# Render sliders UI for variables tab
sliders_UI <- function(chosenVars, chosenDate) {
  # Check Variables_user for chosenDate, which is input by user. If this date is found, then render sliders based on values in Variables_user
  # One slider for each chosen var
  lapply(seq_along(chosenVars), function(var) {
    f7Accordion(
      # Get id of accordion so you can select which vars to upload. Need to remove spaces from names
      id=paste0(gsub(' ', '_', chosenVars[var]), '_accord'),
      
      f7AccordionItem(
        title=chosenVars[var],
        # Open only if there is a value in Variables_user for specified date, if there is a value present, and if the value isn't NA. Need nested ifelse statements
        open=ifelse(length(Variables_user[Variables_user$Datetime == chosenDate, chosenVars[var]]) > 0,
                    ifelse(is.na(Variables_user[Variables_user$Datetime == chosenDate, chosenVars[var]]),
                           FALSE,
                           TRUE),
                    FALSE),
        
        # Create sliders for all types of variable
        f7Slider(inputId=gsub(' ', '_', chosenVars[var]), # gsub necessary for variables with spaces
                 label=ifelse(chosen_vars_row(chosenVars[var])$DataType != 'Binary (True or False)', 
                              chosen_vars_row(chosenVars[var])$DataType,
                              'Binary (0 = False, 1 = True)'), # If binary variable, need to rename to make clear to user
                 min=0,
                 max=chosen_vars_row(chosenVars[var])$UpperBound, # Even if two users share same column for variables table in postgres, they can have different UpperBounds via variables_metadata
                 value=ifelse(length(Variables_user[Variables_user$Datetime == chosenDate, chosenVars[var]]) > 0,
                              ifelse(is.na(Variables_user[Variables_user$Datetime == chosenDate, chosenVars[var]]),
                                     0,
                                     Variables_user[Variables_user$Datetime == chosenDate, chosenVars[var]]),
                              0), # If the user chooses an old date, select value for var for old date, otherwise select 0 as default
                 step=chosen_vars_row(chosenVars[var])$Increment,
                 scaleSteps=ifelse(chosen_vars_row(chosenVars[var])$DataType != 'Binary (True or False)', 
                                   4,
                                   1), # If binary, no scale steps
                 scaleSubSteps=0,
                 scale=TRUE),
          
        br(),br()
      )
    )
  })
}