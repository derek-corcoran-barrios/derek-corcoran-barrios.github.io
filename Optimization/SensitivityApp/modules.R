# modules.R

distributionPlotUI <- function(id) {
  tagList(
    plotly::plotlyOutput(NS(id, "distPlot"))
  )
}

distributionPlotServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    filtered_data <- reactive({
      data %>%
        filter(ContiguityBonus == input$bonus)
    })

    output$distPlot <- plotly::renderPlotly({
      ggplotly(
        ggplot(data, aes(x = ContiguityBonus, y = Biodiversity)) +
          geom_path() +
          geom_point(data = filtered_data(), size = 4) +
          theme_bw()
      )
    })
  })
}

sensitivityPlotUI <- function(id) {
  tagList(
    plotOutput(NS(id, "sensitivityPlot"))
  )
}

sensitivityPlotServer <- function(id, sensitivity) {
  moduleServer(id, function(input, output, session) {
    output$sensitivityPlot <- renderPlot({
      cols <- c("Biodiversity" = "red", "Contiguity" = "blue", "Equal" = "darkgreen")
      ggplot() +
        geom_spatraster(data = sensitivity[[names(sensitivity) == input$bonus]]) +
        theme_void() +
        scale_colour_manual(values = cols)
    })
  })
}
