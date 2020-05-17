shinyUI(pageWithSidebar(
  headerPanel('Stats - Spain General Election'),
  sidebarPanel(
    checkboxGroupInput("selectedParty", 
                       h3("Checkbox group"), 
                       choices = opt_choices,
                       selected = c("PP","PSOE")),
    sliderInput('filtervotes', '% votes cutoff', c(0.025,0.16),
                 min = 0, max = 0.16, step = 0.005),
    dateRangeInput("dates", h3("Date range"))
  ),
  mainPanel(
    plotOutput('plot1')
  )
))

