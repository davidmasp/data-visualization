source("helper.R")
library("dplyr")
library("scales")


colors <- list("Amaiur" = "#0198B3",
               "Bildu" = "#BDD016",
               "BNG" = "#6EC9FF",
               "CC" = "#FFED03", 
               "CDC" = "darkblue", 
               "Compromis" = "orange", 
               "Cs" = "#F17A36", 
               "EB" = "grey", 
               "ECP" = "blueviolet", 
               "EnMarea" = "blue4", 
               "EQUO"="green4", 
               "ERC" = "yellow1", 
               "Foro" = "royalblue4", 
               "GeroaBai" = "#4dff4d", 
               "IU" = "red2", 
               "PA" = "palegreen2", 
               "PACMA" = "palegreen4",
               "PNV" = "#419653",
               "PODEMOS" = "darkmagenta",
               "PP" = "dodgerblue3",
               "PRC" = "darkred",
               "PSOE" = "red2",
               "PxC" = "paleturquoise3",
               "UPYD" = "violetred1",
               "GeroaBai" = "seagreen1",
               "CiU" = "#000099",
               "DL" = "#0000b3",
               "UP" = "darkmagenta")


shinyServer(function(input, output, session) {
  
  
  output$plot1 <- renderPlot({
    
    # merging coalitions
    
    if (input$group == "coalition") {
      el.df <- el.df %>% group_by(coalition,election) %>% 
        summarise(sum(votes.per),sum(seats.per))
      el.df <- data.frame(el.df)
      colnames(el.df) <- c("coalition",
                          "election",
                          "votes.per",
                          "seats.per")
    }
    
    #filtering by votes range
    co <- input$filtervotes[1]
    up <- input$filtervotes[2]
    el.df <- dplyr::filter(el.df,votes.per > co & votes.per < up)
    
    
    # building the region
    tri.df <- data.frame(votes.per = c(0,1,
                                       1),
                         seats.per = c(0,1,0) ) 



    # plotting
    p <- ggplot(el.df, aes(votes.per,seats.per, color = el.df[,input$group])) + 
      geom_polygon(data = tri.df, 
                   alpha = 0.2, 
                   fill = "yellow", 
                   colour = "yellow") +
      geom_point(size = 2.5) +
      geom_path(size = 1) +
      geom_label_repel(aes(
        label=paste(el.df[,input$group],format(election,"%Y"),sep = " - "))) +
      theme_bw() + 
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
      coord_cartesian(
        xlim = c(min(el.df$votes.per), max(el.df$votes.per)), 
        ylim = c(min(el.df$seats.per), max(el.df$seats.per))) + 
      scale_y_continuous(labels=percent) +
      scale_x_continuous(labels=percent) 
    
      if (input$group == "coalition"){
        p
      } else {
        p +  scale_colour_manual(labels = unique(el.df[,input$group]),
                                 values = unlist(colors[el.df[,input$group]])
        ) 
      }
  })
  
})