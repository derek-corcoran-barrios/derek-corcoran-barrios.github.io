
library(shiny)
library(tidyverse)


ui <- fluidPage(


    titlePanel("Explorador de datos"),

    sidebarLayout(
        sidebarPanel(
            selectInput("y_var",
                        "Selecciona variable y:",
                        choices = c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", 
                                    "gear", "carb"),
                        selected = "wt"),
            selectInput("n_cyl",
                        "Selecciona tipos de cilidros:",
                        choices = c(4, 6, 8),
                        multiple = T,
                        selected = 6),
            radioButtons("Estilo",
                         "Selecciona estilo",
                         choices = c("default", "classic", "black and white", "dark"),
                         selected = "black and white"),
            radioButtons("Reg",
                         "Quieres hacer regresión?",
                         choices = c("Si", "No"),
                         selected = "No"),
            uiOutput("Regresion")
        ),
        mainPanel(
           plotOutput("distPlot"),
           downloadButton("GraficoDown", 
                          label = "Descargar gráfico"),
           dataTableOutput("MiTabla")
        )
    )
)

server <- function(input, output) {
    data("mtcars")
    mt2 <- reactive({
        mtcars %>% dplyr::filter(cyl %in% input$n_cyl)
                    })
    
    output$MiTabla <- renderDataTable({
        mt2()
    })
    
    output$Regresion <- renderUI({
        if(input$Reg == "Si"){
            textInput("Formula",
                      "Escribe tu formula",
                      "y ~ x")   
        }
    })

    output$distPlot <- renderPlot({
        g <- ggplot(mt2(), aes_string(x = "mpg", y = input$y_var)) + geom_point()
        if(input$Reg == "Si"){
            g <- g + stat_smooth(method = "lm", formula = input$Formula)
        }
        if(input$Estilo == "classic"){
           g + theme_classic()
           } else if(input$Estilo == "black and white"){
            g + theme_bw()
        }else if(input$Estilo == "dark"){
            g + theme_dark()
        }else{
            g
        }
        
    })
    
    output$GraficoDown <- downloadHandler(
        filename = function() {
            paste0("data-", Sys.Date(), ".png")
        },
        content = function(file) {
            g <- ggplot(mt2(), aes_string(x = "mpg", y = input$y_var)) + geom_point()
            if(input$Reg == "Si"){
                g <- g + stat_smooth(method = "lm", formula = input$Formula)
            }
            if(input$Estilo == "classic"){
                g + theme_classic()
            } else if(input$Estilo == "black and white"){
                g + theme_bw()
            }else if(input$Estilo == "dark"){
                g + theme_dark()
            }
            ggsave(file, plot = g, device = "png")
        }
    )
    
    
}



# Run the application 
shinyApp(ui = ui, server = server)
