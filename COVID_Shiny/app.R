
library(shiny) # versión 1.7.1
library(DT) # versión 0.23
library(shinythemes) # versión 1.2.0
library(tidyverse) # versión 1.3.2
library(magrittr) # versión 2.0.3
library(lubridate) # versión 1.8.0
library(plotly) # versión 4.10.0
library(xts) # versión 0.12.1
library(dygraphs) # versión 1.1.1.6

# Define UI for application that draws a histogram
ui <- fluidPage(
  shinythemes::themeSelector(),
  titlePanel("Análisis de COVID-19"),
  sidebarLayout(
    sidebarPanel(
      dateInput("date1", "Fecha Inicio: ", value = "2020-01-24"),
      dateInput("date2", "Fecha Fin: ", value = today()),
      uiOutput("pais"), ## Rellenar desde server con países
      checkboxInput("logscale", "Log Y: ", value = F),
      sliderInput("alpha", "Selecciona el nivel de transparencia", min = 0, max = 0.3, value = 0.12)
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Tabla", dataTableOutput("contents")),
                  tabPanel("Plot 1", plotOutput("plot1")),
                  tabPanel("Plot 2", dygraphOutput("plot2")),
                  tabPanel("Plot 3", plotOutput("plot3")),
                  tabPanel("Plot 4" ,plotlyOutput("plot4"))
                  )
      )
    )
  )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  myoriginaldata <- reactive({
    datos <- read.csv("covid_19_clean_complete.csv", stringsAsFactors = F)
    
    colnames(datos) = c("Provincia_Estado",
                        "Pais_Region",
                        "Latitud", # N+ o S-
                        "Longitud", # E+ o W-
                        "Fecha",
                        "Confirmados",
                        "Muertos",
                        "Recuperados",
                        "Activos",
                        "WHO_Region"
    )
    datos$Fecha %<>% ymd()
    return(datos)
  })
  
  mydata <- reactive({
    return(myoriginaldata() %>% filter(between(Fecha, input$date1, input$date2)))
  })
  
  primer_contagio <- reactive({
    myoriginaldata() %>%
      group_by(Pais_Region) %>%
      filter(Confirmados > 0) %>%
      summarise(Primer_Contagio = min(Fecha - 1)) # Fecha de primer contacto de cada país
  })
  
  output$pais <- renderUI({
    countries <- mydata() %>%
      select(Pais_Region) %>%
      arrange(Pais_Region) %>%
      unique()
    selectInput("pais", "Selecciona el país: ", choices = countries)
    
  })
  
  output$contents <- renderDataTable({
    df <- mydata()
    datatable(df)
  })

  # Plot 1
  output$plot1 <- renderPlot({
    datos_por_fecha = aggregate(
      cbind(Confirmados, Muertos, Recuperados) ~ Fecha,
      data = mydata() %>% filter(Pais_Region == input$pais),
      FUN = sum)
    
    datos_por_fecha$Enfermos = datos_por_fecha$Confirmados - datos_por_fecha$Muertos - datos_por_fecha$Recuperados
    logy = ""
    ylims = c(0, 1.05 * max(datos_por_fecha$Confirmados))
    if(input$logscale){
      logy = "y"
      datos_por_fecha %<>%
        filter(Confirmados > 0)
      ylims = c(1, 1.05 * max(datos_por_fecha$Confirmados))
    }
    
    plot(Confirmados ~ Fecha, data = datos_por_fecha,
         col = "blue", type = "l", ylim = ylims,
         main = paste0("Casos documentados por día en ", input$pais),
         xlab = "Fecha", ylab = "Número de personas", log = logy)
    lines(Muertos ~ Fecha, data = datos_por_fecha, col = "red")
    lines(Recuperados ~ Fecha, data = datos_por_fecha, col = "green")
    legend("topleft", c("Confirmados", "Muertos", "Recuperados"),
           col = c("blue", "red", "green"), pch = 1, lwd = 2)
  })
  
  # Plot 2
  output$plot2 <- renderDygraph({
    datos_por_fecha = aggregate(
      cbind(Confirmados, Muertos, Recuperados) ~ Fecha,
      data = mydata() %>% filter(Pais_Region == input$pais),
      FUN = sum)
    
    datos_por_fecha$Enfermos = datos_por_fecha$Confirmados - datos_por_fecha$Muertos - datos_por_fecha$Recuperados
    datos_por_fecha_ts <- xts(x = datos_por_fecha[, 2:5],
                              order.by = datos_por_fecha$Fecha)
    
    dygraph(datos_por_fecha_ts) %>%
      dyOptions(labelsUTC = T, labelsKMB = T,
                fillGraph = T, fillAlpha = input$alpha,
                drawGrid = F, colors = "#FF2D55") %>%
      dyRangeSelector() %>%
      dyCrosshair(direction = "vertical") %>%
      dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2,
                  hideOnMouseOut = F) %>%
      dyRoller(rollPeriod = 2) %>%
      dyLegend(width = 850, hideOnMouseOut = F)
  })
  
  # Plot 3
  output$plot3 <- renderPlot({
    mydata() %>%
      filter(Fecha == ymd(input$date1)) %>%
      ggplot(aes(x = Longitud, y = Latitud)) +
      geom_point(aes(size = log(Confirmados + 1),
                     colour = log(Muertos + 1))) +
      coord_fixed() +
      theme(legend.position = "bottom")
  })
  
  # Plot 4
  output$plot4 <- renderPlotly({
    data_first = mydata() %>%
      inner_join(primer_contagio(), by = "Pais_Region") %>%
      mutate(Dias_Desde_PC = as.numeric(Fecha - Primer_Contagio)) %>%
      filter(Dias_Desde_PC >= 0) %>%
      group_by(Dias_Desde_PC, Pais_Region) %>%
      summarise(Confirmados = sum(Confirmados),
                Muertos = sum(Muertos),
                Recuperados = sum(Recuperados))
    
    data_first %>%
      filter(Pais_Region %in% c("Spain", "Italy", "China",
                                "US", "Germany", input$pais)) %>%
      ggplot(aes(x = Dias_Desde_PC, y = Confirmados)) +
      geom_line(aes(col = Pais_Region)) +
      xlab("Días desde el primer contagio") +
      ylab("Número de personas contagiadas") +
      ggtitle("Análisis por Cohortes") +
      theme(legend.position = "none") -> g
    ggplotly(g)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
