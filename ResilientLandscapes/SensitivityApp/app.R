
library(shiny)
library(tidyverse)
library(terra)
library(tidyterra)
library(plotly)
library(patchwork)
# Define UI for application that draws a histogram
OptimalLong <- read_csv("OptimalLong.csv")
Sensitivity <- terra::rast("LocalSensitivity.tif")
names(Sensitivity) <- stringr::str_remove_all(names(Sensitivity),"Bonus_")

Solutions <- terra::rast("LocalSolutions.tif")
names(Solutions) <- names(Sensitivity)[1:nlyr(Solutions)]
ui <- fluidPage(

    # Application title
    titlePanel("Sensitivity analysis"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(width = 2,
            sliderInput("bonus",
                        "Select contiguity bonus:",
                        min = 0,
                        max = 1.1,
                        value = 0,
                        step = 0.05)
        ),

        # Show a plot of the generated distribution
        mainPanel(width = 10,
           plotly::plotlyOutput("distPlot"),
           plotOutput("sensitivityPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  observeEvent(input$bonus, {
    filtered_data <- OptimalLong %>%
      filter(ContiguityBonus == input$bonus)

    # Update the distPlot using ggplotly
    output$distPlot <- plotly::renderPlotly({
      ggplotly(
        ggplot(OptimalLong, aes(x = ContiguityBonus, y = Contribution, group = Part)) + geom_path(aes(color = Part)) +
          geom_point(data = filtered_data, size = 4, aes(color = Part)) +
          theme_bw()
      ) |>
        layout(yaxis = list(range = c(28, 40), autorange = FALSE))
    })

    # Update the sensitivityPlot
    output$sensitivityPlot <- renderPlot({
      cols <- c("Biodiversity" = "red", "Contiguity" = "blue", "Equal" = "darkgreen")
      cols2 <- c("ForestDryRich" = '#8c510a', "ForestWetPoor" = '#d8b365',"ForestWetRich" = '#f6e8c3',"OpenDryRich" = '#c7eae5',"OpenWetPoor" = '#5ab4ac', "OpenWetRich" = '#01665e')
     G1 <-  ggplot() +
        geom_spatraster(data = Sensitivity[[names(Sensitivity) == input$bonus]]) +
        theme_void() +
        scale_colour_manual(values = cols) + theme(legend.position = "bottom")
     G2 <- ggplot() +
       geom_spatraster(data = Solutions[[names(Solutions) == input$bonus]]) +
       theme_void() +
       scale_colour_manual(values = cols2) + theme(legend.position = "right")
     patchwork::wrap_plots(G1, G2, ncol = 2)
    }, res = 120, width = 800, height = 600)
  })

  # Use req for input validation
  observe({
    req(input$bonus)
  })
}



# Run the application
shinyApp(ui = ui, server = server)
