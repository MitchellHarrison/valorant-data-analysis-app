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

MAPS <- c("Ascent", "Bind", "Breeze", "Fracture", "Haven", "Icebox", "Lotus",
          "Pearl", "Split")

OUTCOMES <- c("Win", "Loss", "Draw")

RANKS <- c("Iron 1", "Iron 2", "Iron 3", "Bronze 1", "Bronze 2", "Bronze 3",
           "Silver 1", "Silver 2", "Silver 3", "Gold 1", "Gold 2", "Gold 3",
           "Platinum 1", "Platinum 2", "Platinum 3", "Diamond 1", "Diamond 2",
           "Diamond 3", "Ascendant 1", "Ascendant 2", "Ascendant 3", 
           "Immortal 1", "Immortal 2", "Immortal 3", "Radiant")

# UI --------------------
ui <- fluidPage(
  theme = shinytheme("slate"),
  titlePanel(h1("Valorant Explorer")),
  
  sidebarLayout(
    sidebarPanel = sidebarPanel(width = 3,
      selectInput("module_select", "Select module:",
                  choices = c("Data Table Explorer", "Agent Analysis"),
                  selected = "Data Table Explorer"),
      
      # Data Table Explorer Module -----------------
      conditionalPanel(
        condition = "input.module_select == 'Data Table Explorer'",
        
        # checkboxes to toggle which data table filters are visible
        checkboxGroupInput("dt_filters_select", "Choose your filters:",
                           choices = c("Agent", "Map", "Game outcome", 
                                       "Post-game rank", "Kills", "Deaths", 
                                       "Assists", "Rounds won", "Rounds lost", 
                                       "Frag", "Date"),
                           inline = T),
        
        # toggle hiding missing vods
        checkboxInput("hide_missing_vod_selector", "Hide missing VODs"),
        
        # Data Table Categorical Selectors -------------------
        # agent
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Agent')",
          selectInput("agent_select", "Agent:", 
                      choices = c("All", AGENTS), selected = "All"),
        ),
        
        # map
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Map')",
          selectInput("map_select", "Map:",
                      choices = c("All", MAPS), selected = "All"),
        ),
        
        # game outcome
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Game outcome')",
          selectInput("outcome_select", "Outcome:",
                      choices = c("All", OUTCOMES), selected = "All")
        ),
        
        # post-game rank
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Post-game rank')",
          selectInput("rank_select", "Rank:", choices = c("All", RANKS),
                      selected = "All")
        ),
        
        # Data Table Range Selectors ------------------
        # kill count range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Kills')",
          sliderInput("kills_select", "Kills:", min = 0, max = 30,
                      value = c(0,30))
        ),
        
        # death count range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Deaths')",
          sliderInput("deaths_select", "Deaths:", min = 0, max = 30,
                      value = c(0,30))
        ),
        
        # assist count range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Assists')",
          sliderInput("assists_select", "Assists:", min = 0, max = 30,
                      value = c(0,30))
        ),
        
        # rounds won range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Rounds won')",
          sliderInput("roundw_select", "Rounds won:", min = 0, max = 16,
                      value = c(0,16))
        ),
        
        # rounds lost range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Rounds lost')",
          sliderInput("roundl_select", "Rounds lost:", min = 0, max = 16,
                      value = c(0,16))
        ),
        
        # frag range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Frag')",
          sliderInput("nfrag_select", "Frag:", min = 1, max = 5, value = c(1,5))
        ),
        
        # date range selector
        conditionalPanel(
          condition = "input.dt_filters_select.includes('Date')",
          dateRangeInput("date_selector", "Date:", start = "2023-01-01", 
                         end = "2023-05-31", min = "2023-01-01", 
                         max = "2023-05-31")
        )
      ),
      
      # Agent Module ----------------
      conditionalPanel(
        condition = "input.module_select == 'Agent Analysis'",
        selectInput("agent_select_agent", "Agent:", choices = AGENTS,
                    selected = "Astra")
      )
    ),
    
    mainPanel = mainPanel(
      # Data Table Module -----------------
      conditionalPanel(
        condition = "input.module_select == 'Data Table Explorer'",
        dataTableOutput("table")
      ),
      
      # Agent Module ----------------
      conditionalPanel(
        condition = "input.module_select == 'Agent Analysis'",
        uiOutput(outputId = "agent_module_agent_image")
      )
    )
  )
)


# SERVER ----------------
server <- function(input, output){
  ranked_data <- reactive({read_sheet(DATA_URL)})
  
  # render the filtered data table
  output$table <- renderDataTable({
    val <- ranked_data()
    
    # filters
    agent_select <- input$agent_select
    map_select <- input$map_select
    outcome_select <- input$outcome_select
    rank_select <- input$rank_select
    roundsw_min <- input$roundw_select[1]
    roundsw_max <- input$roundw_select[2]
    roundsl_min <- input$roundl_select[1]
    roundsl_max <- input$roundl_select[2]
    date_min <- input$date_selector[1]
    date_max <- input$date_selector[2]
    
    # apply filters
    val |>
      filter(
        case_when(
          agent_select != "All" ~ agent == agent_select,
          map_select != "All" ~ map == map_select,
          outcome_select != "All" ~ outcome == outcome_select,
          rank_select != "All" ~ rank_after_match == rank_select,
          input$hide_missing_vod_selector ~ !is.na(vod),
          TRUE ~ rank_after_match %in% RANKS
        ),
        kills <= input$kills_select[2] & kills >= input$kills_select[1],
        deaths <= input$deaths_select[2] & deaths >= input$deaths_select[1],
        assists <= input$assists_select[2] & assists >= input$assists_select[1],
        round_wins <= roundsw_max & round_wins >= roundsw_min,
        round_losses <= roundsl_max & round_losses >= roundsl_min,
        num_frag <= input$nfrag_select[2] & num_frag >= input$nfrag_select[1],
        date <= date_max & date >= date_min
      )
  })
  
  # render agent image in agent module
  output$agent_module_agent_image <- renderUI({
    img(src = paste("agents/", str_replace(input$agent_select_agent, "/", ""), 
                    ".png", sep = ""),
        height = 400)
  })
}

# run the application
shinyApp(ui = ui, server = server)