# Settings tab
f7Tab(
  tabName = "Settings",
  icon = f7Icon("person_circle"),
  active = FALSE,
  
  # Title
  f7Align(
    f7BlockTitle('Settings', 'large'),
    'center'),
  
  br(), br(),
  
  ## Add new variable from pre-made list
  
  f7Button(inputId="toggleAddVars", 
           label="Add new variable from list", 
           size='large',
           fill=TRUE,
           rounded=TRUE),
  f7Popup(id='addVars',
          title=h2('Add new variable from list'),
          closeButton=TRUE,
          
          "Choose a variable to add to your current list. All variables in the list below are scaled from 0 to 10.",
          
          br(),
          
          # Add variables from pre-chosen list
          f7Select('varSelect',
                   'Choose new variable from list:',
                   choices=prev_vars),
          
          # Confirm
          f7Button('varSelectConfirm',
                   'Add variable!',
                   fill=TRUE,
                   rounded=TRUE)
  ), 
  
  br(), br(),
  
  ## Add self-made variable
  
  f7Button(inputId="toggleAddNewVars", 
           label="Create your own variable", 
           size='large',
           fill=TRUE,
           rounded=TRUE),
  f7Popup(id='addNewVars',
          title=h2('Create your own variable'),
          closeButton=TRUE,
          
          "You can create a variable of your own choosing, with its own name, type and scale.",
          
          br(),
          
          # Add self-chosen variables
          f7Text('varCreate', 
                         'Name:',
                         placeholder='Enter the variable name here'),
          
          # Choose type of variable. This automatically sets increment also (0.25 for 0-10 or hour sliders, or 1 for minutes or Count)
          f7Select("varType",
                   "Choose type of variable:",
                   choices=c('Slider (0-10)',
                             'Slider (Hours)',
                             'Slider (Minutes)',
                             'Count',
                             'Binary (True or False)')),
          
          # Set upper bound for variable
          uiOutput('varUpperBoundSelect'),
          
          br(),
          
          # Confirm
          f7Button('varCreateConfirm',
                   'Create variable!',
                   fill=TRUE,
                   rounded=TRUE)
  ),
  
  br(), br(),
  
  ## Remove variable
  
  f7Button("toggleRemoveVars", 
           "Remove variable", 
           size='large',
           fill=TRUE,
           rounded=TRUE),
  f7Popup(id='removeVars',
          title=h2('Remove variable'),
          closeButton=TRUE,
          
          "This will permanently delete the chosen variable (and its data) from your current list of variables.",
          
          br(),
          
          # Choose vars to remove (list updates based on current state of chosen_vars)
          uiOutput("remVarList"),
          
          # Confirm
          f7Button('varRemoveConfirm',
                   'Remove variable!',
                   fill=TRUE,
                   rounded=TRUE)
  ),
  
  br(), br(), br(), br(),
  
  ## Email subscription settings
  
  f7Button('toggleEmailAlerts',
           'Email settings',
           size='large',
           fill=TRUE,
           rounded=TRUE,
           color='deeppurple'),
  
  f7Popup(
    id='emailAlerts',
    title=h2('Email settings'),
    closeButton=TRUE,
    
    "Choose whether to receive daily emails that alert you to enter your variables each day.",
    
    br(), br(),
    
    # Daily emails
    uiOutput('checkboxDailyEmail'),
    
    br(), br(), br(),
    
    # Confirm
    f7Button('emailSettingConfirm',
             'Confirm settings!',
             fill=TRUE,
             rounded=TRUE)
    ),
  
  br(), br(),
  
  ## Privacy settings
  
  f7Button('togglePrivacySettings',
           'Privacy settings',
           size='large',
           fill=TRUE,
           rounded=TRUE,
           color='deeppurple'),
  
  f7Popup(
    id='privacySettings',
    title=h2('Privacy settings'),
    closeButton=TRUE,
    
    h4("Occasionally we create blog posts based on the data provided by our users. This data is grouped and anonymized so it is impossible for users to be identified. We also use this data in the app to calculate global statistics, so you can compare your data with other Harden users."),
    
    br(), br(),
    
    # Choose whether to allow anonymous info to be public
    uiOutput('checkboxBlogPrivacy'),
    
    br(),
    
    uiOutput('checkboxGlobalPrivacy'),
    
    br(), 
    
    # Confirm
    f7Button('privacySettingConfirm',
             'Confirm settings!',
             fill=TRUE,
             rounded=TRUE),
    
    br(), br(),
    
    h4("The app will still work if you decide not to opt in to these settings, which can be modified at any time. You can access our Privacy Policy at hardenapp.com."),
    
    br(), br(), br(),
  ),
  
  br(), br(), br(), br(),
  
  ## Signout
  
  f7Button("signOut", 
           "Sign out", 
           size='large',
           fill=TRUE,
           rounded=TRUE,
           color='red'),
  
  br(), br(),
  
  ## Delete account & data
  
  f7Button('deleteAccount',
           'Delete account & data',
           size='large',
           fill=TRUE,
           rounded=TRUE,
           color='red'),
  
  br(), br(), br(),
  
  # Only 1 GITHUB commit per day, so you don't exceed Cloud Run build limits. Don't forget to change ui.R PWA settings, add polished auth and convert to production database!!!
  # Checks:
  # 1) Check production vs test database
  # 2) Dockerfile
  # 3) Check payment settings for stripe
  
  f7Align(h4("v1.0.3.4. © Harden Analytics"), 
          'center'),

  uiOutput('debug3'), # DELETE - used to debug date issues
  
  br(), br(), br(), br() # Must stay at end of tab
)