# Relapse stats for 'Analytics Master.RMD' ########################################

# Put it all in a function so htmltools::tagList() works correctly in Analytics Master
relapse_stats <- function(graph_type = 'days') {
  
  # If number of relapses < 2, then don't run these functions
  if (nrow(Relapses_user) < 2) {
    return(blank_msg_graph("You don't have enough relapses\nto view this graph -\nthat's a good thing!"))
  }
  
  # Add weekdays
  Relapses_user %<>%
    arrange(RelapseDatetime) %>% 
    mutate(Weekday = wday(RelapseDatetime, label=TRUE)) %>% 
    mutate(Hour = hour(ymd_hms(RelapseDatetime)) %>% 
             factor(levels=as.character(0:24))) %>% 
    mutate(PornUsed_2 = case_when(PornUsed == 'Yes' ~ 'Porn Used',
                                  PornUsed == 'No' ~ 'No Porn'))
  
  # Days of relapse #######################################################################
  
  if (graph_type == 'days') {
    # Plot for relapse days
    relapse_days_plot <- Relapses_user %>% 
      ggplot(aes(Weekday, fill=PornUsed_2)) +
      labs(y="Number of relapses") +
      geom_histogram(stat='count', position='stack') + 
      scale_x_discrete(breaks = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'),
                       drop = FALSE) +
      # scale_y_continuous(breaks = integer_scale) +
      scale_fill_manual(name='Porn used', values = c(colour_scheme_duo[[1]][[1]], colour_scheme_duo[[1]][[2]])) +
      dark_theme_nh()
    
    gg_relapse <- default_plotly(relapse_days_plot)
  }
  
  # Hours of relapse ##############################################################3
  
  if (graph_type == 'hours') {
    # Plot for relapse times
    relapse_times_plot <- Relapses_user %>% 
      ggplot(aes(Hour, fill=PornUsed_2)) +
      labs(y="Number of relapses", x="Hour of relapse (24 hr time)") +
      geom_histogram(stat='count', position='stack') + 
      scale_x_discrete(breaks = seq(0, 24, 2),
                       labels = seq(0, 24, 2),
                       drop = FALSE) +
      scale_fill_manual(values = c(colour_scheme_duo[[2]][[1]], colour_scheme_duo[[2]][[2]])) +
      dark_theme_nh()
    
    gg_relapse <- default_plotly(relapse_times_plot)
  }
  
  # Streak length histogram ############################################################
  
  if (graph_type == 'hist') {
    
    # Need at least 2 relapses for streak lengths
    if (nrow(Relapses_user) < 2) {
      return(blank_msg_graph())
    }
    
    # Find streak lengths
    Relapses_user$streak_length <- NA_integer_
    for (i in 2:nrow(Relapses_user)) {
      Relapses_user$streak_length[i] <- round(as.double(difftime(lubridate::ymd_hms(Relapses_user$RelapseDatetime[i]),
                               lubridate::ymd_hms(Relapses_user$RelapseDatetime[i-1]),
                               units = "days")), 0)
    }
    
    # Convert to streak days (single digit)
    Relapses_user %<>% filter(!is.na(streak_length))
    max_streak <- max(Relapses_user$streak_length, na.rm=TRUE)
    # Relapses_user$streak_length %<>% 
    #   factor(levels=c(as.character(0:max_streak, na.rm=TRUE)))
    
    streak_hist_plot <- Relapses_user %>% 
      ggplot(aes(streak_length, fill='1')) +
      labs(y='Number of streaks', x='Length of streak (days)') +
      geom_histogram(stat='count') +
      scale_fill_manual(values=colour_scheme_duo[[4]][[1]]) +
      scale_x_continuous(
        breaks = function(x) seq(ceiling(x[1]), floor(x[2]), by = 2),
        labels = function(x) replace(x, x < 0, "")
      ) +
      scale_y_continuous(
        breaks = function(x) seq(ceiling(x[1]), floor(x[2]), by = 1)
      ) +
      dark_theme_nh() + 
      theme(legend.position='none')
    
    gg_relapse <- default_plotly(streak_hist_plot)
  }

  return(gg_relapse)
}
