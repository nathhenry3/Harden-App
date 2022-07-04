# This file contains code for a weekday analysis of the variables

weekday_stats <- function(var_name) {

  if (nrow(select(Variables_user, var_name) %>% na.omit) < 15) return(blank_msg_graph("You need at least 15 data points\nto view this graph!"))
  
  weekdays <- Variables_user %>% 
    mutate('Weekday' = wday(Datetime, label=TRUE))

  weekday_plot <- weekdays %>% 
    ggplot(aes(x=Weekday, y=!!sym(var_name), fill=Weekday, colour=Weekday, alpha=0.2)) +
    geom_boxplot() +
    geom_jitter(width = 0.03) +
    labs(y=var_name) +
    scale_fill_discrete() +
    scale_colour_discrete() +
    dark_theme_nh() +
    theme(legend.position='none')
  
  weekday_plotly <- default_plotly(weekday_plot)

  return(weekday_plotly)
}
  
