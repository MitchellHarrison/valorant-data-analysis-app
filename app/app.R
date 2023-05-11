# import libraries
library(shiny)
library(googlesheets4)
library(tidyverse)
library(shinythemes)

# CONSTANTS -------------
DATA_URL <- paste("https://docs.google.com/spreadsheets/d/1EdN0USO2oTRaY77LUpd",
                  "uruFPNn_00L8Ea8wjGBiZybY/edit?usp=sharing", sep = "")

AGENTS <- c("Astra", "Breach", "Brimstone", "Chamber", "Cypher", "Fade",
            "Gekko", "Harbor", "Jett", "KAY/O", "Killjoy", "Neon", "Omen",
            "Phoenix", "Raze", "Reyna", "Sage", "Skye", "Sova", "Viper", "Yoru")


# UI --------------------
ui <- fluidPage(
  theme = shinytheme("slate"),
  titlePanel(h1("Valorant Explorer")),
  
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      selectInput("agent_select", "Select an agent:", 
                  choices = c("All", AGENTS), selected = "All")
    ),
    
    mainPanel = mainPanel(
      dataTableOutput("table")
    )
  )
)


# SERVER ----------------
server <- function(input, output){
  ranked_data <- reactive({read_sheet(DATA_URL)})
  
  output$table <- renderDataTable({
    if (input$agent_select == "All") {
      ranked_data()
    } else {
      ranked_data() |> filter(agent == input$agent_select)
    }
  })
}

# run the application
shinyApp(ui = ui, server = server)