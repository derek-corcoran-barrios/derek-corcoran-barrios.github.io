
library(shiny)
library(tidyverse)
data("mtcars")

ui <- fluidPage(

    titlePanel("Eficiencia de combustible de vehiculos"),
    sidebarLayout(
        sidebarPanel(
            selectInput("VarY",
                        "Selecciona tu variable y:",
                        choices = c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", 
                                    "gear", "carb"),
                        selected = "wt"),
            selectInput("Modelo", 
                        "Elije tu tipo de modelo:",
                        choices = c("lm", "gam", "loess"),
                        selected = "lm"),
            textInput(
                "Formula",
                "Escribe la formula de tu modelo:",
                "y~ x + I(x^2)"),
            checkboxGroupInput("Factores", "Transformar en factores:",
                               c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", 
                                 "gear", "carb"), selected = "am"),
            sliderInput("YLIM", 
                        "Elije tus limites del eje y:",
                        c(5,35),
                        min = 0,
                        max = 40,
                        step = 1),
            submitButton("Actualizar gráfico")
        ),
        mainPanel(
           plotOutput("distPlot"),
           dataTableOutput("Table")
        )
    )
)

server <- function(input, output) {

    output$distPlot <- renderPlot({
        
        MT2 <- as.data.frame(map_at(mtcars, factor, .at = input$Factores))
        
        ggplot(MT2, aes_string(x = input$VarY, y = "mpg")) + 
            stat_smooth(method = input$Modelo, formula = input$Formula) + 
            geom_point() +
            ylim(input$YLIM)
        
    })
    
    
    output$Table <- renderDataTable({
        mtcars
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
