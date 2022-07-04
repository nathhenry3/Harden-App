# This file contains general streak statistics for Analytics Master.RMD ##################################

# Calculate current streak length and make global variable
curr_streak_length <- function() {
  # Render streak length if relapses have been added. This is also used by 'Streak stats.R'
  if (nrow(Relapses_user) != 0) {
    # Calc streak length
    streak_length <<- round(as.numeric(curr_datetime - ymd_hms(Relapses_user$RelapseDatetime[length(Relapses_user$RelapseDatetime)]),
                                       units='days'),
                            2)
  }
}

# Graphs for streak stats
streak_stats <- function(graph_type = 'streak') {
  # Create dataframe for current streak and previous streaks
  streak_df <- Relapses_user %>% 
    arrange(RelapseDatetime) %>% # Redundant?
    mutate(diff = round(ymd_hms(RelapseDatetime) - lag(ymd_hms(RelapseDatetime)), 2),
           streak_days = round(as.numeric(diff, units = 'days'), 2)) %>% 
    filter(!is.na(streak_days)) %>% 
    select(RelapseDatetime, streak_days)
  
  # If no relapses
  if (nrow(Relapses_user) == 0) {
    return(blank_msg_graph('You need to enter your\nlast relapse in the\nVariables tab to view\nthis graph!'))
  }
  
  # If 1 relapse only, then not enough streak data to plot graph, so just return streak length
  if (nrow(Relapses_user) != 0 & nrow(streak_df) == 0) return(blank_msg_graph(paste(streak_length, 'days. KEEP GOING!')))

  # Add row for current datetime.
  streak_df[nrow(streak_df) + 1, ] <- list(
    paste(as.character(curr_datetime), 'UTC'),
    round(as.numeric(curr_datetime - ymd_hms(streak_df$RelapseDatetime[nrow(streak_df)]), units='days'), 
      2)
    )
  
  # Add streak number
  streak_df$rownumber <- 1:nrow(streak_df)
  
  # Normal streak graph.....###################################################333
  
  if (graph_type == 'streak') {
    # Plot streak lengths as they vary over time
    streaks_plot <- streak_df %>%
      ggplot(aes(x=as_date(RelapseDatetime),
                 y=streak_days,
                 group=1,
                 label=streak_days)) +
      geom_line(colour=colour_scheme_duo[[3]][[1]], 
                size=1.1) +
      geom_point(colour=colour_scheme_duo[[3]][[1]], 
                 size=1.5) +
      # geom_text(data = filter(streak_df,
      #                         streak_days == last(streak_days)),
      #           colour=colour_scheme_duo[[3]][[1]],
      #           nudge_x=difftime(streak_df$RelapseDatetime[nrow(streak_df)], streak_df$RelapseDatetime[1])/23,
      #           nudge_y=max(streak_df$streak_days)/14,
      #           size=5) +
      # geom_area(fill=colour_scheme_duo[[3]][[1]], alpha=0.2, position='identity') +
      labs(x='Date of streak', y='Streak length (days)', title=paste(streak_length, "days. KEEP GOING!")) + # streak_length calculated from curr_streak_length(), above
      dark_theme_nh()
    
    # Ggplotly
    streaks_plotly <- default_plotly(streaks_plot)
    
    # Add tab title 
    streaks_plotly$tabTitle <- 'Length of streak'
  }
  
  # Mean streak graph...###### #####################################################
  
  if (graph_type == 'mean') {
    
    # Return blank_msg_graph() if less than 2 streaks
    if (nrow(streak_df) < 2) return(blank_msg_graph())
    
    # Add mean streak number over time
    for (i in 1:nrow(streak_df)) {
      # Get mean value of streaks thus far
      mean_streak_df <- streak_df %>% 
        filter(rownumber <= i)
      mean_streak <- sum(mean_streak_df$streak_days)/i
      
      # Add to dataframe
      streak_df$`Mean streak length`[i] <- round(mean_streak, 2)
    }

    # Plot mean streak length over time
    streaks_mean_plot <- streak_df %>% 
      ggplot(aes(x=as_date(RelapseDatetime),
                 y=`Mean streak length`,
                 group=1,
                 label=`Mean streak length`)) +
      geom_line(colour=colour_scheme_duo[[5]][[1]],
                size=1.1) +
      geom_point(colour=colour_scheme_duo[[5]][[1]], 
                 size=1.5) +
      # geom_text(data = filter(streak_df, 
      #                         `Mean streak length` == last(`Mean streak length`)),
      #           colour=colour_scheme_duo[[5]][[1]],
      #           nudge_x=difftime(streak_df$RelapseDatetime[nrow(streak_df)], streak_df$RelapseDatetime[1])/23,
      #           nudge_y=max(streak_df$`Mean streak length`)/14,
      #           size=5) +
      # geom_area(fill=colour_scheme_duo[[5]][[1]], alpha=0.2, position='identity') +
      labs(x='Date of streak', y='Mean streak length (days)', title=paste(last(streak_df$`Mean streak length`), 'days')) +
      dark_theme_nh()
    
    # Ggplotly
    streaks_plotly <- default_plotly(streaks_mean_plot)
    
    # Add tab title
    streaks_plotly$tabTitle <- 'Average streak length over time'
  }
  
  return(streaks_plotly)
}
