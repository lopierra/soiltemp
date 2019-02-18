library(shiny)
library(here)

source(here("soil_temp_data.R"))

ui <- fluidPage(
  titlePanel("Optimal soil temperatures for vegetable seed germination"),
  tabsetPanel(
    tabPanel(
      title = "Search by temperature",
      sidebarPanel(
      textInput("soiltemp", "Enter soil temperature in degrees F")
    ),
    mainPanel(
      h3("This is a good time to plant:"),
      tableOutput("soil_input_table")
    )
    ),
    tabPanel(
      title = "Search by crop",
      sidebarPanel(
        checkboxGroupInput("veg", label = "Select crop(s)", choices = soil_temp_data$crop)
      ),
      mainPanel(
        h3("Optimal soil temperatures for planting (degrees F):"),
        tableOutput("crop_input_table")
      )
    ),
    tabPanel(
      title = "Reference",
      h4("Data were obtained from"), 
      tags$a(href = "https://extension.oregonstate.edu/sites/default/files/documents/12281/soiltemps.pdf", 
             "https://extension.oregonstate.edu/sites/default/files/documents/12281/soiltemps.pdf"),
      br(),
      br(),
      h4("This app was created using"),
      tags$a(href = "https://shiny.rstudio.com/", "Shiny"),
      br(),
      tags$a(href = "https://www.tidyverse.org/", "tidyverse"),
      br(),
      tags$a(href = "https://github.com/ropensci/tabulizer", "tabulizer")
    )
  )
)

server <- function(input, output) {
  
  # search by temperature
  output$soil_input_table <- renderTable({
    req(input$soiltemp)
    
    # get germination times using reference temp closest to input temp 
    # (ref temps are 9 degrees apart, so use ref temp +/- 4 from input temp)
    nearest_ref_temp <- germination %>% 
      filter(((germination$ref_temp - 4) <= input$soiltemp) & 
               ((germination$ref_temp + 4) >= input$soiltemp))
    
    soil_temp_data %>% 
      filter(opt_min <= input$soiltemp & opt_max >= input$soiltemp) %>% 
      select(crop, opt_temp) %>% 
      rename(Crop = crop, "Optimal temp (F)" = opt_temp) %>% 
      left_join(nearest_ref_temp, by = "Crop") %>% 
      select(-ref_temp) %>% 
      rename("Approx. germination time (days)" = germ_time)
  })

  # search by crop
  output$crop_input_table <- renderTable({
    
    soil_temp_data %>% 
      filter(crop %in% input$veg) %>% 
      rename(Crop = crop, "Min. temp" = opt_min, "Max. temp" = opt_max, "Optimal temp" = opt_temp)
  })
  
}

shinyApp(ui = ui, server = server)