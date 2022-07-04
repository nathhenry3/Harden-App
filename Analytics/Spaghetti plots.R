# Spaghetti plots for Analytics Master file #################################################

# spag_basic() - selects individual variables (var_name) from spagdata and plots a comparison of their current streak to all their previous streaks. chosen_vars is passed as a global variable from 'Analytics Master.RMD'

spag_basic <- function(var_name, plot_type="basic") {
  
  # If number of data points is < 6/9/12 (depending on graph type), then don't run these functions
  if (plot_type %in% c('basic', 'mixed')) {
    if (nrow(select(Variables_user, var_name) %>% na.omit) < 6) {
      return(blank_msg_graph("You need at least 6 data points\nto view this graph!"))
    }
  }
  if (plot_type == 'mean_all') {
    if (nrow(select(Variables_user, var_name) %>% na.omit) < 9) {
      return(blank_msg_graph("You need at least 9 data points\nto view this graph!"))
    }
  }
  if (plot_type == 'before_after') {
    if (nrow(select(Variables_user, var_name) %>% na.omit) < 12) {
      return(blank_msg_graph("You need at least 12\ndata points to view\nthis graph!"))
    }
  }
  
  # If number of relapses < 2, then don't run these functions
  if (nrow(Relapses_user) < 2) return(blank_msg_graph("You don't have enough relapses\nto view this graph -\nthat's a good thing!"))
  
  # Add PMO variable to Relapses_user
  Relapses_user %<>% 
    mutate(PMO = 'Yes') %>% 
    group_by(PMO) %>% 
    mutate(PMO_count = sequence(n()))
  
  # Convert Variables_user Datetime column to add H:M:S so compatible with Relapses Datetime column
  Variables_user %<>%
    mutate(Datetime = paste(Datetime, "23:59:59"))
  
  # Join Variables to Relapses data for user, then add column to group by relapse number, as well as lubridate column and streak day column
  all_events <- full_join(Variables_user, Relapses_user, by=c('Datetime' = 'RelapseDatetime',
                                                              'UserID' = 'UserID')) %>%
    select(Datetime, all_of(chosen_vars), PMO, PMO_count) %>%
    arrange(Datetime) %>% 
    # mutate(Datetime=format(Datetime,"%Y-%m-%d %H:%M")) %>% # Uniform datetime format
    mutate(streak_day = NA_integer_, 
           streak_length = NA_integer_, 
           inverse_day = NA_integer_, 
           inverse_length = NA_integer_)
  
  # Fill in missing group values for PMO_count, as well as day numbers originating from 0 for each streak ######################
  
  # Calculate streak length for each streak
  # For each value, if NA, replace with value above in column

  # if (is.na(all_events$PMO_count[1])) {
  #   all_events$PMO_count[1] <- 0
  # }
  
  for (i in 1:nrow(all_events)) {
    if (!is.na(all_events$PMO[i])) {
      # Set streak day beginning
      all_events$streak_day[i] <- all_events$Datetime[i]
    } else if (i > 1) {
      all_events$PMO_count[i] <- all_events$PMO_count[i-1]
      # Set datetime for relapse and recur while streak lasts
      all_events$streak_day[i] <- all_events$streak_day[i-1]
      # Get difftime
      all_events$streak_length[i] <- round(as.numeric(ymd_hms(all_events$Datetime[i]) - ymd_hms(all_events$streak_day[i-1]),
                                                              units = "days"), 2)
    }
  }
  
  # Calculate days from streak ending for each streak
  
  for (i in (nrow(all_events)):1) {
    if (!is.na(all_events$PMO[i])) {
      # set datetime for streak ending
      all_events$inverse_day[i] <- all_events$Datetime[i]
    } else if (i < nrow(all_events)) {
      # Set inverse datetime for relapse and recur while streak lasts
      all_events$inverse_day[i] <- all_events$inverse_day[i+1]
      # Get difftime
      all_events$inverse_length[i] <- round(as.double(difftime(lubridate::ymd_hms(all_events$Datetime[i]),
                                                               lubridate::ymd_hms(all_events$inverse_day[i+1]),
                                                               units = "days")), 2)
    }
  }
  
  # Separate out previous streaks from current streak
  current_streak <- all_events %>% 
    filter(PMO_count == max(all_events$PMO_count, na.rm=TRUE)) %>% 
    mutate(colour_fill = 'Current streak')
  prev_streaks <- all_events %>% 
    filter(PMO_count != max(all_events$PMO_count, na.rm=TRUE)) %>% 
    mutate(colour_fill = 'Average of previous streaks')
  
  # Create colour scheme that updates automatically for number of variables
  # duo_scheme <- c(rep(colour_scheme[[2]][[2]],
  #                     length(chosen_vars)),
  #                 colour_scheme[[2]][[1]])
  
  # Clean events - unused?????
  # all_events_clean <- filter(all_events, is.na(PMO))

  ##############################################################################################################################
  
  #### Plot all streaks for each one of chosen_vars

  if (plot_type == 'basic') {
  
    # Create plot
    spag_plot <- ggplot(data=current_streak, aes(x=streak_length, y=!!sym(var_name), group=PMO_count, colour=as.factor(PMO_count))) +
      geom_line(linetype='solid', size=1) +
      geom_point() +
      geom_line(data=prev_streaks, aes(alpha=0.6), linetype='dotted') +
      geom_point(data=prev_streaks, aes(alpha=0.6)) +
      geom_vline(xintercept=0, colour='red') +
      # scale_y_continuous(breaks = integer_scale) +
      # scale_x_continuous(breaks = integer_scale) +
      # scale_colour_manual(values = duo_scheme) +
      xlim(0, NA) +
      labs(y=var_name,
           x="Length of streak (days)") +
      dark_theme_nh()
    
    spag_plotly <- default_plotly(spag_plot)

    # Modify legend
    spag_plotly$x$data[[1]]$name <- 'Current streak'
    spag_plotly$x$data[[3]]$name <- 'Previous streaks'
    if (max(all_events$PMO_count, na.rm=TRUE) > 2) {
      for (i in 4:(max(all_events$PMO_count, na.rm=TRUE)+1)) {
        spag_plotly$x$data[[i]]$showlegend <- FALSE
      }
    }
  }

  ###############################
  
  #### Plot current streak vs mean (plus smooth error bars) of previous streaks
  
  if (plot_type == 'mixed') {
  
    spag_plot <- ggplot() +
      geom_line(data=current_streak, 
                aes(x=streak_length, 
                    y=!!sym(var_name), 
                    fill=colour_fill, # Necessary for legend
                    colour=colour_fill, 
                    group=colour_fill)) +
      # Need to add geom_point eventually, but messes up legend...
      # geom_point(data=current_streak, aes(x=streak_length, y=!!sym(var_name), colour=colour_fill), size=0.5) +
      geom_smooth(data=prev_streaks, aes(x=streak_length, y=!!sym(var_name), fill=colour_fill, colour=colour_fill, group=colour_fill)) +
      geom_vline(xintercept=0, colour='red') +
      # scale_y_continuous(breaks = integer_scale) +
      # scale_x_continuous(breaks = integer_scale) +
      scale_colour_manual(values=c(colour_scheme[[3]][[1]], colour_scheme[[3]][[2]])) +
      scale_fill_manual(values=c(colour_scheme[[3]][[1]], colour_scheme[[3]][[2]])) +
      xlim(0, NA) +
      labs(y=var_name,
           x="Length of streak (days)") +
      dark_theme_nh()
  
    spag_plotly <- default_plotly(spag_plot)
  }
  
  ###############################
  
  #### Plot mean of all streaks 
  
  if (plot_type == 'mean_all') {
  
    spag_plot <- ggplot(all_events, aes(x=streak_length, y=!!sym(var_name), fill='orange', colour='orange', group=1)) +
      geom_smooth() +
      geom_point() +
      geom_vline(xintercept=0, colour='red') +
      # scale_y_continuous(breaks = integer_scale) +
      # scale_x_continuous(breaks = integer_scale) +
      scale_colour_manual(values=c(colour_scheme[[4]][[2]])) +
      scale_fill_manual(values=c(colour_scheme[[4]][[2]])) +
      xlim(0, NA) +
      labs(y=var_name,
           x="Length of streak (days)") +
      dark_theme_nh() +
      theme(legend.position = 'none')
    
    spag_plotly <- default_plotly(spag_plot)
  }
  
  ###############################
  
  #### Plot mean of all streaks before/after relapse

  if (plot_type == 'before_after') {
    
    spag_plot <- ggplot(all_events) +
      geom_smooth(aes(x=inverse_length, y=!!sym(var_name), fill='Before', colour='Before')) +
      geom_point(aes(x=inverse_length, y=!!sym(var_name), fill='Before', colour='Before')) +
      geom_smooth(aes(x=streak_length, y=!!sym(var_name), fill='After', colour='After')) +
      geom_point(aes(x=streak_length, y=!!sym(var_name), fill='After', colour='After')) +
      geom_vline(xintercept=0, colour='red') +
      scale_colour_manual(values=c(colour_scheme[[4]][[2]], colour_scheme[[4]][[1]])) +
      scale_fill_manual(values=c(colour_scheme[[4]][[2]], colour_scheme[[4]][[1]])) +
      coord_cartesian(ylim=c(min(all_events[[var_name]], na.rm=TRUE), 
                             max(all_events[[var_name]], na.rm=TRUE))) +
      # scale_y_continuous(breaks = integer_scale) +
      labs(y=var_name,
           x="Days before/after relapse") +
      dark_theme_nh()
    
    spag_plotly <- default_plotly(spag_plot)
  }
  
  ###############################
  
  # Return correct plot
  return(spag_plotly)
 
}