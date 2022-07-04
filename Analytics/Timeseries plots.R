# Timeseries plots for 'Analytics Master.RMD' ########################################

# tseries_basic() - selects individual variables (var_name) from Variables_user and plots rolling mean. Then plots various messages
tseries_basic <- function(var_name) {
  # Only plot if 3+ data points
  if (nrow(select(Variables_user, var_name) %>% na.omit) < 3) return(blank_msg_graph("You need at least 3 data points\nto view this graph!"))

  
  # Select data
  ts_data_obj <- Variables_user %>% 
    select(Datetime, !!var_name) %>% 
    na.omit()
  
  # Get rolling mean of data
  roll_mean_data <- tibble('Rolling mean' = rollapply(ts_data_obj[[var_name]], width = 7, FUN = mean, align = "center", partial = TRUE))
  
  # Combine rolling mean with original dataset, then pivot longer for ggplot
  comb_data <- ts_data_obj %>% 
    bind_cols(`Rolling average` = roll_mean_data$`Rolling mean`) %>% 
    mutate('Date' = ymd(Datetime)) %>% 
    pivot_longer(cols=c(!!var_name, `Rolling average`), names_to="orig_roll_names", values_to="orig_roll_values") %>% 
    mutate(orig_roll_labels = case_when(orig_roll_names == var_name ~ 'Daily value',
                                        TRUE ~ 'Rolling average'))
  
  # Plot
  combined_plot <- ggplot(data=comb_data, 
                          aes(x=Date, y=orig_roll_values, colour=orig_roll_labels, linetype=orig_roll_labels)) +
    geom_line() +
    geom_vline(xintercept=as.numeric(ymd_hms(Relapses_user$RelapseDatetime)), 
               colour='red',
               show.legend=TRUE) +
    geom_point(size=0.5) +
    geom_area(data=filter(comb_data, orig_roll_names == 'Rolling average'),
              aes(x=Date, y=orig_roll_values, fill=orig_roll_labels, alpha=orig_roll_labels)) +
    scale_colour_manual(values=c(colour_scheme[[1]][[1]], colour_scheme[[1]][[2]])) +
    scale_fill_manual(values=c(colour_scheme[[1]][[2]])) +
    scale_alpha_manual(values = c(0.2)) +
    scale_linetype_manual(values=c('solid', 'dotted')) +
    # scale_y_continuous(breaks = integer_scale) +
    labs(y=var_name) +
    dark_theme_nh()
  
  combined_plotly <- default_plotly(combined_plot)

  # Modify legend
  combined_plotly$x$data[[1]]$name <- 'Daily value'
  combined_plotly$x$data[[2]]$name <- 'Rolling average'
  for (i in 3:length(combined_plotly$x$data)) {
    combined_plotly$x$data[[i]]$showlegend <- FALSE
  }

  return(combined_plotly)
}
