
library(shiny)
library(tidyverse)
library(broom)
data("mtcars")

ui <- fluidPage(

    titlePanel("Explorador de datos"),

    sidebarLayout(
        sidebarPanel(
            submitButton(text = "Aplicar cambios"),
            selectInput("x_var",
                        "Selecciona la variable x:",
                        choices = c("cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", 
                                    "gear", "carb"),
                        selected = "wt"),
            selectInput("n_cyl",
                        "Número de cilindros para estudio:",
                        choices = c(4, 6, 8),
                        selected = c(4,6),
                        multiple = T),
            radioButtons("Theme",
                         "Elige tu estilo de ggplot:",
                         choices = c("Default", "Clásico", "Blanco y negro"),
                         selected = "Clásico"),
            radioButtons("Reg",
                         "Quieres hacer una regresión?",
                         choices = c("Si", "No"),
                         selected = "No"),
            textInput("Modelo",
                      "Agrega la formula de tu modelo lineal",
                      "mpg ~ wt"),
            uiOutput("Regresion")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("CarPlot"),
           dataTableOutput("CarTable"),
           dataTableOutput("Table2")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    mt <- reactive({
        mtcars %>% dplyr::filter(cyl %in% input$n_cyl)
    })

    output$CarPlot <- renderPlot({
     g <- ggplot(mt(), aes_string(x = input$x_var, y = "mpg")) + geom_point()
     if(input$Reg == "Si"){
         g <- g + stat_smooth(method = "lm", formula = input$Formula)
     }
     if(input$Theme == "Clásico"){
         g + theme_classic()
     }else if(input$Theme == "Blanco y negro"){
         g + theme_bw()
     }else if(input$Theme == "Default"){
         g
     } 
    })
        fit <- reactive({
            lm(as.formula(input$Modelo), data = mt())
        })
    output$CarTable <- renderDataTable({
        
        glance(fit()) %>% mutate_if(is.numeric, ~round(.x,2))
    })
    
    output$Table2 <- renderDataTable({
        tidy(fit())
    })
    
    output$Regresion <- renderUI({
        if(input$Reg == "Si"){
            textInput("Formula",
                      "Escribe tu formula",
                      "y ~ x")   
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
