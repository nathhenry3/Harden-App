# Instructions tab
f7Tab(
  tabName = "Instructions",
  icon = f7Icon("square_list"),
  active = FALSE,

  # Render instructions tab off website
  uiOutput("instructSite"),
  
  # Title
  f7BlockTitle('Instructions', 'large'),

  br(),

  # Explanatory text
  f7BlockTitle(title = "Variable input", size = 'medium'),
  f7Block(
    inset=TRUE,
    strong=TRUE,
    "Here comes paragraph within content block.
     Donec et nulla auctor massa pharetra
     adipiscing ut sit amet sem. Suspendisse
     molestie velit vitae mattis tincidunt.
     Ut sit amet quam mollis, vulputate
     turpis vel, sagittis felis."
  ),

  # FAQ
  f7BlockTitle(title="FAQ", size='medium'),
  f7Accordion(
    id='questions',
    f7AccordionItem(
      title='How do I input my variables?',
      "Open the 'Variable input' tab, and swipe to choose the value..."
    ),
    f7AccordionItem(
      title='How do I record a relapse?',
      "Open the relapse button..."
    )
  ),

  br(), br(), br() # Must stay at end of tab
)