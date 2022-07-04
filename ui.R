# Contains the UI code for Shiny. 

ui <- f7Page(
  
  # Customized disconnect screen
  use_sever(),
  
  f7TabLayout(
    navbar=f7Navbar(
      title=f7Align(div(img(src='harden_logo3.png',
                    width='200px')), # Max width without clipping...
                    'center'), 
      hairline=TRUE,
      bigger=TRUE,
      transparent=TRUE,
      
      # Add ability to convert to PWA
      pwa("https://harden-hp2jvearza-uc.a.run.app/",
          "Harden",
          output="www",
          color='#000000',
          icon='www/harden_icon_512x512.png'
          )
    ),
    
    f7Tabs(
      id='mainTabs',
      # Source UI for tabs
      source(here::here('UI', 'Variables tab.R'), local=TRUE)$value,
      source(here::here('UI', 'Dashboard tab.R'), local=TRUE)$value,
      source(here::here('UI', 'Settings tab.R'), local=TRUE)$value
    )
  ),
  
  # Get client's timezone offset (linked to server.R)
  HTML('<input type="text" id="client_time" name="client_time" style="display: none;"> '),
  HTML('<input type="text" id="client_time_zone_offset" name="client_time_zone_offset" style="display: none;"> '),
  tags$script('
  $(function() {
    var time_now = new Date()
    $("input#client_time").val(time_now.getTime())
    $("input#client_time_zone_offset").val(time_now.getTimezoneOffset())
  });')
)

###### ###### ###### ###### ###### ###### ###### ###### ######

# Place behind authentication wall
polished::secure_ui(ui, 
                    sign_in_page_ui=custom_signin_page,
                    account_module_ui = polishedpayments::app_module_ui("account")
                    )

###### ###### ###### ###### ###### ###### ###### ###### ######