source("helper.R")


shinyServer(function(input, output, session) {
  

  
  output$plot1 <- renderPlot({
    
    dat %>% dplyr::filter(votes.per > input$filtervotes[1]) %>% 
      dplyr::filter(votes.per < input$filtervotes[2]) %>% 
      dplyr::filter(election < input$dates[1]) %>% 
      dplyr::filter(election < input$dates[2]) %>% 
      dplyr::filter(party %in% input$selectedParty )-> plot_data
      
    p <- ggplot(plot_data,aes(x = votes.per,
                              y = seats.per,
                              color = party)) +
      geom_point(size = 2.5) +
      geom_path(size = 1) +
      labs(x = "Votes",
           y = "Seats") +
      theme_classic() +
      geom_abline(slope = 1,intercept = 0, linetype = "dashed") +
      scale_color_manual(values = colors) +
      geom_text_repel(aes(label = party_label)) + 
      annotate("text",
               x=Inf,
               y=-Inf,
               label = "UNDER REPRESENTED",
               color = "black",
               alpha = 0.9,
               vjust = -2, 
               hjust = 1.5,
               fontface = 2) + 
      annotate("text",
               x=-Inf,
               y=Inf,
               label = "OVER REPRESENTED",
               color = "black",
               alpha = 0.9,
               vjust = 2, 
               hjust = -0.5,
               fontface = 2) + 
      scale_y_continuous(labels=percent) +
      scale_x_continuous(labels=percent) 
    
      p
  })
  
})