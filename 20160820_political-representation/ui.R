shinyUI(pageWithSidebar(
  headerPanel('Stats - Spain General Election'),
  sidebarPanel(
    selectInput('group', 'Party or Coalition', c("party","coalition")),
    #checkboxGroupInput(),
    sliderInput('filtervotes', '% votes cutoff', c(0.025,0.16),
                 min = 0, max = 0.16, step = 0.005)
    
  ),
  mainPanel(
    plotOutput('plot1')
  )
))