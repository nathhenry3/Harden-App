# Correlations statistics for AnalyticsMaster.RMD ##############################################
corr_stats <- function(var_name, var_name_2=NULL, trend_type='Linear') {
  # Scatter plot with correlation...
  # Only perform if there are values to run correlation on...need at least 7 points
  corr_points <- Variables_user %>% 
    select(!!var_name, !!var_name_2) %>% 
    na.omit()
  
  if (nrow(corr_points) > 6) {
    scatter_corr <- Variables_user %>% 
      ggplot(aes(x=!!sym(var_name), y=!!sym(var_name_2), colour='', fill='')) +
      geom_jitter(width=0.2, height=0.2) +
      geom_smooth(method=ifelse(trend_type=='Linear', 'lm', 'loess')) +
      scale_colour_manual(values=c('#29B6F6')) +
      scale_fill_manual(values=c('#29B6F6')) +
      coord_cartesian(xlim=c(min(Variables_user[[var_name]], na.rm=TRUE),
                             max(Variables_user[[var_name]], na.rm=TRUE)),
                      ylim=c(min(Variables_user[[var_name_2]], na.rm=TRUE),
                             max(Variables_user[[var_name_2]], na.rm=TRUE))) +
      # scale_y_continuous(breaks = integer_scale) +
      dark_theme_nh() +
      theme(legend.position='none')
    
    scatter_corrly <- default_plotly(scatter_corr)
    return(scatter_corrly)
  } else {
    return(blank_msg_graph("You need at least 7 data points\nper variable to view this graph!"))
  }
  
}
